library(raster)

soi <- read.csv('soi.csv') #the more negative, the stronger the El Nino
oni <- read.csv('oni.csv') #the more positive, the stronger the El Nino

#ONI measures tempurate, and therefore measures the most recent El Nino as relatively more
#sever than SOI, because ocean temps are higher.

StDev <- raster('PrecipStDev.asc')
AllMean <- raster('PrecipAllMean.asc')
PrecipYears <- brick('UDelPrecipData.grd')

getENSOstdevRast <- function(metric=c('soi','oni'), value){
  #Use data from 1900-2014 to generate a raster of standard deviations
  #Each cell is how many standard deviations from the mean an average ENSO year
  #is for precipitation.
  
  #metric is which ENSO indicator you are using - ie, Southern Oscillation
  #Index or Oceanic Nino Index
  
  #value is the cutoff value beyond which events will be classified as El Ninos
  
  if(metric=='soi'){
    data <- soi
  } else if(metric=='oni'){
    data <- oni
  }
  
  if(value > 0){
    select_dates <- as.character(data$date[data$value > value])
  } else{
    select_dates <- as.character(data$date[data$value < value])
  }

  dates_parsed <- paste0('X', substring(select_dates, 1, 4), '.', substring(select_dates, 6, 7))

  ENSObrick <- subset(PrecipYears, dates_parsed)

  ENSOmean <- mean(ENSObrick)

  ENSOstdev <- (ENSOmean-AllMean)/StDev
  
  ENSOstdev
}

#plot(getENSOstdevRast('oni', 1.5))

#plot(getENSOstdevRast('soi', -20))