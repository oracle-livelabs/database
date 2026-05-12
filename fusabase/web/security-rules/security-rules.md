# Security Rules

## Introduction

In this lab, you will add an edit recipe feature and then discover a security vulnerability: any signed-in user can edit any recipe. You will fix this by configuring granular security rules in the Fusabase console that enforce owner-based access control on the server side.

### Objectives

In this lab, you will:

- create a document reference with `doc(collection(db, "recipes"), state.editingRecipeId)`
- partially update an existing recipe with `updateDoc(recipeRef, { ... })`
- observe that the permissive rule allows any user to edit any recipe
- replace the permissive database rule with granular auth-based and owner-based rules
- configure owner-based security rules with `request.resource.data.ownerId == request.auth.uid` on create and `request.auth.uid == resource.data.ownerId` on update
- verify that security rules correctly deny unauthorized updates
- add storage security rules that require authentication for uploads

Estimated Time: 15 minutes

## Task 1: Review the current rules

1. Return to the Fusabase console.

2. Open your project, then click **Database** in the left navigation.

3. Click the **Security rules** tab.

4. You should see the permissive rule you published in Lab 1:

    ```text
    match /{document=**} { allow read, write: if true;}
    ```

    This rule allows any client to read and write any document, with or without authentication. That was fine for getting started, but it is not safe for production.

    ![shows the code. ](images/security1.png =60%x*)


5. Why this matters in Fusabase:

    Security rules are the server-side access control layer. Even though the SDK runs in the browser, every read and write passes through Fusabase, where security rules decide whether to allow or deny the operation.

## Task 2: Edit recipes with the SDK

Steps 1-6 walk through the edit pattern piece by piece. Read each step to understand how the SDK updates an existing document, then copy the complete code in step 7.

1. Return to your code editor and open `starter/scripts/app.js`.

2. Find the **Lab 7 TODO** for editing a recipe.

    ```js
    if (state.editingRecipeId) {
      runAction("Recipe updated.", async () => {
        // ── Lab 7 TODO: Edit a recipe with the SDK ───
        // Use doc() to point at this recipe, then call updateDoc().
        //
        // const recipeRef = doc(collection(db, "recipes"), state.editingRecipeId);
        // await updateDoc(recipeRef, {
        //   title: formInput.title.trim(),
        //   description: formInput.description.trim(),
        //   category: formInput.category,
        //   prepTime: Number(formInput.prepTime),
        //   instructions: formInput.instructions.trim()
        // });
        throw new Error("Complete Lab 7 to edit recipes.");
      });
    }
    ```

3. First, build a reference to the recipe being edited:

    ```js
    const recipeRef = doc(collection(db, "recipes"), state.editingRecipeId);
    ```

    This combines the recipes collection reference with the current `state.editingRecipeId` so the SDK points at one existing recipe document.

4. Next, call `updateDoc()` with the editable fields from the form:

    ```js
    await updateDoc(recipeRef, {
      title: formInput.title.trim(),
      description: formInput.description.trim(),
      category: formInput.category,
      prepTime: Number(formInput.prepTime),
      instructions: formInput.instructions.trim(),
      ingredients: formInput.ingredients
    });
    ```

5. Walk through what this update does:

    - `collection(db, "recipes")` points at the recipes collection.
    - `doc(collection(db, "recipes"), state.editingRecipeId)` creates a reference to the recipe currently being edited.
    - `updateDoc(recipeRef, { ... })` modifies only the specified fields on the existing document.
    - This is a partial update. Fields you do not include, such as `ownerId`, `createdAt`, and any photo URL, are left untouched.

6. **Remove the placeholder error:**

    ```js
    throw new Error("Complete Lab 7 to edit recipes.");
    ```

    Removing the throw lets Recipe Share run your `updateDoc()` call and refresh the recipe list.

7. Your completed Lab 7 TODO code should look like this:

    ```js
    <copy>const recipeRef = doc(collection(db, "recipes"), state.editingRecipeId);
    await updateDoc(recipeRef, {
      title: formInput.title.trim(),
      description: formInput.description.trim(),
      category: formInput.category,
      prepTime: Number(formInput.prepTime),
      instructions: formInput.instructions.trim(),
      ingredients: formInput.ingredients
    });</copy>
    ```

    ![shows the code. ](images/update.png =60%x*)

    Copy this Lab 7 code into the TODO area and remove the placeholder error.

8. Keep this update pattern in mind:

    - `updateDoc()` performs a partial update — it merges the new fields into the existing document rather than replacing it.
    - This is different from `addDoc()`, which creates a new document. With `updateDoc()`, you target an existing document by reference.
    - The browser SDK can attempt the update, but Fusabase security rules decide whether the server allows it.

9. Save the file.

## Task 3: Edit someone else's recipe

1. Return to the web app and refresh the page.

2. Sign in with the account you created in Lab 4 if you signed out for any reason, or simply create a new demo user.

3. Notice that an **Edit** button appears on **every** recipe in the detail panel — not just recipes you created.

    ![shows the code. ](images/edit.gif =60%x*)


4. Select one of the **seed demo recipes** (a recipe where the Author is not your email address).

5. Click **Edit**. The modal opens with the recipe's current values pre-filled.

6. Change the title to something recognizable (for example, add "EDITED" to the beginning) and click **Publish recipe**.

    ![shows the code. ](images/edited.png =60%x*)


7. The status banner shows "Recipe updated." and the detail panel reflects your change.

8. You just edited a recipe that belongs to someone else. The browser SDK successfully sent the `updateDoc()` request, and the server allowed it because the current security rule is `allow write: if true` — the backend allows any write from any client, with or without authentication.

9. Why this is a problem:

    The app shows the Edit button to every signed-in user, and the backend accepts the update. There is nothing preventing one user from modifying another user's recipes. Hiding the button in the UI would not fix this — a user could still send the update request directly.

## Task 4: Add database security rules

1. Return to the Fusabase console and open the **Database > Security rules** tab.

    ![shows the code. ](images/security1.png =60%x*)


3. Replace the current rule with these rules:

    ```text
    <copy>match /recipes/{recipeId} {
      allow read: if true;
      allow create: if request.auth != null && request.resource.data.ownerId == request.auth.uid;
      allow update: if request.auth != null && request.auth.uid == resource.data.ownerId;
    }
    match /recipes/{recipeId}/ratings/{ratingId} {
      allow read: if true;
      allow create: if request.auth != null;
    }</copy>
    ```

4. Click **Publish changes**.

5. Walk through what each rule does:

    - `allow read: if true` — anyone can read recipes and ratings, even without signing in.
    - `allow create: if request.auth != null && request.resource.data.ownerId == request.auth.uid` — signed-in users can create recipes only when the new document's `ownerId` matches their authenticated user ID. This prevents a browser client from creating a recipe that claims to belong to someone else.
    - `allow update: if request.auth != null && request.auth.uid == resource.data.ownerId` — only the recipe creator can update their own recipe. `resource.data` refers to the existing document's fields, so this rule checks that the authenticated user's `uid` matches the `ownerId` field you saved in Lab 5.
    - The ratings subcollection allows read and create but not update or delete. Ratings are write-once.

6. Why ratings still work for non-owners:

    The ratings subcollection has its own match block — `allow create: if request.auth != null` is enough to let any signed-in user rate any recipe. Lab 5's rating handler is a single write to the ratings subcollection, so the strict update rule on `/recipes/{recipeId}` never gets in the way of rating. The recipe's average rating is computed live in the detail view from the loaded ratings list, which is why no cached aggregate fields exist on the recipe document to keep in sync.

7. Keep these database rule patterns in mind:

    - Security rules support granular methods: `read`, `create`, `update`, and `delete` instead of a blanket `write` rule.
    - `request.auth` reflects the current user's authentication state.
    - `resource.data` accesses the existing document's fields, enabling owner-based access control.
    - Separate match paths let you apply different rules to collections and their subcollections.

## Task 5: Verify security rules block unauthorized edits

1. Return to the browser where the Recipe Share app is running and refresh the page.

2. Sign in if needed.

3. Select the same seed demo recipe you edited in Task 3. The Edit button is still visible — the UI has not changed.

4. Click **Edit**, change a field, and click **Publish recipe**.

5. This time the status banner shows an **error message**. The security rule denied the update because your user ID does not match the recipe's `ownerId`.

    ![shows the code. ](images/blocked.png =60%x*)


6. Now select a recipe that **you** created (one where the Author matches your email). Click **Edit**, change a field, and submit. The update should succeed because your `uid` matches the recipe's `ownerId`.

    ![shows the code. ](images/new-update.png =60%x*)


7. The key lesson:

    The Edit button is visible on every recipe, but security rules on the server decide whether the update is allowed. **Client-side UI checks are a convenience, not a security boundary.** Even if the app hid the Edit button for non-owners, a determined user could still send the update request directly. Security rules are the only reliable enforcement.

## Task 6: Add storage security rules

1. In the Fusabase console, click **Storage** in the left navigation.

2. Click the **Security rules** tab.

3. Replace the current rule with this rule:

    ```text
    <copy>match /recipes/{recipeId}/{fileName} {
      allow read: if true;
      allow create: if request.auth != null;
    }</copy>
    ```

4. Click **Publish changes**.

    ![shows the code. ](images/recipe.png =60%x*)


5. Walk through what this rule does:

    - `match /recipes/{recipeId}/{fileName}` — applies this rule to the same storage path the app uses in Lab 6: `recipes/{recipeId}/{photoFile.name}`.
    - `allow read: if true` — anyone can view uploaded recipe photos.
    - `allow create: if request.auth != null` — only signed-in users can upload new recipe photo files.

6. Keep this storage rule pattern in mind:

    Storage security rules use the same `request.auth` object and conditional syntax as database rules, but they should target file paths and file operations. For uploads, use `create` instead of a broad `write` rule.

## Task 7: Review what you built

1. Take a moment to review everything you built across the workshop:

    - **Lab 1**: Created a local Fusabase environment with a project, authentication, and storage.
    - **Lab 2**: Connected the starter app to your Fusabase project.
    - **Lab 3**: Used `getDocs()`, `query()`, `where()`, `orderBy()`, and `limit()` to query recipe data, then seeded demo data.
    - **Lab 4**: Used `getAuth()`, `createUserWithEmailAndPassword()`, `signInWithEmailAndPassword()`, `signOut()`, and `onAuthStateChanged()` to add authentication.
    - **Lab 5**: Used `collection()`, `addDoc()`, `doc()`, `getDoc()`, and `updateDoc()` to write recipes and ratings as an authenticated user, with `ownerId` for ownership tracking.
    - **Lab 6**: Used `getStorage()`, `ref()`, `uploadBytes()`, and `getDownloadURL()` to add photo upload.
    - **Lab 7**: Used `updateDoc()` to edit existing recipes, discovered that permissive rules let any user modify any document, then configured granular database and storage security rules with owner-based access control.

2. Across Labs 3 through 7, you used SDK calls to query recipes, sign users in and out, create documents, upload files, rate recipes, and edit existing recipes.

3. The Fusabase JavaScript SDK follows the same modular pattern throughout:

    - import the functions you need from the relevant module
    - initialize the service with your app instance
    - call the SDK functions to interact with Fusabase

4. Security rules gave you server-side enforcement:

    - Public reads for browsing
    - Authenticated creates for new content
    - Owner-only updates so users can only edit their own recipes
    - Storage rules that allow public reads and authenticated uploads on the recipe photo path

5. The security rules lab connected the client and server pieces: the browser SDK can attempt a write, but Fusabase rules enforce access control on the server. **Never rely on client-side checks alone for access control.** The UI can guide users, but the server must enforce the rules.

    If the starter app does not work after this lab, navigate to the `checkpoints` folder in your repo, open `app-after-lab-7.js` and `index-after-lab-7.html`, then use those files' contents to replace `starter/scripts/app.js` and `starter/index.html`. Keep your own `starter/fusabase-config.js`.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Contributors** - 
* **Last Updated By/Date** - Killian Lynch, April 2026
