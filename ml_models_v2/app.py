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

        if ml_model == 'lm':
            coef_df = pd.DataFrame({'Variables': myModel.feature_names_in_, 
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