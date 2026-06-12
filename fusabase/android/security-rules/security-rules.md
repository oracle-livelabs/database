# Lab 7: Security Rules

## Introduction

In this lab, you will add an edit-recipe feature and then discover a security vulnerability: any signed-in user can edit any recipe — even ones they didn't create. You will fix this by configuring granular security rules in the Fusabase console that enforce owner-based access control on the server side.

### Objectives

In this lab, you will:

- Implement `RecipeRepository.updateRecipe(...)` so the **Edit** flow actually writes back
- Observe that the permissive rule allows any signed-in user to edit any recipe
- Replace the permissive database rule with granular auth-based and owner-based rules
- Configure owner-based rules with `request.resource.data.ownerId == request.auth.uid` on create and `request.auth.uid == resource.data.ownerId` on update
- Verify that security rules correctly deny unauthorized updates
- Add storage security rules that require authentication for uploads

Estimated Time: 15 minutes

### Prerequisites

This lab assumes you have:

- Successfully completed all previous labs.

## Task 1: Review the current rules

1. Return to the Fusabase console.

2. Open your project, then click **Database** in the left navigation.

3. Click the **Security rules** tab.

    ![Security rules tab in the Fusabase console](images/rules.png =60%x*)

4. You should see the permissive rule from Lab 1:

    ```text
    match /{document=**} { allow read, write: if true;}
    ```

    This rule allows any client to read and write any document, with or without authentication. Fine for getting started, but not safe for production.

5. Why this matters in Fusabase:

    Security rules are the server-side access control layer. Even though the SDK runs on the device, every read and write passes through Fusabase, where security rules decide whether to allow or deny the operation.

## Task 2: Implement updateRecipe

1. In Android Studio, expand `app/src/main/java/com/oracle/fusabase/recipeshare/recipes/` and open `RecipeRepository.java`.

2. Find the `updateRecipe(...)` stub at the bottom of the file. It looks like:

    ```java
    public void updateRecipe(String recipeId, Recipe draft, OnResultListener<Void> cb) {
        // TODO Lab 7
        cb.onFailure(new UnsupportedOperationException(
                "RecipeRepository.updateRecipe — implement in Lab 7."));
    }
    ```

3. Replace the body with this:

    ```java
    <copy>public void updateRecipe(String recipeId, Recipe draft, OnResultListener<Void> cb) {
        Map<String, Object> patch = new HashMap<>();
        patch.put("title", draft.getTitle());
        patch.put("description", draft.getDescription());
        patch.put("category", draft.getCategory());
        patch.put("instructions", draft.getInstructions());
        patch.put("ingredients", draft.getIngredients());
        if (draft.getPrepTime() != null) {
            patch.put("prepTime", draft.getPrepTime());
        } else {
            patch.put("prepTime", null);
        }

        db.collection("recipes").document(recipeId).update(patch)
                .addOnSuccessListener(v -> cb.onSuccess(null))
                .addOnFailureListener(cb::onFailure);
    }</copy>
    ```

4. Walk through what the code does:

    - Builds a patch map of just the editable fields. You never touch `ownerId`, `createdBy`, `createdAt`, `averageRating`, `ratingCount`, or `photoURL` — `update` is a partial write, so any field you don't include is left alone on the server.
    - When `prepTime` is null (the user cleared the value), you write `null` explicitly so the field is removed.
    - `db.collection("recipes").document(recipeId).update(map)` is the same `update` call you used in Lab 6 to stamp `photoURL` after a photo upload.
    - The Fusabase Android SDK can attempt the update, but Fusabase security rules decide whether the server allows it. That's the whole topic of this lab.

5. Save the file.

## Task 3: Edit someone else's recipe

1. Click **Run** to redeploy.

2. Sign in with the account you've been using.

3. Tap any recipe and notice that an **Edit** action appears in the toolbar overflow — on **every** recipe, not just recipes you created.

    ![Recipe detail view showing the Edit menu item on a seed recipe](images/lemon.png =30%x*)

4. Tap one of the **demo seed recipes** (Avocado Toast, Caprese Salad, Chicken Noodle Soup, Chocolate Chip Cookies). These were created by `seedDemoRecipes` with `ownerId = ""`, so you don't own them.

5. Open the overflow menu and tap **Edit**. The edit form opens with the recipe's current values pre-filled.

6. Change the title to something recognizable (for example, prepend "EDITED — ") and tap **Save**.

    ![Edit form with a modified seed-recipe title](images/cookie.png =30%x*)

7. The form closes and the recipe list reflects your change. **You just edited a recipe that belongs to someone else.**

8. Why this happened:

    The Android SDK successfully sent the `update` request, and the server allowed it because the current security rule is `allow write: if true` — the backend allows any write from any client, with or without authentication.

9. Why this is a problem:

    The app shows the **Edit** menu item to every signed-in user, and the backend accepts the update. There is nothing preventing one user from modifying another user's recipes. Hiding the menu item in the UI would not fix this — a user could still send the update request directly through a custom build or proxy.

## Task 4: Add database security rules

1. Return to the Fusabase console and open the **Database > Security rules** tab.

2. Replace the current rule with these rules:

    ```text
    <copy>match /recipes/{recipeId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null && request.resource.data.ownerId == request.auth.uid;
        allow update: if request.auth != null && request.auth.uid == resource.data.ownerId;
    }
    match /recipes/{recipeId}/ratings/{ratingId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null;
    }</copy>
    ```

3. Click **Publish changes**.

    ![Recipe detail view showing the new rules in the console](images/new-rules.png =60%x*)


4. Walk through what each rule does:

    - `allow read: if request.auth != null` — signed-in users can read recipes and ratings. The Android app gates the recipe browser behind `AuthFragment` already, so this matches the client's auth model.
    - `allow create: if request.auth != null && request.resource.data.ownerId == request.auth.uid` — signed-in users can create recipes only when the new document's `ownerId` matches their authenticated user ID. This prevents a client from creating a recipe that claims to belong to someone else.
    - `allow update: if request.auth != null && request.auth.uid == resource.data.ownerId` — only the recipe creator can update their own recipe. `resource.data` refers to the existing document's fields, so this rule checks that the authenticated user's `uid` matches the `ownerId` field stamped by `createRecipe` in Lab 5.
    - The ratings subcollection allows read and create but not update or delete. Ratings are write-once.

5. Keep these database rule patterns in mind:

    - Security rules support granular methods: `read`, `create`, `update`, and `delete` instead of a blanket `write` rule.
    - `request.auth` reflects the current user's authentication state.
    - `resource.data` accesses the existing document's fields, enabling owner-based access control on updates.
    - `request.resource.data` accesses the document state after the proposed write — useful for `create` rules that need to validate fields the client is sending.
    - Separate match paths let you apply different rules to collections and their subcollections.

## Task 5: Verify security rules block unauthorized edits

1. Return to Android Studio and click **Run** to relaunch.

2. Sign in if needed.

3. Tap the same seed recipe you edited in Task 3. The **Edit** menu item is still visible — the UI has not changed.

4. Open the overflow, tap **Edit**, change a field, and tap **Save**.

5. This time the edit fails. The security rule rejected the update because your user ID does not match the recipe's `ownerId` (which is `""` on seed recipes). A Snackbar appears at the bottom with the SDK's permission-denied message.

    ![Edit form showing a permission-denied Snackbar](images/denied.png =30%x*)


6. Now tap a recipe **you** created in Lab 5. Open the overflow, tap **Edit**, change a field, and tap **Save**. The update succeeds because your `uid` matches the recipe's `ownerId`.

    ![Recipe list reflecting the edited owned recipe](images/new.png =30%x*)


7. Confirm in the Fusabase console: open the recipe document under **Database > recipes** and verify the `title` field reflects your edit, while `ownerId`, `createdBy`, and `createdAt` are unchanged.

8. The key lesson:

    The Edit menu item is visible on every recipe, but security rules on the server decide whether the update is allowed. **Client-side UI checks are a convenience, not a security boundary.** Even if the app hid the Edit menu for non-owners, a determined user could still send the update request directly. Security rules are the only reliable enforcement.

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

    ![Storage security rules tab with the new rule published](images/storage.png =60%x*)


5. Walk through what this rule does:

    - `match /recipes/{recipeId}/{fileName}` — applies this rule to the same storage path the app uses in Lab 6: `recipes/{recipeId}/{uuid}.jpg`.
    - `allow read: if true` — anyone can fetch uploaded recipe photos. The Android app loads photos via Glide from the public URL stamped on each recipe document.
    - `allow create: if request.auth != null` — only signed-in users can upload new recipe photo files.

6. Keep this storage rule pattern in mind:

    Storage security rules use the same `request.auth` object and conditional syntax as database rules, but they target file paths and file operations. For uploads, use `create` instead of a broad `write` rule.

## Summary

Take a moment to look back at what you wrote across the workshop:

- **Lab 1**: Started a local Fusabase environment.
- **Lab 2**: Connected the Android starter project to your Fusabase project.
- **Lab 3**: Implemented `signUp`, `signIn`, `signOut`, and `addAuthStateListener` in `AuthRepository`.
- **Lab 4**: Implemented snapshot listeners on the `recipes` collection and on the single recipe document plus its `ratings` subcollection — with `ListenerRegistration.remove()` cleanup.
- **Lab 5**: Implemented `createRecipe` and `addRating` — `add(map)` for the recipe and the rating, stamped with the authenticated user's `uid` and `email`.
- **Lab 6**: Implemented `uploadRecipePhoto` — Storage upload via `putBytes`, `getDownloadUrl`, then `update("photoURL", ...)` to write the URL onto the recipe.
- **Lab 7**: Implemented `updateRecipe` to edit existing recipes, discovered that permissive rules let any signed-in user modify any document, then configured granular database and storage security rules with owner-based access control.

Every line of code you wrote was repository code in two files: `AuthRepository.java` and `RecipeRepository.java`. The Models, Fragments, layouts, navigation graph, and Application class were pre-built — your job was the SDK boundary.

The Fusabase Android SDK follows the same shape across modules:

- `FusabaseAuth.getInstance().{createUserWithEmailAndPassword, signInWithEmailAndPassword, signOut, addAuthStateListener}`
- `FusabaseOracledb.getInstance().collection(...).{addSnapshotListener, add, update, document(...).update}`
- `Storage.getInstance().getReference().child(path).{putBytes, getDownloadUrl}`

Security rules gave you server-side enforcement:

- Authenticated reads for browsing
- Authenticated creates with owner stamping for new content
- Owner-only updates so users can only edit their own recipes
- Storage rules that allow public reads of recipe photos and require authentication for uploads

The security rules lab connected the client and server pieces: the Android SDK can attempt a write, but Fusabase rules enforce access control on the server. **Never rely on client-side checks alone for access control.** The UI can guide users, but the server must enforce the rules.

## Appendix

### Troubleshooting

- **"Save shows a permission-denied Snackbar for a recipe I created."** The `ownerId` on the recipe doesn't match your current `uid`. Most likely cause: you created the recipe under a different account. Sign in as the original creator, or check the recipe document in the console.

- **"Save throws 'Not yet implemented'."** You replaced the body of `updateRecipe` but didn't save the file, or you replaced the wrong stub. Confirm Android Studio has no unsaved-changes indicator on the file tab.

- **"Task 3 edit succeeded but Task 5 still works on the seed recipe."** Confirm you clicked **Publish changes** in the Fusabase console after pasting the new rule. The console keeps draft and published rules separate, so an unpublished rule won't take effect.

- **"I want to test the rule directly."** The Fusabase console has a **Rules Playground** tab where you can simulate `update` requests with different `auth.uid` values and see whether the rule allows or denies them. Useful for sanity-checking before publishing.

> **Want a clean copy?**
>
> A copy of `RecipeRepository.java` as it should look after this lab is available at `checkpoints/RecipeRepository-after-lab-7.java`. Drop it into `starter/RecipeShare/app/src/main/java/com/oracle/fusabase/recipeshare/recipes/` any time you'd like a fresh baseline. Keep your own `app/fusabase-config.json` — checkpoints don't include your project config.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Last Updated By/Date** - Killian Lynch, May 2026
