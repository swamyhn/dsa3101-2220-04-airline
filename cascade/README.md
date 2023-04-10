## Execute these steps on terminal to run the flask app
1. cd to this folder
2. docker compose up --build
3. The homepage will be on localhost:5000
4. To get the dataframe (in json format) for the day with most delays from origin to destination in year, 
go to localhost:5000/query?origin=origin&dest=destination&year=year.

e.g. localhost:5000/query?origin=ATL&dest=LAX&year=2007 will show the day with most delays in 2007 from ATL to LAX.
