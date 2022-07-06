# LiveLabs Test Template

*About this template: This file is used to demonstrate all of the features built into the LiveLabs conversion engine. Many of the features described here are optional and are so marked. Start with the [Use the LiveLabs Lab Markdown Template](https://confluence.oraclecorp.com/confluence/display/DUASPG/Use+the+LiveLabs+Lab+Markdown+Template) Confluence page. Next, use the [LiveLabs Markdown Template What's New](https://confluence.oraclecorp.com/confluence/display/DUASPG/LiveLabs+Markdown+Template+What%27s+New) page.*

## Introduction

*Describe the lab in one or two sentences, for example:* This lab walks you through the Steps to ...

*You may add an option video, using this format: [](youtube:YouTube video id)*

  [](youtube:zNKxJjkq0Pw)

Estimated Time: -- minutes

### About <Product/Technology> (Optional)
Enter background information here about the technology/feature or product used in this lab - no need to repeat what you covered in the introduction. Keep this section fairly concise. If you find yourself needing more than to sections/paragraphs, please utilize the "Learn More" section.

### Objectives

*List objectives for the lab - if this is the intro lab, list objectives for the workshop*

In this lab, you will:
* Objective 1
* Objective 2
* Objective 3
* [relative lab url test](?lab=need-help)

### Prerequisites (Optional)

*List the prerequisites for this lab using the format below. Fill in whatever knowledge, accounts, etc. is needed to complete the lab. **Do NOT list** each previous lab as a prerequisite.*

This lab assumes you have:

* An Oracle account
* All previous labs successfully completed

  > **Note:** If you have a **Free Trial** account, when your Free Trial expires your account will be converted to an **Always Free** account. You will not be able to conduct Free Tier workshops unless the Always Free environment is available. **[Click here for the Free Tier FAQ page.](https://www.oracle.com/cloud/free/faq.html)**

*This is the "fold" - below items are collapsed by default*

## Task 1: Standard LiveLabs Images and Text

<!-- Images -->

1. Standard method to include an image.

    ![](images/sample1.png)

	The image alt text is optional.

    ![image alt text](images/sample1.png)

2.	Image with a link to the text description below it. This provides screen readers with an accessible way to "see" the image. The `sample1.txt` file must be added to the `files` folder.

	![Image alt text](images/sample1.png "Image title")

3. Inline image icon ![Image alt text](images/sample2.png) click **Navigation**.

<!-- Text formatting -->

4. One example with bold **text**.

   If you add another paragraph, add 3 spaces before the beginning of the line to keep it in line with the numbered step.

5. Use tables sparingly:

 | Column 1 | Column 2 | Column 3 |
 | --- | --- | --- |
 | 1 | Some text or a link | More text  |
 | 2 |Some text or a link | More text |
 | 3 | Some text or a link | More text |

6.	You can also include bulleted lists - make sure to indent 4 spaces:

    - List item 1
    - List item 2

7. Inline monospaced font is done with a single back ticks, for example `this is code`.

8. Code blocks are identified by three back ticks, indented to align with the step:

    ```
    This is a code block.
    ```

9. Long code block with line breaks

    ```
    <copy>/* Specify the base URL that you copied from your files in OCI Object Storage in the define base_URL line below*/
    /* change idthydc0kinr to your real namespace. The name is case-sensitive. */
    /* change ADWCLab to your real bucket name. The name is case-sensitive. */
    /* change us-phoenix-1 to your real region name. The name is case-sensitive. */
    /* you can find these values on the OCI Console .. Storage .. Object Storage screen */
    set define on
    define base_URL='https://objectstorage.us-phoenix-1.oraclecloud.com/n/idthydc0kinr/b/ADWCLab/o'

    /* copy Channels table */
    begin
     dbms_cloud.copy_data(
        table_name =>'CHANNELS',
        credential_name =>'OBJ_STORE_CRED',
        file_uri_list =>'&base_URL/chan_v3.dat',
        format => json_object('ignoremissingcolumns' value 'true', 'removequotes' value 'true')
     );
    end;
    /

    /* copy Countries table */
    begin
     dbms_cloud.copy_data(
        table_name =>'COUNTRIES',
        credential_name =>'OBJ_STORE_CRED',
        file_uri_list =>'&base_URL/coun_v3.dat',
        format => json_object('ignoremissingcolumns' value 'true', 'removequotes' value 'true')
     );
    end;
    /

    /* Copy customers */
    begin
     dbms_cloud.copy_data(
        table_name =>'CUSTOMERS',
        credential_name =>'OBJ_STORE_CRED',
        file_uri_list =>'&base_URL/cust1v3.dat',
        format => json_object('ignoremissingcolumns' value 'true', 'removequotes' value 'true', 'dateformat' value 'YYYY-MM-DD-HH24-MI-SS')
     );
    end;
    /
    begin
     dbms_cloud.copy_data(
        table_name =>'SUPPLEMENTARY_DEMOGRAPHICS',
        credential_name =>'OBJ_STORE_CRED',
        file_uri_list =>'&base_URL/dem1v3.dat',
        format => json_object('ignoremissingcolumns' value 'true', 'removequotes' value 'true')
     );
    end;
    /
    begin
     dbms_cloud.copy_data(
        table_name =>'SALES',
        credential_name =>'OBJ_STORE_CRED',
        file_uri_list =>'&base_URL/dmsal_v3.dat',
        format => json_object('ignoremissingcolumns' value 'true', 'removequotes' value 'true', 'dateformat' value 'YYYY-MM-DD')
     );
    end;
    /
    begin
     dbms_cloud.copy_data(
        table_name =>'PRODUCTS',
        credential_name =>'OBJ_STORE_CRED',
        file_uri_list =>'&base_URL/prod1v3.dat',
        format => json_object('delimiter' value '|', 'quote' value '^', 'ignoremissingcolumns' value 'true', 'dateformat' value 'YYYY-MM-DD-HH24-MI-SS', 'blankasnull' value 'true')
     );
    end;
    /
    begin
     dbms_cloud.copy_data(
        table_name =>'PROMOTIONS',
        credential_name =>'OBJ_STORE_CRED',
        file_uri_list =>'&base_URL/prom1v3.dat',
        format => json_object('ignoremissingcolumns' value 'true', 'removequotes' value 'true', 'dateformat' value 'YYYY-MM-DD-HH24-MI-SS', 'blankasnull' value 'true')
     );
    end;
    /
    begin
     dbms_cloud.copy_data(
        table_name =>'SALES',
        credential_name =>'OBJ_STORE_CRED',
        file_uri_list =>'&base_URL/sale1v3.dat',
        format => json_object('ignoremissingcolumns' value 'true', 'removequotes' value 'true', 'dateformat' value 'YYYY-MM-DD', 'blankasnull' value 'true')
     );
    end;
    /
    begin
     dbms_cloud.copy_data(
        table_name =>'TIMES',
        credential_name =>'OBJ_STORE_CRED',
        file_uri_list =>'&base_URL/time_v3.dat',
        format => json_object('ignoremissingcolumns' value 'true', 'removequotes' value 'true', 'dateformat' value 'YYYY-MM-DD-HH24-MI-SS', 'blankasnull' value 'true')
     );
    end;
    /
    begin
     dbms_cloud.copy_data(
        table_name =>'COSTS',
        credential_name =>'OBJ_STORE_CRED',
        file_uri_list =>'&base_URL/costs.dat',
        format => json_object('ignoremissingcolumns' value 'true', 'dateformat' value 'YYYY-MM-DD', 'blankasnull' value 'true')
     );
    end;
    /</copy>
    ```

9. Use the copy function to allow your users to copy code snippets from LiveLabs into the clipboard.

    ```
  	<copy>Enclose the text you want to copy using the <copy> element.</copy>
    ```

10. Code snippets that include variables

  	```
    <copy>ssh -i <ssh-key-file></copy>
    ```

11. Syntax highlighting examples

    ```
    <copy>select * from employees;</copy>
    ```
    Sample with line breaks:

    ```
    <copy>class Simple{  

      public static void main(String args[]){  

        System.out.println("Hello Java");  

      }  

    }</copy>
    ```

    ```
    <copy>{  
        "employee": {  
            "name":       "sonoo",   
            "salary":      56000,   
            "married":    true  
        }  
    }</copy>
    ```

    ```
    <copy># This program prints Hello, world!

    print('Hello, world!')</copy>
    ```

12. You may want to turn highlighting off, to do so, use `nohighlight`:

    ```nohighlight
    <copy>class Simple{  
      public static void main(String args[]){  
        System.out.println("Hello Java");  
      }  
    }</copy>
    ```

## Task 2: Optional Advanced Features

<!-- files -->

1. Files that you want the reader to download:

  When the file type is not recognized by the browser, you can use the following format.

  > **Note:** _The filename must be in lowercase letters and CANNOT include any spaces._

  Download the [starter SQL code](files/starter-file.sql).

  When the file type is recognized by the browser, it will attempt to render it. So you can use the following format to force the download dialog box.

  > **Note:** _The filename must be in lowercase letters and CANNOT include any spaces._

  Download the [sample JSON code](files/sample.json?download=1).

  *IMPORTANT: do not include zip files, CSV, PDF, PSD, JAR, WAR, EAR, bin or exe files - you must have those objects stored somewhere else. We highly recommend using Oracle Cloud Object Store and creating a PAR URL instead. See [Using Pre-Authenticated Requests](https://docs.cloud.oracle.com/en-us/iaas/Content/Object/Tasks/usingpreauthenticatedrequests.htm)*

3. Conditional content example (type="livelabs")

    Select your compartment. <if type="livelabs">If you are using a LiveLabs environment, be sure to select the compartment provided by the environment. Leave Always Free unchecked,</if><if type="alwaysfree">Choose any compartment, select "Always Free",</if> and enter `SecretPassw0rd` for the ADMIN password, then click **Create Autonomous Database**.

    ![](images/atp-settings-1.png)
    <if type="livelabs">![](images/atp-settings-2-notaf.png)</if>
    <if type="alwaysfree">![](images/atp-settings-2.png)</if>
    ![](images/atp-settings-3.png)

## Learn More

*(optional - include links to docs, white papers, blogs, etc)*

* [URL text 1](http://docs.oracle.com)
* [URL text 2](http://docs.oracle.com)

## Acknowledgements
* **Author** - <Name, Title, Group>
* **Contributors** -  <Name, Group> (optional)
* **Last Updated By/Date** - <Name, Month Year>
