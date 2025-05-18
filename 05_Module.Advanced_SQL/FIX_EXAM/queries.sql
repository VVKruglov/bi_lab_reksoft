--Получение дневного расписания сеансов на указанную дату
CREATE OR REPLACE FUNCTION public.get_movie_date(p_date DATE) 
RETURNS TABLE 
(
    movie TEXT,
    date TIMESTAMP,  
    cinema_hall TEXT
) 
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m."name" AS movie,
        s.date_time_start, 
        ch."name" AS cinema_hall
    FROM public.schedule AS s 
        INNER JOIN public.movie AS m ON s.movie_id = m.movie_id 
        INNER JOIN public.cinema_hall AS ch ON s.cinema_hall_id = ch.cinema_hall_id 
    WHERE s.date_time_start::DATE = p_date;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM public.get_movie_date('2024-12-25');
    

--Получение списка забронированных билетов (с указанием полной информации по сеансу) для аннулирования
CREATE OR REPLACE FUNCTION get_booking_ticket() 
RETURNS TABLE 
(
    ticket_id INT,
    movie TEXT,
    date TIMESTAMP, 
    cinema_hall TEXT
) 
AS $$
BEGIN
    RETURN QUERY
    SELECT
    t.ticket_id,
    m."name" AS movie,
    s.date_time_start,
    ch."name" AS cinema_hall
FROM public.ticket t 
    INNER JOIN public.movie_session AS ms ON t.movie_session_id = ms.movie_session_id
    INNER JOIN public.schedule AS s ON ms.schedule_id = s.schedule_id 
    INNER JOIN public.booking AS b ON t.booking_id = b.booking_id 
    INNER JOIN public.movie AS m ON s.movie_id = m.movie_id 
    INNER JOIN public.cinema_hall AS ch ON s.cinema_hall_id = ch.cinema_hall_id
    INNER JOIN public.customer AS c ON t.customer_id = c.customer_id 
WHERE b.flag = TRUE;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_booking_ticket();


 
--Определение трех самых посещаемых фильмов для каждого зала.
CREATE OR REPLACE VIEW get_top_three_popelar_movies
AS
WITH movie_visits AS (
    SELECT
        m."name" AS movie_name,
        ch."name" AS cinema_hall_name,
        COUNT(t.ticket_id) AS visit_count
    FROM public.ticket t 
    INNER JOIN public.movie_session AS ms ON t.movie_session_id = ms.movie_session_id
    INNER JOIN public.schedule AS s ON ms.schedule_id = s.schedule_id 
    INNER JOIN public.movie AS m ON s.movie_id = m.movie_id 
    INNER JOIN public.cinema_hall AS ch ON s.cinema_hall_id = ch.cinema_hall_id
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

SELECT * FROM get_top_three_popelar_movies;





 