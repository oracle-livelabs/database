# Workshop Details

## Short Description

Build a recipe sharing web app powered by Oracle Backend for Firebase (Fusabase). Learn to use the Fusabase JavaScript SDK for database, authentication, file storage, and security rules.

## Long Description

Modern web apps need a backend for data, sign-in, and file storage. Oracle Backend for Firebase (Fusabase) provides those services on top of Oracle AI Database, with an SDK shape familiar to anyone who has used Firebase. This workshop teaches you that SDK on the web by building a real, working app.

You start with a JavaScript starter project for RecipeShare, a simple app where users browse, post, rate, and photograph recipes. The HTML, CSS, and component scaffolding are pre-built. Your job is the SDK boundary: implement the JavaScript functions that call into Fusabase. You connect the app to a local Fusabase project, query and seed documents, add authentication, write recipes and subcollection ratings, upload photos to file storage, and finish by replacing permissive starter rules with owner-based security rules.

By the end of the workshop, you have a running RecipeShare web app, a working mental model of the Fusabase JavaScript SDK (`collection`, `query`, `getDocs`, `addDoc`, `updateDoc`, `auth.currentUser`, storage refs), and a clear pattern for how authentication, data access, and security rules fit together in a real app.

## Workshop Outline

1. Introduction
2. Setup Fusabase
3. Lab 1: Create Your First Project
4. Lab 2: Connect the Starter App
5. Lab 3: Build the Public Recipe Experience
6. Lab 4: Authentication
7. Lab 5: Write Recipe Data
8. Lab 6: Photo Upload
9. Lab 7: Security Rules

## Workshop Prerequisites

- **A code editor.** The examples use VS Code, but any modern editor works.
- **Node.js LTS** to install dependencies and run the starter app's local dev server.
- **A current web browser** (Chrome, Edge, Firefox, or Safari).
- **Docker or Podman** to run the local Fusabase backend. Lab 1 walks through the install.
- Runs on macOS, Windows, and Linux. Basic familiarity with JavaScript and HTML is helpful but not required.

## Estimated Time

75 minutes.

## Notes

- Keep this file aligned with the final manifest and lab titles.
- Keep the long description learner-focused. Do not say the workshop was created from a blog, prompt, or source format.
