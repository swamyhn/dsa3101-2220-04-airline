import pandas as pd
import glob

#adjustable variables
#joined_weather_path = 'path/to/joined/weather/data/'
joined_weather_path = "C:/Users/swamy/OneDrive - National University of Singapore/DSA3101/Project/joined_weather/"
#sampled_output_path = 'path/to/sampled/output/'
sampled_output_path = "C:/Users/swamy/OneDrive - National University of Singapore/DSA3101/Project/load_db/import_csv/"
sample_percentage = 0.2

modelling_cols = ['YEAR', 'MONTH', 'DAY_OF_MONTH', 'DAY_OF_WEEK',
       'CRS_DEP_TIME', 'DEP_DELAY', 'DEP_DELAY_GROUP', 
       'CRS_ARR_TIME', 'ARR_DELAY', 'ARR_DELAY_GROUP', 
       'DISTANCE', 'PRCP_ORIGIN', 'SNOW_ORIGIN', 'SNWD_ORIGIN', 
       'TMAX_ORIGIN', 'TMIN_ORIGIN', 'PRCP_DEST',
       'SNOW_DEST', 'SNWD_DEST', 'TMAX_DEST', 'TMIN_DEST']

# all_years = set()
# for file in glob.glob(f'{joined_weather_path}airOT*.csv'):
#     all_years.add(int(file[-10:-6]))

all_years = [1989, 1990, 2000, 2001, 2006, 2007]

for year in all_years:
    year_dfs_list = []
    for file in glob.glob(f'{joined_weather_path}airOT{year}*.csv'):
        month_df = pd.read_csv(file, usecols = modelling_cols)
        sampled_month_df = month_df.sample(frac = sample_percentage)
        year_dfs_list.append(sampled_month_df)

    year_df = pd.concat(year_dfs_list, ignore_index = True)

    year_df.to_csv(f'{sampled_output_path}{year}.csv', index = False)
    print(str(year) + ' DONE')