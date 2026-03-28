
-- SCRIPT 1: DROP, REBUILD TABLES, CONSTRAINTS, TRIGGERS

-- TABLES

CREATE TABLE job (
    job_id        VARCHAR2(10)    PRIMARY KEY,
    job_title     VARCHAR2(50)    NOT NULL,
    min_salary    NUMBER(8,2),
    max_salary    NUMBER(8,2),
    created_by    VARCHAR2(30),
    created_date  DATE,
    modified_by   VARCHAR2(30),
    modified_date DATE
);

CREATE TABLE country (
    country_id    CHAR(2)         PRIMARY KEY,
    country_name  VARCHAR2(40)    NOT NULL,
    region_name   VARCHAR2(30)    NOT NULL,
    created_by    VARCHAR2(30),
    created_date  DATE,
    modified_by   VARCHAR2(30),
    modified_date DATE
);

CREATE TABLE location (
    location_id     NUMBER(4)     PRIMARY KEY,
    street_address  VARCHAR2(40),
    postal_code     VARCHAR2(12),
    city            VARCHAR2(30)  NOT NULL,
    state_province  VARCHAR2(25),
    country_id      CHAR(2)       NOT NULL,
    created_by      VARCHAR2(30),
    created_date    DATE,
    modified_by     VARCHAR2(30),
    modified_date   DATE
);

CREATE TABLE department (
    department_id   NUMBER(4)     PRIMARY KEY,
    department_name VARCHAR2(30)  NOT NULL,
    manager_id      NUMBER(6),
    location_id     NUMBER(4),
    created_by      VARCHAR2(30),
    created_date    DATE,
    modified_by     VARCHAR2(30),
    modified_date   DATE
);

CREATE TABLE employee (
    employee_id     NUMBER(6)     PRIMARY KEY,
    first_name      VARCHAR2(20),
    last_name       VARCHAR2(25)  NOT NULL,
    email           VARCHAR2(25)  NOT NULL,
    phone_number    VARCHAR2(20),
    hire_date       DATE          NOT NULL,
    job_id          VARCHAR2(10)  NOT NULL,
    salary          NUMBER(8,2),
    commission_pct  NUMBER(2,2),
    manager_id      NUMBER(6),
    department_id   NUMBER(4),
    created_by      VARCHAR2(30),
    created_date    DATE,
    modified_by     VARCHAR2(30),
    modified_date   DATE
);

CREATE TABLE job_history (
    employee_id     NUMBER(6)   NOT NULL,
    start_date      DATE        NOT NULL,
    end_date        DATE        NOT NULL,
    job_id          VARCHAR2(10) NOT NULL,
    department_id   NUMBER(4),
    created_by      VARCHAR2(30),
    created_date    DATE,
    modified_by     VARCHAR2(30),
    modified_date   DATE,
    CONSTRAINT job_history_pk PRIMARY KEY (employee_id, start_date)
);

-- CONSTRAINTS (FKs DEFERRABLE INITIALLY DEFERRED)

ALTER TABLE location
  ADD CONSTRAINT loc_country_fk
  FOREIGN KEY (country_id)
  REFERENCES country(country_id)
  DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE department
  ADD CONSTRAINT dept_loc_fk
  FOREIGN KEY (location_id)
  REFERENCES location(location_id)
  DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE employee
  ADD CONSTRAINT emp_job_fk
  FOREIGN KEY (job_id)
  REFERENCES job(job_id)
  DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE employee
  ADD CONSTRAINT emp_dept_fk
  FOREIGN KEY (department_id)
  REFERENCES department(department_id)
  DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE employee
  ADD CONSTRAINT emp_mgr_fk
  FOREIGN KEY (manager_id)
  REFERENCES employee(employee_id)
  DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE department
  ADD CONSTRAINT dept_mgr_fk
  FOREIGN KEY (manager_id)
  REFERENCES employee(employee_id)
  DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE job_history
  ADD CONSTRAINT jhist_emp_fk
  FOREIGN KEY (employee_id)
  REFERENCES employee(employee_id)
  DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE job_history
  ADD CONSTRAINT jhist_job_fk
  FOREIGN KEY (job_id)
  REFERENCES job(job_id)
  DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE job_history
  ADD CONSTRAINT jhist_dept_fk
  FOREIGN KEY (department_id)
  REFERENCES department(department_id)
  DEFERRABLE INITIALLY DEFERRED;

-- CHECK CONSTRAINTS

ALTER TABLE job_history
  ADD CONSTRAINT jhist_dates_ck
  CHECK (start_date <= end_date);

ALTER TABLE job
  ADD CONSTRAINT job_salary_ck
  CHECK (
        min_salary IS NULL
     OR max_salary IS NULL
     OR min_salary <= max_salary
  );

-- FOOTPRINT TRIGGER (TRG01)

CREATE OR REPLACE TRIGGER job_trg01
BEFORE INSERT OR UPDATE ON job
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

CREATE OR REPLACE TRIGGER country_trg01
BEFORE INSERT OR UPDATE ON country
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

CREATE OR REPLACE TRIGGER location_trg01
BEFORE INSERT OR UPDATE ON location
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

CREATE OR REPLACE TRIGGER department_trg01
BEFORE INSERT OR UPDATE ON department
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

CREATE OR REPLACE TRIGGER employee_trg01
BEFORE INSERT OR UPDATE ON employee
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

CREATE OR REPLACE TRIGGER job_history_trg01
BEFORE INSERT OR UPDATE ON job_history
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





