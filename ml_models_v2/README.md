## Machine learning models
- linear regression (lm)
- decision tree (dt)

## Execute these steps on bash terminal to run the flask app
1. cd to this folder
2. docker compose up --build 

    **Wait for 'HUGE SUCCESS!' to be printed, will take around 20 mins**
4. The homepage will be on localhost:1000
5. **Linear regression** model coefficients will be on 'localhost:1000/**coefficients**?mode=**lm**_direction_year_std' where
    - direction: arr, dep
    - year: 1989, 1990, 2000, 2001, 2006, 2007
    - std: T (standardised coefficients), F (unstandardised coefficients)
    - e.g mode: lm_dep_2001_T, lm_arr_1989_F
6. Plots for the **decision trees** will be on 'localhost:1000/**plots**?mode=**dt**_direction_year' where
    - direction: arr, dep
    - year: 1989, 1990, 2000, 2001, 2006, 2007
    - e.g mode: dt_dep_2000, dt_arr_2007