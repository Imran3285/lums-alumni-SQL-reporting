/* =====================================================================
   LOAD VALIDATION - did every row arrive, and do the tables link up?
   Run straight after loading the data.
   ===================================================================== */

-- 1. Row counts per table
--    Expected: alumni 22,794 | education 22,794 | employment 20,196 | contact 22,794
SELECT 'alumni' AS tbl, COUNT(*) AS n FROM alumni
UNION ALL SELECT 'education',  COUNT(*) FROM education
UNION ALL SELECT 'employment', COUNT(*) FROM employment
UNION ALL SELECT 'contact',    COUNT(*) FROM contact;

-- 2. Referential check: every person has exactly one education and contact row
--    Expected: 0 and 0  (LEFT JOIN ... IS NULL finds people with no match)
SELECT
    SUM(CASE WHEN e.roll_number IS NULL THEN 1 ELSE 0 END) AS missing_education,
    SUM(CASE WHEN c.roll_number IS NULL THEN 1 ELSE 0 END) AS missing_contact
FROM alumni AS a
LEFT JOIN education AS e ON e.roll_number = a.roll_number
LEFT JOIN contact   AS c ON c.roll_number = a.roll_number;

-- 3. No duplicate people in the employment table
--    Expected: 0 rows
SELECT roll_number, COUNT(*) AS rows_per_person
FROM employment
GROUP BY roll_number
HAVING COUNT(*) > 1;

-- 4. Reconciliation: people with job data + without = all alumni
--    Expected: 20,196 + 2,598 = 22,794
SELECT
    SUM(CASE WHEN m.roll_number IS NOT NULL THEN 1 ELSE 0 END) AS with_job_data,
    SUM(CASE WHEN m.roll_number IS NULL     THEN 1 ELSE 0 END) AS without_job_data,
    COUNT(*)                                                   AS total
FROM alumni AS a
LEFT JOIN employment AS m ON m.roll_number = a.roll_number;
