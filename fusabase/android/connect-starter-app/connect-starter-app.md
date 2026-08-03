# Lab 2: Connect the Android App

## Introduction

In this lab, you will get the RecipeShare starter project, register an Android app in the Fusabase console, install the Fusabase SDK into your Gradle build, drop the generated config into the project, and run the app on the Android Emulator. By the end of this lab, the empty sign-in screen will appear on the emulator with the Fusabase SDK fully wired up.

### Objectives

In this lab, you will:

- Clone the workshop repo and open the Android starter project in Android Studio
- Register an Android app in the Fusabase console
- Install the Fusabase SDK and Gradle plugin in the starter project
- Copy `fusabase-config.json` into the project
- Adjust the `ords_host` so the Android Emulator can reach your local backend
- Sync Gradle and run the app on the emulator

Estimated Time: 15 minutes

### Prerequisites

This lab assumes you have:

- Successfully completed all previous labs.

## Task 1: Get the starter project

1. Open a terminal where you keep your projects.

2. Clone the workshop repository.

    ```bash
    <copy>git clone https://github.com/KillianLynch/fusabase-livelabs-android.git
    cd fusabase-livelabs-android</copy>
    ```

3. Open the starter project in Android Studio.

    Launch Android Studio, choose **Open** from the welcome screen, and select the `starter/RecipeShare` folder inside the cloned repo.

    ![Android Studio Open dialog pointing at starter/RecipeShare](images/task-1-open-project.png =85%x*)

4. Android Studio will start indexing and a Gradle sync will begin automatically. The starter ships **without** the Fusabase SDK wired into Gradle, so the initial sync should succeed. The Java source files under `app/src/main/java/...` will show unresolved imports for `com.oracle.mobile.fusabase.*` — that is expected. You'll add the SDK in Task 3 to make those imports resolve.

5. While Android Studio is indexing, take a quick look at the structure.

    - `app/java/com.oracle.fusabase.recipeshare/auth/` — the Authentication code lives here. `AuthRepository.java` is the file you'll edit in Lab 3.
    ![Fusabase console showing the generated fusabase-config.json](images/auth.png =65%x*)


    - `app/java/com.oracle.fusabase.recipeshare/recipeshare/recipes/` — the Database and Storage code lives here. `RecipeRepository.java` is the file you'll edit in Labs 4 through 7.
    ![Fusabase console showing the generated fusabase-config.json](images/recipes.png =65%x*)

    - `app/fusabase-config.json` — the config file the Fusabase Gradle plugin reads at build time. You'll fill this in during Task 4 of this lab.


## Task 2: Register an Android app in the Fusabase console

1. Return to the Fusabase console at [http://localhost:8080](http://localhost:8080) and open the project you created in Lab 1.

2. In the project home page, click the Android icon to register a new Android app.

    ![Fusabase console project home with the Android app icon highlighted](images/android.png =65%x*)

3. In the **Register Android app** dialog, enter the application ID from the starter project:

    ```text
    <copy>com.oracle.fusabase.recipeshare</copy>
    ```

    ![Fusabase console project home with the Android app icon highlighted](images/register.png =65%x*)


4. Click **Register app**. The console generates the integration steps for your app — first the **Add SDK** step, then the **Get config** step.

## Task 3: Install the Fusabase SDK

The console's **Add SDK** step shows two snippets — one for the project-level `build.gradle.kts` and one for `app/build.gradle.kts`. The starter project ships **without** the Fusabase SDK so you wire it up yourself. The Java source files in `app/src/main/java/...` already import `com.oracle.mobile.fusabase.*`; once you finish this task, those imports will resolve.

> **Use the Package Manager tab** in the console's **Add SDK** screen. The **AAR & JAR** tab is for offline / air-gapped environments where you can't reach Maven Central — it's not covered here.

1. Keep the **Add SDK** step open in the console as a reference. The snippets below match what the console shows on the **Package Manager** tab.

    ![Fusabase console showing the SDK install snippets](images/package.png =75%x*)

2. Switch to the project folder 
    ![Fusabase console showing the SDK install snippets](images/project.png =45%x*)


2. Open the project-level `build.gradle.kts` (at `RecipeShare/build.gradle.kts`, **not** the one inside `app/`). Add a `buildscript` block **below** the existing `plugins` block:

    ```kotlin
    <copy>buildscript {
        repositories {
            google()
            mavenCentral()
        }
        dependencies {
            classpath("com.oracle.mobile:fusabase-gradle-plugin:26.1.0")
        }
    }</copy>
    ```

    This puts the Fusabase Gradle plugin on the build classpath so the next file can apply it.
    ![Fusabase console showing the SDK install snippets](images/build.png =55%x*)


3. Open `app/build.gradle.kts`. Add the plugin id inside the existing `plugins { ... }` block:

    ```kotlin
    <copy>id("com.oracle.mobile.fusabase-gradle-plugin")</copy>
    ```
    ![Fusabase console showing the SDK install snippets](images/add-sdk.png =55%x*)


4. In the same file, add the SDK as a dependency. At the top of the existing `dependencies { ... }` block, add:

    ```kotlin
    <copy>implementation("com.oracle.mobile:fusabase:26.1.0")</copy>
    ```

5. Save both files. **Don't sync Gradle yet** — `fusabase-config.json` is still a placeholder, so the Fusabase plugin would fail. You'll fill in the config in the next task, then sync in Task 6.

   > **What each piece does:**
   >
   > - `fusabase-gradle-plugin` reads `fusabase-config.json` at build time and emits Android string resources the SDK consumes at runtime.
   > - `fusabase` is the SDK library itself — it exposes `FusabaseAuth.getInstance()`, `FusabaseOracledb.getInstance()`, and `Storage.getInstance()`, all of which the starter source code already imports.

## Task 4: Add the Fusabase config to the project

1. In the console, click **Next** to advance from the **Add SDK** step to the **Get config** step. The console now shows the `fusabase-config.json` payload — this is the file you'll paste into the project.

    ![Fusabase console showing the generated fusabase-config.json](images/task-3-config-json.png =85%x*)

2. In Android Studio's **Project** view (top left), expand the `app` module. You'll find a placeholder `fusabase-config.json` at the module root with `"PASTE FROM CONSOLE"` strings.

    ![Fusabase console project home with the Android app icon highlighted](images/project.png =45%x*)

3. Open `app/fusabase-config.json` and replace the entire contents with the JSON the console gave you. It looks like:

    ```json
    {
        "schema": "testuser",
        "app_name": "recipeshare",
        "app_type": "ANDROID",
        "app_id": "...",
        "objs_type": "dbfs",
        "project_id": "...",
        "storage_bucket": "...",
        "auth_type": "base",
        "auth_id": "...",
        "ords_host": "http://localhost:8080/ords/testuser/"
    }
    ```

4. Save the file (**Ctrl+S** / **Cmd+S**).

## Task 5: Point the emulator at your machine

1. The config the console emits uses `localhost:8080` as the `ords_host`. That works from any browser running on your machine, but the **Android Emulator runs in its own virtualized network** — `localhost` from inside the emulator means "the emulator itself," not your development machine.

2. To reach your machine from the emulator, Android provides the special address `10.0.2.2`.

3. In `app/fusabase-config.json`, change the host portion of `ords_host` from `localhost` to `10.0.2.2`. The rest of the URL stays the same.

    Before:

    ```text
    "ords_host": "http://localhost:8080/ords/testuser/"
    ```

    After:

    ```text
    <copy>"ords_host": "http://10.0.2.2:8080/ords/testuser/"</copy>
    ```
    ![Fusabase console project home with the Android app icon highlighted](images/example.png =85%x*)

4. Save the file.

   > Why this matters: any time the Fusabase SDK on your emulator opens a request to your local backend, it will resolve the host using the emulator's network stack. `10.0.2.2` is the only address that maps back to your machine.

## Task 6: Sync Gradle

1. Click **Sync Project with Gradle Files** in the Android Studio toolbar (the elephant-with-arrow icon), or wait for the banner that appears whenever a build file changes.

    ![Android Studio Sync Project with Gradle Files toolbar button](images/sync.png =85%x*)

2. Watch the build output panel. Gradle will pull down what you declared in Task 3:

    - The `com.oracle.mobile:fusabase-gradle-plugin` artifact — the plugin you applied in `app/build.gradle.kts`.
    - The `com.oracle.mobile:fusabase` library — the SDK dependency you added.
    - The Material Components, AndroidX, Navigation Component, and Glide dependencies that already shipped with the starter.
    - The Android Gradle Plugin and the Android SDK platform.

3. When the sync finishes successfully, you'll see **BUILD SUCCESSFUL** in the build panel.

   > If sync fails because `fusabase-config.json` still has placeholder values, double-check Task 4.
   >
   > If sync fails on a dependency resolution error for `com.oracle.mobile:*`, your Maven repository might not yet expose the version pinned in `gradle/libs.versions.toml`. Update the `fusabase` version in that file to match the version your Fusabase console reports.

## Task 7: Run the app on the emulator

1. In the Android Studio toolbar, select an emulator from the device dropdown. If you don't have one yet, click **Device Manager**, click **Create Virtual Device**, pick any recent Pixel device, and accept the recommended system image.

    ![RecipeShare empty sign-in screen running on the Pixel emulator](images/device.png =30%x*)
    ![RecipeShare empty sign-in screen running on the Pixel emulator](images/device2.png =30%x*)
    ![RecipeShare empty sign-in screen running on the Pixel emulator](images/device3.png =30%x*)


2. Click the green **Run** button (Ctrl+R / Ctrl+R).
    ![RecipeShare empty sign-in screen running on the Pixel emulator](images/run.png =30%x*)

3. Android Studio builds the app and launches it in the emulator. The emulator boot can take 30–60 seconds the first time.

4. The app starts on the **Sign in** screen. The sign in will fail becauase we have not implemented it yet. Leave the emulator running. You'll keep using it through the rest of the workshop.


    ![RecipeShare empty sign-in screen running on the Pixel emulator](images/task-6-app-running.png =30%x*)


## Summary

Take a moment to look at what's now in place:

- **Fusabase Gradle plugin and SDK library** that you added in Task 3 are now on the build classpath and the app's runtime classpath. `FusabaseAuth.getInstance()`, `FusabaseOracledb.getInstance()`, and `Storage.getInstance()` are all callable from your code.
- **`fusabase-config.json`** sits at the app module root. The Fusabase Gradle plugin reads it at build time and generates Android string resources the SDK consumes at runtime.
- **`com.oracle.mobile.fusabase.auth.SocialLoginActivity`** is declared in your manifest with the correct redirect scheme. You won't use it for the email/password flow in Lab 3, but it's ready if you later add federated providers.
- **`network_security_config.xml`** permits cleartext HTTP to `10.0.2.2` so your local development backend works without TLS. Production deployments would use HTTPS and would not need this configuration.

Move on to Lab 3 to wire up authentication.

You may now **proceed to the next lab**.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Last Updated By/Date** - Killian Lynch, May 2026
