--Получение дневного расписания сеансов на указанную дату
CREATE OR REPLACE FUNCTION get_movie_date(date_ DATE) 
RETURNS TABLE 
(
    movie VARCHAR,
    time_start TIME,
    time_finish TIME,  
    cinema_hall VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
     m."name" AS movie,
    s.time_start,
    s.time_finish,
    ch."name" AS cinema_hall
FROM public.schedule s 
    JOIN public.movie m ON s.movie_id = m.movie_id 
    JOIN public.cinema_hall ch ON s.cinema_hall_id = ch.cinema_hall_id 
WHERE s."date" = date_;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_movie_date('2023-12-20');
    

--Получение списка забронированных билетов (с указанием полной информации по сеансу) для аннулирования
CREATE OR REPLACE FUNCTION get_booking_ticket() 
RETURNS TABLE 
(
    ticket_id INT,
    movie VARCHAR,
    date DATE,
    time_start TIME, 
    cinema_hall VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
    t.ticket_id,
    m."name" AS movie,
    s."date",
    s.time_start,
    ch."name" AS cinema_hall
FROM public.ticket t 
    JOIN public.schedule s ON t.schedule_id = s.schedule_id 
    JOIN public.booking b ON t.booking_id = b.booking_id 
    JOIN public.movie m ON s.movie_id = m.movie_id 
    JOIN public.cinema_hall ch ON s.cinema_hall_id = ch.cinema_hall_id
    JOIN public.customer c ON t.customer_id = c.customer_id 
WHERE b.flag = TRUE;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_booking_ticket();

--Определение трех самых посещаемых фильмов для каждого зала.
WITH movie_visits AS (
    SELECT
        m."name" AS movie_name,
        ch."name" AS cinema_hall_name,
        COUNT(t.ticket_id) AS visit_count
    FROM public.ticket t
    JOIN public.schedule s ON t.schedule_id = s.schedule_id
    JOIN public.movie m ON s.movie_id = m.movie_id
    JOIN public.cinema_hall ch ON s.cinema_hall_id = ch.cinema_hall_id
    GROUP BY m."name", ch."name"
),
ranked_movies AS (
    SELECT
        mv.movie_name,
        mv.cinema_hall_name,
        mv.visit_count,
        ROW_NUMBER() OVER (PARTITION BY mv.cinema_hall_name ORDER BY mv.visit_count DESC) AS rnk
    FROM movie_visits mv
)
SELECT
    rm.cinema_hall_name,
    rm.movie_name,
    rm.visit_count
FROM ranked_movies rm
WHERE rm.rnk <= 3
ORDER BY rm.cinema_hall_name, rm.visit_count DESC;
 