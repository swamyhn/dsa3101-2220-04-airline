#!/bin/bash
i=1
for f in AirOnTimeCSV/cleaned/*.csv
do
	mysql -e "load data local infile '"$f"'
	 into table airlines fields terminated by ',' enclosed by '\"' escaped by '\"'
	 lines terminated by '\n'
	 ignore 1 rows" -u root -ppassword_here --local-infile airlinesdb
	echo $i files have been imported
	((i=i+1))
done



