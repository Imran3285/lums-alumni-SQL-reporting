/* =====================================================================
   REQUEST : Identify the 3 most senior alumni in each selected graduating
             batch (BSc 2011-2018, MBA/EMBA 1990-2018) for an alumni event.
   APPROACH: Score each alumnus by job title with CASE (1 = CEO/Founder/MD/
             Partner, 2 = Director/Head/VP, 3 = Manager/Lead, 4 = other),
             rank within each batch with ROW_NUMBER() OVER (PARTITION BY
             program, graduation_year), keep rank <= 3.
   QUALITY : Tested against real titles and fixed false matches such as
             "HR Partner", "Chief Manager", "Product Owner",
             "President Student Council" and "... - CEO Office".
             Deceased alumni excluded.
   RESULT  : 63 alumni across 21 batches (no EMBA graduates in 1990/1993/2003).
   SKILLS  : multi-table JOINs, LEFT JOIN, CASE, CTEs, window functions.
   ===================================================================== */
WITH ranked AS (
    SELECT
        e.roll_number,
        e.program,
        e.graduation_year,
        a.full_name,
        m.current_designation,
        m.current_company,
        c.personal_email,
        c.mobile,
        c.linkedin_url,
        CASE
            WHEN m.current_designation IS NULL                         THEN 9
            WHEN m.current_designation LIKE '%Assistant%'
              OR m.current_designation LIKE '%Associate%'
              OR m.current_designation LIKE '%Deputy%'
              OR m.current_designation LIKE '%Intern%'
              OR m.current_designation LIKE '%Trainee%'                THEN 4
            WHEN m.current_designation LIKE '%Student%'
              OR m.current_designation LIKE '%Committee%'
              OR m.current_designation LIKE '%Society%'
              OR m.current_designation LIKE '%Club%'                    THEN 4
            WHEN m.current_designation LIKE '%CEO Office%'
              OR m.current_designation LIKE '%CEO-1%'                   THEN 2
            WHEN m.current_designation LIKE '%Vice President%'
              OR m.current_designation LIKE 'VP%'
              OR m.current_designation LIKE '% VP%'                     THEN 2
            WHEN m.current_designation LIKE '%CEO%'
              OR m.current_designation LIKE '%Chief%Officer%'
              OR m.current_designation LIKE '%Cheif%Officer%'
              OR m.current_designation LIKE '%Founder%'
              OR m.current_designation LIKE '%Managing Director%'
              OR m.current_designation LIKE '%President%'
              OR m.current_designation LIKE '%Chairman%'
              OR m.current_designation LIKE '%Chairperson%'
              OR m.current_designation = 'Partner'
              OR m.current_designation LIKE 'Partner,%'
              OR m.current_designation LIKE 'Partner -%'
              OR m.current_designation LIKE '%Managing Partner%'
              OR m.current_designation LIKE '%Senior Partner'
              OR m.current_designation LIKE '%Equity Partner%'
              OR (m.current_designation LIKE '%Owner%'
                  AND m.current_designation NOT LIKE '%Product Owner%')  THEN 1
            WHEN m.current_designation LIKE '%Director%'
              OR m.current_designation LIKE '%Head%'
              OR m.current_designation LIKE '%General Manager%'
              OR m.current_designation LIKE '%Country Manager%'
              OR m.current_designation LIKE '%Principal%'               THEN 2
            WHEN m.current_designation LIKE '%Manager%'
              OR m.current_designation LIKE '%Lead%'                    THEN 3
            ELSE 4
        END AS seniority
    FROM education AS e
    INNER JOIN alumni     AS a ON a.roll_number = e.roll_number
    INNER JOIN contact    AS c ON c.roll_number = e.roll_number
    LEFT  JOIN employment AS m ON m.roll_number = e.roll_number
    WHERE (a.deceased IS NULL OR a.deceased <> 'Yes')
      AND (
            (e.program = 'BSc'  AND e.graduation_year IN (2011, 2012, 2013, 2018))
         OR (e.program = 'MBA'  AND e.graduation_year IN (1990, 1993, 2003, 2004, 2008, 2011, 2015, 2016, 2017, 2018))
         OR (e.program = 'EMBA' AND e.graduation_year IN (1990, 1993, 2003, 2004, 2008, 2011, 2015, 2016, 2017, 2018))
          )
),
numbered AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY program, graduation_year
                              ORDER BY seniority, full_name) AS rank_in_batch
    FROM ranked
)
SELECT
    program               AS [Program],
    graduation_year       AS [Batch],
    rank_in_batch         AS [Rank],
    roll_number           AS [Roll Number],
    full_name             AS [Full Name],
    current_designation   AS [Job Title],
    current_company       AS [Company],
    CASE seniority WHEN 1 THEN 'C-level / Founder'
                   WHEN 2 THEN 'Director / Head / VP'
                   WHEN 3 THEN 'Manager / Lead'
                   WHEN 4 THEN 'Other'
                   ELSE 'No job data' END  AS [Seniority],
    personal_email        AS [Email],
    mobile                AS [Mobile],
    linkedin_url          AS [LinkedIn]
FROM numbered
WHERE rank_in_batch <= 3
ORDER BY program, graduation_year, rank_in_batch;