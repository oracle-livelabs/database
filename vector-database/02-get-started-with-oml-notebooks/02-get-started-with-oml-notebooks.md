# Lab 2: Get Started with Oracle Machine Learning Notebooks

## Introduction

In this lab, you switch from the Vector Database Console to Oracle Machine Learning (OML) Notebooks. You open OML, create a project and notebook, then run a Python paragraph. Later labs use this notebook environment to run the Vector Database Python SDK examples.

Estimated Time: 10 minutes

### Objectives

- Open Oracle Machine Learning from your Autonomous AI Vector Database.
- Create an OML project and notebook.
- Add and run a `%python` paragraph.

### Prerequisites

- Complete Lab 1: Working with the Vector Database Console.
- Have the database sign-in credentials provided for this workshop.

## Task 1: Open Oracle Machine Learning

1. In the Oracle Cloud Console, open your Autonomous AI Vector Database.

2. Select **Database Actions**. If prompted, sign in with the database username and password provided for the workshop.

3. On the Database Actions launchpad, select **Oracle Machine Learning**.

    The OML landing page opens. This is where you organize projects, create notebooks, and run SQL, Python, and other notebook paragraphs.

## Task 2: Create a Project and Notebook

1. In OML, open **Projects** and select **Create**.

2. Enter `Vector Database Workshop` for the project name, then select **Create**.

3. Open the new project and select **Create Notebook**.

4. Enter `vector-database-workshop` for the notebook name, then select **Create**.

    The notebook opens with a first paragraph, ready for you to choose the language and enter code.

## Task 3: Add and Run a Python Paragraph

1. In the first notebook paragraph, enter the following code.

    <copy>
    ```python
    %python
    print("OML notebook is ready for the Vector Database workshop.")
    ```
    </copy>

2. Run the paragraph by selecting the **Run** icon or pressing **Shift+Enter**.

3. Confirm that the output appears below the paragraph.

4. To add another paragraph, select **Add Paragraph**. Use `%python` at the top of a paragraph whenever you want to run Python code in the notebook.

    Keep this notebook and project open. You will use them to run the Python SDK examples in the next lab.

## Learn More

- [Oracle Machine Learning Notebooks documentation](https://docs.oracle.com/en/database/oracle/machine-learning/oml-notebooks/)

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, August 27, 2026
