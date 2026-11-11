# Lab 3: Create and Manage Data Structures

## Introduction

Turn the design into Oracle tables. Create the four tables, add their rules, make one small change, and then check the structure.

### Objectives

You will:

- Create tables with Oracle data types.
- Modify a table with `ALTER TABLE`.
- Add primary, unique, foreign key, and check constraints.
- Inspect table columns and constraints.
- Recognize how DDL affects transactions.

Estimated Time: 20 minutes

## Task 1: Create the department and student tables

1. Run the following statements as a script.

    ```sql
    <copy>
    CREATE TABLE dbc_departments (
        department_id   NUMBER(4),
        department_name VARCHAR2(100) NOT NULL,
        location        VARCHAR2(100) NOT NULL,
        CONSTRAINT dbc_departments_pk PRIMARY KEY (department_id),
        CONSTRAINT dbc_departments_name_uk UNIQUE (department_name)
    );

    CREATE TABLE dbc_students (
        student_id      NUMBER(6),
        first_name      VARCHAR2(50) NOT NULL,
        last_name       VARCHAR2(50) NOT NULL,
        email           VARCHAR2(150) NOT NULL,
        department_id   NUMBER(4) NOT NULL,
        enrollment_date DATE DEFAULT SYSDATE NOT NULL,
        status          VARCHAR2(12) DEFAULT 'ACTIVE' NOT NULL,
        CONSTRAINT dbc_students_pk PRIMARY KEY (student_id),
        CONSTRAINT dbc_students_email_uk UNIQUE (email),
        CONSTRAINT dbc_students_status_ck
            CHECK (status IN ('ACTIVE', 'PAUSED', 'GRADUATED')),
        CONSTRAINT dbc_students_dept_fk
            FOREIGN KEY (department_id)
            REFERENCES dbc_departments (department_id)
    );
    </copy>
    ```

    Start with departments because students will reference them. The primary key identifies each department, and the unique rule prevents repeated department names.

    The student table requires a name, email, and department. It fills in the enrollment date and status when you omit them. The check rule accepts only the three listed status values. The foreign key accepts only departments that already exist.

2. You should see two successful DDL statements. If Oracle reports that a table already exists, ask your instructor whether the schema uses demo-ready mode.

## Task 2: Create the course and enrollment tables

1. Run the next two statements as a script.

    ```sql
    <copy>
    CREATE TABLE dbc_courses (
        course_id      NUMBER(6),
        course_code    VARCHAR2(20) NOT NULL,
        course_title   VARCHAR2(120) NOT NULL,
        credits        NUMBER(1) NOT NULL,
        department_id  NUMBER(4) NOT NULL,
        CONSTRAINT dbc_courses_pk PRIMARY KEY (course_id),
        CONSTRAINT dbc_courses_code_uk UNIQUE (course_code),
        CONSTRAINT dbc_courses_credits_ck CHECK (credits BETWEEN 1 AND 6),
        CONSTRAINT dbc_courses_dept_fk
            FOREIGN KEY (department_id)
            REFERENCES dbc_departments (department_id)
    );

    CREATE TABLE dbc_enrollments (
        student_id     NUMBER(6),
        course_id      NUMBER(6),
        enrolled_on    DATE DEFAULT SYSDATE NOT NULL,
        grade          VARCHAR2(2),
        CONSTRAINT dbc_enrollments_pk PRIMARY KEY (student_id, course_id),
        CONSTRAINT dbc_enroll_student_fk
            FOREIGN KEY (student_id)
            REFERENCES dbc_students (student_id),
        CONSTRAINT dbc_enroll_course_fk
            FOREIGN KEY (course_id)
            REFERENCES dbc_courses (course_id),
        CONSTRAINT dbc_enroll_grade_ck
            CHECK (grade IN ('A', 'B', 'C', 'D', 'F') OR grade IS NULL)
    );
    </copy>
    ```

    Courses also belong to a department, and the credit rule accepts values from 1 through 6.

    `DBC_ENROLLMENTS` is the bridge between students and courses. Its two-column primary key prevents the same enrollment from appearing twice. A grade can stay empty until the course is complete. When a grade is present, it must match one of the listed values.

2. Notice the order. A parent table must exist before another table can reference it with a foreign key.

## Task 3: Inspect the columns

1. Query the data dictionary.

    ```sql
    <copy>
    SELECT table_name,
           column_id,
           column_name,
           data_type,
           data_length,
           nullable
    FROM   user_tab_columns
    WHERE  table_name LIKE 'DBC\_%' ESCAPE '\'
    ORDER  BY table_name, column_id;
    </copy>
    ```

    `USER_TAB_COLUMNS` lists the columns owned by your user. The filter keeps only names that begin with `DBC_`. The `ESCAPE '\'` part treats the underscore as a real character, not a wildcard. Check the type, size, order, and null setting for each column.

2. Find one `NUMBER`, one `VARCHAR2`, and one `DATE` column. Check `NULLABLE` for a required column. Oracle also supports `JSON`, `VECTOR`, `CLOB`, and `BLOB`.

3. Add a temporary column.

    ```sql
    <copy>
    ALTER TABLE dbc_students
        ADD (preferred_name VARCHAR2(50));
    </copy>
    ```

    You just added an optional text column. It has no default and no `NOT NULL` rule, so it can remain empty.

4. Rerun the query from Step 1 and find `PREFERRED_NAME`. Then restore the planned design.

    ```sql
    <copy>
    ALTER TABLE dbc_students
        DROP COLUMN preferred_name;
    </copy>
    ```

    `DROP COLUMN` removes the temporary column and returns the table to the original design. It also removes any values stored in that column, so take care outside a practice schema.

## Task 4: Inspect the constraints

1. Run this query.

    ```sql
    <copy>
    SELECT table_name,
           constraint_name,
           constraint_type,
           status
    FROM   user_constraints
    WHERE  table_name LIKE 'DBC\_%' ESCAPE '\'
    ORDER  BY table_name, constraint_type, constraint_name;
    </copy>
    ```

    `USER_CONSTRAINTS` lists the rules on objects owned by your user. The result shows each rule name, type, and status. Sorting the rows makes the related rules easier to compare.

2. Interpret the constraint types:

    - `P` identifies a primary key.
    - `R` identifies a foreign key.
    - `U` identifies a unique constraint.
    - `C` identifies a check constraint or a generated `NOT NULL` rule.

3. Oracle commits pending work before and after DDL such as `CREATE`, `ALTER`, `RENAME`, and `DROP`. Keep DDL separate from data changes when you may need a rollback.

## Acknowledgements

* **Author** - Oracle University Program
* **Last Updated By/Date** - Oracle University Program, October 2026
