CREATE DATABASE PortfolioProject;

USE portfolioproject;
SELECT * FROM hr;

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

USE portfolioproject;
SELECT * FROM hr;

#SET sql_safe_updates = 0;
SET sql_mode = '';

UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

ALTER TABLE hr
ADD COLUMN age INT;

DESCRIBE hr;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT
	min(age) as youngest,
    max(age) as oldest
FROM hr;

SELECT count(*) FROM hr WHERE age<18;

#DISTRIBUTION OF EMPLOYEES BASED ON VARIOUS CATEGORIES
#GENDER BREAKDOWN
SELECT gender, count(*) as count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY gender;

#ETHNICITY BREAKDONW
SELECT race, count(*) as count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY count(*) DESC;

#AGE DISTRIBUTION
SELECT
	min(age) as youngest,
    max(age) as oldest
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00';

SELECT 
	CASE
		WHEN age >= 18 AND age <= 24 THEN '18-24'
        WHEN age >= 25 AND age <= 34 THEN '25-34'
        WHEN age >= 35 AND age <= 44 THEN '35-44'
        WHEN age >= 45 AND age <= 54 THEN '45-54'
        WHEN age >= 55 AND age <= 64 THEN '55-64'
		ELSE '65+'
	END AS age_group,
    count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY age_group
ORDER BY age_group;

SELECT 
	CASE
		WHEN age >= 18 AND age <= 24 THEN '18-24'
        WHEN age >= 25 AND age <= 34 THEN '25-34'
        WHEN age >= 35 AND age <= 44 THEN '35-44'
        WHEN age >= 45 AND age <= 54 THEN '45-54'
        WHEN age >= 55 AND age <= 64 THEN '55-64'
		ELSE '65+'
	END AS age_group,
    gender,
    count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY age_group, gender
ORDER BY age_group, gender;

#HEADQUARTERS VS REMOTE
SELECT location, count(*) as count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location;

#DURATION OF WORK BEFORE TERMINATION
SELECT
	round(avg(datediff(termdate, hire_date))/365,0) AS avg_length_employment
FROM hr
WHERE termdate <= curdate() AND termdate <> '0000-00-00' AND age >= 18;

#GENDER DIST. ACROSS VARIOUS DEPTs
SELECT gender, department, count(*) as count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY department, gender
ORDER BY department;

#JOB DIST. ACROSS COMPANY
SELECT jobtitle, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle DESC;

#TURNOVER RATE OF EMPLOYEES
SELECT department, 
	total_count,
    terminated_count,
    terminated_count/total_count AS termination_rate
FROM (
	SELECT department,
    count(*) AS total_count,
    SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
    FROM hr
    WHERE age >= 18
    GROUP BY department
    ) AS subquery
ORDER BY termination_rate DESC;

#DIST. OF EMPs BY CITY AND STATE
SELECT location_state, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location_state
ORDER BY count DESC;

SELECT location_city, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location_city
ORDER BY count DESC;

#CHANGE IN EMPLOYEE COUNT BETWEEN 2000-2020
SELECT
	year,
    hires,
    terminations,
    hires - terminations AS net_change,
    round((hires - terminations)/hires*100, 2) AS net_change_percent
FROM (
	SELECT YEAR(hire_date) AS year,
    count(*) AS hires,
    SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
    FROM hr
    WHERE age >= 18
    GROUP BY YEAR(hire_date)
    ) AS subquery
ORDER BY year ASC;

#TENURE DIST. FOR EACH DEPT.
SELECT department,
	   round(avg(datediff(termdate, hire_date)/365), 0) AS avg_tenure
FROM hr
WHERE termdate <> '0000-00-00' AND termdate <= curdate() AND age >= 18
GROUP BY department;
