# Load R packages
library(shiny)
library(shinythemes)
library(ggplot2)
library(tidyverse)
library(plotly)
library(dplyr)
library(leaflet)
library(airportr)
library(shinyWidgets)
library(geosphere)
library(sp)
library(shinyjs)
library(htmltools)
library(leaflegend)
library(httr)
library(jsonlite)

origin_dest <- function(origin, year){
  df <- Delayed %>% filter(ORIGIN==origin, YEAR==year) %>%
    group_by(ORIGIN, DEST) %>%
    summarise_at(vars("delayed_dep", "delayed_arr", "total_flights"), sum) %>%
    ungroup()  %>% 
    mutate('Delayed_departure'=delayed_dep/total_flights*100, 
           'Delayed_arrival'=delayed_arr/total_flights*100)
  return(df)
}

sidebarPanel2 <- function (..., out = NULL, out2 = NULL, width = 4) 
{
  div(class = paste0("col-sm-", width), 
      tags$form(class = "well", ...),
      tags$style(HTML("
        #box {
          background-color: #f2f2f2; border: 1px solid #ccc; padding: 5px 25px 15px 20px;
        }
      ")),
      div(id = "box", out)
  )
}

sidebarPanel3 <- function (..., out = NULL, out2 = NULL, width = 4) 
{
  div(class = paste0("col-sm-", width), 
      tags$form(class = "well", ...),
      tags$style(HTML("
        #box box2 {
          background-color: #f2f2f2; border: 1px solid #ccc; padding: 5px 25px 15px 20px;
        }
      ")),
      div(id = "box", out),
      tags$style(HTML("
        #box2 {
          background-color: #f2f2f2; border: 1px solid #ccc; padding: 5px 25px 15px 20px; margin:10px 0px;
        }
      ")),
      div(id = "box2", out2)
  )
}

writeup_summary <- "<li>Our app visualises air travel delays from flights across 
the years 1989 - 1990, 2000 - 2001 and 2006 - 2007.</li><li>Visualisations 1, 2 
and 3 are meant to help ease visualisations of flight delays over such years and 
would help to give different insights.</li>"
writeup_motivation <- "<li>There were several important events that took place 
from 1987 to 2012 which had a significant impact on the aviation industry of the 
USA. Some of the most notable ones are: </li><div style='margin-top:9px;'><ol>
<div id='motivation'><em><li>Gulf War (1990-1991):</li></em><ul><li> The Gulf 
War led to a surge in air travel demand as military personnel and their families 
traveled to and from the region. Airlines increased their capacity to meet the 
demand, leading to a significant increase in profits for the industry.
</ul></li></div>
<div id='motivation'><em><li>September 11 attacks (2001):</li></em><ul><li> 
The terrorist attacks on September 11, 2001, had a profound impact on the 
aviation industry, leading to increased security measures and changes in the 
way airlines operate. The attacks resulted in a significant decline in air 
travel demand, leading to financial losses for the industry.</ul></li></div>
<div id='motivation'><em><li>Global Financial Crisis (2007-2008):
</li></em><ul><li> The global financial crisis had a significant impact on the 
aviation industry, leading to a decline in air travel demand and financial 
losses for airlines. Many airlines were forced to cut costs, reduce capacity, 
and lay off employees to stay afloat.</ul></li></div></div></ol>"

vis1_writeup <- "<ul><li>This visualisation shows periodic aggregated 
data for a chosen month or year. For further analysis, within specified month 
and year, the visualisation breaks down to show monthly departure delay and 
arrival delay.</li><li>Inputs: <ul><li>Year</li><li>Month</li></ul></li></ul>"
vis2_writeup <- "<ul><li>This visualistion has a geographical map which locates
the destination cities for a chosen origin city, and vice versa. The user 
may explore the percentage of delayed arrival and departure flights for the 
airports within a set month and year with the barchart and dataframe attached 
below.</li><li>Inputs: <ul><li>Year</li><li>Month</li><li>Origin/Destination
</li><li>City</li></ul></li></ul>"
vis3_writeup <- "<ul><li>This visualisation generates a heat map for delay 
factors including distance, precipitation, temperature, season and day of the 
week. This helps to highlight the cause of delay for flights in a selected year 
and flight direction (arrival/departure).</li><li>Inputs: <ul><li>Regression 
mode</li><li>Flight direction</li><li>Year</li></ul></li></ul>"

vis1_instruction <- "<ul><li>Select year = 'All' and month = 'All' for yearly 
aggregated data. This shows the trend of arrival delay from 1989 to 2012.</li>
</ul><ul><li>Select month = 'All' and a specified year for monthly aggregated 
data. This shows the trend of arrival delay from Jan to Dec within the chosen 
year.</li></ul><ul><li>Select year = 'All' and a specified month for yearly 
aggregated data. This shows the trend of arrival delay from 1989 to 2012 for a 
chosen month.</li></ul><ul><li>Select specified year and month for a break 
down of delayed arrival in the bottom left panel and delayed departure in the 
bottom right panel within the chosen month of the year.</li></ul>"

vis2_instruction <- "<ul><li>Select specified origin, destination and year to 
view flight map.</li></ul><ul><li>Red pinpoint represents origin airport and blue 
pinpoint represents destination airport. Green pinpoints are the airports which 
experienced cascading delay due to the flight from origin to destination.</li>
</ul><ul><li>You may scroll down to compare the percentage of delayed arrival 
and departure flights of destination aiports from the same origin airport in 
the dataframe below.</li></ul>"

vis3_instruction <- "<ul><li>Select regression mode, year and flight direction.
</li></ul><ul><li>The variables are independent factors that we model to find 
their relationship with flight delay.</li></ul><ul><li>Selecting the linear 
regression model 'lm' shows a barplot, while selecting the decision tree model 
'dt' shows a tree plot where left of each split is true, right is false.</li>
</ul>"
# Define UI
ui <- fluidPage(
  useShinyjs(),
  theme = shinytheme("cerulean"),
  tags$head(tags$style(
    HTML(
      # "body {background: #ADD8E6}",
      "#selected_year, #vis2_welcometext, #vis3_welcometext {
                    font-size: 20px;
                    padding-bottom: 20px;
      }",
      "#main-title {
        font-size:20px;
      }",
      "body {margin-left: -15px; margin-right: -15px}",
      "h1 {margin-top: 0px;}",
      "li {margin-bottom:3px; font-size:16px;}",
      "#motivation {margin-bottom:10px;}",
      "#plot2 {padding-top:15px;}"
    )
  )),
  navbarPage(
    title = div(id = "main-title", "Airline Delay Webapp"),
    tabPanel("Home",
             HTML(
               paste(
                 '<div style="padding: 10px 20px"><h1>Welcome to the Airline Delay Webapp!</h1>
             <h3> Introduction: </h3>
              <div  style="display: flex; flex-direction: column; align-items: left; font-size:16px;">',
                 writeup_summary,
                 '</div>',
                 '<h3> Motivation of Selected Timeframe: </h3>',
                 writeup_motivation,
                 '<h3> Visualisations Explained: </h3>',
                 '<ol>
              <li id="motivation"> Visualisation 1: <div>',
                 vis1_writeup,
                 '</div> </li>
              <li id="motivation"> Visualisation 2: <div>',
                 vis2_writeup,
                 '</div> </li>
              <li id="motivation"> Visualisation 3: <div>',
                 vis3_writeup,
                 '</div> </li>
              </ol>',
                 '</div>',
                 sep = ''
               )
             )),
    tabPanel("Vis 1",
             sidebarLayout(
               sidebarPanel2(
                 selectInput("year", "Select year",
                             choices = NULL,
                             selected = "All"),
                 selectInput(
                   "month",
                   "Select month",
                   choices = NULL,
                   selected = "All"
                 ),
                 out = HTML(paste('<h3> How to use visualisation </h3>', vis1_instruction))
               ),
               mainPanel(
                 htmlOutput("selected_year"),
                 fluidRow(
                   column(
                     width = 12,
                     plotOutput("selected_plot"),
                     style = "padding-bottom: 15px;"
                   ),
                   column(width = 6, plotOutput("selected_plot_arr")),
                   column(width = 6, plotOutput("selected_plot_dep")),
                 )
               )
             )),
    
    tabPanel("Vis 2",
             sidebarLayout(
               sidebarPanel2(
                 selectInput(
                   "origin",
                   "Select origin",
                   choices = NULL,
                   selected = ""
                 ),
                 selectInput(
                   "destination",
                   "Select destination",
                   choices = NULL,
                   selected = ""
                 ),
                 selectInput(
                   "year2",
                   "Select year",
                   choices = NULL,
                   selected = ""
                 ),
                 actionButton(
                   "submit_button",
                   "Enter!",
                   disabled = TRUE,
                   icon = icon("fas fa-plane", lib = "font-awesome", style = "color:black;")
                 ),
                 out = HTML(paste('<h3> How to use visualisation </h3>', vis2_instruction))
               ),
               mainPanel(
                 htmlOutput("vis2_welcometext"),
                 leafletOutput("locations", height = 600),
                 br(),
                 plotOutput("delay_bar"),
                 DT::DTOutput("delay_info")
               )
             )),
    
    tabPanel("Vis 3",
             sidebarLayout(
               sidebarPanel3(
                 selectInput(
                   "model",
                   label = "Select model",
                   choices = c("Linear Model", "Decision Tree", ""),
                   selected = ""
                 ),
                 selectInput(
                   "flight",
                   label = "Select flight type",
                   choices = c("Arriving", "Departing", ""),
                   selected = ""
                 ),
                 selectInput(
                   "year3",
                   label = "Select year",
                   choices = c("1989", "1990", "2000", "2001", "2006", "2007", ""),
                   selected = ""
                 ),
                 # Action button
                 actionButton(
                   "plot_button",
                   "Plot!",
                   icon = icon("fas fa-bar-chart", lib = "font-awesome", style = "color:black;")
                 ),
                 out = HTML(paste('<div><h3> How to use visualisation </h3>', vis3_instruction,"</div>")),
                 out2 = 
                   HTML("<h3> Explanation of variables </h3><div style='font-size: 10px;'><div>
<ul><li>distance: distance of route</div> </li></ul>
<ul><li>prcp_{origin/dest}: precipitation (mm) in the state of the origin/destination airport</li></ul>
<ul><li>snow_{origin/dest}: snowfall (mm) in the state of the origin/destination airport</li></ul>
<ul><li>snwd_{origin/dest}: snow depth (mm) in the state of the origin/destination airport</li></ul>
<ul><li>tmax_{origin/dest}: maximum temperature (°C) in the state of the origin/destination airport</li></ul>
<ul><li>tmin_{origin/dest}:minimum temperature (°C) in the state of the origin/destination airport</li></ul>
<ul><li>season_*: autumn, spring, summer and winter</li></ul>
<ul><li>day_of_week_*: 1 to 7 represents Monday to Sunday</li></ul>
<ul><li>crs_arr_bin_00-06: departure time 0000 to before 0600</li></ul>
<ul><li>crs_arr_bin_06-12: departure time 0600 to before 1200</li></ul>
<ul><li>crs_arr_bin_12-18: departure time 1200 to before 1800</li></ul>
<ul><li>crs_arr_bin_18-00: departure time 1800 onwards</li></ul></div>")
               ),
               mainPanel(htmlOutput("vis3_welcometext"),
                         uiOutput("vis3_plot"))
             ))
  )
)

# Define server function
server <- function(input, output) {
  ##vis1
  month_order <-
    c("Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec")
  data <- read.csv("./unbinned_delay_count.csv")
  data$Month <- factor(data$Month, levels = month_order)
  binned_data <- read.csv("./binned_delay_count.csv")
  observe({
    updateSelectInput(
      inputId = "year",
      choices = c("1989", "1990", "2000", "2001", "2006", "2007", ""),
      selected = ""
    )
  })

  output$selected_year <- renderText({
    if (input$year != "") {
      paste0("Data of flight delays in Year ", input$year)
    } else {
      paste0("Please select a year using the dropdown on the left panel")
    }
  })


  filtered_data_year <- reactive({
    subset(data, Year == input$year)
  })

  observe({
    updateSelectInput(inputId = "month", choices = c("", month_order[unique(filtered_data_year()$Month)]))
  })

  output$selected_plot <- renderPlot({
    if (input$year == "") {
      return(NULL)
    } else {
      ggplot(filtered_data_year(), aes(x = Month, y = Arr_Delay_Count)) +
        geom_bar(stat = "identity",
                 fill = "skyblue",
                 color = "black") +
        labs(title = "Monthly Aggregated Delay Data",
             x = "Month",
             y = "Delay Count") +
        theme(
          axis.title = element_text(size = 15),
          plot.title = element_text(size = 17),
          axis.text = element_text(size = 14)
        )
    }
  })

  filtered_data_binned <- reactive({
    subset(binned_data, Year == input$year & Month == input$month)
  })

  filtered_data_binned_arr <- reactive({
    filtered_data_binned() %>% select(starts_with("Arr_")) %>% gather(key = "arrBin", value = "value")
  })

  filtered_data_binned_dep <- reactive({
    filtered_data_binned() %>% select(starts_with("Dep_")) %>% gather(key = "depBin", value = "value")
  })


  observeEvent(input$year, {
    # Render the plots as null
    output$selected_plot_arr <- renderPlot(NULL)
    output$selected_plot_dep <- renderPlot(NULL)
  })

  monthPlot_bins <-
    c(
      "60-74",
      "75-89",
      "90-104",
      "105-119",
      "120-134",
      "135-149",
      "150-164",
      "165-179",
      "Above 180"
    )

  # Create the ordered factor
  monthPlot_bins <- factor(monthPlot_bins, levels = monthPlot_bins)
  observeEvent(input$month, {
    output$selected_plot_arr <- renderPlot({
      if (input$month == "") {
        return(NULL)
      } else {
        ggplot(filtered_data_binned_arr(),
               aes(x = monthPlot_bins, y = value)) +
          geom_bar(stat = "identity",
                   fill = "green",
                   color = "black") +
          labs(
            title = paste0("Arrival Flights Delay Data (", input$month, ")"),
            x = "Delay Time (minutes)",
            y = "Delay Count"
          ) +
          theme(
            axis.title = element_text(size = 15),
            plot.title = element_text(size = 17),
            axis.text = element_text(size = 14)
          ) +
          coord_flip()
      }
    })

    output$selected_plot_dep <- renderPlot({
      if (input$month == "") {
        return(NULL)
      } else {
        ggplot(filtered_data_binned_dep(),
               aes(x = monthPlot_bins, y = value)) +
          geom_bar(
            stat = "identity",
            fill = "purple",
            color = "black"
          ) +
          labs(
            title = paste0("Departure Flights Delay Data (", input$month, ")"),
            x = "Delay Time (minutes)",
            y = "Delay Count"
          ) +
          theme(
            axis.title = element_text(size = 15),
            plot.title = element_text(size = 17),
            axis.text = element_text(size = 14)
          ) +
          coord_flip()
      }
    })
  })


  
  ##vis2:
  url1 <- "http://backend_cascade:5000/query?origin=" # + origin
  url2 <- "&dest=" # + destination
  url3 <- "&year=" # + year
  list_unique_origins <-
    c('ATL',
      'ORD',
      'DFW',
      'LAX',
      'PHX',
      'DEN',
      'IAH',
      'LAS',
      'DTW',
      'STL')
  list_unique_dests <-
    c('ATL',
      'ORD',
      'DFW',
      'LAX',
      'PHX',
      'DEN',
      'IAH',
      'LAS',
      'DTW',
      'STL')
  
  list_year2 <- c("1989", "1990", "2000", "2001", "2006", "2007", "")
  
  dat <- reactiveVal(NULL)
  
  reactive_text <- eventReactive(input$submit_button, {
    cascade_data <- dat()
    if (nrow(cascade_data) == 0) {
      HTML(
        "<div> You have selected",
        input$origin,
        "-->",
        input$destination,
        "in Year",
        input$year2,
        "<br></br>",
        "However, the chosen inputs has 0 flights recorded. </div>"
      )
    } else {
      paste(
        "You have selected",
        input$origin,
        "-->",
        input$destination,
        "in Year",
        input$year2
      )
    }
  })
  
  output$vis2_welcometext <- renderUI({
    if (input$origin == "" ||
        input$destination == "" || input$year2 == "") {
      paste0("Please select all inputs from the left panel")
    } else if (input$submit_button == 0) {
      paste0("Please press the enter button")
    } else {
      reactive_text()
    }
  })
  
  observeEvent(input$submit_button, {
    response <-
      GET(paste0(
        url1,
        input$origin,
        url2,
        input$destination,
        url3,
        input$year2
      ))
    content <- content(response, as = 'text')
    json_content <- fromJSON(content)
    df <- as.data.frame(json_content)
    dat(df)
  })
  
  
  reactive_leaflet <- eventReactive(input$submit_button, {
    cascade <- dat()
    if (nrow(cascade) == 0) {
      return (NULL)
    }
    
    cascade <-
      cascade %>% filter(row_number() == 1 |
                           delayed_dep > 0 & row_number() > 1)
    
    tempOrigin <- lapply(cascade$ORIGIN, airport_location)
    cascade$originLat <- sapply(tempOrigin, function(x)
      x$Latitude)
    cascade$originLng <- sapply(tempOrigin, function(x)
      x$Longitude)
    
    tempDest <- lapply(cascade$DEST, airport_location)
    cascade$destLat <- sapply(tempDest, function(x)
      x$Latitude)
    cascade$destLng <- sapply(tempDest, function(x)
      x$Longitude)
    cascade$markerColour <- c("blue")
    cascade$markerColour[1] = "red"
    
    cascade$markerColour2 <- c("green")
    markerColour2 <- cascade$markerColour2
    
    markerColour <- cascade$markerColour
    
    icons <- makeAwesomeIcon(icon = 'ios-close',
                             library = 'ion',
                             markerColor =  markerColour)
    icons2 <- makeAwesomeIcon(icon = 'ios-close',
                              library = 'ion',
                              markerColor =  markerColour2)
    
    
    iconSet <- awesomeIconList(
      origin = makeAwesomeIcon(
        icon = 'ios-close',
        library = 'ion',
        markerColor = 'red'
      ),
      destination = icons,
      `cascade dests` = icons2
    )
    
    
    greenSubset <-
      cascade %>% filter(cascade$DEST != input$origin &
                           cascade$DEST != input$destination) %>% filter(delayed_dep > 0)
    polyLinesSubset <-
      cascade %>% filter(cascade$DEST != input$origin)
    
    first_row_data <-
      gcIntermediate(
        c(cascade$originLng[1], cascade$originLat[1]),
        c(cascade$destLng[1], cascade$destLat[1]),
        n = 100,
        addStartEnd = TRUE,
        sp = TRUE
      )
    first_row_list <- cascade[1, ]
    locations <- leaflet(data = cascade)
    map <- addTiles(locations)
    tempMap <-
      addAwesomeMarkers(
        data = cascade,
        lat = ~ originLat,
        lng = ~ originLng,
        map = map,
        popup = ~ ORIGIN,
        icon = icons
      ) %>%
      addPolylines(
        data = first_row_data,
        color = "red",
        opacity = 0.5,
        weight = cascade$delayed_arr[1],
        label = HTML(
          "<span style='font-size:17px'> <div><strong>",
          cascade$ORIGIN[1],
          "->",
          cascade$DEST[1],
          "</strong></div>",
          "num delayed arr:",
          cascade$delayed_arr[1],
          "</span>"
        )
      ) %>%
      addAwesomeMarkers(
        data = greenSubset,
        lat = ~ destLat,
        lng = ~ destLng,
        popup = ~ DEST,
        icon = icons2
      ) %>%
      addPopups(
        data = first_row_list,
        lat = ~ destLat,
        lng = ~ destLng,
        popup =  ~ DEST
      ) %>%
      addPopups(
        data = first_row_list,
        lat = ~ originLat,
        lng = ~ originLng,
        popup =  ~ ORIGIN
      ) %>%
      addPopups(
        data = greenSubset,
        lat = ~ destLat,
        lng = ~ destLng,
        popup =  ~ DEST
      )
    
    polyLinesSubset <-
      polyLinesSubset %>% mutate(id = row.names(.)) %>%
      mutate(
        label = paste(
          "<span style='font-size:17px'><div><strong>",
          polyLinesSubset$ORIGIN,
          "->",
          polyLinesSubset$DEST,
          "</strong></div>",
          "num delayed dep:",
          polyLinesSubset$delayed_dep,
          "</span>"
        )
      )
    
    flights_lines <- apply(polyLinesSubset, 1, function(x) {
      points <- data.frame(
        lng = as.numeric(c(x["originLng"],
                           x["destLng"])),
        lat = as.numeric(c(x["originLat"],
                           x["destLat"])),
        stringsAsFactors = F
      )
      coordinates(points) <- c("lng", "lat")
      Lines(Line(points), ID = x["id"])
    })
    
    flights_lines <-
      SpatialLinesDataFrame(SpatialLines(flights_lines), polyLinesSubset)
    
    polyLinesSubset <- polyLinesSubset %>% mutate(id = row.names(.))
    tempMap %>%
      addPolylines(
        data = flights_lines,
        opacity = 0.5,
        color = "blue",
        weight = ~ delayed_dep,
        label = lapply(flights_lines$label, HTML)
      ) %>%
      addLegendAwesomeIcon(iconSet = iconSet,
                           position = "bottomright",
                           title = "marker legend") %>%
      addLegend(
        position = 'topright',
        colors = c("red", "blue"),
        labels = c("delayed arr to dest", "delayed dep (cascaded)"),
        opacity = 0.5,
        title = 'line colour legend'
      )
    
  })
  
  output$locations <- renderLeaflet({
    if (input$submit_button == 0) {
      NULL
    } else {
      reactive_leaflet()
    }
  })
  
  observe({
    updateSelectInput(
      inputId = "origin",
      choices = c("", sort(unique(
        list_unique_origins
      ))),
      selected = ""
    )
    updateSelectInput(
      inputId = "destination",
      choices = c("", sort(unique(
        list_unique_dests
      ))),
      selected = ""
    )
    updateSelectInput(
      inputId = "year2",
      choices = c("", list_year2),
      selected = ""
    )
  })
  
  observeEvent(input$origin, {
    selected_origin <- input$origin
    destination_choices <- list_unique_dests
    if (selected_origin != "") {
      destination_choices <-
        list_unique_dests[list_unique_dests != selected_origin]
    }
    updateSelectInput(
      inputId = "destination",
      choices = destination_choices,
      selected = input$destination
    )
  })
  
  observeEvent(input$destination, {
    selected_destination <- input$destination
    origin_choices <- list_unique_origins
    if (selected_destination != "") {
      origin_choices <-
        list_unique_origins[list_unique_origins != selected_destination]
    }
    updateSelectInput(inputId = "origin",
                      choices = origin_choices,
                      selected = input$origin)
  })
  
  
  observeEvent(c(input$origin, input$destination, input$year2), {
    if (input$origin != "" &
        input$destination != "" & input$year2 != "") {
      shinyjs::enable("submit_button")
    } else {
      shinyjs::disable("submit_button")
    }
  })
  
  output$delay_bar <- renderPlot({
    data <- origin_dest(input$origin, input$year2)
    data <- data %>% select(ORIGIN, Delayed_arrival, Delayed_departure) %>%
      gather(variable, percentage , -ORIGIN)
    ggplot(data, aes(ORIGIN, percentage, fill = variable)) +
      geom_bar(stat="identity", position = "dodge") +
      labs(title=paste("Percentage of delayed flights of", input$destination, 
                       "compared to other destination airports from",
                       input$origin))
  })
  output$delay_info <- DT::renderDT({
    origin_dest(input$origin, input$year2) %>%
      DT::datatable()
  })
  
  ##Vis3
  url5 <- "http://backend_ml_models:5000/coefficients?mode="
  url7 <- "http://backend_ml_models:5000/plots?mode="
  url6 <- "_"
  
  output$vis3_plot <- renderUI({
    tags$div(
      if (input$plot_button != 0) {
        plotOutput("plot1")
      },
      if (input$plot_button != 0) {
        plotOutput("plot2")
      }
    )
  })
  
  
  observeEvent(input$plot_button, {
    input_flight = ifelse(input$flight == "Arriving", "arr", "dep")
    if (input$model == "Linear Model") {
      url_1 <-
        paste0(url5,
               "lm",
               url6,
               input_flight,
               url6,
               input$year3,
               url6,
               'T')
      url_2 <-
        paste0(url5,
               "lm",
               url6,
               input_flight,
               url6,
               input$year3,
               url6,
               'F')
      
      response1 <- GET(url_1)
      content1 <- content(response1, as = 'text')
      json_content1 <- fromJSON(content1)
      coefficients <- as.data.frame(json_content1)
      response2 <- GET(url_2)
      content2 <- content(response2, as = 'text')
      json_content2 <- fromJSON(content2)
      coefficients2 <- as.data.frame(json_content2)
      output$plot1 <- renderPlot({
        coefficients$Variables <-
          factor(coefficients$Variables,
                 levels = rev(coefficients$Variables[order(coefficients$Coefficients)]))
        coefficients_processed <-
          coefficients %>% mutate(colour = ifelse(Coefficients > 0, "#619CFF", "#F8766D"))
        ggplot(coefficients_processed,
               aes(
                 x = Coefficients,
                 y = Variables,
                 fill = colour
               )) +
          geom_bar(stat = "identity") +
          theme(
            axis.title = element_text(size = 17),
            plot.title = element_text(size = 18),
            axis.text = element_text(size = 14),
            legend.text = element_text(size = 14),
            legend.title = element_text(size = 14)
          ) +
          labs(x = "Correlation", y = "Variables") +
          scale_fill_manual(
            name = "Legend",
            values = c("#F8766D", "#619CFF"),
            labels = c("negative correlation", "positive correlation")
          ) +
          ggtitle("Plot with standardised coefficients (T)")
      })
      
      output$plot2 <- renderPlot({
        coefficients2$Variables <-
          factor(coefficients2$Variables,
                 levels = rev(coefficients2$Variables[order(coefficients2$Coefficients)]))
        coefficients_processed <-
          coefficients2 %>% mutate(colour = ifelse(Coefficients > 0, "#619CFF", "#F8766D"))
        ggplot(coefficients_processed,
               aes(
                 x = Coefficients,
                 y = Variables,
                 fill = colour
               )) +
          geom_bar(stat = "identity") +
          theme(
            axis.title = element_text(size = 17),
            plot.title = element_text(size = 18),
            axis.text = element_text(size = 14),
            legend.text = element_text(size = 14),
            legend.title = element_text(size = 14)
          ) +
          labs(x = "Correlation", y = "Variables") +
          scale_fill_manual(
            name = "Legend",
            values = c("#F8766D", "#619CFF"),
            labels = c("negative correlation", "positive correlation")
          ) +
          ggtitle("Plot with unstandardised coefficients (F)")
      })
      
    } else {
      url_1 <-
        paste0(url7,
               'dt',
               url6,
               input_flight,
               url6,
               input$year3)
      response1 <- GET(url_1)
      content1 <- content(response1, as = 'text')
      json_content1 <- fromJSON(content1)
      df1 <- as.data.frame(json_content1)
      output$plot1 <- renderPlot({
        coefficients$Variables <-
          factor(coefficients$Variables,
                 levels = rev(coefficients$Variables[order(coefficients$Coefficients)]))
        coefficients_processed <-
          coefficients %>% mutate(colour = ifelse(Coefficients > 0, "#619CFF", "#F8766D"))
        
        ggplot(coefficients_processed,
               aes(
                 x = Coefficients,
                 y = Variables,
                 fill = colour
               )) +
          geom_bar(stat = "identity") +
          theme(
            axis.title = element_text(size = 17),
            axis.text = element_text(size = 14),
            legend.text = element_text(size = 14),
            legend.title = element_text(size = 14)
          ) +
          labs(x = "Correlation", y = "Variables") +
          scale_fill_manual(
            name = "Legend",
            values = c("#F8766D", "#619CFF"),
            labels = c("negative correlation", "positive correlation")
          )
      })
    }
  })
  
  observeEvent(c(input$model, input$flight, input$year3), {
    if (input$model != "" & input$flight != "" & input$year3 != "") {
      shinyjs::enable("plot_button")
    } else {
      shinyjs::disable("plot_button")
    }
  })
  
  reactive_text3 <- eventReactive(input$plot_button, {
    if (input$model == "Linear Model") {
      paste0(
        "Barplot of correlation of variables in relation to ",
        input$flight,
        " flights in Year ",
        input$year3,
        " (",
        input$model,
        ")"
      )
    } else {
      paste0(
        "Barplot of correlation of variables in relation to ",
        input$flight,
        " flights in Year ",
        input$year3,
        " (",
        input$model,
        " Model)"
      )
    }
  })
  
  output$vis3_welcometext <- renderUI({
    if (input$model == "" || input$flight == "" || input$year3 == "") {
      paste0("Please select all inputs from the left panel")
    } else if (input$plot_button == 0) {
      paste0("Please press the plot button")
    } else {
      reactive_text3()
    }
  })
  
} # server



# Create Shiny object
shinyApp(ui = ui, server = server)
