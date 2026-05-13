# Build a Recipe App with Oracle Backend for Firebase (Android)

## Introduction

In this workshop, you will build a recipe sharing Android app powered by Oracle Backend for Firebase (Fusabase). The app is built in Java with the Android SDK and runs on the Android Emulator.

![Architecture diagram showing the workshop stack, the Fusabase console, the generated app config, and the RecipeShare Android app](images/app.png =20%x*)

### Objectives

In this workshop, you will:

- Create a Project in the Fusabase console
- Build an Android app with Java and the Android SDK
- Read and Write Data Using the Fusabase Android SDK
- Add Sign-Up and Sign-In with Fusabase Authentication
- Upload Photos with Fusabase File Storage
- Secure Your App Data with Fusabase Security Rules


Estimated Workshop Time: 90 minutes

## Prerequisites

Before you start, make sure you have:

- **Android Studio Ladybug (2024.2.1) or later**, installed from [developer.android.com/studio](https://developer.android.com/studio). The download is around 1 GB and the first launch can take several minutes while Android Studio downloads the SDK and the default emulator system image.
- **JDK 17.** Android Studio bundles a compatible JDK; you do not need to install one separately. If you prefer to use a system JDK, [Eclipse Temurin 17](https://adoptium.net/) is recommended.
- **An Android Emulator system image.** Android Studio will offer to install one on first launch — pick any recent system image (API 34 or 35).
- **At least 10 GB of free disk space** for Android Studio, the SDK, and the Emulator.
- **A running Fusabase backend.** Lab 1 walks you through starting it locally with Docker or Podman.

This workshop runs on macOS, Windows, and Linux — anywhere Android Studio runs.

## Task 1: Review the workshop overview

1. In this workshop, you will build a recipe sharing Android app with three core services.

    - **Database** stores recipes and rating data.
    - **Authentication** manages sign-up, sign-in, and session state.
    - **File Storage** stores one image for each recipe.

2. Before you continue, make sure Android Studio is installed and has been launched at least once so it can finish downloading the Android SDK platform tools and the default emulator runtime.

    The examples in this workshop use Android Studio Ladybug with the Pixel 8 Emulator running API 35, but any recent emulator device will work.

3. Keep these learning goals in mind as you move through the labs.

    - In Lab 1, you will set up the workshop environment, and create your first Fusabase project.
    - In Lab 2, you will get the starter Android project and connect it to your Fusabase project.
    - In Lab 3, you will learn how to add auth to your Android app so users can sign up, sign in, and sign out.
    - In Lab 4, you will learn how to read data into a RecyclerView with real-time snapshot listeners.
    - In Lab 5, you will learn how to write data from Android forms.
    - In Lab 6, you will learn how to use file storage with the Android Photo Picker.
    - In Lab 7, you will update security rules to protect your data.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Contributors** -
* **Last Updated By/Date** - Killian Lynch, May 2026
