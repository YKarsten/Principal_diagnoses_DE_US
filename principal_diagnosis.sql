-- Data import
USE
    ICD_10_DE;

-- Import principal diagnosis data for Germany
-- Drop the table if it exists
DROP TABLE
    IF EXISTS diagnoses_DE;

-- Create the table with utf8mb4 character set
CREATE TABLE
    diagnoses_DE (
        ICD_10 VARCHAR(255),
        ICD_10_description VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci, -- mySQL default encoding doesn't support 'Umlaute'
        `2012` INT,
        `2013` INT,
        `2014` INT,
        `2015` INT,
        `2016` INT,
        `2017` INT,
        `2018` INT,
        `2019` INT,
        `2020` INT,
        `2021` INT
    );

-- Load data from CSV
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.1\\Uploads\\23131-0001_$F.csv' INTO TABLE diagnoses_DE
FIELDS TERMINATED BY ';' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 7 ROWS (
    ICD_10,
    @ICD_10_description,
    @`2012`,
    @`2013`,
    @`2014`,
    @`2015`,
    @`2016`,
    @`2017`,
    @`2018`,
    @`2019`,
    @`2020`,
    @`2021`
)
SET
    ICD_10_description = CONVERT(REPLACE(REPLACE(REPLACE(@ICD_10_description, '\xF6', 'oe'), '\xFC', 'ue'), '\xE4', 'ae'), CHAR),
    `2012` = NULLIF(@`2012`, '-'),
    `2013` = NULLIF(@`2013`, '-'),
    `2014` = NULLIF(@`2014`, '-'),
    `2015` = NULLIF(@`2015`, '-'),
    `2016` = NULLIF(@`2016`, '-'),
    `2017` = NULLIF(@`2017`, '-'),
    `2018` = NULLIF(@`2018`, '-'),
    `2019` = NULLIF(@`2019`, '-'),
    `2020` = NULLIF(@`2020`, '-'),
    `2021` = CASE
        WHEN TRIM(@`2021`) REGEXP '^[0-9]*\\.?[0-9]+$' THEN TRIM(@`2021`)
        ELSE NULL
    END;

-- Import population data for germany
-- Drop the table if it exists
DROP TABLE
    IF EXISTS population_DE;

CREATE TABLE population_DE(
    `year` YEAR,
    population INT
);

-- Load data from CSV
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.1\\Uploads\\DE_population.csv' INTO TABLE population_DE
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS (
    `Year`,
    @population
)
SET
    population = @population*1000000;

-- Import principal diagnosis data for USA
-- Drop the table if it exists
DROP TABLE IF EXISTS diagnoses_US;

-- Create the table with utf8mb4 character set
CREATE TABLE diagnoses_US (
    ICD_10 VARCHAR(255),
    ICD_10_description VARCHAR(255),
    `2020` INT,
    `2019` INT,
    `2018` INT,
    `2017` INT,
    `2016` INT
);

-- Load data from CSV, skipping the first 4 lines (metadata and headers)
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.1\\Uploads\\HCUP-NIS2016-2020-DXandPRfreqs.csv' INTO TABLE diagnoses_US
FIELDS TERMINATED BY '\t' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 8 LINES (
    ICD_10,
    ICD_10_description,
    @C,
    @D,
    @`2020`,
    @F,
    @G,
    @H,
    @`2019`,
    @J,
    @K,
    @L,
    @`2018`,
    @N,
    @O,
    @P,
    @`2017`,
    @R,
    @S,
    @T,
    @`2016`,
    @V,
    @W,
    @X
)
SET
    `2020` = NULLIF(REPLACE(REPLACE(@`2020`, '*', ''), ' ', ''), ''),
    `2019` = NULLIF(REPLACE(REPLACE(@`2019`, '*', ''), ' ', ''), ''),
    `2018` = NULLIF(REPLACE(REPLACE(@`2018`, '*', ''), ' ', ''), ''),
    `2017` = NULLIF(REPLACE(REPLACE(@`2017`, '*', ''), ' ', ''), ''),
    `2016` = NULLIF(REPLACE(REPLACE(@`2016`, '*', ''), ' ', ''), '');


-- Import population data for USA
DROP TABLE IF EXISTS population_US;

CREATE TABLE population_US (
    `Year` YEAR,
    Population INT
);

-- Load data from CSV
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.1\\Uploads\\NST-EST2020.csv' INTO TABLE population_US
FIELDS TERMINATED BY ';' LINES TERMINATED BY '\n' IGNORE 1 ROWS (
    `Year`,
    @Population
)
SET
    Population = REPLACE(@Population, ' ', '');

-------------

-- confirm the import by listing the column names
SHOW COLUMNS 
FROM diagnoses_DE;

SHOW COLUMNS  
FROM diagnoses_US;

SELECT * FROM 
population_DE;

SELECT * FROM 
population_US;

-- Select all groups of diseases
SELECT *
FROM diagnoses_DE
WHERE ICD_10 LIKE '%-%-%'
ORDER BY `2012` DESC;

------------
-- DE data
-- Diagnosis Rate per year among all diagnoses (wide format)
SELECT
    ICD_10,
    ICD_10_description,
    `2021` AS TotalCases2021,   
    (`2021` / (SELECT `2021` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate_2021,
    (`2020` / (SELECT `2020` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate_2020,
    (`2019` / (SELECT `2019` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate_2019,
    (`2018` / (SELECT `2018` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate_2018,
    (`2017` / (SELECT `2017` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate_2017,
    (`2016` / (SELECT `2016` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate_2016,
    (`2015` / (SELECT `2015` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate_2015,
    (`2014` / (SELECT `2014` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate_2014,
    (`2013` / (SELECT `2013` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate_2013,
    (`2012` / (SELECT `2012` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate_2012
FROM
    diagnoses_DE
WHERE ICD_10 NOT LIKE '%-%-%'
ORDER BY Diagnosis_Rate_2021 DESC
LIMIT 100;

-- Create a new view to melt the data (long format)
DROP VIEW IF EXISTS melted_diagnoses_rate_DE;

CREATE VIEW melted_diagnoses_rate_DE AS
SELECT
    ICD_10,
    ICD_10_description,
    '2021' AS Year,
    `2021` AS Cases,
    (`2021` / (SELECT `2021` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate
FROM diagnoses_DE
WHERE ICD_10 NOT LIKE '%-%-%'
UNION ALL
SELECT
    ICD_10,
    ICD_10_description,
    '2020' AS Year,
    `2020` AS Cases,
    (`2020` / (SELECT `2020` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate
FROM diagnoses_DE
WHERE ICD_10 NOT LIKE '%-%-%'
UNION ALL
SELECT
    ICD_10,
    ICD_10_description,
    '2019' AS Year,
    `2019` AS Cases,
    (`2019` / (SELECT `2019` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate
FROM diagnoses_DE
WHERE ICD_10 NOT LIKE '%-%-%'
UNION ALL
SELECT
    ICD_10,
    ICD_10_description,
    '2018' AS Year,
    `2018` AS Cases,
    (`2018` / (SELECT `2018` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate
FROM diagnoses_DE
WHERE ICD_10 NOT LIKE '%-%-%'
UNION ALL
SELECT
    ICD_10,
    ICD_10_description,
    '2017' AS Year,
    `2017` AS Cases,
    (`2017` / (SELECT `2017` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate
FROM diagnoses_DE
WHERE ICD_10 NOT LIKE '%-%-%'
UNION ALL
SELECT
    ICD_10,
    ICD_10_description,
    '2016' AS Year,
    `2016` AS Cases,
    (`2016` / (SELECT `2016` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate
FROM diagnoses_DE
WHERE ICD_10 NOT LIKE '%-%-%'
UNION ALL
SELECT
    ICD_10,
    ICD_10_description,
    '2015' AS Year,
    `2015` AS Cases,
    (`2015` / (SELECT `2015` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate
FROM diagnoses_DE
WHERE ICD_10 NOT LIKE '%-%-%'
UNION ALL
SELECT
    ICD_10,
    ICD_10_description,
    '2014' AS Year,
    `2014` AS Cases,
    (`2014` / (SELECT `2014` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate
FROM diagnoses_DE
WHERE ICD_10 NOT LIKE '%-%-%'
UNION ALL
SELECT
    ICD_10,
    ICD_10_description,
    '2013' AS Year,
    `2013` AS Cases,
    (`2013` / (SELECT `2013` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate
FROM diagnoses_DE
WHERE ICD_10 NOT LIKE '%-%-%'
UNION ALL
SELECT
    ICD_10,
    ICD_10_description,
    '2012' AS Year,
    `2012` AS Cases,
    (`2012` / (SELECT `2012` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate
FROM diagnoses_DE
WHERE ICD_10 NOT LIKE '%-%-%'

ORDER BY Year, ICD_10;

WITH RankedData AS (
    SELECT
        ICD_10,
        ICD_10_description,
        Year,
        Cases,
        Diagnosis_Rate,
        ROW_NUMBER() OVER (PARTITION BY Year ORDER BY Cases DESC) AS RowNum
    FROM melted_diagnoses_rate_DE
)
SELECT
    ICD_10,
    ICD_10_description,
    Year,
    Cases,
    Diagnosis_Rate
FROM RankedData
WHERE RowNum <= 100;

-- Proportion of Diagnoses per 100k people per year (wide format)
SELECT
    d.ICD_10,
    d.ICD_10_description,
    `2021` AS TotalCases2021,
    (d.2021 / P2021.Population) * 100000 AS Cases_per_100k_2021,
    (d.2020 / P2020.Population) * 100000 AS Cases_per_100k_2020,
    (d.2019 / P2019.Population) * 100000 AS Cases_per_100k_2019,
    (d.2018 / P2018.Population) * 100000 AS Cases_per_100k_2018,
    (d.2017 / P2017.Population) * 100000 AS Cases_per_100k_2017,
    (d.2016 / P2016.Population) * 100000 AS Cases_per_100k_2016,
    (d.2015 / P2015.Population) * 100000 AS Cases_per_100k_2015,
    (d.2014 / P2014.Population) * 100000 AS Cases_per_100k_2014,
    (d.2013 / P2013.Population) * 100000 AS Cases_per_100k_2013,
    (d.2012 / P2012.Population) * 100000 AS Cases_per_100k_2012
FROM
    diagnoses_DE d
JOIN
    population_DE AS P2021 ON P2021.Year = 2021
JOIN
    population_DE AS P2020 ON P2020.Year = 2020
JOIN
    population_DE AS P2019 ON P2019.Year = 2019
JOIN
    population_DE AS P2018 ON P2018.Year = 2018
JOIN
    population_DE AS P2017 ON P2017.Year = 2017
JOIN
    population_DE AS P2016 ON P2016.Year = 2016 
JOIN
    population_DE AS P2015 ON P2015.Year = 2015 
JOIN
    population_DE AS P2014 ON P2014.Year = 2014 
JOIN
    population_DE AS P2013 ON P2013.Year = 2013 
JOIN
    population_DE AS P2012 ON P2012.Year = 2012 
WHERE ICD_10 NOT LIKE '%-%-%'
ORDER BY Cases_per_100k_2021 DESC;

-- Create a view to melt the data (long format)
DROP VIEW IF EXISTS melted_diagnoses_per_100k_DE;

CREATE VIEW melted_diagnoses_per_100k_DE AS
SELECT
    d.ICD_10,
    d.ICD_10_description,
    '2021' AS Year,
    d.`2021` AS Cases,
    (d.`2021` / p2021.Population) * 100000 AS Cases_per_100k
FROM diagnoses_DE d
JOIN population_DE p2021 ON p2021.Year = 2021
WHERE d.ICD_10 NOT LIKE '%-%-%'
UNION ALL

SELECT
    d.ICD_10,
    d.ICD_10_description,
    '2020' AS Year,
    d.`2020` AS Cases,
    (d.`2020` / p2020.Population) * 100000 AS Cases_per_100k
FROM diagnoses_DE d
JOIN population_DE p2020 ON p2020.Year = 2020
WHERE d.ICD_10 NOT LIKE '%-%-%'
UNION ALL

SELECT
    d.ICD_10,
    d.ICD_10_description,
    '2019' AS Year,
    d.`2019` AS Cases,
    (d.`2019` / p2019.Population) * 100000 AS Cases_per_100k
FROM diagnoses_DE d
JOIN population_DE p2019 ON p2019.Year = 2019
WHERE d.ICD_10 NOT LIKE '%-%-%'
UNION ALL

SELECT
    d.ICD_10,
    d.ICD_10_description,
    '2018' AS Year,
    d.`2018` AS Cases,
    (d.`2018` / p2018.Population) * 100000 AS Cases_per_100k
FROM diagnoses_DE d
JOIN population_DE p2018 ON p2018.Year = 2018
WHERE d.ICD_10 NOT LIKE '%-%-%'
UNION ALL

SELECT
    d.ICD_10,
    d.ICD_10_description,
    '2017' AS Year,
    d.`2017` AS Cases,
    (d.`2017` / p2017.Population) * 100000 AS Cases_per_100k
FROM diagnoses_DE d
JOIN population_DE p2017 ON p2017.Year = 2017
WHERE d.ICD_10 NOT LIKE '%-%-%'
UNION ALL

SELECT
    d.ICD_10,
    d.ICD_10_description,
    '2016' AS Year,
    d.`2016` AS Cases,
    (d.`2016` / p2016.Population) * 100000 AS Cases_per_100k
FROM diagnoses_DE d
JOIN population_DE p2016 ON p2016.Year = 2016
WHERE d.ICD_10 NOT LIKE '%-%-%'
UNION ALL

SELECT
    d.ICD_10,
    d.ICD_10_description,
    '2015' AS Year,
    d.`2015` AS Cases,
    (d.`2015` / p2015.Population) * 100000 AS Cases_per_100k
FROM diagnoses_DE d
JOIN population_DE p2015 ON p2015.Year = 2015
WHERE d.ICD_10 NOT LIKE '%-%-%'
UNION ALL

SELECT
    d.ICD_10,
    d.ICD_10_description,
    '2014' AS Year,
    d.`2014` AS Cases,
    (d.`2014` / p2014.Population) * 100000 AS Cases_per_100k
FROM diagnoses_DE d
JOIN population_DE p2014 ON p2014.Year = 2014
WHERE d.ICD_10 NOT LIKE '%-%-%'
UNION ALL

SELECT
    d.ICD_10,
    d.ICD_10_description,
    '2013' AS Year,
    d.`2013` AS Cases,
    (d.`2013` / p2013.Population) * 100000 AS Cases_per_100k
FROM diagnoses_DE d
JOIN population_DE p2013 ON p2013.Year = 2013
WHERE d.ICD_10 NOT LIKE '%-%-%'
UNION ALL

SELECT
    d.ICD_10,
    d.ICD_10_description,
    '2012' AS Year,
    d.`2012` AS Cases,
    (d.`2012` / p2012.Population) * 100000 AS Cases_per_100k
FROM diagnoses_DE d
JOIN population_DE p2012 ON p2012.Year = 2012
WHERE d.ICD_10 NOT LIKE '%-%-%'

ORDER BY Year, Cases_per_100k DESC;

WITH RankedData AS (
    SELECT
        ICD_10,
        ICD_10_description,
        Year,
        Cases,
        Cases_per_100k,
        ROW_NUMBER() OVER (PARTITION BY Year ORDER BY Cases DESC) AS RowNum
    FROM melted_diagnoses_per_100k_DE
)
SELECT
    ICD_10,
    ICD_10_description,
    Year,
    Cases,
    Cases_per_100k
FROM RankedData
WHERE RowNum <= 100;

-- Select diagnoses that increased the most from 2012 to 2021 in relation to the population
SELECT
    D.ICD_10,
    D.ICD_10_description,
    ((D.2021 / P2021.population - D.2012 / P2012.population) / (D.2012 / P2012.population)) * 100 AS Percentage_Increase_Relative_to_Population
FROM diagnoses_DE AS D
JOIN population_DE AS P2021 ON P2021.Year = 2021
JOIN population_DE AS P2012 ON P2012.Year = 2012
WHERE D.2021 > D.2012 AND ICD_10 NOT LIKE '%-%-%'
ORDER BY Percentage_Increase_Relative_to_Population DESC;

-- Select diagnosis that increased the most from 2012 to 2021 in relation to the population. Broad categories
SELECT
    D.ICD_10,
    D.ICD_10_description,
    ((D.2021 / P2021.population - D.2012 / P2012.population) / (D.2012 / P2012.population)) * 100 AS Percentage_Increase_Relative_to_Population
FROM diagnoses_DE AS D
JOIN population_DE AS P2021 ON P2021.Year = 2021
JOIN population_DE AS P2012 ON P2012.Year = 2012
WHERE D.2021 > D.2012 AND ICD_10 LIKE '%-%-%'
ORDER BY Percentage_Increase_Relative_to_Population DESC;

-- Select diagnosis that increased the most from 2016 to 2020 in relation to the population. Broad categories
SELECT
    D.ICD_10,
    D.ICD_10_description,
    ((D.2020 / P2020.population - D.2016 / P2016.population) / (D.2016 / P2016.population)) * 100 AS Percentage_Increase_Relative_to_Population
FROM diagnoses_DE AS D
JOIN population_DE AS P2020 ON P2020.Year = 2020
JOIN population_DE AS P2016 ON P2016.Year = 2016
WHERE D.2020 > D.2016 AND ICD_10 LIKE '%-%-%'
ORDER BY Percentage_Increase_Relative_to_Population DESC;

-- US DATA
-- Diagnosis Rate per year among all diagnoses (wide format)
SELECT
    ICD_10,
    ICD_10_description,
    `2020` AS TotalCases2020,
    (`2020` / (SELECT SUM(`2020`) FROM diagnoses_US))*100 AS Percentage2020,
    (`2019` / (SELECT SUM(`2019`) FROM diagnoses_US))*100 AS Percentage2019,
    (`2018` / (SELECT SUM(`2018`) FROM diagnoses_US))*100 AS Percentage2018,
    (`2017` / (SELECT SUM(`2017`) FROM diagnoses_US))*100 AS Percentage2017,
    (`2016` / (SELECT SUM(`2016`) FROM diagnoses_US))*100 AS Percentage2016
FROM
    diagnoses_US
ORDER BY Percentage2020 DESC;

-- Create a view to melt the data (long format)
DROP VIEW IF EXISTS melted_diagnoses_rate_US;

CREATE VIEW melted_diagnoses_rate_US AS
SELECT
    ICD_10,
    ICD_10_description,
    '2020' AS Year,
    `2020` AS Cases,
    (`2020` / (SELECT `2020` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate
FROM diagnoses_US
WHERE ICD_10 NOT LIKE '%-%-%'
UNION ALL

SELECT
    ICD_10,
    ICD_10_description,
    '2019' AS Year,
    `2019` AS Cases,
    (`2019` / (SELECT `2019` FROM diagnoses_US WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate
FROM diagnoses_US
WHERE ICD_10 NOT LIKE '%-%-%'
UNION ALL

SELECT
    ICD_10,
    ICD_10_description,
    '2018' AS Year,
    `2018` AS Cases,
    (`2018` / (SELECT `2018` FROM diagnoses_US WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate
FROM diagnoses_US
WHERE ICD_10 NOT LIKE '%-%-%'
UNION ALL

SELECT
    ICD_10,
    ICD_10_description,
    '2017' AS Year,
    `2017` AS Cases,
    (`2017` / (SELECT `2017` FROM diagnoses_US WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate
FROM diagnoses_US
WHERE ICD_10 NOT LIKE '%-%-%'
UNION ALL

SELECT
    ICD_10,
    ICD_10_description,
    '2016' AS Year,
    `2016` AS Cases,
    (`2016` / (SELECT `2016` FROM diagnoses_US WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Diagnosis_Rate
FROM diagnoses_US
WHERE ICD_10 NOT LIKE '%-%-%'

ORDER BY Year, ICD_10;

WITH RankedData AS (
    SELECT
        ICD_10,
        ICD_10_description,
        Year,
        Cases,
        Diagnosis_Rate,
        ROW_NUMBER() OVER (PARTITION BY Year ORDER BY Cases DESC) AS RowNum
    FROM melted_diagnoses_rate_US
)
SELECT
    ICD_10,
    ICD_10_description,
    Year,
    Cases,
    Diagnosis_Rate
FROM RankedData
WHERE RowNum <= 100;

-- Proportion of Diagnoses per 100k people per year
SELECT
    d.ICD_10,
    d.ICD_10_description,
    `2020` AS TotalCases2020,
    (d.`2020` / P2020.Population) * 1000000 AS Cases_per_100k_2020,
    (d.`2019` / p2019.Population) * 1000000 AS Cases_per_100k_2019,
    (d.`2018` / p2018.Population) * 1000000 AS Cases_per_100k_2018,
    (d.`2017` / p2017.Population) * 1000000 AS Cases_per_100k_2017,
    (d.`2016` / p2016.Population) * 1000000 AS Cases_per_100k_2016
FROM
    diagnoses_US d
JOIN
    population_US AS P2020 ON P2020.Year = 2020
JOIN
    population_US AS P2019 ON P2019.Year = 2019
JOIN
    population_US AS P2018 ON P2018.Year = 2018
JOIN
    population_US AS P2017 ON P2017.Year = 2017
JOIN
    population_US AS P2016 ON P2016.Year = 2016 
ORDER BY Cases_per_100k_2020 DESC;

-- Create a view to melt the data
DROP VIEW IF EXISTS melted_diagnoses_per_100k_US;

CREATE VIEW melted_diagnoses_per_100k_US AS
SELECT
    d.ICD_10,
    d.ICD_10_description,
    '2020' AS Year,
    d.`2020` AS Cases,
    (d.`2020` / p2020.Population) * 100000 AS Cases_per_100k
FROM diagnoses_US d
JOIN population_DE p2020 ON p2020.Year = 2020
WHERE d.ICD_10 NOT LIKE '%-%-%'
UNION ALL

SELECT
    d.ICD_10,
    d.ICD_10_description,
    '2019' AS Year,
    d.`2019` AS Cases,
    (d.`2019` / p2019.Population) * 100000 AS Cases_per_100k
FROM diagnoses_US d
JOIN population_DE p2019 ON p2019.Year = 2019
WHERE d.ICD_10 NOT LIKE '%-%-%'
UNION ALL

SELECT
    d.ICD_10,
    d.ICD_10_description,
    '2018' AS Year,
    d.`2018` AS Cases,
    (d.`2018` / p2018.Population) * 100000 AS Cases_per_100k
FROM diagnoses_US d
JOIN population_DE p2018 ON p2018.Year = 2018
WHERE d.ICD_10 NOT LIKE '%-%-%'
UNION ALL

SELECT
    d.ICD_10,
    d.ICD_10_description,
    '2017' AS Year,
    d.`2017` AS Cases,
    (d.`2017` / p2017.Population) * 100000 AS Cases_per_100k
FROM diagnoses_US d
JOIN population_DE p2017 ON p2017.Year = 2017
WHERE d.ICD_10 NOT LIKE '%-%-%'
UNION ALL

SELECT
    d.ICD_10,
    d.ICD_10_description,
    '2016' AS Year,
    d.`2016` AS Cases,
    (d.`2016` / p2016.Population) * 100000 AS Cases_per_100k
FROM diagnoses_US d
JOIN population_DE p2016 ON p2016.Year = 2016
WHERE d.ICD_10 NOT LIKE '%-%-%'

ORDER BY Year, Cases_per_100k DESC;

WITH RankedData AS (
    SELECT
        ICD_10,
        ICD_10_description,
        Year,
        Cases,
        Cases_per_100k,
        ROW_NUMBER() OVER (PARTITION BY Year ORDER BY Cases DESC) AS RowNum
    FROM melted_diagnoses_per_100k_US
)
SELECT
    ICD_10,
    ICD_10_description,
    Year,
    Cases,
    Cases_per_100k
FROM RankedData
WHERE RowNum <= 100;


-- Select diagnoses that increased the most from 2016 to 2020 in relation to the population
SELECT
    D.ICD_10,
    D.ICD_10_description,
    ((D.`2020` / P2020.population - D.`2016` / P2016.population) / (D.`2016` / P2016.population)) * 100 AS Percentage_Increase_Relative_to_Population
FROM diagnoses_US AS D
JOIN population_US AS P2020 ON P2020.Year = 2020
JOIN population_US AS P2016 ON P2016.Year = 2016
WHERE D.`2020` > D.`2016`
ORDER BY Percentage_Increase_Relative_to_Population DESC
LIMIT 100;



-- Zeitlicher Verlauf ausgewählter Erkrankungen
-- ICD10-E00-E90 Endokrine, Ernährungs- und Stoffwechselkrankheiten
-- Create a view to melt the data
DROP VIEW IF EXISTS melted_endocrine_data;

CREATE VIEW melted_endocrine_data AS
SELECT
    'Endocrine US' AS Description,
    2020 AS Year,
    ((SELECT SUM(`2020`) FROM diagnoses_US WHERE ICD_10 LIKE 'E%' AND Year = 2020) / (SELECT SUM(`2020`) FROM diagnoses_US )) * 100 AS Percentage
UNION ALL
SELECT
    'Endocrine US' AS Description,
    2019 AS Year,
    ((SELECT SUM(`2019`) FROM diagnoses_US WHERE ICD_10 LIKE 'E%' AND Year = 2019) / (SELECT SUM(`2019`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Endocrine US' AS Description,
    2018 AS Year,
    ((SELECT SUM(`2018`) FROM diagnoses_US WHERE ICD_10 LIKE 'E%' AND Year = 2018) / (SELECT SUM(`2018`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Endocrine US' AS Description,
    2017 AS Year,
    ((SELECT SUM(`2017`) FROM diagnoses_US WHERE ICD_10 LIKE 'E%' AND Year = 2017) / (SELECT SUM(`2017`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Endocrine US' AS Description,
    2016 AS Year,
    ((SELECT SUM(`2016`) FROM diagnoses_US WHERE ICD_10 LIKE 'E%' AND Year = 2016) / (SELECT SUM(`2016`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Endocrine DE' AS Description,
    2020 AS Year,
    ((SELECT SUM(`2020`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-E%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2020` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Endocrine DE' AS Description,
    2019 AS Year,
    ((SELECT SUM(`2019`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-E%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2019` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Endocrine DE' AS Description,
    2018 AS Year,
    ((SELECT SUM(`2018`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-E%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2018` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Endocrine DE' AS Description,
    2017 AS Year,
    ((SELECT SUM(`2017`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-E%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2017` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Endocrine DE' AS Description,
    2016 AS Year,
    ((SELECT SUM(`2016`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-E%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2016` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage;

SELECT * 
FROM melted_endocrine_data;

-- Krankheiten des Atmungssystems
-- Create a view to melt the data
DROP VIEW IF EXISTS melted_respiratory_data;

CREATE VIEW melted_respiratory_data AS
SELECT
    'Respiratory US' AS Description,
    2020 AS Year,
    ((SELECT SUM(`2020`) FROM diagnoses_US WHERE ICD_10 LIKE 'J%' AND Year = 2020) / (SELECT SUM(`2020`) FROM diagnoses_US )) * 100 AS Percentage
UNION ALL
SELECT
    'Respiratory US' AS Description,
    2019 AS Year,
    ((SELECT SUM(`2019`) FROM diagnoses_US WHERE ICD_10 LIKE 'J%' AND Year = 2019) / (SELECT SUM(`2019`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Respiratory US' AS Description,
    2018 AS Year,
    ((SELECT SUM(`2018`) FROM diagnoses_US WHERE ICD_10 LIKE 'J%' AND Year = 2018) / (SELECT SUM(`2018`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Respiratory US' AS Description,
    2017 AS Year,
    ((SELECT SUM(`2017`) FROM diagnoses_US WHERE ICD_10 LIKE 'J%' AND Year = 2017) / (SELECT SUM(`2017`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Respiratory US' AS Description,
    2016 AS Year,
    ((SELECT SUM(`2016`) FROM diagnoses_US WHERE ICD_10 LIKE 'J%' AND Year = 2016) / (SELECT SUM(`2016`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Respiratory DE' AS Description,
    2020 AS Year,
    ((SELECT SUM(`2020`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-J%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2020` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Respiratory DE' AS Description,
    2019 AS Year,
    ((SELECT SUM(`2019`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-J%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2019` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Respiratory DE' AS Description,
    2018 AS Year,
    ((SELECT SUM(`2018`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-J%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2018` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Respiratory DE' AS Description,
    2017 AS Year,
    ((SELECT SUM(`2017`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-J%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2017` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Respiratory DE' AS Description,
    2016 AS Year,
    ((SELECT SUM(`2016`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-J%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2016` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage;

SELECT * 
FROM melted_respiratory_data;

-- Krankheiten des Kreislaufsystems
-- Create a view to melt the data
DROP VIEW IF EXISTS melted_circulatory_data;

CREATE VIEW melted_circulatory_data AS
SELECT
    'Circulatory US' AS Description,
    2020 AS Year,
    ((SELECT SUM(`2020`) FROM diagnoses_US WHERE ICD_10 LIKE 'I%' AND Year = 2020) / (SELECT SUM(`2020`) FROM diagnoses_US )) * 100 AS Percentage
UNION ALL
SELECT
    'Circulatory US' AS Description,
    2019 AS Year,
    ((SELECT SUM(`2019`) FROM diagnoses_US WHERE ICD_10 LIKE 'I%' AND Year = 2019) / (SELECT SUM(`2019`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Circulatory US' AS Description,
    2018 AS Year,
    ((SELECT SUM(`2018`) FROM diagnoses_US WHERE ICD_10 LIKE 'I%' AND Year = 2018) / (SELECT SUM(`2018`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Circulatory US' AS Description,
    2017 AS Year,
    ((SELECT SUM(`2017`) FROM diagnoses_US WHERE ICD_10 LIKE 'I%' AND Year = 2017) / (SELECT SUM(`2017`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Circulatory US' AS Description,
    2016 AS Year,
    ((SELECT SUM(`2016`) FROM diagnoses_US WHERE ICD_10 LIKE 'I%' AND Year = 2016) / (SELECT SUM(`2016`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Circulatory DE' AS Description,
    2020 AS Year,
    ((SELECT SUM(`2020`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-I%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2020` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Circulatory DE' AS Description,
    2019 AS Year,
    ((SELECT SUM(`2019`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-I%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2019` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Circulatory DE' AS Description,
    2018 AS Year,
    ((SELECT SUM(`2018`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-I%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2018` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Circulatory DE' AS Description,
    2017 AS Year,
    ((SELECT SUM(`2017`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-I%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2017` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Circulatory DE' AS Description,
    2016 AS Year,
    ((SELECT SUM(`2016`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-I%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2016` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage;

SELECT * 
FROM melted_circulatory_data;

-- Psychische und Verhaltensstörungen
-- Create a view to melt the data
DROP VIEW IF EXISTS melted_mental_data;

CREATE VIEW melted_mental_data AS
SELECT
    'Mental US' AS Description,
    2020 AS Year,
    ((SELECT SUM(`2020`) FROM diagnoses_US WHERE ICD_10 LIKE 'F%' AND Year = 2020) / (SELECT SUM(`2020`) FROM diagnoses_US )) * 100 AS Percentage
UNION ALL
SELECT
    'Mental US' AS Description,
    2019 AS Year,
    ((SELECT SUM(`2019`) FROM diagnoses_US WHERE ICD_10 LIKE 'F%' AND Year = 2019) / (SELECT SUM(`2019`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Mental US' AS Description,
    2018 AS Year,
    ((SELECT SUM(`2018`) FROM diagnoses_US WHERE ICD_10 LIKE 'F%' AND Year = 2018) / (SELECT SUM(`2018`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Mental US' AS Description,
    2017 AS Year,
    ((SELECT SUM(`2017`) FROM diagnoses_US WHERE ICD_10 LIKE 'F%' AND Year = 2017) / (SELECT SUM(`2017`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Mental US' AS Description,
    2016 AS Year,
    ((SELECT SUM(`2016`) FROM diagnoses_US WHERE ICD_10 LIKE 'F%' AND Year = 2016) / (SELECT SUM(`2016`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Mental DE' AS Description,
    2020 AS Year,
    ((SELECT SUM(`2020`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-F%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2020` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Mental DE' AS Description,
    2019 AS Year,
    ((SELECT SUM(`2019`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-F%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2019` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Mental DE' AS Description,
    2018 AS Year,
    ((SELECT SUM(`2018`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-F%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2018` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Mental DE' AS Description,
    2017 AS Year,
    ((SELECT SUM(`2017`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-F%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2017` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Mental DE' AS Description,
    2016 AS Year,
    ((SELECT SUM(`2016`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-F%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2016` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage;

SELECT * 
FROM melted_mental_data;

-- Schwangerschaft, Geburt und Wochenbett
-- Create a view to melt the data
DROP VIEW IF EXISTS melted_gyn_data;

CREATE VIEW melted_gyn_data AS
SELECT
    'Gynaecology US' AS Description,
    2020 AS Year,
    ((SELECT SUM(`2020`) FROM diagnoses_US WHERE ICD_10 LIKE 'O%' AND Year = 2020) / (SELECT SUM(`2020`) FROM diagnoses_US )) * 100 AS Percentage
UNION ALL
SELECT
    'Gynaecology US' AS Description,
    2019 AS Year,
    ((SELECT SUM(`2019`) FROM diagnoses_US WHERE ICD_10 LIKE 'O%' AND Year = 2019) / (SELECT SUM(`2019`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Gynaecology US' AS Description,
    2018 AS Year,
    ((SELECT SUM(`2018`) FROM diagnoses_US WHERE ICD_10 LIKE 'O%' AND Year = 2018) / (SELECT SUM(`2018`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Gynaecology US' AS Description,
    2017 AS Year,
    ((SELECT SUM(`2017`) FROM diagnoses_US WHERE ICD_10 LIKE 'O%' AND Year = 2017) / (SELECT SUM(`2017`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Gynaecology US' AS Description,
    2016 AS Year,
    ((SELECT SUM(`2016`) FROM diagnoses_US WHERE ICD_10 LIKE 'O%' AND Year = 2016) / (SELECT SUM(`2016`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'Gynaecology DE' AS Description,
    2020 AS Year,
    ((SELECT SUM(`2020`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-O%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2020` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Gynaecology DE' AS Description,
    2019 AS Year,
    ((SELECT SUM(`2019`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-O%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2019` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Gynaecology DE' AS Description,
    2018 AS Year,
    ((SELECT SUM(`2018`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-O%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2018` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Gynaecology DE' AS Description,
    2017 AS Year,
    ((SELECT SUM(`2017`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-O%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2017` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'Gynaecology DE' AS Description,
    2016 AS Year,
    ((SELECT SUM(`2016`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-O%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2016` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage;

SELECT * 
FROM melted_gyn_data;

-- ICD10-Z00-Z99 Faktoren,die zur Inanspruchn.d.Gesundheitsw.führen
-- Create a view to melt the data
DROP VIEW IF EXISTS melted_z_codes_data;

CREATE VIEW melted_z_codes_data AS
SELECT
    'z_codes US' AS Description,
    2020 AS Year,
    ((SELECT SUM(`2020`) FROM diagnoses_US WHERE ICD_10 LIKE 'Z%' AND Year = 2020) / (SELECT SUM(`2020`) FROM diagnoses_US )) * 100 AS Percentage
UNION ALL
SELECT
    'z_codes US' AS Description,
    2019 AS Year,
    ((SELECT SUM(`2019`) FROM diagnoses_US WHERE ICD_10 LIKE 'Z%' AND Year = 2019) / (SELECT SUM(`2019`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'z_codes US' AS Description,
    2018 AS Year,
    ((SELECT SUM(`2018`) FROM diagnoses_US WHERE ICD_10 LIKE 'Z%' AND Year = 2018) / (SELECT SUM(`2018`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'z_codes US' AS Description,
    2017 AS Year,
    ((SELECT SUM(`2017`) FROM diagnoses_US WHERE ICD_10 LIKE 'Z%' AND Year = 2017) / (SELECT SUM(`2017`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'z_codes US' AS Description,
    2016 AS Year,
    ((SELECT SUM(`2016`) FROM diagnoses_US WHERE ICD_10 LIKE 'Z%' AND Year = 2016) / (SELECT SUM(`2016`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'z_codes DE' AS Description,
    2020 AS Year,
    ((SELECT SUM(`2020`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-Z%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2020` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'z_codes DE' AS Description,
    2019 AS Year,
    ((SELECT SUM(`2019`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-Z%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2019` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'z_codes DE' AS Description,
    2018 AS Year,
    ((SELECT SUM(`2018`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-Z%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2018` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'z_codes DE' AS Description,
    2017 AS Year,
    ((SELECT SUM(`2017`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-Z%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2017` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'z_codes DE' AS Description,
    2016 AS Year,
    ((SELECT SUM(`2016`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-Z%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2016` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage;

SELECT * 
FROM melted_z_codes_data;


-- ICD10-U00-U85 Schlüsselnummern für besondere Zwecke
-- ICD10-U00-U49 Vorl.Zuord. f. Kh. m.unkl.Ätiologie u.n.b.Schl-Nr.

-- Create a view to melt the data
DROP VIEW IF EXISTS melted_unknown_data;

CREATE VIEW melted_unknown_data AS
SELECT
    'unknown US' AS Description,
    2020 AS Year,
    ((SELECT SUM(`2020`) FROM diagnoses_US WHERE ICD_10 LIKE 'U%' AND Year = 2020) / (SELECT SUM(`2020`) FROM diagnoses_US )) * 100 AS Percentage
UNION ALL
SELECT
    'unknown US' AS Description,
    2019 AS Year,
    ((SELECT SUM(`2019`) FROM diagnoses_US WHERE ICD_10 LIKE 'U%' AND Year = 2019) / (SELECT SUM(`2019`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'unknown US' AS Description,
    2018 AS Year,
    ((SELECT SUM(`2018`) FROM diagnoses_US WHERE ICD_10 LIKE 'U%' AND Year = 2018) / (SELECT SUM(`2018`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'unknown US' AS Description,
    2017 AS Year,
    ((SELECT SUM(`2017`) FROM diagnoses_US WHERE ICD_10 LIKE 'U%' AND Year = 2017) / (SELECT SUM(`2017`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'unknown US' AS Description,
    2016 AS Year,
    ((SELECT SUM(`2016`) FROM diagnoses_US WHERE ICD_10 LIKE 'U%' AND Year = 2016) / (SELECT SUM(`2016`) FROM diagnoses_US)) * 100 AS Percentage
UNION ALL
SELECT
    'unknown DE' AS Description,
    2020 AS Year,
    ((SELECT SUM(`2020`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-U%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2020` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'unknown DE' AS Description,
    2019 AS Year,
    ((SELECT SUM(`2019`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-U%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2019` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'unknown DE' AS Description,
    2018 AS Year,
    ((SELECT SUM(`2018`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-U%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2018` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'unknown DE' AS Description,
    2017 AS Year,
    ((SELECT SUM(`2017`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-U%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2017` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage
UNION ALL
SELECT
    'unknown DE' AS Description,
    2016 AS Year,
    ((SELECT SUM(`2016`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-U%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2016` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS Percentage;

SELECT * 
FROM melted_unknown_data;

-----
-- README section
-- Covid-19
SELECT 
    'Germany' AS Country,
    'U71' AS ICD_10,
    'Covid-19' AS ICD_10_description,
    (SELECT SUM(`2020`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-U%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2020` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt') * 100 AS '2020',
    (SELECT SUM(`2019`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-U%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2019` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt') * 100 AS '2019',
    (SELECT SUM(`2018`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-U%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2018` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt') * 100 AS '2018',
    (SELECT SUM(`2017`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-U%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2017` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt') * 100 AS '2017',
    (SELECT SUM(`2016`) FROM diagnoses_DE WHERE ICD_10 LIKE 'ICD10-U%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2016` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt') * 100 AS '2016'
FROM
    diagnoses_DE
UNION
SELECT 
    'USA' AS Country,
    'U71' AS ICD_10,
    'Covid-19' AS ICD_10_description,
    ((SELECT SUM(`2020`) FROM diagnoses_US WHERE ICD_10 LIKE 'U%')/ SUM(`2020`)) * 100 ,
    ((SELECT SUM(`2019`) FROM diagnoses_US WHERE ICD_10 LIKE 'U%')/ SUM(`2019`)) * 100 ,
    ((SELECT SUM(`2018`) FROM diagnoses_US WHERE ICD_10 LIKE 'U%')/ SUM(`2018`)) * 100 ,
    ((SELECT SUM(`2017`) FROM diagnoses_US WHERE ICD_10 LIKE 'U%')/ SUM(`2017`)) * 100 ,
    ((SELECT SUM(`2016`) FROM diagnoses_US WHERE ICD_10 LIKE 'U%')/ SUM(`2016`)) * 100 
FROM
    diagnoses_US
UNION
SELECT 
    'Germany' AS Country,
    'U4' AS ICD_10,
    'Severe acute respiratory syndrome [SARS]' AS ICD_10_description,
    (SELECT SUM(`2020`) FROM diagnoses_DE WHERE ICD_10 LIKE '%U4%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2020` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt') * 100 AS '2020',
    (SELECT SUM(`2019`) FROM diagnoses_DE WHERE ICD_10 LIKE '%U4%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2019` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt') * 100 AS '2019',
    (SELECT SUM(`2018`) FROM diagnoses_DE WHERE ICD_10 LIKE '%U4%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2018` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt') * 100 AS '2018',
    (SELECT SUM(`2017`) FROM diagnoses_DE WHERE ICD_10 LIKE '%U4%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2017` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt') * 100 AS '2017',
    (SELECT SUM(`2016`) FROM diagnoses_DE WHERE ICD_10 LIKE '%U4%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2016` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt') * 100 AS '2016'
FROM
    diagnoses_DE
UNION
SELECT 
    'USA' AS Country,
    'U4' AS ICD_10,
    'Severe acute respiratory syndrome [SARS]' AS ICD_10_description,
    ((SELECT SUM(`2020`) FROM diagnoses_US WHERE ICD_10 LIKE '%U4%')/ SUM(`2020`)) * 100 ,
    ((SELECT SUM(`2019`) FROM diagnoses_US WHERE ICD_10 LIKE '%U4%')/ SUM(`2019`)) * 100 ,
    ((SELECT SUM(`2018`) FROM diagnoses_US WHERE ICD_10 LIKE '%U4%')/ SUM(`2018`)) * 100 ,
    ((SELECT SUM(`2017`) FROM diagnoses_US WHERE ICD_10 LIKE '%U4%')/ SUM(`2017`)) * 100 ,
    ((SELECT SUM(`2016`) FROM diagnoses_US WHERE ICD_10 LIKE '%U4%')/ SUM(`2016`)) * 100 
FROM
    diagnoses_US
UNION
SELECT 
    'Germany' AS Country,
    'J00-J99' AS ICD_10,
    'Diseases of the respiratory system' AS ICD_10_description,
    (SELECT SUM(`2020`) FROM diagnoses_DE WHERE ICD_10 LIKE '%J%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2020` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt') * 100 AS '2020',
    (SELECT SUM(`2019`) FROM diagnoses_DE WHERE ICD_10 LIKE '%J%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2019` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt') * 100 AS '2019',
    (SELECT SUM(`2018`) FROM diagnoses_DE WHERE ICD_10 LIKE '%J%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2018` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt') * 100 AS '2018',
    (SELECT SUM(`2017`) FROM diagnoses_DE WHERE ICD_10 LIKE '%J%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2017` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt') * 100 AS '2017',
    (SELECT SUM(`2016`) FROM diagnoses_DE WHERE ICD_10 LIKE '%J%' AND ICD_10 NOT LIKE '%-%-%') / (SELECT `2016` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt') * 100 AS '2016'
FROM
    diagnoses_DE
UNION
SELECT 
    'USA' AS Country,
    'J00-J99' AS ICD_10,
    'Diseases of the respiratory system' AS ICD_10_description,
    ((SELECT SUM(`2020`) FROM diagnoses_US WHERE ICD_10 LIKE '%J%')/ SUM(`2020`)) * 100 ,
    ((SELECT SUM(`2019`) FROM diagnoses_US WHERE ICD_10 LIKE '%J%')/ SUM(`2019`)) * 100 ,
    ((SELECT SUM(`2018`) FROM diagnoses_US WHERE ICD_10 LIKE '%J%')/ SUM(`2018`)) * 100 ,
    ((SELECT SUM(`2017`) FROM diagnoses_US WHERE ICD_10 LIKE '%J%')/ SUM(`2017`)) * 100 ,
    ((SELECT SUM(`2016`) FROM diagnoses_US WHERE ICD_10 LIKE '%J%')/ SUM(`2016`)) * 100 
FROM
    diagnoses_US
;

-- ICD10-Z38 Liveborn infants according to place of birth
SELECT
    'Germany' AS Country,
    'Z38' AS ICD_10,
    'Liveborn infants according to place of birth' AS ICD_10_description,
    (`2020` / (SELECT `2020` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS '2020',
    (`2019` / (SELECT `2019` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS '2019',
    (`2018` / (SELECT `2018` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS '2018',
    (`2017` / (SELECT `2017` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS '2017',
    (`2016` / (SELECT `2016` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS '2016'
FROM
    diagnoses_DE
WHERE ICD_10 NOT LIKE '%-%-%' AND ICD_10 LIKE '%-Z38%'
UNION
SELECT
    'USA' AS Country,
    'Z38' AS ICD_10,
    'Liveborn infants according to place of birth' AS ICD_10_description,
    ((SELECT SUM(`2020`) FROM diagnoses_US WHERE ICD_10 LIKE '%Z38%')/ SUM(`2020`)) * 100 ,
    ((SELECT SUM(`2019`) FROM diagnoses_US WHERE ICD_10 LIKE '%Z38%')/ SUM(`2019`)) * 100 ,
    ((SELECT SUM(`2018`) FROM diagnoses_US WHERE ICD_10 LIKE '%Z38%')/ SUM(`2018`)) * 100 ,
    ((SELECT SUM(`2017`) FROM diagnoses_US WHERE ICD_10 LIKE '%Z38%')/ SUM(`2017`)) * 100 ,
    ((SELECT SUM(`2016`) FROM diagnoses_US WHERE ICD_10 LIKE '%Z38%')/ SUM(`2016`)) * 100 
FROM
    diagnoses_US ;

-- ICD10-A41	   Sonstige Sepsis    
SELECT
    'Germany' AS Country,
    'A41' ICD_10,
    'Other sepsis' AS ICD_10_description,
    (`2020` / (SELECT `2020` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS '2020',
    (`2019` / (SELECT `2019` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS '2019',
    (`2018` / (SELECT `2018` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS '2018',
    (`2017` / (SELECT `2017` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS '2017',
    (`2016` / (SELECT `2016` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS '2016'
FROM
    diagnoses_DE
WHERE ICD_10 NOT LIKE '%-%-%' AND ICD_10 LIKE '%-A41%'
UNION
SELECT
    'USA' AS Country,
    'A41' ICD_10,
    'Other sepsis' AS ICD_10_description,
    ((SELECT SUM(`2020`) FROM diagnoses_US WHERE ICD_10 LIKE '%A41%')/ SUM(`2020`)) * 100 ,
    ((SELECT SUM(`2019`) FROM diagnoses_US WHERE ICD_10 LIKE '%A41%')/ SUM(`2019`)) * 100 ,
    ((SELECT SUM(`2018`) FROM diagnoses_US WHERE ICD_10 LIKE '%A41%')/ SUM(`2018`)) * 100 ,
    ((SELECT SUM(`2017`) FROM diagnoses_US WHERE ICD_10 LIKE '%A41%')/ SUM(`2017`)) * 100 ,
    ((SELECT SUM(`2016`) FROM diagnoses_US WHERE ICD_10 LIKE '%A41%')/ SUM(`2016`)) * 100 
FROM
    diagnoses_US ;


-- ICD10-E10-E14 Diabetes mellitus
SELECT
    'Germany' AS Country,
    'E10-E14' ICD_10,
    'Diabetes Mellitus' AS ICD_10_description,
    (`2020` / (SELECT `2020` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS '2020',
    (`2019` / (SELECT `2019` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS '2019',
    (`2018` / (SELECT `2018` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS '2018',
    (`2017` / (SELECT `2017` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS '2017',
    (`2016` / (SELECT `2016` FROM diagnoses_DE WHERE ICD_10_description LIKE 'Insgesamt')) * 100 AS '2016'
FROM
    diagnoses_DE
WHERE  ICD_10 LIKE '%E10-E14%'
UNION
SELECT
    'USA' AS Country,
    'E10-E14' ICD_10,
    'Diabetes Mellitus' AS ICD_10_description,
    SUM(`2020`) / (SELECT SUM(`2020`) FROM diagnoses_US) * 100 AS Percentage2020,
    SUM(`2019`) / (SELECT SUM(`2019`) FROM diagnoses_US) * 100 AS Percentage2019,
    SUM(`2018`) / (SELECT SUM(`2018`) FROM diagnoses_US) * 100 AS Percentage2018,
    SUM(`2017`) / (SELECT SUM(`2017`) FROM diagnoses_US) * 100 AS Percentage2017,
    SUM(`2016`) / (SELECT SUM(`2016`) FROM diagnoses_US) * 100 AS Percentage2016
FROM
    diagnoses_US
WHERE ICD_10 LIKE '%E10%' 
OR ICD_10 LIKE '%E11%' 
OR ICD_10 LIKE '%E12%' 
OR ICD_10 LIKE '%E13%' 
OR ICD_10 LIKE '%E14%';


