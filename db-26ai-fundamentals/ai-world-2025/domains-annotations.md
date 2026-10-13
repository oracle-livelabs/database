# Domains and Annotations with Oracle AI Database 26ai

## Introduction

Welcome to the **Domains and Annotations** lab! In this hands-on session, you'll learn how Oracle AI Database 26ai's Data Use Case Domains and Schema Annotations work together to solve data governance challenges in the LumenCare demo.

As organizations like LumenCare manage increasingly complex data requirements—from regulatory compliance to business workflow automation, traditional database comments and constraints fall short. This lab demonstrates how modern database features can enforce data integrity while maintaining comprehensive metadata documentation for any business domain.

Estimated Lab Time: 15 minutes

### Objective:
The objective of this lab is to demonstrate Oracle AI Database 26ai's Data Use Case Domains and Schema Annotations for enterprise data governance. By the end of this lab, you will understand how to create reusable domains, embed structured metadata in your schema with Annotations, and query them for any number of reasons.

**The LumenCare Challenge**
LumenCare's platform faces several common data governance challenges that many organizations encounter:

1. **Data Consistency**: Business IDs, names, and status values need consistent validation across all applications
2. **Regulatory Compliance**: Industry regulations require detailed metadata documentation and audit trails
3. **Business Data Integrity**: Critical business records must enforce proper constraints while remaining flexible for different workflows
4. **Audit Requirements**: All sensitive data needs structured metadata for compliance reporting and business intelligence

### Prerequisites:
- Access to Oracle AI Database 26ai.
- Basic understanding of SQL concepts.

## What are Data Use Case Domains?
Data Use Case Domains provide reusable data types with built-in constraints and validation rules. Unlike simple data types, domains can enforce complex business rules and provide consistent metadata across your entire schema, reducing development time and ensuring data quality.

  ![click SQL](./images/domains-ll.png =28%x*)


Data Use Case Domains also provide consistent metadata for development, analytics, and ETL applications and tools, helping to ensure data consistency and validation throughout the schema.

### Understanding the Four Types of Data Use Case Domains

Before we dive into our healthcare examples, let's understand the four types of Data Use Case Domains available in Oracle AI Database 26ai:

#### 1. Single Column Domain
* **Purpose**: Applies constraints and validation rules to a single column across multiple tables.
* **Common Use Cases**: Email validation, price constraints, ID formats, status codes
* **Example Scenario**: A `price` domain that ensures all monetary values are positive numbers, used consistently across product tables, invoice tables, and pricing history tables.

#### 2. Multi-Column Domain
* **Purpose**: Applies constraints across multiple related columns, treating them as a logical unit.
* **Common Use Cases**: Address validation (street, city, state, zip), coordinate validation (latitude/longitude), date ranges (start/end dates), contact information (phone/email combinations)
* **Example Scenario**: A `coordinates` domain that ensures latitude is between -90 and 90 degrees and longitude is between -180 and 180 degrees, preventing invalid geographical data.

#### 3. Flexible Domain
* **Purpose**: Allows dynamic selection of different Data Use Case Domains based on specific conditions or context.
* **Common Use Cases**: Contact information that varies by type (personal vs. business), product specifications that differ by category, user profiles with role-based fields
* **Example Scenario**: A `contact_information` domain that applies different validation rules for personal contacts (requires name and phone) versus business contacts (requires company name, contact person, and phone).

#### 4. Enumeration Use Case Domain
* **Purpose**: Contains a predefined set of named values, optionally with corresponding numeric or string values.
* **Common Use Cases**: Order statuses, priority levels, user roles, product categories, workflow states
* **Example Scenario**: An `order_status` domain with values like 'pending', 'processing', 'shipped', 'delivered' that can have either auto-assigned numbers (1, 2, 3, 4) or custom values ('PEND', 'PROC', 'SHIP', 'DELV').

## What are Schema Annotations? 
Schema Annotations, as an extension of traditional comments, offer a more structured and versatile approach to database documentation. They allow us to associate name-value pairs with database objects, allowing us to describe, classify, and categorize them according to our specific requirements.

### Why Use Them Together?
The combination creates a data governance framework that benefits any organization:
- **Domains** enforce consistent data validation rules across all applications
- **Annotations** provide structured metadata for compliance, documentation, and automation
- Together they create self-documenting database schemas that reduce maintenance overhead and improve data quality

## Task 1: Creating Domains

1. If you haven't done so already, on the **Autonomous Database details** page, click the **Database actions** drop-down list, and then click **Database Users**.

    ![The Database Actions button is highlighted.](./images/im1.png =50%x* " ")

2. From the Database Users page, click the icon to open the `AIWORLD25` users login page.

    ![The Database Actions button is highlighted.](./images/im2.png =50%x* " ")

3. Sign in with the following info:
    * Username: AIWORLD25
    * Password: OracleAIworld2025

    ![The Database Actions button is highlighted.](./images/im3.png =50%x* " ")

4. This is the database actions launchpad. From here, select open (in the bottom right hand corner) to launch the SQL Editor

    ![The Database Actions button is highlighted.](./images/im4.png =50%x* " ")

5. Before we begin, this lab will be using Database Actions Web. If you're unfamiliar, please see the picture below for a simple explanation of the tool. You can click on the photo to enlarge it.

    ![The Database Actions button is highlighted.](../common-images/simple-db-actions.png =50%x* " ")

1. Now that we understand the four types of Data Use Case Domains, let's see them in action by creating specialized healthcare domains that demonstrate each type while including annotations.

  Let's create single column domains that apply constraints and validation to individual columns that can be reused across multiple tables.

    **Note**: We're using `IF NOT EXISTS` syntax, an Oracle AI Database 26ai feature that can prevents errors when running scripts multiple times. The feature lets you to create objects only if they don't already exist, making your database scripts more robust and reusable - particularly valuable in development environments where scripts may be executed repeatedly.

    ```sql
    <copy>
    -- Healthcare ID domain for consistent patient/encounter IDs
    CREATE DOMAIN IF NOT EXISTS healthcare_id AS NUMBER
    CONSTRAINT healthcare_id_positive CHECK (healthcare_id > 0)
    ANNOTATIONS (
    data_classification 'Primary identifier for healthcare entities'
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
    hipaa_compliant 'Contains clinical observations and treatments'
    );
    </copy>
    ```

    These single column domains demonstrate the **domain-level annotation pattern**:
    - **healthcare_id**: Validation rules + universal metadata 
    - **person_name**: Data constraints + reusable compliance tags (GDPR, GDPR flags)
    - **clinical_text**: Business rules + universal classification that applies everywhere this domain is used

    **Annotation Best Practice**: 
    - **Domain-level**: Universal, reusable metadata (classification, compliance flags, business sensitivity)
    - **Table-level**: Contextual, business-specific metadata (retention policies, purpose of use, jurisdiction rules)
    
    This separation ensures consistent compliance tagging while maintaining clear business context for each table.

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
        'Male', 'Female', 'Other', 'Prefer not to say', 'Unknown'
      ));
    </copy>
    ```

    Both patterns ensure data consistency while documenting business rules and privacy considerations.

## Task 2: Creating Healthcare Tables Using Domains

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
      -- Virtual columns (26ai enhanced support for up to 4096 columns)
      full_name_upper   VARCHAR2(100) GENERATED ALWAYS AS (
        UPPER(name)
      ) VIRTUAL
    ) 
    ANNOTATIONS (
      retention_policy 'Retain for 7 years after patient relationship ends',
      clinical_purpose 'Stores core patient information'
    );
    </copy>
    ```

2. Now we'll create an appointments table that demonstrates how domains work with relational constraints and JSON columns (More on the JSON data columns in the next lab).

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
      retention_policy 'Retain for 5 years after appointment date',
      clinical_purpose 'Tracks scheduling and outcomes of patient visits'
    );
    </copy>
    ```


## Task 3: Testing Domain Constraints

1. Let's test our domain constraints by inserting valid and invalid data.

    ```sql
    <copy>
    -- Insert valid patient data
  INSERT INTO patients (id, name, dob, sex, primary_reason) 
  VALUES (1, 'Sarah Johnson', DATE '1985-03-15', 'Female', 'Annual checkup'),
        (2, 'Alex Chen', DATE '1992-07-22', 'Male', 'Follow-up consultation');

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

    -- This will fail - person_name too short
    INSERT INTO patients (name, dob, sex) 
    VALUES ('A', DATE '1990-01-01', 'Male');

    -- This will fail - invalid medical_status
    INSERT INTO appointments (patient_id, start_time, reason, status)
    VALUES (1, TIMESTAMP '2025-02-16 14:00:00', 'Check-up', 'Invalid Status');
    </copy>
    ```

## Task 4: Multi-Column Domain Example

1. Now let's explore the power of multi-column domains with an example that shows how to validate related data points as a logical unit. 

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

2. Now create a table using the multi-column domain

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
        retention_policy '7 years post last interaction',
        clinical_purpose 'Patient vital signs monitoring and clinical assessment'
          );
    </copy>
    ```

3. We can test the multi-column constraints

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

## Task 5: Exploring Annotations and Domain Information

1. We can explore metadata to learn more about our annotations. 

    ```sql
    <copy>
    SELECT *
    FROM user_annotations_usage
    </copy>
    ```

2. Now let's create a report showing all our data retention policies

    ```sql
    <copy>
    -- Generate data retention policy report
    SELECT 
      object_name as "Database Object",
      object_type as "Object Type",
      annotation_value as "Retention Policy"
    FROM user_annotations_usage
    WHERE annotation_name = 'RETENTION_POLICY'
    ORDER BY object_name;
    </copy>
    ```

3. Now, view all healthcare domains and their constraints

    ```sql
    <copy>
    -- View all healthcare domains and their constraints
    SELECT *
    FROM user_domain_constraints;
    </copy>
    ```

4. View domain columns for multi-column domains

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

In this lab, you've seen how Oracle AI Database 26ai's Domains and Annotations work together to solve real data governance challenges:

1. **Domains** provide reusable, consistent data validation across your entire schema
2. **Annotations** enable structured metadata management

LumenCare can now ensure data consistency, maintain regulatory compliance, and provide clear documentation—all built into the database schema itself.

## Learn More

* [Data Use Case Domains Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/application-data-usage.html)
* [Schema Annotations Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/annotations_clause.html)

## Acknowledgements
* **Author** - Killian Lynch, Database Product Management
* **Last Updated By/Date** - Killian Lynch, September 2025