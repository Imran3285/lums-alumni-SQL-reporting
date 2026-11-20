/* =====================================================================
   REPORTING VIEWS
   Saved queries that behave like tables, so reports do not repeat the joins.
   Azure Query editor: run EACH CREATE VIEW on its own (it must be the only
   statement in its batch - GO is not supported in the browser editor).
   ===================================================================== */

-- V1. Full alumni profile: one row per person, all four tables joined.
CREATE VIEW vw_alumni_profile AS
SELECT
    a.roll_number, a.full_name, a.gender,
    e.program, e.major, e.school, e.graduation_year,
    m.current_designation, m.current_company, m.industry,
    c.city, c.country, c.residence, c.personal_email, c.linkedin_url
FROM alumni AS a
INNER JOIN education  AS e ON a.roll_number = e.roll_number
LEFT  JOIN employment AS m ON a.roll_number = m.roll_number
INNER JOIN contact    AS c ON a.roll_number = c.roll_number;

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
