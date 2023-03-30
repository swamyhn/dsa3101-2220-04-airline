import pandas as pd
from flask import Flask, request, jsonify
import main

app = Flask(__name__)

@app.route("/", methods=['GET'])
def cover():
    return "This app is working"

# input (mode):
# "<direction>_<year>", where <direction>: arr, dep
#                       and   <year>: 1989, 1990, 2000, 2001, 2006, 2007
# eg. "arr_1989"
@app.route("/coefficients", methods=['GET'])
def get_coefficients():

    try:
        mode = request.args.get('mode')
        myModel = main.load_and_train(mode)
        coef_df = pd.DataFrame({'Variables': myModel.feature_names_in_, 
                                'Coefficients': myModel.coef_})
        print(coef_df)
    
        return jsonify(coef_df.to_dict(orient = 'records'))
    
    except Exception as e:
        print(e)
        print("Cannot get_coefficients")