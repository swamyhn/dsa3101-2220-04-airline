import mysql.connector as msql

#adjustable variables
years = [1989, 1990, 2000, 2001, 2006, 2007]
path_to_csv_folder = 'path/to/folder/containing/yearly/data/to/import/'
db_password = "db_password"

# Connect to the MySQL database
conn = msql.connect(
    host = "localhost",
    user = "root",
    password = db_password,
    db = "airlines",
    allow_local_infile = True,
)

# Get a cursor object
cur = conn.cursor()

# Load data into tables
for year in years:
    file_path = f'{path_to_csv_folder}{year}.csv'
    cur.execute(f"""LOAD DATA INFILE '{file_path}' INTO TABLE airlinesdb.year_{year} FIELDS TERMINATED BY ',' 
    ENCLOSED BY '\"' ESCAPED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
    (year, month, day_of_month, day_of_week, @crs_dep_time, @dep_delay, @dep_delay_group, 
    @crs_arr_time, @arr_delay, @arr_delay_group, distance, prcp_origin, snow_origin, 
    snwd_origin, tmax_origin, tmin_origin, prcp_dest, snow_dest, snwd_dest, 
    tmax_dest, tmin_dest) SET dep_delay = NULLIF(@dep_delay, ''), dep_delay_group = NULLIF(@dep_delay_group, ''), 
    crs_dep_time = NULLIF(@crs_dep_time, ''), arr_delay = NULLIF(@arr_delay, ''), 
    arr_delay_group = NULLIF(@arr_delay_group, ''), crs_arr_time = NULLIF(@crs_arr_time, '');""")
    print(f'{year} LOADED')

conn.commit()
conn.close()