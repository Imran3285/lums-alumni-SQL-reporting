/* =====================================================================
   REQUEST : Current organisation, designation and higher education for a
             list of scholarship recipients sent by the Development team
             (163 names across 11 scholarship funds, in an Excel layout with
             several side-by-side blocks).
   APPROACH: Parsed every block of the Excel file into one list (fund, roll
             number, name), loaded it into a table variable, then matched:
               1. roll number (dashes removed)
               2. a second roll number given in brackets after some names
               3. exact name, only when exactly ONE alumnus has that name
             OUTER APPLY + HAVING COUNT(*) = 1 makes the name match safe.
             Output kept in the requester's own column layout.
   QUALITY : Every name on the list is returned, matched or not, with a
             matched_by column so name matches can be checked by eye.
             Two name matches were flagged as likely namesakes (graduation
             year decades away from the roll number year). Roll numbers
             starting 2025-2027 are current students, not alumni yet.
   RESULT  : 148 of 163 matched (140 by roll number, 8 by name), 15 not found.
   SKILLS  : Table variable, LEFT JOIN, OUTER APPLY, HAVING, COALESCE, CASE.
   NOTE    : The real list is not stored here; 3 placeholder rows show the
             format.
   ===================================================================== */
DECLARE @list TABLE (sr_no INT, fund NVARCHAR(100), roll_number NVARCHAR(20),
                     alt_roll NVARCHAR(20), list_name NVARCHAR(100));
INSERT INTO @list (sr_no, fund, roll_number, alt_roll, list_name) VALUES
(1, 'Example Scholarship Fund', '2014-02-0001', NULL,           'Example Name One'),
(2, 'Example Scholarship Fund', '2017-02-0002', '2018-09-0003', 'Example Name Two'),
(3, 'Example Scholarship Fund', '2021-09-0004', NULL,           'Example Name Three');

WITH matched AS (
    SELECT
        l.*,
        COALESCE(r.roll_number, r2.roll_number, n.roll_number) AS db_roll,
        CASE WHEN r.roll_number  IS NOT NULL THEN 'Roll number'
             WHEN r2.roll_number IS NOT NULL THEN 'Second roll number'
             WHEN n.roll_number  IS NOT NULL THEN 'Name'
             ELSE 'Not found' END                          AS matched_by
    FROM @list l
    LEFT JOIN alumni r  ON r.roll_number  = REPLACE(l.roll_number, '-', '')
    LEFT JOIN alumni r2 ON r2.roll_number = REPLACE(l.alt_roll, '-', '')
                       AND r.roll_number IS NULL
    OUTER APPLY (
        SELECT MIN(a.roll_number) AS roll_number
        FROM alumni a
        WHERE r.roll_number IS NULL AND r2.roll_number IS NULL
          AND a.full_name = l.list_name
        HAVING COUNT(*) = 1
    ) n
)
SELECT
    m.sr_no                  AS [Sr. No],
    m.fund                   AS [Scholarship Fund],
    m.roll_number            AS list_roll_number,
    m.list_name,
    m.matched_by,
    m.db_roll                AS lums_roll_number,
    a.full_name              AS lums_name,
    e.program                AS [Program],
    e.graduation_year        AS [Grad Year],
    emp.current_designation  AS [LinkedIn Jobtitle],
    emp.current_company      AS [CompanyName],
    emp.job_location         AS [LinkedIn JobLocation],
    c.linkedin_url           AS [LinkedIn Profile],
    CASE
        WHEN m.db_roll IS NULL THEN NULL
        WHEN emp.current_designation LIKE '%Student%'
          OR emp.current_designation LIKE '%PhD%'
          OR emp.current_designation LIKE '%Research Scholar%'
          OR e.linkedin_school_name NOT LIKE '%Lahore University of Management%'
        THEN 'Yes' ELSE 'No'
    END                      AS [Higher Education]
FROM matched m
LEFT JOIN alumni a       ON a.roll_number   = m.db_roll
LEFT JOIN education e    ON e.roll_number   = m.db_roll
LEFT JOIN employment emp ON emp.roll_number = m.db_roll
LEFT JOIN contact c      ON c.roll_number   = m.db_roll
ORDER BY m.sr_no;
