# Data model

Four tables, all linked by `roll_number` (one person = one roll number).

```mermaid
erDiagram
  ALUMNI ||--|| EDUCATION : "studied"
  ALUMNI ||--o| EMPLOYMENT : "works"
  ALUMNI ||--|| CONTACT : "reached at"
  ALUMNI {
    nvarchar roll_number PK
    nvarchar full_name
    nvarchar gender
    date date_of_birth
    nvarchar deceased
  }
  EDUCATION {
    nvarchar roll_number PK
    nvarchar program
    nvarchar major
    nvarchar school
    int graduation_year
  }
  EMPLOYMENT {
    int employment_id PK
    nvarchar roll_number FK
    nvarchar current_designation
    nvarchar current_company
    nvarchar industry
    nvarchar last_experience_company
  }
  CONTACT {
    nvarchar roll_number PK
    nvarchar personal_email
    nvarchar mobile
    nvarchar city
    nvarchar country
    nvarchar residence
    nvarchar linkedin_url
  }
```

| Table | Rows | Relationship to `alumni` | Join to use |
|---|---|---|---|
| `alumni` | 22,794 | – | – |
| `education` | 22,794 | exactly 1 per person | `INNER JOIN` |
| `contact` | 22,794 | exactly 1 per person | `INNER JOIN` |
| `employment` | 20,196 | 0 or 1 per person | `LEFT JOIN` when you need **all** alumni |

**Which table?**
- name, gender, date of birth → `alumni`
- program, major, school, graduation year → `education`
- company, job title, industry → `employment`
- email, phone, city, country, LinkedIn → `contact`
