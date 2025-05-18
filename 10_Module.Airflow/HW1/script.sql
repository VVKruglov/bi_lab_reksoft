--создание схемы raw и таблицы raw.olympics

CREATE SCHEMA raw;

CREATE TABLE raw.olympics
(
    City TEXT,
    Edition INT,
    Sport TEXT,
    Discipline TEXT,
    Athlete TEXT,
    NOC TEXT,
    Gender TEXT,
    Event TEXT,
    Event_gender TEXT,
    Medal TEXT
);


--создание схемы dds и таблицы dds.olympics

CREATE SCHEMA dds;

CREATE TABLE dds.olympics
(
    Country TEXT,
    First_medal_date INT,
    Last_medal_date INT,
    Count_of_medals INT
);


--создание схемы etl и процедуры etl.usp_dds_olympics_insert

CREATE SCHEMA etl;

CREATE OR REPLACE PROCEDURE etl.usp_dds_olympics_insert()
LANGUAGE plpgsql
AS $$
BEGIN
   
    TRUNCATE TABLE dds.olympics;

    
    INSERT INTO dds.olympics (Country, First_medal_date, Last_medal_date, Count_of_medals)
    SELECT
        olymp.NOC,
        MIN(olymp.Edition) AS First_medal_date, 
        MAX(olymp.Edition) AS Last_medal_date,   
        COUNT(olymp.Medal) AS Count_of_medals  
    FROM raw.olympics AS olymp
    GROUP BY olymp.NOC 
    ORDER BY olymp.NOC;

    RAISE NOTICE 'Procedure etl.usp_dds_olympics_insert completed successfully.';
END;
$$;


--создание схемы dm и представления dm.olympics, которая выводит дланные из dds.olympics

CREATE SCHEMA dm;

CREATE VIEW dm.olympics
AS 
SELECT
    olimp.Country,
    olimp.First_medal_date,
    olimp.Last_medal_date,
    olimp.Count_of_medals
FROM dds.olympics AS olimp; 



SELECT * FROM dm.olympics;

 