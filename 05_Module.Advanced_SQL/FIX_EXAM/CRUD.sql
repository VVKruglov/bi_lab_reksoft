CREATE OR REPLACE FUNCTION public.create_schedule(
    p_date_time_start TIMESTAMP,
    p_movie_id INT,
    p_cinema_hall_id INT
) 
RETURNS VOID 
AS $$
BEGIN
    INSERT INTO public.schedule (date_time_start, movie_id, cinema_hall_id)
    VALUES (p_date_time_start, p_movie_id, p_cinema_hall_id);
END;
$$ LANGUAGE plpgsql;

SELECT public.create_schedule('2024-12-25 18:00:00', 1, 2);


CREATE OR REPLACE FUNCTION public.get_all_schedules()
RETURNS TABLE 
(
    schedule_id INT,
    date_time_start TIMESTAMP,
    movie_name TEXT,
    cinema_hall_name TEXT
) 
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.schedule_id,
        s.date_time_start,
        m.name AS movie_name,
        ch.name AS cinema_hall_name
    FROM public.schedule s
    INNER JOIN public.movie AS m ON s.movie_id = m.movie_id
    INNER JOIN public.cinema_hall AS ch ON s.cinema_hall_id = ch.cinema_hall_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM public.get_all_schedules();


CREATE OR REPLACE FUNCTION public.get_schedules_by_date(p_date DATE)
RETURNS TABLE 
(
    schedule_id INT,
    date_time_start TIMESTAMP,
    movie_name TEXT,
    cinema_hall_name TEXT
) 
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.schedule_id,
        s.date_time_start,
        m.name AS movie_name,
        ch.name AS cinema_hall_name
    FROM public.schedule s
    INNER JOIN public.movie AS m ON s.movie_id = m.movie_id
    INNER JOIN public.cinema_hall AS ch ON s.cinema_hall_id = ch.cinema_hall_id
    WHERE s.date_time_start::DATE = p_date;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM public.get_schedules_by_date('2024-12-25');


CREATE OR REPLACE FUNCTION public.update_schedule(
    p_schedule_id INT,
    p_date_time_start TIMESTAMP,
    p_movie_id INT,
    p_cinema_hall_id INT
) 
RETURNS VOID 
AS $$
BEGIN
    UPDATE public.schedule
    SET 
        date_time_start = p_date_time_start,
        movie_id = p_movie_id,
        cinema_hall_id = p_cinema_hall_id
    WHERE schedule_id = p_schedule_id;
END;
$$ LANGUAGE plpgsql;

SELECT public.update_schedule(1, '2024-12-26 20:00:00', 2, 3);


CREATE OR REPLACE FUNCTION public.delete_schedule(p_schedule_id INT)
RETURNS VOID
AS $$
BEGIN
    DELETE FROM public.movie_session
    WHERE schedule_id = p_schedule_id;
    DELETE FROM public.schedule
    WHERE schedule_id = p_schedule_id;
END;
$$ LANGUAGE plpgsql;

SELECT public.delete_schedule(4);