# Lab 2: Design a Relational Schema

## Introduction

Start with the design. The flat student roster repeats the same facts many times. You will split it into four related tables so each fact appears once.

### Objectives

You will:

- Find repeated facts in a flat data set.
- Separate those facts into related tables.
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
    | `DBC_DEPARTMENTS` | One row per department | `DEPARTMENT_ID` |
    | `DBC_STUDENTS` | One row per student | `STUDENT_ID` |
    | `DBC_COURSES` | One row per course | `COURSE_ID` |
    | `DBC_ENROLLMENTS` | One row per student and course pair | `STUDENT_ID`, `COURSE_ID` |

2. Read this compact entity relationship diagram.

    ```text
    DBC_DEPARTMENTS 1 ----- many DBC_STUDENTS
    DBC_DEPARTMENTS 1 ----- many DBC_COURSES
    DBC_STUDENTS    1 ----- many DBC_ENROLLMENTS
    DBC_COURSES     1 ----- many DBC_ENROLLMENTS
    ```

3. `DBC_ENROLLMENTS` connects students and courses. One student can take many courses, and one course can have many students. The enrollment table stores each student-course pair once.

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

2. Review the physical model that you will create in the next lab.

    ```text
    DBC_DEPARTMENTS(department_id, department_name, location)
    DBC_STUDENTS(student_id, first_name, last_name, email,
                 department_id, enrollment_date, status)
    DBC_COURSES(course_id, course_code, course_title, credits, department_id)
    DBC_ENROLLMENTS(student_id, course_id, enrolled_on, grade)
    ```

3. Check the foreign keys. Each one points to a primary key. The enrollment table combines its two foreign keys to create its own primary key.

4. The entities give you the main idea, or conceptual model. Keys and relationships turn it into a logical model. In the next lab, you will create the actual Oracle tables.

## Task 4: Prepare for deployment

1. Every workshop object starts with `DBC_`. A future setup script can find these objects without touching unrelated content in the schema.

2. In learner build mode, you will create the objects yourself. Demo-ready mode can use the repeatable scripts in `workshops/tenancy/sql`.

## Acknowledgements

* **Author** - Oracle University Program
* **Last Updated By/Date** - Oracle University Program, October 2026
