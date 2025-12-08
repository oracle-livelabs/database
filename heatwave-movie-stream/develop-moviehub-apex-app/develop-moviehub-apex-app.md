# Develop the MovieHub - Movie Recommendation App

![MovieHub - Powered by MySQL Heatwave](./images/moviehub-logo-large.png "moviehub-logo-large ")

## Introduction

The MovieHub App is a demo application created to showcase the potential of MySQL HeatWave powered applications.

In this lab, you will be guided to create high performance apps powered by the MySQL HeatWave Database Service; developing a movie stream like web application using Oracle APEX, a leading low-code development tool that allows you to create complex web apps in minutes. You will also learn how you can leverage the automation of machine learning processes, thanks to MySQL AutoML that allows you to build, train, deploy, and explain machine learning models within MySQL HeatWave.

_Estimated Time:_ 10 minutes

### Objectives

In this lab, you will be guided through the following task:

- Running the MovieHub demo application powered by MySQL
- Explore the users movies recommendation pages
- Use the Administration Views page
- Explore the Analytics Dashboard page
- Explore the Holiday Movie page


### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell
- Some Experience with Oracle Autonomous and Oracle APEX
- Completed Lab 9

## Task 1: Run the MovieHub App

1. Login into to your Oracle APEX workspace

    ![APEX workspace menu with app](./images/apex-workspace-moviehub-menu.png "apex-workspace-moviehub-menu ")

    You should see the imported application

2. Run and log into the imported app

    **The app will not run correctly if the Web credentials and Endopint have not been correctly set at Lab 8, Task 6 and Lab 9, Task 3**

    a. Click on **Run**

    A window will open in the web browser with the application home page

    ![MovieHub Home page](./images/moviehub-app-home-page.png "moviehub-app-home-page ")

    Notice that the nobody user will be the default value when you are not currently logged as your APEX account

    c. Click on **Go To User Login Page**

    The application login page will appear

    ![MovieHub Log In page](./images/apex-app-login-page.png =50%x* "apex-app-login-page ")

    d. Introduce your the user credentials of the 'public' account. This will simulate what happens when a not administrator user logs in the MovieHub App

    ![MovieHub PUBLIC user log in](./images/public-user-login-page.png =50%x* "public-user-login-page ")

## Task 2: Explore the users movies recommendation pages

1. Explore the Profiles page

    a. The **My Profiles** page will open, with the current account profiles in the app

    ![MovieHub Profiles page](./images/moviehub-profiles-page.png "moviehub-profiles-page ")

    b. At any time, You can log out. This action will return you to the home page

    c. When logged as the public account, only the Profiles page will appear in the Side Tree Navigation Menu

    ![MovieHub Side Tree Navigation Menu](./images/side-tree-navigation-menu.png =50%x* "side-tree-navigation-menu ")

2. See the movie recommendations for the user James

    a. Go to the profiles page

    ![MovieHub Profiles page](./images/moviehub-profiles-page2.png "moviehub-profiles-page ")

    b. Click the button below James profile

    ![James profile button](./images/moviehub-user1-button.png =30%x* "moviehub-user1-button ")

    c. The James movies recommendation page will appear

    ![James recommendation page](./images/recommendations-user1-page.png "recommendations-user1-page ")

    The page will have the top 5 recommended movies, according to the "**pred\_user\_21\_0r**" MySQL table. This page is loaded with the **Restore** button as well

3. Explore the movie recommendations when you add more movie records to the data with "Watch movies" buttons. **This simulates the action of watching 15 and 30 movies from the movie catalog compared with the original data**

    a. Click on **Watch 15 movies**

    ![James recommendation page plus 15](./images/recommendations-user1-plus15.png "recommendations-user1-plus15 ")

    Notice the movie recommendation change. This action will show the top 5 recommended movies, according to the "**pred\_user\_21\_15r**" MySQL table

    b. Click on **Watch 30 movies**

    ![James recommendation page plus 30](./images/recommendations-user1-plus30.png "recommendations-user1-plus30 ")

    Notice the movie recommendation change. This action will show the top 5 recommended movies, according to the "**pred\_user\_21\_30r**" MySQL table

4. Explore the popular movies recommendations

    The application allows you to simulate what would happen if the user has inactivity for more than 30 days. This will trigger the global recommendations that are the same as a **new user**.

    a. Click on the Date Picker Item

    ![Date Picker item selector](./images/date-picker.png =40%x* "date-picker ")

    b. Select **30 days after** today's date. Or Select the **next month**

    ![Inactivity Popular Movies Recommendations](./images/recommendations-popular-movies.png "recommendations-popular-movies ")

    Notice the movie recommendation change. This action will show the top 5 recommended movies, according to the "**pred\_user\_30\_30r**" MySQL table

## Task 3: Explore the Analytics Dashboard page

1. **Log Out** from the 'public' account

    ![Sign Out from public account](./images/sign-out-public.png =30%x* "sign-out-public ")

2. **Log In** as an 'admin' account

    ![Sign In as admin account](./images/sing-in-admin.png =30%x*  "sing-in-admin ")

3. When logged in as an administrative account, the Home Page will be the **Admin Views**

    ![Administration Views Page](./images/administration-views.png  "administration-views ")

4. Click in the Analytics Dashboard button to access the **Analytics Dashboard** page. You can also access this pages by the Navigation Menu

    ![Analytics Dashboard Page](./images/analytics-dashboard-page.png  "analytics-dashboard-page ")

    You can see:

    a. **Movies - Genres Distribution** Pie chart

    b. **User - Gender Distribution** Donut chart

    c. **Users - Age Distribution** Bar chart

    d. **Top 10 Trending Movies** Bar chart

## Task 4: Explore the Holiday and Top Trending Movies page

1. Click in the **Holiday Movie** Navigation Menu button to access the **Holiday Movie** page

    a.

    ![Holiday Movie navigation menu](./images/navigation-menu-holiday-movie.png =60%x* "navigation-menu-holiday-movie ")

    b. The page will have the top 10 recommended users for the Movie 200 - 'The Shinning', according to the "**pred\_item\_200**" MySQL table

    ![Item 200 recommendation page](./images/recommendations-item-200-page.png "recommendations-item-200-page ")

2. You can inspect the **Top Trending Movie** page too.

You may now **proceed to the next lab**

## Learn More

- [Oracle Autonomous Database Serverless Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/index.html#Oracle%C2%AE-Cloud)
- [Oracle APEX Rendering Objects Documentation](https://docs.oracle.com/en/database/oracle/apex/23.1/aexjs/apex.html)
- [Oracle JavaScript Extension Toolkit (JET) API Reference Documentation](https://docs.oracle.com/en/middleware/developer-tools/jet/14.1/develop/getting-started-oracle-javascript-extension-toolkit-jet.html)
- [Oracle Cloud Infrastructure MySQL Database Service Documentation](https://docs.oracle.com/en-us/iaas/mysql-database/home.htm)
- [MySQL HeatWave AutoML Documentation] (https://dev.mysql.com/doc/heatwave/en/mys-hwaml-machine-learning.html)

## Acknowledgements

- **Author** - Cristian Aguilar, MySQL Solution Engineering
- **Contributors** - Perside Foster, MySQL Principal Solution Engineering
- **Last Updated By/Date** - Cristian Aguilar, MySQL Solution Engineering, May 2025
