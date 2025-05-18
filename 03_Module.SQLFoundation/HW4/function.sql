/*Напишите функцию «library.udf_book_by_author_report» с параметром «author», 
которая вернет список доступных для выдачи книг с произведениями, 
написанными указанным автором. В вывод функции добавьте колонки: «book_title», «work», «book_reg_number».*/

CREATE OR REPLACE FUNCTION "library.udf_book_by_author_report" (IN author VARCHAR)
RETURNS TABLE(
    book_title VARCHAR,
    "work" VARCHAR,
    book_reg_number INT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        b."name" AS book_title,
        w.title AS "work",
        b.book_id AS book_reg_number
    FROM
        library.author a
    JOIN library.author_work aw ON
        a.author_id = aw.author_id
    JOIN library."work" w ON
        aw.work_id = w.work_id
    JOIN library.book_work bw ON
        w.work_id = bw.work_id
    JOIN library.book b ON
        bw.book_id = b.book_id
    LEFT JOIN library."order" o ON
        b.book_id = o.book_id
    WHERE
        (LOWER(a.first_name || ' ' || a.last_name) = LOWER(author)
         OR LOWER(a.last_name) = LOWER(author))
        AND NOT EXISTS (
            SELECT
                1
            FROM
                library."order" o
            WHERE 
                o.return_date IS NULL
        );
END;
$$ LANGUAGE plpgsql;


SELECT * FROM "library.udf_book_by_author_report"('Black')

