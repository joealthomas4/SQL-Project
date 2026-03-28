-- SCRIPT 2: NORMALIZE + MV LOGS + MATERIALIZED VIEW

-- 1. NORMALIZE COUNTRY → CREATE REGION TABLE

CREATE TABLE region (
    region_id     NUMBER(4)    PRIMARY KEY,
    region_name   VARCHAR2(30) NOT NULL,
    created_by    VARCHAR2(30),
    created_date  DATE,
    modified_by   VARCHAR2(30),
    modified_date DATE
);

CREATE SEQUENCE region_seq START WITH 1 INCREMENT BY 1;

-- TRIGGER CREATED BEFORE INSERT
CREATE OR REPLACE TRIGGER region_trg01
BEFORE INSERT OR UPDATE ON region
FOR EACH ROW
BEGIN
   IF INSERTING THEN
      :NEW.created_by   := NVL(:NEW.created_by, USER);
      :NEW.created_date := NVL(:NEW.created_date, SYSDATE);
   END IF;
   :NEW.modified_by   := USER;
   :NEW.modified_date := SYSDATE;
END;
/

-- Populate REGION from distinct REGION_NAME values in COUNTRY
INSERT INTO region (region_id, region_name)
SELECT region_seq.NEXTVAL, region_name
FROM   (SELECT DISTINCT region_name FROM country);

-- Add REGION_ID column to COUNTRY
ALTER TABLE country
  ADD (region_id NUMBER(4));

UPDATE country c
SET region_id = (
    SELECT r.region_id
    FROM   region r
    WHERE  r.region_name = c.region_name
);

-- Enforce NOT NULL on region_id
ALTER TABLE country
  MODIFY (region_id NOT NULL);

-- Remove the denormalized REGION_NAME column
ALTER TABLE country
  DROP COLUMN region_name;

-- Add FK from COUNTRY to REGION
ALTER TABLE country
  ADD CONSTRAINT country_region_fk
  FOREIGN KEY (region_id)
  REFERENCES region(region_id)
  DEFERRABLE INITIALLY DEFERRED;


-- 2. NORMALIZE LOCATION → CREATE STATE_PROVINCE TABLE

CREATE TABLE state_province (
    state_province_id   NUMBER(6)    PRIMARY KEY,
    state_province_name VARCHAR2(25) NOT NULL,
    country_id          CHAR(2)      NOT NULL,
    created_by          VARCHAR2(30),
    created_date        DATE,
    modified_by         VARCHAR2(30),
    modified_date       DATE
);

CREATE SEQUENCE state_province_seq START WITH 1 INCREMENT BY 1;

-- TRIGGER CREATED BEFORE INSERT
CREATE OR REPLACE TRIGGER state_province_trg01
BEFORE INSERT OR UPDATE ON state_province
FOR EACH ROW
BEGIN
   IF INSERTING THEN
      :NEW.created_by   := NVL(:NEW.created_by, USER);
      :NEW.created_date := NVL(:NEW.created_date, SYSDATE);
   END IF;
   :NEW.modified_by   := USER;
   :NEW.modified_date := SYSDATE;
END;
/

-- Populate STATE_PROVINCE from distinct values in LOCATION
INSERT INTO state_province (state_province_id, state_province_name, country_id)
SELECT state_province_seq.NEXTVAL,
       state_province,
       country_id
FROM (
      SELECT DISTINCT state_province, country_id
      FROM   location
      WHERE  state_province IS NOT NULL
);

-- Add STATE_PROVINCE_ID column to LOCATION
ALTER TABLE location
  ADD (state_province_id NUMBER(6));

UPDATE location l
SET state_province_id = (
    SELECT s.state_province_id
    FROM   state_province s
    WHERE  s.state_province_name = l.state_province
    AND    s.country_id          = l.country_id
);

-- Drop the original denormalized STATE_PROVINCE column
ALTER TABLE location
  DROP COLUMN state_province;

-- FK from LOCATION to STATE_PROVINCE
ALTER TABLE location
  ADD CONSTRAINT loc_state_prov_fk
  FOREIGN KEY (state_province_id)
  REFERENCES state_province(state_province_id)
  DEFERRABLE INITIALLY DEFERRED;

-- FK from STATE_PROVINCE to COUNTRY
ALTER TABLE state_province
  ADD CONSTRAINT stateprov_country_fk
  FOREIGN KEY (country_id)
  REFERENCES country(country_id)
  DEFERRABLE INITIALLY DEFERRED;


-- 3. MATERIALIZED VIEW LOGS ON ALL TABLES

BEGIN EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW LOG ON job';
  EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW LOG ON country';
  EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW LOG ON location';
  EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW LOG ON department';
  EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW LOG ON employee';
  EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW LOG ON job_history';
  EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW LOG ON region';
  EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW LOG ON state_province';
  EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- JOB
CREATE MATERIALIZED VIEW LOG ON job
   WITH ROWID, PRIMARY KEY, SEQUENCE
        (job_title, min_salary, max_salary)
   INCLUDING NEW VALUES;

-- REGION (new table)
CREATE MATERIALIZED VIEW LOG ON region
   WITH ROWID, PRIMARY KEY, SEQUENCE
        (region_name)
   INCLUDING NEW VALUES;

-- COUNTRY (region_id is now the FK column replacing region_name)
CREATE MATERIALIZED VIEW LOG ON country
   WITH ROWID, PRIMARY KEY, SEQUENCE
        (country_name, region_id)
   INCLUDING NEW VALUES;

-- LOCATION (state_province_id replaces state_province)
CREATE MATERIALIZED VIEW LOG ON location
   WITH ROWID, PRIMARY KEY, SEQUENCE
        (street_address, postal_code, city, country_id, state_province_id)
   INCLUDING NEW VALUES;

-- DEPARTMENT
CREATE MATERIALIZED VIEW LOG ON department
   WITH ROWID, PRIMARY KEY, SEQUENCE
        (department_name, manager_id, location_id)
   INCLUDING NEW VALUES;

-- EMPLOYEE
CREATE MATERIALIZED VIEW LOG ON employee
   WITH ROWID, PRIMARY KEY, SEQUENCE
        (first_name, last_name, email, phone_number,
         hire_date, job_id, salary, commission_pct,
         manager_id, department_id)
   INCLUDING NEW VALUES;

-- JOB_HISTORY
CREATE MATERIALIZED VIEW LOG ON job_history
   WITH ROWID, PRIMARY KEY, SEQUENCE
        (job_id, department_id)
   INCLUDING NEW VALUES;

-- STATE_PROVINCE (new table)
CREATE MATERIALIZED VIEW LOG ON state_province
   WITH ROWID, PRIMARY KEY, SEQUENCE
        (state_province_name, country_id)
   INCLUDING NEW VALUES;


-- 4. FAST REFRESH ON COMMIT MATERIALIZED VIEW
--    Joins: REGION → COUNTRY → LOCATION

BEGIN
  EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW region_country_location_mv';
  EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE MATERIALIZED VIEW region_country_location_mv
BUILD IMMEDIATE
REFRESH FAST ON COMMIT
AS
SELECT
    r.ROWID          AS region_rowid,
    c.ROWID          AS country_rowid,
    l.ROWID          AS location_rowid,
    r.region_id,
    r.region_name,
    c.country_id,
    c.country_name,
    l.location_id,
    l.street_address,
    l.postal_code,
    l.city,
    l.state_province_id
FROM   region   r,
       country  c,
       location l
WHERE  c.region_id  = r.region_id
AND    l.country_id = c.country_id;


-- 5. VERIFY

SELECT mview_name,
       refresh_method,
       refresh_mode,
       staleness
FROM   user_mviews
WHERE  mview_name = 'REGION_COUNTRY_LOCATION_MV';
