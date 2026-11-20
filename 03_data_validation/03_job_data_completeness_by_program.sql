/* Data completeness by program: how many alumni have job data, and what %
   is missing. Pattern: LEFT JOIN + SUM(CASE ... IS NULL) + GROUP BY.
   Healthcare equivalent: referred patients seen vs still waiting, per hospital.
   Finding: MBA has the most complete job data (3.5% missing); MSc and PhD the
   least (~25%) - targets for the next alumni data-update campaign. */
SELECT
    e.program,
    COUNT(*)                                                    AS total,
    SUM(CASE WHEN m.roll_number IS NOT NULL THEN 1 ELSE 0 END)  AS with_job,
    SUM(CASE WHEN m.roll_number IS NULL     THEN 1 ELSE 0 END)  AS no_job,
    CAST(100.0 * SUM(CASE WHEN m.roll_number IS NULL THEN 1 ELSE 0 END)
         / COUNT(*) AS DECIMAL(5,1))                            AS pct_no_job
FROM education AS e
LEFT JOIN employment AS m ON e.roll_number = m.roll_number
WHERE e.program IS NOT NULL
GROUP BY e.program
ORDER BY pct_no_job DESC;
