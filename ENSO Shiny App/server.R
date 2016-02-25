library(reshape2)
library(zoo)
library(lubridate)
library(plyr)
library(ggplot2)
library(raster)

clickmap <- raster('clickmap2.asc')

#Soi data from http://www.bom.gov.au/climate/current/soihtm1.shtml
soi <- read.csv('SOI.csv')

soi$date <- ymd(soi$date)

worldprecips <- brick('Allbrick.gri')

plotit <- function(lat, long, smooth=1, startyear=1900, endyear=2016){
  EXT <- extract(worldprecips, SpatialPoints(data.frame(x=long,y=lat)))
  EXTdf <- data.frame(precip=EXT[1,], date=parse_date_time(substr(colnames(EXT),2,8), "Ym"))
  EXTdf <- merge(EXTdf, soi, by='date', all.x=T)
  
  EXTdf$precip <- rollapply(EXTdf$precip, FUN=mean, na.rm=T, width=smooth, fill=NA)
  EXTdf$value <- rollapply(EXTdf$value, FUN=mean, na.rm=T, width=smooth, fill=NA)
  
  EXTdf$phase <- 'other'
  EXTdf$phase[EXTdf$value > 9] <- 'Nina'
  EXTdf$phase[EXTdf$value < -9] <- 'Nino'
  
  
  f <- ggplot(EXTdf[year(EXTdf$date) >= startyear & year(EXTdf$date) <= endyear,], aes(date, precip))+ 
    ggtitle('Rainfall vs ENSO phase') +
    geom_rect(aes(NULL, NULL, 
                  xmin=date-weeks(2), xmax=date+weeks(2), 
                  ymin=0, ymax=max(precip, na.rm=T), 
                  fill=phase), alpha=.5) + scale_fill_manual(values = c('#bfe0fc','#fcbfbf','White')) + 
    geom_line(size=.5) + theme(axis.text=element_text(size=12), axis.title=element_text(size=14,face="bold"), title=element_text(size=18,face='bold'))+ 
    scale_y_continuous(expand = c(0,0)) + scale_x_datetime(expand = c(0,0))

  return(f)
}

shinyServer(function(input, output) {
      ranges <- reactiveValues(x = c(-180,180), y = c(-90,90))    
  
      output$plot1 <- renderPlot({
        plot(clickmap, main='Select an Area to Zoom to here:')
      })
      
      output$plot4 <- renderPlot({
        if(is.null(ranges$y)){return(NULL)}
        else{
          plot(clickmap, main='Click on a spot to see historic ENSO patterns:',
                xlim = ranges$x, ylim = ranges$y)
        }
      })
      
      observe({
        brush <- input$plot1_brush
        if (!is.null(brush)) {
          ranges$x <- c(brush$xmin, brush$xmax)
          ranges$y <- c(brush$ymin, brush$ymax)
          
        } else {
          ranges$x <- NULL
          ranges$y <- NULL
        }
      })
      
      output$plot2 <- renderPlot({
        if(is.null(input$plot_click$y)){return(NULL)}
        else{
          plotit(input$plot_click$y, input$plot_click$x, input$smooth, 1900, 2016)
        }
      })
      
      ranges2 <- reactiveValues(x = NULL, y = NULL)
      
      output$plot3 <- renderPlot({
        if(is.null(ranges2$x)){return(NULL)}
        else{
          plotit(input$plot_click$y, input$plot_click$x, input$smooth, ranges2$x[[1]], ranges2$x[[2]])
        }
      })
      
      observe({
        brush2 <- input$plot2_brush
        if (!is.null(brush2)) {
          ranges2$x <- year(as.Date(as.POSIXct(c(brush2$xmin, brush2$xmax), origin="1970-01-01 UTC")))
        } else {
          ranges2$x <- NULL
        }
      })
})