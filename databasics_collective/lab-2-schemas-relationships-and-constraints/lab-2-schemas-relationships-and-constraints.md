# Lab 2: Design a Relational Schema

## Introduction

The reservation already has four related tables. Look at the design behind them: a flat student roster (one wide list with all details together) would repeat the same facts many times, while the ready schema stores each fact in one place. A **schema** is the set of tables and other objects owned by a database user.

### Objectives

You will:

- Find repeated facts in a flat data set.
- Explain how the ready tables separate those facts.
- Choose primary keys and foreign keys.
- Define constraints for required values and business rules.

Estimated Time: 15 minutes

## Task 1: See what a flat report repeats

1. Run a report that combines student, department, course, and enrollment details. A **query** is a request for data. This query uses **joins** to match rows from related tables using their ID columns.

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

    The query joins each student to their department, then joins each enrollment to its course. Matching ID columns connect the related rows. Because a student can take several courses, their name, email, and department can appear on several report rows. `ORDER BY` sorts the preview into a predictable order, while `FETCH FIRST 12 ROWS ONLY` limits it to a small sample.

2. Look for repeated details in the result. Student and department details repeat when a student takes several courses. Course details repeat for each student enrolled. This is the duplication a flat report creates when it is used as the main way to store data.

3. Imagine changing a department location in this spreadsheet. You would edit many rows and could miss one, leaving different rows with conflicting locations for the same department. The ready schema stores each fact once and joins the tables for reports.

## Task 2: Separate the entities

1. Use four tables to store each type of fact. An **entity** is a kind of thing the database tracks, such as a student, course, or department:

    | Table | Purpose | Primary key |
    | --- | --- | --- |
    | `DEPARTMENTS` | One row per department | `DEPARTMENT_ID` |
    | `STUDENTS` | One row per student | `STUDENT_ID` |
    | `COURSES` | One row per course | `COURSE_ID` |
    | `ENROLLMENTS` | One row per student and course pair | `STUDENT_ID`, `COURSE_ID` |

    A **primary key** is a column, or combination of columns, that uniquely identifies a row. The first three tables use one ID column; `ENROLLMENTS` uses the student and course IDs together because an enrollment is identified by that pair. This is a **composite key**. IDs keep relationships stable even if names or titles change.

2. Read this compact relationship diagram. It is an **entity relationship diagram (ERD)**, a simple map of tables and how their rows relate. In `1 ----- many`, one row on the left can connect to several rows on the right:

    ```text
    DEPARTMENTS 1 ----- many STUDENTS
    DEPARTMENTS 1 ----- many COURSES
    STUDENTS    1 ----- many ENROLLMENTS
    COURSES     1 ----- many ENROLLMENTS
    ```

3. `ENROLLMENTS` connects students and courses. One student can take many courses, and one course can have many students. This is a **many-to-many relationship**, represented by the enrollment table, which stores each student-course pair once.

4. A **one-to-one relationship** links one row to no more than one other row, such as a student and one current identity card. A **one-to-many relationship** lets one row connect to several rows. The workshop uses one-to-many and many-to-many relationships.

## Task 3: Choose the constraints

1. A **constraint** is a rule the database checks when data is inserted or changed. Match each rule to an Oracle constraint:

    | Rule | Constraint |
    | --- | --- |
    | Every row has a stable identifier | `PRIMARY KEY` |
    | Each student email and course code is different | `UNIQUE` |
    | Names, titles, and required relationships must have a value | `NOT NULL` |
    | Students and courses must reference an existing department; enrollments must reference an existing student and course | `FOREIGN KEY` |
    | Status must be `ACTIVE`, `PAUSED`, or `GRADUATED`; grade must be A, B, C, D, F, or not assigned yet; credits must be 1–6 | `CHECK` |

    These constraints protect the data when rows are inserted or changed. A `NOT NULL` rule requires a value. A `CHECK` rule accepts only values that match its condition; for example, a grade can be `A` through `F` or `NULL` (not assigned yet). A `FOREIGN KEY` prevents a course from referring to a department that is not in `DEPARTMENTS`, while `UNIQUE` prevents duplicate values in the specified column or columns. In this schema, the enrollment foreign key points to `STUDENTS.STUDENT_ID`, so an enrollment cannot refer to a student who is not in the `STUDENTS` table.

2. Review the physical model used by the ready tables.

    ```text
    DEPARTMENTS(department_id, department_name, location)
    STUDENTS(student_id, first_name, last_name, email,
                 department_id, enrollment_date, status)
    COURSES(course_id, course_code, course_title, credits, department_id)
    ENROLLMENTS(student_id, course_id, enrolled_on, grade)
    ```

3. Trace each foreign key in the model: `STUDENTS.DEPARTMENT_ID` and `COURSES.DEPARTMENT_ID` point to `DEPARTMENTS.DEPARTMENT_ID`; `ENROLLMENTS.STUDENT_ID` and `ENROLLMENTS.COURSE_ID` point to their matching parent keys. The two enrollment columns also form a composite primary key, so the same student-course pair cannot be entered twice.

4. The entities give you the main idea, or **conceptual model**. The **logical model** describes the tables, keys, and relationships used to represent it. Lab 3 queries the ready data. Lab 4 uses these rules in a small practice table.

## Task 4: Connect the design to the reservation

1. The reservation setup created the four core tables, their constraints, and the sample rows before you signed in. Constraint and index names start with `DBC_`, which helps you recognize workshop-created objects in the schema.

2. Lab 3 queries the loaded rows. Lab 4 lets you inspect their columns and rules, then create a separate practice table.

## Acknowledgements

* **Author** - Ilan Gómez Guerrero
* **Last Updated By/Date** - Ilan Gómez Guerrero, November 2026
