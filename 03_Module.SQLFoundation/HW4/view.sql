/*Создайте представление (view) «library.vw_book_on_hand_report», 
которое отобразит все книги, выданные читателям на текущую дату. 
В представление добавьте колонки: «reader_name», 
«book_title», «book_reg_number», «issue_date», «days_on_hands» (количество полных дней).*/

CREATE VIEW "library.vw_book_on_hand_report"
AS 
SELECT
    r.first_name || ' ' || r.last_name AS readerd_name,
    b.name AS book_title,
    b.book_id AS book_reg_number,
    o.taken_date AS issue_date,
    DATE_PART('day', CURRENT_DATE - o.taken_date) AS days_on_hands
FROM
    book b
JOIN "order" o ON
    b.book_id = o.book_id
JOIN reader r ON
    o.reader_id = r.reader_id
WHERE
    o.return_date IS NULL

SELECT *
FROM "library.vw_book_on_hand_report"