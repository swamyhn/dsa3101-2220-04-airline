## Steps required to create MYSQL database locally

1. Create database (**airlines**)
- Run init.sql to create table or copy paste code into mysql workbench and run
2. Import CSV files
- Create folder to store all csv files to import (**files containing yearly data that has been cleaned and joined with external weather data**)
- Go to the directory with the folder, right-click on "Properties"
    - Click on the "Security" tab
    - Under "Group or user names", click on "Edit" and then "Add"
    - Under "Enter the object names to select", type "Users" and select "Check names"
    - Click "OK" to close all dialog boxes
- Open the configuration file, my.ini, and set sql-mode=""
    - This file is usually found in the directory 'C:\ProgramData\MySQL\MySQL Server 8.0'
    - Open Notepad and run as administrator
    - Copy paste contents of my.ini onto a new text file on Notepad and make the required changes
    - Save the new file with the same name and extension my.ini, overwriting the old my.ini
- Login to mysql in terminal and type:
    - SET GLOBAL local_infile = true;
- Run load_data.py after making minor changes to the path in the script

## Steps required to create and upload MYSQL database image

1. Dump the database
- Open Command Prompt and navigate to the directory with the file init.sql
    - Execute the following command to create a dump:
        mysqldump -u root -p airlines > init.sql
    - Input MySQL password upon prompted

- If mysqldump is not recognized in Command Prompt: 
    - Locate the mysqldump executable file on your system. This is usually in the directory 'C:\Program Files\MySQL\MySQL Workbench 8.0'
    - Add the directory containing the mysqldump executable to the PATH environment variable. This can be done by following these steps:
        - Open the System Properties dialog box by right-clicking on "This PC" or "My Computer" and selecting "Properties"
        - Click on "Advanced system settings"
        - Click on the "Environment Variables" button
        - Under "System variables", locate the "Path" variable and double click on it
        - Add the directory containing the mysqldump executable to the list of directories as a new variable
        - Click "OK" to close all dialog boxes and try to execute the mysqldump command again

    - NOTE: If the database is successfully dumped, the init.sql file will be automatically modified and the file size should drastically increase. In the same directory as this README file, the init_template.sql is a copy of init.sql before modification for reference.

2. Dockerise the database
- Replace {db_password} in the Dockerfile with your MYSQL password
- Open a terminal and execute the following command to build the image:
    docker build -t {dockerhub username}/mysqldb .
    - The image is tagged with dockerhub username at the front so that there is no permission error when pushing to a dockerhub repository in your dockerhub account.

3. Add image to dockerhub
    - Login to dockerhub on your browser.
    - You might be required to login to dockerhub in your bash terminal. This can be done by following these steps:
        - docker login -u {dockerhub username}
        - Input dockerhub password when prompted.
    - Upload image to dockerhub by running:
        docker push {dockerhub username}/mysqldb
    - Ensure the dockerhub repository containing the image is public so that others can pull the image.

## Steps taken to obtain mysqldb image:

1. Pull the image from dockerhub (swamyhn's image)
    - To obtain the image, execute the following command:
        docker pull swamyhn/mysqldb
2. Run the image from a container
    - To run a container, choose a [port] and execute the following command:
        docker run -d -p [port]:3306 --name mysqldb_container swamyhn/mysqldb