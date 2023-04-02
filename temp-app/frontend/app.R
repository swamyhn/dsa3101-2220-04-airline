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

writeup_summary <-
  "<li>Our app visualises air travel delays from flights across the years 1989 - 1990, 2000 - 2001 and 2006 - 2007.</li><li>Visualisations 1, 2 and 3 are meant to help ease visualisations of flight delays over such years and would help to give different insights.</li>"
writeup_motivation <-
  "<li>There were several important events that took place from 1987 to 2012 which had a significant impact on the aviation industry of the USA. Some of the most notable ones are: </li><div style='margin-top:9px;'><ol>
<div id='motivation'><em><li>Gulf War (1990-1991):</li></em><ul><li> The Gulf War led to a surge in air travel demand as military personnel and their families traveled to and from the region. Airlines increased their capacity to meet the demand, leading to a significant increase in profits for the industry.</ul></li></div>
<div id='motivation'><em><li>September 11 attacks (2001):</li></em><ul><li> The terrorist attacks on September 11, 2001, had a profound impact on the aviation industry, leading to increased security measures and changes in the way airlines operate. The attacks resulted in a significant decline in air travel demand, leading to financial losses for the industry.</ul></li></div>
<div id='motivation'><em><li>Global Financial Crisis (2007-2008):</li></em><ul><li> The global financial crisis had a significant impact on the aviation industry, leading to a decline in air travel demand and financial losses for airlines. Many airlines were forced to cut costs, reduce capacity, and lay off employees to stay afloat.</ul></li></div></div></ol>"

vis1_writeup <-
  "<ul><li>This visualisation shows monthly aggregated data for a chosen year. To go further in the analysis, a month within the year can be chosen to break the visualisations down into departure delay and arrival delay.
</li><li>Inputs: <ul><li>Year</li><li>Month</li></ul></li></ul>"
vis2_writeup <-
  "<ul><li>This visualisation aims to show the cascading delays for a flight with chosen origin, destination and year.</li><li>Inputs: <ul><li>Origin</li><li>Destination</li><li>Year</li></ul></li></ul>"
vis3_writeup <-
  "<ul><li>This visualisation shows the correlation between the variables and delay for a chosen year, flight type. Output rendered are the results output based on different derived when using different machine learning models.</li><li>Users can choose from 'Linear Model' or 'Decision Tree' for model selection, as well as 'Arriving' or 'Departing' flights for flight type selection.</li><li>Inputs: <ul><li>Model</li><li>Flight Type</li><li>Year</li></ul></li></ul>"

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
      "#motivation {margin-bottom:10px;}"
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
              <li style="font-size:20px;" id="motivation"> Visualisation 1: <div style="font-size: 16px;">',
                 vis1_writeup,
                 '</div> </li>
              <li style="font-size:20px;" id="motivation"> Visualisation 2: <div style="font-size: 16px;">',
                 vis2_writeup,
                 '</div> </li>
              <li style="font-size:20px;" id="motivation"> Visualisation 3: <div style="font-size: 16px;">',
                 vis3_writeup,
                 '</div> </li>
              </ol>',
                 '<h3> How to use app: </h3>',
                 '</div>',
                 sep = ''
               )
             )),
    tabPanel("Vis 1",
             sidebarLayout(
               sidebarPanel(
                 selectInput("year", "Select year",
                             choices = NULL,
                             selected = ""),
                 selectInput(
                   "month",
                   "Select month",
                   choices = NULL,
                   selected = ""
                 )
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
                   column(width = 6, plotOutput("selected_plot_dep"))
                 )
               )
             )),
    
    tabPanel("Vis 2",
             sidebarLayout(
               sidebarPanel(
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
                 )
               ),
               mainPanel(
                 htmlOutput("vis2_welcometext"),
                 leafletOutput("locations", height = 600),
                 #locations is name of map
                 br()
               )
             )),
    
    tabPanel("Vis 3",
             sidebarLayout(
               sidebarPanel(
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
                 )
               ),
               mainPanel(htmlOutput("vis3_welcometext"),
                         fluidRow(
                           column(12, plotOutput("plot1", height = 500), style = "padding-bottom: 15px;"),
                           column(12, plotOutput("plot2", height = 500))
                         ))
             ))
  )
)

# Define server function
server <- function(input, output) {
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
      choices = c("", unique(data$Year)),
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
  list_year2 <- as.character(seq(1987, 2012))
  
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
    print(paste0(
      url1,
      input$origin,
      url2,
      input$destination,
      url3,
      input$year2
    ))
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
    
    
    #setup an empty map
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
  
  ##VIS3 -------
  url5 <-
    "http://backend_ml_models:5000/coefficients?mode=" # + origin
  url6 <- "_"
  
  
  observeEvent(input$plot_button, {
    if (input$model == "Linear Model") {
      input_flight = ifelse(input$flight == "Arriving", "arr", "dep")
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
               url2,
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
        paste0(url5,
               input$mode,
               url6,
               input$flight,
               url6,
               input$year3,
               url6)
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
