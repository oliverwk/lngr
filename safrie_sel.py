# -*- coding: utf-8 -*-
#!/usr/bin/env python3
import time
from selenium.webdriver import Safari
from selenium.webdriver.common.action_chains import ActionChains




with Safari() as driver:
       URL = "https://www.na-kd.com/nl/lingerie/onderbroeken?sortBy=price&count=18&p_categories=c_1-32927_nl-nl"
       driver.get(URL)
       time.sleep(9)
       print("On the page")
       numbers = list(range(0, 30))
       action = ActionChains(driver);
       for s in numbers:
           print(s)
           action = ActionChains(driver);
           parent_level_menu = driver.find_element_by_id(s)
           action.move_to_element(parent_level_menu).perform()

       time.sleep(6)
       file = open("/Users/MWK/Desktop/OLE/NA-KD.html","w")
       file.writelines(driver.page_source)
       print("wrting file")
       file.close()
       driver.quit()
       print("starting naamloos.pys")
       os.system("python /Users/MWK/Desktop/nakd.py")
