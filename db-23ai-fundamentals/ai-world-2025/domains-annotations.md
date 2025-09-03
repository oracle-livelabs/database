# Domains & Annotations: Enterprise Data Governance with Oracle Database 23ai

## Introduction

Welcome to the **Domains & Annotations** lab! In this hands-on session, you'll learn how Oracle Database 23ai's Data Usecase Domains and Schema Annotations work together to solve critical data governance challenges across any industry.

As organizations like LumenCare manage increasingly complex data requirements—from regulatory compliance to business workflow automation—traditional database comments and constraints fall short. This lab demonstrates how modern database features can enforce data integrity while maintaining comprehensive metadata documentation for any business domain.

Estimated Lab Time: 25 minutes

### Objective:
The objective of this lab is to demonstrate Oracle Database 23ai's Data Usecase Domains and Schema Annotations for enterprise data governance. By the end of this lab, you will understand how to create reusable domain constraints, embed structured metadata in your schema, and query annotations for compliance reporting.

### Prerequisites:
- Access to Oracle Database 23ai.
- Basic understanding of SQL concepts.

## The LumenCare Challenge

LumenCare's platform faces several common data governance challenges that many organizations encounter:

1. **Data Consistency**: Business IDs, names, and status values need consistent validation across all applications
2. **Regulatory Compliance**: Industry regulations require detailed metadata documentation and audit trails
3. **Business Data Integrity**: Critical business records must enforce proper constraints while remaining flexible for different workflows
4. **Audit Requirements**: All sensitive data needs structured metadata for compliance reporting and business intelligence

## The Oracle 23ai Solution: Domains + Annotations

### What are Data Usecase Domains?
Data Usecase Domains provide reusable data types with built-in constraints and validation rules. Unlike simple data types, domains can enforce complex business rules and provide consistent metadata across your entire schema, reducing development time and ensuring data quality.

Data Use Case Domains also provide consistent metadata for development, analytics, and ETL applications and tools, helping to ensure data consistency and validation throughout the schema.

### Understanding the Four Types of Data Usecase Domains

Before we dive into our healthcare examples, let's understand the four powerful types of Data Usecase Domains available in Oracle Database 23ai:

#### 1. Single Column Domain
**Purpose**: Applies constraints and validation rules to a single column across multiple tables.

**Benefits**:
- Ensures consistent validation logic for commonly used data types
- Reduces code duplication across table definitions
- Centralizes business rule enforcement
- Simplifies maintenance when rules need to change

**Common Use Cases**: Email validation, price constraints, ID formats, status codes

**Example Scenario**: A `price` domain that ensures all monetary values are positive numbers, used consistently across product tables, invoice tables, and pricing history tables.

#### 2. Multi-Column Domain
**Purpose**: Applies constraints across multiple related columns, treating them as a logical unit.

**Benefits**:
- Enforces relationships between related data points
- Validates complex business rules that span multiple fields
- Maintains data integrity for composite data structures
- Reduces the need for complex table-level CHECK constraints

**Common Use Cases**: Address validation (street, city, state, zip), coordinate validation (latitude/longitude), date ranges (start/end dates), contact information (phone/email combinations)

**Example Scenario**: A `coordinates` domain that ensures latitude is between -90 and 90 degrees and longitude is between -180 and 180 degrees, preventing invalid geographical data.

#### 3. Flexible Domain
**Purpose**: Allows dynamic selection of different Data Usecase Domains based on specific conditions or context.

**Benefits**:
- Supports polymorphic data structures within a single table
- Enables context-aware validation rules
- Reduces the need for multiple similar tables
- Maintains type safety while providing flexibility

**Common Use Cases**: Contact information that varies by type (personal vs. business), product specifications that differ by category, user profiles with role-based fields

**Example Scenario**: A `contact_information` domain that applies different validation rules for personal contacts (requires name and phone) versus business contacts (requires company name, contact person, and phone).

#### 4. Enumeration Use Case Domain
**Purpose**: Contains a predefined set of named values, optionally with corresponding numeric or string values.

**Benefits**:
- Enforces strict value lists for categorical data
- Provides clear, meaningful names for coded values
- Supports both automatic and manual value assignment
- Improves data quality by preventing invalid entries

**Common Use Cases**: Order statuses, priority levels, user roles, product categories, workflow states

**Example Scenario**: An `order_status` domain with values like 'pending', 'processing', 'shipped', 'delivered' that can have either auto-assigned numbers (1, 2, 3, 4) or custom values ('PEND', 'PROC', 'SHIP', 'DELV').

### What are Schema Annotations? 
Schema Annotations are structured key-value pairs that attach metadata to database objects. Unlike traditional comments, annotations are queryable, standardized, and designed for automated reporting, making them ideal for compliance, documentation, and business intelligence needs.

### Why Use Them Together?
The combination creates a powerful data governance framework that benefits any organization:
- **Domains** enforce consistent data validation rules across all applications
- **Annotations** provide structured metadata for compliance, documentation, and automation
- Together they create self-documenting database schemas that reduce maintenance overhead and improve data quality

## Task 1: Understanding Domains Through Healthcare Examples

1. If you haven't done so already, from the Autonomous Database home page, **click** Database action and then **click** SQL.

    ![click SQL](../common-images/im1.png =50%x*)

    Using the ADMIN user isn't typically advised due to the high level of access and security concerns it poses. **However**, for this demo, we'll use it to simplify the setup and ensure we can show the full range of features effectively. 

2. Before we begin, this lab will be using Database Actions Web. If you're unfamiliar, please see the picture below for a simple explanation of the tool. You can click on the photo to enlarge it.

    ![click SQL](../common-images/simple-db-actions.png =50%x*)

1. Now that we understand the four types of Data Usecase Domains, let's see them in action by creating specialized healthcare domains that demonstrate each type while including compliance annotations.

  Let's create single column domains that apply constraints and validation to individual columns that can be reused across multiple tables.

    **Note**: We're using `CREATE DOMAIN IF NOT EXISTS` syntax, an Oracle Database 23ai feature that can prevents errors when running scripts multiple times. The feature lets you to create objects only if they don't already exist, making your database scripts more robust and reusable - particularly valuable in development environments where scripts may be executed repeatedly.

    ```sql
    <copy>
    -- Healthcare ID domain for consistent patient/encounter IDs
    CREATE DOMAIN IF NOT EXISTS healthcare_id AS NUMBER 
      CONSTRAINT healthcare_id_positive CHECK (healthcare_id > 0)
      ANNOTATIONS (
        data_classification 'Primary identifier for healthcare entities',
        retention_policy '7 years post last interaction'
      );

    -- Personal name domain with proper constraints
    CREATE DOMAIN IF NOT EXISTS person_name AS VARCHAR2(100) 
      CONSTRAINT name_not_empty CHECK (TRIM(person_name) IS NOT NULL)
      CONSTRAINT name_length CHECK (LENGTH(TRIM(person_name)) >= 2)
      ANNOTATIONS (
        data_classification 'PII - Personal Name',
        gdpr_compliant 'Subject to right of erasure'
      );

    -- Clinical note domain with size limits
    CREATE DOMAIN IF NOT EXISTS clinical_text AS CLOB
      CONSTRAINT clinical_text_not_empty CHECK (clinical_text IS NOT NULL)
      ANNOTATIONS (
        data_classification 'Protected Health Information (PHI)',
        hipaa_compliant 'Contains clinical observations and treatments',
        retention_policy 'Minimum 7 years, varies by jurisdiction'
      );
    </copy>
    ```

    These single column domains demonstrate:
    - **healthcare_id**: Ensures all IDs are positive numbers with retention policies
    - **person_name**: Validates names are non-empty and at least 2 characters with PII classification
    - **clinical_text**: Ensures sensitive text fields are never empty with comprehensive compliance metadata

3. Now we'll create enumeration domains that enforce strict value lists for categorical data, preventing invalid entries and improving data quality.

  Next, let's create enumeration domains - these enforce strict value lists for categorical data, preventing invalid entries and improving data quality.

    ```sql
    <copy>
    -- Medical status domain
    CREATE DOMAIN IF NOT EXISTS medical_status AS VARCHAR2(30)
      CONSTRAINT valid_status CHECK (medical_status IN (
        'Scheduled', 'In Progress', 'Completed', 'Cancelled', 
        'No-Show', 'Rescheduled', 'Emergency'
      ))
      ANNOTATIONS (
        data_classification 'Medical workflow status',
        business_rule 'Drives clinical workflow automation'
      );

    -- Gender domain with modern inclusive values
    CREATE DOMAIN IF NOT EXISTS gender_type AS VARCHAR2(20)
      CONSTRAINT valid_gender CHECK (gender_type IN (
        'Male', 'Female', 'Non-binary', 'Other', 'Prefer not to say', 'Unknown'
      ))
      ANNOTATIONS (
        data_classification 'Demographic information',
        sensitivity_level 'Medium'
      );
    </copy>
    ```

    These enumeration domains demonstrate:
    - **medical_status**: Ensures only valid workflow statuses, preventing data entry errors in clinical processes
    - **gender_type**: Provides modern, inclusive options with appropriate sensitivity classification

    Both patterns ensure data consistency while documenting business rules and privacy considerations.

## Task 2: Creating Healthcare Tables Using Domains

Now let's create tables that use these domains while adding table-level annotations.

1. Let's create a patients table that uses our domains while adding comprehensive table-level annotations for compliance tracking.

    ```sql
    <copy>
    CREATE TABLE IF NOT EXISTS patients (
      id                healthcare_id GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
      name              person_name NOT NULL,
      dob               DATE,
      sex               gender_type,
      primary_reason    VARCHAR2(200),
      created_at        TIMESTAMP DEFAULT SYSTIMESTAMP,
      last_updated      TIMESTAMP DEFAULT SYSTIMESTAMP,
      -- Virtual columns (23ai enhanced support for up to 4096 columns)
      full_name_upper   VARCHAR2(100) GENERATED ALWAYS AS (
        UPPER(name)
      ) VIRTUAL
    ) 
    ANNOTATIONS (
      hipaa_compliant 'Core patient demographics',
      data_classification 'Highly sensitive PII',
      business_purpose 'Patient identity and demographic tracking',
      table_comment 'Patient master data with HIPAA compliance'
    );
    </copy>
    ```

2. Now we'll create an appointments table that demonstrates how domains work with relational constraints and JSON columns.

    ```sql
    <copy>
    CREATE TABLE IF NOT EXISTS appointments (
      id                healthcare_id GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
      patient_id        healthcare_id NOT NULL,
      start_time        TIMESTAMP NOT NULL,
      end_time          TIMESTAMP GENERATED ALWAYS AS (
        start_time + INTERVAL '30' MINUTE
      ) VIRTUAL,
      reason            VARCHAR2(200),
      status            medical_status DEFAULT 'Scheduled',
      created_at        TIMESTAMP DEFAULT SYSTIMESTAMP,
      provider_name     person_name DEFAULT 'Dr. Rivera',
      -- JSON column for flexible appointment metadata
      appointment_data  JSON,
      CONSTRAINT appointments_patient_fk FOREIGN KEY (patient_id) 
        REFERENCES patients(id) ON DELETE CASCADE
    )
    ANNOTATIONS (
      business_purpose 'Healthcare appointment scheduling and tracking',
      data_retention '5 years post appointment',
      audit_required 'Yes - track all status changes'
    );
    </copy>
    ```

## Task 3: Testing Domain Constraints

Let's test our domain constraints by inserting valid and invalid data.

1. Let's insert some valid patient and appointment data to establish our baseline dataset.

    ```sql
    <copy>
    -- Insert valid patient data
    INSERT INTO patients (name, dob, sex, primary_reason) 
    VALUES ('Sarah Johnson', DATE '1985-03-15', 'Female', 'Annual checkup');

    INSERT INTO patients (name, dob, sex, primary_reason) 
    VALUES ('Alex Chen', DATE '1992-07-22', 'Non-binary', 'Follow-up consultation');

    -- Insert valid appointment
    INSERT INTO appointments (patient_id, start_time, reason, status, provider_name)
    VALUES (1, TIMESTAMP '2025-02-15 10:00:00', 'Routine physical', 'Scheduled', 'Dr. Martinez');

    COMMIT;
    </copy>
    ```

2. Now we'll test our domain constraints by attempting to insert data that violates our business rules.

    ```sql
    <copy>
    -- This will fail - invalid healthcare_id (negative number)
    INSERT INTO patients (id, name, dob, sex) 
    VALUES (-1, 'Invalid Patient', DATE '1990-01-01', 'Male');
    </copy>
    ```

    ```sql
    <copy>
    -- This will fail - person_name too short
    INSERT INTO patients (name, dob, sex) 
    VALUES ('A', DATE '1990-01-01', 'Male');
    </copy>
    ```

    ```sql
    <copy>
    -- This will fail - invalid medical_status
    INSERT INTO appointments (patient_id, start_time, reason, status)
    VALUES (1, TIMESTAMP '2025-02-16 14:00:00', 'Check-up', 'Invalid Status');
    </copy>
    ```

    Each of these should fail with clear constraint violation messages, demonstrating how domains enforce data integrity.

## Task 4: Querying Annotations for Compliance

  Now let's explore how annotations support compliance reporting.

1. Let's query the annotation metadata to see all the compliance information we've embedded in our database objects.

    ```sql
    <copy>
    SELECT 
      object_name,
      object_type,
      annotation_name,
      annotation_value
    FROM user_annotations_usage
    WHERE object_name IN ('PATIENTS', 'APPOINTMENTS', 'HEALTHCARE_ID', 'PERSON_NAME', 'MEDICAL_STATUS')
    ORDER BY object_name, annotation_name;
    </copy>
    ```

2. We'll generate a compliance report focusing on HIPAA-related classifications and data handling requirements.

    ```sql
    <copy>
    -- Generate HIPAA compliance report
    SELECT 
      object_name as "Database Object",
      object_type as "Object Type",
      annotation_value as "HIPAA Classification"
    FROM user_annotations_usage
    WHERE annotation_name = 'hipaa_compliant'
      OR annotation_name = 'data_classification'
    ORDER BY object_name;
    </copy>
    ```

3. Now let's create a report showing all our data retention policies, crucial for compliance and lifecycle management.

    ```sql
    <copy>
    -- Generate data retention policy report
    SELECT 
      object_name as "Database Object",
      annotation_value as "Retention Policy"
    FROM user_annotations_usage
    WHERE annotation_name = 'retention_policy'
        OR annotation_name = 'data_retention'
    ORDER BY object_name;
    </copy>
    ```

## Task 5: Multi-Column Domain Example

Now let's explore the power of multi-column domains with a complex healthcare example that demonstrates how to validate related data points as a logical unit.

  ```sql
  <copy>
    -- Multi-column domain for vital signs
    CREATE DOMAIN IF NOT EXISTS vital_signs AS (
      systolic_bp    AS NUMBER,
      diastolic_bp   AS NUMBER,
      heart_rate     AS NUMBER,
      temperature    AS NUMBER,
      recorded_at    AS TIMESTAMP
    )
    CONSTRAINT vital_signs_check CHECK (
      systolic_bp BETWEEN 70 AND 250 AND
      diastolic_bp BETWEEN 40 AND 150 AND
      heart_rate BETWEEN 30 AND 220 AND
      temperature BETWEEN 95.0 AND 110.0
    )
    ANNOTATIONS (
      data_classification 'Protected Health Information (PHI)',
      clinical_significance 'Core vital signs for patient monitoring',
      validation_rules 'Enforces medically reasonable ranges'
    );
  </copy>
  ```

    This multi-column domain demonstrates how to enforce relationships between related data points - all vital signs must fall within medically reasonable ranges, and they're validated as a complete set rather than individual values.

  ```sql
  <copy>
  -- Create table using the multi-column domain
  CREATE TABLE patient_vitals (
    id           healthcare_id GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    patient_id   healthcare_id NOT NULL,
    systolic_bp  NUMBER,
    diastolic_bp NUMBER,
    heart_rate   NUMBER,
    temperature  NUMBER,
    recorded_at  TIMESTAMP DEFAULT SYSTIMESTAMP,
    recorded_by  person_name NOT NULL,
    DOMAIN vital_signs(systolic_bp, diastolic_bp, heart_rate, temperature, recorded_at),
    CONSTRAINT patient_vitals_fk FOREIGN KEY (patient_id) REFERENCES patients(id)
  )
  ANNOTATIONS (
    clinical_purpose 'Patient vital signs monitoring',
    hipaa_compliant 'Contains PHI - vital signs measurements'
  );
  </copy>
  ```

## Task 6: Testing Multi-Column Domain

  ```sql
  <copy>
  -- Valid vital signs
  INSERT INTO patient_vitals (patient_id, systolic_bp, diastolic_bp, heart_rate, temperature, recorded_by)
  VALUES (1, 120, 80, 72, 98.6, 'Nurse Johnson');

  -- This should fail - temperature out of range
  INSERT INTO patient_vitals (patient_id, systolic_bp, diastolic_bp, heart_rate, temperature, recorded_by)
  VALUES (1, 125, 82, 68, 115.0, 'Nurse Smith');
  </copy>
  ```

## Task 7: Viewing Domain Information

  ```sql
  <copy>
  -- View all healthcare domains and their constraints
  SELECT 
    domain_name,
    name,
    search_condition
  FROM user_domain_constraints
  WHERE domain_name LIKE '%HEALTHCARE%' OR domain_name LIKE '%MEDICAL%' 
      OR domain_name LIKE '%PERSON%' OR domain_name LIKE '%VITAL%'
  ORDER BY domain_name;
  </copy>
  ```

  ```sql
  <copy>
  -- View domain columns for multi-column domains
  SELECT 
    domain_name,
    column_name,
    data_type,
    column_id
  FROM user_domain_cols
  WHERE domain_name = 'VITAL_SIGNS'
  ORDER BY column_id;
  </copy>
  ```

## Conclusion

In this lab, you've seen how Oracle Database 23ai's Domains and Annotations work together to solve real healthcare data governance challenges:

1. **Domains** provide reusable, consistent data validation across your entire schema
2. **Annotations** enable structured metadata management for compliance and documentation
3. **Together** they create self-documenting, compliant database schemas that reduce development time and audit complexity

LumenCare can now ensure data consistency, maintain regulatory compliance, and provide clear documentation—all built into the database schema itself.

## Learn More

* [Data Usecase Domains Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/application-data-usage.html)
* [Schema Annotations Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/annotations_clause.html)
* [Healthcare Data Compliance Best Practices](https://www.oracle.com/healthcare/database/)

## Acknowledgements
* **Author** - Killian Lynch, Database Product Management
* **Last Updated By/Date** - Killian Lynch, August 2025