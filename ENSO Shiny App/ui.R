fluidPage(
  titlePanel("El Niño, Precipitaion and NDVI Explorer"),
  fluidRow(
    column(6,
      plotOutput("plot1", brush = brushOpts(id = "plot1_brush",
                                               resetOnNew = TRUE,
                                               direction = 'xy')
    )),
    column(6,
      plotOutput("plot4", click = "plot_click")
    )),
  fluidRow(
    column(1,
      numericInput(inputId='smooth', label='Smoothing', value=1, min=1, max=150)
    ),
    column(3,
           radioButtons(inputId='type', label='Display', choices=c("Precipitation"='precip', "NDVI"='ndvi', "Both"='both'), inline=TRUE)
    ),
    column(5,
           radioButtons(inputId='type', label='ENSO measurement', choices=c("Oceanic Niño Index"='ONI', "Southern Oscillation Index"='soi'), inline=TRUE)
    )
  ),
  plotOutput("plot2", height = 300,
                    brush = brushOpts(
                      id = "plot2_brush",
                      resetOnNew = TRUE,
                      direction='x')),
  plotOutput("plot3")
)
