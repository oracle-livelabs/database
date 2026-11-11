# Lab 5: Add Schema Objects and Indexes

## Introduction

The tables are done. Finish the schema with a sequence, a view, a synonym, and three B-tree indexes.

Here is what each object is for:

| Object | Purpose |
| --- | --- |
| Sequence | Generates numeric values independently of a table |
| View | Gives a saved query a reusable table-like interface |
| Synonym | Provides another name for an existing object |
| Index | Gives Oracle an alternate path for locating rows |

### Objectives

You will:

- Generate numeric values with a sequence.
- Present joined data through a view.
- Create a private synonym for a schema object.
- Add B-tree indexes that support foreign key joins.
- Inspect schema objects and indexes.

Estimated Time: 20 minutes

## Task 1: Create and use a sequence

A sequence gives you new numbers without checking the highest value in a table. It is a separate object, so requesting a number does not insert a row.

1. Check whether the sequence already exists.

    ```sql
    <copy>
    SELECT sequence_name, last_number
    FROM   user_sequences
    WHERE  sequence_name = 'DBC_STUDENT_SEQ';
    </copy>
    ```

    `USER_SEQUENCES` lists the sequences in your schema. If this query returns a row, `DBC_STUDENT_SEQ` already exists. Because Oracle caches sequence values, `LAST_NUMBER` may not be the next value you receive.

2. If the query returns no rows, create the sequence.

    ```sql
    <copy>
    CREATE SEQUENCE dbc_student_seq
        START WITH 1100
        INCREMENT BY 1
        NOCYCLE
        CACHE 20;
    </copy>
    ```

    The sequence starts at 1100 and adds one for each request. `NOCYCLE` stops it from returning to the beginning. `CACHE 20` keeps a small group of values ready in memory.

3. Read the next value without inserting a row.

    ```sql
    <copy>
    SELECT dbc_student_seq.NEXTVAL AS next_student_id
    FROM   dual;
    </copy>
    ```

    `NEXTVAL` returns a new number and moves the sequence forward. `DUAL` gives the query one row to work with. The alias makes the output easier to read.

4. Oracle does not roll sequence values back. An unused cached value can also disappear when an instance stops. Gaps are normal, and they do not mean that table rows are missing.

## Task 2: Create a view and synonym

A regular view gives a useful query a name. It reads the current rows from the base tables whenever you use it. A synonym is only another name for an object; it does not give extra privileges.

1. Create a view that stores the four-table query definition.

    ```sql
    <copy>
    CREATE OR REPLACE VIEW dbc_student_schedule_v AS
    SELECT s.student_id,
           s.first_name || ' ' || s.last_name AS student_name,
           d.department_name,
           c.course_code,
           c.course_title,
           e.enrolled_on,
           e.grade
    FROM   dbc_students s
    JOIN   dbc_departments d ON d.department_id = s.department_id
    JOIN   dbc_enrollments e ON e.student_id = s.student_id
    JOIN   dbc_courses c ON c.course_id = e.course_id;
    </copy>
    ```

    The view saves the four-table query, not another copy of the data. `CREATE OR REPLACE` also lets you update the definition later without dropping the view first.

2. Create a shorter private synonym for the view.

    ```sql
    <copy>
    CREATE OR REPLACE SYNONYM dbc_schedule
    FOR dbc_student_schedule_v;
    </copy>
    ```

    `DBC_SCHEDULE` is now a shorter name for the view. The synonym does not store data and does not copy the view.

3. Query through the synonym.

    ```sql
    <copy>
    SELECT student_name, department_name, course_code, course_title
    FROM   dbc_schedule
    ORDER  BY student_name, course_code;
    </copy>
    ```

    Oracle resolves `DBC_SCHEDULE` to the original view and runs its joins. You get the same rows as you would from `DBC_STUDENT_SCHEDULE_V`.

4. A regular view stores the query definition. A materialized view stores the query results on disk and must refresh when the base data changes. We will not create one in this workshop.

5. `DBC_SCHEDULE` is private to your schema. A public synonym is database-wide and needs administrative privileges.

## Task 3: Add indexes for common joins

A B-tree index keeps ordered key values and their row locations. It can help Oracle find a small set of rows without scanning the whole table. An index also uses storage and adds work when data changes, so do not index every column.

1. Check which indexes already exist.

    ```sql
    <copy>
    SELECT table_name, index_name, uniqueness
    FROM   user_indexes
    WHERE  table_name LIKE 'DBC\_%' ESCAPE '\'
    ORDER  BY table_name, index_name;
    </copy>
    ```

    `USER_INDEXES` lists the indexes in your schema. The filter keeps workshop tables, and the result shows whether each index allows duplicate values.

2. If the following indexes are absent, create them.

    ```sql
    <copy>
    CREATE INDEX dbc_students_dept_ix
        ON dbc_students (department_id);

    CREATE INDEX dbc_courses_dept_ix
        ON dbc_courses (department_id);

    CREATE INDEX dbc_enroll_course_ix
        ON dbc_enrollments (course_id);
    </copy>
    ```

    Oracle creates three standard B-tree indexes on foreign key columns. It may use them for joins and targeted searches when they cost less than a full table scan.

3. The primary key on `DBC_ENROLLMENTS` already starts with `STUDENT_ID`. The new index starts with `COURSE_ID`, which supports searches from the other side of the relationship.

    Oracle normally creates or reuses an index for a primary key or unique rule. It does not automatically index foreign key columns. That is why you checked the existing indexes first.

4. Use the workload to choose an index type.

    | Index type | Typical use |
    | --- | --- |
    | B-tree | Lookups, ranges, joins, and frequently changed data |
    | Bitmap | Low-cardinality, read-heavy analytics; avoid frequent DML |
    | Function-based | Expressions such as `UPPER(last_name)` |
    | Specialized | Text, spatial, JSON, graph, or vector searches |

5. Do not worry if Oracle scans the full table in this small example. The optimizer uses an index only when it estimates that the index will cost less.

6. Autonomous Database can evaluate B-tree indexes automatically. You created them yourself here so you can see how index selection works.

## Task 4: Inspect the finished schema

Oracle records schema details in data dictionary views. Names that begin with `USER_` describe objects owned by your user. Use these final queries to check what you built.

1. Count the workshop objects by type.

    ```sql
    <copy>
    SELECT object_type, COUNT(*) AS object_count
    FROM   user_objects
    WHERE  object_name LIKE 'DBC\_%' ESCAPE '\'
    GROUP  BY object_type
    ORDER  BY object_type;
    </copy>
    ```

    `USER_OBJECTS` lists everything owned by your user. `GROUP BY` collects matching object types, and `COUNT` totals them. You should see tables, indexes, a view, a sequence, and a synonym.

2. List the indexed columns in order.

    ```sql
    <copy>
    SELECT i.table_name,
           i.index_name,
           c.column_position,
           c.column_name
    FROM   user_indexes i
    JOIN   user_ind_columns c ON c.index_name = i.index_name
    WHERE  i.table_name LIKE 'DBC\_%' ESCAPE '\'
    ORDER  BY i.table_name, i.index_name, c.column_position;
    </copy>
    ```

    The join connects each index to its columns. `COLUMN_POSITION` shows the column order. The first column matters because it usually controls which searches can use the index well.

3. Run the schedule query one last time.

    ```sql
    <copy>
    SELECT student_name, department_name, course_code, course_title
    FROM   dbc_student_schedule_v
    ORDER  BY student_name, course_code;
    </copy>
    ```

    The view should still return the same schedule. Indexes do not change the data or the answer. They only give the optimizer another way to find the rows.

4. Your schema now has data, constraints, a sequence, a view, a synonym, and indexes. Keep the objects for review unless your instructor asks you to reset the workshop schema.

## Acknowledgements

* **Author** - Oracle University Program
* **Last Updated By/Date** - Oracle University Program, October 2026
