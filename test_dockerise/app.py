import pandas as pd
from flask import Flask, request, jsonify
import main
import joblib
import os

app = Flask(__name__)

@app.route("/", methods=['GET'])
def front_page():
    return "Our model outputs"

# input (mode):
# "<ml model>_<direction>_<year>", where <ml model>: lm, dt
#                                  and   <direction>: arr, dep
#                                  and   <year>: 1989, 1990, 2000, 2001, 2006, 2007
# eg. "lm_arr_1989"
@app.route("/coefficients", methods=['GET'])
def get_coefficients():

    try:
        mode = request.args.get('mode')

        pkl_file = f'{mode}.pkl'

        if os.path.isfile(pkl_file):
            myModel = joblib.load(pkl_file)
            print('---Successfully loaded pickle file---')
        else:
            myModel = main.load_and_train(mode)
            print('---Successfully loaded model---')

        coef_df = pd.DataFrame({'Variables': myModel.feature_names_in_, 
                                'Coefficients': myModel.coef_})
            
        return jsonify(coef_df.to_dict(orient='records'))
    
    except Exception as e:
        print(e)
        print("Cannot get_coefficients")