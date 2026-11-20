# Data dictionary

All tables are in schema `dbo`. `roll_number` links every table.

## alumni – one row per person (22,794)
| Column | Type | Description |
|---|---|---|
| roll_number | NVARCHAR(20), **PK** | Campus ID – unique per degree |
| full_name, first_name, last_name | NVARCHAR(100) | Name as held by the alumni office |
| gender | NVARCHAR(10) | Male / Female / NULL |
| date_of_birth | DATE | NULL where the recorded value was impossible |
| nationality, marital_status | NVARCHAR | |
| cnic | NVARCHAR(20) | National ID – **sensitive, never exported** |
| nop, css | NVARCHAR(5) | Yes/No flags from the alumni office |
| deceased | NVARCHAR(5) | Yes / No / NULL – always exclude 'Yes' from outreach |
| profile_strength | INT | Completeness score from the alumni portal |

## education – one row per person (22,794)
| Column | Type | Description |
|---|---|---|
| roll_number | NVARCHAR(20), **PK, FK** | |
| program | NVARCHAR(30) | BSc, BS, BA, BA-LLB (Hons), MBA, EMBA, MS, MSc, MPhil, PhD, Undeclared |
| major, minor | NVARCHAR | Standardised names |
| graduation_year | INT | |
| school | NVARCHAR(20) | SDSB, MGSHSS, SBASSE, SAHSOL, SOE |
| other_institution, other_degree, other_field | NVARCHAR(200) | Education outside LUMS |
| linkedin_school_name / _degree / _field | NVARCHAR(200) | Most recent school on LinkedIn |

## employment – zero or one row per person (20,196)
| Column | Type | Description |
|---|---|---|
| employment_id | INT IDENTITY, **PK** | Auto-number |
| roll_number | NVARCHAR(20), **FK** | |
| current_designation | NVARCHAR(200) | Current job title (LinkedIn) |
| current_company | NVARCHAR(200) | Current employer (LinkedIn) |
| industry | NVARCHAR(100) | LinkedIn industry list, e.g. `Hospital & Health Care`, `Medical Device` |
| job_location | NVARCHAR(200) | Location of the current job |
| last_experience_company / _designation | NVARCHAR(200) | Last job recorded by the alumni office |

## contact – one row per person (22,794)
| Column | Type | Description |
|---|---|---|
| roll_number | NVARCHAR(20), **PK, FK** | |
| personal_email, official_email, campus_email, alternate_email | NVARCHAR(100) | |
| mobile, alternate_mobile, landline, alternate_landline | NVARCHAR(30) | Digits with country code |
| current_address, city, state, country | NVARCHAR | Where the person lives |
| residence | NVARCHAR(10) | Derived: Pakistan / Abroad / Unknown |
| permanent_address / _city / _state / _country | NVARCHAR | |
| linkedin_url, linkedin_first_name, linkedin_last_name, linkedin_location | NVARCHAR | |

## Things to know when querying
- `employment` has fewer rows – use **LEFT JOIN** when you need *all* alumni.
- `country <> 'Pakistan'` excludes NULL countries – use `residence` or handle NULLs explicitly.
- Text comparisons are **case-insensitive** (Azure default collation), so `LIKE '%cto%'` also matches "Dire**cto**r".
- People with two LUMS degrees have **two roll numbers** – group by email to get one row per person.
