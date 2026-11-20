/* =====================================================================
   Simplified, teachable version of 01 - same structure, fewer title rules.
   Built in 4 steps:
     1. JOIN + WHERE        -> everyone in the selected batches (2,501)
     2. CASE                -> seniority score from job title
     3. ROW_NUMBER          -> number people 1,2,3... within each batch
     4. CTE + WHERE rn <= 3 -> top 3 per batch (63 rows)
   Trade-off: shorter, but treats Partner/Owner/Chairman as "other".
   ===================================================================== */
WITH ranked AS (
    SELECT
        e.roll_number, a.full_name, e.program, e.graduation_year,
        m.current_designation, m.current_company,
        c.personal_email, c.mobile, c.linkedin_url,
        ROW_NUMBER() OVER (
            PARTITION BY e.program, e.graduation_year
            ORDER BY CASE
                         WHEN m.current_designation LIKE '%CEO%'
                           OR m.current_designation LIKE '%Founder%'
                           OR m.current_designation LIKE '%Managing Director%' THEN 1
                         WHEN m.current_designation LIKE '%Director%'
                           OR m.current_designation LIKE '%Head%'              THEN 2
                         WHEN m.current_designation LIKE '%Manager%'           THEN 3
                         ELSE 4
                     END,
                     a.full_name
        ) AS rn
    FROM education AS e
    JOIN alumni  AS a ON a.roll_number = e.roll_number
    JOIN contact AS c ON c.roll_number = e.roll_number
    LEFT JOIN employment AS m ON m.roll_number = e.roll_number
    WHERE (a.deceased IS NULL OR a.deceased <> 'Yes')
      AND ( (e.program = 'BSc' AND e.graduation_year IN (2011, 2012, 2013, 2018))
         OR (e.program IN ('MBA', 'EMBA')
             AND e.graduation_year IN (1990, 1993, 2003, 2004, 2008, 2011, 2015, 2016, 2017, 2018)) )
)
SELECT
    program AS [Program], graduation_year AS [Batch], rn AS [Rank],
    roll_number AS [Roll Number], full_name AS [Full Name],
    current_designation AS [Job Title], current_company AS [Company],
    personal_email AS [Email], mobile AS [Mobile], linkedin_url AS [LinkedIn]
FROM ranked
WHERE rn <= 3
ORDER BY program, graduation_year, rn;
