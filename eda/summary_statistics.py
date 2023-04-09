import pandas as pd
import glob
import numpy as np

#adjustable variables
cleaned_path = 'path/to/AirOnTimeCSV_cleaned'
tables_path = 'path/to/tables/'

month_mapping = {'01': 'Jan', '02': 'Feb', '03': 'Mar', '04': 'Apr', '05': 'May', '06': 'Jun', '07': 'Jul', '08': 'Aug', '09': 'Sep', '10': 'Oct', '11': 'Nov', '12': 'Dec'}

#1st table
year_col, month_col, dep_delay_count_col, arr_delay_count_col = [], [], [], []

for file in glob.glob(cleaned_path + '/*.csv'):
    year = file[-10:-6]
    year_col.append(year)
    month = file[-6:-4]
    month_col.append(month_mapping[month])

    month_df = pd.read_csv(file)
    dep_delay_count_col.append(np.count_nonzero(month_df['DEP_DELAY_GROUP'] >= 4))
    arr_delay_count_col.append(np.count_nonzero(month_df['ARR_DELAY_GROUP'] >= 4))

unbinned_delay_count_df = pd.DataFrame({'Year': year_col, 'Month': month_col, 'Dep Delay Count': dep_delay_count_col, 'Arr Delay Count': arr_delay_count_col})
unbinned_delay_count_df.to_csv(tables_path + 'unbinned_delay_count.csv', index = False)

#2nd table
bin_mapping = {}
for i in range(4, 13):
    bin_mapping[i] = str(i * 15) + '-' + str(i * 15 + 14)
    if i == 12:
        bin_mapping[i] = 'Above 180'

year_col, month_col =  [], []
for key in bin_mapping:
    exec(f'dep_bin_{key}_col = []')
    exec(f'arr_bin_{key}_col = []')

for file in glob.glob(cleaned_path + '/*.csv'):
    year = file[-10:-6]
    year_col.append(year)
    month = file[-6:-4]
    month_col.append(month_mapping[month])

    month_df = pd.read_csv(file)
    for key in bin_mapping:
        locals()[f'dep_bin_{key}_col'].append(np.count_nonzero(month_df['DEP_DELAY_GROUP'] == key))
        locals()[f'arr_bin_{key}_col'].append(np.count_nonzero(month_df['ARR_DELAY_GROUP'] == key))

data_dict = {}
data_dict['Year'] = year_col
data_dict['Month'] = month_col
for key, val in bin_mapping.items():
    data_dict['Arr '+ val] = locals()[f'arr_bin_{key}_col']
for key, val in bin_mapping.items():
    data_dict['Dep '+ val] = locals()[f'dep_bin_{key}_col']

binned_delay_count_df = pd.DataFrame(data_dict)
binned_delay_count_df.to_csv(tables_path + 'binned_delay_count.csv', index = False)