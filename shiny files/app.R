library(shiny)
library(shinythemes)
library(mapsapi)
library(shiny)
library(mapsapi)
library(tidyverse)
library(DT)
library(plotly)
library(leaflet)
library(mapsapi)
library(kableExtra)
library(tidyr)
library(lubridate)
library(DT)
library(data.table)
library(RColorBrewer)
library(gepaf)
library(osrm)

## load files for shiny



########### 
########### BUS


sl_routes<- read_csv("sl_routes.csv")

sl_routes_traveltimes<- read_csv("sl_routes_traveltimes.csv")
 
########### T
# load stops & travel times 
red_travel_times<- read_csv("red_travel_times.csv", show_col_types = FALSE) 
orange_travel_times<- read_csv("orange_travel_times.csv", show_col_types = FALSE)
blue_travel_times<- read_csv("blue_travel_times.csv", show_col_types = FALSE)
greenb_travel_times<- read_csv("greenb_travel_times.csv", show_col_types = FALSE)
greend_travel_times<- read_csv("greend_travel_times.csv", show_col_types = FALSE)
greenc_travel_times<- read_csv("greend_travel_times.csv", show_col_types = FALSE)
greene_travel_times<- read_csv("greene_travel_times.csv", show_col_types = FALSE)
mattpan_travel_times<- read_csv("mattpan_travel_times.csv", show_col_types = FALSE)

# t stops
red_stops <- read_csv("red_stops.csv",show_col_types = FALSE) %>% arrange(stop_lat)
orange_stops <- read_csv("orange_stops.csv",show_col_types = FALSE) %>% arrange(stop_lat )
greenb_stops <- read_csv("greenb_stops.csv",show_col_types = FALSE) %>% arrange(stop_lat) 
greenc_stops <- read_csv("greenc_stops.csv",show_col_types = FALSE) %>% arrange(stop_lat)
greend_stops <- read_csv("greend_stops.csv",show_col_types = FALSE) %>% arrange(stop_lat)
greene_stops <- read_csv("greene_stops.csv",show_col_types = FALSE) %>% arrange(stop_lat)
blue_stops <- read_csv("blue_stops.csv",show_col_types = FALSE) %>% arrange(stop_lat)
mattpan_stops <- read_csv("mattpan_stops.csv",show_col_types = FALSE) %>% arrange(stop_lat)

# Combine all t stops and its associated lon & lat
subwaystops<- rbind(red_stops,orange_stops,greenb_stops,greenc_stops,greend_stops,
                    greene_stops,blue_stops,mattpan_stops)
subwaystops$stop_lat <- round(subwaystops$stop_lat,2)
subwaystops$stop_lon <- round(subwaystops$stop_lon,2)
subwaystops<- subwaystops %>% unique()


########### 
########### EDA files

######## May 2022 no changes of service during this week
## load feed from 0514 to 0521
may<- read_csv("may.csv", show_col_types = FALSE)


# ferry in May
boat_trips_may<- may %>% filter(route_desc == "Ferry") %>% distinct(trip_id,.keep_all = T)
# Boat-Lewis				
# Boat-Hingham				
# Boat-Charlestown				

# Other potential values:
# Boat-Logan				
# Boat-George				
# Boat-Rowes
# Boat-Long-South
# Boat-Hull	
# Boat-Long	

# Commuter rail in May
# CR_trips_may<- may %>% filter(route_desc == "Commuter Rail") %>% distinct(trip_id,.keep_all = T)


# load data for Orange line density plot table
orange_to_south_df <- read_csv("orange_to_south_df.csv",show_col_types = FALSE)
orange_to_north_df <- read_csv("orange_to_north_df.csv",show_col_types = FALSE)


###########-------------------
# now create shiny 

################### 
########################## UI
ui <- fluidPage(
  navbarPage(
    "MBTA Transit Services",
    theme = "cosmo",
    tabPanel("MBTA", leafletOutput("map"),textOutput("intro"),height = 700)
    ,
    tabPanel(
      "Buses",
      fluidRow(column(width = 6,selectInput(inputId = "bus_stop", label = "Bus stop", choices = unique(sl_routes_traveltimes$stop_name),selected = NULL))
      )
      ,fluidRow(column(width = 12, DTOutput("bus_table")))
    ),
    tabPanel(
      "Ferry",
      fluidRow(column(width = 6,selectInput(inputId = "boat_stop", label = "Ferry stop", choices = unique(boat_trips_may$stop_name),selected = NULL))
      )
      ,fluidRow(column(width = 12, DTOutput("boat_table")))
    ),
    tabPanel("Rapid Transit", 
                 fluidRow(column(6,selectInput("Tstop1",label = "Origin", choices = subwaystops$stop_name, selected = NULL)),
                 (column(6,selectInput("Tstop2", label = "Destination", choices =subwaystops$stop_name, selected = NULL)))),
               leafletOutput("subwaymap")),
    tabPanel("EDA", 
             sidebarLayout(
               sidebarPanel(
                 selectInput("lines", "Orange Line:", choices = c("Northbound","Southbound"), selected = NULL)
               ),
               mainPanel(plotlyOutput("traveltimes_dens")))
    )
  )
  )






server <- function(input, output, session){
 
   # Tab:MBTA
  
  output$map <- renderLeaflet({
    # # Boston view
    leaflet() %>% setView(lng = -71.0589, lat = 42.3601, zoom = 12) %>% addProviderTiles("CartoDB.Positron") %>% 
      addPolylines(data = red_stops, lng = ~stop_lon,lat = ~stop_lat, color = "Red") %>% 
      addCircleMarkers(data = red_stops,lng = ~stop_lon, lat = ~stop_lat,radius=2,popup = red_stops$stop_name) %>% 
       
      addPolylines(data = mattpan_stops, lng = ~stop_lon,lat = ~stop_lat, color = "Red") %>% 
      addCircleMarkers(data = mattpan_stops,lng = ~stop_lon, lat = ~stop_lat,radius=2,popup = mattpan_stops$stop_name) %>% 
      
      addPolylines(data = blue_stops, lng = ~stop_lon,lat = ~stop_lat, color = "Blue") %>% 
      addCircleMarkers(data = blue_stops,lng = ~stop_lon, lat = ~stop_lat,radius=2,popup = blue_stops$stop_name) %>% 
      
      addPolylines(data = orange_stops, lng = ~stop_lon,lat = ~stop_lat, color = "Orange") %>% 
      addCircleMarkers(data = orange_stops,lng = ~stop_lon, lat = ~stop_lat,radius=2,popup = orange_stops$stop_name) %>% 
      
      addPolylines(data = greenb_stops, lng = ~stop_lon,lat = ~stop_lat, color = "Green") %>% 
      addCircleMarkers(data = greenb_stops,lng = ~stop_lon, lat = ~stop_lat,radius=2,popup = greenb_stops$stop_name) %>% 
      
      addPolylines(data = greenc_stops, lng = ~stop_lon,lat = ~stop_lat, color = "Green") %>% 
      addCircleMarkers(data = greenc_stops,lng = ~stop_lon, lat = ~stop_lat,radius=2,popup = greenc_stops$stop_name) %>% 
      
      addPolylines(data = greend_stops, lng = ~stop_lon,lat = ~stop_lat, color = "Green") %>% 
      addCircleMarkers(data = greend_stops,lng = ~stop_lon, lat = ~stop_lat,radius=2,popup = greend_stops$stop_name) %>% 
      
      addPolylines(data = greene_stops, lng = ~stop_lon,lat = ~stop_lat, color = "Green") %>% 
      addCircleMarkers(data = greene_stops,lng = ~stop_lon, lat = ~stop_lat,radius=2,popup = greene_stops$stop_name) 
     })
  
  
  output$intro <- renderText({
    "The app displays MBTA transit information and my exploratory analysis of it. Information used for visualization is extracted from hostrical records of MBTA services and from current google Directions API. 
      I selected data from Novemenber 2021 to October 2022 to explore."})
  
  # Tab bus
  
  output$bus_table <- renderDT({
    sl_routes_traveltimes %>% filter(stop_name == input$bus_stop) %>% dplyr::select(route_id,direction_id, headway, scheduled, actual) 
  })
  
  # output$SLboxplot2 <- renderPlotly(
  #   plot_ly(data = sl_routes_traveltimes, y=~headway, color = ~stop_name, type = "box") %>%
  #     layout(title="Box plot of silver line travel times by stop", yaxis=list(title="Time",range=c(0,1000)))
  # )
  # 
  
  # Tab:  Ferry
  output$boat_table <- renderDT({
    boat_trips_may %>% filter(stop_name == input$boat_stop) %>% dplyr::select(trip_headsign,arrival_time, departure_time, direction_destination)}) 
  
  # Tab:rapid transit 
  

  
  Tstop1 <- reactive({
    subwaystops %>% filter(stop_name == input$Tstop1) %>% select(stop_lon,stop_lat) %>% as.numeric()
     })
  
  Tstop2 <- reactive({
    subwaystops %>% filter(stop_name == input$Tstop2) %>% select(stop_lon,stop_lat) %>% as.numeric()
    
   })
  
  
  output$subwaymap <- renderLeaflet({
    
    api_key = "AIzaSyAZZEueevQyJrIRJUregAEbUC775LEfrxg"
    
    doc=mp_directions(
      origin = Tstop1(),
      destination = Tstop2(),
      mode = "transit",
      transit_mode = "subway",
      alternatives = TRUE,
      key = api_key,
      quiet = T)
    
    r = mp_get_routes(doc)
    
    pal = colorFactor(palette = "Dark2", domain = r$alternative_id) 
    
    leaflet() %>%
      addProviderTiles("CartoDB.Positron") %>%
      addPolylines(data = r, opacity = 1, weight = 7, color = ~pal(alternative_id),
                   # input for label is from r$distance_text)
                   label = ~duration_text,
                   labelOptions = labelOptions(noHide = TRUE)) %>% 
      addMarkers(lng = Tstop1()[1], lat = Tstop1()[2],popup = input$Tsop1) %>% 
      addMarkers(lng = Tstop2()[1], lat = Tstop2()[2],popup = input$Tsop2)
  })
  
  # Tab:EDA
  tdirection <- reactive({
    input$lines })
  
  output$traveltimes_dens <- renderPlotly(
    
    if(tdirection() == "Northbound"){
      org_n <- plot_ly(orange_to_north_df, x = ~x, y = ~y, color = ~dept_name)%>% add_lines() %>% 
        layout(title = "Northbound density plot by stop", yaxis=list(title="Density"), xaxis=list(title="Northbound Travel Times",range = c(0,3000)))
    }
    else{ tdirection() == "Souththbound"
      org_s <- plot_ly(orange_to_south_df, x = ~x, y = ~y, color = ~dept_name)%>% add_lines() %>% 
        layout(title = "Southbound density plot by stop", yaxis=list(title="Density"), xaxis=list(title="SouthBound Travel Times",range = c(0,2000)))
    }
  )
  
}

shinyApp(ui, server)





