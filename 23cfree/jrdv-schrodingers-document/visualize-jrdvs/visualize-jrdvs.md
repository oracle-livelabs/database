# Visualize Geospatial Data Within JSON Relational Duality Views

## Introduction

In this lab you will leverage Oracle APEX's Native Map Region to visualize the data captured within the set of JSON Relational Duality Views (JRDVs) you created earlier to show the progress of the volunteer teams in planting trees within designated heat islands.

Estimated Time: 5 minutes.

<!-- Watch the video below for a quick walk through of the lab. -->

<!-- update video link. Previous iteration: [](youtube:XnE1yw2k5IU) -->

### Objectives
Learn how to:
- Use Oracle APEX's Native Map Region to view a simple map that visualizes tree planting progress within Chicago's heat islands


### Prerequisites
This lab assumes you have:
- Oracle Database 23c Free Developer Release
- Completed all previous labs successfully
- ORDS still running so that you can run the sample APEX application

## Task 1: Open the APEX Application

1. Open Activities -> Google Chrome

    ![Open Google Chrome](images/activities-chrome.png)


2. Go to this URL and wait for the screen to load, then log in as **admin** and supply the password you previously reset in the prior lab.
    ```
    <copy>
    http://localhost:8080
    </copy>
    ```
    ![Login using credentials](images/apex-wtfc-login.png)


3. Since this APEX application uses  database account authentication to connect to the database, supply **hol23c** for the login and supply the password you previously reset in the prior lab.

    ![Connect APEX session](images/app-301-hol23c-login.png)


## Task 2: Visualize GeoJSON and SDO_GEOMETRY Data With APEX'S Native Map Region 

1. Select the {page} from the left-hand-side menu. A map of the . . . 

    top 450 most disadvantaged communities (DACs) in the USA state of Wisconsin are displayed using the APEX Native Map Region's capability to show multiple aspects mapping data as *Extruded Polygons.*  Explore the map to understand these features:

2. Explore the map of Chicago-area heat islands just like you would explore any browser-based map:

    - Move around the map and hover over a few of the heat islands displayed. You can use the +/- keys or CTL and your mouse wheel to increase or decrease the scale of the map, just as if it were a Google Maps or MapQuest web interface.

    - Observe the intensity of the color scheme for a few of the most disadvantaged DACs. Also, observe that the height of each polygon in the map region is tied to the [] value for each DAC.

    - You can also turn off the 3D appearance of DACs by clicking on the 2D button on the map region. Conversely, you can return to a 3D appearance by clicking on the 3D button.

    ![Experiment with Native Map Region features](images/app-301-100-03.png)

    - Click into a few of the DACs to view its FIPS code and some of the properties that qualify them to be a disadvantaged community.  
    - Finally, click on a few of the map icons to view the location of *potential* (brown square) or *actual* (blue teardrop) charging stations and their location within the state.

    ![Explore DAC and charger details](images/app-301-100-04.png)

3. Sign out of the application

    ![exitapplication](images/app-301-signout.png)

4. You have now completed this lab.

## Learn More
* [Oracle Database 23c: Spatial Concepts](https://docs.oracle.com/en/database/oracle/oracle-database/23/spatl/spatial-concepts.html#GUID-67E4037F-C40F-442A-8662-837DD5539784)
* [Oracle APEX 23.1: Creating Maps](https://docs.oracle.com/en/database/oracle/apex/23.1/htmdb/creating-maps.html#GUID-ACA5ED1C-7031-42BF-90B1-98938FB6DC17)


## Acknowledgements
* **Author** - Kaylien Phan, William Masdon, Jim Czuprynski
* **Contributors** - Jim Czuprynski, LiveLabs Contributor, Zero Defect Computing, Inc.
* **Last Updated By/Date** - Jim Czuprynski, July 2023