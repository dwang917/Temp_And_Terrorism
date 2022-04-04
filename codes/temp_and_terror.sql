/*
 *  final project
 * 
 *  members: Daming Wang, Giorgio Cassata, John Murphy
 *
 */

-- load data onto server 

DROP TABLE IF EXISTS temp CASCADE;  

DROP TABLE IF EXISTS terrorism CASCADE;  
 

CREATE TABLE temp (  

    date DATE,   

    avg_temp NUMERIC,   

    country TEXT);  

 

\COPY temp FROM 'C:\Users\wangd\OneDrive\Desktop\CSCI403\final\global_temps_cleaned.csv' WITH (FORMAT csv);  

 
 

CREATE TABLE terrorism (  

    date DATE,  

    country TEXT,   

    success BOOLEAN,   

    suicide BOOLEAN,   

    people_killed INTEGER,   

    property BOOLEAN,   

    ransom BOOLEAN);  

 

\COPY terrorism FROM 'C:\Users\wangd\OneDrive\Desktop\CSCI403\final\global_terrorism_cleaned.csv' WITH (FORMAT csv); 

 

 

-- create combination table for the two datasets, grouped by year and country 

DROP TABLE IF EXISTS combo_table;  

 

CREATE TABLE combo_table   

    AS SELECT temp_year, temp_country, temp_avg, terror_success, terror_nkills, terror_suicide, terror_property, terror_ransom 

    FROM   

        (SELECT date_trunc('year', date) AS temp_year, country AS temp_country, avg(avg_temp) AS temp_avg FROM temp GROUP BY temp_year, temp_country) AS new_temp,  

        (SELECT date_trunc('year', date) as terror_year, country AS terror_country, count(CASE WHEN success THEN 1 END) AS terror_success, sum(people_killed) AS terror_nkills, count(CASE WHEN suicide THEN 1 END) AS terror_suicide, count(CASE WHEN property THEN 1 END) AS terror_property, count(CASE WHEN ransom THEN 1 END) AS terror_ransom FROM terrorism GROUP BY terror_year, terror_country) AS new_terror 

    WHERE temp_country = terror_country AND temp_year = terror_year;  

 

 

 

-- create table byKilled which includes average temperatures and total people killed grouped by countries from the combinaiton table  

CREATE TABLE byKilled AS SELECT temp_country, AVG(temp_avg), SUM(terror_nkills) FROM combo_table WHERE terror_nkills IS NOT NULL GROUP BY temp_country ORDER BY SUM(terror_nkills) DESC;  

 

-- export the byKilled table to a local csv file  

\COPY byKilled TO 'C:\Users\wangd\OneDrive\Desktop\CSCI403\final\byKilled.csv' CSV;  
 

-- create table bySuccess which includes avergage temperatures and total successful terrorism attacks grouped by countries from the combination table  

CREATE TABLE bySuccess AS SELECT temp_country, AVG(temp_avg), SUM(terror_success) FROM combo_table WHERE terror_success IS NOT NULL GROUP BY temp_country ORDER BY SUM(terror_success) DESC;  

 

-- export the bySuccess table to a local csv file  

\COPY bySuccess TO 'C:\Users\wangd\OneDrive\Desktop\CSCI403\final\bySuccess.csv' CSV; 

 

-- create table US which includes US’s average temperatures and terrorism data from all recorded years  

SELECT * from combo_table WHERE temp_country = 'United States' ORDER BY temp_year;   

 

-- export the US table to a local csv file  

\COPY US to 'C:\Users\wangd\OneDrive\Desktop\CSCI403\final\US.csv' CSV; 