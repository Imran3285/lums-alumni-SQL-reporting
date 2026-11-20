-- =====================================================================
-- LUMS Alumni SQL Practice Set (Data Analyst interview prep)
-- Tables: alumni, education, contact (1 row per roll_number, 22,794 rows)
--         employment (only alumni with job data, 20,196 rows)
-- Join key everywhere: roll_number
-- Try each question yourself first, then check the answer below it.
-- T-SQL version for Azure SQL Database / SQL Server (uses TOP instead of LIMIT).
-- =====================================================================

-- ---------- LEVEL 1: SELECT, WHERE, ORDER BY, TOP ----------

-- Q1. List the names and roll numbers of 10 female alumni who graduated in 2020.
SELECT TOP 10 a.roll_number, a.full_name
FROM alumni a JOIN education e ON a.roll_number = e.roll_number
WHERE a.gender = 'Female' AND e.graduation_year = 2020
ORDER BY a.full_name;

-- Q2. How many alumni have no personal email on record?
SELECT COUNT(*) AS missing_email
FROM contact
WHERE personal_email IS NULL;

-- Q3. Find alumni whose current designation contains the word 'Data'.
SELECT a.full_name, m.current_designation, m.current_company
FROM alumni a JOIN employment m ON a.roll_number = m.roll_number
WHERE m.current_designation LIKE '%Data%';

-- ---------- LEVEL 2: GROUP BY, HAVING, aggregates ----------

-- Q4. Number of graduates per school, largest first.
SELECT school, COUNT(*) AS graduates
FROM education
GROUP BY school
ORDER BY graduates DESC;

-- Q5. Top 10 countries where alumni live (excluding unknown).
SELECT TOP 10 country, COUNT(*) AS alumni
FROM contact
WHERE country IS NOT NULL
GROUP BY country
ORDER BY alumni DESC;

-- Q6. Top 15 employers of LUMS alumni (ignore companies with fewer than 30 alumni).
SELECT TOP 15 current_company, COUNT(*) AS alumni
FROM employment
WHERE current_company IS NOT NULL
GROUP BY current_company
HAVING COUNT(*) >= 30
ORDER BY alumni DESC;

-- Q7. Gender split (count and %) for each program.
SELECT e.program,
       SUM(CASE WHEN a.gender = 'Female' THEN 1 ELSE 0 END) AS female,
       SUM(CASE WHEN a.gender = 'Male'   THEN 1 ELSE 0 END) AS male,
       ROUND(100.0 * SUM(CASE WHEN a.gender = 'Female' THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_female
FROM education e JOIN alumni a ON a.roll_number = e.roll_number
WHERE a.gender IS NOT NULL
GROUP BY e.program
ORDER BY COUNT(*) DESC;

-- ---------- LEVEL 3: JOINs (inner vs left), NULL handling ----------

-- Q8. How many alumni have NO employment record at all? (LEFT JOIN anti-join)
SELECT COUNT(*) AS no_job_data
FROM alumni a
LEFT JOIN employment m ON a.roll_number = m.roll_number
WHERE m.roll_number IS NULL;

-- Q9. % of each graduating class (2015 onwards) living abroad.
SELECT e.graduation_year,
       COUNT(*) AS class_size,
       ROUND(100.0 * SUM(CASE WHEN c.residence = 'Abroad' THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_abroad
FROM education e JOIN contact c ON c.roll_number = e.roll_number
WHERE e.graduation_year >= 2015
GROUP BY e.graduation_year
ORDER BY e.graduation_year;

-- Q10. Contact-data completeness: % of alumni with email, mobile and LinkedIn.
SELECT ROUND(100.0 * COUNT(personal_email) / COUNT(*), 1) AS pct_email,
       ROUND(100.0 * COUNT(mobile)         / COUNT(*), 1) AS pct_mobile,
       ROUND(100.0 * COUNT(linkedin_url)   / COUNT(*), 1) AS pct_linkedin
FROM contact;

-- ---------- LEVEL 4: CTEs, subqueries, window functions ----------

-- Q11. For each school, the single most common industry its alumni work in.
WITH ind AS (
  SELECT e.school, m.industry, COUNT(*) AS n,
         ROW_NUMBER() OVER (PARTITION BY e.school ORDER BY COUNT(*) DESC) AS rn
  FROM education e JOIN employment m ON m.roll_number = e.roll_number
  WHERE m.industry IS NOT NULL
  GROUP BY e.school, m.industry
)
SELECT school, industry, n FROM ind WHERE rn = 1 ORDER BY n DESC;

-- Q12. Top 3 employers for each major (majors with 500+ graduates only).
WITH big_majors AS (
  SELECT major FROM education WHERE major IS NOT NULL
  GROUP BY major HAVING COUNT(*) >= 500
), ranked AS (
  SELECT e.major, m.current_company, COUNT(*) AS n,
         DENSE_RANK() OVER (PARTITION BY e.major ORDER BY COUNT(*) DESC) AS rnk
  FROM education e
  JOIN employment m ON m.roll_number = e.roll_number
  WHERE e.major IN (SELECT major FROM big_majors) AND m.current_company IS NOT NULL
  GROUP BY e.major, m.current_company
)
SELECT major, rnk, current_company, n FROM ranked WHERE rnk <= 3 ORDER BY major, rnk;

-- Q13. Running total of graduates by year (cumulative alumni base).
SELECT graduation_year,
       COUNT(*) AS graduates,
       SUM(COUNT(*)) OVER (ORDER BY graduation_year) AS cumulative_alumni
FROM education
GROUP BY graduation_year
ORDER BY graduation_year;

-- Q14. Year-over-year growth in class size (LAG).
WITH y AS (SELECT graduation_year, COUNT(*) AS n FROM education GROUP BY graduation_year)
SELECT graduation_year, n,
       LAG(n) OVER (ORDER BY graduation_year) AS prev_year,
       ROUND(100.0 * (n - LAG(n) OVER (ORDER BY graduation_year)) / LAG(n) OVER (ORDER BY graduation_year), 1) AS yoy_pct
FROM y ORDER BY graduation_year;

-- Q15. Alumni who changed company (last company in alumni records differs from current LinkedIn company), by industry.
SELECT TOP 10 industry, COUNT(*) AS switched
FROM employment
WHERE last_experience_company IS NOT NULL AND current_company IS NOT NULL
  AND LOWER(last_experience_company) <> LOWER(current_company)
  AND industry IS NOT NULL
GROUP BY industry
ORDER BY switched DESC;

-- ---------- LEVEL 5: data-quality checks (interviewers love these) ----------

-- Q16. Find personal emails shared by more than one roll number.
SELECT personal_email, COUNT(*) AS roll_numbers
FROM contact
WHERE personal_email IS NOT NULL
GROUP BY personal_email
HAVING COUNT(*) > 1
ORDER BY roll_numbers DESC;

-- Q17. Alumni whose profile country disagrees with their LinkedIn location.
SELECT a.full_name, c.country, c.linkedin_location
FROM contact c JOIN alumni a ON a.roll_number = c.roll_number
WHERE c.country IS NOT NULL AND c.linkedin_location IS NOT NULL
  AND LOWER(c.linkedin_location) NOT LIKE CONCAT('%', LOWER(c.country), '%');
