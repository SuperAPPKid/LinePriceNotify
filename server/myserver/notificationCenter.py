from myserver.myRedis import myRedis
from collections import  namedtuple
import requests
import json
import datetime

Shop = namedtuple("Shop","name url")
shopsList = {"ybid":Shop("Yahoo!奇摩拍賣","tw.bid.yahoo.com"),
             "shopee":Shop("蝦皮拍賣","shopee.tw"),
             "ruten": Shop("露天拍賣","www.ruten.com.tw"),
             "kingstone": Shop("金石堂網路書店", "www.kingstone.com.tw/"),
             "books": Shop("博客來", "www.books.com.tw"),
             "taaze": Shop("TAAZE讀冊生活", "www.taaze.tw"),
             "24hpchome": Shop("PChome24h購物", "24h.pchome.com.tw"),
             "ybuy": Shop("Yahoo奇摩購物中心", "tw.buy.yahoo.com"),
             "gohappy": Shop("friDay購物", "shopping.friday.tw"),
             "rakuten": Shop("樂天市場購物網", "www.rakuten.com.tw"),
             "udn": Shop("udn買東西購物中心", "shopping.udn.com"),
             "momoshop": Shop("momo購物網", "www.momoshop.com.tw")}


def getResult(url,**karg):
    from bs4 import BeautifulSoup
    print(url, karg)
    count = 0
    ansStr = ""
    try:
        response = requests.get(url, karg)
    except requests.RequestException as e:
        print(e)
        return None
    try:
        bsObj = BeautifulSoup(response.text, "html.parser")
        row = bsObj.find("ol", {"id": {"list_view"}}).findAll("li", {"class": {"pure-g", "items"}}, recursive=False)
        for item in row:
            if item.h3 != None:
                count += 1
        shop = karg["pr[]"]
        if count >= 30 :
            ansStr += shopsList[shop].name + "有多筆的資料\n" + "連結:" + shopsList[shop].url + "\n"
        else:
            ansStr += shopsList[shop].name + "有"+str(count) + "筆資料\n" + "連結:" + shopsList[shop].url + "\n"
        return ansStr
    except AttributeError:
        return ""
    except ValueError:
        return ""

def gogoNotify(token,titleStr,notifyStr):
    url = "https://notify-api.line.me/api/notify"
    header = {"Authorization": "Bearer " + token}
    data = { "message": titleStr + notifyStr }
    res = requests.post(url, headers=header, data=data)
    return res.text

def main():
    r = myRedis()
    tokens = r.lrange("token", 0, -1)

    for token in tokens:
        contents = r.lrange(token, 0, -1)
        for index, content in enumerate(contents):
            notifyStr = ""

            data = json.loads(content)
            params = {"q": data["title"],
                      "pl": data["lowPrice"],
                      "ph": data["highPrice"],
                      "sort": "p",
                      "page": 1}
            shops = data["shops"]
            for shop in shops:
                params["pr[]"] = shop
                notifyStr += getResult("https://feebee.com.tw/all/", **params)

            if len(notifyStr) != 0:
                titleStr = "\n" + data["title"] + ":" + str(data["lowPrice"]) + "~" + str(data["highPrice"]) + "\n"
                response = gogoNotify(token, titleStr, notifyStr)
                print(response)

                print(token)
                if json.loads(response)["status"] != 200:
                    r.lrem("token", token, 0)
                    r.delete(token)
                    continue
                else:
                    r.lset(token, index, "del")

        r.lrem(token, "del", 0)


if __name__ == "__main__":
    starttime = datetime.datetime.now()
    print("---------------------------------------------Start---------------------------------------------")
    main()
    endtime = datetime.datetime.now()
    print(endtime - starttime)
    print("---------------------------------------------End---------------------------------------------")