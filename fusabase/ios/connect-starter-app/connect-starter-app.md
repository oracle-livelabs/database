# Connect the iOS App

## Introduction

In this lab, you'll get the starter Xcode project running, register an iOS app in the Fusabase console, paste the config, and verify the app shows the empty recipe list in the iOS Simulator.

### Objectives

In this lab, you will:

- get the sample app from GitHub
- open the starter Xcode project
- add the Fusabase iOS SDK as a Swift Package dependency
- register an iOS app in the Oracle Backend for Firebase Anywhere console
- paste the app config into `fusabase-config.json`
- run the app in the iOS Simulator and verify it connects to your project

Estimated Time: 15 minutes

### Prerequisites

This lab assumes you have:

- Successfully completed all previous labs.

## Task 1: Get the sample code

1. Clone the GitHub repository from your command line. If you don't have git, you could visit the URL below and download a .zip of the repo.

    ```bash
    <copy>git clone https://github.com/KillianLynch/fusabase-livelabs-ios.git</copy>
    ```

2. Move into the repository root.

    ```bash
    <copy>cd fusabase-livelabs-ios</copy>
    ```

    ![  screenshot showing the RecipeShare iOS starter project folder with the starter and finished subdirectories visible](images/task-1-starter-folder.png =40%x*)


## Task 2: Open the project in Xcode

1. Move into the `starter` directory and open the Xcode project.

    ```bash
    <copy>cd starter
    open RecipeShare.xcodeproj</copy>
    ```

    Or, in Finder, navigate to the `starter` folder and double-click `RecipeShare.xcodeproj`.

    ![screenshot showing the RecipeShare project open in Xcode with the project navigator on the left](images/task-2-xcode-open.png =60%x*)


2. In Xcode's toolbar, click the destination dropdown (next to the play button) and pick **iPhone 17** (or any "iOS Simulator" device).

    If the Simulator runtime isn't installed, Xcode will prompt you to download it (~5 GB). The download may take several minutes the first time.

    ![screenshot showing the Xcode destination dropdown with iPhone 16 Simulator selected](images/task-2-destination.png =40%x*)


## Task 3: Add the Fusabase iOS SDK Swift Package

1. In Xcode's menu bar, choose **File → Add Package Dependencies…**.

    ![screenshot showing the File > Add Package Dependencies menu item](images/task-3-add-package-menu.png =40%x*)


2. In the dialog that opens, paste the Fusabase iOS SDK URL into the search field at the top right and press Return.

    ```
    <copy>https://github.com/oracle/fusabase-ios-sdk.git</copy>
    ```

    Xcode resolves the package and shows it in the dialog.

    ![screenshot showing the Add Package Dependencies dialog with the Fusabase iOS SDK resolved](images/task-3-package-dialog.png =60%x*)


3. For **Dependency Rule**, leave the default (typically "Up to Next Major Version") and click **Add Package**.

4. Xcode opens a second dialog asking which products to add to the **RecipeShare** target. **Tick all four boxes**:

    - `FusabaseAuth`
    - `FusabaseCore`
    - `FusabaseOracledb`
    - `FusabaseStorage`

    Make sure each is added to the **RecipeShare** target (the only target in the project).

    ![  screenshot showing the product selection dialog with all four Fusabase products checked](images/task-3-product-selection.png =60%x*)

5. Click **Add Package** to finish. This will close the window. 

6. Now build the package by pressing **⌘B**, or . The build now **succeeds** — Xcode found all four Fusabase modules.

    ![  screenshot showing the build succeeded indicator at the top of Xcode](images/build.png =40%x*)

    ![  screenshot showing the build succeeded indicator at the top of Xcode](images/task-3-build-succeeded.png =40%x*)


## Task 4: Register an iOS app and paste the config

1. Return to the Oracle Backend for Firebase Anywhere console that you left open at the end of Lab 1. You will now register an iOS app so the SwiftUI app can connect to the Fusabase services (auth, database, file storage).

2. Open the project that you created in Lab 1.

3. From the project's home page, click **iOS** to register an iOS app.

    ![  screenshot of the Fusabase project home page with the iOS app option highlighted](images/task-4-ios-button.png =40%x*)

4. Name the app `RecipeShare` and click **Register App**.

5. Click **Next** through the next screens — skip the SDK install step, since you already added the Fusabase iOS SDK to the project in Task 3.

    > Note: If you've already closed the popup before copying the config, you can view all of the applications you've registered under **Project settings** → **Applications**.

6. The third screen shows your config JSON. For this demo we wany only the key and value pairs in the JSON object. Copy only those values. See the gif below

    > Note: If you've already closed the popup before copying the config, you can view all of the applications and configs you've registered under **Project settings** → **Applications**.

    ![  screenshot of the Fusabase console showing the iOS app config JSON with the copy icon visible](images/task-4-config.gif =70%x*)


    The config is what allows your app to work with Fusabase:

    - `project_id` identifies the Fusabase project you created in Lab 1.
    - `app_id` identifies the iOS app you just registered.
    - `schema` identifies the database schema that stores your project data.
    - `storage_bucket` identifies the bucket that later labs will use for uploads.
    - `ords_host` gives the SDK the ORDS base URL for API requests.

7. Switch back to Xcode. In the **Project navigator** (the left sidebar), expand **RecipeShare → Resources** and open `fusabase-config.json`.

    ![  screenshot showing fusabase-config.json open in Xcode's editor](images/c2.png =40%x*)


8. Replace all the key values besides `"allows_self_signed_certificates": true,` and `"enable_logging": true`

    Your config should look like this image below

    ![  screenshot showing fusabase-config.json open in Xcode's editor](images/comma.png =70%x*)


    Make sure to keep the surrounding curly braces and the bottom two values.

    ![  screenshot showing fusabase-config.json open in Xcode's editor](images/cf.gif =70%x*)

## Task 5: Launch the app


9. Press **⌘B** to build. The JSON is bundled into the `.app` at build time, so a rebuild is required for the new config to take effect.

10. Press **⌘R** to run or click product -> run. The Simulator opens and the app launches to the **Sign In** screen. Sign-in won't work yet — you haven't set up authentication yet. That comes next.

    ![  screenshot showing the build succeeded indicator at the top of Xcode](images/run.png =40%x*)

    ![  screenshot showing the RecipeShare Sign In screen running in the iOS Simulator](images/app.gif =60%x*))


3. If you see network errors instead, see **Appendix → Troubleshooting** below.

You've now finished the setup. You have the sample code, the Fusabase iOS SDK is added to the project, and your app is configured to talk to the Fusabase project you created in Lab 1.

> Note: If you'd rather skip the workshop and just run the completed app, open `finished/RecipeShare.xcodeproj` instead of `starter/`. The finished project also ships without the Fusabase iOS SDK linked — repeat **Task 3** above on the finished project to add it, then paste your config into `finished/RecipeShare/Resources/fusabase-config.json` (Task 4).

## Appendix

### Troubleshooting

- **"iOS 17 simulator not installed."** Xcode will prompt you to download a Simulator runtime the first time you select an iPhone destination. Wait it out — the download can take around 10 minutes depending on your Wi-Fi.

- **"Cannot find package."** Swift Package resolution failed when Xcode tried to fetch the SDK. Common causes: no internet, corporate VPN blocking GitHub, or the URL is wrong. In Xcode, go to **File → Packages → Reset Package Caches** and try Task 3 again.

- **"Module 'FusabaseAuth' not found"** persists after Task 3. The package was added but products weren't all linked. Open the project's **Package Dependencies** tab (click the project root in the left sidebar, then the project at the top of the editor pane), confirm `fusabase-ios-sdk` is listed under **Package Dependencies**, then check the **RecipeShare** target's **General → Frameworks, Libraries, and Embedded Content** — all four `Fusabase*` products should be listed. If any are missing, click **+** and add them.

- **"App can't reach localhost."** The iOS Simulator shares the host Mac's loopback interface, so `http://localhost:8080` works from the Simulator just like it does from your terminal. Confirm ORDS is actually running on port 8080:

    ```bash
    <copy>curl http://localhost:8080/ords/</copy>
    ```

    You should get an HTTP response (any response — even an error page from ORDS) rather than `Connection refused`. If you see `Connection refused`, return to Lab 1 and confirm the compose stack is up.

- **"Build failed: cannot find type AuthService."** Either you opened `finished/` instead of `starter/`, or you opened `starter/` before the Fusabase iOS SDK Swift Package finished resolving. Close Xcode, reopen `starter/RecipeShare.xcodeproj`, and wait for **Resolving package graph…** to disappear before you build.

You may now **proceed to the next lab**.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Contributors** -
* **Last Updated By/Date** - Killian Lynch, May 2026
