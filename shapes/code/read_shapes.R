library(dplyr)
library(data.table)
library(sf)
library(doParallel)

setwd("~/Sasha/Housing/shapes/raw")	

nCores <- 4 
registerDoParallel(nCores)

crosswalk <- function(decade_one, decade_two) {

  ## Create decade abbreviations
  decade_one_abbrev <- substr(decade_one, 3, 4)
  decade_two_abbrev <- substr(decade_two, 3, 4)

  ## Read in Shape Files
  decade_one_tracts <- st_read(dsn = path.expand(paste0("./shapes_", decade_one)), layer = paste0("US_tract_",decade_one))
  decade_two_tracts <- st_read(dsn = path.expand(paste0("./shapes_", decade_two)), layer = paste0("US_tract_",decade_two))
  
  for (state in unique(decade_one_tracts$NHGISST)) {
  
    print(paste("This is state", state))
    
    ## Subset both tracts by state
    decade_one_state <- subset(decade_one_tracts, as.character(NHGISST) == state)
    decade_two_state <- subset(decade_two_tracts, as.character(NHGISST) == state) %>%
    		     	mutate(Match_Area = st_area(.))

    #matches <- list()
    matches <- foreach (obs = 1:nrow(decade_one_state), .combine = rbind) %dopar% {
	
      ## Find intersection of decade_one_state[i]
      ## and decade_two_tracts
      ## Drop geometry
      st_intersection(decade_one_state[obs,], decade_two_state) %>%
      mutate(Intersect_Area    = st_area(.),
             Intersect_Percent = Intersect_Area/Match_Area)     %>%
      st_set_geometry(., NULL)

    }
  
    ## Concatenate matches for each state
    #crosswalk_tracts <- rbindlist(matches)

    ## Write each state crosswalk_tracts
    ## to .Rda
    saveRDS(matches, file = paste0("~/Sasha/Housing/crosswalk/crosswalk_",decade_one_abbrev,decade_two_abbrev,"/crosswalk_",state,".rds"))

    ## Clear crosswalk data and matches
    rm(matches, decade_one_state, decade_two_state)
  }

}

crosswalk(1940, 1950)
crosswalk(1950, 1960)
crosswalk(1960, 1970)

