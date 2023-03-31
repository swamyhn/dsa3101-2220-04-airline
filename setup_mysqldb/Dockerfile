FROM mysql:latest

ENV MYSQL_ROOT_PASSWORD={db_password}
ENV MYSQL_DATABASE=airlines

COPY init.sql /docker-entrypoint-initdb.d/