/* =====================================================================
   Practice session 1 - The Alumni Office inbox
   Date: 2026-11-14
   ===================================================================== */

-- R1. How many female alumni do we have?           Target: 8,188
-- What I learned: one total = only COUNT(*) in SELECT, no other columns.
SELECT COUNT(*) AS total_female_alumni
FROM alumni
WHERE gender = 'Female';

-- R2. How many alumni live in Islamabad?           Target: 1,347
-- My query:


-- R3. MBA graduates 2015-2020?                     Target: 402
-- My query:


-- R4. Countries with 500+ alumni, biggest first.   Target: 5 countries
-- My query:


-- R5. How many alumni currently work at Engro?     Target: 59
-- My query:

