-- LUMS alumni practice database v2 (standardised + LinkedIn-filled master, 14 Nov 2026)
-- Azure SQL Database / SQL Server (T-SQL)
-- WARNING: deletes the old 4 tables and the view, then creates new empty ones.

DROP VIEW IF EXISTS vw_alumni_profile;
DROP TABLE IF EXISTS employment;
DROP TABLE IF EXISTS contact;
DROP TABLE IF EXISTS education;
DROP TABLE IF EXISTS alumni;

CREATE TABLE alumni (
  roll_number NVARCHAR(20) NOT NULL PRIMARY KEY,
  full_name NVARCHAR(100),
  first_name NVARCHAR(100),
  last_name NVARCHAR(100),
  gender NVARCHAR(10),
  date_of_birth DATE,
  nationality NVARCHAR(60),
  marital_status NVARCHAR(30),
  cnic NVARCHAR(20),
  nop NVARCHAR(5),
  css NVARCHAR(5),
  deceased NVARCHAR(5),
  profile_strength INT
);

CREATE TABLE education (
  roll_number NVARCHAR(20) NOT NULL PRIMARY KEY,
  program NVARCHAR(30),
  major NVARCHAR(100),
  minor NVARCHAR(200),
  graduation_year INT,
  school NVARCHAR(20),
  other_institution NVARCHAR(200),
  other_degree NVARCHAR(200),
  other_field NVARCHAR(200),
  linkedin_school_name NVARCHAR(200),
  linkedin_school_degree NVARCHAR(200),
  linkedin_school_field NVARCHAR(200),
  CONSTRAINT fk_education_alumni FOREIGN KEY (roll_number) REFERENCES alumni(roll_number)
);

CREATE TABLE employment (
  employment_id INT IDENTITY(1,1) PRIMARY KEY,
  roll_number NVARCHAR(20) NOT NULL,
  current_designation NVARCHAR(200),
  current_company NVARCHAR(200),
  industry NVARCHAR(100),
  job_location NVARCHAR(200),
  last_experience_company NVARCHAR(200),
  last_experience_designation NVARCHAR(200),
  CONSTRAINT fk_employment_alumni FOREIGN KEY (roll_number) REFERENCES alumni(roll_number)
);

CREATE TABLE contact (
  roll_number NVARCHAR(20) NOT NULL PRIMARY KEY,
  personal_email NVARCHAR(100),
  official_email NVARCHAR(100),
  campus_email NVARCHAR(100),
  alternate_email NVARCHAR(100),
  mobile NVARCHAR(30),
  alternate_mobile NVARCHAR(30),
  landline NVARCHAR(30),
  alternate_landline NVARCHAR(30),
  current_address NVARCHAR(400),
  city NVARCHAR(100),
  state NVARCHAR(100),
  country NVARCHAR(60),
  residence NVARCHAR(10),
  permanent_address NVARCHAR(400),
  permanent_city NVARCHAR(100),
  permanent_state NVARCHAR(100),
  permanent_country NVARCHAR(60),
  linkedin_url NVARCHAR(200),
  linkedin_first_name NVARCHAR(100),
  linkedin_last_name NVARCHAR(100),
  linkedin_location NVARCHAR(100),
  CONSTRAINT fk_contact_alumni FOREIGN KEY (roll_number) REFERENCES alumni(roll_number)
);

CREATE INDEX ix_emp_roll ON employment(roll_number);
CREATE INDEX ix_emp_company ON employment(current_company);
CREATE INDEX ix_edu_year ON education(graduation_year);
CREATE INDEX ix_contact_country ON contact(country);