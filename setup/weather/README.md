Historical weather data provided by National Centers for Environmental Information 
is extracted from https://www.ncei.noaa.gov/pub/data/ghcn/daily/.

On this webpage, ghcnd-stations.txt contains the mapping for each weather
station to its state.

Download ghcnd_hcn.tar.gz and extract all the raw dly files containing the
weather station data. Then, convert those files to csv.

The five core weather elements in the final joined data output are:

    PRCP = Precipitation (mm)
    SNOW = Snowfall (mm)
    SNWD = Snow depth (mm)
    TMAX = Maximum temperature (degrees Celsius)
    TMIN = Minimum temperature (degrees Celsius)

*The scales of the elements have been adjusted and are different from the raw data.