# Lab 3: Query and Change Data Safely

## Introduction

The reservation has already loaded three departments, 60 students, 10 courses, and 285 enrollments. Use those rows to practice queries. Then try an insert, update, and delete inside a transaction that you roll back.

### Objectives

You will:

- Check the loaded rows.
- Filter, sort, join, and aggregate data with `SELECT`.
- Practice targeted `INSERT`, `UPDATE`, and `DELETE` statements.
- Control a transaction with `SAVEPOINT`, `ROLLBACK`, and `COMMIT`.

Estimated Time: 25 minutes

## Task 1: Check the loaded data

1. Count the rows in each core table.

    ```sql
    <copy>
    SELECT 'DEPARTMENTS' AS table_name, COUNT(*) AS row_count FROM departments
    UNION ALL
    SELECT 'STUDENTS', COUNT(*) FROM students
    UNION ALL
    SELECT 'COURSES', COUNT(*) FROM courses
    UNION ALL
    SELECT 'ENROLLMENTS', COUNT(*) FROM enrollments;
    </copy>
    ```

    Expect 3 departments, 60 students, 10 courses, and 285 enrollments. The setup loaded these rows before you opened Database Actions. If a count is missing, the reservation did not finish loading the dataset.

2. Open `STUDENTS` in the Tables list and view a few rows. The student IDs and department IDs connect these rows to the other tables.

## Task 2: Filter and sort rows

1. Find active students in the Computer Science department.

    ```sql
    <copy>
    SELECT student_id, first_name, last_name, email
    FROM   students
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
    FROM   students s
    JOIN   departments d ON d.department_id = s.department_id
    JOIN   enrollments e ON e.student_id = s.student_id
    JOIN   courses c ON c.course_id = e.course_id
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
    FROM   courses c
    LEFT JOIN enrollments e ON e.course_id = c.course_id
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

    INSERT INTO students
        (student_id, first_name, last_name, email, department_id,
         enrollment_date, status)
    VALUES
        (1999, 'Sam', 'Rivera', 'sam.rivera@example.edu', 10,
         SYSDATE, 'ACTIVE');

    UPDATE students
    SET    status = 'PAUSED'
    WHERE  student_id = 1002;

    DELETE FROM enrollments
    WHERE  student_id = 1004
      AND  course_id = 2002;
    </copy>
    ```

    `SAVEPOINT` marks where the practice begins. The next statements add one student, pause another, and remove one enrollment. The `WHERE` clauses keep the changes limited to the intended rows.

3. Check the pending changes before you commit them.

    ```sql
    <copy>
    SELECT student_id, first_name, last_name, status
    FROM   students
    WHERE  student_id IN (1002, 1999)
    ORDER  BY student_id;

    SELECT student_id, course_id
    FROM   enrollments
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

* **Author** - Ilan Gómez Guerrero
* **Last Updated By/Date** - Ilan Gómez Guerrero, November 2026
