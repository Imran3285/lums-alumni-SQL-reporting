/* =====================================================================
   Practice session 1 - The Alumni Office inbox
   Date: 2026-11-14
   ===================================================================== */

-- R1. How many female alumni do we have?           Target: 8,188
-- What I learned: one total = only COUNT(*) in SELECT, no other columns.
SELECT COUNT(*) AS total_female_alumni
FROM alumni
WHERE gender = 'Female';

-- R2. How many alumni live in Islamabad?           Target: 1,347
SELECT COUNT(*) AS alumni_in_islamabad
FROM contact
WHERE city = 'Islamabad';

-- R3. MBA graduates 2015-2020?                     Target: 402
-- Learned: BETWEEN includes both end years.
SELECT COUNT(*) AS mba_2015_2020
FROM education
WHERE program = 'MBA'
  AND graduation_year BETWEEN 2015 AND 2020;

-- R4. Countries with 500+ alumni, biggest first.   Target: 5 countries
-- Learned: HAVING filters groups after counting.
SELECT country, COUNT(*) AS alumni
FROM contact
WHERE country IS NOT NULL
GROUP BY country
HAVING COUNT(*) >= 500
ORDER BY alumni DESC;

-- R5. How many alumni currently work at Engro?     Target: 59
-- Learned: LIKE '%Engro%' catches every Engro company name.
SELECT COUNT(*) AS engro_alumni
FROM alumni AS a
JOIN employment AS m ON m.roll_number = a.roll_number
WHERE m.current_company LIKE '%Engro%';

