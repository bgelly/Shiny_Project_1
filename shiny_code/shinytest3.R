library(shiny)
library(ggmap)
library(leaflet)
#install.packages("ggmap")

ui <- shinyUI(dashboardPage(
  
  dashboardHeader(
    title = "Uber Pickups"
  ),
  
  dashboardSidebar(disable = TRUE),
  
  dashboardBody(
  fluidRow(infoBoxOutput("rphBox"),
           infoBoxOutput("minBox"),
           infoBoxOutput("avgBox")),
  fluidRow(
      column(width = 9,
             box(width = NULL, solidHeader = TRUE,
                leafletOutput("map")
              ),
              box(width = NULL, status = "warning",
                plotOutput("hist")
                    )
             ),

      column(width = 3,
             box(width = NULL, status = "warning",
              sliderInput("slidertime", label = h3("Time Range (Military)"), min = 0,
                  max = 24, value = c(0, 5)),

              sliderInput("sliderW", label = h3("Temperature (Fahrenheit)"), min = min(dataf$hourlydrybulbtempf),
                  max = max(dataf$hourlydrybulbtempf), value = c(min(dataf$hourlydrybulbtempf), max(dataf$hourlydrybulbtempf))),

              checkboxGroupInput("checkDay", label = h3("Day of the Week"),
                                 choices = list("Monday" = "Monday", "Tuesday" = "Tuesday", "Wednesday" = "Wednesday", "Thursday" = "Thursday", "Friday" = "Friday", "Saturday" = "Saturday", "Sunday" = "Sunday"),
                                 selected = "Monday")
                )
            )
    )
)))

server <- shinyServer(function(input, output, session) {

  ## Make your initial map
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$MtbMap) %>%
      addProviderTiles(providers$Stamen.TonerLines,
                       options = providerTileOptions(opacity = 0.35)) %>%
      addProviderTiles(providers$Stamen.TonerLabels) %>%
      setView(lng = -73.99, lat = 40.75, zoom = 12) 
  })
  
  
  
  ## Observe mouse clicks and add circles
  observeEvent(input$map_click, {
    ## Get the click info
    leafletProxy("map") %>%
      clearShapes()
    click <- input$map_click
    clat <- click$lat
    clng <- click$lng
    address <- revgeocode(c(as.numeric(clng),as.numeric(clat)))
    print(address)

    leafletProxy('map') %>%
      addCircles(lng=clng, lat=clat, group='circles',
                 weight=1, radius=100, color='black', fillColor='black',
                 popup=address, fillOpacity=0.5, opacity=1)
    
    
    
    
    
    
    output$rphBox <- renderInfoBox({
      infoBox(paste("Start: ", address),icon = icon("clock-o"))
    })
    
    output$minBox <- renderInfoBox({
      infoBox(paste("AVG."), icon = icon("hand-o-down"))
    })
    output$avgBox <- renderInfoBox(
      infoBox(paste("AVG."),
              icon = icon("calculator"), fill = TRUE))
  })
  
  observeEvent(c(input$slidertime, input$checkDay, input$sliderW),{

          filterData = filter(dataf, dataf$timeNum  %in% c(seq(input$slidertime[1], input$slidertime[2])))
          filterData = filter(filterData, filterData$hourlydrybulbtempf  %in% c(seq(input$sliderW[1], input$sliderW[2])))
          filterData = filter(filterData, filterData$day.x  %in% input$checkDay)

          leafletProxy("map", data = filterData) %>%
            clearMarkerClusters() %>%
              addCircleMarkers(lng = ~Lon, lat = ~Lat, clusterOptions = markerClusterOptions(showCoverageOnHover = TRUE, zoomToBoundsOnClick = TRUE,
                                                               spiderfyOnMaxZoom = FALSE, removeOutsideVisibleBounds = TRUE))
          output$hist <- renderPlot(
            ggplot(filterData, aes(x = timeNum)) + geom_density(stat="count"))
          
          })
  
  
})

shinyApp(ui=ui, server=server)