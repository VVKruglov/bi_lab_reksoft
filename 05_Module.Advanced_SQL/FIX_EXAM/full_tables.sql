TRUNCATE TABLE public.customer, public.booking, public.movie, public.cinema_hall, public.schedule, public.movie_session, public.ticket RESTART IDENTITY CASCADE;


INSERT INTO public.customer (first_name, last_name, phone, email) VALUES
('Anna', 'Iavanova', '+123456789', 'anna@example.com'),
('Ivan', 'Petrov', '+987654321', 'ivan@example.com'),
('Anton', 'Chernov', '+555666777', 'anton@example.com');


INSERT INTO public.booking (flag) VALUES
(TRUE),
(FALSE),
(NULL);


INSERT INTO public.movie (name, release_date, genre, during_in_min) VALUES
('The Avengers', '2012-05-04', 'Action', 143),
('Inception', '2010-07-16', 'Sci-Fi', 148),
('The Matrix', '1999-03-31', 'Sci-Fi', 136);


INSERT INTO public.cinema_hall (name, type, quantity_place) VALUES
('Hall 1', 'IMAX', 120),
('Hall 2', 'Standard', 80),
('Hall 3', '3D', 100);


INSERT INTO public.schedule (date_time_start, movie_id, cinema_hall_id) VALUES
('2024-12-25 15:00:00', 1, 1), 
('2024-12-25 18:00:00', 2, 2),
('2024-12-25 20:00:00', 3, 3);


INSERT INTO public.movie_session (schedule_id) VALUES
(1),
(2), 
(3); 


INSERT INTO public.ticket (price, place, customer_id, movie_session_id, booking_id) VALUES
(400.50, 'A1', 1, 1, 1), 
(350.00, 'B2', 2, 2, 2),
(500.00, 'C3', 3, 3, 2);

