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

## Task 1: Understanding Existing Data

1. Before creating duality views, let's examine the healthcare data we've built throughout our previous labs and add the flexibility needed for evolving healthcare requirements.

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

2. Now, lets add schema flexibility to the patients table. Healthcare data requirements often change - new regulations, additional patient information, or evolving clinical practices. Let's add a flex field to handle future requirements.

    ```sql
    <copy>
    -- Add a flexible JSON column for future patient information
    ALTER TABLE patients ADD (
        patient_extras JSON (object)
    );
    </copy>
    ```

## Task 2: Creating Duality Views 

1. JSON Relational Duality Views allow you to define exactly how your data should be presented as JSON documents while maintaining full relational integrity.

    Create a patient-centric duality view with full patient access but controlled appointment access.

    ```sql
    <copy>
    -- Create a comprehensive patient duality view with schema flexibility
    CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW patient_complete_dv AS
    patients @insert @update
    {
        _id: id,
        patientName: name,
        dateOfBirth: dob,
        sex: sex,
        primaryReason: primary_reason,
        joinedDate: created_at,
        patient_extras @flex,
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

2. Now, create a mobile appointment view with read-only patient access.

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

1. Now let's explore how the same data can be accessed in completely different formats through our duality views. Query patient data in JSON document format.

    ```sql
    <copy>
    -- View complete patient records as JSON documents
    SELECT JSON_SERIALIZE(data PRETTY) as patient_document
    FROM patient_complete_dv
    WHERE JSON_VALUE(data, '$."patientName"') = 'Courtney Henry';
    </copy>
    ```

2. Next, query appointment data optimized for mobile applications through our mobile duality view

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

3. Here, we can see relational vs. document access to the same underlying data.

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
    -- Document view: Derive appointment count by COUNT(*) after JSON_TABLE expansion
    SELECT JSON_VALUE(p.data, '$.patientName') as name,
        COUNT(t.duration) as appointment_count,
        AVG(t.duration) as avg_duration
    FROM patient_complete_dv p
    LEFT JOIN JSON_TABLE(
        JSON_QUERY(p.data, '$.appointments'), '$[*]'
        COLUMNS (duration NUMBER PATH '$.clinicalData.duration')
    ) t ON 1=1
    GROUP BY JSON_VALUE(p.data, '$.patientName')
    ORDER BY appointment_count DESC;
    </copy>
    ```

4. One of the big value propositions of JSON documents is schema flexibility. You don't have to know all attributes and structures of your documents ahead of time - and those will most likely change over time anyway. Duality views give you this flexibility with their flex fields.

    The patient\_complete\_dv duality view was defined with this schema flexibility through the `patient extras @flex` field, so we can add any attribute to our patient documents. Any attribute that is not explicitly mapped to a relational column will be stored in the flex column.

    ```sql
    <copy>
    -- Add flexible patient information using the flex field
    UPDATE patient_complete_dv p
    SET p.data = JSON_TRANSFORM(
        data,
        SET '$.insuranceProvider' = 'Blue Cross Blue Shield',
        SET '$.emergencyContact' = JSON_OBJECT(
            'name' VALUE 'Sarah Johnson',
            'relationship' VALUE 'Spouse', 
            'phone' VALUE '555-0123'
        ),
        SET '$.allergies' = JSON_ARRAY('penicillin', 'shellfish')
    )
    WHERE JSON_VALUE(data, '$.patientName') = 'Courtney Henry';
    
    COMMIT;
    </copy>
    ```

    ```sql
    <copy>
    -- View the enhanced patient document
    SELECT JSON_SERIALIZE(data PRETTY) as enhanced_patient_data
    FROM patient_complete_dv
    WHERE JSON_VALUE(data, '$.patientName') = 'Courtney Henry';
    </copy>
    ```

    As you can see, we added new attributes that weren't part of our original table structure without any problems. Checking the relational underlying table will show you where this information ended up: in the flex field `patient_extras`.

    ```sql
    <copy>
    -- See where the flex data is stored in the relational table
    SELECT name, JSON_SERIALIZE(patient_extras PRETTY) as extras_data
    FROM patients 
    WHERE name = 'Courtney Henry';
    </copy>
    ```

5. There is more that you can do with duality views. Often, derived information from existing data is necessary to complete or augment the information of your 'business objects' - our JSON documents. This is very easily doable with duality views.

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

1. First, let's reset our duality view to the standard structure for the update examples.

    ```sql
    <copy>
    -- Recreate the patient duality view without generated fields for update examples
    CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW patient_complete_dv AS
    patients @insert @update
    {
        _id: id,
        patientName: name,
        dateOfBirth: dob,
        sex: sex,
        primaryReason: primary_reason,
        joinedDate: created_at,
        patient_extras @flex,
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

2. Now we can add a new appointment through the patient-centric duality view.

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

3. Now lets verify the appointment appears in all views and the base table.

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

3. We can also update appointment status through the mobile view.

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

4. Again, we can verify the change propagated to all views.

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

1. Another aspect of duality views is the ability to control exactly what data can be modified and by whom. Remember that our `appointment_mobile_dv` view was designed for mobile applications and doesn't allow patient demographic updates.

    Let's try to update patient information through the mobile appointment view.

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

2. Now update the same patient information through the correct view.

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

3. We can also verify the security model worked as designed.

    ```sql
    <copy>
    -- Check the updated name appears in patient view
    SELECT JSON_VALUE(data, '$.patientName') as updated_name
    FROM patient_complete_dv
    WHERE JSON_VALUE(data, '$._id') = '3';
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


## Conclusion

In this lab, you've explored Oracle Database 23ai's JSON Relational Duality Views:

- **Task 1**: Added schema flexibility to existing healthcare data
- **Task 2**: Created duality views with precise access control permissions 
- **Task 3**: Queried data through both relational and document interfaces, experienced schema flexibility with flex fields, and used generated columns
- **Task 4**: Updated data through duality views with automatic synchronization
- **Task 5**: Tested security permissions across different duality views

You've seen how duality views provide unified access to the same data as both relational tables and JSON documents, with automatic synchronization and granular security control.

## Learn More

* [JSON Relational Duality Views Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/jsnvu/overview-json-relational-duality-views.html)
* [Duality View SQL Reference](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/create-json-relational-duality-view.html)


## Acknowledgements
* **Author** - Killian Lynch, Database Product Management  
* **Last Updated By/Date** - Killian Lynch, September 2025