#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(tidyverse)

fish <- read_tsv('../data/0036070-190918142434337.csv')

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Fisheries Data"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
           selectInput("species","Fish Species", sort(unique(fish$species))) 
           )
        ,

        # Show a plot of the generated distribution
        mainPanel(
           leafletOutput("nzmap")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$nzmap <- renderLeaflet({
        leaflet(options=leafletOptions(worldCopyJump=TRUE)) %>%
            setView(173.0,-41.0, zoom=5) %>%
            addProviderTiles(providers$Stamen.Terrain,
                             options = providerTileOptions(noWrap = TRUE)
            )
        
    })
    
    observe({
        selected <-
            fish %>% 
            filter(species == input$species) %>% 
            select(decimalLatitude, decimalLongitude)
        
        leafletProxy("nzmap") %>% clearMarkers() %>%  clearShapes()  %>% addCircles(lat = selected$decimalLatitude,
                                             lng = selected$decimalLongitude)
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
