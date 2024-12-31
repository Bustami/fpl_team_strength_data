
library(rvest)
library(dplyr)
library(janitor)
library(readr)


### PERFORMANCE (XG & GOALS)

url = "https://fbref.com/en/comps/9/Premier-League-Stats"
html = read_html(url)

raw_data = html %>% 
        html_nodes(xpath = '//*[@id="results2024-202591_home_away"]/tbody') %>% 
        html_table(fill = T) %>% 
        as.data.frame()

write_csv(raw_data, "pl_team_performance_raw_data.csv")



### FIXTURES

url_fixture = "https://fbref.com/en/comps/9/schedule/Premier-League-Scores-and-Fixtures"

html_fixture = read_html(url_fixture)

raw_data_fixture = html_fixture %>% 
  html_nodes(xpath = '//*[@id="div_sched_2024-2025_9_1"]') %>% 
  html_table(fill = T) %>% 
  as.data.frame() %>% 
  clean_names()

pending_games = raw_data_fixture %>% 
  filter(is.na(x_g) & !is.na(wk)) %>% 
  select(wk, date, home, away)


write_csv(pending_games, "pl_pending_games.csv")


