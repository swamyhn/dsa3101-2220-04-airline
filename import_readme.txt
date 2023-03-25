Steps taken to create mysql database image:

1. Create database (airlines)
- Run init.sql to create table / can ask them copy paste code into mysql workbench and run
2. Import CSV files
- Create folder to store all csv files to import
- Go to the directory with the folder, right-click on "Properties".
    - Click on the "Security" tab. 
    - Under "Group or user names", click on "Edit" and then "Add".
    - Under "Enter the object names to select", type "Users" and select "Check names".
    - Click "OK" to close all dialog boxes.
- Open the configuration file, my.ini, and set sql-mode="".
- Login to mysql in terminal, SET GLOBAL local_infile = true;
- Run import_to_mysql.py after making minor changes to the path in the script.

3. Dump the database
- Open Command Prompt and navigate to the directory with the file init.sql
    - Execute the following command by replacing [username] and [database] to create a dump:
        mysqldump -u [username] -p [database] > init.sql
    - Input password upon prompted

- If mysqldump is not recognized in Command Prompt, locate the mysqldump executable file on your system and add the directory containing the mysqldump executable to the PATH environment variable. This can be done by following these steps:
    - Open the System Properties dialog box by right-clicking on "This PC" or "My Computer" and selecting "Properties".
    - Click on "Advanced system settings".
    - Click on the "Environment Variables" button.
    - Under "System variables", locate the "Path" variable and click on "Edit".
    - Add the directory containing the mysqldump executable to the list of directories separated by a semicolon (;) / wanna ask them to add the workbench instead?
    - Click "OK" to close all dialog boxes and try to execute the mysqldump command again.

4. Dockerise the database
- Open a terminal and execute the following command to build the image:
    docker build -t mysqldb .

5. Add image to dockerhub
    - Login to dockerhub.
    - Tag the image using the following command:
        docker tag mysqldb swamyhn/mysqldb
    - Upload image to dockerhub by running:
        docker pull swamhyn/mysqldb




Steps required to obtain mysqldb:

1. Pull the image from dockerhub
    - To obtain the image, execute the following command:
        docker pull swamyhn/mysqldb
2. Run the image from a container
    - To run a container, choose a [port] and execute the following command:
        docker run -d -p [port]:3306 --name mysqldb_container mysqldb