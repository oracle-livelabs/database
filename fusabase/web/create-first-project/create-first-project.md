# Create Your First Project

## Introduction

This section starts where both workshop environments align. You’ll open Fusabase from the workshop page, create your first project, and set the starter security rules used by the rest of the workshop.

### Objectives

In this lab, you will:

- Open Fusabase from the workshop.
- Sign in with the workshop credentials.
- Create your first project.
- Set the starter database and storage security rules.

Estimated Time: 10 minutes

## Task 1: Create your first project

1. From the workshop page, click **Go** to open Fusabase.

    ![Fusabase console home page at localhost 8080](./images/task-4-console-home.png =85%x*)

2. Sign in to the Fusabase console with the workshop credentials.

    Use these workshop credentials:

    - Username: **`testuser`**
    - Password: **`testpwd`**

    ![Fusabase console navigation after the page loads](../start-environment/images/task-4-console-navigation.png =40%x*)

3. This is the Fusabase landing page. Click **Create project** to create your first project.

    ![Fusabase console showing the available services](./images/task-4-console-services.png =85%x*)

4. In the **Create Project** dialog:

    - enter a project name such as `recipe-workshop`
    - select **Set up using quickstart**
    - leave **Set up authentication for me** and **Set up storage for me** selected
    - click **Create Project**

    ![Fusabase create project dialog with quickstart selected](./images/task-4-console-ready.png =40%x*)

   > This step creates the Fusabase project. A project is like a container for the different applications that you want to create. To learn more about projects, read about them in the docs. [Update link to docs.]

5. This is the Fusabase project home page after the project is created.

    ![Fusabase project home page after project creation](./images/task-5-project-home.png =85%x*)

## Task 2: Set starter security rules

1. Now we're going to set some basic security rules. We will revisit this in Lab 7 and learn about the security rules in more detail.

2. Open the project that you created in Task 1, then click **Database** in the left navigation.

    This gets you to the Database workspace for your project.

    ![Fusabase Database section with the Security rules tab visible](./images/Area.gif =85%x*)

3. Click the **Security rules** tab and replace the current rule with this rule, then click **Publish changes**.

    ```text
    <copy>match /{document=**} { allow read, write: if true;}</copy>
    ```

    ![Fusabase Security rules tab with the starter rule ready to publish](./images/task-6-security-rules.png =85%x*)

4. Confirm that the rule is published before you continue.

    This permissive rule applies broadly to database reads and writes in this project. It is only to get you started in the workshop. You will return to security rules later and tighten them so the app does not leave read and write access open.

5. Now do the same thing for Storage. Click **Storage** in the left navigation, click the **Security rules** tab, replace the current rule with this rule, then click **Publish changes**.

    ```text
    <copy>match /{document=**} { allow read, write: if true;}</copy>
    ```

    ![Fusabase Security rules tab with the starter rule ready to publish](./images/task-6-security-rules-storage.png =85%x*)

6. Leave the Fusabase console open for the next lab.

## Appendix

1. Use these workshop credentials for this lab:

    - Username: **`testuser`**
    - Password: **`testpwd`**

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Contributors** -
* **Last Updated By/Date** - Killian Lynch, April 2026
