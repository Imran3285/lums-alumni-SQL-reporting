# Loading the data

The cleaned data (22,794 alumni) was converted into `INSERT` statements and loaded into
**Azure SQL Database** (free tier) through the Azure portal Query editor.

| Step | Script | Notes |
|---|---|---|
| 1 | `01_create_tables.sql` | Drops and recreates the 4 tables with primary and foreign keys |
| 2 | 13 insert batches (not in this repo – they contain personal data) | ~1.4 MB each, so each runs within the editor's 5-minute limit; parents (`alumni`) loaded before children so foreign keys are satisfied |
| 3 | `03_create_views.sql` | Reporting views – run each `CREATE VIEW` separately |
| 4 | `04_create_procedure.sql` | Parameterised report procedure |
| 5 | `../03_data_validation/` | Row counts, referential checks, data quality |

**Re-running a batch** gives a `PRIMARY KEY` violation ("duplicate key") – that is the
database protecting itself from loading the same person twice, not a data error.
