/*Задания на использование CUBE:
  
 
Создайте куб по странам, городам, заказчикам, трем месяцам, 
категории продукта, подкатегории продукта, продукту, каналам, промокатегории.

Выставьте фильтры до 5-ти, но так, чтобы данных в итоговой таблице для 
ответа на вопрос было больше двух.

Решите задачи (таблица должна давать ответ на вопрос):
*/


--Самый покупающий заказчик в городе
WITH ranked_sales AS (
    SELECT
        c.country_name,                          
        cus.cust_city,                           
        cus.cust_id AS customer_id, 
        t.calendar_month_desc,                  
        p.prod_category,                        
        p.prod_subcategory,                      
        p.prod_name,                             
        ch.channel_desc,                        
        prom.promo_category,                     
        SUM(s.amount_sold) AS total_amount_sold,
        ROW_NUMBER() OVER (
            PARTITION BY c.country_name, cus.cust_city 
            ORDER BY SUM(s.amount_sold) DESC
        ) AS rank_per_city,
        GROUPING(
            c.country_name,                          
            cus.cust_city,                           
            cus.cust_id, 
            t.calendar_month_desc,                  
            p.prod_category,                        
            p.prod_subcategory,                     
            p.prod_name,                             
            ch.channel_desc,                        
            prom.promo_category
        ) AS grps
    FROM sh.countries c                                                  
    JOIN sh.customers cus   ON c.country_id = cus.country_id               
    JOIN sh.sales s         ON cus.cust_id = s.cust_id                           
    JOIN sh.channels ch     ON s.channel_id = ch.channel_id                  
    JOIN sh.products p      ON s.prod_id = p.prod_id                         
    JOIN sh.times t         ON s.time_id = t.time_id                             
    JOIN sh.promotions prom ON s.promo_id = prom.promo_id
    WHERE
        c.country_name IN ('United States of America', 'France', 'United Kingdom')
        AND t.calendar_month_desc IN ('2000-04', '2000-05', '2000-06')
        AND ch.channel_class IN('Direct', 'Others')
        AND p.prod_category IN ('Men', 'Women')
        AND prom.promo_category = 'NO PROMOTION'
    GROUP BY 
        CUBE(
            c.country_name,
            cus.cust_city,                                                   
            cus.cust_id,
            t.calendar_month_desc,                                         
            p.prod_category,                                                 
            p.prod_subcategory,                                              
            p.prod_name,                                                     
            ch.channel_desc,                                                 
            prom.promo_category
        )
    HAVING GROUPING(
        c.country_name,
        cus.cust_city,                                                   
        cus.cust_id,
        t.calendar_month_desc,                                         
        p.prod_category,                                                 
        p.prod_subcategory,                                              
        p.prod_name,                                                     
        ch.channel_desc,                                                 
        prom.promo_category
    ) IN (319)
)
SELECT
    customer_id,
    cust_city,
    total_amount_sold
FROM ranked_sales
WHERE rank_per_city = 1
ORDER BY 
    cust_city, 
    total_amount_sold DESC;



--Продукт на который заказчик готов тратить больше всего денег
WITH ranked_products AS (
    SELECT
        c.country_name,                          
        cus.cust_city,                           
        cus.cust_id AS customer_id,
        t.calendar_month_desc,                  
        p.prod_category,                        
        p.prod_subcategory,                      
        p.prod_name,                             
        ch.channel_desc,                        
        prom.promo_category,                     
        SUM(s.amount_sold) AS total_amount_sold,
        GROUPING(
            c.country_name,                          
            cus.cust_city,                           
            cus.cust_id,
            t.calendar_month_desc,                  
            p.prod_category,                        
            p.prod_subcategory,                     
            p.prod_name,                             
            ch.channel_desc,                        
            prom.promo_category
        ) AS grps,
        ROW_NUMBER() OVER (
            PARTITION BY cus.cust_id
            ORDER BY SUM(s.amount_sold) DESC
        ) AS rank_per_customer
    FROM sh.countries c                                                  
    JOIN sh.customers cus   ON c.country_id = cus.country_id               
    JOIN sh.sales s         ON cus.cust_id = s.cust_id                           
    JOIN sh.channels ch     ON s.channel_id = ch.channel_id                  
    JOIN sh.products p      ON s.prod_id = p.prod_id                         
    JOIN sh.times t         ON s.time_id = t.time_id                             
    JOIN sh.promotions prom ON s.promo_id = prom.promo_id
    WHERE
        c.country_name IN ('United States of America', 'France', 'United Kingdom')
        AND t.calendar_month_desc IN ('2000-04', '2000-05', '2000-06')
        AND ch.channel_class IN('Direct', 'Others')
        AND p.prod_category IN ('Men', 'Women')
        AND prom.promo_category = 'NO PROMOTION'
    GROUP BY 
        CUBE(
            c.country_name,
            cus.cust_city,                                                   
            cus.cust_id,
            t.calendar_month_desc,                                         
            p.prod_category,                                                 
            p.prod_subcategory,                                              
            p.prod_name,                                                     
            ch.channel_desc,                                                 
            prom.promo_category
        )
    HAVING GROUPING(
        c.country_name,
        cus.cust_city,                                                   
        cus.cust_id,
        t.calendar_month_desc,                                         
        p.prod_category,                                                 
        p.prod_subcategory,                                              
        p.prod_name,                                                     
        ch.channel_desc,                                                 
        prom.promo_category
    ) IN (443)
)
SELECT
    customer_id,
    prod_name,
    total_amount_sold
FROM ranked_products
WHERE rank_per_customer = 1
ORDER BY 
    total_amount_sold DESC;



--Продажи за месяц и составляющие этого месяца по каналам, промокатегории и страны
SELECT
    c.country_name,                          
    cus.cust_city,                           
    cus.cust_id AS customer_id, 
    t.calendar_month_desc,                  
    p.prod_category,                        
    p.prod_subcategory,                      
    p.prod_name,                             
    ch.channel_desc,                        
    prom.promo_category,                     
    SUM(s.amount_sold) AS total_amount_sold,
    GROUPING(
        c.country_name,
        cus.cust_city, 
        cus.cust_id,
        t.calendar_month_desc, 
        p.prod_category, 
        p.prod_subcategory, 
        p.prod_name, 
        ch.channel_desc, 
        prom.promo_category
    ) AS grouping_id
FROM sh.countries c                                                  
JOIN sh.customers cus   ON c.country_id = cus.country_id               
JOIN sh.sales s         ON cus.cust_id = s.cust_id                           
JOIN sh.channels ch     ON s.channel_id = ch.channel_id                  
JOIN sh.products p      ON s.prod_id = p.prod_id                         
JOIN sh.times t         ON s.time_id = t.time_id                             
JOIN sh.promotions prom ON s.promo_id = prom.promo_id
WHERE
    c.country_name = 'United States of America'  
    AND t.calendar_month_desc = '2000-05' 
    AND p.prod_category IN ('Men', 'Women')
GROUP BY 
    CUBE(
        c.country_name,
        cus.cust_city, 
        cus.cust_id,
        t.calendar_month_desc, 
        p.prod_category, 
        p.prod_subcategory, 
        p.prod_name, 
        ch.channel_desc, 
        prom.promo_category
    )
HAVING GROUPING(
        c.country_name,
        cus.cust_city, 
        cus.cust_id,
        t.calendar_month_desc, 
        p.prod_category, 
        p.prod_subcategory, 
        p.prod_name, 
        ch.channel_desc, 
        prom.promo_category
    ) IN (220, 221, 222, 223)  
ORDER BY 
    grouping_id DESC,
    prom.promo_category;



/*Задания на использование WINDOW FUNCTIONS:
 
 
Для выполнения заданий используйте базу SalesHistoryDB:


Создать числовой ключ для таблицы со справочником стран.
Задача: заполнить во временной таблице стран (my_countries) числовое поле 
id уникальными последовательными значениями, начиная с 10.*/


DROP TABLE IF EXISTS my_countries;

SELECT 
    ROW_NUMBER () OVER () + 9 AS id, 
    c.country_id, 
    c.country_name,
    c.country_subregion,
    c.country_region
INTO TEMPORARY my_countries
FROM  sh.countries c;

SELECT *
FROM my_countries;


/*Удалить дубликаты из справочника стран.
Задача: удалить дубликаты из временной таблицы стран (my_countries)
 на основании значения поля country_id.*/

DROP TABLE IF EXISTS my_countries;

SELECT gen_random_uuid() as id, c.*
INTO TEMPORARY my_countries
FROM sh.countries c
UNION ALL
SELECT gen_random_uuid(), c.*
FROM sh.countries c
UNION ALL
SELECT gen_random_uuid(), c.*
FROM sh.countries c;

WITH ranked_countries AS (
    SELECT 
        id,
        country_id,
        ROW_NUMBER() OVER (PARTITION BY country_id ORDER BY id) AS row_num
    FROM my_countries
)
DELETE FROM my_countries
WHERE 
    id IN (
    SELECT id
    FROM ranked_countries
    WHERE 
        row_num > 1
);

SELECT * FROM my_countries;



/*Отбор N первых значений по подгруппам.

Задача: Вывести названия трёх товаров, которые были проданы в максимальном 
количестве в последней (по времени) дате заказа для каждого из каналов продаж.*/

WITH ranked_products AS (
    SELECT
        ch.channel_desc,
        p.prod_name,
        s.quantity_sold,
        s.time_id,
        ROW_NUMBER() OVER (
            PARTITION BY ch.channel_desc 
            ORDER BY s.time_id DESC, s.quantity_sold DESC, p.prod_name ASC
        ) AS rnk
    FROM sh.sales s
    JOIN sh.channels ch ON s.channel_id = ch.channel_id
    JOIN sh.products p ON s.prod_id = p.prod_id
)
SELECT
    rp.channel_desc,
    rp.prod_name,
    rp.quantity_sold
FROM ranked_products rp
WHERE rp.rnk <= 3
ORDER BY 
    rp.channel_desc, 
    rp.rnk;



/*Поиск «разрывов» в последовательности.

Задача: Найти границы «разрывов», т.е. диапазонов значений, не использованных 
(пропущенных) в последовательности, хранящейся в таблице. То есть для последовательности,
 созданной в подготовительных действиях, ожидается следующий результат:

Начало диапазона    Конец диапазона
4                   6
10                  10
12                  14
18                  27*/


DROP TABLE IF EXISTS my_sequence;

CREATE TEMP TABLE my_sequence
(
    col1 int NOT NULL PRIMARY KEY
);

INSERT INTO my_sequence (col1)
    VALUES (2),(3),(7),(8),(9),(11),(15),(16),(17),(28);


WITH ranked_sequence AS
(
SELECT
    ms.col1,
    LAG (col1) OVER (ORDER BY ms.col1) AS number
FROM my_sequence ms
)
SELECT
      rs.number + 1 AS range_start,
      rs.col1 - 1 AS range_finish
FROM ranked_sequence rs
WHERE
    rs.col1 - rs.number > 1;
   
    
    
/*Поиск «занятых» диапазонов в последовательности.

Задача: Найти границы диапазонов, использованных значений.
То есть для последовательности, созданной в подготовительных действиях,
ожидается следующий результат:

Начало диапазона    Конец диапазона
2                   3
7                   9
11                  11
15                  17
28                  28*/


DROP TABLE IF EXISTS my_sequence;

CREATE TEMP TABLE my_sequence
(
    col1 int NOT NULL PRIMARY KEY
);

INSERT INTO  my_sequence (col1)
    VALUES (2),(3),(7),(8),(9),(11),(15),(16),(17),(28);


WITH ranked_sequence AS 
(
    SELECT
        col1,
        col1 - ROW_NUMBER() OVER (ORDER BY col1) AS number 
    FROM my_sequence
),
ranges AS 
(
    SELECT
        MIN(rs.col1) AS range_start, 
        MAX(rs.col1) AS range_finish 
    FROM ranked_sequence rs
    GROUP BY 
        rs.number 
)
SELECT
    r.range_start,
    r.range_finish
FROM ranges r
ORDER BY 
    range_start;




--Для выполнения заданий используйте базу DB_dvdrental:

/*Вывести страны, города, адреса покупателей из этих городов, 
общее количество покупателей для каждой страны, какой процент покупателей от 
общего числа составляют покупатели из этой страны (округлить значение до 4-х знаков после запятой). 
Решите задачу используя оконные функции*/

SELECT
    c.country, 
    ct.city,
    a.address,
    COUNT(cus.customer_id) OVER (PARTITION BY c.country) AS total_customers_for_country,
   ROUND(((COUNT(cus.customer_id) OVER (PARTITION BY c.country)) * 100.0 / (SELECT COUNT(cus.customer_id)
                                                                            FROM public.customer cus)), 4) AS persent
FROM public.country c 
    JOIN public.city ct ON c.country_id = ct.country_id 
    JOIN public.address a ON ct.city_id = a.city_id 
    JOIN public.customer cus ON a.address_id = cus.address_id
ORDER BY 
    persent, 
    c.country DESC;

 
    
/*Для каждого актёра вывести ID, имя, фамилию, самый ранний фильм и самый 
последний фильм, в котором они снимались (по году релиза фильма).*/

WITH films AS
(
SELECT
    a.actor_id,
    a.first_name, 
    a.last_name,
    f.title,
    ROW_NUMBER () OVER (PARTITION BY a.actor_id ORDER BY f.release_year) AS first_film,
    ROW_NUMBER () OVER (PARTITION BY a.actor_id ORDER BY f.release_year DESC) AS last_film
FROM public.actor a 
    JOIN public.film_actor fa ON a.actor_id = fa.actor_id 
    JOIN public.film f ON fa.film_id = f.film_id 
)
SELECT 
    f.actor_id,
    f.first_name, 
    f.last_name,
    MIN(CASE 
            WHEN f.first_film = 1 THEN f.title
        END
        ) AS first_film,
    MAX(CASE 
            WHEN f.last_film = 1 THEN f.title
        END
        ) AS last_film
FROM films f
GROUP BY 
    f.actor_id,
    f.first_name, 
    f.last_name
ORDER BY 
    f.actor_id;