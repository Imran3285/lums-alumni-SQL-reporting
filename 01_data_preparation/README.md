# Step 1 – Data preparation (Excel / Python)

Before any SQL, the raw alumni data had to be combined, cleaned and checked.
The raw files contain personal information and are **not** stored in this repository –
this page documents what was done and why.

## 1. Sources
| Source | Rows | What it added |
|---|---|---|
| Alumni office records (CRM export, 138 columns) | 21,472 | Personal details, addresses, phones, emails, employment history |
| Alumni short sheet | 22,795 | Program, major, graduation year, school, LinkedIn job data |
| LinkedIn lookup file 1 | 1,499 | Current job, company, industry, location |
| LinkedIn lookup file 2 | 1,187 | Current job, company, industry, location |

**Unique key:** `roll_number` (Campus ID) – one row per roll number.

## 2. Merge
- Combined the two main sheets on `roll_number` → one row per roll number, no duplicates (**22,794 alumni** in the final master).
- Kept only the columns needed for education, career and contact (138 source columns → 51 in the final master).
- Where both sheets had a value, the sources were compared; they agreed apart from formatting.

## 3. Cleaning and standardisation
| Area | Rule | Example |
|---|---|---|
| Placeholders | `"0"`, `"-"`, `"N/A"` → blank (NULL) | `0` in Major → NULL |
| Programs | One spelling per program; **BS ≠ BSc** and **MS ≠ MSc** kept separate | `BSC` → `BSc`, `MPHIL` → `MPhil` |
| Majors | Abbreviations written out; joint majors merged (45 → 40 values) | `Politics/Economics` → `Politics & Economics` |
| Minors | Spelling variants merged (254 → 227 values) | `CS`, `Computer Sciences` → `Computer Science` |
| Provinces | Old names and spellings standardised | `NWFP` → `Khyber Pakhtunkhwa`; 3 Islamabad variants → `Islamabad Capital Territory` |
| Cities | Stray punctuation removed, variants merged | `Karachi,` → `Karachi` |
| Phones | Digits only, with country code | `0300-0000000` → `923000000000` |
| Emails | Lower-case, format-checked, invalid ones removed | |
| Names | Lone dots/dashes removed; compound names, qualifications and non-Latin scripts kept | `Asim .` → `Asim` |
| Dates of birth | Impossible values blanked (age at graduation < 18 or > 75); 126 records, mostly a `2000-01-01` placeholder | |

Every change was written to a **change log** (old value → new value → reason).

## 4. Filling gaps from LinkedIn data
- Matched the LinkedIn files to the master on **Campus ID**, then **checked the LinkedIn name against the alumni name** for every row.
- **Only blank cells were filled** – existing values were never overwritten (1,390 cells filled).
- Company, job title, industry and job location were filled **as one set**, so a company is never paired with a title from a different job.
- **12 profiles were held back** (6 clearly a different person, 6 uncertain) and **329 newer jobs** were listed for review instead of applied automatically.

## 5. Validation before loading
- Every filled value was re-checked against its source Campus ID.
- After loading into Azure SQL, every one of **1.1 million cells** was compared with the cleaned file: **0 mismatches**.

## Lessons learned
- A lookup on a free-text field (like a LinkedIn URL) fails silently on small differences – normalise first.
- VLOOKUP returns `0` for empty source cells and can't detect a wrong-person match – a name check is essential.
- Always keep a change log so every cleaned value can be explained.
