/* =====================================================================
   REQUEST : An external list of names, emails and phone numbers needed to
             be checked against the alumni database (who is LUMS alumni?).
   APPROACH: 1) exact match on email (most reliable)
             2) phone match with a leading wildcard, because the database
                stores numbers with the country code
             3) loose name match (start of first name AND start of surname)
                only as a fallback, labelled with CASE for manual review
   QUALITY : Testing showed name matching alone is unreliable:
             '%Heer Cheema%' matched "Shaheer Cheema", one name matched two
             different people, and middle names caused misses. First name OR
             surname alone returned 7,591 rows; AND-ing the two returned ~20.
             '_' is a LIKE wildcard, so emails containing it use [_].
   RESULT  : 7 of 12 matched (6 by email/phone, 1 by name - flagged).
   NOTE    : Real contact details removed - values below are placeholders.
   SKILLS  : LIKE patterns and wildcards, escaping, CASE labels, OR/AND logic.
   ===================================================================== */

-- Step 1: exact email / phone match
SELECT
    a.roll_number, a.full_name, e.program, e.major, e.graduation_year,
    c.personal_email, c.mobile, c.city, c.country
FROM alumni AS a
JOIN education AS e ON e.roll_number = a.roll_number
JOIN contact   AS c ON c.roll_number = a.roll_number
WHERE c.personal_email LIKE 'person.one@example.com'   OR c.mobile LIKE '%5550000001'
   OR c.personal_email LIKE 'person[_]two@example.com' OR c.mobile LIKE '%5550000002'
ORDER BY a.full_name;

-- Step 2: loose name match for anyone not found, labelled for review
SELECT
    CASE
        WHEN a.full_name LIKE 'Fir%' AND a.full_name LIKE '% Las%' THEN 'Firstname Lastname'
        WHEN (a.full_name LIKE '% Ali %' OR a.full_name LIKE 'Ali %')
             AND a.full_name LIKE '% Kha%'                          THEN 'Muhammad Ali Khan'
    END AS searched_for,
    a.roll_number, a.full_name, e.program, e.major, e.graduation_year
FROM alumni AS a
JOIN education AS e ON e.roll_number = a.roll_number
WHERE (a.full_name LIKE 'Fir%' AND a.full_name LIKE '% Las%')
   OR ((a.full_name LIKE '% Ali %' OR a.full_name LIKE 'Ali %') AND a.full_name LIKE '% Kha%')
ORDER BY searched_for, a.full_name;

-- Step 3: show alumni with two degrees as one row per person
SELECT
    c.personal_email,
    MAX(a.full_name)                                            AS full_name,
    COUNT(*)                                                    AS degrees,
    STRING_AGG(CONCAT(e.program, ' ', e.graduation_year), ', ') AS programs,
    STRING_AGG(a.roll_number, ', ')                             AS roll_numbers
FROM alumni AS a
JOIN education AS e ON e.roll_number = a.roll_number
JOIN contact   AS c ON c.roll_number = a.roll_number
WHERE c.personal_email IS NOT NULL
GROUP BY c.personal_email
HAVING COUNT(*) > 1;
