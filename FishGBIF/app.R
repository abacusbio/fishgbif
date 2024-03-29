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

bycatch <- read_tsv('../data/0036070-190918142434337.csv.gz')

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Fisheries Bycatch Data"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
           selectInput("species",
                       "Bycatch Species", 
                       sort(unique(bycatch$species))) ,
           sliderInput("years",
                       "Year Range", 
                       min = min(bycatch$year), 
                       max=max(bycatch$year), 
                       value=c( min(bycatch$year),max(bycatch$year) ), 
                       dragRange = TRUE,sep = "") 
           )
        ,

        # Show a plot of the generated distribution
        mainPanel(
           leafletOutput("nzmap", width="100%", height="800px")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$nzmap <- renderLeaflet({
        
        leaflet(options=leafletOptions(worldCopyJump=TRUE)) %>%
            setView(173.0,-41.0, zoom=6) %>%
            addProviderTiles(providers$Esri.OceanBasemap,
                             options = providerTileOptions()
            )
        
    })
    
    observe({
        selected <-
            bycatch %>% 
            filter(species == input$species) %>% 
            filter(year >= input$years[1], year <= input$years[2]) %>%
            select(decimalLatitude, decimalLongitude)
        
        leafletProxy("nzmap") %>% clearMarkers() %>%  clearShapes()  %>% addCircles(lat = selected$decimalLatitude,
                                             lng = selected$decimalLongitude)
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
