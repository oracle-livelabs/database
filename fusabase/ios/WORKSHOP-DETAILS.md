# Workshop Details

## Short Description

Build a recipe sharing iOS app powered by Oracle Backend for Firebase (Fusabase). Learn to use the Fusabase iOS SDK for database, authentication, file storage, and security rules in SwiftUI.

## Long Description

Modern mobile apps need a backend for data, sign-in, and file storage. Oracle Backend for Firebase (Fusabase) provides those services on top of Oracle AI Database, with an SDK shape familiar to anyone who has used Firebase. This workshop teaches you that SDK on iOS by building a real, working app.

You start with a SwiftUI starter project for RecipeShare, a simple app where users browse, post, rate, and photograph recipes. The Models, Views, and app root are pre-built. Your job is the SDK boundary: implement the methods in `AuthService.swift` and `RecipeService.swift` that call into Fusabase. You connect the app to a local Fusabase project, add authentication, query and write documents, upload photos from the iOS photo picker, and finish by replacing permissive starter rules with owner-based security rules.

By the end of the workshop, you have a running RecipeShare iOS app, a working mental model of the Fusabase iOS SDK shape (`FusabaseAuth`, `FusabaseOracledb`, `FusabaseStorage`), and a clear pattern for how authentication, data access, and security rules fit together in a real app.

## Workshop Outline

1. Introduction
2. Setup Oracle Backend for Firebase
3. Lab 1: Create Your First Project
4. Lab 2: Connect the iOS App
5. Lab 3: Authentication
6. Lab 4: Read Recipe Data
7. Lab 5: Write Recipe Data
8. Lab 6: Photo Upload
9. Lab 7: Security Rules

## Workshop Prerequisites

- **macOS.** Xcode runs only on macOS, so this workshop cannot be completed on Windows or Linux. For a cross-platform version, see the JavaScript edition.
- **Xcode 16 or later**, installed from the Mac App Store. The download is around 7 GB. Launch Xcode at least once before the workshop so it can finish installing command line tools and the default iOS Simulator runtime.
- **No Apple Developer account required.** The workshop targets the iOS Simulator, which does not require code signing or a paid developer account.
- **Docker or Podman** to run the local Fusabase backend. Lab 1 walks through the install.
- Basic familiarity with Swift and SwiftUI is helpful but not required.

## Estimated Time

90 minutes.

## Notes

- Keep this file aligned with the final manifest and lab titles.
- Keep the long description learner-focused. Do not say the workshop was created from a blog, prompt, or source format.
