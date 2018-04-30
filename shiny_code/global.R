#install.packages("shinydashboard")
#install.packages("data.table")
#intall.packages("dplyr")

library(shinydashboard)
library(data.table)
library(dplyr)

data1 = read.csv("/Users/bgelly/Documents/Folders/Coding/NYCDSA_Bootcamp/project1/shiny/Apr14Set.csv")
dataf = data.frame(data1)

rownames(dataf) <- NULL
# create variable with colnames as choice
choice <- colnames(dataf)[-1]

