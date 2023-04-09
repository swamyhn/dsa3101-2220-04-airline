import pandas as pd
import numpy as np
import os
import glob
import chardet

# Edit path to AirOnTimeCSV folder
curr_path = 'path/to/AirOnTimeCSV/'

# Edit path to folder you want to save in (eg. AirOnTimeCSV_cleaned)
new_path = 'path/to/AirOnTimeCSV_cleaned/'

# Files that require manual cleaning
excluded_csv = [curr_path + 'airOT200304.csv',
                curr_path + 'airOT200403.csv',
                curr_path + 'airOT200404.csv',
                curr_path + 'airOT200405.csv',
                curr_path + 'airOT200406.csv',
                curr_path + 'airOT200502.csv',
                curr_path + 'airOT200503.csv',
                curr_path + 'airOT200510.csv']

# List of columns to convert to integer
ls = ['DEP_DELAY', 'DEP_DELAY_NEW', 'DEP_DELAY_GROUP', 'TAXI_OUT', 'TAXI_IN', 'ARR_DELAY', 'ARR_DELAY_NEW', 
      'ARR_DELAY_GROUP', 'CRS_ELAPSED_TIME', 'ACTUAL_ELAPSED_TIME', 'AIR_TIME', 'FLIGHTS', 'DISTANCE', 
      'DISTANCE_GROUP', 'CARRIER_DELAY', 'WEATHER_DELAY', 'NAS_DELAY', 'SECURITY_DELAY', 'LATE_AIRCRAFT_DELAY']

# Get encoding of csv file
def get_encoding(file):
    with open(file, 'rb') as f:
        content = f.read(1000000)
    result = chardet.detect(content)
    return result['encoding']

# Cleaning to be done on every csv file
def general_cleaning(df):
    # Change float columns to integer
    for col in ls:
        df[col] = df[col].astype("Int64")
    # Delete extra column in csv file if it exists
    if len(df.columns) > 44:
        clean_df = df.drop(df.columns[len(df.columns)-1], axis=1)
    return clean_df



# Clean airOT200304.csv
# - drop row 64383 in csv (index 64382)
f = 'airOT200304.csv'
enc = get_encoding(curr_path + f)
if enc == 'ascii':
    data = pd.read_csv(curr_path + f, skiprows=[64382])
elif enc == 'MacRoman':
    data = pd.read_csv(curr_path + f, skiprows=[64382], encoding="mac_roman")
print("......Manual cleaning done for " + f)
clean_data = general_cleaning(data)
clean_data.to_csv(new_path + f, index=False)
print("      " + f + " added successfully")
print("---------------------------------------------------")

# Clean airOT200510.csv
# - drop row 57583 in csv (index 57582) and 67627 in csv (index 67626)
f = 'airOT200510.csv'
enc = get_encoding(curr_path + f)
if enc == 'ascii':
    data = pd.read_csv(curr_path + f, skiprows=[57582, 67626])
elif enc == 'MacRoman':
    data = pd.read_csv(curr_path + f, skiprows=[57582, 67626], encoding="mac_roman")
print("......Manual cleaning done for " + f)
clean_data = general_cleaning(data)
clean_data.to_csv(new_path + f, index=False)
print("      " + f + " added successfully")
print("---------------------------------------------------")

# Clean airOT200503.csv
# - drop row 60297 in csv (index 60296)
# - specify data type of column 31 as str
f = 'airOT200503.csv'
enc = get_encoding(curr_path + f)
if enc == 'ascii':
    data = pd.read_csv(curr_path + f, skiprows=[60296], dtype={'CANCELLATION_CODE': str})
elif enc == 'MacRoman':
    data = pd.read_csv(curr_path + f, skiprows=[60296], encoding="mac_roman", dtype={'CANCELLATION_CODE': str})
print("......Manual cleaning done for " + f)
clean_data = general_cleaning(data)
clean_data.to_csv(new_path + f, index=False)
print("      " + f + " added successfully")
print("---------------------------------------------------")

# Clean airOT200403.csv/airOT200404.csv/airOT200405.csv/airOT200406.csv/airOT200502.csv
# - specify data type of column 31 as str
file_list = ['airOT200403.csv', 'airOT200404.csv', 'airOT200405.csv', 'airOT200406.csv', 'airOT200502.csv']
for f in file_list:
    enc = get_encoding(curr_path + f)
    if enc == 'ascii':
        data = pd.read_csv(curr_path + f, dtype={'CANCELLATION_CODE': str})
    elif enc == 'MacRoman':
        data = pd.read_csv(curr_path + f, encoding="mac_roman", dtype={'CANCELLATION_CODE': str})
    print("......Manual cleaning done for " + f)
    clean_data = general_cleaning(data)
    clean_data.to_csv(new_path + f, index=False)
    print("      " + f + " added successfully")
    print("---------------------------------------------------")



# List of all files in AirOnTimeCSV
csv_files = [os.path.normpath(i) for i in glob.glob(curr_path + "/*.csv")]

# Clean all files excluding those those that have to be manually cleaned
for f in csv_files:
    f = os.path.normpath(f)
    if f in [os.path.normpath(i) for i in excluded_csv]:
        continue
    enc = get_encoding(f)
    if enc == 'ascii':
        data = pd.read_csv(f)
    elif enc == 'MacRoman':
        data = pd.read_csv(f, encoding="mac_roman")
    clean_data = general_cleaning(data)
    print("......General cleaning done for " + f[-15:])
    clean_data.to_csv(new_path + f[-15:], index=False)
    print("      " + f[-15:] + " added successfully")
    print("---------------------------------------------------")