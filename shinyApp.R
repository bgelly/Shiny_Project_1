library(shiny)
#install.packages("leaflet")
library(leaflet)
#install.packages("gmapsdistance")
library(gmapsdistance)
#install.packages("lubridate")
library(lubridate)
#install.packages("measurements")
library(measurements)
#install.packages('shinydashboard')
library(shinydashboard)
#install.packages("ggmap")
library(ggmap)
#install.packages('data.table')
library(data.table)
#install.packages('dplyr')
library(dplyr)
#install.packages('geosphere')
library(geosphere)

data1 = read.csv("/Users/bennettgelly/Documents/NYCDSA/Shiny_Project_1/data.csv")
dataf = data.frame(data1)

rownames(dataf) <- NULL
# create variable with colnames as choice
choice <- colnames(dataf)[-1]

ui <- shinyUI(dashboardPage(
  ### ADD HEADER
  dashboardHeader(
    title = "Uber Passenger Finder"
  ),
  ### DISABLE SIDEBAR
  dashboardSidebar(disable = TRUE),
  
  ### ADD INFO BOXES IN UI
  dashboardBody(
  fluidRow(infoBoxOutput("rphBox"),
           infoBoxOutput("minBox"),
           infoBoxOutput("avgBox")),
  
  ### ADD MAP AND HISTOGRAM BOXES IN UI
  fluidRow(
      column(width = 9,
             box(width = NULL, solidHeader = TRUE, status = "warning", title = h3("Click on Map to Set Starting Location and Wait"),
                leafletOutput("map")
              ),
              box(width = NULL, status = "primary", title = h3("Rides per Hour"), solidHeader = TRUE, collapsible = TRUE, collapsed=TRUE,
                plotOutput("hist")
                    )
             ),
      
      ### ADD SLIDERS FOR TIME, TEMP AND DAY IN UI
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

  ## MAKE BLANK MAP
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$MtbMap) %>%
      addProviderTiles(providers$Stamen.TonerLines,
                       options = providerTileOptions(opacity = 0.35)) %>%
      addProviderTiles(providers$Stamen.TonerLabels) %>%
      setView(lng = -73.99, lat = 40.75, zoom = 12) 
  })
  
  
  
  ####### OBSERVE AND FILTER DATA  BY TIME, DAY, TEMP #######
  observeEvent(c(input$slidertime, input$checkDay, input$sliderW),{

          filterData = filter(dataf, dataf$timeNum  %in% c(seq(input$slidertime[1], input$slidertime[2])))
          filterData = filter(filterData, filterData$hourlydrybulbtempf  %in% c(seq(input$sliderW[1], input$sliderW[2])))
          filterData = filter(filterData, filterData$day.x  %in% input$checkDay)
          
          ### PLOT FILTERED DATA
          leafletProxy("map", data = filterData) %>%
            clearMarkerClusters() %>%
              addCircleMarkers(lng = ~Lon, lat = ~Lat, clusterOptions = markerClusterOptions(showCoverageOnHover = TRUE, zoomToBoundsOnClick = TRUE,
                                                               spiderfyOnMaxZoom = FALSE, removeOutsideVisibleBounds = TRUE))
          output$hist <- renderPlot(
            ggplot(filterData, aes(x = timeNum)) + geom_density(stat="count") +labs(x = "Hour", y = "Ride Count") + theme(text = element_text(size=15)))
          
          ####### OBSERVE CLICK ####### 
          observeEvent(input$map_click, {
            leafletProxy("map") %>%
              clearShapes()
            click <- input$map_click
            clat <- click$lat
            clng <- click$lng
            address <- revgeocode(c(as.numeric(clng),as.numeric(clat)))
            
            ####### PLOT CLICK #######
            leafletProxy('map') %>%
              addCircles(lng=clng, lat=clat, group='circles',
                         weight=1, radius=200, color='red', fillColor='red',
                         popup=address, fillOpacity=0.5, opacity=1)
            
            ####### FIND POINTS WITHIN A CERTAIN RADIUS #######
            de = data.frame()
            for(i in 1:dim(filterData)[1]){
              Lat1 = filterData$Lat[i]
              Lon1 = filterData$Lon[i]
              
              if(distm(c(clat, clng), c(Lat1, Lon1), fun = distHaversine)/1000 <.5*0.621371){
                df = data.frame(Lat1, Lon1)
                de = rbind(de, df)
              }else{
                next
              }
            }
            
            ####### FIND DATA POINT IN THIS DATA FRAME WITH MOST POINTS WITHIN A RADIUS #######          
            
            points = (cbind(de, X=rowSums(distm (de[,2:1], fun = distHaversine) / 1000 < .25*0.621371)))
            z = points[which.max(points$X),][1,1:2]
            #print(z)
            address2 <- revgeocode(c(as.numeric(z[2]), as.numeric(z[1])))
            #print(address2)
            leafletProxy('map') %>%
              clearMarkers() %>%
              addAwesomeMarkers(lng=as.numeric(z[2]), lat=as.numeric(z[1]))
            
            
            ####### CALC DRIVING TIME AND DISTANCE #######
            origin = paste(z[[1]],z[[2]], sep = "+")
            destination = paste(clat,clng, sep = "+")
            results = gmapsdistance(origin = origin, 
                                    destination = destination, 
                                    mode = "driving")
            
            timeR = seconds_to_period(as.numeric(results[1]))
            distR = round(conv_unit(as.numeric(results[2]), "m", "mi"),2)
            #print(timeR)
            #print(distR)
            
            ####### DISPLAY METRICS IN INFO BOXES #######
            
            output$rphBox <- renderInfoBox({
              infoBox("Start: ", address ,icon = icon("map-pin"), fill = TRUE)
            })
            
            output$minBox <- renderInfoBox({
              infoBox("Go To: ", address2, icon = icon("hand-o-right"), fill = TRUE)
            })
            output$avgBox <- renderInfoBox(
              infoBox("Time/Dist: ", paste(timeR, "/", distR, "mi"),
                      icon = icon("clock-o"), fill = TRUE))
          })
          
          })
})

shinyApp(ui=ui, server=server)