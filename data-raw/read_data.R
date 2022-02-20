
# read_data.R
# Purpose: read-in NC Shark data for inclusion in package
# This file is run to rebuild the Shark data for the package

library(devtools)
library(tidyverse)
library(lubridate)

# read-in CSV's
tmp <- read_csv("./data-raw/uncsharkdata_1972-2008.csv")
weather <- read_csv("./data-raw/noaa.csv",na="-9999")

# before merging, first need to remove spaces from variable names
colnames(tmp)<-make.names(names(tmp))

# delete records indicating no sharks caught
tmp = tmp %>% filter(Common.Name != "Null set no sharks caught")

# drop years 2007 and 2008
#tmp = tmp %>% filter(!Year %in% c("2007","2008"))

# drop sharks with length >500cm
tmp = tmp %>% filter(Fork.length < 500)

# fix tide
tide=factor(ifelse(tmp$Tide=="HIGH" | tmp$Tide=="F" | tmp$Tide=="F/E","HIGH","LOW"))

# compute date and time and make a tibble
shark=tibble(date=ymd(with(tmp,paste(Year,Month,Day))),
      time=hm(paste(round(tmp$Time.of.Day/100,0),":00")),
      tide=tide,species=factor(tmp$Common.Name),
      fork.length=tmp$Fork.length)

weather = tibble(date = ymd(weather$DATE),
                 temp.max = weather$TMAX,
                 temp.min = weather$TMIN,
                 precip = weather$PRCP)

shark = shark %>% left_join(weather)

# Save R data set in the sharkr package
devtools::use_data(shark,overwrite=TRUE)

# example plot
ggplot(data=subset(shark,fork.length<2000),aes(x=date,y=fork.length,color=species))+
  geom_jitter(alpha=0.2)

ggplot(data=subset(shark,fork.length<2000),aes(x=temp.max,y=fork.length,color=species))+
  geom_jitter(alpha=0.2)

