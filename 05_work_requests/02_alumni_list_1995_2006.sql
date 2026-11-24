/* =====================================================================
   REQUEST : Admissions team needed alumni from the 1995-2006 graduating
             batches, with name, program, year and email, for the UG
             Admission Launch email campaign.
   APPROACH: BETWEEN for the year range; exclude deceased alumni; keep only
             people with at least one email; COALESCE gives one usable
             email per person (personal, else official).
   QUALITY : 39 emails were shared by alumni with two degrees in the range -
             flagged so nobody receives the campaign twice.
   RESULT  : 2,221 alumni delivered to the requesting team.
   SKILLS  : JOINs, BETWEEN, NULL handling, COALESCE, ORDER BY.
   ===================================================================== */
SELECT
    a.roll_number                                AS [Roll Number],
    a.full_name                                  AS [Full Name],
    e.program                                    AS [Program],
    e.graduation_year                            AS [Graduation Year],
    c.personal_email                             AS [Personal Email],
    c.official_email                             AS [Official Email],
    COALESCE(c.personal_email, c.official_email) AS [Email to Use]
FROM alumni AS a
JOIN education AS e ON e.roll_number = a.roll_number
JOIN contact   AS c ON c.roll_number = a.roll_number
WHERE e.graduation_year BETWEEN 1995 AND 2006
  AND (a.deceased IS NULL OR a.deceased <> 'Yes')
  AND (c.personal_email IS NOT NULL OR c.official_email IS NOT NULL)
ORDER BY e.graduation_year, e.program, a.full_name;
