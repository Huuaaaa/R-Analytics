install.packages("rvest")
install.packages("httr")
install.packages("polite")
install.packages("dplyr")
install.packages("kableExtra")

library(rvest)
library(httr)
library(dplyr)
library(polite)
library(kableExtra)

polite::use_manners(save_as = 'polite_scrape.R')
url <- 'https://m.imdb.com/chart/toptv/?ref_=nv_tvv_250'

cat("URL:", url, "\n")

session <- bow(url, user_agent = "Educational")
session

rank_title <- character(0)
links <- character(0)

title_list <- scrape(session) %>%
html_nodes('h3.ipc-title__text') %>%
html_text
class(title_list)

title_list_sub <- as.data.frame(title_list[1:250])
head(title_list_sub)
tail(title_list_sub)

colnames(title_list_sub) <- "ranks"
split_df <- strsplit(as.character(title_list_sub$ranks),".",fixed = TRUE)
split_df <- data.frame(do.call(rbind,split_df))
split_df <- split_df[-c(3:4)]
colnames(split_df) <- c("ranks","title")
str(split_df)
class(split_df)
head(split_df)
rank_title <- data.frame(
rank_title = split_df)
write.csv(rank_title,file = "title.csv")


link_list <- scrape(session) %>%
html_nodes("a.ipc-title-link-wrapper") %>%
html_attr('href')
head(link_list)

link_list[245:257]
link <- as.vector(link_list[1:250])
names(link) <- "links"
head(link)
tail(link)


for (i in 1:250) {
  link[i] <- paste0("https://imdb.com", link[i], sep = "tt0903747")
}
links <- as.data.frame(link)
rank_title <- data.frame(
rank_title = split_df, link)

scrape_df <- data.frame(rank_title,links)
names(scrape_df) <- c("Rank","Title","Link")
head(scrape_df)


write.csv(scrape_df,file = "top50.csv")

current_row <- 1
imdb_top_50 <- data.frame()

for (row in 1:2) {
url <- links$link[current_row]
session2 <- bow(url,
                  user_agent = "Educational")
webpage <- scrape(session2)


rating <- html_text(html_nodes(webpage, ".sc-bde20123-1 cMEQkK"))
rating <- rating[-2]
cat(rating)


votecount <- html_text(html_nodes(webpage,
                                  'sc-bde20123-3 gPVQxL'))
votecount <- votecount[-2]

number_episode <- html_text(html_nodes(webpage,
                                   'sc-9b367beb-0 dfytnn'))
number_episode <- number_episode[-2]

year_released <- html_text(html_nodes(webpage,
                                       'sc-3a4309f8-0 bjXIAP sc-9aa2061f-1 foKegm'))
year_released <- year_released[-2]

cat("Rating for", url, "is:", rating , "vote count is", votecount, "with" ,number_episode, "episodes", "and released at", year_released,  "\n")


cat(url)


