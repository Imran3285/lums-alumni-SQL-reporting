SELECT 'alumni' AS tbl, COUNT(*) AS n FROM alumni
UNION ALL SELECT 'education', COUNT(*) FROM education
UNION ALL SELECT 'employment', COUNT(*) FROM employment
UNION ALL SELECT 'contact', COUNT(*) FROM contact;
-- Expected: alumni 22794, education 22794, employment 20196, contact 22794
