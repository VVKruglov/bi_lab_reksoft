/*Напишите запросы для добавления в каждую таблицу добавьте не менее 2 записей. 
 Дополнительно, нескольким читателям необходимо выдать
 книги и вернуть книги от одного читателя.*/

INSERT INTO author (first_name, last_name, nationality, date_of_birth)
VALUES ('Lev', 'Ermakov', 'Russian', '1973-05-07');

INSERT INTO author (first_name, last_name, nationality, date_of_birth, date_of_death)
VALUES ('Robert', 'Black', 'American', '1925-05-07', '1986-09-25');


INSERT INTO genre ("name")
VALUES ('science');

INSERT INTO genre ("name")
VALUES ('fantasy');


INSERT INTO "work" (title, craeated_date, genre_id)
VALUES ('History of the Pacific War', '2005-02-07', 1);

INSERT INTO "work" (title, craeated_date, genre_id)
VALUES ('King of the seas', '1967-06-12', 2);

INSERT INTO "work" (title, craeated_date, genre_id)
VALUES ('Sunrise', '1950-06-12', 2);

INSERT INTO book  (name, publishing_house, published_date)
VALUES ('History of the Second World War', 'Universe', '2006-09-20');

INSERT INTO book  (name, publishing_house, published_date)
VALUES ('King of the seas', 'Magic world', '2019-10-06');

INSERT INTO book  (name, publishing_house, published_date)
VALUES ('Sunrise', 'Pink door', '2015-10-06');


INSERT INTO book_work (book_id, work_id)
VALUES (1, 1);

INSERT INTO book_work (book_id, work_id)
VALUES (2, 2);

INSERT INTO book_work (book_id, work_id)
VALUES (3, 3);


INSERT INTO author_work (author_id, work_id)
VALUES (1, 1);

INSERT INTO author_work (author_id, work_id)
VALUES (2, 1);

INSERT INTO author_work (author_id, work_id)
VALUES (3, 2);

INSERT INTO author_work (author_id, work_id)
VALUES (3, 3);


INSERT INTO reader (first_name, last_name, phone_number, email, registration_date)
VALUES ('Ivan', 'Smirnov', '89904521223', 'smir@mail.ru', '2023-01-05');

INSERT INTO reader (first_name, last_name, phone_number, email, registration_date)
VALUES ('Anna', 'Ivanova', '89904577723', 'ivanova98@mail.ru', '2024-06-02');


INSERT INTO "order" (taken_date, return_date, book_id, reader_id)
VALUES ('2024-09-23', '2024-10-25', 1, 2); --вернул книгу

INSERT INTO "order" (taken_date, book_id, reader_id)
VALUES ('2024-10-03', 2, 1);


/*Напишите запрос для удаления всех данных из всех таблиц, используя команду DELETE.
При этом внешние ключи должны быть включены. После удаления данных, 
все идентификаторы в таблицах нужно сбросить на 1 
(при вставке в пустую таблицу, первая запись должна вставиться с идентификатором = 1).*/

DO $$
BEGIN
PERFORM set_config('session_replication_role', 'replica', true);
DELETE FROM author;
ALTER SEQUENCE public.author_author_id_seq RESTART WITH 1;
PERFORM set_config('session_replication_role', 'origin', true);
END
$$


DO $$
BEGIN
PERFORM set_config('session_replication_role', 'replica', true);
DELETE FROM genre;
ALTER SEQUENCE public.genre_genre_id_seq RESTART WITH 1;
PERFORM set_config('session_replication_role', 'origin', true);
END 
$$;

DO $$
BEGIN
PERFORM set_config('session_replication_role', 'replica', true);
DELETE FROM "work";
ALTER SEQUENCE public.work_work_id_seq RESTART WITH 1;
PERFORM set_config('session_replication_role', 'origin', true);
END 
$$;

DO $$
BEGIN
PERFORM set_config('session_replication_role', 'replica', true);
DELETE FROM book;
ALTER SEQUENCE public.book_book_id_seq RESTART WITH 1;
PERFORM set_config('session_replication_role', 'origin', true);
END 
$$;

DO $$
BEGIN
PERFORM set_config('session_replication_role', 'replica', true);
DELETE FROM reader;
ALTER SEQUENCE public.reader_reader_id_seq RESTART WITH 1;
PERFORM set_config('session_replication_role', 'origin', true);
END 
$$;

DO $$
BEGIN
PERFORM set_config('session_replication_role', 'replica', true);
DELETE FROM "order";
ALTER SEQUENCE public.order__order_id_seq RESTART WITH 1;
PERFORM set_config('session_replication_role', 'origin', true);
END 
$$;

DO $$
BEGIN
PERFORM set_config('session_replication_role', 'replica', true);
DELETE FROM author_work;
PERFORM set_config('session_replication_role', 'origin', true);
END 
$$;

DO $$
BEGIN
PERFORM set_config('session_replication_role', 'replica', true);
DELETE FROM book_work;
PERFORM set_config('session_replication_role', 'origin', true);
END 
$$;


/*Напишите запрос для удаления всех данных из таблиц, используя команду TRUNCATE. 
Все внешние ключи нужно удалить до очистки и затем создать заново.*/


TRUNCATE author CASCADE;

TRUNCATE genre CASCADE;

DO $$
BEGIN
ALTER TABLE "work"
DROP CONSTRAINT work_genre_id_fkey;
TRUNCATE "work" CASCADE;
ALTER TABLE "work"
ADD CONSTRAINT work_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES genre(genre_id);
END
$$;

TRUNCATE book CASCADE;

TRUNCATE reader CASCADE;

DO $$
BEGIN
ALTER TABLE "order" 
DROP CONSTRAINT order__book_id_fkey,
DROP CONSTRAINT order__reader_id_fkey;
TRUNCATE "order" CASCADE;
ALTER TABLE "order" 
ADD CONSTRAINT order__book_id_fkey FOREIGN KEY (book_id) REFERENCES book(book_id),
ADD CONSTRAINT order__reader_id_fkey FOREIGN KEY (reader_id) REFERENCES reader(reader_id);
END
$$;

DO $$
BEGIN
ALTER TABLE author_work 
DROP CONSTRAINT author_work_author_id_fkey,
DROP CONSTRAINT author_work_work_id_fkey;
TRUNCATE author_work CASCADE;
ALTER TABLE author_work 
ADD CONSTRAINT author_work_author_id_fkey FOREIGN KEY (author_id) REFERENCES author(author_id),
ADD CONSTRAINT author_work_work_id_fkey FOREIGN KEY (work_id) REFERENCES work(work_id);
END
$$;

DO $$
BEGIN
ALTER TABLE book_work 
DROP CONSTRAINT book_work_book_id_fkey,
DROP CONSTRAINT book_work_work_id_fkey;
TRUNCATE book_work CASCADE;
ALTER TABLE book_work 
ADD CONSTRAINT book_work_book_id_fkey FOREIGN KEY (book_id) REFERENCES book(book_id),
ADD CONSTRAINT book_work_work_id_fkey FOREIGN KEY (work_id) REFERENCES work(work_id);
END
$$;
