/* =====================================================================
   SEGMENTATION & ANALYSIS
   Age bands, top employers per school, healthcare alumni, career movement,
   and missing job data by decade.
   ===================================================================== */

-- C1. Age bands of alumni (where date of birth is known).
--     Skill: DATEDIFF + CASE bucketing.  Healthcare: patients by age
--     group (0-17, 18-64, 65+) - a very common HSE report.
WITH ages AS (
    SELECT roll_number,
           DATEDIFF(YEAR, date_of_birth, GETDATE())
           - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, date_of_birth, GETDATE()), date_of_birth) > GETDATE()
                  THEN 1 ELSE 0 END AS age
    FROM alumni
    WHERE date_of_birth IS NOT NULL
)
SELECT
    CASE WHEN age < 25 THEN '1. Under 25'
         WHEN age < 35 THEN '2. 25-34'
         WHEN age < 45 THEN '3. 35-44'
         WHEN age < 55 THEN '4. 45-54'
         ELSE               '5. 55+' END   AS age_band,
    COUNT(*)                              AS alumni
FROM ages
GROUP BY CASE WHEN age < 25 THEN '1. Under 25'
              WHEN age < 35 THEN '2. 25-34'
              WHEN age < 45 THEN '3. 35-44'
              WHEN age < 55 THEN '4. 45-54'
              ELSE               '5. 55+' END
ORDER BY age_band;

-- C2. Top 3 employers for each school.
--     Skill: ROW_NUMBER / DENSE_RANK in a CTE.  Healthcare: top 3
--     diagnoses or procedures per hospital.
WITH ranked AS (
    SELECT
        e.school,
        m.current_company,
        COUNT(*) AS alumni,
        DENSE_RANK() OVER (PARTITION BY e.school ORDER BY COUNT(*) DESC) AS rnk
    FROM education AS e
    INNER JOIN employment AS m ON m.roll_number = e.roll_number
    WHERE e.school IS NOT NULL AND m.current_company IS NOT NULL
    GROUP BY e.school, m.current_company
)
SELECT school, rnk, current_company, alumni
FROM ranked
WHERE rnk <= 3
ORDER BY school, rnk;

-- C3. Alumni working in healthcare - by country and industry.
--     Skill: LIKE patterns + GROUP BY.  (A nice talking point for an
--     HSE interview: "I segmented alumni already in the health sector.")
SELECT
    COALESCE(c.country, 'Unknown')   AS country,
    m.industry,
    COUNT(*)                         AS alumni
FROM employment AS m
INNER JOIN contact AS c ON c.roll_number = m.roll_number
WHERE m.industry IN ('Hospital & Health Care', 'Health, Wellness & Fitness',
                     'Pharmaceuticals', 'Medical Device', 'Mental Health Care',
                     'Medical Practice', 'Biotechnology')
GROUP BY COALESCE(c.country, 'Unknown'), m.industry
ORDER BY alumni DESC;

-- C4. Career movement: alumni whose current LinkedIn employer differs
--     from the last employer in alumni-office records, by industry.
--     Skill: comparing two sources, case-insensitive matching.
SELECT
    m.industry,
    COUNT(*)                                                         AS with_both_sources,
    SUM(CASE WHEN LOWER(m.last_experience_company) <> LOWER(m.current_company)
             THEN 1 ELSE 0 END)                                      AS changed_employer,
    CAST(100.0 * SUM(CASE WHEN LOWER(m.last_experience_company) <> LOWER(m.current_company)
                          THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS pct_changed
FROM employment AS m
WHERE m.last_experience_company IS NOT NULL
  AND m.current_company IS NOT NULL
  AND m.industry IS NOT NULL
GROUP BY m.industry
HAVING COUNT(*) >= 50
ORDER BY pct_changed DESC;

-- C5. Alumni with NO employment record, by graduating decade.
--     Skill: LEFT JOIN anti-join (... IS NULL).  Healthcare: patients
--     referred but never given an appointment.
SELECT
    (e.graduation_year / 10) * 10                                     AS decade,
    COUNT(*)                                                          AS alumni,
    SUM(CASE WHEN m.roll_number IS NULL THEN 1 ELSE 0 END)            AS no_job_data,
    CAST(100.0 * SUM(CASE WHEN m.roll_number IS NULL THEN 1 ELSE 0 END)
         / COUNT(*) AS DECIMAL(5,1))                                  AS pct_missing
FROM education AS e
LEFT JOIN employment AS m ON m.roll_number = e.roll_number
WHERE e.graduation_year IS NOT NULL
GROUP BY (e.graduation_year / 10) * 10
ORDER BY decade;
