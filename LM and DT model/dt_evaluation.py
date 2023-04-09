# Script for decision trees to find optimal max_leaf_nodes with GridSearchCV and calculate accuracy score 

import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
from sklearn.model_selection import GridSearchCV
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from imblearn.under_sampling import RandomUnderSampler

## adjustable variables
years = [1989, 1990, 2000, 2001, 2006, 2007]
### directory containing the csv files of yearly data loaded into database
all_years_path = "C:/Users/swamy/OneDrive - National University of Singapore/DSA3101/Project/load_db/import_csv/"
### range of 'max_leaf_nodes' to use with GridSearchCV, 2 <= MAX_LEAF_NODES_LOWER < MAX_LEAF_NODES_UPPER
MAX_LEAF_NODES_LOWER = 2 
MAX_LEAF_NODES_UPPER = 7

def bin_time(crs_time):
    bin_dict = {0: '00-06', 1: '06-12', 2: '12-18', 3: '18-00'}
    if crs_time == 2400:
        return '18-00'
    return bin_dict[crs_time // 600]

def get_season(month):
    season_dict = {(1,2,3): 'spring', (4,5,6): 'summer', (7,8,9): 'autumn', (10,11,12): 'winter'}
    for key, val in season_dict.items():
        if month in key:
            return val

direction_col, year_col, leaf_col, score_col = [], [], [], []

#Arrival
for year in years:
    direction_col.append('Arrival')
    year_col.append(year)

    data = pd.read_csv(f'{all_years_path}{year}.csv')
    data = data.rename(columns = str.lower)

    use_cols = ['month', 'day_of_week', 'crs_arr_time', 'distance', 'prcp_dest', 'snow_dest', 'snwd_dest', 'tmax_dest', 'tmin_dest', 'arr_delay']
    data = data[use_cols]

    data['has_arr_delay'] = data['arr_delay'].apply(lambda x: 1 if x >= 60 else 0)
    data['crs_arr_bin'] = data['crs_arr_time'].apply(bin_time)
    data['season'] = data['month'].apply(get_season)  

    cols = ['season', 'day_of_week', 'crs_arr_bin', 'distance', 'prcp_dest', 'snow_dest', 'snwd_dest', 'tmax_dest', 'tmin_dest', 'has_arr_delay']
    data = data[cols]
    data = data.dropna()
    data = pd.get_dummies(data, columns=['season', 'day_of_week', 'crs_arr_bin'])
    arr_X = data.drop('has_arr_delay', axis=1)
    arr_y = data['has_arr_delay']

    # create an instance of RandomUnderSampler
    rus = RandomUnderSampler(random_state=42)

    # fit and transform the data
    X_resampled, y_resampled = rus.fit_resample(arr_X, arr_y)

    #use GridSearchCV to find optimal max_leaf_nodes
    num_nodes = np.arange(MAX_LEAF_NODES_LOWER, MAX_LEAF_NODES_UPPER + 1)
    dt = DecisionTreeClassifier()
    dt_cv = GridSearchCV(dt, param_grid = {"max_leaf_nodes": num_nodes})
    dt_cv.fit(X_resampled, y_resampled)
    max_leaf_nodes = dt_cv.best_params_['max_leaf_nodes']

    leaf_col.append(max_leaf_nodes)

    #calculate accuracy score
    dt = DecisionTreeClassifier(max_leaf_nodes = max_leaf_nodes)
    X_train_dt, X_test_dt, y_train_dt, y_test_dt = train_test_split(X_resampled, y_resampled, test_size = 0.2)
    dt.fit(X_train_dt, y_train_dt)
    predicted_y = dt.predict(X_test_dt)
    
    score_col.append(accuracy_score(predicted_y, y_test_dt))

#Departure
for year in years:
    direction_col.append('Departure')
    year_col.append(year)

    data = pd.read_csv(f'{all_years_path}{year}.csv')
    data = data.rename(columns = str.lower)

    use_cols = ['month', 'day_of_week', 'crs_dep_time', 'distance', 'prcp_origin', 'snow_origin', 'snwd_origin', 'tmax_origin', 'tmin_origin', 'dep_delay']
    data = data[use_cols]

    data['has_dep_delay'] = data['dep_delay'].apply(lambda x: 1 if x >= 60 else 0)
    data['crs_dep_bin'] = data['crs_dep_time'].apply(bin_time)
    data['season'] = data['month'].apply(get_season)  

    cols = ['season', 'day_of_week', 'crs_dep_bin', 'distance', 'prcp_origin', 'snow_origin', 'snwd_origin', 'tmax_origin', 'tmin_origin', 'has_dep_delay']
    data = data[cols]
    data = data.dropna()
    data = pd.get_dummies(data, columns=['season', 'day_of_week', 'crs_dep_bin'])
    arr_X = data.drop('has_dep_delay', axis=1)
    arr_y = data['has_dep_delay']

    # create an instance of RandomUnderSampler
    rus = RandomUnderSampler(random_state=42)

    # fit and transform the data
    X_resampled, y_resampled = rus.fit_resample(arr_X, arr_y)

    #use GridSearchCV to find optimal max_leaf_nodes
    num_nodes = np.arange(MAX_LEAF_NODES_LOWER, MAX_LEAF_NODES_UPPER + 1)
    dt = DecisionTreeClassifier()
    dt_cv = GridSearchCV(dt, param_grid = {"max_leaf_nodes": num_nodes})
    dt_cv.fit(X_resampled, y_resampled)
    max_leaf_nodes = dt_cv.best_params_['max_leaf_nodes']

    leaf_col.append(max_leaf_nodes)

    #calculate accuracy score
    dt = DecisionTreeClassifier(max_leaf_nodes = max_leaf_nodes)
    X_train_dt, X_test_dt, y_train_dt, y_test_dt = train_test_split(X_resampled, y_resampled, test_size = 0.2)
    dt.fit(X_train_dt, y_train_dt)
    predicted_y = dt.predict(X_test_dt)
    
    score_col.append(accuracy_score(predicted_y, y_test_dt))

#Output 
eval_df = pd.DataFrame(data = {'Direction': direction_col, 'Year': year_col, 'max_leaf_nodes': leaf_col, 'Accuracy Score': score_col})
print(eval_df)
eval_df.to_csv('dt_evaluation.csv', index = False)