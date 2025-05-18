TRUNCATE TABLE public.customer, public.booking, public.movie, public.cinema_hall, public.schedule, public.ticket RESTART IDENTITY CASCADE;


INSERT INTO public.customer (first_name, last_name, phone, email)
VALUES
('Ivan', 'Ivanov', '+123456789', 'ivan.ivanov@ex.com'),
('Anna', 'Fedorova', '+123856789', 'anna.fedorova@ex.com'),
('Elena', 'Belova', '+523456789', 'elena.belova@ex.com'),
('Anton', 'Sidorov', '+823456789', 'anton.sidorov@ex.com'),
('Petr', 'Petrov', '+987654321', 'petr.petrov@ex.com');


INSERT INTO public.booking (flag)
VALUES
(TRUE),
(FALSE),
(NULL);


INSERT INTO public.movie (name, release_date, genre, during_in_min)
VALUES
('Puss in boots', '2022-12-15', 'Cartoon', 125),
('The matrix', '1999-12-15', 'Action', 150);


INSERT INTO public.cinema_hall (name, "type")
VALUES
('1', 'Standart'),
('2', 'VIP'),
('3', 'I-MAX');


INSERT INTO public.schedule (date, time_start, time_finish, movie_id, cinema_hall_id)
VALUES
('2023-12-20', '12:00:00', '14:05:00', 1, 1), 
('2023-12-20', '15:00:00', '17:30:00', 2, 2), 
('2023-12-21', '12:00:00', '14:05:00', 1, 3),
('2023-12-21', '20:30:00', '23:00:00', 2, 1);


INSERT INTO public.ticket (price, place, customer_id, schedule_id, booking_id)
VALUES
(400, 'A1', 1, 1, 1),
(600, 'B2', 2, 2, 2),
(500, 'C3', 3, 3, 2),
(400, 'D4', 4, 4, 2);  