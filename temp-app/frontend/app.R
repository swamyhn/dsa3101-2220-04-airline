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
library(grid)
library(png)

#added
library(shinycssloaders)

origin_dest <- function(origin, year){
  df <- Delayed %>% filter(ORIGIN==origin, YEAR==year) %>%
    group_by(ORIGIN, DEST) %>%
    summarise_at(vars("delayed_dep", "delayed_arr", "total_flights"), sum) %>%
    ungroup()  %>%
    mutate('Delayed_departure'=delayed_dep/total_flights*100,
           'Delayed_arrival'=delayed_arr/total_flights*100)
  return(df)
}

sidebarPanel <- function (..., out = NULL, out2 = NULL, width = 4) 
{
  div(class = paste0("col-sm-", width), 
      tags$form(class = "well", ...),
      tags$style(HTML("
        #box {
          background-color: #f2f2f2; border: 1px solid #ccc; padding: 5px 25px 15px 20px;
        }
      "))
  )
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

writeup_summary <- "The Airline Delay WebApp visualises air travel delays from flights across 
the years 1989 - 1990, 2000 - 2001 and 2006 - 2007."
writeup_motivation <- "There were several important events that took place 
from 1987 to 2012 which had a significant impact on the aviation industry of the 
USA. Some of the most notable ones are in 1990, 2001 and 2007. <br> 

<div style='margin-top:9px;'>

<ol>
  <li id='motivation'>
  <em>Gulf War (1990):</em> 
  The Gulf War led to a surge in air travel demand as military personnel and their 
  families traveled to and from the region. Airlines increased their capacity to meet 
  the demand, leading to a significant increase in profits for the industry.</li>

  <li id='motivation'>
  <em>September 11 attacks (2001):</em>
  The terrorist attacks on September 11, 2001, had a profound impact on the 
  aviation industry, leading to increased security measures and changes in the 
  way airlines operate. The attacks resulted in a significant decline in air 
  travel demand.</li>

  <li id='motivation'>
  <em>Global Financial Crisis (2007):</em> 
  The global financial crisis had a significant impact on the 
  aviation industry, leading to a decline in air travel demand and financial 
  losses for airlines.</li>
</ol>

In order to see the impacts of these events, we decided on these 3 years and their
corresponding preceeding years.

</div>"

vis1_writeup <- "This visualisation shows periodic aggregated 
data for a chosen year (light purple). The red dots represent the data for the previous year
so as to show comparison. For further analysis, the visualisation also 
breaks down to show monthly departure and arrival delays within a specific 
month (dark purple)."
vis2_writeup <- "This visualisation shows the cascading of delays for a chosen flight 
route.<br>

<div style='background-color: #f5f5f5; padding: 10px;'>
<em>How to interpret the visualisation?</em><br>
The user selects a flight route by inputting an origin and destination state. 
Other flight routes from the destination state to other states will appear. These 
are delays that occur when there is a delay from the origin to the destination state.</div>"

vis3_writeup <- "This visualisation generates a bar graph showing the importance
of delay factors, detemined by a linear regression model. This helps to highlight 
the important causes of delays for flights in a selected year and flight direction 
(arrival/departure).<br>
<div style='background-color: #f5f5f5; padding: 10px;'>
<em>How to interpret the visualisation?</em><br>
The y-axis shows the delay factors, while the x-axis shows the impact of delay factors
on delays. If the bar graph is extending towards the left (dark purple), the 
specific feature has a negative impact on delays. If the bar graph extends towards the 
right (light purple), the specific feature has a positive impact on delays. The longer 
the bar, the more important a feature is. If no bar graph is present, the feature does 
not give any information regarding delays.</div>"
vis4_writeup <- "This visualisation showcases a decision tree plot, which depicts
the importance of each feature in the classification of delays or no delays.<br>
<div style='background-color: #f5f5f5; padding: 10px;'>
<em>How to interpret the visualisation?</em><br>
There would be a condition at the top of each node. The branch that splits towards 
the left represents true and towards the right represent false. Note that for categorical
variables, a value less than or equal to 0 can be interpreted as equal to 0.</div>"

# vis1_instruction <- "<ul><li>Select year = 'All' and month = 'All' for yearly 
# aggregated data. This shows the trend of arrival delay from 1989 to 2012.</li>
# </ul><ul><li>Select month = 'All' and a specified year for monthly aggregated 
# data. This shows the trend of arrival delay from Jan to Dec within the chosen 
# year.</li></ul><ul><li>Select year = 'All' and a specified month for yearly 
# aggregated data. This shows the trend of arrival delay from 1989 to 2012 for a 
# chosen month.</li></ul><ul><li>Select specified year and month for a break 
# down of delayed arrival in the bottom left panel and delayed departure in the 
# bottom right panel within the chosen month of the year.</li></ul>"

vis1_instruction <- "Select specific year and month to view the summary
statistics for arrival and departure delays."

vis1_instruction2 <- "<span style='color: #d63e2a;'>Red </span> dots on Monthly Aggregated Delay
plot represents delay counts from the previous year."

# vis2_instruction <- "<ul><li>Select specified origin, destination and year to 
# view flight map.</li></ul><ul><li>Red pinpoint represents origin airport and blue 
# pinpoint represents destination airport. Green pinpoints are the airports which 
# experienced cascading delay due to the flight from origin to destination.</li>
# </ul><ul><li>You may scroll down to compare the percentage of delayed arrival 
# and departure flights of destination aiports from the same origin airport in 
# the dataframe below.</li></ul>"

vis2_instruction <- "Select specified origin, destination and year to 
view flight map."

vis2_instruction2 <- "<span style='color: #d63e2a;'>Red </span>
pinpoint represents origin airport. <br><span style='color: #38a9dc;'>Blue </span>
pinpoint represents destination airport. <br><span style='color: #71ae26;'>Green </span>
pinpoints are the airports which experienced cascading delays due to the flight delay from 
origin to destination."
# <br><br>You may scroll down to compare the percentage of delayed arrival 
# and departure flights of destination aiports from the same origin airport in 
# the dataframe below."

# vis3_instruction <- "<ul><li>Select regression mode, year and flight direction.
# </li></ul><ul><li>The variables are independent factors that we model to find 
# their relationship with flight delay.</li></ul><ul><li>Selecting the linear 
# regression model 'lm' shows a barplot, while selecting the decision tree model 
# 'dt' shows a tree plot where left of each split is true, right is false.</li>
# </ul>"

vis3_instruction <- "Select fight type and year to view relationships between variables
and flight delays."

vis4_instruction <- "Select flight type and year to view Decision Tree plots."

explanation_of_vars <- HTML("<h3> Explanation of variables </h3>
<div style='font-size: 16px;'>
  <ul><li><em>Distance:</em><br> distance of route (km)</li></ul>
  <ul><li><em>(Origin/Destination) Precipitation:</em><br>  precipitation (mm) in the state of the origin/destination airport</li></ul>
  <ul><li><em>(Origin/Destination) Snow:</em><br>  snowfall (mm) in the state of the origin/destination airport</li></ul>
  <ul><li><em>(Origin/Destination) Snow Depth:</em><br>  snow depth (mm) in the state of the origin/destination airport</li></ul>
  <ul><li><em>(Origin/Destination) Mean Temperature:</em><br>  mean temperature (°C) in the state of the origin/destination airport</li></ul>
  <ul><li><em>Autumn, Spring, Summer, Winter:</em><br>  seasons</li></ul>
  <ul><li><em>Monday, Tuesday, Wednesday, etc.:</em><br>  days of the week</li></ul>
  <ul><li><em>(Departure/Arrival) Time: 12am-6am:</em><br>  scheduled departure/arrival time between 12am to 6am</li></ul>
  <ul><li><em>(Departure/Arrival) Time: 6am-12pm:</em><br>  scheduled departure/arrival time between 6am to 12pm</li></ul>
  <ul><li><em>(Departure/Arrival) Time: 12pm-6pm:</em><br>  scheduled departure/arrival time between 12pm to 6pm</li></ul>
  <ul><li><em>(Departure/Arrival) Time: 6pm-12am:</em><br>  scheduled departure/arrival time between 6pm to 12am</li></ul>
</div>")


# Define UI
ui <- fluidPage(
  useShinyjs(),
  # tags$head(tags$style(HTML('.navbar-static-top {background-color: #4D7298;'))),
  # tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "https://fonts.googleapis.com/css?family=Helvetica+Neue&display=swap")),
  tags$link(
    href = "https://fonts.googleapis.com/css2?family=Alegreya+Sans+SC:wght@700&family=Puritan&family=Varta:wght@500&display=swap",
    rel = "stylesheet"
  ),
  tags$head(tags$style(HTML("
  #logo-image {
    position: absolute;
    top: 0;
    left: 0;
    z-index: 9999;
  }
"))),
  tags$head(tags$style(
    HTML(
      # "body {background: #ADD8E6}",
      "#selected_year, #vis2_welcometext, #vis3_welcometext, #vis4_welcometext {
                    font-size: 20px;
                    padding-bottom: 20px;
      }",
      "#main-title {
        font-size:20px;
        color:#002045;
        font-family: 'Alegreya Sans SC', sans-serif;
        font-weight: 700;
      }",
      "#other-title {
        font-size:20px;
        color:#002045;
        font-family: 'Puritan', sans-serif;
        font-weight: 400;
      }",
      "body {margin-left: -15px; margin-right: -15px; font-size:16px; font-family: 'Varta', sans-serif;}",
      "h1 {margin-top: 0px; font-family: 'Varta', sans-serif;}",
      "h3 {font-weight: bold; font-family: 'Varta', sans-serif;}",
      "li {margin-bottom:3px; font-size:16px; font-family: 'Varta', sans-serif;}",
      "#motivation {margin-bottom:10px; font-family: 'Varta', sans-serif;}",
      "#plot2 {padding-top:15px;}"
    )
  )),
  navbarPage(
    # title = div(id = "main-title", "Airline Delay Webapp"),
    title = div(
      img(src = "logo.png", height = 25), # set the path and height of the logo image
      style = "display: flex; align-items: center; justify-content: center;"), # center the logo
    bg = '#9ea2d1',
    tabPanel(div(id = "other-title", "Home"),
            headerPanel("Welcome to the Airline Delay WebApp!"),
            tags$img(src = "airplane.jpg", width = "100%", height = "300px", style = "padding-bottom: 20px;"),
             HTML(
               paste(
                 '<div style="padding: 10px 20px">
             <h3> Introduction </h3>
              <div  style="display: flex; flex-direction: column; align-items: left; font-size:16px;">',
                 writeup_summary,
                 '</div>',
                 '<h3> Motivation of Selected Timeframe </h3>',
                 writeup_motivation,
                 '<h3> Visualisations Explained </h3>',
                 '<ol>
              <li id="motivation"><u> Summary Statistics </u><div>',
                 vis1_writeup,
                 '</div> </li>
              <li id="motivation"><u> Cascading Delays </u><div>',
                 vis2_writeup,
                 '</div> </li>
              <li id="motivation"><u> Linear Regression </u><div>',
                 vis3_writeup,
                 '</div> </li>
              <li id="motivation"><u> Decision Tree </u><div>',
                 vis4_writeup,
                 '</div> </li>
              </ol>',
                 '</div>',
                 sep = ''
               )
             )),
    tabPanel(div(id = "other-title", "Summary Statistics"),
            headerPanel("Welcome to Summary Statistics!"),
            tags$img(src = "airplane.jpg", width = "100%", height = "300px", style = "padding-bottom: 20px;"),
            #  mainPanel(
              # tags$div(
              #   HTML(paste('<h3> How to use visualisation </h3>', vis1_instruction)),
              #   style = "background-color: #f2f2f2; border: 1px solid #ccc; padding: 5px 25px 15px 20px;"
              # )),
             sidebarLayout(
               sidebarPanel2(
                tags$div(
                    HTML(vis1_instruction),
                    style = "padding-bottom: 20px; font-size: 18px;"
                  ),
                 selectInput("year", "Select year",
                             choices = NULL,
                             selected = "All"),
                 selectInput(
                   "month",
                   "Select month",
                   choices = NULL,
                   selected = "All"
                 ),
                out =  tags$div(
                  HTML(vis1_instruction2),
                  style = "padding-top: 10px;"
                )
                #  out = HTML(paste('<h3> How to use visualisation </h3>', vis1_instruction))
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
    
    tabPanel(div(id = "other-title", "Cascading Delays"),
            headerPanel("Welcome to Cascading Delays!"),
            tags$img(src = "airplane.jpg", width = "100%", height = "300px", style = "padding-bottom: 20px;"),
             sidebarLayout(
               sidebarPanel2(
                tags$div(
                    HTML(vis2_instruction),
                    style = "padding-bottom: 20px; font-size: 18px;"
                  ),
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
                 out =  tags$div(
                    HTML(vis2_instruction2),
                    style = "padding-top: 10px;"
                  )
               ),
               mainPanel(
                 htmlOutput("vis2_welcometext"),
                 leafletOutput("locations", height = 600),
                 br(),
                 # plotOutput("delay_bar"),
                 # DT::DTOutput("delay_info")
               )
             )),
    
    tabPanel(div(id = "other-title", "Linear Regression"),
            headerPanel("Welcome to Linear Regression Coefficients!"),
            tags$img(src = "airplane.jpg", width = "100%", height = "300px", style = "padding-bottom: 20px;"),
             sidebarLayout(
               sidebarPanel2(
                tags$div(
                  HTML(vis3_instruction),
                  style = "padding-bottom: 20px; font-size: 18px;"
                ),
                 # selectInput(
                 #   "model",
                 #   label = "Select model",
                 #   choices = c("Linear Model", "Decision Tree", ""),
                 #   selected = ""
                 # ),
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
                #  out = HTML(paste('<div><h3> How to use visualisation </h3>', vis3_instruction,"</div>")),
                 out = explanation_of_vars
               ),
               mainPanel(htmlOutput("vis3_welcometext"),
                         uiOutput("vis3_plot"))
             )),
    tabPanel(div(id = "other-title", "Decision Tree"),
            headerPanel("Welcome to Decision Tree Plots!"),
            tags$img(src = "airplane.jpg", width = "100%", height = "300px", style = "padding-bottom: 20px;"),
             sidebarLayout(
               sidebarPanel2(
                tags$div(
                  HTML(vis4_instruction),
                  style = "padding-bottom: 20px; font-size: 18px;"
                ),
                 # selectInput(
                 #   "model",
                 #   label = "Select model",
                 #   choices = c("Linear Model", "Decision Tree", ""),
                 #   selected = ""
                 # ),
                 selectInput(
                   "flight4",
                   label = "Select flight type",
                   choices = c("Arriving", "Departing", ""),
                   selected = ""
                 ),
                 selectInput(
                   "year4",
                   label = "Select year",
                   choices = c("1989", "1990", "2000", "2001", "2006", "2007", ""),
                   selected = ""
                 ),
                 # Action button
                 actionButton(
                   "vis4_plot_button",
                   "Plot!",
                   icon = icon("fas fa-bar-chart", lib = "font-awesome", style = "color:black;")
                 ),
                #  out = HTML(paste('<div><h3> How to use visualisation </h3>', vis3_instruction,"</div>")),
                 out = explanation_of_vars
               ),
               mainPanel(htmlOutput("vis4_welcometext"), withSpinner(
                         uiOutput("vis4_image"), color = "#615fa0"))
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
      paste0(tags$p(tags$b("Data of flight delays in Year ", input$year, style = "text-decoration: underline;")))
    } 
    else {
      paste0(tags$p(tags$b("Please select a year using the dropdown on the left panel", style = "color: red;")))
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
      p <- ggplot(filtered_data_year(), aes(x = Month, y = Arr_Delay_Count)) +
        geom_bar(stat = "identity",
                 fill = "#bbb7cf",
                 color = "black") +
        labs(title = "Monthly Aggregated Delay Data",
             x = "Month",
             y = "Delay Count") +
        theme(
          axis.title = element_text(size = 15),
          plot.title = element_text(size = 17),
          axis.text = element_text(size = 14)
        )
      prev_year <- as.numeric(input$year) - 1
      filtered_data_prev_year <- subset(data, Year == as.character(prev_year))
      p <- p + geom_point(data = filtered_data_prev_year, color = "red", alpha = 0.5)
      # hover options: 
      # ggplotly(p, tooltip = c("Arr_Delay_Count")) %>% layout(hovermode = "y")
      p
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
                   fill = "#615fa0",
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
            fill = "#615fa0",
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
      tags$p(tags$b(HTML(
        "<div> You have selected",
        input$origin,
        "-->",
        input$destination,
        "in Year",
        input$year2,
        "<br></br>",
        "However, the chosen inputs has 0 flights recorded. </div>",
        style = "text-decoration: underline;"
      )))
    } else {
      paste(tags$p(tags$b(
        "You have selected",
        input$origin,
        "-->",
        input$destination,
        "in Year",
        input$year2,
        style = "text-decoration: underline;"
      )))
    }
  })
  
  output$vis2_welcometext <- renderText({
    if (input$origin == "" ||
        input$destination == "" || input$year2 == "") {
      paste0(tags$p(tags$b("Please select all inputs from the left panel", style = "color: red;")))
    } else if (input$submit_button == 0) {
      paste0(tags$p(tags$b("Please press the enter button", style = "color: red;")))
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
      `cascade destinations` = icons2
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
        label = ~ ORIGIN,
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
        label = ~ DEST,
        popup = ~ DEST,
        icon = icons2
      ) 
      # %>%
      # addPopups(
      #   data = first_row_list,
      #   lat = ~ destLat+2,
      #   lng = ~ destLng,
      #   popup =  ~ DEST
      # ) %>%
      # addPopups(
      #   data = first_row_list,
      #   lat = ~ originLat,
      #   lng = ~ originLng,
      #   popup =  ~ ORIGIN
      # ) %>%
      # addPopups(
      #   data = greenSubset,
      #   lat = ~ destLat,
      #   lng = ~ destLng,
      #   popup =  ~ DEST
      # )
    
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
                           title = "Marker Legend") %>%
      addLegend(
        position = 'topright',
        colors = c("red", "blue"),
        labels = c("Delayed Arrival", "Delayed Departure (Cascaded)"),
        opacity = 0.5,
        title = 'Line Colour Legend'
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
  
  ##Vis3
  url5 <- "http://backend_ml_models:5000/coefficients?mode="
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

      if (input_flight == 'dep') {
        coefficients_map <- c("prcp_origin" = "Origin Precipitation", 
        "tmean_origin" = "Origin Mean Temperature")
      }

      output$plot1 <- renderPlot({
        coefficients$Variables <-
          factor(coefficients$Variables,
                 levels = rev(coefficients$Variables[order(coefficients$Coefficients)]))
        # coefficients_processed <- coefficients %>% 
        #   mutate(colour = ifelse(Coefficients > 0, "#619CFF", "#F8766D")) 
        coefficients_processed <- coefficients %>% 
          mutate(colour = ifelse(Coefficients > 0, "#619CFF", "#F8766D"))

        
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
          labs(x = "Coefficients", y = "Variables") +
          scale_fill_manual(
            name = "Legend",
            values = c("#bbb7cf", "#615fa0"),
            labels = c("positive correlation", "negative correlation")
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
          labs(x = "Coefficients", y = "Variables") +
          scale_fill_manual(
            name = "Legend",
            values = c("#bbb7cf", "#615fa0"),
            labels = c("positive correlation", "negative correlation")
          ) +
          ggtitle("Plot with unstandardised coefficients (F)")
      })
      
    
  })
  
  observeEvent(c(input$flight, input$year3), {
    if (input$flight != "" & input$year3 != "") {
      shinyjs::enable("plot_button")
    } else {
      shinyjs::disable("plot_button")
    }
  })
  
  reactive_text3 <- eventReactive(input$plot_button, {
      paste0(
        tags$p(tags$b("Barplot of correlation of variables in relation to ",
        input$flight,
        " flights in Year ",
        input$year3, style = "text-decoration: underline;")))
  })
  
  output$vis3_welcometext <- renderText({
    if (input$flight == "" || input$year3 == "") {
      paste0(tags$p(tags$b("Please select all inputs from the left panel", style = "color: red;")))
    } else if (input$plot_button == 0) {
      paste0(tags$p(tags$b("Please press the plot button", style = "color: red;")))
    } else {
      reactive_text3()
    }
  })
  
  
  ##Vis4
  output$vis4_image <- renderUI({
    tags$div(
      if (input$vis4_plot_button != 0) {
        plotOutput("image", height = 650)
      }
    )
  })
  
  observeEvent(c(input$flight4, input$year4), {
    if (input$flight4 != "" & input$year4 != "") {
      shinyjs::enable("plot_button")
    } else {
      shinyjs::disable("plot_button")
    }
  })
  
  reactive_text4 <- eventReactive(input$vis4_plot_button, {
    paste0(
        tags$p(tags$b("Decision tree of correlation of variables in relation to ",
        input$flight4,
        " flights in Year ",
        input$year4, style = "text-decoration: underline;")))
  })
  
  output$vis4_welcometext <- renderText({
    if (input$flight4 == "" || input$year4 == "") {
      paste0(tags$p(tags$b("Please select all inputs from the left panel", style = "color: red;")))
    } else if (input$vis4_plot_button == 0) {
      paste0(tags$p(tags$b("Please press the plot button", style = "color: red;")))
    } else {
      reactive_text4()
    }
  })
  
  observeEvent(input$vis4_plot_button, {
    input_flight = ifelse(input$flight == "Arriving", "arr", "dep")
      url7 <- "http://backend_ml_models:5000/plots?mode="
      url6 <- "_"
      url_1 <-
        paste0(url7,
               'dt',
               url6,
               input_flight,
               url6,
               input$year4)
      output$image <- renderPlot({
        # Make the GET request and retrieve the content
        flask_url <- "http://backend_ml_models:5000"
        response <- GET(url_1)
        content <- content(response, "raw")
        
        # Write the content to a temporary PNG file
        png_file <- tempfile(fileext = ".png")
        writeBin(content, png_file)
        
        # Read the PNG file as a rasterGrob and plot it
        png_data <- readPNG(png_file)
        png_raster <- as.raster(png_data)
        png_grob <- rasterGrob(png_raster)
        
        # Display the PNG image
        grid.newpage()
        grid.draw(png_grob)
      })
  })
  
} # server

# Create Shiny object
shinyApp(ui = ui, server = server)
