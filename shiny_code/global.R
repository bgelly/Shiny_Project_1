# install.packages("shinydashboard")
# install.packages("data.table")

data1 = read.csv("/Users/bgelly/Documents/Folders/Coding/NYCDSA_Bootcamp/project1/Apr14SetTues1.csv")
dataf = data.frame(data1)

rownames(dataf) <- NULL
# create variable with colnames as choice
choice <- colnames(dataf)[-1]

