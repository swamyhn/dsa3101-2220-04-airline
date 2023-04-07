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

        pkl_file = f'{mode}.pkl'

        current_dir = os.getcwd()
        pkl_file = os.path.join(current_dir, pkl_file)
        myModel = joblib.load(pkl_file)

        if ml_model == 'lm':
            coef_df = pd.DataFrame({'Variables': myModel.feature_names_in_, 
                                    'Coefficients': myModel.coef_})
        
        # elif ml_model == 'dt':
        #     coef_df = pd.DataFrame({'Variables': myModel.feature_names_in_, 
        #                     'Coefficients': myModel.feature_importances_})       
            
        return jsonify(coef_df.to_dict(orient='records'))
    
    except Exception as e:
        print(e)
        print("Cannot get_coefficients")

@app.route("/plots")
def return_plot():
    try:
        current_dir = os.getcwd()
        pkl_file = os.path.join(current_dir, pkl_file)
        diagram = joblib.load(pkl_file)

        return send_file(diagram)
    
    except Exception as e:
        print(e)
        print("Cannot return_plot")