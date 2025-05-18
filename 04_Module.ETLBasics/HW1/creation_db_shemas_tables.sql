--На локальном экземпляре Postgres создайте новую базу данных «airflights_db». (1 балл)

CREATE DATABASE airflights_db;



--Создайте в базе данных «airflights_db» новую схему «raw». (1 балл)

CREATE SCHEMA raw;



/*Создайте в схеме «raw» таблицу «airflights_passengers_denorm_exporting». 
Структура таблицы будет повторять структуру исходного файла «airflights_passengers_denorm_export.csv».
Здесь очень важно выбирать верный формат колонок, чтобы при загрузке не потерять данные из файла. (1 балл)*/
 
CREATE TABLE IF NOT EXISTS raw.airflights_passengers_denorm_exporting (
    airline_icao_code VARCHAR(20),
    airline_name VARCHAR(50),
    airline_call_sign VARCHAR(20),
    airline_country VARCHAR(50),
    flight_code VARCHAR(20),
    airport_from_iata_code VARCHAR(20),
    airport_from_name VARCHAR(100),
    airport_from_location VARCHAR,
    airport_to_iata_code VARCHAR(20),
    airport_to_name VARCHAR(100),
    airport_to_location VARCHAR,
    flight_distance INT,
    pilot_name VARCHAR(50),
    pilot_surname VARCHAR(50),
    copilot_name VARCHAR(50),
    copilot_surname VARCHAR(50),
    passenger_first_name VARCHAR(50),
    passenger_last_name VARCHAR(50),
    passenger_country VARCHAR(50),
    travel_class VARCHAR(20),
    ticket_code VARCHAR(20),
    ticket_price MONEY
);



/*Загрузите денормализованные данные из Excel файла в базу данных «airflights_db» в схему «raw».
Для этого используйте команду «COPY» (LINK) (1 балл)*/

COPY airflights_passengers_denorm_exporting (
    airline_icao_code,
    airline_name,
    airline_call_sign,
    airline_country,
    flight_code,
    airport_from_iata_code,
    airport_from_name,
    airport_from_location,
    airport_to_iata_code,
    airport_to_name,
    airport_to_location,
    flight_distance,
    pilot_name,
    pilot_surname,
    copilot_name,
    copilot_surname,
    passenger_first_name,
    passenger_last_name,
    passenger_country,
    travel_class,
    ticket_code,
    ticket_price
)
FROM 'D:\Programs files\PostgreSQL_15\postresql_files\airflights_passengers_denorm_exporting.csv'
DELIMITER ';'
CSV HEADER;



/*Напишите SQL запрос для подсчета количества записей в таблице «airflights_passengers_denorm_exporting». 
Убедитесь, что количество записей в таблице совпадает с количеством записей в исходном файле (1 балл)*/

SELECT COUNT(*)
FROM raw.airflights_passengers_denorm_exporting apde; --Запрос выдал 2065 строк, столько же и в файле не считая заголовок



--Создайте в базе «airflights_db» схему «dds». (1 балл)

CREATE SCHEMA dds; 



/*В схеме «dds» создайте все таблицы, необходимые для приведения данных из таблицы
«raw.airflights_passengers_denorm_exporting» к 3 нормальной форме. 
Подумайте также над созданием необходимых ограничений (Constraints) (2 балла)*/

CREATE TABLE IF NOT EXISTS dds.country (
    country_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);


CREATE TABLE IF NOT EXISTS dds.passenger (
    passenger_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    country_id INT,
    FOREIGN KEY (country_id) REFERENCES dds.country(country_id)
);


CREATE TABLE IF NOT EXISTS dds.airline (
    airline_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    airline_icao_code VARCHAR(20) NOT NULL,
    name VARCHAR(50) UNIQUE NOT NULL,
    airline_call_sign VARCHAR(50) NOT NULL,
    country_id INT,
    FOREIGN KEY (country_id) REFERENCES dds.country(country_id)
);


CREATE TABLE IF NOT EXISTS dds.location (
    location_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);


CREATE TABLE IF NOT EXISTS dds.airport (
    airport_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    airport_iata_code VARCHAR(20) NOT NULL,
    name VARCHAR(50) UNIQUE NOT NULL,
    location_id INT NOT NULL,
    FOREIGN KEY (location_id) REFERENCES dds.location(location_id)
);


CREATE TABLE IF NOT EXISTS dds.pilot (
    pilot_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    surname VARCHAR (50) NOT NULL
);


CREATE TABLE IF NOT EXISTS dds.travel_class (
    travel_class_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);


CREATE TABLE IF NOT EXISTS dds.flight (
    flight_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    flight_code VARCHAR(20) NOT NULL,
    flight_distance INT NOT NULL,
    airport_id_from INT NOT NULL,
    airport_id_to INT NOT NULL,
    airline_id INT NOT NULL,
    main_pilot_id INT NOT NULL,
    copilot_id INT NOT NULL,
    FOREIGN KEY (airport_id_from) REFERENCES dds.airport(airport_id),
    FOREIGN KEY (airport_id_to) REFERENCES dds.airport(airport_id),
    FOREIGN KEY (airline_id) REFERENCES dds.airline(airline_id),
    FOREIGN KEY (main_pilot_id) REFERENCES dds.pilot(pilot_id),
    FOREIGN KEY (copilot_id) REFERENCES dds.pilot(pilot_id)
);


CREATE TABLE IF NOT EXISTS dds.ticket (
    ticket_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_code VARCHAR(20) NOT NULL,
    ticket_price MONEY NOT NULL,
    travel_class_id INT NOT NULL,
    passenger_id INT NOT NULL,
    flight_id INT NOT NULL,
    FOREIGN KEY (travel_class_id) REFERENCES dds.travel_class(travel_class_id),
    FOREIGN KEY (passenger_id) REFERENCES dds.passenger(passenger_id),
    FOREIGN KEY (flight_id) REFERENCES dds.flight(flight_id)
);
