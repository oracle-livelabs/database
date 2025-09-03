# JSON Relational Duality Views: Unified Healthcare Data Access with Oracle Database 23ai

## Introduction

Welcome to the **JSON Relational Duality Views** lab! This final session in our LumenCare workshop series demonstrates how Oracle Database 23ai's JSON Relational Duality Views provide unified access to both relational and document data models, creating the ultimate flexibility for healthcare applications.

Building on the patient data, domains, and JSON documents from our previous labs, you'll learn how to create duality views that present the same healthcare data as both structured relational records and flexible JSON documents. This revolutionary capability eliminates the traditional trade-offs between relational integrity and document flexibility.

Estimated Lab Time: 20 minutes

### What You'll Learn

- Creating JSON Relational Duality Views over existing healthcare tables
- Updating data through duality views with automatic relational synchronization
- Querying the same data in both relational and JSON formats
- Understanding ACID compliance across document and relational operations
- Leveraging duality views for modern healthcare applications

### Prerequisites

- Access to Oracle Database 23ai
- Completion of previous LumenCare labs (Domains & Annotations, JSON Data Type, AI Vector Search)
- Basic understanding of JSON and SQL

## The LumenCare Integration Challenge

LumenCare's development teams face a common modern challenge: some applications work best with structured relational data (reporting, analytics, compliance systems), while others need flexible document models (mobile apps, APIs, real-time dashboards). Traditionally, this meant choosing one approach or maintaining dual storage systems.

**Oracle Database 23ai's JSON Relational Duality Views solve this completely.** The same data can be accessed and modified as either relational rows or JSON documents, with all changes automatically synchronized and ACID-compliant.

## Task 1: Understanding Your Existing Data

Before creating duality views, let's examine the healthcare data we've built throughout our previous labs.

1. **Review the existing patient and appointment data structure that we'll use for our duality views.**

    ```sql
    <copy>
    -- Check existing patients table
    SELECT id, name, dob, sex, primary_reason 
    FROM patients
    ORDER BY id;
    </copy>
    ```

    ```sql
    <copy>
    -- Check existing appointments with JSON data
    SELECT p.name as patient_name,
           a.id as appointment_id,
           a.start_time,
           a.reason,
           a.status,
           a.provider_name,
           JSON_SERIALIZE(a.appointment_data PRETTY) as appointment_details
    FROM appointments a
    JOIN patients p ON a.patient_id = p.id
    ORDER BY p.id, a.start_time;
    </copy>
    ```

    **What You'll See:** The structured patient demographics alongside rich appointment data stored as JSON, representing different aspects of the same healthcare encounters.

## Task 2: Creating Patient-Focused Duality Views with Precise Access Control

JSON Relational Duality Views allow you to define exactly how your data should be presented as JSON documents while maintaining full relational integrity. **Crucially, you can control exactly which operations (insert, update, delete) are allowed on each table through each view.**

1. **Create a patient-centric duality view with full patient access but controlled appointment access.**

    ```sql
    <copy>
    -- Create a comprehensive patient duality view
    CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW patient_complete_dv AS
    patients @insert @update
    {
        _id: id,
        patientName: name,
        dateOfBirth: dob,
        sex: sex,
        primaryReason: primary_reason,
        joinedDate: created_at,
        appointments: appointments @insert @update @delete
        [
            {
                appointmentId: id,
                scheduledTime: start_time,
                endTime: end_time,
                reason: reason,
                status: status,
                providerName: provider_name,
                createdAt: created_at,
                clinicalData: appointment_data
            }
        ]
    };
    </copy>
    ```

    **Understanding the Access Control Permissions:**
    - **`patients @insert @update`**: This view can create new patients and modify existing patient information, but **cannot delete patients** (no `@delete` specified)
    - **`appointments @insert @update @delete`**: This view has full control over appointments - can create, modify, and remove appointments
    - **Security Benefit**: Clinical staff can manage both patient demographics and appointments, but patient deletion requires a different, more restricted process

2. **Create a mobile appointment view with read-only patient access.**

    ```sql
    <copy>
    -- Create an appointment-focused duality view for mobile apps
    CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW appointment_mobile_dv AS
    appointments @insert @update @delete
    {
        _id: id,
        scheduledTime: start_time,
        appointmentLength: end_time,
        reason: reason,
        currentStatus: status,
        provider: provider_name,
        metadata: appointment_data,
        patientInfo: patients
        {
            patientId: id,
            name: name,
            dob: dob,
            sex: sex
        }
    };
    </copy>
    ```

    **Understanding This Mobile View's Permissions:**
    - **`appointments @insert @update @delete`**: Mobile apps can fully manage appointments (create, modify, cancel)
    - **`patients` (no permissions)**: Mobile apps can **read** patient information but **cannot modify** patient demographics
    - **Healthcare Benefit**: Prevents mobile scheduling apps from accidentally corrupting patient master data while still providing necessary information for appointment booking

## Task 3: Querying Data Through Duality Views

Now let's explore how the same data can be accessed in completely different formats through our duality views.

1. **Query patient data in JSON document format.**

    ```sql
    <copy>
    -- View complete patient records as JSON documents
    SELECT JSON_SERIALIZE(data PRETTY) as patient_document
    FROM patient_complete_dv
    WHERE JSON_VALUE(data, '$."patientName"') = 'Courtney Henry';
    </copy>
    ```

2. **Query appointment data optimized for mobile applications.**

    ```sql
    <copy>
    -- View appointments in mobile-optimized format
    SELECT JSON_SERIALIZE(data PRETTY) as mobile_appointment
    FROM appointment_mobile_dv 
    WHERE JSON_VALUE(data, '$."currentStatus"') = 'Completed'
    ORDER BY JSON_VALUE(data, '$."scheduledTime"')
    FETCH FIRST 3 ROWS ONLY;
    </copy>
    ```

3. **Compare relational vs. document access to the same underlying data.**

    ```sql
    <copy>
    -- Relational view: Traditional SQL query
    SELECT p.name, 
           COUNT(a.id) as appointment_count,
           AVG(JSON_VALUE(a.appointment_data, '$.duration' RETURNING NUMBER)) as avg_duration
    FROM patients p
    LEFT JOIN appointments a ON p.id = a.patient_id
    GROUP BY p.id, p.name
    ORDER BY appointment_count DESC;
    </copy>
    ```

    ```sql
    <copy>
    -- Document view: Extract same metrics from JSON structure
    WITH appointment_durations AS (
        SELECT JSON_VALUE(data, '$.patientName') as name,
               JSON_VALUE(data, '$.appointments.size()') as appointment_count,
               t.duration
        FROM patient_complete_dv p,
             JSON_TABLE(JSON_QUERY(data, '$.appointments'), '$[*]' 
                 COLUMNS (duration NUMBER PATH '$.clinicalData.duration')) t
    )
    SELECT name,
           appointment_count,
           AVG(duration) as avg_duration
    FROM appointment_durations
    GROUP BY name, appointment_count
    ORDER BY appointment_count DESC;
    </copy>
    ```

4. **Experience schema flexibility through existing JSON fields.**

    One of the big value propositions of JSON documents is schema flexibility. Our healthcare data already demonstrates this through the flexible appointment metadata stored in JSON format. Let's add additional clinical information to an existing appointment's JSON data.

    ```sql
    <copy>
    -- Add flexible clinical information to appointment metadata
    UPDATE patient_complete_dv p
    SET p.data = JSON_TRANSFORM(
        data,
        SET '$.appointments[0].clinicalData.vitalSigns' = JSON_OBJECT(
            'bloodPressure' VALUE '120/80',
            'heartRate' VALUE 72,
            'temperature' VALUE 98.6
        ),
        SET '$.appointments[0].clinicalData.notes' = 'Patient reports good progress with rehabilitation exercises'
    )
    WHERE JSON_VALUE(data, '$.patientName') = 'Courtney Henry';
    
    COMMIT;
    </copy>
    ```

    ```sql
    <copy>
    -- View the enhanced appointment with additional clinical data
    SELECT JSON_SERIALIZE(JSON_QUERY(data, '$.appointments[0].clinicalData') PRETTY) as enhanced_clinical_data
    FROM patient_complete_dv
    WHERE JSON_VALUE(data, '$.patientName') = 'Courtney Henry';
    </copy>
    ```

    As you can see, we added new clinical information (vital signs, notes) to the existing appointment's JSON metadata without modifying any table structures. This demonstrates the schema flexibility that duality views provide through their integration with Oracle's native JSON capabilities.

5. **Advanced Duality View capability - generated columns.**

    So far our duality views have mapped to the columns in our base relational model, exposing the information in the relational schema as JSON documents. However, there is more that you can do with duality views. Often, derived information from existing data is necessary to complete or augment the information of your 'business objects' - our JSON documents. This is very easily doable with duality views.

    In our healthcare example, you not only want to show the patient information with all their appointments, but you also want to know the total number of appointments that a patient actually has. We can use **generated fields** to add additional data that is derived from other information in our duality view. (Generated fields are ignored when updating data.)

    Let's enhance our patient duality view to include a generated field:

    ```sql
    <copy>
    -- Recreate the patient duality view with a generated column
    CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW patient_complete_dv AS
    patients @insert @update
    {
        _id: id,
        patientName: name,
        dateOfBirth: dob,
        sex: sex,
        primaryReason: primary_reason,
        joinedDate: created_at,
        appointments: appointments @insert @update @delete
        [
            {
                appointmentId: id,
                scheduledTime: start_time,
                endTime: end_time,
                reason: reason,
                status: status,
                providerName: provider_name,
                createdAt: created_at,
                clinicalData: appointment_data
            }
        ],
        totalAppointments @generated (path: "$.appointments.size()")
    };
    </copy>
    ```

    We didn't touch any data on disk, but only changed the metadata of our duality view.

    ```sql
    <copy>
    -- See the generated column in action
    SELECT JSON_SERIALIZE(data PRETTY) as patient_with_count
    FROM patient_complete_dv
    WHERE JSON_VALUE(data, '$.patientName') = 'Courtney Henry';
    </copy>
    ```

    You can see that the `totalAppointments` field is automatically calculated from the size of the appointments array. This derived information is available in every patient document without storing redundant data.

## Task 4: Updating Data Through Duality Views

The real power of duality views becomes apparent when updating data - changes made through any view automatically appear in all other views and the underlying tables.

1. **Add a new appointment through the patient-centric duality view.**

    ```sql
    <copy>
    -- Add appointment through patient duality view using JSON_TRANSFORM
    UPDATE patient_complete_dv p
    SET p.data = JSON_TRANSFORM(
        data,
        APPEND '$."appointments"' = JSON_OBJECT(
            'appointmentId' VALUE 999,
            'scheduledTime' VALUE TIMESTAMP '2025-09-15 14:30:00',
            'reason' VALUE 'Follow-up consultation',
            'status' VALUE 'Scheduled',
            'providerName' VALUE 'Dr. Jennifer Park',
            'clinicalData' VALUE JSON_OBJECT(
                'appointmentType' VALUE 'orthopedic',
                'duration' VALUE 30,
                'followUpWeeks' VALUE 4
            )
        )
    )
    WHERE JSON_VALUE(data, '$."patientName"') = 'Courtney Henry';
    
    COMMIT;
    </copy>
    ```

2. **Verify the appointment appears in all views and the base table.**

    ```sql
    <copy>
    -- Check the relational table
    SELECT reason, status, provider_name, 
           JSON_VALUE(appointment_data, '$.appointmentType') as type
    FROM appointments 
    WHERE id = 999;
    </copy>
    ```

    ```sql
    <copy>
    -- Check the mobile duality view
    SELECT JSON_SERIALIZE(data PRETTY) as mobile_view
    FROM appointment_mobile_dv
    WHERE JSON_VALUE(data, '$._id') = '999';
    </copy>
    ```

3. **Update appointment status through the mobile view.**

    ```sql
    <copy>
    -- Update status through mobile duality view
    UPDATE appointment_mobile_dv a
    SET a.data = JSON_TRANSFORM(
        data,
        SET '$."currentStatus"' = 'In Progress'
    )
    WHERE JSON_VALUE(data, '$._id') = '999';
    
    COMMIT;
    </copy>
    ```

4. **Verify the change propagated to all views.**

    ```sql
    <copy>
    -- Verify appointment 999 status in patient view
    SELECT appointment_id, status
    FROM patient_complete_dv p,
         JSON_TABLE(JSON_QUERY(p.data, '$.appointments'), '$[*]'
             COLUMNS (
                 appointment_id NUMBER PATH '$.appointmentId',
                 status VARCHAR2(50) PATH '$.status'
             )) t
    WHERE JSON_VALUE(p.data, '$.patientName') = 'Courtney Henry'
      AND appointment_id = 999;
    </copy>
    ```

    ```sql
    <copy>
    -- Verify in base table - shows the same status
    SELECT status FROM appointments WHERE id = 999;
    </copy>
    ```

## Task 5: Understanding Duality View Permissions and Security

One of the powerful features of duality views is the ability to control exactly which data can be modified and by whom. Remember that our `appointment_mobile_dv` view was designed for mobile applications and doesn't allow patient demographic updates.

1. **Try to update patient information through the mobile appointment view.**

    Let's attempt to change a patient's name through the mobile duality view that's designed only for appointment management.

    ```sql
    <copy>
    -- This should fail - mobile view doesn't allow patient updates
    UPDATE appointment_mobile_dv a
    SET a.data = JSON_TRANSFORM(
        data,
        SET '$.patientInfo.name' = 'Courtney Henry-Smith'
    )
    WHERE JSON_VALUE(data, '$._id') = '999';
    </copy>
    ```

    **Expected Result:** This will fail with an error because the `appointment_mobile_dv` view doesn't include `@update` permissions on the patients table. The mobile view is designed only to manage appointment data, not patient demographics.

2. **Now update the same patient information through the correct view.**

    ```sql
    <copy>
    -- This works - patient view allows patient updates
    UPDATE patient_complete_dv p
    SET p.data = JSON_TRANSFORM(
        data,
        SET '$.patientName' = 'Courtney Henry-Smith'
    )
    WHERE JSON_VALUE(data, '$.patientName') = 'Courtney Henry';
    
    COMMIT;
    </copy>
    ```

3. **Verify the security model worked as designed.**

    ```sql
    <copy>
    -- Check the updated name appears in patient view
    SELECT JSON_VALUE(data, '$.patientName') as updated_name
    FROM patient_complete_dv
    WHERE JSON_VALUE(data, '$._id') = '1';
    </copy>
    ```

    ```sql
    <copy>
    -- Check the same change appears in mobile view (read-only access to patient info)
    SELECT JSON_VALUE(data, '$.patientInfo.name') as patient_name_in_mobile_view
    FROM appointment_mobile_dv
    WHERE JSON_VALUE(data, '$._id') = '999';
    </copy>
    ```

    **Key Security Insight:** Duality views provide granular access control. The mobile view can *read* patient information but cannot *modify* it. Only the patient-focused duality view has permission to update patient demographics. This ensures that mobile applications can't accidentally corrupt patient master data while still providing access to necessary information for appointment management.


## Task 6: Performance and Indexing

Duality views benefit from the same indexing strategies as regular tables.

1. **Check existing indexes on our base tables.**

    ```sql
    <copy>
    -- View indexes on base tables
    SELECT table_name, index_name, column_name, uniqueness
    FROM user_ind_columns 
    WHERE table_name IN ('PATIENTS', 'APPOINTMENTS')
    ORDER BY table_name, index_name, column_position;
    </copy>
    ```

2. **Create indexes to optimize duality view queries.**

    ```sql
    <copy>
    -- Index for fast patient lookups
    CREATE INDEX IF NOT EXISTS idx_patients_name ON patients(name);
    
    -- Index for appointment status queries
    CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);
    
    -- JSON functional index for appointment metadata
    CREATE INDEX IF NOT EXISTS idx_appointment_type ON appointments (
        JSON_VALUE(appointment_data, '$.appointmentType')
    );
    </copy>
    ```

## Conclusion

In this lab, you've experienced the revolutionary power of Oracle Database 23ai's JSON Relational Duality Views applied to healthcare data:

1. **Unified Data Access**: The same healthcare data accessible as both relational records and JSON documents
2. **Automatic Synchronization**: Changes through any view instantly appear everywhere
3. **ACID Compliance**: Full transactional consistency across document and relational operations  
4. **Flexible Modeling**: Different applications can use the optimal data representation
5. **Performance**: Benefits from traditional indexing and query optimization

JSON Relational Duality Views eliminate the traditional choice between relational integrity and document flexibility, enabling LumenCare to build modern applications without data architecture compromises.

## Learn More

* [JSON Relational Duality Views Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/jsnvu/overview-json-relational-duality-views.html)
* [Duality View SQL Reference](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/create-json-relational-duality-view.html)
* [Healthcare Data Modernization with Oracle 23ai](https://www.oracle.com/healthcare/database/)

## Acknowledgements
* **Author** - Killian Lynch, Database Product Management  
* **Last Updated By/Date** - Killian Lynch, January 2025