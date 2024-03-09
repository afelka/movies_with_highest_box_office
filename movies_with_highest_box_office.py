# -*- coding: utf-8 -*-
"""
Created on Sat Mar  9 20:30:31 2024

@author: Erdem Emin Akcay
"""

from selenium import webdriver
from selenium.webdriver.common.by import By
import re
import pandas as pd
import requests
import time

#start chrome driver
driver = webdriver.Chrome()

# List of URLs for top 600 movies with highest box office results
urls = ["https://www.boxofficemojo.com/chart/ww_top_lifetime_gross/", 
        "https://www.boxofficemojo.com/chart/ww_top_lifetime_gross/?offset=200",
        "https://www.boxofficemojo.com/chart/ww_top_lifetime_gross/?offset=400"
       ]



# Create an empty DataFrame
box_office_df_links = pd.DataFrame(columns=['movie_title', 'movie_urls',
                                       'worldwide_gross', 'year'])

for my_url in urls:
    # Navigate to the URL
    driver.get(my_url)

    web_elements1 = driver.find_elements(By.XPATH, '//td[@class="a-text-left mojo-field-type-title"]')
    movie_title = [elem.text for elem in web_elements1]
    
    web_elements2 = driver.find_elements(By.XPATH, '//td[@class="a-text-left mojo-field-type-title"]//a')
    movie_urls = [elem.get_attribute("href") for elem in web_elements2]
    
    web_elements3 = driver.find_elements(By.XPATH, '//td[@class="a-text-right mojo-field-type-money"]')
    worldwide_gross = [elem.text for elem in web_elements3[::3]]
    
    web_elements4 = driver.find_elements(By.XPATH, '//td[@class="a-text-left mojo-field-type-year"]')
    year = [elem.text for elem in web_elements4]
    
    # Create a temporary DataFrame
    temp_df = pd.DataFrame({
        'movie_title': movie_title,
        'movie_urls': movie_urls,
        'worldwide_gross': worldwide_gross,
        'year': year
    })
    
    # Concatenate the temporary DataFrame with the main DataFrame
    box_office_df_links = pd.concat([box_office_df_links, temp_df], ignore_index=True)    

#add empty img_src and rating columns
box_office_df_links["img_src"] = ""
box_office_df_links["rating"] = ""

#find image src and ratings
for i in range(len(box_office_df_links)):
    new_url = box_office_df_links.iloc[i, 1]  

    driver.get(new_url)      

    web_elements5 = driver.find_elements(By.XPATH, '//div[@class="a-fixed-left-grid-col a-col-left"]//img')
    img_src = [elem.get_attribute("src") for elem in web_elements5]    
    
    box_office_df_links.at[i, "img_src"] = img_src
    
    #find Imdb title and go to Imdb.com to get ratings
    match = re.search(r'tt(\d+)/', new_url)

    if match:
        imdb_id = match.group(1)
        imdb_url = f"https://www.imdb.com/title/tt{imdb_id}/"
        driver.get(imdb_url)
        meta_title_tag = driver.find_elements("css selector",'meta[property="og:title"]')

       
        meta_title_content = [elem.get_attribute("content") for elem in meta_title_tag] 
        
        match2 = re.search(r'\⭐ (\d+\.\d+)', meta_title_content[0])

        if match2:
            rating = match2.group(1)
            box_office_df_links.at[i, "rating"] = rating
        else:
            print("Rating not found.")
        
    else:
        print("IMDb ID not found in the URL.")
        
    time.sleep(3)    
    
# Custom conversion function
def convert_to_numeric(value_str):
    return int(value_str.replace(',', '').replace('$', ''))

# Apply the conversion function to the 'worldwide_gross' column
box_office_df_links['worldwide_gross'] = box_office_df_links['worldwide_gross'].apply(convert_to_numeric)

box_office_df_links["image_name"] = ""
   
#download movie poster
for i in range(len(box_office_df_links)):
    image_url = box_office_df_links.iloc[i, 4][0]  

    image_name = f"movie_poster_{i + 1}.png"
    box_office_df_links.loc[i, 'image_name'] = image_name

    response = requests.get(image_url)
    
    with open(image_name, 'wb') as file:
        file.write(response.content)
     
      
box_office_df_links.to_csv("movies_with_highest_box_office.csv", index=False)