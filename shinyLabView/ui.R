
library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  titlePanel("shiny Lab View"),

  mainPanel(
    DT::dataTableOutput("patients")
  )
))
