#install.packages("googleVis")
library(googleVis)
library(ggmap)
#devtools::install_github("rstudio/leaflet")
#install.packages('leaflet.extras')
library('leaflet.extras')
library(leaflet)
#install.packages("ggplot2")
library(ggplot2)


shinyServer(function(input, output, session){

########################### ORIGINAL CLUSTER MAP DRAWING -- BLANK ###########################
    # output$mymap <- renderLeaflet({
    #   leaflet() %>%
    #     addProviderTiles(providers$MtbMap) %>%
    #     addProviderTiles(providers$Stamen.TonerLines,
    #                      options = providerTileOptions(opacity = 0.35)) %>%
    #     addProviderTiles(providers$Stamen.TonerLabels) %>%
    #     setView(lng = -73.99, lat = 40.75, zoom = 12)
    # })
    
#############################################################################################

################################## ADD CLUSTER MARKERS ######################################  
    #filterData = dataf 
    
    #check if any of the map filters have been triggered
#     observeEvent(c(input$slidertime, input$checkDay, input$sliderW),{
#       
#       # leafletProxy("mymap") %>%
#       #   clearShapes()
#       
#       click <- input$map_click
#       clat <- click$lat
#       clng <- click$lng
#       
#       print(clat)
#       
#       filterData = filter(dataf, dataf$timeNum  %in% c(seq(input$slidertime[1], input$slidertime[2])))
#       filterData = filter(filterData, filterData$hourlydrybulbtempf  %in% c(seq(input$sliderW[1], input$sliderW[2])))
#       filterData = filter(filterData, filterData$day.x  %in% input$checkDay)
#       
# 
# 
#       #add markers based on filtered data
#       
#       #print(input$map_click)
#    
#       
#       leafletProxy("mymap", data = filterData) %>%
#         clearMarkerClusters() %>%
#           addCircleMarkers(lng = ~Lon, lat = ~Lat, clusterOptions = markerClusterOptions(showCoverageOnHover = TRUE, zoomToBoundsOnClick = TRUE,
#                                                            spiderfyOnMaxZoom = FALSE, removeOutsideVisibleBounds = TRUE))
# 
#       
#       #print(input$sliderW)
#       #print(filterData$hourlydrybulbtempf)
#       #check roger ren github for pins
#       #print(filterData$day.x)
#       #print(unique((filterData$day.x)))
#       
#       output$hist <- renderPlot(
#         ggplot(filterData, aes(x = timeNum)) + geom_density(stat="count"))
#       
#       
# ################################## ADD INFO BOXES ######################################
#       
#       output$rphBox <- renderInfoBox({
#         rph_value <- round(nrow(filterData)/nrow(dataf)*100,2)
#         infoBox(paste("% Total Rides: ", rph_value), icon = icon("clock-o"))
#       })
#       output$minBox <- renderInfoBox({
#         #min_value <- 
#         #min_state <-
#         #   state_stat$state.name[state_stat[,input$selected]==min_value]
#         infoBox(paste("AVG.", input$slidertime[1]), icon = icon("hand-o-down"))
#       })
#       output$avgBox <- renderInfoBox(
#         infoBox(paste("AVG.", input$slidertime[1]),
#                 #mean(state_stat[,input$selected]),
#                 icon = icon("calculator"), fill = TRUE))
#       
#       
#       })
    # observeEvent(input$map_click,{
    #   clearShapes() %>%
    #          leafletProxy("mymap") %>%
    #            addCircles(lng=clng, lat=clat, group='circles',
    #                      weight=1, radius=100, color='black', fillColor='black',
    #                      popup=address, fillOpacity=0.5, opacity=1)
    #   print(input$map_click)
    #   })
    # 
    output$mymap <- renderLeaflet({
      leaflet() %>%
        addProviderTiles(providers$MtbMap) %>%
        addProviderTiles(providers$Stamen.TonerLines,
                         options = providerTileOptions(opacity = 0.35)) %>%
        addProviderTiles(providers$Stamen.TonerLabels) %>%
        setView(lng = -73.99, lat = 40.75, zoom = 12)
    })
    
    
    
    ## Observe mouse clicks and add circles
    observeEvent(input$map_click, {
      ## Get the click info like had been doing
      # leafletProxy("map") %>%
      #   clearShapes()
      click <- input$map_click
      clat <- click$lat
      clng <- click$lng
      address <- revgeocode(c(clat,clng))
      
      print(clat)
      ## Add the circle to the map proxy
      ## so you dont need to re-render the whole thing
      ## I also give the circles a group, "circles", so you can
      ## then do something like hide all the circles with hideGroup('circles')
      leafletProxy('mymap') %>% # use the proxy to save computation
        clearShapes() %>%
        addCircles(lng=clng, lat=clat, group='circles',
                   weight=1, radius=100, color='black', fillColor='black',
                   popup=address, fillOpacity=0.5, opacity=1)
    })
    

    
})

