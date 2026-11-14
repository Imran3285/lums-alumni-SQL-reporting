# LUMS Alumni – SQL Practice & Portfolio

My SQL learning log and portfolio, built on a real-world alumni database
(22,794 records) that I cleaned, modelled and loaded into **Azure SQL Database**.

> **Data is not included in this repository.** It contains personal information,
> so only SQL code and the table structure are stored here.

## The project
- Merged **4 sources** (alumni-office records and LinkedIn data) using roll number as the unique key.
- Cleaned and standardised names, programs, locations, phones and emails, with an audit log of every change.
- Designed a **4-table relational model** with primary and foreign keys – see [docs/data_model.md](docs/data_model.md).
- Validated the load against the source file (1.1M cells, 0 mismatches).

## Skills shown
`SELECT / WHERE / ORDER BY` · `GROUP BY / HAVING` · `INNER vs LEFT JOIN` · `CASE` ·
`CTEs` · window functions (`ROW_NUMBER`, `DENSE_RANK`, `LAG`, running totals) ·
date functions · views · stored procedures · data-quality checks · GDPR-conscious reporting

## Folders
| Folder | What's inside |
|---|---|
| `01_setup/` | Table structure (`CREATE TABLE`), reporting view, row-count check |
| `02_practice/` | Practice questions with model answers |
| `03_portfolio/` | Finished analysis queries: data quality, KPIs, segmentation, reporting procedure |
| `04_my_solutions/` | My own answers, one file per practice session |
| `docs/` | Data model diagram |

## Progress log
| Date | Session | Topics | Done |
|---|---|---|---|
| 2026-11-14 | Session 1 – Alumni Office inbox | COUNT, WHERE, BETWEEN, HAVING, first JOIN | ⬜ |
|  |  |  |  |

## Tools
Azure SQL Database (T-SQL) · Excel · GitHub
