# Build a Recipe App with Oracle Backend for Firebase (iOS)

## Introduction

In this workshop, you will build a recipe sharing iOS app powered by Oracle Backend for Firebase (Fusabase). The app is built with SwiftUI and runs in the iOS Simulator on your Mac.

![Architecture diagram showing the workshop stack, the Fusabase console, the generated app config, and the RecipeShare iOS app](images/app.png =20%x*)

### Objectives

In this workshop, you will:

- Create a Project in the Fusabase console
- Build an iOS app with SwiftUI
- Read and Write Data Using the Fusabase iOS SDK
- Add Sign-Up and Sign-In with Fusabase Authentication
- Upload Photos with Fusabase File Storage
- Secure Your App Data with Fusabase Security Rules


Estimated Workshop Time: 90 minutes

## Prerequisites

This is an iOS workshop, so the development tools are macOS-only. Before you start, make sure you have:

- **macOS**. Xcode runs only on macOS, so you cannot complete this workshop on Windows or Linux. If you need a web-based version of this workshop, see the JavaScript edition.
- **Xcode 16 or later**, installed from the Mac App Store. The download is around 7 GB and the first launch can take several minutes while Xcode finishes installing components.
- **No Apple Developer account is required.** This workshop targets the iOS Simulator, which does not require code signing or a paid developer account.
- **A running Fusabase backend.** Lab 1 walks you through starting it locally with Docker or Podman.

## Task 1: Review the workshop overview

1. In this workshop, you will build a recipe sharing iOS app with three core services.

    - **Database** stores recipes and rating data.
    - **Authentication** manages sign-up, sign-in, and session state.
    - **File Storage** stores one image for each recipe.

2. Before you continue, make sure Xcode is installed and has been launched at least once so it can finish setting up command line tools and the default iOS Simulator runtime.

    The examples in this workshop use Xcode 16 with the iPhone 16 Simulator, but any recent Simulator device will work.

3. Keep these learning goals in mind as you move through the labs.

    - In Lab 1, you will set up the workshop environment, and create your first Fusabase project.
    - In Lab 2, you will get the starter Xcode project and connect it to your Fusabase project.
    - In Lab 3, you will learn how to add auth to your iOS app so users can sign up, sign in, and sign out.
    - In Lab 4, you will learn how to read data into SwiftUI views.
    - In Lab 5, you will learn how to write data from SwiftUI forms.
    - In Lab 6, you will learn how to use file storage with the iOS photo picker.
    - In Lab 7, you will update security rules to protect your data.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Contributors** -
* **Last Updated By/Date** - Killian Lynch, May 2026
