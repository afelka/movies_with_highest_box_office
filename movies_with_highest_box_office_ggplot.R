library(ggplot2)
library(ggimage)
library(dplyr)
library(ggrepel)


movies_with_highest_box_office <- read.csv("movies_with_highest_box_office.csv.csv")

movies_with_highest_box_office_top_250 <- movies_with_highest_box_office %>% arrange(desc(worldwide_gross)) %>%
  head(250)

highest_avg_rating <- movies_with_highest_box_office_top_250 %>% arrange(desc(avg_rating)) %>% slice(1)
lowest_avg_rating <- movies_with_highest_box_office_top_250 %>% arrange(avg_rating) %>% slice(1)

# Create a ggplot2 plot with book covers as points
gg <- ggplot(movies_with_highest_box_office, aes(x = avg_rating, y = no_of_ratings)) +
  geom_image(aes(image = img_src), size = 0.03) +  # Add book covers
  geom_text_repel(data = highest_avg_rating, aes(x = avg_rating, y = no_of_ratings, 
                                                 label = paste0(substr(book_names,1,24), "\nhas the highest avg.(",avg_rating ,
                                                                ")\nrating across most rated books \n")),
                  color = "orange", size = 2 , vjust = -0.25, hjust = 0.7) +
  geom_text_repel(data = lowest_avg_rating, aes(x = avg_rating, y = no_of_ratings, 
                                                label = paste0(book_names, "\nhas the lowest avg.(",avg_rating ,
                                                               ")\nrating across most rated books \n")),
                  color = "purple", size = 2 , vjust = -2.25, hjust = 0.7) +
  labs(title = "Box Office vs Average Rating for the Movies with Highest Box Office Revenue",
       x = "Average Rating",
       y = "Office") +
  scale_y_continuous(labels = scales::comma) +  
  theme_minimal()  

# Save the plot as an image file
ggsave( "movies_with_highest_box_office.png",plot = gg, bg="white")