library(ggplot2)
library(ggimage)
library(dplyr)
library(ggrepel)

movies_with_highest_box_office <- read.csv("movies_with_highest_box_office.csv")

movies_with_highest_box_office_top_250 <- movies_with_highest_box_office %>% arrange(desc(worldwide_gross)) %>%
  head(250)

highest_avg_rating <- movies_with_highest_box_office_top_250 %>% arrange(desc(rating)) %>% slice(1)
lowest_avg_rating <- movies_with_highest_box_office_top_250 %>% arrange(rating) %>% slice(1)

# Create a ggplot2 plot with book covers as points
gg <- ggplot(movies_with_highest_box_office_top_250, aes(x = rating, y = worldwide_gross)) +
  geom_image(aes(image = image_name), size = 0.03) +  # Add book covers
  geom_text_repel(data = highest_avg_rating, aes(x = rating, y = worldwide_gross, 
                                                 label = paste0(movie_title, "\nhas the highest avg.(",rating ,
                                                                ")\nrating across movies with highest box office \n")),
                  color = "orange", size = 1.8 , vjust = -0.25, hjust = 0.7) +
  geom_text_repel(data = lowest_avg_rating, aes(x = rating, y = worldwide_gross, 
                                                label = paste0(movie_title, "\nhas the lowest avg.(",rating ,
                                                               ")\nrating across movies with highest box office \n")),
                  color = "purple", size = 2 , vjust = -1.25, hjust = 0.7) +
  labs(title = "Box Office vs Average IMDB Rating for the Movies with Highest Box Office Revenue",
       x = "Average IMDB Rating",
       y = "Box Office in $") +
  scale_y_continuous(labels = scales::comma) +  
  theme_minimal()  

# Save the plot as an image file
ggsave( "movies_with_highest_box_office.png",plot = gg, bg="white")