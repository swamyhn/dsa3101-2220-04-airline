import pandas as pd
import glob

#adjustable variables
joined_weather_path = 'path/to/joined/weather/data/'
output_path = 'path/to/output/'

all_years = set()
for file in glob.glob(f'{joined_weather_path}airOT*.csv'):
    all_years.add(int(file[-10:-6]))

for year in all_years:
    year_dfs_list = []
    for file in glob.glob(f'{joined_weather_path}airOT{year}*.csv'):
        year_dfs_list.append(pd.read_csv(file))
    year_df = pd.concat(year_dfs_list, ignore_index = True)

    year_df.to_csv(f'{output_path}{year}.csv', index = False)
    print(str(year) + ' DONE')
