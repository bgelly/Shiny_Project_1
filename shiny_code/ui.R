#install.packages("shinydashboard")
#devtools::install_github('rstudio/DT')
library(shinydashboard)
library(shiny)

shinyUI(dashboardPage(
  dashboardHeader(
   title = "Uber Pickups"
   ),

  dashboardSidebar(disable = TRUE),

  dashboardBody(
    fluidRow(
      column(width = 9,
             box(width = NULL, solidHeader = TRUE,
                leafletOutput("mymap")
              )
             # box(width = NULL,
             #      uiOutput("hist")
              ),
              sliderInput("slidertime", label = h3("Slider Range"), min = 0, 
                  max = 23, value = c(0, 5))
            )
 
    )
  )
)

    

        

