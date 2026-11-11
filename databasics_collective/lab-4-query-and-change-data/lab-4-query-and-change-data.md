# Lab 4: Query and Change Data Safely

## Introduction

The tables are ready. Add a small dataset, join the related rows, and then test a few changes without keeping them.

### Objectives

You will:

- Insert related rows in the correct order.
- Filter, sort, join, and aggregate data with `SELECT`.
- Use targeted `UPDATE` and `DELETE` statements.
- Control a transaction with `SAVEPOINT`, `ROLLBACK`, and `COMMIT`.

Estimated Time: 25 minutes

## Task 1: Load the sample data

1. If your environment already contains rows in the `DBC_` tables, continue to Task 2. Otherwise, insert the departments.

    ```sql
    <copy>
    INSERT ALL
        INTO dbc_departments VALUES (10, 'Computer Science', 'North Campus')
        INTO dbc_departments VALUES (20, 'Business', 'Central Campus')
        INTO dbc_departments VALUES (30, 'Design', 'Arts Campus')
    SELECT 1 FROM dual;
    </copy>
    ```

    `INSERT ALL` adds the three departments with one command. Each `INTO` clause adds one row. Load departments first because students and courses will reference them.

2. Insert the students.

    ```sql
    <copy>
    INSERT ALL
        INTO dbc_students
            (student_id, first_name, last_name, email, department_id,
             enrollment_date, status)
        VALUES
            (1001, 'Ana', 'Torres', 'ana.torres@example.edu', 10,
             DATE '2026-08-17', 'ACTIVE')
        INTO dbc_students
            (student_id, first_name, last_name, email, department_id,
             enrollment_date, status)
        VALUES
            (1002, 'Leo', 'Kim', 'leo.kim@example.edu', 10,
             DATE '2026-08-17', 'ACTIVE')
        INTO dbc_students
            (student_id, first_name, last_name, email, department_id,
             enrollment_date, status)
        VALUES
            (1003, 'Maya', 'Singh', 'maya.singh@example.edu', 20,
             DATE '2026-08-18', 'ACTIVE')
        INTO dbc_students
            (student_id, first_name, last_name, email, department_id,
             enrollment_date, status)
        VALUES
            (1004, 'Daniel', 'Cruz', 'daniel.cruz@example.edu', 30,
             DATE '2026-08-18', 'ACTIVE')
    SELECT 1 FROM dual;
    </copy>
    ```

    `INSERT ALL` adds four students. The column list shows where each value belongs. `DATE` creates an exact date and avoids session-format differences. Each department ID matches a row from Step 1.

3. Insert the courses and enrollments.

    ```sql
    <copy>
    INSERT ALL
        INTO dbc_courses VALUES (2001, 'DB101', 'Database Fundamentals', 3, 10)
        INTO dbc_courses VALUES (2002, 'DV110', 'Data Visualization', 3, 30)
        INTO dbc_courses VALUES (2003, 'BA120', 'Business Analytics', 3, 20)
        INTO dbc_courses VALUES (2004, 'SQL201', 'SQL for Applications', 4, 10)
    SELECT 1 FROM dual;

    INSERT ALL
        INTO dbc_enrollments VALUES (1001, 2001, DATE '2026-09-01', NULL)
        INTO dbc_enrollments VALUES (1001, 2004, DATE '2026-09-01', NULL)
        INTO dbc_enrollments VALUES (1002, 2001, DATE '2026-09-02', NULL)
        INTO dbc_enrollments VALUES (1003, 2003, DATE '2026-09-02', NULL)
        INTO dbc_enrollments VALUES (1004, 2002, DATE '2026-09-03', NULL)
    SELECT 1 FROM dual;

    COMMIT;
    </copy>
    ```

    The first statement adds four courses. The second adds five enrollments that connect students to those courses. A `NULL` grade means that the course has no grade yet. `COMMIT` saves the rows.

4. The commit ends the transaction. The sample rows will remain after you close the worksheet.

5. Demo-ready mode uses `MERGE`. It updates a matching row or inserts a missing row, so the setup can run more than once.

## Task 2: Filter and sort rows

1. Find active students in the Computer Science department.

    ```sql
    <copy>
    SELECT student_id, first_name, last_name, email
    FROM   dbc_students
    WHERE  department_id = 10
      AND  status = 'ACTIVE'
    ORDER  BY last_name, first_name;
    </copy>
    ```

    `WHERE` keeps active students from department 10. `ORDER BY` sorts them by last name and then first name.

2. Change the filter to another department and run the query again.

## Task 3: Join related tables

1. Run a four-table join to show the courses for each student.

    ```sql
    <copy>
    SELECT s.first_name || ' ' || s.last_name AS student_name,
           d.department_name,
           c.course_code,
           c.course_title,
           e.enrolled_on
    FROM   dbc_students s
    JOIN   dbc_departments d ON d.department_id = s.department_id
    JOIN   dbc_enrollments e ON e.student_id = s.student_id
    JOIN   dbc_courses c ON c.course_id = e.course_id
    ORDER  BY student_name, c.course_code;
    </copy>
    ```

    The joins follow the primary and foreign keys from one table to the next. The `||` operator combines first and last names for display. The result shows each enrollment with its student, department, and course.

2. Count students in each course.

    ```sql
    <copy>
    SELECT c.course_code,
           c.course_title,
           COUNT(e.student_id) AS student_count
    FROM   dbc_courses c
    LEFT JOIN dbc_enrollments e ON e.course_id = c.course_id
    GROUP  BY c.course_code, c.course_title
    ORDER  BY c.course_code;
    </copy>
    ```

    `GROUP BY` collects the rows for each course, and `COUNT` totals the students. The `LEFT JOIN` also keeps courses with no enrollments. Those courses get a count of zero.

3. The foreign keys give you the join conditions. Each department, student, and course still lives in only one table.

## Task 4: Test data changes inside a transaction

1. Oracle locks changed rows until `COMMIT` or `ROLLBACK`. Other sessions can still read the last committed version. Another session that tries to change the same row may need to wait.

2. Create a savepoint, then insert, update, and delete specific rows.

    ```sql
    <copy>
    SAVEPOINT before_practice;

    INSERT INTO dbc_students
        (student_id, first_name, last_name, email, department_id,
         enrollment_date, status)
    VALUES
        (1999, 'Sam', 'Rivera', 'sam.rivera@example.edu', 10,
         SYSDATE, 'ACTIVE');

    UPDATE dbc_students
    SET    status = 'PAUSED'
    WHERE  student_id = 1002;

    DELETE FROM dbc_enrollments
    WHERE  student_id = 1004
      AND  course_id = 2002;
    </copy>
    ```

    `SAVEPOINT` marks where the practice begins. The next statements add one student, pause another, and remove one enrollment. The `WHERE` clauses keep the changes limited to the intended rows.

3. Check the pending changes before you commit them.

    ```sql
    <copy>
    SELECT student_id, first_name, last_name, status
    FROM   dbc_students
    WHERE  student_id IN (1002, 1999)
    ORDER  BY student_id;

    SELECT student_id, course_id
    FROM   dbc_enrollments
    WHERE  student_id = 1004;
    </copy>
    ```

    The first query shows the new student and the changed status. The second checks the enrollment you removed. Your session can see these changes even though you have not committed them.

4. Undo every change made after the savepoint.

    ```sql
    <copy>
    ROLLBACK TO before_practice;
    COMMIT;
    </copy>
    ```

    `ROLLBACK TO` removes everything done after the savepoint. The final `COMMIT` ends the transaction and keeps the original sample data. The practice changes do not remain.

5. Run the two verification queries again. Student `1999` should be absent, student `1002` should be active, and student `1004` should have an enrollment.

6. Use the same pattern for future experiments: target rows with `WHERE`, check the result, and then choose `COMMIT` or `ROLLBACK`.

## Acknowledgements

* **Author** - Oracle University Program
* **Last Updated By/Date** - Oracle University Program, October 2026
