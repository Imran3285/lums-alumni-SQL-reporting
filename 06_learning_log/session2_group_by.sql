/* =====================================================================
   Practice session 2 - GROUP BY drills
   Learned: Aug–Sep 2026 · Practice file on this database: November 2026
   Topics: COUNT, WHERE, GROUP BY, HAVING, TOP, first JOINs
   ===================================================================== */

-- R1. How many alumni live in Lahore?                          Target: 6,940
-- Learned: WHERE city IS NOT NULL keeps every city - = 'Lahore' keeps one.
SELECT COUNT(*) AS alumni_in_lahore
FROM contact
WHERE city = 'Lahore';

-- R2. How many alumni in each program? Biggest first.          Target: BSc 11,357
-- Learned: "in each" means GROUP BY. Comma between every SELECT column.
SELECT program, COUNT(*) AS total_alumni
FROM education
WHERE program IS NOT NULL
GROUP BY program
ORDER BY total_alumni DESC;

-- R3. Male vs female (blanks excluded).                        Target: M 13,283 / F 8,188
SELECT gender, COUNT(*) AS total_alumni
FROM alumni
WHERE gender IS NOT NULL
GROUP BY gender
ORDER BY total_alumni DESC;

-- R4. Graduates each year from 2020, in year order.            Target: 2020 = 1,042 ... 2026 = 1,483
-- Learned: "in order" / trend -> ORDER BY the year, not the count.
SELECT graduation_year, COUNT(*) AS total_alumni
FROM education
WHERE graduation_year >= 2020
GROUP BY graduation_year
ORDER BY graduation_year;

-- R5. Cities with more than 500 alumni.                        Target: 6 cities
-- Learned: WHERE filters rows (people) - HAVING filters groups (piles) after counting.
SELECT city, COUNT(*) AS total_alumni
FROM contact
WHERE city IS NOT NULL
GROUP BY city
HAVING COUNT(*) > 500
ORDER BY total_alumni DESC;

-- R6. Top 5 industries.                                        Target: Computer Software 2,126
-- Learned: SQL Server uses TOP 5 after SELECT - LIMIT 5 is MySQL/PostgreSQL.
SELECT TOP 5 industry, COUNT(*) AS total
FROM employment
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY total DESC;

-- R7. Female alumni from SDSB.                                 Target: 2,208
SELECT COUNT(*) AS female_sdsb
FROM alumni AS a
INNER JOIN education AS e ON a.roll_number = e.roll_number
WHERE a.gender = 'Female'
  AND e.school = 'SDSB';

-- R8. MBA: male vs female.                                     Target: M 2,257 / F 626
SELECT a.gender, COUNT(*) AS total
FROM alumni AS a
INNER JOIN education AS e ON a.roll_number = e.roll_number
WHERE e.program = 'MBA'
  AND a.gender IS NOT NULL
GROUP BY a.gender;
