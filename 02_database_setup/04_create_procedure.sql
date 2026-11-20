/* =====================================================================
   REPORTING STORED PROCEDURE
   A parameterised report colleagues can run without writing SQL.
   Run the CREATE PROCEDURE on its own, then call it with EXEC.
   ===================================================================== */

-- D1. Parameterised report: alumni list for any country and industry.
--     Skill: CREATE PROCEDURE with parameters, optional filters.
CREATE OR ALTER PROCEDURE usp_alumni_by_country_industry
    @country  NVARCHAR(60),
    @industry NVARCHAR(100) = NULL      -- optional
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        a.full_name          AS [Full Name],
        e.program            AS [Program],
        e.graduation_year    AS [Graduation Year],
        m.current_designation AS [Job Title],
        m.current_company    AS [Company],
        m.industry           AS [Industry],
        c.city               AS [City]
    FROM alumni AS a
    INNER JOIN education  AS e ON e.roll_number = a.roll_number
    INNER JOIN employment AS m ON m.roll_number = a.roll_number
    INNER JOIN contact    AS c ON c.roll_number = a.roll_number
    WHERE c.country = @country
      AND (@industry IS NULL OR m.industry = @industry)
      AND (a.deceased IS NULL OR a.deceased <> 'Yes')
    ORDER BY e.graduation_year DESC, a.full_name;
END;

-- How to run it (in a NEW query box, after the procedure is created):
-- EXEC usp_alumni_by_country_industry @country = 'Ireland';                    -- 69 alumni
-- EXEC usp_alumni_by_country_industry @country = 'United Kingdom',
--                                     @industry = 'Hospital & Health Care';
