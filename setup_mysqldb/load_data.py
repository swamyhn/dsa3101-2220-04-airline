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
    cur.execute(f"""LOAD DATA INFILE '{file_path}' INTO TABLE airlines.year_{year} FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;""")
    print(f'{year} LOADED')

conn.commit()
conn.close()