📊 HR Database System (Oracle SQL)

This project implements a fully structured Human Resources (HR) database system using Oracle SQL. It includes schema creation, normalization, constraints, triggers, materialized views, and utility procedures for database management.

📁 Project Files
Schema Setup & Data Load
Script1.sql
Creates tables, constraints, triggers, and inserts sample HR data.
Normalization & Materialized Views
Script2.sql
Normalizes the schema and implements materialized view logs and fast-refresh views.
Cleanup Utility Procedure
zap_objects.sql
Provides a procedure to drop all database objects dynamically.
🧱 Database Schema Overview

The system models a typical HR database with the following core entities:

Job – Job roles and salary ranges
Employee – Employee details and relationships
Department – Organizational units
Location – Office locations
Country – Country-level data
Job History – Employee role transitions
Relationships
Employees are linked to jobs, departments, and managers
Departments are linked to locations and managers
Locations are linked to countries
⚙️ Key Features
✅ 1. Table Creation & Constraints
Primary keys for all tables
Foreign keys with DEFERRABLE INITIALLY DEFERRED constraints
Check constraints for:
Salary validation
Date consistency
🔄 2. Audit Triggers

Each table includes triggers to automatically track:

created_by, created_date
modified_by, modified_date

This ensures proper auditing of all records.

🧹 3. Data Population

Preloaded dataset includes:

Jobs (e.g., IT_PROG, SA_MAN)
Countries and regions
Locations worldwide
Departments and employees
🧩 4. Database Normalization
Region Normalization
Extracts region_name into a separate REGION table
Links COUNTRY to REGION using a foreign key
State/Province Normalization
Extracts state_province into STATE_PROVINCE table
Links LOCATION to STATE_PROVINCE

This improves data consistency and reduces redundancy.

⚡ 5. Materialized View Logs

Materialized view logs are created for all major tables to support fast refresh operations.

📊 6. Materialized View

A fast-refresh materialized view is created:

region_country_location_mv

Joins:

REGION → COUNTRY → LOCATION

Features:

REFRESH FAST ON COMMIT
Optimized for reporting and analytics
🧨 7. Utility Procedure (Zap_objects)

The Zap_objects procedure allows dynamic deletion of:

Tables
Views
Triggers
Sequences
Materialized Views and logs
Other schema objects

Useful for resetting the database before rerunning scripts.

🚀 How to Run

Step 1: Clean Existing Schema (Optional)
@zap_objects.sql

Step 2: Create Base Schema & Load Data
@Script1.sql

Step 3: Apply Normalization & Materialized Views
@Script2.sql

🧠 Concepts Demonstrated
Relational Database Design
Normalization (1NF → 3NF)
Constraints & Referential Integrity
Triggers for auditing
Sequences for surrogate keys
Materialized Views & Logs
PL/SQL Procedures
Dynamic SQL
🎯 Use Cases
Academic database assignments
Learning Oracle SQL & PL/SQL
Practicing normalization and optimization
Understanding enterprise-level HR systems
👤 Author

Joeal Bijoy Thomas
