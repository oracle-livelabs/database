# Lab 7: Security Rules

## Introduction

In this lab, you will add an edit-recipe feature and then discover a security vulnerability: any signed-in user can edit any recipe. You will fix this by configuring granular security rules in the Fusabase console that enforce owner-based access control on the server side.

### Objectives

In this lab, you will:

- implement `RecipeService.updateRecipe(...)` so the **Edit** flow in the iOS UI actually writes back
- observe that the permissive rule allows any signed-in user to edit any recipe
- replace the permissive database rule with granular auth-based and owner-based rules
- configure owner-based rules with `request.resource.data.ownerId == request.auth.uid` on create and `request.auth.uid == resource.data.ownerId` on update
- verify that security rules correctly deny unauthorized updates
- add storage security rules that require authentication for uploads

Estimated Time: 15 minutes

## Task 1: Review the current rules

1. Return to the Oracle Backend for Firebase Anywhere console.

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

1. In Xcode's **Project navigator**, expand **RecipeShare > Services** and open `RecipeService.swift`.

2. Find the `updateRecipe(...)` stub at the bottom of the file. It looks like:

    ```swift
    func updateRecipe(
        recipeId: String,
        title: String,
        description: String,
        category: String,
        prepTime: Int?,
        instructions: String,
        ingredients: [String]
    ) async throws {
        // TODO: Implement in Lab 7 — update recipes (and write the security rule)
        throw NSError(
            domain: "RecipeShare",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "RecipeService.updateRecipe — implement in Lab 7."]
        )
    }
    ```

3. Replace the entire function body with this:

    ```swift
    <copy>func updateRecipe(
        recipeId: String,
        title: String,
        description: String,
        category: String,
        prepTime: Int?,
        instructions: String,
        ingredients: [String]
    ) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var fields: [AnyHashable: Any] = [
                "title": title,
                "description": description,
                "category": category,
                "instructions": instructions,
                "ingredients": ingredients
            ]
            if let prepTime {
                fields["prepTime"] = prepTime
            } else {
                // Clear the field when the user removed prep time.
                fields["prepTime"] = NSNull()
            }

            try await db
                .collection("recipes")
                .document(recipeId)
                .updateData(fields)

            // Refresh the published list so the updated values appear.
            try await loadRecipes(category: nil)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }</copy>
    ```

4. Walk through what this function does:

    - Builds a dictionary of just the editable fields. Notice we never touch `ownerId`, `createdBy`, `createdAt`, `averageRating`, `ratingCount`, or `photoURL` — `updateData` is a partial update, so any field you don't include is left alone on the server.
    - When `prepTime` is nil, we explicitly write `NSNull()` to clear the field. This lets a user remove a prep-time value they previously set.
    - `db.collection("recipes").document(recipeId).updateData(fields)` is the same `updateData` you used in `addRecipeRating` (Lab 5).
    - After the write, we call `loadRecipes(category: nil)` to refresh the published list so the UI reflects the edit.
    - The Fusabase iOS SDK can attempt the update, but Fusabase security rules decide whether the server allows it.

5. Save the file.

## Task 3: Edit someone else's recipe

1. Press **Cmd+R** to rebuild and run the app in the Simulator.

2. Sign in with the account you created in Lab 4.

3. Tap any recipe and notice that an **Edit** button appears in the toolbar — on **every** recipe, not just recipes you created.

    ![Recipe detail view showing the Edit button on a seed recipe](images/lemon.png =30%x*)

4. Tap one of the **demo seed recipes** (Avocado Toast, Caprese Salad, Chicken Noodle Soup, Chocolate Chip Cookies). These were created by `seedRecipes` with `ownerId: ""`, so you don't own them.

5. Tap **Edit**. The edit sheet opens with the recipe's current values pre-filled.

6. Change the title to something recognizable (for example, prepend "EDITED — ") and tap **Save**.

    ![Edit sheet with a modified seed-recipe title](images/cookie.png =30%x*)


7. The sheet closes and the recipe list reflects your change. You just edited a recipe that belongs to someone else.

8. Why this happened:

    The iOS SDK successfully sent the `updateData` request, and the server allowed it because the current security rule is `allow write: if true` — the backend allows any write from any client, with or without authentication.

9. Why this is a problem:

    The app shows the Edit button to every signed-in user, and the backend accepts the update. There is nothing preventing one user from modifying another user's recipes. Hiding the button in the UI would not fix this — a user could still send the update request directly through a custom build or proxy.

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

    ![Recipe detail view showing the Edit button on a seed recipe](images/new-rules.png =60%x*)


4. Walk through what each rule does:

    - `allow read: if request.auth != null` — signed-in users can read recipes and ratings. The iOS app gates the recipe browser behind `AuthView` already, so this matches the client's auth model.
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

1. Return to Xcode and press **Cmd+R** to rebuild and run.

2. Sign in if needed.

3. Tap the same seed recipe you edited in Task 3. The **Edit** button is still visible — the UI has not changed.

4. Tap **Edit**, change a field, and tap **Save**.

5. This time the edit fails. The security rule rejected the update because your user ID does not match the recipe's `ownerId` (which is `""` on seed recipes). Scroll down on the recipe you are trying to edit to see the error. 

    ![Recipe list reflecting the edited owned recipe](images/denied.png =30%x*)



6. Now tap a recipe **you** created in Lab 5. Tap **Edit**, change a field, and tap **Save**. The update succeeds because your `uid` matches the recipe's `ownerId`.

    ![Recipe list reflecting the edited owned recipe](images/new.png =30%x*)


7. Confirm in the Fusabase console: open the recipe document under **Database > recipes** and verify the `title` field reflects your edit, while `ownerId`, `createdBy`, and `createdAt` are unchanged.

8. The key lesson:

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

    ![Recipe list reflecting the edited owned recipe](images/storage.png =60%x*)


5. Walk through what this rule does:

    - `match /recipes/{recipeId}/{fileName}` — applies this rule to the same storage path the app uses in Lab 6: `recipes/{recipeId}/{photoFile.name}`.
    - `allow read: if true` — anyone can fetch uploaded recipe photos. The iOS app loads photos via `AsyncImage` from the public URL stamped on each recipe document.
    - `allow create: if request.auth != null` — only signed-in users can upload new recipe photo files.

6. Keep this storage rule pattern in mind:

    Storage security rules use the same `request.auth` object and conditional syntax as database rules, but they target file paths and file operations. For uploads, use `create` instead of a broad `write` rule.

## Summary

Take a moment to look back at what you wrote across the workshop:

- **Lab 1**: Started a local Fusabase environment.
- **Lab 2**: Connected the iOS starter app to your Fusabase project.
- **Lab 3**: Implemented `loadRecipes` with `whereFilter`, `order(by:)`, `limit(to:)`, and `getDocuments()`.
- **Lab 4**: Implemented `signUp`, `signIn`, `signOut`, and the `addStateDidChangeListener` in `AuthService`.
- **Lab 5**: Implemented `createRecipe` and `addRecipeRating` — `addDocument` for the recipe and the rating, plus `updateData` for the running-mean aggregate.
- **Lab 6**: Implemented `uploadRecipePhoto` — Storage upload via continuation, `downloadURL()`, then `updateData` to write the URL onto the recipe.
- **Lab 7**: Implemented `updateRecipe` to edit existing recipes, discovered that permissive rules let any signed-in user modify any document, then configured granular database and storage security rules with owner-based access control.

Every line of code you wrote was service code in two files: `AuthService.swift` and `RecipeService.swift`. The Models, Views, and app root were pre-built — your job was the SDK boundary.

The Fusabase iOS SDK follows the same shape across modules:

- `FusabaseAuth.auth().{createUser, signIn, signOut, addStateDidChangeListener}`
- `FusabaseOracledb.oracledb().collection(...).{getDocuments, addDocument, updateData}`
- `FusabaseStorage.Storage.storage().reference().{putData, downloadURL}`

Security rules gave you server-side enforcement:

- Authenticated reads for browsing
- Authenticated creates with owner stamping for new content
- Owner-only updates so users can only edit their own recipes
- Storage rules that allow public reads of recipe photos and require authentication for uploads

The security rules lab connected the client and server pieces: the iOS SDK can attempt a write, but Fusabase rules enforce access control on the server. **Never rely on client-side checks alone for access control.** The UI can guide users, but the server must enforce the rules.

## Appendix

### Troubleshooting

- **"Save throws permission-denied for a recipe I created."** The `ownerId` on the recipe doesn't match your current `uid`. Most likely cause: you created the recipe under a different account. Sign in as the original creator, or check the recipe document in the console.

- **"Save throws 'Not yet implemented'."** You replaced the body of `updateRecipe` but didn't save the file, or you replaced the wrong stub. Confirm the title bar in Xcode shows no unsaved-changes dot.

- **"Task 3 edit succeeded but Task 5 still works on the seed recipe."** Confirm you clicked **Publish changes** in the Fusabase console after pasting the new rule. The console keeps draft and published rules separate, so an unpublished rule won't take effect.

- **"I want to test the rule directly."** The Fusabase console has a Rules Playground tab where you can simulate `update` requests with different `auth.uid` values and see whether the rule allows or denies them. Useful for sanity-checking before publishing.

> **Want a clean copy?**
>
> A copy of `RecipeService.swift` as it should look after this lab is available at `checkpoints/RecipeService-after-lab-7.swift`. Drop it into `starter/RecipeShare/Services/` any time you'd like a fresh baseline before moving on. Keep your own `starter/RecipeShare/Resources/fusabase-config.json` — checkpoints don't include your project config.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Last Updated By/Date** - Killian Lynch, May 2026
