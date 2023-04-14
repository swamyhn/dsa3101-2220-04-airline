# dsa3101-2220-04-airline

## **Project Description**
Our project is about understanding factors that lead to airline delays and to analyse their impact on the delays. We have modelled delays and created a web application for interactive visualisation for the user. Our raw data source is from https://packages.revolutionanalytics.com/datasets/. 

## **Structure of the Repository**
### **temp-app**
This folder contains the dockerised Shiny app developed by the frontend. Please refer to the README in the folder for the steps to get the web application running.

### **setup**
This folder contains instructions and scripts to pre-process the raw data. Please refer to the README in the folder for more details.

### **eda**
This folder contains a script to generate 2 csv files, unbinned_delay_count.csv and binned_delay_count.csv, which are used to create the plots in the 'Summary Statistics' section of the web application.

### **setup_mysqldb**
This folder contains instructions and scripts to read the data that has been pre-processed into a MySQL database. It also contains steps for creating the database image and uploading it to Docker Hub. Please refer to the README in the folder for more details.

### **modelling**
This folder contains the backend's dockerised models. There is a cascade model and 2 versions of machine learning models. The machine learning methods used are linear regression and decision trees. The README files in each of the subfolders contain steps to get each model running in the backend on Flask. The frontend retrives the model outputs from Flask. For the machine learning models, the frontend Shiny app is connected to ml_models_v2. 