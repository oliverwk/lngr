#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
os.system("clear")
import time
from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By
print("Imported")
chrome_options = webdriver.ChromeOptions();
chrome_options.add_argument("--headless")
chrome_options.add_experimental_option("excludeSwitches", ['enable-automation']);
browser = webdriver.Chrome('/Users/MWK/Desktop/ProjectInitializationAutomation-master/chromedriver', options=chrome_options);
print("Launched")
browser.get("https://www.na-kd.com/nl/lingerie--nachtkleding/bodys?sortBy=price&count=18")
time.sleep(4)
print("Arrived")
action = ActionChains(browser);
el_list = browser.find_elements_by_class_name('sg-product-card')
for s in range(len(el_list)):
    print(s)
    action = ActionChains(browser);
    parent_level_menu = browser.find_element_by_id(s)
    action.move_to_element(parent_level_menu).perform()

time.sleep(6)
file = open("/Users/MWK/Desktop/nkd/NA-KD.html","w")
file.writelines(browser.page_source)
print("wrting file")
file.close()
browser.quit()
print("starting nakd.py")
os.system("python3 /Users/MWK/Desktop/nkd/nakd.py")
