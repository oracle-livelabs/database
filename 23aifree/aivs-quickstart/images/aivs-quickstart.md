# Get Started with AI Vector Search on Autonomous Database Free Container Image

## Introduction

To optimize your workflow while developing workshop content, we highly recommend utilizing VSCode as your preferred editor. Leveraging the power of VSCode you can use the optional tasks below and efficiently edit the Markdown files according to your specific needs. As demonstrated in the previous lab, Task 1 has templates that will provide a solid foundation for you to get started with editing process. By incorporating these recommendations from Task 2 to 15 (optional tasks), you can streamline your content development and enhance productivity.

> **Note:** For a comprehensive workshop development experience, we recommended to utilize the sample workshop folder provided in Task 1, while tasks 2 to 15 are optional.

<!-- **Helpful tips from your LiveLabs Team**
[Video walking through markdown editing](youtube:rOj5APIU-XU) -->

### Objectives

* Create workshop and lab content
* Link to absolute path images
* Use conditional formatting
* Add videos and scale images
* Use the LintChecker
* **IMPORTANT!** Case sensitivity

### What Do You Need?
* An IDE, such as Visual Studio Code.


## Understanding how it works the include and varibles section in manifest.json

The "include" section of a workshop manifest file have a critical role in seamlessly incorporating external resources into the workshop content. These resources can include a variety of files, including code snippets, data files, images. Utilizing the "include" directive, you can embed links to local files, enabling readers to conveniently download essential resources.

Variables stored in JSON format gives you the possibility to define configurable parameters, such as database names, compute resources, or workload types.

## Task 1: Create your labs and workshop content
Leverage the content from the **[sample-livelabs-templates/sample-workshop](https://github.com/oracle-livelabs/common/tree/main/sample-livelabs-templates/sample-workshop)** folder to start creating lab and workshop content for your project. Fork and clone the **[oracle-livelabs/common repository](https://github.com/oracle-livelabs/common/)** to get the sample-workshop folder on your local computer, by following Task 1 and Task 2 of this workshop.

> **Note:** Ensure to update your clone from the **upstream/main** repository (detailed in **Task 3**) regularly whenever we are working on the markdown files.

To create your lab and workshop content:
1. Open your cloned repository (where you want to put your workshop, not the common repository) using Windows Explorer (Windows) or Finder (Mac).

2. Create your workshop folder anywhere in your cloned repository. If a folder already exists for the workshop, then you can create your subfolders within that.

4. In your cloned *common* repository, Go to **sample-livelabs-templates/sample-workshop**. This has a few lab folders, such as **provision**, **query**, etc. Every lab folder contains the following: a **files** folder, an **images** folder, and the respective `.md` file. You can use **Live Server** (see in Task 6) to open up **sample-workshop/workshops/tenancy/index.html** to see how a workshop will show up in production, and play with it.

5. Copy any lab folder (except the folder named `workshops`), such as the **query** folder, to your project folder. In your project folder, rename the folder **query** and the respective `.md` file within it as per your requirement.  Based on the sample **query** folder, you can create and rename as many labs (folders) and the respective `.md` files as per your requirement.

      >**Note:** The **files** folder within every sample lab folder is currently not required and is reserved for future use. You can remove it if you don't need it.

      ![Files folder with sample labs.](./images/lab-files-folder-currently-not-needed.png " ")
      After you copy the sample folder to your project folder, you can delete your copy of the **files** folder from your project folder.
      Your lab will look similar to this example:
      ![Example of your lab files folder.](./images/lab-folder-structure.png " ")

6. Similarly, copy the **workshops** folder along with its contents from **sample-livelabs-templates/sample-workshop** to your project folder.

7. To edit a `.md` file of your lab, you click **File > Open**.
  ![Open md file](./images/file-open.png " ")

8. Navigate to your project folder and click **Open** to open your project folder.
  ![Navigate to your project folder.](./images/project-folder.png " ")

  The project folder along with the labs and **workshops** folder will then be displayed in your text editor.
    ![Workshops folder displayed in text editor.](./images/project-folder-displayed.png " ")

9. Select the `.md` file you want to edit, for example, select the `data-load/data-load.md` file and edit your lab content. Similarly, edit the `.md` files of the rest of your labs.
    ![Select markdown file to edit.](./images/open-mdfile-editing.png " ")

10. If you want to add images in your lab, then include them within the **images** folder. You can insert images in the respective `.md` file.

11. Similarly to edit your workshop content, expand the **workshops/tenancy** (if you are creating a workshop running on users' tenancies), **workshops/sandbox** (if you are creating a sandbox/green button workshop), and/or **workshops/desktop** (if you are creating a noVNC workshop) folder in your text editor. Edit the `manifest.json` to list the labs you have added to your workshop (or plan to add) and update the title of the workshop. The `manifest.json` is like your book map file in SDL.

  Besides the list of labs, also update the `workshoptitle` field, and update the `help` field to point to the workshop's stakeholders group email. If the `include` and `variables` field do not apply to your workshop, please remove them, otherwise, your workshop will not render properly.=

  ![Edit manifest json file](./images/manifest.png " ")

12. If you want to add an introduction to your workshop, then navigate to **sample-livelabs-templates/sample-workshop** and copy the `introduction` folder to your project folder. You can rename the introduction folder if you would want to.

13. You can also create a `README.md` file within **workshops/tenancy**, **workshops/sandbox**, and/or **workshops/desktop**, and update the `README.md` with a summary of your workshop. Note that the `README.md` file is optional for your workshop.

## Task 2: Use common labs and images

1. Some labs can be shared by many LiveLabs workshops, so we put together a list of [common labs](https://github.com/oracle-livelabs/common/tree/main/labs), including "Generate SSH Key," "Register an Oracle Cloud account," "Need Help," etc. for easier workshop development. You can leverage the [common labs](https://github.com/oracle-livelabs/common/tree/main/labs) located in the **[oracle-livelabs/common repository](https://github.com/oracle-livelabs/common/)**.

2. To use a common lab, you need to use an absolute link to the lab in your workshop's manifest.json file. For example, if you want to use the "Generate SSH Key" common lab located in [https://github.com/oracle-livelabs/common/blob/main/**labs/generate-ssh-key-cloud-shell/generate-ssh-keys-cloud-shell.md**](https://github.com/oracle-livelabs/common/blob/main/labs/generate-ssh-key-cloud-shell/generate-ssh-keys-cloud-shell.md), you should use this link in the manifest.json file: [https://oracle-livelabs.github.io/common/**labs/generate-ssh-key-local/generate-ssh-keys-local.md**](https://oracle-livelabs.github.io/common/labs/generate-ssh-key-local/generate-ssh-keys-local.md).

Leverage LiveLabs [Markdown Cheat Sheet](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/LiveLabs_MD_Cheat_Sheet.pdf)

## Task 3: DONT's

1. Mandatory requirements (Check links, code snippets, help email address, grammar issues)
2. Make sure that all filenames are lowercase, markdown filenames and directories generally match
3. Pay attention on lab section (each lab has a title(#), Introduction (##), Objectives(###), Prerequisites(###), Acknowledgements (##))

## Task 4: Security

1. Blur all personal information (IP addresses, intranet URLs, email addresses, OCIDs, usernames, and passwords) from images.
  ![Blur all identifiable information.](./images/blur-ip.png " ")

2. Every image must have a description: ![DESC] (…/…/name.png “ “)

  ![Every image must have a description.](./images/image-desc.png " ")

3. Do not use any IP addresses, intranet URLs (for example links to a Confluence page), email addresses, OCIDs, usernames, or passwords in the text. Do not provide a demo password.

## Task 5: Link to absolute path images
Rather than pointing to images within your lab folder or workshop directory with a relative path, you can just as easily point your images to URLs. This comes in handy if you use [common images](https://github.com/oracle-livelabs/common/tree/main/images), or reuse an image a lot, the code you write to display it in markdown will always be the same no matter where the image is in relation to markdown. Using absolute image paths is also handy if you need to keep an image updated, as changing the destination file image will affect every instance where you pointed an image to it. This is also useful when you want to *point to an image in a different repository* (you don't need to clone or fork that repository). This is the same concept and implementation as using absolute paths for common labs in your manifest.json files.

*For screenshots of OCI menu navigation, use the images with absolute links*

1. Here is an example of what the image code block looks like for pointing to a local image using relative pathing.

  ```![Description](images/image.png " ")```

2. To use an image with an absolute path, just replace the path with an URL. In this case, I am pointing to a common image located in the **oracle-livelabs/common** repository.

    ```
    <copy>
    ![Description](https://oracle-livelabs.github.io/common/images/console/home-page.png " ")
    </copy>
    ```

  Here is how the image path above shows up in production:
  ![Description](https://oracle-livelabs.github.io/common/images/console/home-page.png " ")

3. You can find all common images in the [oracle-livelabs/common](https://github.com/oracle-livelabs/common/tree/main/images) GitHub repository. For example, if an image is located in **images/console/home-page.png** in the **common** repository, then the link you should use is https://oracle-livelabs.github.io/common/images/console/home-page.png.

  ![Recommended to use GitHub path for images.](./images/home-page.png " ")

## Task 6: Use conditional formatting

If your workshop supports multiple instance types, but the bulk of the content stays the same, then conditional formatting can save you a lot of work. Most commonly, if you have differences between the "Free Tier" and "LiveLabs" (Green button) versions such as provisioning a database instance in Free Tier and just checking that it's created properly for LiveLabs, then conditional formatting will allow your workshop to use a singular markdown for both. This will save you immense effort and prevent accidental oversights if you need to update your workshop in the future since you won't have to maintain a duplicate markdown.

  1. Conditional formatting is using the "if" conditional to choose what to display in your markdown, based on an additional attribute "type" you attach to a lab element in your manifest.json file. Take a look at this example to understand the components involved in making conditional formatting work.

  ![Example of conditional formatting.](./images/conditional-vsc1.png " ")

  On line 71, you can see the conditional is **if type="freetier"** and the closing **/if** on line 92. That means line 71-92 is only rendered if the type is freetier, and lines 93-98 is only rendered if the type is livelabs.

  ![Code is only rendered if condition is met.](./images/freetier.png " ")

  On lines 21 and 27, you can see that we added the attribute "type" to the lab element. In this instance, this manifest.json is for the free tier version of the workshop so when a customer launches the workshop through a free tier button on the workshop's landing page, lab 2 and lab 3 will always have the **"freetier"** type attached to it.

  ![Freetier version type.](./images/livelabs.png " ")

  On lines 12, 17, and 23, you can see the same thing except that the type is "livelabs" for this file. The actual word doesn't matter, as long as the "type" in the manifest.json and the "type" in the markdown matches, the contents of the markdown conditional will be displayed.

2. You may have noticed that the numbering of the substeps within a step that uses conditional formatting may get out of line. Don't worry, as long as you use a number greater than 0, markdown will automatically number them sequentially when it gets rendered on a webpage. Also, note that conditional formatting can be used in-line if needed, you don't **HAVE TO** envelope content in a neat code block... though it's recommended to keep things organized and easy to read.

  ![Recommended to keep code block organization.](./images/conditional-note.png " ")

3. **Conditional Formatting Tabs** - Conditional formatting can also be utilized to showcase distinct content based on various programming languages. You can follow the steps below to achieve this objective, by incorporating either a single task or multiple tasks, depending on your specific needs.

  Determine the specific programming languages for which you want to display different content. Create if blocks in a task, or multiple tasks if necessary, for each programming language you identified. Make sure to include the relevant instructions and content specific to each language.

  In the manifest.json file, in the corresponding lab section add the attribute "type" and reference all the programming language elements referenced in the in your manifest.json file. This association will allow the system to identify and display the appropriate content based on the programming language selected.

  The following example screenshot demonstrates the implementation of blocks for Java and Python programming languages on lines 69 and 78, respectively. Each if block contains the necessary steps specific to each programming language.

  ![mutiple-type-conditional-formatting-instructions](./images/mutiple-type-conditional-formatting-instructions.png " ")

  To ensure proper integration, the respective lab section in the manifest.json file should include the "type" attribute, referencing all the programming languages mentioned in the lab's markdown file. In the provided example, along with other programming languages, "java" and "python" are included.

  ![mutiple-type-conditional-formatting](./images/mutiple-type-conditional-formatting.png " ")

  To validate these modifications, you can utilize LiveServer to initiate testing. Tabs will be generated for each language, enabling users to switch between them. Upon selecting a specific tab, language-specific instructions will be displayed in the associated task(s). This interactive approach enhances the user experience by providing relevant instructions based on the selected programming language.

  ![tabs-conditional-formatting](./images/tabs-conditional-formatting.png " ")


## Task 13: Code Snippets

1. If you include code snippets in your workshop instruction, you can use the following syntax for code to distinguish it from other instructions.

    ![Code Snippet](./images/code-snippet.png " ")

    ```
    some code
    ```

2. If you want users to copy this code snippet, you can add the *copy* tag around the code.

  ![Add copy tag for code snippet](./images/code-copy.png " ")

    ```
    <copy>
    some code
    </copy>
    ```

3. If you specify the language of the code, Markdown can recognize the syntax and highlight certain information.

    ![Add json tag for code snippet](./images/json-code.png " ")

    ```json
    {
      "firstName": "John",
      "lastName": "Smith",
      "age": 25
    }

    ```
    ![Add java tag for code snippet](./images/java-code.png " ")
    ```java
    System.out.println("Hello World");
    ```

4. If you do not want anything highlighted in your code snippet, simply add the `text` tag.

    ![Add text tag to remove all highlighting](./images/text.png " ")
    ```text
    {
      "firstName": "John",
      "lastName": "Smith",
      "age": 25
    }
    ```

5. You can hide and reveal a code snippet, to challenge the users first, but still provide them with support when they get stumped.

  ![Code Block Reveal](./images/code-block-reveal.png " ")
  <details>
        <summary>*Reveal code block*</summary>
        ```python
        <copy>
        def getPrice():
        ...
        return jsonify(product_price)</copy>
        ```
  </details>

**Reminder** Download this handy [Cheatsheet](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/LiveLabs_MD_Cheat_Sheet.pdf), which has more information about using Markdown syntax for LiveLabs development.

## Task 14: Strikethrough

With this new feature, you can now cross out text or words in a paragraph by adding two tilde before and after the word or text in a paragraph.

1. Use this format to cross out a word - *`~~strikethrough~~`* transforms to *~~strikethrough~~*.

2. To cross out text or a sentence in a paragraph, use this format.

  *`~~An example of Strikethrough.~~`* transforms to *~~An example of Strikethrough.~~*

## Task 15: Clickable Links

1. Old pattern of making URL clickable required markdown formatting. For example, you need to have this format in markdown to make the links clickable.

  *`Please visit [https://livelabs.oracle.com](https://livelabs.oracle.com)`* or *`Please visit <https://livelabs.oracle.com>`* transforms to Please visit [https://livelabs.oracle.com](https://livelabs.oracle.com)

2. With new pattern, type the URL (including https://) and the engine automatically creates a clickable URL.

  *`Please visit https://livelabs.oracle.com`* transforms to Please visit https://livelabs.oracle.com

3.  The old formatting still works and is required to achieve the below formatting with alternative text in markdown format.

  *`Please visit [LiveLabs](https://developer.oracle.com)`* transforms to Please visit [LiveLabs](https://developer.oracle.com).

4. The URLs are opened in a new tab in the browser and the same applies to email addresses as well.

## Task 16: Building Blocks

Building Blocks are a way to enhance both the workshop development and customer experience. This step focuses on how authors can use Building Blocks and Tasks to accelerate their workshop development in your repo.

1. You can view the sample on building block [here](https://github.com/oracle-livelabs/common/blob/main/building-blocks/blocks/adb/provision/provision-console.md) and sample task [here](https://github.com/oracle-livelabs/common/blob/main/building-blocks/tasks/adb/provision-body.md)

2. You can view more building blocks and tasks by navigating to the [building-blocks](https://github.com/oracle-livelabs/common/tree/main/building-blocks) folder in the common repo.

3. If you would like to leverage pre-built building blocks for your repository, feel free to check out this [how to create building block guide](https://github.com/oracle-livelabs/common/blob/main/building-blocks/how-to-author-with-blocks/how-to-author-with-blocks.md) to begin building for your repo.

## Task 17: Use LiveServer extension

If you have installed the LiveServer extension in your VSCode by following the steps in Lab 2 Task4, you can conveniently utilize Live Server to open your workshop's HTML file and enjoy the seamless experience of dynamically viewing and testing your changes.

1. In the "workshops" folder of your workshop project, locate either your "tenancy" or "sandbox" folder. Right-click on the index.html file within the chosen folder. From the context menu, select **Open with Live Server**.

  ![open-live-server](./images/open-live-server.png " ")

2. This action will launch a local server, and your default web browser will open, displaying your workshop.

  ![view-in-live-server](./images/view-in-live-server.png " ")

3. With the workshop now open in your browser, you have the flexibility to modify your files as needed. Save the changes you make to the files. To see the changes reflected in real-time, simply reload the page in your browser and the Live Server ensures that any modifications you make to the files are immediately visible.

You may now **proceed to the next lab**.

## Acknowledgements

* **Author:**
    * Michelle Malcher, Director, Oracle Database Product Management
* **Contributors:**
    * Lauran Serhal, Consulting User Assistance Developer, Oracle Database and Big Data
    * Anuradha Chepuri, Consulting User Assistance Developer, Oracle GoldenGate

* **Reviewed by:**
    * Aslam Khan, Senior Manager, ODI, OGG, EDQ
    * Kay Malcolm, Vice President, Database Product Management
    * Andres Quintana, Senior Product Manager
    * Brianna Ambler, Product Manager

* **Last Updated By/Date:**
    * Ana Coman, Technical Program Manager, Oracle Database Product Management, May 2024