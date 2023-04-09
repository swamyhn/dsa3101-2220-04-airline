import numpy as np
import pandas as pd
import glob
import joblib

all_pairs = pd.DataFrame(columns = ["YEAR", "MONTH", "DAY_OF_MONTH", "DAY_OF_WEEK", "ORIGIN", "DEST", "delayed_dep", "delayed_arr", "total_flights"])
both_col = ["YEAR", "MONTH", "DAY_OF_MONTH", "DAY_OF_WEEK", "ORIGIN", "DEST", "DEP_DELAY", "ARR_DELAY"]
dep_col = ["YEAR", "MONTH", "DAY_OF_MONTH", "DAY_OF_WEEK", "ORIGIN", "DEP_DELAY", "DEST"]
airports = ['ATL', 'ORD', 'DFW', 'LAX', 'PHX', 'DEN', 'IAH', 'LAS', 'DTW', 'STL']
years = ["1989", "1990", "2000", "2001", "2006", "2007"]


for year in years:
    for file in glob.glob(f'airOT{year}*.csv'):

        df = pd.read_csv(file)
        #find total number of flights between the 2 airports
        deps = df[dep_col]
        deps = deps.dropna()
        deps = deps[deps.ORIGIN.isin(airports) & deps.DEST.isin(airports)] #only between top 10 airports
        deps['total_flights'] = deps.groupby(["YEAR", "MONTH", "DAY_OF_MONTH", "DAY_OF_WEEK","ORIGIN", "DEST"]).transform("count")
        deps = deps[["YEAR", "MONTH", "DAY_OF_MONTH", "DAY_OF_WEEK", "ORIGIN", "DEST", "total_flights"]].drop_duplicates()

        #take number of arrival and departure delays between the two airports
        both = df[both_col]
        both = both.dropna()
        both = both[both.ORIGIN.isin(airports) & both.DEST.isin(airports)] #only between top 10 airports
        both = both.groupby(["YEAR", "MONTH", "DAY_OF_MONTH", "DAY_OF_WEEK", "ORIGIN", "DEST"])
        delayed_deps = both['DEP_DELAY'].agg(lambda x: (x >= 60.0).sum()).reset_index()
        delayed_arrs = both['ARR_DELAY'].agg(lambda x: (x >= 60.0).sum()).reset_index()

        final = delayed_deps.merge(delayed_arrs)
        final = final.merge(deps)
        final = final.rename({"DEP_DELAY":"delayed_dep","ARR_DELAY":"delayed_arr"}, axis = 1)

        all_pairs = pd.concat([all_pairs, final])

all_pairs.to_csv("pairwise_flights.csv",index=False)