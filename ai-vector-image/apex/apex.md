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

### Prerequisites (Optional)

This lab assumes you have:
* All previous labs successfully completed


## Task 1: Create a Workspace and APEX User

This task you will log into APEX with the ADMIN user and create a workspace for your specific application. Take note of the workspace, user and password for this application as it will be different than your database user.

1. Open the "View Login Info" section of your workshop.

	![Image alt text](images/sample1.png)

2. You will use the APEX URL to open APEX

  ![Image alt text](images/sample1.png)

3. Login using:
    - APEX Workspace Name
    - APEX Workspace User
    - APEX Workspace Password

4. It will ask you to change the password. You can change the password or you can use the existing password

5. Click on "Create Workspace"

6. For Workspace Name type in "Vector" and click Next

7. For "Re-Use existing schema?" set this to Yes

8. For Schema Name type in "ADMIN" and click Next.
    **Note:** By doing this you have linked your application with your database schema where your tables reside.

9.  For the Identify Administrator section fill in:
    - Administrator Username: vectoruser (This will be the user we will log into APEX with)
    - Administrator Password: Welcome_1 (or any password you want just make sure to remember it as we will use this to log into APEX with)
    - Email: test@test.com (Any email address will work.)
  
10. Click Next
    
11. Click Create Workspace

12. Click Done

13. Click on admin in the upper right corner and click sign out

14. Click on Return to Sign In Page

15. On the page fill in the following values:
    - Workspace: Vector
    - Username: vectoruser
    - Password: Welcome_1 (or the password you created)
  
16. Again you will be asked to create a new password. You can use the same password or change it.

17. You should now be on the main landing page of APEX

## Task 2: Create Application
In this task you will create the application so you can start building pages.

1. Click on App Builder Icon

2. Click on Create a New App

3. Name your application. I'm going to use "Vector Image" then click Create Application

## Task 3: Create Image Gallery Page
In this task you will create the Image Gallery page. This page will display the images that are brought back from your AI Vector Search based on input from the user.

1. Click on Create Page

2. Choose Cards

3. On this page:
    - Name: Image Gallery
    - Table/View Name: VECTOR_IMAGE
    - Click Next

4. On this page:
    - Choose Float
    - For Title Column select the URL field from the table
    - Click on Create Page

5. On the left panel where you see the section called Body, right click on the word Body and choose "Create Page Item" We will use this as a text entry box for searching.
    
6.  If you click on the newly created Item on the left side of the page then on the right side of the page you will see the Page Item panel for that item. Make the following changes in the Page Item Panel:
    - Change the name of the item you just created to P4\_SEARCH\_ITEM.
    - Change Submit when Enter pressed to On
 
7.  In the panel on the left, Drag the P4\_SEARCH\_ITEM up above the Image Gallery page item. This will make it so your search box will be at the top of the page.

8.   Click on the Image Gallery page item and make the following changes in the Region panel on the right:
    
    - Under source change the Type to SQL Query
    - For the SQL Query paste the following:
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
    - In the Page Items to Submit section click on the menu button on the right and click on P4\_SEARCH\_ITEM
 
 
13. Click on the Attributes Tab

14. Change the following:
    - Card
      - Primary Key Column 1: URL
    - Media
      - Source: Blob Column
      - Blob Column: IMG
    - Click on Save at the top of the page

15. Right click on P4\_ORDER\_BY in the left panel and select delete
16. Click on Save
17. If you want to see how your page looks click on the run button
18. You will need to login to your application
    - Username: vectoruser
    - Password: Welcome_1 (Or whatever password you set it to)
19. Try typing in Fruit or Climbing in the search bar
20. You can close your application page but leave your Application Designer/Builder page open

## Task 4: Create Image Detail Page
In this task you will create the Image Detail Page that will display information like the descriptions and vectors for the image selected. You will also create a link back to the Image Gallery Page.

1. If you are not at the application builder home page click on the Application Breadcrumb at the top corner of the page
2.  You should be on a page that looks like the image below
3.  Click on Create Page

4.  Choose Interactive Report

5.  On this page:
    - Name: Image Detail
    - Table/View Name: VECTOR_IMAGE
    - Click Create Page

6. On the left panel where you see the section called Body, right click on the word Body and choose "Create Page Item". This will be a variable so that you can pass which image you want to see the detail from the Image Gallery page.

7. If you click on the newly created Item then on the right side of the page you will see the Page Item panel for that item. Make the following changes in the Page Item Panel:
    - Name: P2_URL
    - In the Default section change:
      - Type: SQL Query (return single value)
      - SQL Query: "select min(url) from vector_image" (without the double quotes)

8.  In the panel on the left, Drag the P2_URL up above the Image Detail page item

9.  Click on the Image Detail in the left panel to pull up its details

10. In the Where Clause section paste "URL = :P2_URL" (without the double quotes)

11. In the Page Items to Submit section click on the menu button on the right and click on P2_URL

12. Back on the left side panel right click on image detail and click on duplicate

13. Expand the column list of the top image detail page item and do the following:
    - Right click on url and choose comment out
    - Right click on img and choose comment out
    - Right click on uform_vector and choose comment out
    - Right click on nlp_vector and choose comment out

14. Expand the columns list of the bottom image detail page item and do the following:
    - Right click on url and choose comment out
    - Right click on img and choose comment out
    - Right click on uform_desc and choose comment out
    - Right click on nlp_desc and choose comment out

15. Right click on Body in the left panel and click on Create Button

16. Click on the button on the left and in the Button panel on the right change the following:
    - Button Name: Back\_to\_Images
    - The label should automatically change to Back To Images
    - Under Behavior make the following changes: 
    - Action: Redirect to to Page in this Application
    - Target: Click on Link to bring up the dialog
      - Click on the menu on the page box
      - Click on the number next to the Image Gallery. In my case I would click on 2
      - Click on Ok

17. Click on Save on the Page

18. Click on the application breadcrumb at the top left corner of the page

## Task 5: Linking Image Gallery to the Image Details
In this task you will link the Image Gallery page to the Image Detail Pages so when you click on an image you will get the details for it.

1.  If you are not at the application builder home page click on the Application Breadcrumb at the top of the page
2.  You should be on a page that looks like the image below
3.  Click on your Image Gallery page

4.  In the left panel Under Image Gallery right click on Actions and Choose create action

5.  In the Action Panel on the right make the following changes
    - Identification -> Type: Media
    - Under link Change
      - Type: Redirect to Page in this Application
      - Click on Target 
        - Click on the menu on the Page box which should pop up the list of pages in your application
        - Click on the number of the page for the "Image Detail" page. In my case I would click on the 3
        - In the Set Items section click on the menu button next to the box for Name. It should show P2_URL. Click on that to select it
        - For the Value box, again click on the menu button and here select URL
        - Click Ok to save the dialog
      - Click on the menu on the Link Attributes box and select URL

1.  Click Save on the page


## Task 6: Running the Application
1. To run your application do one of the following:
   1. If you are still on the Image Gallery page you can click on the run button to start your application. 
   2. If you are on the Application Builder home page then click on the Image Gallery page and then click the run button.
   3. If you are on the Image Detail page you can click the application breadcrumb at the top of the page to get to the Application Builder home page the follow the instructions above.
   
2.  If you need to login use:
    - Username: vectorimage
    - Password: Welcome_1 (or whatever password you set for vectorimage)

3. If you want you can click on the Menu and select Image Gallery to get to the Image Gallery page as well.

4. In your search bar type in Fruit or Surfing or whatever you want to search on
5. Click on an image to go to your detail page
6. On the detail page you can see both descriptions and what the vectors for the descriptions are. At the bottom is the button to go back to the Image Gallery page.

Congradulations, you have built a AI Vector Search enabled application using images!

## Learn More

*(optional - include links to docs, white papers, blogs, etc)*

* [URL text 1](http://docs.oracle.com)
* [URL text 2](http://docs.oracle.com)

## Acknowledgements
* **Author** - David Start, Product Management
* **Contributors** -  David Start, Product Management
* **Last Updated By/Date** - David Start, Sept 2024
