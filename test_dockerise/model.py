import pandas as pd
import numpy as np
from sklearn.linear_model import Ridge, RidgeCV
import joblib

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
            
def create_arr_model(result, year):

    # idk how the output will look
    # also maybe no need to select columns here alr
    try:
        arr_use_cols = ['month', 'day_of_week', 'crs_arr_time', 'distance', 'prcp_dest', 'snow_dest', 'snwd_dest', 'tmax_dest', 'tmin_dest', 'arr_delay']
        arr_df = result[arr_use_cols]

    except Exception as e:
        print(e)
        print("result from db is not a dataframe")
            
    #preprocessing
    # arr_use_cols = ['MONTH', 'DAY_OF_WEEK', 'CRS_ARR_TIME', 'DISTANCE', 'PRCP_DEST', 'SNOW_DEST', 'SNWD_DEST', 'TMAX_DEST', 'TMIN_DEST', 'ARR_DELAY']
    # arr_df = year_df[arr_use_cols]
    arr_df['crs_arr_bin'] = arr_df['crs_arr_time'].apply(bin_time)
    arr_df['season'] = arr_df['month'].apply(get_season)
    arr_df = arr_df.astype({'day_of_week': 'category'})

    arr_regression_cols = ['season', 'day_of_week', 'crs_arr_bin', 'distance', 'prcp_dest', 'snow_dest', 'snwd_dest', 'tmax_dest', 'tmin_dest', 'arr_delay']
    arr_regression_df = arr_df[arr_regression_cols]
    arr_regression_df = arr_regression_df.dropna()
    print('issue is not line 48')
    try:
        print('testing here=====================')
        arr_regression_clean_df = arr_regression_df.drop('arr_delay', axis=1)
        arr_X = pd.get_dummies(arr_regression_clean_df, columns=['season', 'day_of_week', 'crs_arr_bin'])
        print('arr_X is created')
        print(arr_X.head())
    except Exception as e:
        print('issue is in the try chunk')
    arr_y = arr_regression_df['arr_delay']
    print('issue is not line 49')

    # Ridge ARR

    print('it got here')
    print(arr_X.head())
    print(arr_y)

    alphas = 10**np.linspace(10,-2,100)*0.5

    ridge_arr_cv = RidgeCV(alphas=alphas)
    ridge_arr_cv.fit(arr_X, arr_y)

    ridge_arr = Ridge(alpha = ridge_arr_cv.alpha_)
    ridge_arr.fit(arr_X, arr_y)

    print('>>>>>>>>>>>>>>>>>>>>ridge_arr created')

    file_to_save = f"ridge_arr_{year}.pkl"

    # save object
    joblib.dump(ridge_arr, file_to_save, compress = 3)

    print('dump successful')

    return ridge_arr


def create_dep_model(result, year):

    # idk how the output will look
    try:
        dep_use_cols = ['month', 'day_of_week', 'crs_dep_time', 'distance', 'prcp_origin', 'snow_origin', 'snwd_origin', 'tmax_origin', 'tmin_origin', 'dep_delay']
        dep_df = result[dep_use_cols]
        
    except Exception as e:
        print(e)
        print("result from db is not a dataframe")

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
            
    #preprocessing
    # dep_use_cols = ['MONTH', 'DAY_OF_WEEK', 'CRS_DEP_TIME', 'DISTANCE', 'PRCP_DEST', 'SNOW_DEST', 'SNWD_DEST', 'TMAX_DEST', 'TMIN_DEST', 'DEP_DELAY']
    # dep_df = year_df[dep_use_cols]
    dep_df['crs_dep_bin'] = dep_df['crs_dep_time'].apply(bin_time)        
    dep_df['season'] = dep_df['month'].apply(get_season)
    dep_df = dep_df.astype({'day_of_week': 'category'})

    dep_regression_cols = ['season', 'day_of_week', 'crs_dep_bin', 'distance', 'prcp_origin', 'snow_origin', 'snwd_origin', 'tmax_origin', 'tmin_origin', 'dep_delay']
    dep_regression_df = dep_df[dep_regression_cols]
    dep_regression_df = dep_regression_df.dropna()
    dep_X = pd.get_dummies(dep_regression_df.drop('dep_delay', axis=1))
    dep_y = dep_regression_df['dep_delay']

    # Ridge DEP

    alphas = 10**np.linspace(10,-2,100)*0.5

    ridge_dep_cv = RidgeCV(alphas=alphas)
    ridge_dep_cv.fit(dep_X, dep_y)

    ridge_dep = Ridge(alpha = ridge_dep_cv.alpha_)
    ridge_dep.fit(dep_X, dep_y)

    file_to_save = f"ridge_dep_{year}.pkl"

    # save object
    joblib.dump(ridge_dep, file_to_save, compress = 3)

    return ridge_dep