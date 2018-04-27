filtereddata = dataf

#install.packages("googleVis")
library(googleVis)
#devtools::install_github("rstudio/leaflet")
library(leaflet)

shinyServer(function(input, output, session){
  
  output$range <- renderPrint({ input$timeslide })
  
    output$hist <- renderGvis(
      gvisHistogram(dataf[,input$selected, drop=FALSE]
                    )
      )

    
    output$mymap <- renderLeaflet({
      leaflet() %>%
        addProviderTiles("CartoDB.Positron") %>%
        setView(lng = -73.99, lat = 40.75, zoom = 12)
        #addCircles(~Lon, ~Lat)
    })
    
    observeEvent(input$slidertime, {
      
      leafletProxy("mymap") %>%
        clearShapes()
      
      filterData = filter(dataf, dataf$timeNum  %in% c(seq(input$slidertime[1], input$slidertime[2])))
      
      leafletProxy("mymap", data = filterData) %>%
        clearMarkers() %>%
        addCircles(lng = ~Lon, lat = ~Lat)
      
  
      

    })
    # observe({
    #   print(typeof((input$slidertime[1])))
    #   print(head(filtereddata$timeNum))
    #   print(seq(input$slidertime[1], input$slidertime[2]))
    # })

    

})

