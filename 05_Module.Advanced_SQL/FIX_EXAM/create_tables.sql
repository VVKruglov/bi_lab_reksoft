DROP TABLE IF EXISTS public.customer CASCADE; 

CREATE TABLE IF NOT EXISTS public.customer (
    customer_id SERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    phone TEXT, 
    email TEXT,
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

CREATE TABLE IF NOT EXISTS public.movie (
    movie_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    release_date DATE NOT NULL,
    genre TEXT,
    during_in_min INT NOT NULL CHECK (during_in_min > 0)
);


DROP TABLE IF EXISTS public.cinema_hall CASCADE; 

CREATE TABLE IF NOT EXISTS public.cinema_hall (
    cinema_hall_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT,
    quantity_place INT NOT NULL CHECK (quantity_place > 0)
);


DROP TABLE IF EXISTS public.schedule CASCADE;

CREATE TABLE IF NOT EXISTS public.schedule (
    schedule_id SERIAL PRIMARY KEY,
    date_time_start TIMESTAMP NOT NULL,
    movie_id INT NOT NULL,
    cinema_hall_id INT NOT NULL,
    UNIQUE (date_time_start, movie_id, cinema_hall_id),
    FOREIGN KEY (movie_id) REFERENCES movie(movie_id),
    FOREIGN KEY (cinema_hall_id) REFERENCES cinema_hall(cinema_hall_id)
);

DROP TABLE IF EXISTS public.movie_session CASCADE;

CREATE TABLE IF NOT EXISTS public.movie_session (
    movie_session_id SERIAL PRIMARY KEY,
    schedule_id INT UNIQUE,
    FOREIGN KEY (schedule_id) REFERENCES schedule(schedule_id)
);


DROP TABLE IF EXISTS public.ticket CASCADE;

CREATE TABLE ticket (
    ticket_id SERIAL PRIMARY KEY,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    place TEXT NOT NULL,
    customer_id INT NOT NULL,
    movie_session_id INT NOT NULL,
    booking_id INT,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (movie_session_id) REFERENCES movie_session(movie_session_id),
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id)
);
