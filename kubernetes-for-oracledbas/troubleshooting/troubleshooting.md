# Troubleshooting

## Introduction

Every effort is made to ensure this Workshop functions in its entirety without any errors.  Unfortunately, variables and the continual evolution of technology will inevitably cause some tasks to fail.  Below are known issues and their resolutions.

## Task 1: Out of Capacity

When [deploying the Stack](?lab=deploy-stack#Task4:ApplytheStack "Deploy Stack") with the defaults, it may fail due to compute capacity issues.  This can be resolved by changing the shape of the compute instances.

1. Use the breadcrumb to navigate back to the "Stack Details"

    ![Stack Details Breadcrumb](images/stack_details.png "Stack Details Breadcrumb")

2. Select the "Edit" Dropdown and Click "Edit Stack"

    ![Edit Stack](images/edit_stack.png "Edit Stack")

3. On the first screen, "Stack Information", click "Next".  On the "Configure Variables" screen, change the `Node Worker Pool Shape` and click "Next".

    ![Change Shape](images/change_shape.png "Change Shape")

4. Apply the Stack

    Ensure the "Run apply" checkbox is ticked and click "Save changes"

    ![Apply Stack](images/apply_stack.png "Apply Stack")

## Acknowledgements

* **Authors** - [](var:authors)
* **Contributors** - [](var:contributors)
* **Last Updated By/Date** - John Lathouwers, July 2023
