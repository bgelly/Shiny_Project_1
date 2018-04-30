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
    

      leafletOutput("mymap")
    
  #   fluidRow(infoBoxOutput("rphBox"),
  #            infoBoxOutput("minBox"),
  #            infoBoxOutput("avgBox")),
  #   
  #   fluidRow(
  #     column(width = 9,
  #            box(width = NULL, solidHeader = TRUE,
  #               leafletOutput("mymap")
  #             ),
  #             box(width = NULL, status = "warning",
  #               plotOutput("hist")
  #                   )
  #            ),
  #             
  #     column(width = 3,
  #            box(width = NULL, status = "warning",
  #             sliderInput("slidertime", label = h3("Time Range (Military)"), min = 0, 
  #                 max = 24, value = c(0, 5)),
  #             
  #             sliderInput("sliderW", label = h3("Temperature (Fahrenheit)"), min = min(dataf$hourlydrybulbtempf), 
  #                 max = max(dataf$hourlydrybulbtempf), value = c(min(dataf$hourlydrybulbtempf), max(dataf$hourlydrybulbtempf))),
  #             
  #             checkboxGroupInput("checkDay", label = h3("Day of the Week"), 
  #                                choices = list("Monday" = "Monday", "Tuesday" = "Tuesday", "Wednesday" = "Wednesday", "Thursday" = "Thursday", "Friday" = "Friday", "Saturday" = "Saturday", "Sunday" = "Sunday"),
  #                                selected = "Monday")
  #             
  #             
  #               )
  #           )
  # 
  #         
  # 
  #   )
  )
)
)


    

        

