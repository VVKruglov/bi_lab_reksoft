DROP TABLE IF EXISTS public.customer CASCADE; 

CREATE TABLE IF NOT EXISTS public.customer
(
customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
phone VARCHAR(20),
email VARCHAR(100),
CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,5}$'),
CHECK (phone ~ '^[0-9+() -]{6,20}$')
);


DROP TABLE IF EXISTS public.booking CASCADE; 

CREATE TABLE IF NOT EXISTS public.booking
(
booking_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
flag BOOLEAN
);


DROP TABLE IF EXISTS public.movie CASCADE; 

CREATE TABLE IF NOT EXISTS public.movie
(
movie_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
name VARCHAR(50) NOT NULL,
release_date DATE NOT NULL,
genre VARCHAR(50) NOT NULL,
during_in_min INT NOT NULL
);


DROP TABLE IF EXISTS public.cinema_hall CASCADE; 

CREATE TABLE IF NOT EXISTS public.cinema_hall
(
cinema_hall_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
name VARCHAR(50) NOT NULL,
type VARCHAR(50) NOT NULL
);


DROP TABLE IF EXISTS public.schedule CASCADE;

CREATE TABLE IF NOT EXISTS public.schedule
(
schedule_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
date DATE NOT NULL,
time_start TIME NOT NULL,
time_finish TIME NULL NULL,
movie_id INT NOT NULL,
cinema_hall_id INT NOT NULL,
FOREIGN KEY (movie_id) REFERENCES public.movie(movie_id),
FOREIGN KEY (cinema_hall_id) REFERENCES public.cinema_hall(cinema_hall_id)
);


DROP TABLE IF EXISTS public.ticket CASCADE;

CREATE TABLE IF NOT EXISTS public.ticket
(
ticket_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
price MONEY NOT NULL,
place VARCHAR(50) NOT NULL,
customer_id INT NOT NULL,
schedule_id INT NOT NULL,
booking_id INT NOT NULL,
FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id),
FOREIGN KEY (schedule_id) REFERENCES public.schedule(schedule_id),
FOREIGN KEY (booking_id) REFERENCES public.booking(booking_id)
);
