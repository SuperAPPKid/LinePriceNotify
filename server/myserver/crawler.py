import requests
from bs4 import BeautifulSoup

def getResult(url,**karg):
    print(url,karg)
    result = {"results": []}
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
                dict = {}
                print(item.h3.text)
                dict["title"] = item.h3.text
                if item.ul.li["class"][0] == "bid_price":
                    print(int(item.find("span", {"class": {"xlarge"}}).text.replace(",", "")))
                    dict["price"] = int(item.find("span", {"class": {"xlarge"}}).text.replace(",", ""))
                else:
                    print(int(item.find("span", {"class": {"price_title"}}).next_sibling.replace(",", "")))
                    dict["price"] = int(item.find("span", {"class": {"price_title"}}).next_sibling.replace(",", ""))
                print(item.ul.img["alt"])
                print(item.find("span", {"class": {"img_container"}}).a["href"])
                print(item.find("span", {"class": {"img_container"}}).img["src"])
                dict["shop"] = item.ul.img["alt"]
                dict["shopUrl"] = item.find("span", {"class": {"img_container"}}).a["href"]
                dict["imgUrl"] = item.find("span", {"class": {"img_container"}}).img["src"]
                result["results"].append(dict)
    except AttributeError as e:
        print(e)
        return None
    except ValueError as e:
        print(e)
        return None
    print(len(result["results"]))
    return result
# dic = {"q":"ps4",
#        "pl":8000,
#        "ph":13000,
#        "pr[]":["ybid","books"]}
# print(getResult("https://feebee.com.tw/all/",**dic))
