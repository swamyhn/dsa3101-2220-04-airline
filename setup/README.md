## Steps to pre-process raw data

1. Run data_cleaning.py to clean data
    - Input: csv files of raw monthly data
    - Output: csv files of cleaned monthly data

2. Run create_cascade_df.py to create data for the cascading plots
    - Input: csv files of cleaned monthly data
    - Output: pairwise_flights.csv

3. Follow instructions in the README in the weather folder to join cleaned data with external weather data
    - Input: Refer to the README in the weather folder
    - Output: csv files of cleaned monthly data joined with weather data

4. Run create_unsampled_yearly_data.py to create yearly data that will be read into MySQL database
    - Input: csv files of cleaned monthly data joined with weather data
    - Output: csv files of yearly data