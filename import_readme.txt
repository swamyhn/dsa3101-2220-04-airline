1. log into mysql via command prompt and run
SET GLOBAL local_infile = true;

2. run initialization.sql, creating the database and table

3. edit the import.sh script with correct username and password
on command prompt, run the line
sh ./import.sh


