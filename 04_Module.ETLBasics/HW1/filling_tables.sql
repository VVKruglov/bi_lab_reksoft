--Напишите SQL запросы для копирования данных из «raw.airflights_passengers_denorm_exporting» в таблицы схемы «dds». (2 балла)

TRUNCATE dds.country CASCADE;

INSERT INTO dds.country (name)
SELECT DISTINCT
  apde.airline_country AS name
FROM raw.airflights_passengers_denorm_exporting apde
WHERE
    TRIM(apde.airline_country) != ''
    AND apde.airline_country IS NOT NULL
UNION
SELECT DISTINCT
    apde.passenger_country AS name
FROM raw.airflights_passengers_denorm_exporting apde
WHERE
    TRIM(apde.passenger_country) != ''
    AND apde.passenger_country IS NOT NULL;


TRUNCATE dds.travel_class CASCADE;

INSERT INTO dds.travel_class (name)
SELECT DISTINCT 
    apde.travel_class AS name
FROM raw.airflights_passengers_denorm_exporting apde
WHERE 
    TRIM(apde.travel_class) != ''
    AND apde.travel_class IS NOT NULL;


TRUNCATE dds.airline CASCADE;

INSERT INTO dds.airline (airline_icao_code, name, airline_call_sign, country_id)
SELECT DISTINCT
    apde.airline_icao_code AS airline_icao_code,
    apde.airline_name AS name,
    apde.airline_call_sign AS airline_call_sign,
    c.country_id AS country_id
FROM raw.airflights_passengers_denorm_exporting apde
JOIN dds.country c ON 
    c.name = apde.airline_country
WHERE 
    apde.airline_icao_code IS NOT NULL
    AND apde.airline_name IS NOT NULL
    AND apde.airline_call_sign IS NOT NULL;


TRUNCATE dds."location" CASCADE;

INSERT INTO dds.location (name)
SELECT DISTINCT 
    apde.airport_from_location AS name
FROM raw.airflights_passengers_denorm_exporting apde
WHERE 
    TRIM(apde.airport_from_location) != ''
    AND apde.airport_from_location IS NOT NULL
UNION
SELECT DISTINCT 
    apde.airport_to_location AS name
FROM raw.airflights_passengers_denorm_exporting apde
WHERE 
    TRIM(apde.airport_to_location) != ''
    AND apde.airport_to_location IS NOT NULL;


TRUNCATE dds.airport CASCADE;

INSERT INTO dds.airport (airport_iata_code, name, location_id)
SELECT DISTINCT
    apde.airport_from_iata_code AS airport_iata_code,
    apde.airport_from_name AS name,
    loc.location_id AS location_id
FROM raw.airflights_passengers_denorm_exporting apde
JOIN dds.location loc ON
    loc.name = apde.airport_from_location
WHERE 
    apde.airport_from_iata_code IS NOT NULL
    AND apde.airport_from_name IS NOT NULL
    AND apde.airport_from_location IS NOT NULL
UNION
SELECT DISTINCT
    apde.airport_to_iata_code AS airport_iata_code,
    apde.airport_to_name AS name,
    loc.location_id AS location_id
FROM raw.airflights_passengers_denorm_exporting apde
JOIN dds.location loc ON 
    loc.name = apde.airport_to_location
WHERE 
    apde.airport_to_iata_code IS NOT NULL
    AND apde.airport_to_name IS NOT NULL
    AND apde.airport_to_location IS NOT NULL;


TRUNCATE dds.passenger CASCADE;

INSERT INTO dds.passenger (first_name, last_name, country_id)
SELECT DISTINCT
    apde.passenger_first_name AS first_name,
    apde.passenger_last_name AS last_name,
    c.country_id AS country_id
FROM raw.airflights_passengers_denorm_exporting apde
JOIN dds.country c ON 
    c.name = apde.passenger_country
WHERE 
    TRIM(apde.passenger_first_name) != ''
    AND TRIM(apde.passenger_last_name) != ''
    AND apde.passenger_first_name IS NOT NULL
    AND apde.passenger_last_name IS NOT NULL
    AND NOT EXISTS (
        SELECT 1
        FROM dds.passenger p
        WHERE 
            p.first_name = apde.passenger_first_name
            AND p.last_name = apde.passenger_last_name
            AND p.country_id = c.country_id 
    );


TRUNCATE dds.pilot CASCADE;

INSERT INTO dds.pilot (name, surname)
SELECT DISTINCT 
    apde.pilot_name AS name,
    apde.pilot_surname AS surname
FROM raw.airflights_passengers_denorm_exporting apde
WHERE 
    TRIM(apde.pilot_name) != ''
    AND TRIM(apde.pilot_surname) != ''
    AND apde.pilot_name IS NOT NULL
    AND apde.pilot_surname IS NOT NULL
UNION
SELECT DISTINCT 
    apde.copilot_name AS name,
    apde.copilot_surname AS surname
FROM raw.airflights_passengers_denorm_exporting apde
WHERE 
    TRIM(apde.copilot_name) != ''
    AND TRIM(apde.copilot_surname) != ''
    AND apde.copilot_name IS NOT NULL
    AND apde.copilot_surname IS NOT NULL;


TRUNCATE dds.flight CASCADE;

INSERT INTO dds.flight (flight_code, flight_distance, airport_id_from, airport_id_to, airline_id, main_pilot_id, copilot_id)
SELECT DISTINCT
    apde.flight_code AS flight_code,
    apde.flight_distance AS flight_distance,
    a_from.airport_id AS airport_id_from,
    a_to.airport_id AS airport_id_to,
    al.airline_id AS airline_id,
    main_pilot.pilot_id AS main_pilot_id,
    copilot.pilot_id AS copilot_id
FROM
    raw.airflights_passengers_denorm_exporting apde
JOIN dds.airport a_from ON
    a_from.airport_iata_code = apde.airport_from_iata_code
JOIN dds.airport a_to ON
    a_to.airport_iata_code = apde.airport_to_iata_code
JOIN dds.airline al ON
    al.airline_icao_code = apde.airline_icao_code
JOIN dds.pilot main_pilot ON
    main_pilot.name = apde.pilot_name
    AND main_pilot.surname = apde.pilot_surname
JOIN dds.pilot copilot ON
    copilot.name = apde.copilot_name
    AND copilot.surname = apde.copilot_surname
WHERE
    apde.flight_code IS NOT NULL
    AND apde.flight_distance IS NOT NULL;


TRUNCATE dds.ticket CASCADE;

INSERT INTO dds.ticket (ticket_code, ticket_price, travel_class_id, passenger_id, flight_id)
SELECT DISTINCT 
    apde.ticket_code AS ticket_code,
    apde.ticket_price AS ticket_price,
    tc.travel_class_id AS travel_class_id,
    p.passenger_id AS passenger_id,
    f.flight_id AS flight_id
FROM raw.airflights_passengers_denorm_exporting apde
JOIN dds.travel_class tc ON 
    tc.name = apde.travel_class
JOIN dds.passenger p ON 
    p.first_name = apde.passenger_first_name
    AND p.last_name = apde.passenger_last_name
    AND p.country_id = (SELECT country_id FROM dds.country WHERE name = apde.passenger_country)
JOIN dds.flight f ON 
    f.flight_code = apde.flight_code
WHERE
    apde.ticket_code IS NOT NULL
    AND apde.ticket_price IS NOT NULL
    AND apde.flight_code IS NOT NULL
    AND NOT EXISTS (
    SELECT 1
    FROM dds.ticket t
    WHERE t.ticket_code = apde.ticket_code
);

