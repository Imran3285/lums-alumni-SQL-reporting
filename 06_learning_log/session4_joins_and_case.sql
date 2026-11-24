/* =====================================================================
   Practice session 4 - JOIN + CASE
   Learned: October 2026 · Practice file on this database: November 2026
   Topics: CASE labels, GROUP BY a CASE, SUM(CASE) pivots, CTEs
   Rules: first true WHEN wins; put IS NULL checks first;
          GROUP BY the whole CASE (or use a CTE to name it once).
   ===================================================================== */

-- C1. Recent (2020+) vs earlier graduates.                     Target: Earlier 13,286 / Recent 9,507 / Unknown 1
SELECT
    CASE WHEN graduation_year >= 2020 THEN 'Recent (2020+)'
         WHEN graduation_year <  2020 THEN 'Earlier'
         ELSE 'Unknown' END AS grad_group,
    COUNT(*) AS alumni
FROM education
GROUP BY CASE WHEN graduation_year >= 2020 THEN 'Recent (2020+)'
              WHEN graduation_year <  2020 THEN 'Earlier'
              ELSE 'Unknown' END
ORDER BY alumni DESC;

-- C2. Alumni by region.                                        Target: Pakistan 11,065 / Rest of world 6,451 / Unknown 3,615 / Gulf 1,663
SELECT
    CASE WHEN country IS NULL THEN 'Unknown'
         WHEN country = 'Pakistan' THEN 'Pakistan'
         WHEN country IN ('United Arab Emirates','Saudi Arabia','Qatar','Oman','Kuwait','Bahrain') THEN 'Gulf'
         ELSE 'Rest of world' END AS region,
    COUNT(*) AS alumni
FROM contact
GROUP BY CASE WHEN country IS NULL THEN 'Unknown'
              WHEN country = 'Pakistan' THEN 'Pakistan'
              WHEN country IN ('United Arab Emirates','Saudi Arabia','Qatar','Oman','Kuwait','Bahrain') THEN 'Gulf'
              ELSE 'Rest of world' END
ORDER BY alumni DESC;

-- J1. Degree level by gender - CTE version, female/male side by side.
--     Target: Undergraduate 6,071 / 8,546 | Postgraduate 2,046 / 4,622 | Doctorate 70 / 111
-- Learned: GROUP BY runs before SELECT, so it can't use a SELECT alias.
--          A CTE creates degree_level first, so the outer query can use it.
--          Note: excludes 5 alumni with an undeclared program and 1,323 with no gender.
WITH levels AS (
    SELECT
        a.gender,
        CASE
            WHEN e.program IN ('BSc','BS','BA','BA-LLB (Hons)') THEN 'Undergraduate'
            WHEN e.program IN ('MBA','EMBA','MS','MSc','MPhil')  THEN 'Postgraduate'
            WHEN e.program = 'PhD'                               THEN 'Doctorate'
            ELSE 'Unknown'
        END AS degree_level
    FROM education AS e
    INNER JOIN alumni AS a ON a.roll_number = e.roll_number
    WHERE a.gender IS NOT NULL
)
SELECT
    degree_level                                        AS [Degree Level],
    SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END)  AS [Female],
    SUM(CASE WHEN gender = 'Male'   THEN 1 ELSE 0 END)  AS [Male],
    COUNT(*)                                            AS [Total]
FROM levels
WHERE degree_level <> 'Unknown'
GROUP BY degree_level
ORDER BY [Total] DESC;

-- J2. Job data status per school (LEFT JOIN + CASE).           Target: SDSB 7,262 have / 666 don't ...
SELECT
    e.school,
    CASE WHEN m.roll_number IS NULL THEN 'No job data' ELSE 'Has job data' END AS job_status,
    COUNT(*) AS alumni
FROM education AS e
LEFT JOIN employment AS m ON e.roll_number = m.roll_number
WHERE e.school IS NOT NULL
GROUP BY e.school,
         CASE WHEN m.roll_number IS NULL THEN 'No job data' ELSE 'Has job data' END
ORDER BY e.school, job_status;

-- J3. Tech vs non-tech per school, as two columns.             Target: SBASSE 1,646 / 2,918 ...
-- Learned: NULL industries fall in NEITHER column - NOT IN (...) is never true for NULL.
SELECT
    e.school,
    SUM(CASE WHEN m.industry IN ('Computer Software','Information Technology & Services','Internet')
             THEN 1 ELSE 0 END) AS tech,
    SUM(CASE WHEN m.industry NOT IN ('Computer Software','Information Technology & Services','Internet')
             THEN 1 ELSE 0 END) AS non_tech
FROM education AS e
INNER JOIN employment AS m ON e.roll_number = m.roll_number
WHERE e.school IS NOT NULL
GROUP BY e.school
ORDER BY tech DESC;

-- J4. Female alumni in Pakistan by degree level (3 tables).    Target: UG 2,552 / PG 1,020 / Doctorate 28
SELECT
    CASE
        WHEN e.program IN ('BSc','BS','BA','BA-LLB (Hons)') THEN 'Undergraduate'
        WHEN e.program IN ('MBA','EMBA','MS','MSc','MPhil')  THEN 'Postgraduate'
        WHEN e.program = 'PhD'                               THEN 'Doctorate'
        ELSE 'Unknown'
    END AS degree_level,
    COUNT(*) AS alumni
FROM alumni AS a
INNER JOIN education AS e ON a.roll_number = e.roll_number
INNER JOIN contact   AS c ON a.roll_number = c.roll_number
WHERE a.gender = 'Female'
  AND c.country = 'Pakistan'
GROUP BY
    CASE
        WHEN e.program IN ('BSc','BS','BA','BA-LLB (Hons)') THEN 'Undergraduate'
        WHEN e.program IN ('MBA','EMBA','MS','MSc','MPhil')  THEN 'Postgraduate'
        WHEN e.program = 'PhD'                               THEN 'Doctorate'
        ELSE 'Unknown'
    END
ORDER BY alumni DESC;

-- J5. Alumni in Hospital & Health Care: Pakistan vs abroad.    Target: Abroad 154 / Pakistan 69 / Unknown 30
SELECT
    CASE WHEN c.country IS NULL THEN 'Unknown'
         WHEN c.country = 'Pakistan' THEN 'Pakistan'
         ELSE 'Abroad' END AS location,
    COUNT(*) AS alumni
FROM employment AS m
INNER JOIN contact AS c ON m.roll_number = c.roll_number
WHERE m.industry = 'Hospital & Health Care'
GROUP BY CASE WHEN c.country IS NULL THEN 'Unknown'
              WHEN c.country = 'Pakistan' THEN 'Pakistan'
              ELSE 'Abroad' END
ORDER BY alumni DESC;
