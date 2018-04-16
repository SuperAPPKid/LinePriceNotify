from flask import Flask,render_template,request,jsonify
from myserver.myRedis import myRedis
from myserver.crawler import getResult
import requests
import json
app = Flask(__name__,
            static_folder="../templates",
            static_url_path="",
            template_folder="../templates")

@app.after_request
def add_header(r):
    r.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    r.headers["Pragma"] = "no-cache"
    r.headers["Expires"] = "0"
    r.headers['Cache-Control'] = 'public, max-age=0'
    return r

@app.route("/")
def home():
    return app.send_static_file("index.html")

@app.route("/echo")
def echo():
    kwargs = {}
    kwargs["thing"] = "LINE"
    kwargs["code"] = request.args.get("code")
    kwargs["state"] = request.args.get("state")
    url = "https://notify-bot.line.me/oauth/token"
    data = {"grant_type":"authorization_code",
            "code":kwargs["code"],
            # "redirect_uri":"http://192.168.43.37:9999/echo",
            "redirect_uri": "http://localhost:9999/echo",
            "client_id":"u8q2t2XzFHd6TLHuZ2ejai",
            "client_secret":"54wq40T8HYKFbkNuvcwjhDBYcQmwiaxX2nD35AJtg73"}
    res = requests.post(url, data)
    resJson = res.json()
    print(resJson["status"])
    kwargs["token"] = resJson["access_token"]
    
    r = myRedis()
    r.lpush("token",kwargs["token"])
    
    return render_template("flask.html",**kwargs)

@app.route("/add",methods=["POST"])
def add():
    if request.method == "POST":
        json_dict = request.get_json()

        token = json_dict["token"]

        content = { "title": json_dict["title"],
                    "lowPrice": json_dict.get("lowPrice", None),
                    "highPrice": json_dict.get("highPrice", None),
                    "shops": json_dict["shops"],
                    "date":json_dict["date"]}
        
        r = myRedis()
        r.lpush(token,json.dumps(content))
        
        return "OK"
    else:
        return "ERROR"

@app.route("/delete",methods=["POST"])
def delete():
    if request.method == "POST":
        json_dict = request.get_json()

        token = json_dict["token"]
        index = json_dict["index"]
        
        r = myRedis()
        r.lset(token,index,"del")
        r.lrem(token,"del",0)
        
        return "OK"
    else:
        return "ERROR"


@app.route("/deleteAll", methods=["POST"])
def deleteAll():
    if request.method == "POST":
        json_dict = request.get_json()

        token = json_dict["token"]

        r = myRedis()
        r.lrem("token",token, 0)

        return "OK"
    else:
        return "ERROR"

@app.route("/update",methods=["POST"])
def update():
    if request.method == "POST":
        json_dict = request.get_json()

        token = json_dict["token"]
        index = json_dict["index"]
        content =  {"title":json_dict["title"],
                   "lowPrice":json_dict["lowPrice"],
                   "highPrice":json_dict["highPrice"],
                   "shops":json_dict["shops"],
                   "date":json_dict["date"]}
        
        r = myRedis()
        r.lset(token, index, json.dumps(content))
        
        return "OK"
    else:
        return "ERROR"

@app.route("/fetch",methods=["POST"])
def fetch():
    if request.method == "POST":
        json_dict = request.get_json()

        token = json_dict["token"]
        
        r = myRedis()
        r.lrem(token,"del", 0)
        datas = r.lrange(token, 0, -1)
        results = {"list":[]}
        for data in datas:
            results["list"].append(json.loads(data))
        
        return jsonify(results)
    else:
        return "ERROR"

@app.route("/search",methods=["POST"])
def search():
    if request.method == "POST":
        json_dict = request.get_json()

        content = {"q": json_dict["title"],
                   "pl": json_dict.get("lowPrice", None),
                   "ph": json_dict.get("highPrice", None),
                   "sort":"p",
                   "pr[]":json_dict["shops"],
                   "page":json_dict["page"]}



        searchResult = getResult("https://feebee.com.tw/all/",**content)
        if searchResult != None:
            return jsonify(searchResult)
        else:
            searchResult = {"results":"error"}
            return jsonify(searchResult)
    else:
        return "ERROR"

@app.route("/verify",methods=["GET"])
def verify():
    if request.method == "GET":
        notVerifyToken = request.args.get("token")

        print(notVerifyToken)

        code = sendNotify(notVerifyToken)
        print(code)

        if code == 200 :
            r = myRedis()
            r.lpush("token", notVerifyToken)
            return "OK"
        elif code == 401:
            return "NG"
        elif code == 878787:
            return "Unicode"
        else:
            return "ERROR"


        return "ERROR"
    else:
        print("fuck")
        return "ERROR"

def sendNotify(token):
    url = "https://notify-api.line.me/api/notify"
    header = {"Authorization":"Bearer "+token}
    data = {"message":"您已登入Line到價通知服務"}
    try:
        res = requests.post(url, headers=header, data=data)
    except UnicodeEncodeError as e:
        print(e)
        return 878787
    return res.status_code

# app.run(host = "192.168.43.37", port = 9999, debug = True)
app.run(host = "localhost", port = 9999, debug = True)
