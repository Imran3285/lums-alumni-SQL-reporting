/* =====================================================================
   LUMS Alumni Analytics - SQL Portfolio (T-SQL, Azure SQL Database)
   Author : <your name>          Last updated: 2026-11-14
   Data   : 22,794 alumni records merged from 4 sources (alumni office
            records, LinkedIn scrapes), cleaned and loaded into a
            4-table relational model keyed on roll_number.
   Tables : alumni, education, contact (1 row per person)
            employment (0 or 1 row per person)
   Each query starts with the business question it answers and the
   skill it shows. Healthcare equivalents are noted for interviews.
   ===================================================================== */


/* ---------------------------------------------------------------------
   SECTION A - DATA QUALITY & GOVERNANCE
   (HSE: "fragmented data landscapes", "data quality", "GDPR")
   --------------------------------------------------------------------- */

-- A1. Completeness report: % of records with each key field filled.
--     Skill: COUNT(column) ignores NULLs.  Healthcare: % of patient
--     records with a valid GP, Eircode or date of birth.
SELECT
    COUNT(*)                                                     AS total_records,
    CAST(100.0 * COUNT(c.personal_email) / COUNT(*) AS DECIMAL(5,1)) AS pct_email,
    CAST(100.0 * COUNT(c.mobile)         / COUNT(*) AS DECIMAL(5,1)) AS pct_mobile,
    CAST(100.0 * COUNT(c.country)        / COUNT(*) AS DECIMAL(5,1)) AS pct_country,
    CAST(100.0 * COUNT(c.linkedin_url)   / COUNT(*) AS DECIMAL(5,1)) AS pct_linkedin,
    CAST(100.0 * COUNT(a.date_of_birth)  / COUNT(*) AS DECIMAL(5,1)) AS pct_dob,
    CAST(100.0 * COUNT(m.current_company)/ COUNT(*) AS DECIMAL(5,1)) AS pct_employer
FROM alumni AS a
INNER JOIN contact    AS c ON c.roll_number = a.roll_number
LEFT  JOIN employment AS m ON m.roll_number = a.roll_number;

-- A2. Possible duplicate people: same personal email on 2+ roll numbers.
--     Skill: GROUP BY + HAVING, STRING_AGG.  Healthcare: duplicate
--     patient registrations (same name + date of birth).
SELECT
    c.personal_email,
    COUNT(*)                                   AS roll_numbers,
    STRING_AGG(a.roll_number, ', ')            AS rolls,
    STRING_AGG(e.program, ', ')                AS programs
FROM contact AS c
INNER JOIN alumni    AS a ON a.roll_number = c.roll_number
INNER JOIN education AS e ON e.roll_number = c.roll_number
WHERE c.personal_email IS NOT NULL
GROUP BY c.personal_email
HAVING COUNT(*) > 1
ORDER BY roll_numbers DESC;

-- A3. Inconsistent records: country says Pakistan but the LinkedIn
--     location points abroad (candidates for a data refresh).
--     Skill: multi-condition WHERE, NOT LIKE with CONCAT.
SELECT a.roll_number, a.full_name, c.country, c.linkedin_location
FROM contact AS c
INNER JOIN alumni AS a ON a.roll_number = c.roll_number
WHERE c.country = 'Pakistan'
  AND c.linkedin_location IS NOT NULL
  AND c.linkedin_location NOT LIKE '%Pakistan%'
  AND c.linkedin_location NOT LIKE '%Lahore%'
  AND c.linkedin_location NOT LIKE '%Karachi%'
  AND c.linkedin_location NOT LIKE '%Islamabad%'
ORDER BY a.full_name;

-- A4. GDPR-safe view: personal identifiers removed or masked so the
--     data can be shared for reporting (e.g. a Power BI dashboard).
--     Skill: CREATE VIEW, RIGHT(), data minimisation.
CREATE OR ALTER VIEW vw_alumni_reporting AS
SELECT
    a.roll_number,
    a.gender,
    e.program, e.major, e.school, e.graduation_year,
    m.industry, m.current_company,
    c.city, c.country, c.residence,
    CASE WHEN c.mobile IS NULL THEN NULL
         ELSE CONCAT('*******', RIGHT(c.mobile, 3)) END       AS mobile_masked,
    CASE WHEN c.personal_email IS NOT NULL THEN 'Yes' ELSE 'No' END AS has_email
FROM alumni AS a
INNER JOIN education  AS e ON e.roll_number = a.roll_number
INNER JOIN contact    AS c ON c.roll_number = a.roll_number
LEFT  JOIN employment AS m ON m.roll_number = a.roll_number
WHERE a.deceased IS NULL OR a.deceased <> 'Yes';
GO


/* ---------------------------------------------------------------------
   SECTION B - KPI REPORTING
   (HSE: "performance metrics", monthly/annual reporting)
   --------------------------------------------------------------------- */

-- B1. Headline KPIs in one row for a management summary.
--     Skill: conditional aggregation (SUM CASE).
SELECT
    COUNT(*)                                                            AS total_alumni,
    SUM(CASE WHEN c.residence = 'Pakistan' THEN 1 ELSE 0 END)           AS in_pakistan,
    SUM(CASE WHEN c.residence = 'Abroad'   THEN 1 ELSE 0 END)           AS abroad,
    CAST(100.0 * SUM(CASE WHEN a.gender = 'Female' THEN 1 ELSE 0 END)
         / COUNT(*) AS DECIMAL(5,1))                                    AS pct_female,
    CAST(100.0 * COUNT(m.current_company) / COUNT(*) AS DECIMAL(5,1))   AS pct_known_employer
FROM alumni AS a
INNER JOIN contact    AS c ON c.roll_number = a.roll_number
LEFT  JOIN employment AS m ON m.roll_number = a.roll_number;

-- B2. Alumni by school and program, with share of school total.
--     Skill: window function over a GROUP BY (SUM() OVER PARTITION).
SELECT
    e.school,
    e.program,
    COUNT(*)                                                            AS alumni,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY e.school)
         AS DECIMAL(5,1))                                               AS pct_of_school
FROM education AS e
WHERE e.school IS NOT NULL
GROUP BY e.school, e.program
ORDER BY e.school, alumni DESC;

-- B3. Trend: graduates per year with year-on-year change.
--     Skill: CTE + LAG.  Healthcare: monthly referrals / attendances
--     and % change vs previous period.
WITH yearly AS (
    SELECT graduation_year, COUNT(*) AS graduates
    FROM education
    WHERE graduation_year IS NOT NULL
    GROUP BY graduation_year
)
SELECT
    graduation_year,
    graduates,
    LAG(graduates) OVER (ORDER BY graduation_year)                      AS previous_year,
    CAST(100.0 * (graduates - LAG(graduates) OVER (ORDER BY graduation_year))
         / NULLIF(LAG(graduates) OVER (ORDER BY graduation_year), 0)
         AS DECIMAL(6,1))                                               AS yoy_pct_change
FROM yearly
ORDER BY graduation_year;

-- B4. Running total of the alumni base over time.
--     Skill: cumulative SUM() OVER (ORDER BY ...).
SELECT
    graduation_year,
    COUNT(*)                                                 AS graduates,
    SUM(COUNT(*)) OVER (ORDER BY graduation_year)            AS cumulative_alumni
FROM education
WHERE graduation_year IS NOT NULL
GROUP BY graduation_year
ORDER BY graduation_year;


/* ---------------------------------------------------------------------
   SECTION C - SEGMENTATION & ANALYSIS
   --------------------------------------------------------------------- */

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
                     'Pharmaceuticals', 'Medical Devices', 'Mental Health Care',
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


/* ---------------------------------------------------------------------
   SECTION D - REUSABLE REPORTING (stored procedure)
   (HSE: SSRS / Power BI paginated reports call procedures like this)
   --------------------------------------------------------------------- */

-- D1. Parameterised report: alumni list for any country and industry.
--     Skill: CREATE PROCEDURE with parameters, optional filters.
CREATE OR ALTER PROCEDURE usp_alumni_by_country_industry
    @country  NVARCHAR(60),
    @industry NVARCHAR(100) = NULL      -- optional
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        a.full_name          AS [Full Name],
        e.program            AS [Program],
        e.graduation_year    AS [Graduation Year],
        m.current_designation AS [Job Title],
        m.current_company    AS [Company],
        m.industry           AS [Industry],
        c.city               AS [City]
    FROM alumni AS a
    INNER JOIN education  AS e ON e.roll_number = a.roll_number
    INNER JOIN employment AS m ON m.roll_number = a.roll_number
    INNER JOIN contact    AS c ON c.roll_number = a.roll_number
    WHERE c.country = @country
      AND (@industry IS NULL OR m.industry = @industry)
      AND (a.deceased IS NULL OR a.deceased <> 'Yes')
    ORDER BY e.graduation_year DESC, a.full_name;
END;
GO

-- How to run it:
EXEC usp_alumni_by_country_industry @country = 'Ireland';
EXEC usp_alumni_by_country_industry @country = 'United Kingdom', @industry = 'Hospital & Health Care';
