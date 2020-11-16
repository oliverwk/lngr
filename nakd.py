#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
os.system('clear')
import json, re
import sys, requests
from bs4 import BeautifulSoup
rfile = open("/Users/MWK/Desktop/nkd/NA-KD.html","r")
rpdb = rfile.read()
rfile.close()
soup = BeautifulSoup(rpdb, 'html.parser')

datas = []

for img in soup.find_all("div", class_="sg-product-card"):
    json_data_el = json.loads(img["data-tracking-json"])
    data={}
    prijs = json_data_el["price"]
    prijs2 = prijs.replace("EUR\u00a0", "euro ")
    data['prijs'] = prijs2
    print(prijs2)
    print("\n"+"De naam is "+json_data_el["name"])
    data["naam"] = json_data_el["name"]
    img_el = img.find("img")
    print("https://www.na-kd.com"+img_el.parent.parent["href"])
    data["url"] = "https://www.na-kd.com"+img_el.parent.parent["href"]
    try:
        img_url_src = img_el["src"].replace("04k", "01j")
    except IndexError as e:
        oms = "iets te doen"
    try:
        print(img_url_src)
        image_url = img_url_src.rsplit('?', 1)[-2]
    except IndexError as e:
        oms = "iets te doen"
    try:
        data['img_url'] = image_url
        src = image_url.replace("01j", "04k")
        if src in "04k":
            src = image_url.replace("04k", "01j")
        data['img_url_sec'] = src
        datat = json.dumps(data)
        datas.append(datat)
    except IndexError as e:
        om = "iets te doen"

file = open("/Users/MWK/Desktop/nkd/nakd-data.json","w")
l = '\''
final = str(datas).replace(l,"").replace('"{', "{").replace('}"', "}")
file.writelines(final)
file.close()

try:
    data = {}
    datas = json.loads(final.replace("[","").replace("]",""))
    for i in datas:
        naams = i["naam"].replace(" ", "-")
        data.append(i.replace("{", naams+":{"))
except Exception as e:
    print("datas not happing")


#firebase = requests.put("https://wittopkoningweb.firebaseio.com/NA-KD/lingeries/slips.json", data=final)
from github import Github
print("Pushing to Github")
g = Github(os.getenv("git_access_token"))
repo = g.get_repo("oliverwk/wttpknng")
contents = repo.get_contents("SwimWear.json")
repo.update_file(contents.path, "updated SwimWear.json from python3", json.dumps(json.loads(final), indent=4), contents.sha, branch="master")
print("Pushed to Github")
