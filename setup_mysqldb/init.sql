CREATE DATABASE IF NOT EXISTS airlines;
USE airlines;

CREATE TABLE IF NOT EXISTS year_1989 (
  year int DEFAULT NULL,
  month int DEFAULT NULL,
  day_of_month int DEFAULT NULL,
  day_of_week int DEFAULT NULL,
  crs_dep_time decimal(10,0) DEFAULT NULL,
  dep_delay int DEFAULT NULL,
  dep_delay_group int DEFAULT NULL,
  crs_arr_time decimal(10,0) DEFAULT NULL,
  arr_delay int DEFAULT NULL,
  arr_delay_group int DEFAULT NULL,
  distance int DEFAULT NULL,
  prcp_origin decimal(10,6) DEFAULT NULL,
  snow_origin decimal(10,6) DEFAULT NULL,
  snwd_origin decimal(10,6) DEFAULT NULL,
  tmax_origin decimal(10,6) DEFAULT NULL,
  tmin_origin decimal(10,6) DEFAULT NULL,
  prcp_dest decimal(10,6) DEFAULT NULL,
  snow_dest decimal(10,6) DEFAULT NULL,
  snwd_dest decimal(10,6) DEFAULT NULL,
  tmax_dest decimal(10,6) DEFAULT NULL,
  tmin_dest decimal(10,6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS year_1990 (
  year int DEFAULT NULL,
  month int DEFAULT NULL,
  day_of_month int DEFAULT NULL,
  day_of_week int DEFAULT NULL,
  crs_dep_time decimal(10,0) DEFAULT NULL,
  dep_delay int DEFAULT NULL,
  dep_delay_group int DEFAULT NULL,
  crs_arr_time decimal(10,0) DEFAULT NULL,
  arr_delay int DEFAULT NULL,
  arr_delay_group int DEFAULT NULL,
  distance int DEFAULT NULL,
  prcp_origin decimal(10,6) DEFAULT NULL,
  snow_origin decimal(10,6) DEFAULT NULL,
  snwd_origin decimal(10,6) DEFAULT NULL,
  tmax_origin decimal(10,6) DEFAULT NULL,
  tmin_origin decimal(10,6) DEFAULT NULL,
  prcp_dest decimal(10,6) DEFAULT NULL,
  snow_dest decimal(10,6) DEFAULT NULL,
  snwd_dest decimal(10,6) DEFAULT NULL,
  tmax_dest decimal(10,6) DEFAULT NULL,
  tmin_dest decimal(10,6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS year_2000 (
  year int DEFAULT NULL,
  month int DEFAULT NULL,
  day_of_month int DEFAULT NULL,
  day_of_week int DEFAULT NULL,
  crs_dep_time decimal(10,0) DEFAULT NULL,
  dep_delay int DEFAULT NULL,
  dep_delay_group int DEFAULT NULL,
  crs_arr_time decimal(10,0) DEFAULT NULL,
  arr_delay int DEFAULT NULL,
  arr_delay_group int DEFAULT NULL,
  distance int DEFAULT NULL,
  prcp_origin decimal(10,6) DEFAULT NULL,
  snow_origin decimal(10,6) DEFAULT NULL,
  snwd_origin decimal(10,6) DEFAULT NULL,
  tmax_origin decimal(10,6) DEFAULT NULL,
  tmin_origin decimal(10,6) DEFAULT NULL,
  prcp_dest decimal(10,6) DEFAULT NULL,
  snow_dest decimal(10,6) DEFAULT NULL,
  snwd_dest decimal(10,6) DEFAULT NULL,
  tmax_dest decimal(10,6) DEFAULT NULL,
  tmin_dest decimal(10,6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS year_2001 (
  year int DEFAULT NULL,
  month int DEFAULT NULL,
  day_of_month int DEFAULT NULL,
  day_of_week int DEFAULT NULL,
  crs_dep_time decimal(10,0) DEFAULT NULL,
  dep_delay int DEFAULT NULL,
  dep_delay_group int DEFAULT NULL,
  crs_arr_time decimal(10,0) DEFAULT NULL,
  arr_delay int DEFAULT NULL,
  arr_delay_group int DEFAULT NULL,
  distance int DEFAULT NULL,
  prcp_origin decimal(10,6) DEFAULT NULL,
  snow_origin decimal(10,6) DEFAULT NULL,
  snwd_origin decimal(10,6) DEFAULT NULL,
  tmax_origin decimal(10,6) DEFAULT NULL,
  tmin_origin decimal(10,6) DEFAULT NULL,
  prcp_dest decimal(10,6) DEFAULT NULL,
  snow_dest decimal(10,6) DEFAULT NULL,
  snwd_dest decimal(10,6) DEFAULT NULL,
  tmax_dest decimal(10,6) DEFAULT NULL,
  tmin_dest decimal(10,6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS year_2006 (
  year int DEFAULT NULL,
  month int DEFAULT NULL,
  day_of_month int DEFAULT NULL,
  day_of_week int DEFAULT NULL,
  crs_dep_time decimal(10,0) DEFAULT NULL,
  dep_delay int DEFAULT NULL,
  dep_delay_group int DEFAULT NULL,
  crs_arr_time decimal(10,0) DEFAULT NULL,
  arr_delay int DEFAULT NULL,
  arr_delay_group int DEFAULT NULL,
  distance int DEFAULT NULL,
  prcp_origin decimal(10,6) DEFAULT NULL,
  snow_origin decimal(10,6) DEFAULT NULL,
  snwd_origin decimal(10,6) DEFAULT NULL,
  tmax_origin decimal(10,6) DEFAULT NULL,
  tmin_origin decimal(10,6) DEFAULT NULL,
  prcp_dest decimal(10,6) DEFAULT NULL,
  snow_dest decimal(10,6) DEFAULT NULL,
  snwd_dest decimal(10,6) DEFAULT NULL,
  tmax_dest decimal(10,6) DEFAULT NULL,
  tmin_dest decimal(10,6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS year_2007 (
  year int DEFAULT NULL,
  month int DEFAULT NULL,
  day_of_month int DEFAULT NULL,
  day_of_week int DEFAULT NULL,
  crs_dep_time decimal(10,0) DEFAULT NULL,
  dep_delay int DEFAULT NULL,
  dep_delay_group int DEFAULT NULL,
  crs_arr_time decimal(10,0) DEFAULT NULL,
  arr_delay int DEFAULT NULL,
  arr_delay_group int DEFAULT NULL,
  distance int DEFAULT NULL,
  prcp_origin decimal(10,6) DEFAULT NULL,
  snow_origin decimal(10,6) DEFAULT NULL,
  snwd_origin decimal(10,6) DEFAULT NULL,
  tmax_origin decimal(10,6) DEFAULT NULL,
  tmin_origin decimal(10,6) DEFAULT NULL,
  prcp_dest decimal(10,6) DEFAULT NULL,
  snow_dest decimal(10,6) DEFAULT NULL,
  snwd_dest decimal(10,6) DEFAULT NULL,
  tmax_dest decimal(10,6) DEFAULT NULL,
  tmin_dest decimal(10,6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

GRANT ALL PRIVILEGES ON airlines.* TO 'root'@'localhost';