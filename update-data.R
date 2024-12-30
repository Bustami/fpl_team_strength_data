
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

columns = c("team", "gp", "w", "d", "l", "gf", "ga", "g_dif", "pts", "pts_gp", "xgf", "xga", "xg_dif", "xg_dif_p90")

home_stats = raw_data %>%
  select(2:15) %>% 
  setNames(columns) %>% 
  mutate(venue = "home")

away_stats = raw_data %>%
  select(c(2, 16:28)) %>% 
  setNames(columns) %>% 
  mutate(venue = "away")

BEST_RANK = 1
WORST_RANK = 7
N_TEAMS = length(unique(home_stats$team))

stats = home_stats %>% 
  bind_rows(away_stats) %>% 
  mutate(xgf_per_game = xgf/gp,
         xga_per_game = xga/gp,
         gf_per_game = gf/gp,
         ga_per_game = ga/gp,
         metric_for_per_game = xgf_per_game*.7 + gf_per_game*.3,
         metric_against_per_game = xga_per_game*.7 + ga_per_game*.3) %>% 
  group_by(venue) %>% 
  mutate(attack = rank(-metric_for_per_game, ties.method = "average"),
         defense = rank(metric_against_per_game, ties.method = "average"),
         attack_rating = ((attack - BEST_RANK) * (WORST_RANK  - BEST_RANK)) / (N_TEAMS - BEST_RANK) + BEST_RANK,
         defense_rating = ((defense - BEST_RANK) * (WORST_RANK  - BEST_RANK)) / (N_TEAMS - BEST_RANK) + BEST_RANK) %>% 
  arrange(venue, team)

#NewValue = (((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin

write_csv(stats, "pl_teams_xgf_xga_venue.csv")



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


