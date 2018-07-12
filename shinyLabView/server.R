
library(shiny)
library(DT)

shinyServer(function(input, output) {

  data <- read.csv2("../dummyValues.csv")

  output$patients = DT::renderDataTable({
    data
  })

})
