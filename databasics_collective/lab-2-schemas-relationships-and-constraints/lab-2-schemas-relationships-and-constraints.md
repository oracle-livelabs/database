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

## Task 1: Find the repeated facts

1. Consider a single table with these columns:

    ```text
    STUDENT_ID, STUDENT_NAME, EMAIL, DEPARTMENT_NAME, DEPARTMENT_LOCATION,
    COURSE_CODE, COURSE_TITLE, CREDITS, ENROLLED_ON, GRADE
    ```

2. Look for facts that repeat. A student name and department would appear once for every enrollment. Course details would appear once for every student in that course.

3. Think about a department location change. You would need to update several rows, and missing one would leave conflicting data.

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
