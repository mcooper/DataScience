library(raster)

#Read in brick of all precip data
AllData <- brick('EnSO Shiny App/Allbrick.grd')

#Subset data to 1900-2014 dataset
AllDataSub <- AllData[[1:1380]]

writeRaster(AllDataSub, 'UDelPrecipData.grd')

##Get standard deviation of rasters from each year
AllMean <- mean(AllDataSub)
Deviations <- AllDataSub - AllMean
Squared <- Deviations^2
Variance <- mean(Squared)
StDev <- sqrt(Variance)

writeRaster(AllMean, 'PrecipAllMean.asc')
writeRaster(StDev, 'PrecipStDev.asc', overwrite=T)
