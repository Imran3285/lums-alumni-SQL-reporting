/* =====================================================================
   REQUEST : Find alumni currently working in the healthcare sector in the UK.
   APPROACH: Healthcare = healthcare industries OR any NHS employer;
             "in the UK" = job location in the UK, falling back to home
             country when job location is missing; CASE splits Healthcare vs
             Pharma & Life Sciences.
   QUALITY : '%Wales%' matched "New South Wales" (Australia) and "North
             Wales, Pennsylvania" - replaced with '%United Kingdom%'.
             Industry value is 'Medical Device' (singular) - checked with
             SELECT DISTINCT before filtering. Excluded a UK resident whose
             job is located in Pakistan.
   RESULT  : 31 alumni (19 healthcare incl. NHS trusts, 12 pharma/life
             sciences incl. AstraZeneca, GSK, CSL).
   SKILLS  : 4-table JOIN, grouped OR/AND conditions, CASE, data validation.
   ===================================================================== */
SELECT
    a.roll_number            AS [Roll Number],
    a.full_name              AS [Full Name],
    e.program                AS [Program],
    e.graduation_year        AS [Batch],
    m.current_designation    AS [Job Title],
    m.current_company        AS [Company],
    CASE
        WHEN m.industry IN ('Pharmaceuticals', 'Biotechnology', 'Medical Device')
             THEN 'Pharma & Life Sciences'
        ELSE 'Healthcare'
    END                      AS [Sector],
    m.industry               AS [Industry],
    m.job_location           AS [Job Location],
    c.personal_email         AS [Email],
    c.linkedin_url           AS [LinkedIn]
FROM employment AS m
JOIN alumni    AS a ON a.roll_number = m.roll_number
JOIN education AS e ON e.roll_number = m.roll_number
JOIN contact   AS c ON c.roll_number = m.roll_number
WHERE ( m.industry IN ('Hospital & Health Care', 'Mental Health Care', 'Medical Practice',
                       'Health, Wellness & Fitness',
                       'Pharmaceuticals', 'Biotechnology', 'Medical Device')
        OR m.current_company LIKE '%NHS%' )
  AND ( m.job_location LIKE '%United Kingdom%'
        OR (c.country = 'United Kingdom'
            AND (m.job_location IS NULL OR m.job_location NOT LIKE '%,%')) )
  AND (m.job_location IS NULL OR m.job_location NOT LIKE '%Pakistan%')
  AND (a.deceased IS NULL OR a.deceased <> 'Yes')
ORDER BY [Sector], m.current_company, a.full_name;
