/* =====================================================================
   REQUEST : List of Alumni Achievement Award (formerly VC Alumni
             Achievement Award) winners for the QS Rankings submission
             (Office of Programme Enhancement), in their template columns.
   APPROACH: The database has no award field, so winners were taken from
             the public awards page (66 names with program and class year),
             matched to roll numbers by name + graduation year (+/- 1 year),
             then joined to job, industry and location data.
   QUALITY : Name variants checked by hand (e.g. a surname written as one
             word in the database). One winner with two LUMS degrees mapped
             to the later degree. 2 winners not found are still returned
             with the name, program and year from the awards page.
   RESULT  : 64 of 66 winners matched.
   SKILLS  : Table variable, LEFT JOIN, COALESCE fallbacks, ORDER BY alias.
   NOTE    : Roll numbers are not stored here; placeholder rows show format.
   ===================================================================== */
DECLARE @aaa TABLE (sr_no INT, roll_number NVARCHAR(20), award_name NVARCHAR(100),
                    award_program NVARCHAR(30), award_year INT);
INSERT INTO @aaa (sr_no, roll_number, award_name, award_program, award_year) VALUES
(1, '0000000001', 'Example Winner One', 'MBA', 1997),
(2, NULL,         'Example Winner Two', 'BSc', 2005);   -- not found in database

SELECT
    w.roll_number                                AS [Roll Number],
    a.first_name                                 AS [First Name],
    a.last_name                                  AS [Last Name],
    COALESCE(a.full_name, w.award_name)          AS [Full Name],
    COALESCE(e.program, w.award_program)         AS [Program],
    COALESCE(e.graduation_year, w.award_year)    AS [Graduation Year],
    COALESCE(c.personal_email, c.official_email) AS [Personal Email],
    emp.current_designation                      AS [Job Title],
    emp.industry                                 AS [Industry],
    emp.current_company                          AS [Company],
    c.city                                       AS [City],
    c.country                                    AS [Country]
FROM @aaa w
LEFT JOIN alumni a       ON a.roll_number   = w.roll_number
LEFT JOIN education e    ON e.roll_number   = w.roll_number
LEFT JOIN employment emp ON emp.roll_number = w.roll_number
LEFT JOIN contact c      ON c.roll_number   = w.roll_number
ORDER BY [Graduation Year], [Full Name];
