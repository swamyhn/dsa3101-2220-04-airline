import pandas as pd
import database
import model

def load_and_train(mode):

    try:
        if mode == "arr_1989":
            db = database.connect_db()
            cursor = db.cursor()
            cursor.execute("""SELECT month, day_of_week, crs_arr_time, distance, prcp_dest, 
            snow_dest, snwd_dest, tmax_dest, tmin_dest, arr_delay FROM year_1989""")
            result = cursor.fetchall()
            print('-----------------------Selected table successfully----------------------')
            df = pd.DataFrame(result, columns=[desc[0] for desc in cursor.description])
            print('start model generation')
            try:
                myModel = model.create_arr_model(df, 1989) 
                print('-----------------')
                print('model generation completed')
                print(myModel)
                print('-----------------')
            except Exception as e:
                print(e)
                raise
            # myModel = model.create_arr_model(df, 1989) 
            return myModel
        
        elif mode == "arr_1990":
            db = database.connect_db()
            cursor = db.cursor()
            cursor.execute("""SELECT month, day_of_week, crs_arr_time, distance, prcp_dest, 
            snow_dest, snwd_dest, tmax_dest, tmin_dest, arr_delay FROM year_1990""")
            result = cursor.fetchall()
            df = pd.DataFrame(result, columns=[desc[0] for desc in cursor.description])
            myModel = model.create_arr_model(df, 1990) 
            return myModel
        
        elif mode == "arr_2000":
            db = database.connect_db()
            cursor = db.cursor()
            cursor.execute("""SELECT month, day_of_week, crs_arr_time, distance, prcp_dest, 
            snow_dest, snwd_dest, tmax_dest, tmin_dest, arr_delay FROM year_2000""")
            result = cursor.fetchall()
            df = pd.DataFrame(result, columns=[desc[0] for desc in cursor.description])
            myModel = model.create_arr_model(df, 2000) 
            return myModel
        
        elif mode == "arr_2001":
            db = database.connect_db()
            cursor = db.cursor()
            cursor.execute("""SELECT month, day_of_week, crs_arr_time, distance, prcp_dest, 
            snow_dest, snwd_dest, tmax_dest, tmin_dest, arr_delay FROM year_2001""")
            result = cursor.fetchall()
            df = pd.DataFrame(result, columns=[desc[0] for desc in cursor.description])
            myModel = model.create_arr_model(df, 2001) 
            return myModel
        
        elif mode == "arr_2006":
            db = database.connect_db()
            cursor = db.cursor()
            cursor.execute("""SELECT month, day_of_week, crs_arr_time, distance, prcp_dest, 
            snow_dest, snwd_dest, tmax_dest, tmin_dest, arr_delay FROM year_2006""")
            result = cursor.fetchall()
            df = pd.DataFrame(result, columns=[desc[0] for desc in cursor.description])
            myModel = model.create_arr_model(df, 2006) 
            return myModel
        
        elif mode == "arr_2007":
            db = database.connect_db()
            cursor = db.cursor()
            cursor.execute("""SELECT month, day_of_week, crs_arr_time, distance, prcp_dest, 
            snow_dest, snwd_dest, tmax_dest, tmin_dest, arr_delay FROM year_2007""")
            result = cursor.fetchall()
            df = pd.DataFrame(result, columns=[desc[0] for desc in cursor.description])
            myModel = model.create_arr_model(df, 2007) 
            return myModel
        
        elif mode == "dep_1989":
            db = database.connect_db()
            cursor = db.cursor()
            cursor.execute("""SELECT month, day_of_week, crs_dep_time, distance, prcp_origin, 
            snow_origin, snwd_origin, tmax_origin, tmin_origin, dep_delay FROM year_1989""")
            result = cursor.fetchall()
            df = pd.DataFrame(result, columns=[desc[0] for desc in cursor.description])
            myModel = model.create_dep_model(df, 1989) 
            return myModel
        
        elif mode == "dep_1990":
            db = database.connect_db()
            cursor = db.cursor()
            cursor.execute("""SELECT month, day_of_week, crs_dep_time, distance, prcp_origin, 
            snow_origin, snwd_origin, tmax_origin, tmin_origin, dep_delay FROM year_1990""")
            result = cursor.fetchall()
            df = pd.DataFrame(result, columns=[desc[0] for desc in cursor.description])
            myModel = model.create_dep_model(df, 1990) 
            return myModel
        
        elif mode == "dep_2000":
            db = database.connect_db()
            cursor = db.cursor()
            cursor.execute("""SELECT month, day_of_week, crs_dep_time, distance, prcp_origin, 
            snow_origin, snwd_origin, tmax_origin, tmin_origin, dep_delay FROM year_2000""")
            result = cursor.fetchall()
            df = pd.DataFrame(result, columns=[desc[0] for desc in cursor.description])
            myModel = model.create_dep_model(df, 2000) 
            return myModel
        
        elif mode == "dep_2001":
            db = database.connect_db()
            cursor = db.cursor()
            cursor.execute("""SELECT month, day_of_week, crs_dep_time, distance, prcp_origin, 
            snow_origin, snwd_origin, tmax_origin, tmin_origin, dep_delay FROM year_2001""")
            result = cursor.fetchall()
            df = pd.DataFrame(result, columns=[desc[0] for desc in cursor.description])
            myModel = model.create_dep_model(df, 2001) 
            return myModel
        
        elif mode == "dep_2006":
            db = database.connect_db()
            cursor = db.cursor()
            cursor.execute("""SELECT month, day_of_week, crs_dep_time, distance, prcp_origin, 
            snow_origin, snwd_origin, tmax_origin, tmin_origin, dep_delay FROM year_2006""")
            result = cursor.fetchall()
            df = pd.DataFrame(result, columns=[desc[0] for desc in cursor.description])
            myModel = model.create_dep_model(df, 2006) 
            return myModel
        
        elif mode == "dep_2007":
            db = database.connect_db()
            cursor = db.cursor()
            cursor.execute("""SELECT month, day_of_week, crs_dep_time, distance, prcp_origin, 
            snow_origin, snwd_origin, tmax_origin, tmin_origin, dep_delay FROM year_2007""")
            result = cursor.fetchall()
            df = pd.DataFrame(result, columns=[desc[0] for desc in cursor.description])
            myModel = model.create_dep_model(df, 2007) 
            return myModel
        
    except Exception as e:
        print(e)
        print("Cannot load_and_train")
    