import pandas as pd
import database
import model
import os

def load_and_train(mode):

    yr = mode[7:11]
    dir = mode[3:6]
    ml_model = mode[:2]

    try:
        db = database.connect_db()

        print('---Successfully connected to db---')

        cursor = db.cursor()
        
        if dir == 'arr':
            cursor.execute(f"""SELECT month, day_of_week, crs_arr_time, distance, prcp_dest, 
            snow_dest, snwd_dest, tmax_dest, tmin_dest, arr_delay FROM year_{yr}""")
            result = cursor.fetchall()
            df = pd.DataFrame(result, columns=[desc[0] for desc in cursor.description])
            if ml_model == 'lm':
                std = mode[-1]
                if std not in ['T', 'F']:
                    print('Input for standardisation condition:', std)
                    raise Exception('Invalid input for standardisation condition, must be T or F')
                myModel = model.create_lm_arr_model(df, yr, std)
                print('---Successfully created lm model---')
            elif ml_model == 'dt':
                myModel = model.create_dt_arr_model(df, yr)
                print('---Successfully created dt model---')

        
        elif dir == 'dep':
            cursor.execute(f"""SELECT month, day_of_week, crs_dep_time, distance, prcp_origin, 
            snow_origin, snwd_origin, tmax_origin, tmin_origin, dep_delay FROM year_{yr}""")
            result = cursor.fetchall()
            df = pd.DataFrame(result, columns=[desc[0] for desc in cursor.description])
            if ml_model == 'lm':
                std = mode[-1]
                myModel = model.create_lm_dep_model(df, yr, std) 
                print('---Successfully created lm model---')
            elif ml_model == 'dt':
                myModel = model.create_dt_dep_model(df, yr) 
                print('---Successfully created dt model---')
        
        return myModel
        
    except Exception as e:
        print(e)
        raise Exception('Cannot load and train')
    
if __name__ == '__main__':
    dir = ['arr', 'dep']
    yr = ['1989', '1990', '2000', '2001', '2006', '2007']
    std = ['T', 'F']
    for i in dir:
        for j in yr:
            for k in std: 
                lm_file = f'lm_{i}_{j}_{k}'
                if os.path.isfile(f'{lm_file}.pkl'):
                    continue
                load_and_train(lm_file)
                print(f"Successfully saved {lm_file}.pkl")

    for m in dir:
        for n in yr:
            dt_file = f'dt_{m}_{n}'
            if os.path.isfile(f'{dt_file}.pkl'):
                continue
            elif os.path.isfile(f'{dt_file}.png'):
                continue
            load_and_train(dt_file)
            print(f"Successfully saved {dt_file}.pkl and {dt_file}.png")

    print('Huge Success!')
