# Workshop Details

## Short Description

Build a recipe sharing Android app powered by Oracle Backend for Firebase (Fusabase). Learn to use the Fusabase Android SDK for database, authentication, file storage, and security rules in Java.

## Long Description

Modern mobile apps need a backend for data, sign-in, and file storage. Oracle Backend for Firebase (Fusabase) provides those services on top of Oracle AI Database, with an SDK shape familiar to anyone who has used Firebase. This workshop teaches you that SDK on Android by building a real, working app.

You start with an Android Studio starter project for RecipeShare, a simple app where users browse, post, rate, and photograph recipes. The Activities, Fragments, Adapters, and Models are pre-built. Your job is the SDK boundary: implement the methods that call into Fusabase from your service classes. You connect the app to a local Fusabase project, add authentication, attach a real-time snapshot listener to a RecyclerView, write documents and subcollection entries, upload photos from the Android Photo Picker, and finish by replacing permissive starter rules with owner-based security rules.

By the end of the workshop, you have a running RecipeShare Android app, a working mental model of the Fusabase Android SDK shape (`FusabaseAuth`, `FusabaseOracledb`, `Storage`), and a clear pattern for how authentication, real-time data, and security rules fit together in a real app.

## Workshop Outline

1. Introduction
2. Setup Oracle Backend for Firebase
3. Lab 1: Create Your First Project
4. Lab 2: Connect the Android App
5. Lab 3: Authentication
6. Lab 4: Read Recipe Data
7. Lab 5: Write Recipe Data
8. Lab 6: Photo Upload
9. Lab 7: Security Rules

## Workshop Prerequisites

- **Android Studio Ladybug (2024.2.1) or later**, installed from [developer.android.com/studio](https://developer.android.com/studio). The download is around 1 GB. Launch Android Studio at least once before the workshop so it can finish downloading the Android SDK platform tools and the default Emulator runtime.
- **JDK 17.** Android Studio bundles a compatible JDK. If you prefer a system JDK, Eclipse Temurin 17 is recommended.
- **An Android Emulator system image** (API 34 or 35). Android Studio offers to install one on first launch.
- **At least 10 GB of free disk space** for Android Studio, the SDK, and the Emulator.
- **Docker or Podman** to run the local Fusabase backend. Lab 1 walks through the install.
- Runs on macOS, Windows, and Linux. Basic familiarity with Java and Android development is helpful but not required.

## Estimated Time

90 minutes.

## Notes

- Keep this file aligned with the final manifest and lab titles.
- Keep the long description learner-focused. Do not say the workshop was created from a blog, prompt, or source format.
