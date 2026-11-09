# Lab 6: Check Your Understanding

## Introduction

You built a small campus database. Finish with six questions about the choices you made along the way.

```quiz-config
passing: 75
badge: images/badge.png
```

### Objectives

You will:

- Review the main ideas from the workshop.
- Check when to use constraints, transactions, views, and indexes.
- Identify which database tasks Oracle Autonomous Database manages for you.

Estimated Time: 10 minutes

## Task 1: Complete the knowledge check

1. Choose one answer for each question. A score of 75 percent or higher completes the lab.

    ```quiz score
    Q: Why did the workshop use Oracle Autonomous Database?
    * Oracle manages routine work such as patching, backups, and tuning while you work with schemas, SQL, and data.
    - Oracle creates every application table and relationship without a schema design.
    - Oracle removes the need to use SQL when working with relational data.
    > Autonomous Database manages much of the database service. You still decide how to organize the schema and work with its data.

    Q: Why did the workshop place departments, students, courses, and enrollments in separate tables?
    - To make every query use four tables.
    * To store each fact once and reduce repeated or conflicting data.
    - To avoid defining primary keys and foreign keys.
    > Separating the entities keeps department, student, and course facts in one place. The enrollment table connects students and courses without repeating their details.

    Q: Which rule prevents an enrollment from referring to a student who does not exist?
    - A check constraint on the grade.
    - A unique constraint on the student email.
    * A foreign key from the enrollment table to the student table.
    > The foreign key requires the referenced student row to exist before Oracle accepts the enrollment.

    Q: You test an UPDATE and a DELETE after creating a savepoint. How can you undo only those practice changes?
    * Run ROLLBACK TO the savepoint.
    - Run COMMIT before checking the rows.
    - Drop and recreate the affected tables.
    > A savepoint marks a place inside the transaction. ROLLBACK TO returns to that point without removing work done before it.

    Q: You want to reuse the four-table schedule query without storing another copy of its results. Which object fits that need?
    - A sequence.
    * A regular view.
    - A B-tree index.
    > A regular view saves the query definition and reads current data from the base tables whenever you use it.

    Q: Why did you add an index on DBC_ENROLLMENTS(COURSE_ID)?
    - To change the course IDs stored in the table.
    - To guarantee that every course has at least one student.
    * To give Oracle another path for joins and searches that begin with COURSE_ID.
    > The enrollment primary key begins with STUDENT_ID. The additional B-tree index supports access from the course side when the optimizer finds it useful.
    ```

## Task 2: Review your result

1. Read the explanation after each answer, including the questions you answered correctly.

2. If you missed a question, return to the related lab and review that section before trying again.

3. Reach 75 percent or higher to finish the lab.

## Acknowledgements

* **Author** - Oracle University Program
* **Last Updated By/Date** - Oracle University Program, November 2026
