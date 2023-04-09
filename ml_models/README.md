## Machine learning models
- linear regression (lm)
- decision tree (dt)

## Execute these steps on bash terminal to run the flask app
1. cd to this folder
2. docker compose up --build 

    **Wait for the all the commands in orange to be executed, will take around 5 mins**
![alt text](images/bash_terminal.png)
4. The homepage will be on localhost:1000
5. Model coefficients will be on 'localhost:1000/coefficients?mode=mlmodel_direction_year_[std] where
    - mlmodel: lm, dt
    - direction: arr, dep
    - year: 1989, 1990, 2000, 2001, 2006, 2007
    - std: 'T' (standardised coefficients), 'F' (unstandardised coefficients)
        - this argument is **only required for lm models** 
6. If the input for 'mode' is new, the loading time will be around 1-2 mins. Otherwise, the output is instantaneous.
7. Plots for the decision trees will be on 'localhost:1000/plots?mode=**dt**_direction_year' where
    - direction: arr, dep
    - year: 1989, 1990, 2000, 2001, 2006, 2007
8. E.g mode: lm_dep_2001_T, lm_arr_1989_F, dt_arr_2007
