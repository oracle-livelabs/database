# Create your own directory structure for liquibase and sync metadata

Estimated lab time: 10 minutes

## Objectives

In this lab, you will learn how to modify the directory structure for the change logs which we generated in previous lab and sync metadata


## Task 1: Modify the directory structure 

For the base and subsequent changelogs, you might want to use a neater directory organization. Navigate to changes directory and see the directory structure. 

![Changes directory](images/changes-directory.png " ")

Having each changelog contained in a separate directory facilitates the development when schemas start getting bigger and the number of changesets important.

For this reason, we want to convert the file hr.00000.base/controller.xml to hr.00000.base.xml

The conversion can be achieved with the below steps:

In Cloud Shell prompt,navigate to changes directory

```text
<copy>cd ~/changes</copy>
<copy>sed -e "s/file=\"/file=\"hr.00000.base\//" hr.00000.base/controller.xml > hr.00000.base.xml</copy>
```

![SED Command](images/sed-command.png " ")


This command will create new xml file *hr.00000.base.xml* with the hr.00000.base folder structure. Verify the file with the folder structure details by opening the file hr.00000.base.xml

![Base xml folder](images/basexml-folder.png " ")

The file main.xml (**changes** directory) includes all the changelogs, so in a single update, ALL the modifications from the initial version to the last changelog will be checked and eventually applied.This can be verified using opening the file *mainmain.xml* and it will contents as below.

![Main xml](images/main-xml.png " ")



## Task 2 : Synchronize the metadata 

In the example, there are already two placeholders for the next schema/code releases.

At this point we can run lb update to synchronize the definition with the Liquibase metadata

Login to HR schema and verify the current working directory is home path of Cloud Shell. 

![Cloud Shell home](images/cloudshell-home.png " ")

***Home folder will be different for you***

```text
<copy>cd ~</copy>
<copy>sql /nolog</copy>
```

```text
<copy>set cloudconfig ebronline.zip</copy>
<copy>connect hr/Welcome#Welcome#123@ebronline_medium</copy>
<copy>show user</copy>
pwd
```

![sqlcl-hr](images/sqlcl-hr.png " ")

```text
<copy>cd changes</copy>
<copy>lb status -changelog-file main.xml</copy>
```

![lb-chagelog-status](images/lb-changelog-status.png " ")

Now let us run update command

```text
<copy>lb update -changelog-file main.xml</copy>
```

![lb-chagelog-update1](images/lb-changelog-update1.png " ")

![lb-chagelog-update2](images/lb-changelog-update2.png " ")


The next lb status shows everything up to date. A subsequent lb update will not change anything.

```text
<copy>lb status -changelog-file main.xml</copy>
```

```text
<copy>lb update -changelog-file main.xml</copy>
```

![lb-chagelog-last](images/lb-changelog-last.png " ")


You have successfully organized the directory structure and synchronized the metadata [proceed to the next lab](#next) to review and update the edition scripts.

## Acknowledgements

- Authors - Ludovico Caldara,Senior Principal Product Manager,Oracle MAA PM Team and Suraj Ramesh,Principal Product Manager,Oracle MAA PM Team
- Last Updated By/Date - Suraj Ramesh, Jan 2023


