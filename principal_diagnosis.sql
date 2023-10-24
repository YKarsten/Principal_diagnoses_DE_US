-- Data import
USE
    ICD_10_DE;

-- https://www-genesis.destatis.de/genesis/online?operation=find&suchanweisung_language=de&query=23131-0001#abreadcrumb
-- Statistisches Bundesamt Ergebnis 23131-0001
-- Krankenhauspatienten: Deutschland, Jahre, Hauptdiagnose ICD-10 (1-3-Steller Hierarchie)

-- Drop the table if it exists
DROP TABLE
    IF EXISTS Diagnosen_DE;

-- Create the table with utf8mb4 character set
CREATE TABLE
    Diagnosen_DE (
        ICD_10 VARCHAR(255),
        Hauptdiagnose VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci, -- mySQL default encoding doesn't support 'Umlaute'
        cases_2012 INT,
        cases_2013 INT,
        cases_2014 INT,
        cases_2015 INT,
        cases_2016 INT,
        cases_2017 INT,
        cases_2018 INT,
        cases_2019 INT,
        cases_2020 INT,
        cases_2021 INT
    );

-- Load data from CSV
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.1\\Uploads\\23131-0001_$F.csv' INTO TABLE Diagnosen_DE
FIELDS TERMINATED BY ';' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 7 ROWS (
    ICD_10,
    @Hauptdiagnose,
    @cases_2012,
    @cases_2013,
    @cases_2014,
    @cases_2015,
    @cases_2016,
    @cases_2017,
    @cases_2018,
    @cases_2019,
    @cases_2020,
    @cases_2021
)
SET
    Hauptdiagnose = CONVERT(REPLACE(REPLACE(REPLACE(@Hauptdiagnose, '\xF6', 'oe'), '\xFC', 'ue'), '\xE4', 'ae'), CHAR),
    cases_2012 = NULLIF(@cases_2012, '-'),
    cases_2013 = NULLIF(@cases_2013, '-'),
    cases_2014 = NULLIF(@cases_2014, '-'),
    cases_2015 = NULLIF(@cases_2015, '-'),
    cases_2016 = NULLIF(@cases_2016, '-'),
    cases_2017 = NULLIF(@cases_2017, '-'),
    cases_2018 = NULLIF(@cases_2018, '-'),
    cases_2019 = NULLIF(@cases_2019, '-'),
    cases_2020 = NULLIF(@cases_2020, '-'),
    cases_2021 = CASE
        WHEN TRIM(@cases_2021) REGEXP '^[0-9]*\\.?[0-9]+$' THEN TRIM(@cases_2021)
        ELSE NULL
    END;

-- Import population data according to  https://de.statista.com/statistik/daten/studie/1365/umfrage/bevoelkerung-deutschlands-nach-altersgruppen/
-- Drop the table if it exists
DROP TABLE
    IF EXISTS population_DE;

CREATE TABLE population_DE(
    `year` YEAR,
    population FLOAT
);

-- Load data from CSV
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.1\\Uploads\\DE_population.csv' INTO TABLE population_DE
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS (
    `Year`,
    Population
);

-- US data
-- https://hcup-us.ahrq.gov/db/nation/nis/nisdbdocumentation.jsp
-- https://hcup-us.ahrq.gov/db/nation/nis/HCUP-NIS2016-2020-DXandPRfreqs.xlsx

-- Drop the table if it exists
DROP TABLE IF EXISTS diagnosis_US;

-- Create the table with utf8mb4 character set
CREATE TABLE diagnosis_US (
    ICD_10 VARCHAR(255),
    ICD_10_description VARCHAR(255),
    DX1_weighted_2020 INT,
    DX1_weighted_2019 INT,
    DX1_weighted_2018 INT,
    DX1_weighted_2017 INT,
    DX1_weighted_2016 INT
);

-- Load data from CSV, skipping the first 4 lines (metadata and headers)
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.1\\Uploads\\HCUP-NIS2016-2020-DXandPRfreqs.csv' INTO TABLE diagnosis_US
FIELDS TERMINATED BY '\t' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 8 LINES (
    ICD_10,
    ICD_10_description,
    @C,
    @D,
    @DX1_weighted_2020,
    @F,
    @G,
    @H,
    @DX1_weighted_2019,
    @J,
    @K,
    @L,
    @DX1_weighted_2018,
    @N,
    @O,
    @P,
    @DX1_weighted_2017,
    @R,
    @S,
    @T,
    @DX1_weighted_2016,
    @V,
    @W,
    @X
)
SET
    DX1_weighted_2020 = NULLIF(REPLACE(REPLACE(@DX1_weighted_2020, '*', ''), ' ', ''), ''),
    DX1_weighted_2019 = NULLIF(REPLACE(REPLACE(@DX1_weighted_2019, '*', ''), ' ', ''), ''),
    DX1_weighted_2018 = NULLIF(REPLACE(REPLACE(@DX1_weighted_2018, '*', ''), ' ', ''), ''),
    DX1_weighted_2017 = NULLIF(REPLACE(REPLACE(@DX1_weighted_2017, '*', ''), ' ', ''), ''),
    DX1_weighted_2016 = NULLIF(REPLACE(REPLACE(@DX1_weighted_2016, '*', ''), ' ', ''), '');


-- US population data
-- https://www2.census.gov/programs-surveys/popest/tables/2010-2020/national/totals/
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
FROM Diagnosen_DE;

SHOW COLUMNS  
FROM diagnosis_US;

SELECT * FROM 
population_DE;

SELECT * FROM 
population_US;

-- Select all groups of diseases
SELECT *
FROM Diagnosen_DE
WHERE ICD_10 LIKE '%-%-%'
ORDER BY cases_2012 DESC;

------------
-- DE data

-- Diagnosis Rate per year among all diagnoses
SELECT
    ICD_10,
    Hauptdiagnose,
    `cases_2021` AS TotalCases2021,
    (`cases_2021` / (SELECT SUM(`cases_2021`) FROM Diagnosen_DE))*100 AS Percentage2021,
    (`cases_2020` / (SELECT SUM(`cases_2020`) FROM Diagnosen_DE))*100 AS Percentage2020,
    (`cases_2019` / (SELECT SUM(`cases_2019`) FROM Diagnosen_DE))*100 AS Percentage2019,
    (`cases_2018` / (SELECT SUM(`cases_2018`) FROM Diagnosen_DE))*100 AS Percentage2018,
    (`cases_2017` / (SELECT SUM(`cases_2017`) FROM Diagnosen_DE))*100 AS Percentage2017,
    (`cases_2016` / (SELECT SUM(`cases_2016`) FROM Diagnosen_DE))*100 AS Percentage2016,
    (`cases_2015` / (SELECT SUM(`cases_2015`) FROM Diagnosen_DE))*100 AS Percentage2015,
    (`cases_2014` / (SELECT SUM(`cases_2014`) FROM Diagnosen_DE))*100 AS Percentage2014,
    (`cases_2013` / (SELECT SUM(`cases_2013`) FROM Diagnosen_DE))*100 AS Percentage2013,
    (`cases_2012` / (SELECT SUM(`cases_2012`) FROM Diagnosen_DE))*100 AS Percentage2012
FROM
    Diagnosen_DE
ORDER BY Percentage2021 DESC;

-- Proportion of Diagnoses per 100k people per year
SELECT
    d.ICD_10,
    d.Hauptdiagnose,
    `cases_2021` AS TotalCases2021,
    (d.cases_2021 / P2021.Population / 1000000) * 100000 AS Cases_per_100k_2021,
    (d.cases_2020 / P2020.Population / 1000000) * 100000 AS Cases_per_100k_2020,
    (d.cases_2019 / P2019.Population / 1000000) * 100000 AS Cases_per_100k_2019,
    (d.cases_2018 / P2018.Population / 1000000) * 100000 AS Cases_per_100k_2018,
    (d.cases_2017 / P2017.Population / 1000000) * 100000 AS Cases_per_100k_2017,
    (d.cases_2016 / P2016.Population / 1000000) * 100000 AS Cases_per_100k_2016,
    (d.cases_2015 / P2015.Population / 1000000) * 100000 AS Cases_per_100k_2015,
    (d.cases_2014 / P2014.Population / 1000000) * 100000 AS Cases_per_100k_2014,
    (d.cases_2013 / P2013.Population / 1000000) * 100000 AS Cases_per_100k_2013,
    (d.cases_2012 / P2012.Population / 1000000) * 100000 AS Cases_per_100k_2012
FROM
    Diagnosen_DE d
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
ORDER BY Cases_per_100k_2021 DESC;



-- Select diagnosis that increased the most from 2012 to 2021 in relation to the population
SELECT
    D.ICD_10,
    D.Hauptdiagnose,
    ((D.cases_2021 / P2021.population - D.cases_2012 / P2012.population) / (D.cases_2012 / P2012.population)) * 100 AS Percentage_Increase_Relative_to_Population
FROM Diagnosen_DE AS D
JOIN population_DE AS P2021 ON P2021.Year = 2021
JOIN population_DE AS P2012 ON P2012.Year = 2012
WHERE D.cases_2021 > D.cases_2012 AND ICD_10 NOT LIKE '%-%-%'
ORDER BY Percentage_Increase_Relative_to_Population DESC;

-- Select diagnosis that increased the most from 2012 to 2021 in relation to the population. Broad categories
SELECT
    D.ICD_10,
    D.Hauptdiagnose,
    ((D.cases_2021 / P2021.population - D.cases_2012 / P2012.population) / (D.cases_2012 / P2012.population)) * 100 AS Percentage_Increase_Relative_to_Population
FROM Diagnosen_DE AS D
JOIN population_DE AS P2021 ON P2021.Year = 2021
JOIN population_DE AS P2012 ON P2012.Year = 2012
WHERE D.cases_2021 > D.cases_2012 AND ICD_10 LIKE '%-%-%'
ORDER BY Percentage_Increase_Relative_to_Population DESC;

-- Select diagnosis that increased the most from 2016 to 2020 in relation to the population. Broad categories
SELECT
    D.ICD_10,
    D.Hauptdiagnose,
    ((D.cases_2020 / P2020.population - D.cases_2016 / P2016.population) / (D.cases_2016 / P2016.population)) * 100 AS Percentage_Increase_Relative_to_Population
FROM Diagnosen_DE AS D
JOIN population_DE AS P2020 ON P2020.Year = 2020
JOIN population_DE AS P2016 ON P2016.Year = 2016
WHERE D.cases_2020 > D.cases_2016 AND ICD_10 LIKE '%-%-%'
ORDER BY Percentage_Increase_Relative_to_Population DESC;

-- Most prevalent diagnosis
SELECT '2012' AS Year, ICD_10, Hauptdiagnose, cases_2012 AS DiagnosesCount
FROM Diagnosen_DE
WHERE ICD_10 NOT LIKE '%-%-%'
ORDER BY cases_2012 DESC
LIMIT 10;

SELECT '2020' AS Year, ICD_10, Hauptdiagnose, cases_2020 AS DiagnosesCount
FROM Diagnosen_DE
WHERE ICD_10 NOT LIKE '%-%-%'
ORDER BY cases_2020 DESC
LIMIT 10;

SELECT '2021' AS Year, ICD_10, Hauptdiagnose, cases_2021 AS DiagnosesCount
FROM Diagnosen_DE
WHERE ICD_10 NOT LIKE '%-%-%'
ORDER BY cases_2021 DESC
LIMIT 10;

-- Zeitlicher Verlauf ausgewählter Erkrankungen
-- Krankheiten des Atmungssystems
SELECT *
FROM Diagnosen_DE
WHERE ICD_10 LIKE 'ICD10-J00-J99';

-- Krankheiten des Kreislaufsystems
SELECT *
FROM Diagnosen_DE
WHERE ICD_10 LIKE 'ICD10-I00-I99';

-- Psychische und Verhaltensstörungen
SELECT *
FROM Diagnosen_DE
WHERE ICD_10 LIKE 'ICD10-F00-F99';

-- Schwangerschaft, Geburt und Wochenbett
SELECT *
FROM Diagnosen_DE
WHERE ICD_10 LIKE 'ICD10-O00-O99';

--   Vorl.Zuord. f. Kh. m.unkl.Ätiologie u.n.b.Schl-Nr.
SELECT *
FROM Diagnosen_DE
WHERE ICD_10 LIKE 'ICD10-U00-U49';


-- US DATA

-- Diagnosis Rate per year among all diagnoses
SELECT
    ICD_10,
    ICD_10_description,
    `DX1_Weighted_2020` AS TotalCases2020,
    (`DX1_Weighted_2020` / (SELECT SUM(`DX1_Weighted_2020`) FROM diagnosis_US))*100 AS Percentage2020,
    (`DX1_Weighted_2019` / (SELECT SUM(`DX1_Weighted_2019`) FROM diagnosis_US))*100 AS Percentage2019,
    (`DX1_Weighted_2018` / (SELECT SUM(`DX1_Weighted_2018`) FROM diagnosis_US))*100 AS Percentage2018,
    (`DX1_Weighted_2017` / (SELECT SUM(`DX1_Weighted_2017`) FROM diagnosis_US))*100 AS Percentage2017,
    (`DX1_Weighted_2016` / (SELECT SUM(`DX1_Weighted_2016`) FROM diagnosis_US))*100 AS Percentage2016
FROM
    diagnosis_US
ORDER BY Percentage2020 DESC;

-- Proportion of Diagnoses per 100k people per year
SELECT
    d.ICD_10,
    d.ICD_10_description,
    `DX1_Weighted_2020` AS TotalCases2020,
    (d.DX1_Weighted_2020 / P2020.Population) * 1000000 AS Cases_per_100k_2020,
    (d.DX1_Weighted_2019 / p2019.Population) * 1000000 AS Cases_per_100k_2019,
    (d.DX1_Weighted_2018 / p2018.Population) * 1000000 AS Cases_per_100k_2018,
    (d.DX1_Weighted_2017 / p2017.Population) * 1000000 AS Cases_per_100k_2017,
    (d.DX1_Weighted_2016 / p2016.Population) * 1000000 AS Cases_per_100k_2016
FROM
    diagnosis_US d
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


-- Zeitlicher Verlauf ausgewählter Erkrankungen
-- Krankheiten des Atmungssystems
SELECT 
    'Respiratory diseases' AS Description,
    SUM(DX1_weighted_2020) AS SumCases2020,
    SUM(DX1_weighted_2019) AS SumCases2019,
    SUM(DX1_weighted_2018) AS SumCases2018,
    SUM(DX1_weighted_2017) AS SumCases2017,
    SUM(DX1_weighted_2016) AS SumCases2016
FROM diagnosis_US
WHERE ICD_10 LIKE 'J%';


-- Krankheiten des Kreislaufsystems
SELECT 
    'Diseases of the circulatory system' AS Description,
    SUM(DX1_weighted_2020) AS SumCases2020,
    SUM(DX1_weighted_2019) AS SumCases2019,
    SUM(DX1_weighted_2018) AS SumCases2018,
    SUM(DX1_weighted_2017) AS SumCases2017,
    SUM(DX1_weighted_2016) AS SumCases2016
FROM diagnosis_US
WHERE ICD_10 LIKE 'I%';

-- Psychische und Verhaltensstörungen
SELECT 
    'Mental and behavioral disorders' AS Description,
    SUM(DX1_weighted_2020) AS SumCases2020,
    SUM(DX1_weighted_2019) AS SumCases2019,
    SUM(DX1_weighted_2018) AS SumCases2018,
    SUM(DX1_weighted_2017) AS SumCases2017,
    SUM(DX1_weighted_2016) AS SumCases2016
FROM diagnosis_US
WHERE ICD_10 LIKE 'F%';

-- Schwangerschaft, Geburt und Wochenbett
SELECT 
    'Pregnancy, birth and postpartum' AS Description,
    SUM(DX1_weighted_2020) AS SumCases2020,
    SUM(DX1_weighted_2019) AS SumCases2019,
    SUM(DX1_weighted_2018) AS SumCases2018,
    SUM(DX1_weighted_2017) AS SumCases2017,
    SUM(DX1_weighted_2016) AS SumCases2016
FROM diagnosis_US
WHERE ICD_10 LIKE 'O%';


--   Vorl.Zuord. f. Kh. m.unkl.Ätiologie u.n.b.Schl-Nr.
SELECT 
    'Preliminary assign. f. Hospital with unclear etiology and no specific key no.' AS Description,
    SUM(DX1_weighted_2020) AS SumCases2020,
    SUM(DX1_weighted_2019) AS SumCases2019,
    SUM(DX1_weighted_2018) AS SumCases2018,
    SUM(DX1_weighted_2017) AS SumCases2017,
    SUM(DX1_weighted_2016) AS SumCases2016
FROM diagnosis_US
WHERE ICD_10 LIKE 'U%';

-- Select diagnosis that increased the most from 2016 to 2020 in relation to the population
SELECT
    D.ICD_10,
    D.ICD_10_description,
    ((D.DX1_weighted_2020 / P2020.population - D.DX1_weighted_2016 / P2016.population) / (D.DX1_weighted_2016 / P2016.population)) * 100 AS Percentage_Increase_Relative_to_Population
FROM diagnosis_US AS D
JOIN population_US AS P2020 ON P2020.Year = 2020
JOIN population_US AS P2016 ON P2016.Year = 2016
WHERE D.DX1_weighted_2020 > D.DX1_weighted_2016 
ORDER BY Percentage_Increase_Relative_to_Population DESC;