/* =====================================================================
   DATA QUALITY CHECKS
   Run after loading, before any analysis. Answers: how complete is the data,
   are there duplicate people, and do two sources disagree?
   Healthcare equivalent: missing GP/Eircode, duplicate patient registrations.
   ===================================================================== */

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
