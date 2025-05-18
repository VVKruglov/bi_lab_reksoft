--Посчитайте, граждане какой страны летают больше всего (выведите первые 10 стран, отсортированные по убыванию количества перелётов)

SELECT 
    c."name" AS country,
    COUNT(t.ticket_code) AS quantity_flights
FROM
    dds.passenger p
JOIN dds.ticket t ON
    p.passenger_id = t.passenger_id
JOIN dds.country c ON
    p.country_id = c.country_id
GROUP BY
    c."name"
ORDER BY
    quantity_flights DESC
LIMIT 10;



--Авиакомпании каких стран совершили самое большое количество рейсов (вывести 5 стран, упорядоченных по убыванию количества рейсов). (1 балл)

SELECT 
    c."name" AS country,
    COUNT(f.flight_id) AS quantity_flights
FROM
    dds.flight f
JOIN dds.airline a ON
    f.airline_id = a.airline_id
JOIN dds.country c ON
    a.country_id = c.country_id
GROUP BY
    c."name"
ORDER BY
    quantity_flights DESC
LIMIT 5;



--Каких рейсов больше: пассажирских или грузовых? (1 балл)

CREATE OR REPLACE FUNCTION more_cargo_or_passenger() RETURNS TEXT AS $$

DECLARE
    passenger_count INT;
    cargo_count INT;
BEGIN

passenger_count := (SELECT COUNT(*)
                    FROM dds.flight f JOIN dds.ticket t ON f.flight_id = t.flight_id); 

cargo_count := (SELECT COUNT(*)
                FROM dds.flight f LEFT JOIN dds.ticket t ON f.flight_id = t.flight_id
                WHERE t.flight_id IS NULL);

IF passenger_count > cargo_count
    THEN RETURN 'Passenger more';
    ELSE RETURN 'Cargo more';
END IF;
END;   

$$ LANGUAGE plpgsql; 

SELECT more_cargo_or_passenger();



--Подсчитайте процентное соотношение грузовых и пассажирских рейсов для различных авиакомпаний. (1 балл)

WITH flights_count AS 
(
    SELECT
        a.name AS airline,
        COUNT(CASE WHEN t.ticket_id IS NOT NULL THEN 1 END) AS passenger_flights,
        COUNT(CASE WHEN t.ticket_id IS NULL THEN 1 END) AS cargo_flights,
        COUNT(*) AS total_flights
    FROM
        dds.ticket t
    RIGHT JOIN dds.flight f ON
        t.flight_id = f.flight_id
    JOIN dds.airline a ON
        f.airline_id = a.airline_id
    GROUP BY
        a.name
)

SELECT 
    fc.airline AS airline,
    ROUND((fc.passenger_flights::NUMERIC / fc.total_flights) * 100, 2) AS persent_of_passenger_flights,
    ROUND((fc.cargo_flights::NUMERIC / fc.total_flights) * 100, 2) AS persent_of_cargo_flights
FROM
    flights_count fc
ORDER BY
    fc.airline;

    
    
/*Найдите людей, которые наиболее часто путешествуют (выведите первые 20 с указанием количества перелётов, 
суммарного километража и суммарной стоимости всех билетов этого пассажира). (1 балл)*/

SELECT 
    p.first_name || ' ' || p.last_name AS passenger,
    COUNT(t.ticket_id) AS quantity_flight,
    SUM(f.flight_distance) AS total_distance,
    SUM(t.ticket_price) AS total_price
FROM
    dds.country c 
JOIN dds.passenger p ON
    c.country_id = p.country_id 
JOIN dds.ticket t ON
    p.passenger_id = t.passenger_id
JOIN dds.flight f ON
    t.flight_id = f.flight_id
GROUP BY
    p.first_name,
    p.last_name,
    c."name" 
ORDER BY
    quantity_flight DESC
LIMIT 20;



--Найдите трех пассажиров, которые налетали больше всего километров с авиакомпанией «Deutsche Rettungsflugwacht». (1 балл)

WITH top_three_passenger AS 
(
    SELECT
        p.first_name,
        p.last_name,
        SUM(f.flight_distance) AS total_distance,
        a."name"
    FROM
        dds.passenger p
    JOIN dds.ticket t ON
        p.passenger_id = t.passenger_id
    JOIN dds.flight f ON
        t.flight_id = f.flight_id
    JOIN dds.airline a ON
        f.airline_id = a.airline_id
    GROUP BY
        p.first_name,
        p.last_name,
        a."name"
    HAVING
        a.name = 'Deutsche Rettungsflugwacht'
    ORDER BY
        total_distance DESC
    LIMIT 3
)

SELECT
    ttp.first_name || ' ' || ttp.last_name AS passenger
FROM
    top_three_passenger ttp;



--Обновите данные с учётом 15% скидки на авиабилеты для этих (см. выше) пассажиров в этой компании. (1 балл)

WITH top_three_passenger AS 
(
    SELECT
        p.passenger_id
    FROM
        dds.passenger p
    JOIN dds.ticket t ON
        p.passenger_id = t.passenger_id
    JOIN dds.flight f ON
        t.flight_id = f.flight_id
    JOIN dds.airline a ON
        f.airline_id = a.airline_id
    WHERE
        a.name = 'Deutsche Rettungsflugwacht'
    GROUP BY
        p.passenger_id
    ORDER BY
        SUM(f.flight_distance) DESC
    LIMIT 3
)

UPDATE dds.ticket t
SET ticket_price = ROUND(t.ticket_price::NUMERIC * 0.85, 2) -- Скидка 15%
FROM top_three_passenger ttp
WHERE t.passenger_id = ttp.passenger_id;



--Удалите из базы данных информацию о пассажирах, которые были зарегистрированы менее чем на 5 рейсов. (1 балл)

CREATE TABLE dds.passenger_last_five_backup AS --Создаем копию данных перед удалением
SELECT *
FROM
    dds.passenger p
WHERE
    p.passenger_id IN (
        SELECT
            p.passenger_id
        FROM
            dds.passenger p
        JOIN dds.ticket t ON
            p.passenger_id = t.passenger_id
        GROUP BY
            p.passenger_id
        HAVING
            COUNT(t.passenger_id) < 5);

        
DELETE FROM --удаляем данные из ticket
    dds.ticket t
WHERE
    t.passenger_id IN (
        SELECT
            plfb.passenger_id
        FROM
            dds.passenger_last_five_backup plfb);
    
        
DELETE FROM --удаляем данные из passenger
    dds.passenger p
WHERE
    p.passenger_id IN (
        SELECT
            plfb.passenger_id
        FROM
            dds.passenger_last_five_backup plfb);
        

        
/*Добавьте пассажирский рейс, выполняемый авиакомпанией «Belavia Belarusian Airlines» по маршруту
 «Minsk International Airport» - «Warsaw, Poland» (на рейс зарегистрировано 57 пассажиров). (1 балл)*/

--Вставка рейса
INSERT INTO dds.flight (flight_code, flight_distance, airport_id_from, airport_id_to, airline_id, main_pilot_id, copilot_id)
VALUES (
    'MSQ471', 
    471, 
    (
    SELECT
        ap.airport_id
    FROM
        dds.airport ap
    WHERE
        ap.name = 'Minsk International Airport'), 
    (
    SELECT
        ap.airport_id
    FROM
        dds.airport ap
    JOIN dds."location" l ON
        ap.location_id = l.location_id
    WHERE
        l."name" = 'Warsaw, Poland'
    LIMIT 1), 
    (
    SELECT
        al.airline_id
    FROM
        dds.airline al
    WHERE
        al.name = 'Belavia Belarusian Airlines'),
    (
    SELECT 
        p.pilot_id
    FROM 
        dds.pilot p
    WHERE 
        p.name = 'Peter'
        AND p.surname = 'Russell'),
    (
    SELECT 
        p.pilot_id
    FROM 
        dds.pilot p
    WHERE 
        p.name = 'Lisa'
        AND p.surname = 'Greene')
        
);

--Заполнение билетов
DO $$
DECLARE
    i INT := 1;
    passenger RECORD;
BEGIN
    
    FOR passenger IN 
        SELECT passenger_id 
        FROM dds.passenger 
        ORDER BY passenger_id
    LOOP
        
        IF i > 57 THEN
            EXIT; 
        END IF;

        -- Вставка билета
        INSERT INTO dds.ticket (ticket_code, ticket_price, travel_class_id, passenger_id, flight_id) 
        VALUES
        (
            'MSQ471/' || 
                CASE 
                    WHEN i < 10 THEN '00' || i::TEXT 
                    WHEN i >= 10 AND i < 100 THEN '0' || i::TEXT
                    ELSE '' || i::TEXT
                END,
            800,
            (
            SELECT
                tc.travel_class_id
            FROM
                dds.travel_class tc
            WHERE
                tc.name = 'ECONOMY'
            ), 
            passenger.passenger_id,
            (
                SELECT
                    f.flight_id
                FROM
                    dds.flight f
                JOIN dds.airport ap ON
                    f.airport_id_from = ap.airport_id
                JOIN dds.airline al ON
                     f.airline_id = al.airline_id
                WHERE
                    al.name = 'Belavia Belarusian Airlines'
                    AND ap.name = 'Minsk International Airport'
            )
        );

        i := i + 1;
    END LOOP;
END;
$$;

--Проверка результата
SELECT
    t.ticket_code AS code,
    a.name AS airline,
    p.first_name || ' ' || p.last_name AS passenger,
    l."name" 
FROM
    dds.passenger p
JOIN dds.ticket t ON
    p.passenger_id = t.passenger_id
JOIN dds.flight f ON
    t.flight_id = f.flight_id
JOIN dds.airline a ON
    f.airline_id = a.airline_id
JOIN dds.airport a2 ON
    f.airport_id_to = a2.airport_id
JOIN dds."location" l ON
    a2.location_id = l.location_id 
WHERE
    a."name" = 'Belavia Belarusian Airlines'
    AND l."name" = 'Warsaw, Poland'

