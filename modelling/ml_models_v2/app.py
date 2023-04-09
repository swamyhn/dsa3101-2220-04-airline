import pandas as pd
from flask import Flask, request, jsonify, send_file
import joblib
import os

app = Flask(__name__)

@app.route("/", methods=['GET'])
def front_page():
    return "Our model outputs"

@app.route("/coefficients", methods=['GET'])
def get_coefficients():

    try:
        mode = request.args.get('mode')
        ml_model = mode[:2]
        if ml_model != 'lm':
            print('Input for mlmodel condition:', ml_model)
            return('Invalid input for mlmodel condition: must be lm for coefficients')

        pkl_file = f'{mode}.pkl'

        current_dir = os.getcwd()
        pkl_file = os.path.join(current_dir, pkl_file)
        myModel = joblib.load(pkl_file)

        coef_var_dict = {'distance': 'Distance',
                         'prcp_origin': 'Origin Precipitation',
                         'prcp_dest': 'Destination Precipitation',
                         'snow_origin': 'Origin Snow',
                         'snow_dest': 'Destination Snow',
                         'snwd_origin': 'Origin Snow Depth',
                         'snwd_dest': 'Destination Snow Depth',
                         'tmean_origin': 'Origin Mean Temperature',
                         'tmean_dest': 'Destination Mean Temperature',
                         'season_autumn': 'Autumn',
                         'season_spring': 'Spring',
                         'season_summer': 'Summer',
                         'season_winter': 'Winter',
                         'day_of_week_1': 'Monday',
                         'day_of_week_2': 'Tuesday',
                         'day_of_week_3': 'Wednesday',
                         'day_of_week_4': 'Thursday',
                         'day_of_week_5': 'Friday',
                         'day_of_week_6': 'Saturday',
                         'day_of_week_7': 'Sunday',
                         'crs_arr_bin_00-06': 'Arrival Time: 12am-6am',
                         'crs_arr_bin_06-12': 'Arrival Time: 6am-12pm',
                         'crs_arr_bin_12-18': 'Arrival Time: 12pm-6pm',
                         'crs_arr_bin_18-00': 'Arrival Time: 6pm-12am',
                         'crs_dep_bin_00-06': 'Departure Time: 12am-6am',
                         'crs_dep_bin_06-12': 'Departure Time: 6am-12pm',
                         'crs_dep_bin_12-18': 'Departure Time: 12pm-6pm',
                         'crs_dep_bin_18-00': 'Departure Time: 6pm-12am'}

        if ml_model == 'lm':
            variables = []
            for feature in myModel.feature_names_in_:
                variables.append(coef_var_dict[feature])

            coef_df = pd.DataFrame({'Variables': variables, 
                                    'Coefficients': myModel.coef_})
                 
        return jsonify(coef_df.to_dict(orient='records'))
    
    except Exception as e:
        print(e)
        print("Cannot get_coefficients")

@app.route("/plots")
def return_plot():
    try:
        mode = request.args.get('mode')
        ml_model = mode[:2]
        if ml_model != 'dt':
            print('Input for mlmodel condition:', ml_model)
            return('Invalid input for mlmodel condition: must be dt for plots')

        png_file = f'{mode}.png'

        current_dir = os.getcwd()
        png_file = os.path.join(current_dir, png_file)

        return send_file(png_file)
    
    except Exception as e:
        print(e)
        print("Cannot return_plot")