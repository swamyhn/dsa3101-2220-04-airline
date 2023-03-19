# Load R packages
library(shiny)
library(shinythemes)
library(ggplot2)
library(tidyverse)
library(plotly)
library(dplyr)

# Define UI
ui <- fluidPage(theme = shinytheme("cerulean"),
                tags$head(
                  tags$style(HTML(
                    "#selected_year {
                    font-size: 18px;
                    padding-bottom: 20px;
                  }
                  "))
                ),
                titlePanel("Airline Delay Webapp"),

                sidebarLayout(
                  sidebarPanel(
                    selectInput("year", "Select year",
                                choices = NULL,
                                selected = ""),
                    selectInput("month", "Select month",
                                choices = NULL,
                                selected = "")
                  ),
                  mainPanel(
                    textOutput("selected_year"),
                    fluidRow(
                      column(width = 12, plotOutput("selected_plot")),
                      column(width = 6, plotOutput("selected_plot_arr")),
                      column(width = 6, plotOutput("selected_plot_dep"))
                    )
                  )
                )
) # fluidPage


# Define server function
server <- function(input, output) {
  month_order <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
  data <- read.csv("./unbinned_delay_count.csv")
  data$Month <- factor(data$Month, levels = month_order)
  binned_data <- read.csv("./binned_delay_count.csv")
  observe({
    updateSelectInput(inputId="year", choices=c("",unique(data$Year)), selected="")
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
    updateSelectInput(inputId="month", choices=c("",month_order[unique(filtered_data_year()$Month)]))
  })
  
  output$selected_plot <- renderPlot({
    if (input$year == "") {
      return(NULL)
    } else {
      ggplot(filtered_data_year(), aes(x = Month, y = Arr_Delay_Count)) +
        geom_bar(stat="identity", fill = "skyblue", color = "black") +
        labs(title = "Monthly Aggregated Delay Data",
             x = "Month",
             y = "Delay Count")
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
  
  monthPlot_bins <- c("60-74","75-89","90-104","105-119","120-134","135-149","150-164","165-179","Above 180")
  
  # Create the ordered factor
  monthPlot_bins <- factor(monthPlot_bins, levels = monthPlot_bins)
  observeEvent(input$month, {
    output$selected_plot_arr <- renderPlot({
      if (input$month == "") {
        return(NULL)
      } else {
        ggplot(filtered_data_binned_arr(), aes(x = monthPlot_bins, y = value)) +
          geom_bar(stat="identity", fill = "green", color = "black") +
          labs(title = paste0("Arrival Flights Delay Data (", input$month,")"),
               x = "Delay Time (minutes)",
               y = "Delay Count")
      }
    })
    
    output$selected_plot_dep <- renderPlot({
      if (input$month == "") {
        return(NULL)
      } else {
        ggplot(filtered_data_binned_dep(), aes(x = monthPlot_bins, y = value)) +
          geom_bar(stat="identity", fill = "purple", color = "black") +
          labs(title = paste0("Departure Flights Delay Data (", input$month,")"),
               x = "Delay Time (minutes)",
               y = "Delay Count")
      }
    })
  })
  
  
} # server


# Create Shiny object
shinyApp(ui = ui, server = server)