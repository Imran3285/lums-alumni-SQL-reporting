/* =====================================================================
   SCHEMA CHECK - first thing to run on any database (new or unfamiliar)
   Confirms the tables and columns exist as designed.
   Expected: 4 tables, 55 columns (alumni 13, education 12, employment 8,
             contact 22).
   ===================================================================== */

-- Tables in the database
SELECT TABLE_NAME, TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_TYPE, TABLE_NAME;

-- Columns and data types
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME IN ('alumni', 'education', 'employment', 'contact')
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- Column count per table
SELECT TABLE_NAME, COUNT(*) AS columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME IN ('alumni', 'education', 'employment', 'contact')
GROUP BY TABLE_NAME;
