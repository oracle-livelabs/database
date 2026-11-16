# Lab 2: Design a Relational Schema

## Introduction

The reservation already has four related tables. Look at the design behind them: a flat student roster would repeat the same facts many times, while the ready schema stores each fact in one place.

### Objectives

You will:

- Find repeated facts in a flat data set.
- Explain how the ready tables separate those facts.
- Choose primary keys and foreign keys.
- Define constraints for required values and business rules.

Estimated Time: 15 minutes

## Task 1: See what a flat report repeats

1. Run a report that combines student, department, course, and enrollment details.

    ```sql
    <copy>
    SELECT s.student_id,
           s.first_name || ' ' || s.last_name AS student_name,
           s.email,
           d.department_name,
           d.location,
           c.course_code,
           c.course_title,
           e.enrolled_on,
           e.grade
    FROM   students s
    JOIN   departments d ON d.department_id = s.department_id
    JOIN   enrollments e ON e.student_id = s.student_id
    JOIN   courses c ON c.course_id = e.course_id
    ORDER  BY s.student_id, c.course_code
    FETCH FIRST 12 ROWS ONLY;
    </copy>
    ```

2. Student and department details repeat when a student takes several courses. Course details repeat for each student enrolled.

3. Imagine changing a department location in this spreadsheet. You would edit many rows and could miss one. The ready schema stores each fact once and joins the tables for reports.

## Task 2: Separate the entities

1. Use four tables to store each type of fact:

    | Table | Purpose | Primary key |
    | --- | --- | --- |
    | `DEPARTMENTS` | One row per department | `DEPARTMENT_ID` |
    | `STUDENTS` | One row per student | `STUDENT_ID` |
    | `COURSES` | One row per course | `COURSE_ID` |
    | `ENROLLMENTS` | One row per student and course pair | `STUDENT_ID`, `COURSE_ID` |

2. Read this compact entity relationship diagram.

    ```text
    DEPARTMENTS 1 ----- many STUDENTS
    DEPARTMENTS 1 ----- many COURSES
    STUDENTS    1 ----- many ENROLLMENTS
    COURSES     1 ----- many ENROLLMENTS
    ```

3. `ENROLLMENTS` connects students and courses. One student can take many courses, and one course can have many students. The enrollment table stores each student-course pair once.

4. A one-to-one relationship links one row to no more than one other row. A student and one current identity card are a simple example. The workshop model also uses one-to-many and many-to-many relationships.

## Task 3: Choose the constraints

1. Match each rule to an Oracle constraint:

    | Rule | Constraint |
    | --- | --- |
    | Every row has a stable identifier | `PRIMARY KEY` |
    | Each student email and course code is different | `UNIQUE` |
    | Names, titles, and required relationships must have a value | `NOT NULL` |
    | A student or course must reference an existing department | `FOREIGN KEY` |
    | Status, grade, and credit values must stay in an allowed range | `CHECK` |

2. Review the physical model used by the ready tables.

    ```text
    DEPARTMENTS(department_id, department_name, location)
    STUDENTS(student_id, first_name, last_name, email,
                 department_id, enrollment_date, status)
    COURSES(course_id, course_code, course_title, credits, department_id)
    ENROLLMENTS(student_id, course_id, enrolled_on, grade)
    ```

3. Check the foreign keys. Each one points to a primary key. The enrollment table combines its two foreign keys to create its own primary key.

4. The entities give you the main idea, or conceptual model. Keys and relationships turn it into a logical model. Lab 3 queries the ready data. Lab 4 uses these rules in a small practice table.

## Task 4: Connect the design to the reservation

1. Constraint and index names start with `DBC_` so you can recognize them in the schema. Terraform loaded the four core tables and their sample rows before you signed in.

2. Lab 3 queries the loaded rows. Lab 4 lets you inspect their columns and rules, then create a separate practice table.

## Acknowledgements

* **Author** - Ilan Gómez Guerrero
* **Last Updated By/Date** - Ilan Gómez Guerrero, November 2026
