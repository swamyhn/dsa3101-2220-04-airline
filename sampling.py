import pandas as pd
import glob

#adjustable variables
cleaned_path = 'path/to/AirOnTimeCSV_cleaned'
sampled_years_path = 'path/to/sampled_years_path/'
sample_percentage = 0.1

curr_year = None
year_dfs_list = []

for file in glob.glob(cleaned_path + '/*.csv'):
    year = file[-10:-6]
    if year != curr_year:
        if curr_year != None:
            year_df = pd.concat(year_dfs_list, ignore_index = True)
            year_df.to_csv(sampled_years_path + curr_year + '.csv', index = False)
        curr_year = year
        year_dfs_list = []
        
    month_df = pd.read_csv(file)
    month_df = month_df[pd.isnull(month_df['DEP_DELAY_GROUP']) == False]
    
    #sample a certain percentage from each bin of delay
    month_df_grouped = month_df.groupby('DEP_DELAY_GROUP')
    sampled_month_df = month_df_grouped.apply(lambda x: x.sample(frac = sample_percentage))

    year_dfs_list.append(sampled_month_df)