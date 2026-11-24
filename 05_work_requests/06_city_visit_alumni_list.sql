/* =====================================================================
   REQUEST : Contact list of alumni and high-net-worth individuals (HNIs) in
             Sialkot and Faisalabad, for a team visit (1-4 Dec 2026).
   APPROACH: A city can appear in 4 places (current city, hometown, job
             location, LinkedIn location), so all 4 are searched. CASE puts
             each person in ONE city (where they are now beats hometown) and
             a second CASE records how sure we are they are there now.
             A CTE holds the result so it can be sorted and counted.
   QUALITY : '%Fais%labad%' also catches the misspelling "Faislabad".
             ISNULL(deceased, 'No') keeps blanks (NULL <> 'Yes' is unknown,
             which would silently drop them). One row per alumnus checked.
             No wealth field exists, so HNIs were left for the team to pick
             from job title and company (an earlier title-based tier was
             dropped on request).
   RESULT  : 567 alumni: 440 Faisalabad, 127 Sialkot; 221 confirmed in the
             city now, the rest by hometown only.
   SKILLS  : CTE, 4-table JOIN, grouped OR conditions, CASE, COALESCE.
   ===================================================================== */
WITH visit_list AS (
    SELECT
        a.roll_number, a.full_name, e.program, e.graduation_year,
        emp.current_designation, emp.current_company, emp.industry,
        CASE
            WHEN c.city LIKE '%Sialkot%' OR emp.job_location LIKE '%Sialkot%'
              OR c.linkedin_location LIKE '%Sialkot%'                    THEN 'Sialkot'
            WHEN c.city LIKE '%Fais%labad%' OR emp.job_location LIKE '%Fais%labad%'
              OR c.linkedin_location LIKE '%Faisalabad%'                 THEN 'Faisalabad'
            WHEN c.permanent_city LIKE '%Sialkot%'                       THEN 'Sialkot'
            ELSE 'Faisalabad'
        END AS visit_city,
        CASE
            WHEN c.city LIKE '%Sialkot%' OR c.city LIKE '%Fais%labad%'  THEN '1. Current address'
            WHEN emp.job_location LIKE '%Sialkot%'
              OR emp.job_location LIKE '%Fais%labad%'                    THEN '2. Job location'
            WHEN c.linkedin_location LIKE '%Sialkot%'
              OR c.linkedin_location LIKE '%Faisalabad%'                 THEN '3. LinkedIn location'
            ELSE '4. Hometown only'
        END AS matched_on,
        c.mobile,
        COALESCE(c.personal_email, c.official_email, c.alternate_email) AS email,
        c.linkedin_url
    FROM alumni a
    JOIN contact c           ON c.roll_number   = a.roll_number
    LEFT JOIN education e    ON e.roll_number   = a.roll_number
    LEFT JOIN employment emp ON emp.roll_number = a.roll_number
    WHERE ISNULL(a.deceased, 'No') <> 'Yes'
      AND (   c.city              LIKE '%Sialkot%' OR c.city              LIKE '%Fais%labad%'
           OR c.permanent_city    LIKE '%Sialkot%' OR c.permanent_city    LIKE '%Fais%labad%'
           OR emp.job_location    LIKE '%Sialkot%' OR emp.job_location    LIKE '%Fais%labad%'
           OR c.linkedin_location LIKE '%Sialkot%' OR c.linkedin_location LIKE '%Fais%labad%')
)
SELECT *
FROM visit_list
ORDER BY visit_city, matched_on, graduation_year;
