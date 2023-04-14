Historical weather data provided by National Centers for Environmental Information is extracted from https://www.ncei.noaa.gov/pub/data/ghcn/daily/.

1. On this webpage, ghcnd-stations.txt contains the mapping for each weather station to its state. Save ghcnd-stations.txt as a CSV file (ghcnd-stations.csv). To format ghcnd-stations.csv, follow these steps:

- Select column A. Go to the Data panel > Text to Columns.
- Select Fixed width, then select Next.
- Click 41 on the ruler, a break line should be placed right before the column whose first row is 'ST JOHNS COOLIDGE FLD', then select Next and Finish.
- Select OK when prompted to replace data.
- Save and exit the CSV file.

2. Download ghcnd_hcn.tar.gz and extract all the raw dly files containing the weather station data.

3. Run join_weather.py to process and join weather elements to our raw airlines data. join extracted weather data with cleaned raw data

The five core elements (stated in the webpage) that we added to our raw airlines data are:

    PRCP = Precipitation (tenths of mm)
    SNOW = Snowfall (mm)
    SNWD = Snow depth (mm)
    TMAX = Maximum temperature (tenths of degrees C)
    TMIN = Minimum temperature (tenths of degrees C)

\*The scales of the elements will be adjusted during the join, with each PRCP = Precipitation (mm), TMAX = Maximum temperature (degrees C) and TMIN = Minimum temperature (degrees C).
