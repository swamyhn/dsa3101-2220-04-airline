import pandas as pd
import glob
import numpy as np
import os

#adjustable variables
unjoined_clean_data_path = 'path/to/AirOnTimeCSV_cleaned/'
joined_clean_data_path = 'path/to/joined/weather/'
weather_path = 'path/to/weather/data/'
raw_dly_files_path = weather_path + 'dly_files/'
csv_dly_files_path = weather_path + 'csv_dly_files/'

##map weather station code to state
station_state_map_df = pd.read_csv(weather_path + 'ghcnd-stations.csv', header = None)
station_state_map_df = station_state_map_df[[0, 4]]
station_state_map_df.columns = ['station_code', 'state']
station_state_map_df = station_state_map_df[pd.notnull(station_state_map_df['state'])]

#station_state_map_df.to_csv(weather_path + 'station_state_map.csv', index = False)

##convert dly files to csv
# fields as given by the spec
fields = [
    ["ID", 1, 11],
    ["YEAR", 12, 15],
    ["MONTH", 16, 17],
    ["ELEMENT", 18, 21]]

offset = 22

for value in range(1, 32):
    fields.append((f"VALUE{value}", offset,     offset + 4))
    fields.append((f"MFLAG{value}", offset + 5, offset + 5))
    fields.append((f"QFLAG{value}", offset + 6, offset + 6))
    fields.append((f"SFLAG{value}", offset + 7, offset + 7))
    offset += 8

# Modify fields to use Python numbering
fields = [[var, start - 1, end] for var, start, end in fields]
fieldnames = [var for var, start, end in fields]

for dly_filename in glob.glob(raw_dly_files_path + '*.dly', recursive=True): 
    import csv

    path, name = os.path.split(dly_filename)
    print(name)
    csv_filename = os.path.join(csv_dly_files_path, f"{os.path.splitext(name)[0]}.csv")

    with open(dly_filename, newline='') as f_dly, open(csv_filename, 'w', newline='') as f_csv:
        csv = csv.writer(f_csv)
        csv.writerow(fieldnames)    # Write a header using the var names

        for line in f_dly:
            row = [line[start:end].strip() for var, start, end in fields]
            csv.writerow(row)

##concatenating extracted weather data
element_list = ['TMIN', 'TMAX', 'PRCP', 'SNOW', 'SNWD']
years_list = np.arange(1987, 2013)

df_list = []
for filename in glob.glob(csv_dly_files_path + '*.csv'):
    station_df = pd.read_csv(filename)

    col_list = ['ID', 'YEAR', 'MONTH', 'ELEMENT']
    value_list = []
    for col in station_df.keys():
        if 'VALUE' in col:
            col_list.append(col)
            value_list.append(col)

    station_df = station_df[col_list]
    
    station_df = station_df[(station_df['ELEMENT'].isin(element_list) & (station_df['YEAR'].isin(years_list)))]

    # pivot and remove VALUE in column DAY at the same time + auto conversion of str to int, but have to change value to VALUE
    station_df = pd.wide_to_long(station_df, ['VALUE'], i = ['ID', 'YEAR', 'MONTH', 'ELEMENT'], j = 'DAY_OF_MONTH').reset_index()
    station_df = station_df[station_df['VALUE'] != -9999]

    df_list.append(station_df)

all_stations_df = pd.concat(df_list, axis = 0)
station_state_dict = dict(zip(station_state_map_df.station_code, station_state_map_df.state))
all_stations_df['state'] = all_stations_df['ID'].apply(lambda x: station_state_dict[x])

##calculate daily mean of weather data variables for each state by aggregating data from weather stations
final_weather_df = all_stations_df.groupby(['state', 'YEAR', 'MONTH', 'ELEMENT', 'DAY_OF_MONTH'])['VALUE'].mean().reset_index()
final_weather_df = pd.pivot(final_weather_df, index = ['state', 'YEAR', 'MONTH', 'DAY_OF_MONTH'], columns = 'ELEMENT', values = 'VALUE').reset_index()
final_weather_df['TMAX'] = final_weather_df['TMAX'] / 10
final_weather_df['TMIN'] = final_weather_df['TMIN'] / 10
final_weather_df['PRCP'] = final_weather_df['PRCP'] / 10

##join extracted weather data with cleaned raw data
for file in glob.glob(unjoined_clean_data_path + '*.csv'):
    raw_month_df = pd.read_csv(file)
    origin_output_df = raw_month_df.merge(final_weather_df, left_on=['ORIGIN_STATE_ABR', 'YEAR', 'MONTH', 'DAY_OF_MONTH'], right_on=['state', 'YEAR', 'MONTH', 'DAY_OF_MONTH'])
    final_output_df = origin_output_df.merge(final_weather_df, left_on=['DEST_STATE_ABR', 'YEAR', 'MONTH', 'DAY_OF_MONTH'], right_on=['state', 'YEAR', 'MONTH', 'DAY_OF_MONTH'], 
                                             suffixes=['_ORIGIN', '_DEST'])
    final_output_df = final_output_df.drop(columns = ['state_ORIGIN', 'state_DEST'])
    
    final_output_df.to_csv(joined_clean_data_path + file[-15:], index = False)