import pandas as pd
import glob

#adjustable variables
joined_weather_path = 'path/to/joined/weather/data/'
sampled_output_path = 'path/to/sampled/output/'
sample_percentage = 0.1

all_years = set()
for file in glob.glob(f'{joined_weather_path}airOT*.csv'):
    all_years.add(int(file[-10:-6]))

for year in all_years:
    year_dfs_list = []
    for file in glob.glob(f'{joined_weather_path}airOT{year}*.csv'):
        month_df = pd.read_csv(file)
        month_df = month_df[pd.isnull(month_df['DEP_DELAY_GROUP']) == False]

        #sample a certain percentage from each bin of delay
        month_df_grouped = month_df.groupby('DEP_DELAY_GROUP')
        sampled_month_df = month_df_grouped.apply(lambda x: x.sample(frac = sample_percentage))

        year_dfs_list.append(sampled_month_df)

    year_df = pd.concat(year_dfs_list, ignore_index = True)

    year_df.to_csv(f'sampled_output_path{year}.csv', index = False)
    print(str(year) + ' DONE')