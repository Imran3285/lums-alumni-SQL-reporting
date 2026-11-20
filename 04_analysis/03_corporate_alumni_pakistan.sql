/* Alumni currently working in the corporate sector in Pakistan
   Excludes: education, government, non-profit, research; students and interns */
SELECT
    a.roll_number          AS [Roll Number],
    a.full_name            AS [Full Name],
    e.program              AS [Program],
    e.major                AS [Major],
    e.graduation_year      AS [Graduation Year],
    m.current_designation  AS [Designation],
    m.current_company      AS [Company],
    m.industry             AS [Industry],
    c.city                 AS [City],
    c.personal_email       AS [Email],
    c.linkedin_url         AS [LinkedIn]
FROM alumni AS a
INNER JOIN education  AS e ON a.roll_number = e.roll_number
INNER JOIN employment AS m ON a.roll_number = m.roll_number
INNER JOIN contact    AS c ON a.roll_number = c.roll_number
WHERE c.country = 'Pakistan'
  AND (a.deceased IS NULL OR a.deceased <> 'Yes')
  AND m.current_company IS NOT NULL
  AND m.industry IS NOT NULL
  -- remove education, government, non-profit and research sectors
  AND m.industry NOT LIKE '%Educat%'    AND m.industry NOT LIKE '%Academ%'
  AND m.industry NOT LIKE '%Universit%' AND m.industry NOT LIKE '%Teach%'
  AND m.industry NOT LIKE '%School%'    AND m.industry NOT LIKE '%LUMS%'
  AND m.industry NOT LIKE '%E-learning%' AND m.industry NOT LIKE '%Research%'
  AND m.industry NOT LIKE '%Think Tank%' AND m.industry NOT LIKE '%Govern%'
  AND m.industry NOT LIKE '%Govt%'      AND m.industry NOT LIKE '%Ministry%'
  AND m.industry NOT LIKE '%Judiciary%' AND m.industry NOT LIKE '%Law Enforcement%'
  AND m.industry NOT LIKE '%Public Policy%' AND m.industry NOT LIKE '%Public Safety%'
  AND m.industry NOT LIKE '%Defen%'     AND m.industry NOT LIKE '%Political%'
  AND m.industry NOT LIKE '%Profit%'    AND m.industry NOT LIKE '%Proft%'
  AND m.industry NOT LIKE '%NGO%'       AND m.industry NOT LIKE '%Charity%'
  AND m.industry NOT LIKE '%Philanthrop%' AND m.industry NOT LIKE '%Fundrais%'
  AND m.industry NOT LIKE '%Civic%'     AND m.industry NOT LIKE '%Social%'
  AND m.industry NOT LIKE '%Development Sector%' AND m.industry NOT LIKE '%Development Agency%'
  AND m.industry <> 'Development'      AND m.industry NOT LIKE '%Trade & Development%'
  AND m.industry NOT LIKE '%International Affairs%'
  AND m.industry NOT LIKE '%Religious%' AND m.industry NOT LIKE '%Libraries%'
  AND m.industry NOT LIKE '%Museums%'   AND m.industry NOT LIKE '%Peacebuilding%'
  AND m.industry NOT LIKE '%Community%' AND m.industry NOT LIKE '%Not Applicable%'
  AND m.industry NOT LIKE '%Other%'
  -- universities listed as the employer under a business industry
  AND m.current_company NOT LIKE '%Universit%'
  AND m.current_company NOT LIKE '%LUMS%'
  AND m.current_company NOT LIKE '%Lahore University of Management%'
  AND m.current_company NOT LIKE '%College%'
  AND m.current_company NOT LIKE '%School%'
  AND m.current_company NOT LIKE '%Institute%'
  AND m.current_company NOT LIKE '%State Bank of Pakistan%'   -- central bank (regulator), not corporate
  -- remove students, interns and academic assistants
  AND (m.current_designation IS NULL OR (
       m.current_designation NOT LIKE '%Intern'      AND m.current_designation NOT LIKE 'Intern %'
   AND m.current_designation NOT LIKE '% Intern %'   AND m.current_designation NOT LIKE '%Internship%'
   AND m.current_designation NOT LIKE '%Internee%'
   AND m.current_designation NOT LIKE '%Student%'
   AND m.current_designation NOT LIKE '%Research Assistant%'
   AND m.current_designation NOT LIKE '%Teaching Assistant%'
   AND m.current_designation NOT LIKE '%Trainee%'))
ORDER BY m.industry, m.current_company, a.full_name;
