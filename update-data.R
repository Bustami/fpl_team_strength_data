
library(rvest)
library(dplyr)
library(janitor)
library(readr)


### PERFORMANCE (XG & GOALS)

url = "https://fbref.com/en/comps/9/Premier-League-Stats"
html = read_html(url)

season = gsub(".*?(\\d{4}-\\d{4}).*", "\\1", html %>% html_nodes(xpath = '//*[@id="meta"]/div[2]/h1') %>% html_text())

raw_data = html %>% 
        html_nodes(xpath = paste0('//*[@id="results', season, '91_home_away"]/tbody')) %>% 
        html_table(fill = T) %>% 
        as.data.frame()

write_csv(raw_data, "pl_team_performance_raw_data.csv")



### FIXTURES

url_fixture = "https://fbref.com/en/comps/9/schedule/Premier-League-Scores-and-Fixtures"

html_fixture = read_html(url_fixture)

raw_data_fixture = html_fixture %>% 
  html_nodes(xpath = paste0('//*[@id="div_sched_', season, '_9_1"]')) %>% 
  html_table(fill = T) %>% 
  as.data.frame() %>% 
  clean_names()

pending_games = raw_data_fixture %>% 
  filter(is.na(x_g) & !is.na(wk)) %>% 
  select(wk, date, home, away)


write_csv(pending_games, "pl_pending_games.csv")


