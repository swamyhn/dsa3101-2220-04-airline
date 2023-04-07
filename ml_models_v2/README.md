## Machine learning models
- linear regression (lm)
- decision tree (dt)

## Execute these steps on bash terminal to run the flask app
1. docker pull swamyhn/mysqldb
2. cd to this folder
3. docker compose up --build 

    **Wait for 'Huge Success!' to be printed, will take around 25 mins**
4. The homepage will be on localhost:1000
5. Model coefficients will be on 'localhost:1000/coefficients?mode=mlmodel_direction_year_[std] where
    - mlmodel: lm, dt
    - direction: arr, dep
    - year: 1989, 1990, 2000, 2001, 2006, 2007
    - std: 'T' (standardised coefficients), 'F' (unstandardised coefficients)
        - this argument is **only required for lm models** 
6. Plots for the decision trees will be on 'localhost:1000/plots?mode=**dt**_direction_year' where
    - direction: arr, dep
    - year: 1989, 1990, 2000, 2001, 2006, 2007
7. E.g mode: lm_dep_2001_T, lm_arr_1989_F, dt_arr_2007
