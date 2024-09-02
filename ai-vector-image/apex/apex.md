# Build an APEX app for AI Vector Search

## Introduction

This lab will walk you through the steps to create an APEX application that will leverage all of the data you have loaded plus AI Vector Search

Estimated Lab Time: 20 minutes

### Objectives

In this lab, you will:
* Create a workspace for your application
* Create a page to search your images using AI Vector Search
* Create a page to display the details of an image
* Link the two pages together

### Prerequisites

This lab assumes you have:
* All previous labs successfully completed


## Task 1: Create a Workspace and APEX User

This task you will log into APEX with the ADMIN user and create a workspace for your specific application. Take note of the workspace, user and password for this application as it will be different than your database user.

1. Open the "View Login Info" section of your workshop.

	![Image alt text](images/lab4_1ba.png)

2. You will use the APEX URL to open APEX

    ![Image alt text](images/lab4_1c.png)

3. Login using:
    - APEX Workspace Name
    - APEX Workspace User
    - APEX Workspace Password

     ![Image alt text](images/lab4_3a.png)

4. It will ask you to change the password. You can change the password or you can use the existing password

    ![Image alt text](images/lab4_4pass.png)

5. Click on "Create Workspace"

    ![Image alt text](images/lab4_4.png)

6. For Workspace Name type in "Vector" and click Next

    ![Image alt text](images/lab4_5.png)    

7. For "Re-Use existing schema?" set this to Yes

    ![Image alt text](images/lab4_6.png)

8. For Schema Name type in "ADMIN" and click Next.
    **Note:** By doing this you have linked your application with your database schema where your tables reside.

    ![Image alt text](images/lab4_7.png)

9.  For the Identify Administrator section fill in:
    - Administrator Username: vectoruser (This will be the user we will log into APEX with)
    - Administrator Password: Welcome_1 (or any password you want just make sure to remember it as we will use this to log into APEX with)
    - Email: test@test.com (Any email address will work.)
    - Click Next

     ![Image alt text](images/lab4_9.png)
  
10. Click Create Workspace

    ![Image alt text](images/lab4_10.png) 

12. Click Done

    ![Image alt text](images/lab4_11.png) 

13. Click on admin in the upper right corner and click sign out

    ![Image alt text](images/lab4_13.png) 

14. Click on Return to Sign In Page

    ![Image alt text](images/lab4_14.png) 

15. On the page fill in the following values:
    - Workspace: Vector
    - Username: vectoruser
    - Password: Welcome_1 (or the password you created)

     ![Image alt text](images/lab4_15a.png) 
  
16. Again you will be asked to create a new password. You can use the same password or change it.

    ![Image alt text](images/lab4_16.png) 

17. You should now be on the main landing page of APEX

    ![Image alt text](images/lab4_17.png) 

## Task 2: Create Application
In this task you will create the application so you can start building pages.

1. Click on App Builder Icon
    ![Image alt text](images/lab4_task2_1.png) 

2. Click on Create a New App
    ![Image alt text](images/lab4_task2_2.png)

3. Name your application. I'm going to use "Vector Image". Next click Create Application

    ![Image alt text](images/lab4_task2_3.png)

## Task 3: Create Image Gallery Page
In this task you will create the Image Gallery page. This page will display the images that are brought back from your AI Vector Search based on input from the user.

1. Click on Create Page

    ![Image alt text](images/lab4_task3_1.png)

2. Next choose Cards
    ![Image alt text](images/lab4_20a.png)

3. On this page:
    - Under **Page Definition**: Name: Image Gallery
    - Under **Data Source**: Table/View Name: VECTOR_IMAGE
    - Click Next

     ![Image alt text](images/lab4_21a.png)

4. On this page:
    - For **Cards Layout** select: **Float**
    - Under **Cards Attributes** select: **Title Column** in the URL field from the table
    - Click on Create Page

     ![Image alt text](images/lab4_22a.png)

5. On the left panel under `Page*: Image Gallery`: under the section Body, right click Body and choose "**Create Page Item**". We will use this as a text entry box for searching.

    ![Image alt text](images/lab4_23a.png)
    
6.  If you click on the newly created Item on the left side of the page, look to the right side of the screen under **Page Item**. You will make the following changes in the Page Item Panel:
    - Change the name of the item you just created to P4\_SEARCH\_ITEM.
    - Change Submit when Enter pressed to On

     ![Image alt text](images/lab4_25a.png)
 
7.  In the panel on the left, Drag the P4\_SEARCH\_ITEM up above the Image Gallery page item. This will make it so your search box will be at the top of the page.

    ![Image alt text](images/lab4_26.png)


8. Click on the **Image Gallery** page item. Now make the following changes in the **Region** panel on the right:
    
    - Under **Source**, change the **Type** to **SQL Query**.

     ![Image alt text](images/lab4_28a.png)

    - For the **SQL Query**, paste the following:

     ```
     <copy>
     select URL,
        IMG,
        UFORM_DESC,
        UFORM_VECTOR,
        NLP_DESC,
        NLP_VECTOR
     from VECTOR_IMAGE
     ORDER BY VECTOR_DISTANCE( uform_vector, vector_embedding(minilm12v2 using :P4_SEARCH_ITEM as data), EUCLIDEAN ) 
     FETCH EXACT FIRST 2 ROWS ONLY
     </copy>
     ```

     ![Image alt text](images/lab4_29.png)

    - In the **Page Items to Submit** section, click on the menu button on the right and select **P4\_SEARCH\_ITEM**.

     ![Image alt text](images/lab4_30.png)
     ![Image alt text](images/lab4_31.png)

9. Click on the Attributes Tab

    ![Image alt text](images/lab4_32.png)

10. Make the following changes:
      - Scroll down to **Media**
      - Change the **Source**: Blob Column
      - **Blob Column**: IMG

     ![Image alt text](images/lab4_33.png)
     ![Image alt text](images/lab4_34.png)
      - Scroll up to **Card**
      - Primary Key Column 1: URL
    - Click on Save at the top of the page

     ![Image alt text](images/lab4_35.png)
     ![Image alt text](images/lab4_36.png)

11. Right click on the ORDER\_BY in the left panel and select delete. It will have a P2 or another number based on the number your page.
    ![Image alt text](images/lab4_37.png)

12. Click on Save

    ![Image alt text](images/lab4_38.png)


13. If you want to see how your page looks click on the run button

    ![Image alt text](images/lab4_39.png)

14. You will need to login to your application
    - Username: vectoruser
    - Password: Welcome_1 (Or whatever password you set it to)

     ![Image alt text](images/lab4_40.png) 

15. Try typing in Fruit or Climbing in the search bar

    ![Image alt text](images/lab4_41.png)
    ![Image alt text](images/lab4_42.png) 

16. You can close your application page but leave your Application Designer/Builder page open

## Task 4: Create Image Detail Page
In this task you will create the Image Detail Page that will display information like the descriptions and vectors for the image selected. You will also create a link back to the Image Gallery Page.

1. If you are not at the application builder home page click on the Application Breadcrumb at the top corner of the page
    ![Image alt text](images/lab4_task4_1.png) 

2.  You should be on a page that looks like the image below
    ![Image alt text](images/lab4_44_.png) 

3.  Click on Create Page
    ![Image alt text](images/lab4_44.png)

4.  Choose Interactive Report
    ![Image alt text](images/lab4_45a.png)

5.  On this page:
    - Name: Image Detail
    - Table/View Name: VECTOR_IMAGE
    - Click Create Page

     ![Image alt text](images/lab4_46a.png)


6. On the left panel where you see the section called Body, right click on the word Body and choose "Create Page Item". This will be a variable so that you can pass which image you want to see the detail from the Image Gallery page.

    ![Image alt text](images/lab4_47.png)

7. If you click on the newly created Item then on the right side of the page you will see the Page Item panel for that item. Make the following changes in the Page Item Panel:
    - In **Identification** change **Name** to: P2_URL
    ![Image alt text](images/lab4_49a.png)
    - Scroll down to the Default section and change:
      - Type: SQL Query (return single value)
      ![Image alt text](images/lab4_50.png)
      - SQL Query: "select min(url) from vector_image" (without the double quotes)
      ![Image alt text](images/lab4_51.png)

8.  In the panel on the left, Drag the P2_URL up above the Image Detail page item

    ![Image alt text](images/lab4_52a.png)

9.  Click on the Image Detail in the left panel to pull up its details and change the where clause section paste "URL = :P2_URL" (without the double quotes)

    ![Image alt text](images/lab4_53a.png)

11. In the Page Items to Submit section click on the menu button on the right and click on P2_URL

    ![Image alt text](images/lab4_54.png)

12. Back on the left side panel right click on image detail and click on duplicate
    ![Image alt text](images/lab4_55a.png)
    ![Image alt text](images/lab4_56a.png)

13. Expand the column list of the top image detail page item and do the following:
    - Right click on url and choose comment out
    - Right click on img and choose comment out
    - Right click on uform_vector and choose comment out
    - Right click on nlp_vector and choose comment out

     ![Image alt text](images/lab4_57a.png)
     ![Image alt text](images/lab4_58a.png)
     ![Image alt text](images/lab4_59a.png)

14. Expand the columns list of the bottom image detail page item and do the following:
    - Right click on url and choose comment out
    - Right click on img and choose comment out
    - Right click on uform_desc and choose comment out
    - Right click on nlp_desc and choose comment out

     ![Image alt text](images/lab4_60a.png)
     ![Image alt text](images/lab4_61a.png)
     ![Image alt text](images/lab4_62a.png)

15. Right click on Body in the left panel and click on Create Button

    ![Image alt text](images/lab4_63a.png)

16. Click on the button on the left and in the Button panel on the right change the following:
    - Button Name: Back\_to\_Images
     ![Image alt text](images/lab4_65a.png)
    - The label should automatically change to Back To Images
    - Scroll down to Behavior and make the following changes: 
    - Action: Redirect to to Page in this Application
     ![Image alt text](images/lab4_66a.png)
    - Target: Click on Link to bring up the dialog
     ![Image alt text](images/lab4_67a.png)
      - Click on the menu on the page box
      ![Image alt text](images/lab4_68a.png)
      - Click on the number next to the Image Gallery. In my case I would click on 2
      ![Image alt text](images/lab4_69a.png)
      - Click on Ok
      ![Image alt text](images/lab4_70a.png)


17. Click on Save on the Page

    ![Image alt text](images/lab4_71.png)

18. Click on the application breadcrumb at the top left corner of the page
    ![Image alt text](images/lab4_72.png)

## Task 5: Linking Image Gallery to the Image Details
In this task you will link the Image Gallery page to the Image Detail Pages so when you click on an image you will get the details for it.

1.  If you are not at the application builder home page click on the Application Breadcrumb at the top of the page

    ![Image alt text](images/lab4_task5_1.png)

2.  You should be on a page that looks like the image below
    ![Image alt text](images/lab4_task5_2.png)

3.  Click on your Image Gallery page
    ![Image alt text](images/lab4_74.png)

4.  In the left panel Under Image Gallery right click on Actions and Choose create action
    ![Image alt text](images/lab4_76a.png)

5.  In the Action Panel on the right make the following changes
    - Identification -> Type: Media
     ![Image alt text](images/lab4_77.png)
    - Under link Change
      - Type: Redirect to Page in this Application
     ![Image alt text](images/lab4_78a.png)

    - Click on Target 
        
     ![Image alt text](images/lab4_79a.png)

    - Click on the menu on the Page box which should pop up the list of pages in your application

     ![Image alt text](images/lab4_80a.png)
    
    - Click on the number of the page for the "Image Detail" page. In my case I would click on the 3

     ![Image alt text](images/lab4_81.png)

    - In the Set Items section:
        - Click on the menu button next to the box for Name. 
        ![Image alt text](images/lab4_80b.png)
        - It should show P2_URL. Click on that to select it
        ![Image alt text](images/lab4_82a.png)
        - For the Value box, again click on the menu button
        ![Image alt text](images/lab4_80b.png)
        - Select URL
        ![Image alt text](images/lab4_83a.png)
        - Click Ok to save the dialog
        ![Image alt text](images/lab4_84a.png)

     - Click on the menu on the Link Attributes box and select URL

     ![Image alt text](images/lab4_86a.png)

6.  Click Save on the page
    ![Image alt text](images/lab4_87.png)

## Task 6: Running the Application
1. To run your application do one of the following:
    - If you are still on the Image Gallery page you can click on the run button to start your application. 

     ![Image alt text](images/lab4_task6_1.png)

    - If you are on the Application Builder home page then click on the Image Gallery page and then click the run button.

     ![Image alt text](images/lab4_89.png)
     ![Image alt text](images/lab4_90.png)
    
2.  If you need to login use:
    - Username: vectoruser
    - Password: Welcome_1 (or whatever password you set for vectorimage)

     ![Image alt text](images/lab4_91.png)

3. If you want you can click on the Menu and select Image Gallery to get to the Image Gallery page as well.

    ![Image alt text](images/lab4_92.png)

4. In your search bar type in Fruit or Surfing or whatever you want to search on
    ![Image alt text](images/lab4_93.png)

5. Click on an image to go to your detail page
    ![Image alt text](images/lab4_94.png)

6. On the details page you can see both descriptions and what the vectors for the descriptions are. At the bottom is the button to go back to the Image Gallery page.

    ![Image alt text](images/lab4_95.png)
    ![Image alt text](images/lab4_96.png)

Congradulations, you have built a AI Vector Search enabled application using images!

## Learn More

* [Oracle AI Vector Search Users Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/whats-new-oracle-ai-vector-search.html)
* [AI Vector Search Blog](https://blogs.oracle.com/database/post/oracle-announces-general-availability-of-ai-vector-search-in-oracle-database-23ai)
* [Oracle APEX](https://apex.oracle.com)

## Acknowledgements
* **Author** - David Start, Product Management
* **Contributors** -  David Start, Product Management,  Francis Regalado, Product Management
* **Last Updated By/Date** - David Start, Sept 2024
