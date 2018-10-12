############################################
## Read in Neighborhood Change Database   ##
## raw datasets (1970-2000), merge these  ##
## datasets and create tables showing     ##
## changes in aggregate housing value     ##
##                                        ##
## Author: Nathaniel Ruby                 ##
## Date: 09/25/2018                       ##
############################################
library(dplyr)

setwd("~/Sasha/Housing/raw/")

geography    <- read.csv("Geography.csv"   , stringsAsFactors = FALSE)
housing_1970 <- read.csv("Housing_1970.csv", stringsAsFactors = FALSE)
housing_1980 <- read.csv("Housing_1980.csv", stringsAsFactors = FALSE)
housing_1990 <- read.csv("Housing_1990.csv", stringsAsFactors = FALSE)
housing_2000 <- read.csv("Housing_2000.csv", stringsAsFactors = FALSE)

## Merge each dataset to 'geography' so that
## every dataset contains identifiable geographic
## information
housing_1970_geo <- merge(geography, housing_1970)
housing_1980_geo <- merge(geography, housing_1980)
housing_1990_geo <- merge(geography, housing_1990)
housing_2000_geo <- merge(geography, housing_2000)

## First append the datasets. We will have one
## observation per census tract per year
colnames(housing_1970_geo) <- gsub(pattern = "\\d?$", "", colnames(housing_1970_geo))
colnames(housing_1980_geo) <- gsub(pattern = "\\d?$", "", colnames(housing_1980_geo))
colnames(housing_1990_geo) <- gsub(pattern = "\\d?$", "", colnames(housing_1990_geo))
colnames(housing_2000_geo) <- gsub(pattern = "\\d?$", "", colnames(housing_2000_geo))

housing_append <- bind_rows(housing_1970_geo, housing_1980_geo, housing_1990_geo, housing_2000_geo)


## Merge Geography dataset 
## and 1970 - 2000 data
## by "AREAKEY" variable
housing_merge <- merge(geography, housing_1970) %>%
	         merge(.        , housing_1980) %>%    
	         merge(.        , housing_1990) %>%    
	         merge(.        , housing_2000)     


## Calculate proportion 
## white in each year
housing_merge_all <- housing_merge %>%
	             mutate(SHRWHT7_PCT = SHRWHT7N/TRCTPOP7,
                      	    SHRWHT8_PCT = SHRWHT8N/TRCTPOP8,
                      	    SHRWHT9_PCT = SHRWHT9N/TRCTPOP9,
                      	    SHRWHT0_PCT = SHRWHT0N/TRCTPOP0)




