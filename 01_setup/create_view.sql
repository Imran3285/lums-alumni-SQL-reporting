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
