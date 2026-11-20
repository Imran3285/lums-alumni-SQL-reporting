/* =====================================================================
   KPI REPORTING
   Management-summary queries: headline KPIs, shares, trends and running totals.
   Healthcare equivalent: monthly attendances, % change vs previous period.
   ===================================================================== */

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
