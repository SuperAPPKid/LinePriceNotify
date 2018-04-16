from datetime import  datetime
from myserver.myRedis import myRedis
from collections import  namedtuple
from queue import Queue
from bs4 import BeautifulSoup
from apscheduler.schedulers.blocking import BlockingScheduler
import threading
import requests
import json

Shop = namedtuple("Shop","name url")
shopsList = {"ybid":Shop("Yahoo!奇摩拍賣","tw.bid.yahoo.com"),
             "shopee":Shop("蝦皮拍賣","shopee.tw"),
             "ruten": Shop("露天拍賣","www.ruten.com.tw"),
             "kingstone": Shop("金石堂網路書店", "www.kingstone.com.tw/"),
             "books": Shop("博客來", "www.books.com.tw"),
             "taaze": Shop("TAAZE讀冊生活", "www.taaze.tw"),
             "24hpchome": Shop("PChome24h購物", "24h.pchome.com.tw"),
             "ybuy": Shop("Yahoo奇摩購物中心", "tw.buy.yahoo.com"),
             "pchome": Shop("PChome線上購物", "mall.pchome.com.tw"),
             "gohappy": Shop("friDay購物", "shopping.friday.tw"),
             "udn": Shop("udn買東西購物中心", "shopping.udn.com"),
             "momoshop": Shop("momo購物網", "www.momoshop.com.tw")}
queue = Queue()
r = myRedis()


def gogoParser(queue):
    while queue.empty() is False:
        params = queue.get()
        print(threading.current_thread())
        url = "https://feebee.com.tw/all/"
        ansStr = ""


        for shop in params["pr[]"]:
            rule = params.copy()
            rule["pr[]"] = shop
            rule["token"] = None
            rule["index"] = None
            if rule["pl"] == 0 :
                rule["pl"] = None
            if rule["ph"] == 0 :
                rule["ph"] = None

            try:
                response = requests.get(url, rule)
            except requests.RequestException as e:
                print(e)

            try:
                bsObj = BeautifulSoup(response.text, "html.parser")
                row = bsObj.find("ol", {"id": {"list_view"}}).findAll("li", {"class": {"pure-g", "items"}},recursive=False)
                count = 0
                recommend = {}
                for item in row:
                    if item.h3 != None:
                        count += 1
                        if count == 1:
                            if item.ul.li["class"][0] == "bid_price":
                                recommend["price"] = item.find("span", {"class": {"xlarge"}}).text.replace(",", "")
                            else:
                                recommend["price"] = item.find("span", {"class": {"price_title"}}).next_sibling.replace(",", "")
                            recommend["url"] = item.find("span", {"class": {"img_container"}}).a["href"]
                shop = rule["pr[]"]
                if count >= 30:
                    ansStr += shopsList[shop].name + "\n有多筆資料\n" + "最便宜的：$" + recommend["price"] + "元\n" + recommend["url"] + "\n"
                else:
                    ansStr += shopsList[shop].name + "\n有" + str(count) + "筆資料\n" + "最便宜的：$" + recommend["price"] + "元\n" + recommend["url"] + "\n"
            except AttributeError:
                print("AttributeError")
            except ValueError:
                print("ValueError")

        if len(ansStr) != 0:
            token = params["token"]
            index = params["index"]
            if params["ph"] == 0:
                titleStr = "\n-- " + params["q"] + " --\n$" + str(params["pl"]) + "元 ~ ???元 \n"
            else:
                titleStr = "\n-- " + params["q"] + " --\n$" + str(params["pl"]) + "元 ~ $" + str(params["ph"]) + "元 \n"
            print(token,(titleStr + ansStr))
            response = gogoNotify(token,(titleStr + ansStr))
            if json.loads(response)["status"] != 200:
                r.lrem("token",token , 0)
                r.delete(token)
                continue
            else:
                r.lset(token, index, "del")


def gogoNotify(token,notifyStr):
    url = "https://notify-api.line.me/api/notify"
    header = {"Authorization": "Bearer " + token}
    data = { "message":  notifyStr }
    res = requests.post(url, headers=header, data=data)
    return res.text

def main():
    starttime = datetime.now()
    print("---------------------------------------------Start---------------------------------------------")
    tokens = r.lrange("token", 0, -1)
    for token in tokens:
        r.lrem(token, "del", 0)
        contents = r.lrange(token, 0, -1)
        for index, content in enumerate(contents):
            data = json.loads(content)
            params = {"q": data["title"],
                      "pl": data["lowPrice"],
                      "ph": data["highPrice"],
                      "sort": "p",
                      "pr[]":data["shops"],
                      "page": 1,
                      "token":token,
                      "index":index}
            queue.put(params)

        threads = []
        for n in range(101):
            threads.append(threading.Thread(target=gogoParser, args=(queue,)))
        for t in threads:
            t.start()
        for t in threads:
            t.join()
    endtime = datetime.now()
    print(endtime - starttime)
    print("---------------------------------------------End---------------------------------------------")



if __name__ == "__main__":
    scheduler = BlockingScheduler()
    scheduler.add_job(main,"interval",minutes=2)
    scheduler.start()
    # main()