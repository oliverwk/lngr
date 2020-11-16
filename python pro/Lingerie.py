import os, wget
os.system('clear')
import requests, json
page = requests.get("https://raw.githubusercontent.com/oliverwk/wttpknng/master/Lingerie.json")
jsons = json.loads(page.content)
base_dir = os.path.dirname(os.path.abspath(__file__))
path = os.path.join(base_dir, "nakd")
if not os.path.exists(path):
    os.mkdir(path)
if not os.path.isdir(path):
    exit()

si = 0
for i in jsons:
    print(si)
    print(i["img_url"])
    response = requests.get(i["img_url"])
    file = open('/Users/MWK/Desktop/nkd/python pro/nakd/nkd-{n}.jpg'.format(n=si), "wb")
    file.write(response.content)
    file.close()
    print(i["img_url_sec"])
    response = requests.get(i["img_url_sec"])
    file = open('/Users/MWK/Desktop/nkd/python pro/nakd/sec/nkd-{n}.jpg'.format(n=si), "wb")
    file.write(response.content)
    file.close()
    si += 1
