###########################################
###########################################
##
## MTA MNR GTFS Archive
##
###########################################
###########################################

#=========================#
#### Loading packages ####
#=========================#


library(gtfsr)
library(magrittr)
library(dplyr)
library(gtfsway)
library(httr)
library(xml2)
library(rvest)
library(purrr)
library(RProtoBuf)
library(DBI)
library(dbplyr)
library(lubridate)
library(stringr)
library(iterators)
library(glue)
library(tibble)


#==================================#
#### Previously existing files ####
#==================================#

existing_files <- 
    list.files("./GTFS Data") %>% 
    str_replace(".zip", "")


#=========================#
#### Extracting links ####
#=========================#

page <- 1:8
download_links_3 <- data.frame()
root <- "https://transitfeeds.com"


for (i in 1:length(page)) {
    
    download_links_1 <- 
        read_html(glue("https://transitfeeds.com/p/mta/87?p={page[i]}"))
    
    download_links_2 <- 
        download_links_1 %>% 
        html_nodes("tr") %>% 
        html_nodes("td") %>% 
        html_nodes(":not([class])")
    
    link_dates <- 
        download_links_2 %>% 
        html_text()
    
    link_urls <- 
        download_links_2 %>% 
        html_attrs() %>% 
        as.character()
    
    download_links_3 <-
        tibble(link_dates = link_dates,
               link_urls = link_urls) %>% 
        
        bind_rows(download_links_3, .) %>% 
        
        as_tibble()
    
}

download_links_4 <- 
    download_links_3 %>% 
    distinct(link_dates, .keep_all = TRUE) %>% 
    as_tibble() %>% 
    filter(!link_dates %in% existing_files)


#==============================#
#### Downloading zip files ####
#==============================#


for (i in 1:nrow(download_links_4)) {
    
    tryCatch({
        
        download.file(url = paste0(root, download_links_4$link_urls[i], "/download"),
                      destfile = paste0("./GTFS Data/", download_links_4$link_dates[i], ".zip"),
                      mode = "wb",
                      method = "libcurl")
        
    }, finally = next) 
}


################################################################################
################################################################################

