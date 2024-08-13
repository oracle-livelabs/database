# Title of the Lab

## Introduction

*Describe the lab in one or two sentences, for example:* This lab walks you through the steps to ...

Estimated Lab Time: -- minutes

### About <Product/Technology> (Optional)
Enter background information here about the technology/feature or product used in this lab - no need to repeat what you covered in the introduction. Keep this section fairly concise. If you find yourself needing more than two sections/paragraphs, please utilize the "Learn More" section.

### Objectives

*List objectives for this lab using the format below*

In this lab, you will:
* Objective 1
* Objective 2
* Objective 3

### Prerequisites (Optional)

*List the prerequisites for this lab using the format below. Fill in whatever knowledge, accounts, etc. is necessary to complete the lab. Do NOT list each previous lab as a prerequisite.*

This lab assumes you have:
* An Oracle Cloud account
* All previous labs successfully completed


*This is the "fold" - below items are collapsed by default*

## Task 1: Concise Task Description

(optional) Task 1 opening paragraph.

1. Open the "View Login Info" section of your workshop.

	![Image alt text](images/sample1.png)

2. You will use the APEX URL to open APEX

  ![Image alt text](images/sample1.png)

3. Login using
   - APEX Workspace Name
   - APEX Workspace User
   - APEX Workspace Password

4. It will ask you to change the password. You can change the password or you can use the existing password

5. Click on "Create Workspace"

6. For Workspace Name type in "Vector" and click Next

7. For "Re-Use existing schema?" set this to Yes

8. For Schema Name type in "ADMIN"

9. For the Identify Administrator section fill in:
- Administrator Username: vectoruser
- Administrator Password: Welcome_1 (or any password you want)
- Email: test@test.com
  
10. Click Create

11. Click Done

12. Click on admin in the corner and click sign out

13. Click on Return to Sign In Page

14. On the page fill in the following values:
- Vector
- vectoruser
- Welcome_1
  
15. Again you will be asked to create a new password. You can use the same password or change it.

16. You should now be on the main landing page of APEX

## Task 2: Concise Task Description

1. Click on App Builder

2. Click on Create a New App

3. Name your application. I'm going to use "Vector Image" then click Create Application

4. Click on Create Page

5. Choose Interactive Report

6. On this page:
- Name: Image Detail
- Table/View Name: VECTOR_IMAGE
- Click Create Page

7. On the left panel where you see the section called Body, right click on the word Body and choose "Create Page Item"

8. If you want a bigger window to work in you can expand the right window where the page item definition is by dragging the edge to the left.

9. In the Page Item window change the following:
- Name: P2_URL
- In the Default section change:
  - Type "SQL Query (return single value)
  - SQL Query: "select min(url) from vector_image"

10. Drag the P2_URL in the left window above the Image Detail in the Body section

11. Click on the Image Detail in the left window to pull up its details

12. In the Where Clause section paste "URL = :P2_URL"

13. Right below it type in P2_URL into page items to submit.

14. Back on the left side panel right click on image detail and click on duplicate

15. Expand the column list of the top image detail page item and do the following:
- Right click on url and choose comment out
- Right click on img and choose comment out
- Right click on uform_vector and choose comment out
- Right click on nlp_vector and choose comment out

16. Expand the columns list of the bottom image detail page item and do the following:
- Right click on url and choose comment out
- Right click on img and choose comment out
- Right click on uform_desc and choose comment out
- Right click on nlp_desc and choose comment out

17. Click on Save

18. We will come back later to add a return button once we have created our next page

19. Click on the Application 100 breadcrumb at the top of the page

## Task 3: Concise Task Description

4. Click on Create Page

5. Choose Cards

6. On this page:
- Name: Image Gallery
- Table/View Name: VECTOR_IMAGE
- Click Next

7. Choose Float

8. For Title Column select URL and click on Create Page

9. On the left panel where you see the section called Body, right click on the word Body and choose "Create Page Item"

8. Change the name of the item you just created to P4_SEARCH_ITEM. You can see the details on the right pannel (Page Item view)

9. Change Submit when Enter pressed

9.  Drag the P4_SEARCH_ITEM up above the Image Gallery in the panel on the left

10. Click on the Image Gallery page item and make the following Changes:
- Under source change the Type to SQL Query
 - For the Query paste the following:
'''
select URL,
       IMG,
       UFORM_DESC,
       UFORM_VECTOR,
       NLP_DESC,
       NLP_VECTOR
  from VECTOR_IMAGE
  ORDER BY VECTOR_DISTANCE( uform_vector, vector_embedding(minilm12v2 using :P4_SERACH_ITEM as data), EUCLIDEAN ) 
  FETCH APPROX FIRST 2 rows ONLY WITH TARGET ACCURACY 90
'''
- In the Page Items to Submit section type "P4_SERACH_ITEM"
  - In Order by Change Type to None

1.  Click on the Attributes Tab

2.  Change the following:
    - Card
      - Primary Key Column 1: URL
    - Media
      - Source: Blob Column
      - Blob Column: IMG

3.  Right click on P4_ORDER_BY in the left panel and select delete

4.  Under Image Gallery right click on Actions and Choose create action

5.  On the left in the Actions menu make the following changes
- Change Type: Media
- Under link Change
  - Type: Redirect to Page in this Application
  - Click on Target 
    - Click on the menu on the Page box which should pop up the list of pages in your application
    - Click on the number of the page for the "Image Detail" page. In my case I would click on the 2
    - In the Set Items section click on the menu button next to the box for Name. It should show P2_URL. Click on that to select it
    - For the Value box, again click on the menu button and here select URL
    - Click Ok to save the dialog
  - Click on the menu on the Link Attributes box and select URL

1.  Click Save on the page

2.  Click on Application 100 breadcrumb at the top of the page

## Task 4: Concise Task Description

1. Click on the Image Detail page

2. Right click on Body in the left panel and click on Create Button

3. In the Button panel on the right change the following:
- Button Name: Back_to_Images
- Label: Back to Images
- Behavior
  - Action: Redirecto to Page in this Application
  - Target: Click on Link to bring up the dialog
    - Click on the menu on the page box
    - Click on the number next to the Image Gallery. In my case I would click on 4
    - Click on Ok

4. Click on Save on the Page

5. Click on Application 100

## Task 4: Concise Task Description

1. Click on Run Application
2. To login use:
- Username: vectorimage
- Password: Welcome_1 (or whatever password you set for vectorimage)

3. 
## Learn More

*(optional - include links to docs, white papers, blogs, etc)*

* [URL text 1](http://docs.oracle.com)
* [URL text 2](http://docs.oracle.com)

## Acknowledgements
* **Author** - <Name, Title, Group>
* **Contributors** -  <Name, Group> -- optional
* **Last Updated By/Date** - <Name, Month Year>
