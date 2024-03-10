library(ggplot2)
library(ggimage)
library(dplyr)
library(ggrepel)

movies_with_highest_box_office <- read.csv("movies_with_highest_box_office.csv")

movies_with_highest_box_office_top_250 <- movies_with_highest_box_office %>% arrange(desc(worldwide_gross)) %>%
  head(250)

highest_avg_rating <- movies_with_highest_box_office_top_250 %>% arrange(desc(rating)) %>% slice(1)
lowest_avg_rating <- movies_with_highest_box_office_top_250 %>% arrange(rating) %>% slice(1)
highest_box_office <- movies_with_highest_box_office_top_250 %>% arrange(desc(worldwide_gross)) %>% slice(1)

# Create a ggplot2 plot with movie posters as points
gg <- ggplot(movies_with_highest_box_office_top_250, aes(x = rating, y = worldwide_gross)) +
  geom_image(aes(image = image_name), size = 0.03) +  # Add movie posters
  geom_text_repel(data = highest_box_office, aes(x = rating, y = worldwide_gross, 
                                              label = paste0(movie_title, "\nhas the highest box office revenue with\n$",
                                                             scales::comma(worldwide_gross))),
                  color = "red", size = 2.5 , vjust = 1.5,hjust = 0.7) +
  geom_text_repel(data = highest_avg_rating, aes(x = rating, y = worldwide_gross, 
                                                 label = paste0(movie_title, "\nhas the highest avg.(",rating ,
                                                                ")\nrating across movies with highest box office \n")),
                  color = "darkblue", size = 1.8 , vjust = -0.25, hjust = 0.7) +
  geom_text_repel(data = lowest_avg_rating, aes(x = rating, y = worldwide_gross, 
                                                label = paste0(movie_title, "\nhas the lowest avg.(",rating ,
                                                               ")\nrating across movies with highest box office \n")),
                  color = "purple", size = 2 , vjust = -1.25, hjust = 0.5) +
  labs(title = "Box Office vs Average IMDB Rating for the Movies with Highest Box Office Revenue",
       x = "Average IMDB Rating",
       y = "Box Office in $") +
  scale_y_continuous(labels = scales::comma) +  
  theme_minimal()  

# Save the plot as an image file
ggsave( "movies_with_highest_box_office.png",plot = gg, bg="white")

movies_with_highest_box_office_top_250_grouped <- movies_with_highest_box_office_top_250 %>% group_by(year) %>%
                                                  mutate(no_of_movies = n()) %>% ungroup()

# create a plot with movie posters stacked on top of each other on year
gg2 <- ggplot(movies_with_highest_box_office_top_250_grouped, aes(x = year, 1)) + 
  geom_image(aes(image=image_name), size=.03, position = "stack") +
  geom_point(aes(x= year , y = no_of_movies), color = "white") +
  geom_text(aes(y = no_of_movies,label = no_of_movies),
            vjust = -4,
            colour = "#143c8a",
            size = 3.5) +
  theme_classic() +
  scale_y_continuous(
    limits = c(0, round(
      max(movies_with_highest_box_office_top_250_grouped$no_of_movies) + 3),
      digits = (1 - nchar(
        max(movies_with_highest_box_office_top_250_grouped$no_of_movies)
      ))
    )) +
  scale_x_continuous(breaks = seq(min(movies_with_highest_box_office_top_250_grouped$year), 
                                  max(movies_with_highest_box_office_top_250_grouped$year), 
                                  by = 1)) +
  labs(title = "Number of Movies in top 250 Box Office List by Year") +
  theme(
    axis.title.x = element_blank(),
    axis.text.x = element_text(angle = 45, vjust = 0.5)
  ) 

# Save the plot as an image file
ggsave( "movies_with_highest_box_office_by_year.png",plot = gg2, bg="white")