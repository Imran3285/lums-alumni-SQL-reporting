/* =====================================================================
   Practice session 3 - JOIN ladder
   Learned: late September 2026 · Practice file on this database: November 2026
   Topics: INNER JOIN, LEFT JOIN + IS NULL (anti-join), NOT EXISTS,
           3-table joins, JOIN + GROUP BY
   Rule: name the tables first ("I need table __ and table __"), then write.
   ===================================================================== */

-- My own query: female alumni living outside Pakistan.         Result: 2,929
-- Learned: <> 'Pakistan' silently drops NULL countries (1,659 women have none).
SELECT COUNT(*) AS female_abroad
FROM alumni AS a
INNER JOIN contact AS c ON a.roll_number = c.roll_number
WHERE a.gender = 'Female'
  AND c.country <> 'Pakistan';

-- Same, broken down by country.
SELECT c.country, COUNT(*) AS female_abroad
FROM alumni AS a
INNER JOIN contact AS c ON a.roll_number = c.roll_number
WHERE a.gender = 'Female'
  AND c.country <> 'Pakistan'
GROUP BY c.country
ORDER BY female_abroad DESC;

-- D1. Female alumni in Dubai (alumni + contact).               Target: 298
SELECT COUNT(*) AS female_dubai
FROM alumni AS a
INNER JOIN contact AS c ON a.roll_number = c.roll_number
WHERE a.gender = 'Female'
  AND c.city = 'Dubai';

-- D2. BS graduates living abroad (education + contact).        Target: 1,359
SELECT COUNT(*) AS bs_abroad
FROM education AS e
INNER JOIN contact AS c ON e.roll_number = c.roll_number
WHERE e.program = 'BS'
  AND c.residence = 'Abroad';

-- D3. Alumni in Karachi working in Banking (contact + employment).  Target: 145
SELECT COUNT(*) AS karachi_banking
FROM contact AS c
INNER JOIN employment AS m ON c.roll_number = m.roll_number
WHERE c.city = 'Karachi'
  AND m.industry = 'Banking';

-- D4. SDSB graduates working at BAT (education + employment).  Target: 127
SELECT COUNT(*) AS sdsb_bat
FROM education AS e
INNER JOIN employment AS m ON e.roll_number = m.roll_number
WHERE e.school = 'SDSB'
  AND m.current_company = 'BAT';

-- D5. PhD graduates with NO employment record.                 Target: 49
-- Learned: to find who is MISSING, LEFT JOIN and look for the NULLs.
--          INNER JOIN would give 0 - it removes exactly these people.
SELECT COUNT(*) AS phd_no_job
FROM education AS e
LEFT JOIN employment AS m ON e.roll_number = m.roll_number
WHERE e.program = 'PhD'
  AND m.roll_number IS NULL;

-- D5b. Same answer with NOT EXISTS (no join).                  Target: 49
SELECT COUNT(*) AS phd_no_job
FROM education AS e
WHERE e.program = 'PhD'
  AND NOT EXISTS (SELECT 1 FROM employment AS m WHERE m.roll_number = e.roll_number);

-- D5c. Whole picture in one row: LEFT JOIN + SUM(CASE).        Target: 203 / 154 / 49
SELECT
    COUNT(*)                                                   AS total_phd,
    SUM(CASE WHEN m.roll_number IS NOT NULL THEN 1 ELSE 0 END) AS with_job,
    SUM(CASE WHEN m.roll_number IS NULL     THEN 1 ELSE 0 END) AS no_job
FROM education AS e
LEFT JOIN employment AS m ON e.roll_number = m.roll_number
WHERE e.program = 'PhD';

-- D6. Female MBA alumni in Lahore (3 tables).                  Target: 144
-- Learned: a third table is just one more JOIN line back to a.roll_number.
SELECT COUNT(*) AS female_mba_lahore
FROM alumni AS a
INNER JOIN education AS e ON a.roll_number = e.roll_number
INNER JOIN contact   AS c ON a.roll_number = c.roll_number
WHERE a.gender = 'Female'
  AND e.program = 'MBA'
  AND c.city = 'Lahore';

-- D7. Top 3 cities for female SBASSE alumni.                   Target: Lahore 471, Islamabad 51, Karachi 41
SELECT TOP 3 c.city, COUNT(*) AS alumni
FROM alumni AS a
INNER JOIN education AS e ON a.roll_number = e.roll_number
INNER JOIN contact   AS c ON a.roll_number = c.roll_number
WHERE a.gender = 'Female'
  AND e.school = 'SBASSE'
  AND c.city IS NOT NULL
GROUP BY c.city
ORDER BY alumni DESC;
