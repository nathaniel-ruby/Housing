############################################
## Read in Neighborhood Change Database   ##
## raw datasets (1970-2000), merge these  ##
## datasets and create tables showing     ##
## changes in aggregate housing value.    ##
##                                        ##  
## This is using a stripped down          ##
## dataset - only data about share of     ##
## white residents and aggregate housing  ##
## values.                                ##
##                                        ##
## Author: Nathaniel Ruby                 ##
## Date: 10/15/2018                       ##
############################################
library(dplyr)
library(ggplot2)
library(Hmisc)

setwd("~/Sasha/Housing/raw/")

geography       <- read.csv("Geography.csv", stringsAsFactors = FALSE)
housing_reduced <- read.csv("Reduced.csv"  , stringsAsFactors = FALSE)

## Merge Geography and Reduced
housing_all <- merge(geography, housing_reduced) 

## Label Variables
source("~/Sasha/Housing/code/source_label.R")

for (year in c(8,9,0)) {
  
  if (year == 0) {
    curr_var <- paste0("AGGVAL",year)
    prev_var <- paste0("AGGVAL",year+9)
    new_var  <- paste0("AGGVAL",year,year+9) 
  } else {
    curr_var <- paste0("AGGVAL",year)
    prev_var <- paste0("AGGVAL",year-1)
    new_var  <- paste0("AGGVAL",year,year-1) 
  }

  sharewht      <- paste0("SHRWHT",year)
  sharewht_bins <- paste0("SHRWHT",year,"BIN")
      
  ## Winsorize
  housing_all[new_var] <- housing_all[curr_var]/housing_all[prev_var]
  housing_all[,new_var][is.infinite(housing_all[,new_var])] <- NA

  quant_95 <- quantile(housing_all[new_var], .95, na.rm = TRUE) 
  housing_all[,new_var][housing_all[new_var] > quant_95] <- quant_95 

  ## Create bins
  housing_all[sharewht_bins] <- as.character(cut(housing_all[,sharewht], c(0,.1,.2,.3,.4,.5,.6,.7,.8,.9,1)))
}

sharewhite_plot <- function(share_weight, agg_val) {
 
  housing_subset <- housing_all[!is.na(housing_all[,share_weight]),]
 
  evaluate <- ggplot(data = housing_subset)      + 
              geom_bar(aes_string(share_weight, agg_val),
		       stat     = "summary"      , 
                       position = "dodge"        ,       
                       fun.y    = "mean"         ) 

  return(evaluate)
}

eight_plot <- sharewhite_plot("SHRWHT8BIN", "AGGVAL87")
nine_plot  <- sharewhite_plot("SHRWHT9BIN", "AGGVAL98")
aught_plot <- sharewhite_plot("SHRWHT0BIN", "AGGVAL09")

