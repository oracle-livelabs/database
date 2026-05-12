# Lab 5: Write Recipe Data

## Introduction

In this lab, you will implement the two write methods that turn the recipe list into a real social app: `createRecipe` for new recipes (stamped with the authenticated user's `ownerId`) and `addRating` for the per-recipe `ratings` subcollection.

Both methods live in `RecipeRepository.java`. The Fragments calling these methods — `CreateRecipeFragment` for new recipes, `RecipeDetailFragment` for ratings — are already wired and will start working the moment you fill in the SDK calls.

### Objectives

In this lab, you will:

- Build a write payload from a `Recipe` POJO and the current authenticated user
- Call `db.collection("recipes").add(map)` to create a new document with an auto-generated ID
- Write to the `ratings` subcollection nested under a specific recipe
- Surface the new document ID back to the caller through `OnResultListener`

Estimated Time: 10 minutes

## Task 1: Implement createRecipe

1. Open `RecipeRepository.java` and find the `createRecipe(Recipe draft, OnResultListener<String> cb)` stub.

2. Replace the body with this:

    ```java
    <copy>public void createRecipe(Recipe draft, OnResultListener<String> cb) {
        FusabaseUser user = authRepo.getCurrentUser().getValue();
        String ownerId = user != null ? user.getUid() : "";
        String createdBy = user != null && user.getEmail() != null ? user.getEmail() : "";

        Map<String, Object> data = new HashMap<>();
        data.put("title", draft.getTitle());
        data.put("description", draft.getDescription());
        data.put("category", draft.getCategory());
        data.put("instructions", draft.getInstructions());
        data.put("ingredients", draft.getIngredients());
        data.put("createdAt", System.currentTimeMillis());
        data.put("averageRating", 0.0);
        data.put("ratingCount", 0L);
        data.put("ownerId", ownerId);
        data.put("createdBy", createdBy);
        if (draft.getPrepTime() != null) {
            data.put("prepTime", draft.getPrepTime());
        }

        db.collection("recipes").add(data)
                .addOnSuccessListener(ref -> cb.onSuccess(ref.getId()))
                .addOnFailureListener(cb::onFailure);
    }</copy>
    ```

3. Add the import:

    ```java
    <copy>import com.oracle.mobile.fusabase.auth.FusabaseUser;</copy>
    ```

4. Walk through what the code does:

    - You read the current authenticated user from `AuthRepository`. If somehow the user is null (the form fragment guards against that), you fall back to empty strings — the security rules in Lab 7 will reject those writes anyway.
    - `user.getUid()` is the stable user ID. You stamp it as `ownerId` so the security rule in Lab 7 has something to compare against.
    - `user.getEmail()` is what the UI displays as `createdBy` next to ratings and recipe attributions.
    - The map builds the document fields. Note that `prepTime` is added conditionally — when the user leaves it empty, you omit the field rather than writing `null`.
    - `db.collection("recipes").add(data)` writes a new document with an auto-generated ID. It returns a `Task<DocumentReference>` so you can read that ID after the write completes.
    - On success, you pass `ref.getId()` back to the caller through `OnResultListener.onSuccess`. `CreateRecipeFragment` uses this ID in Lab 6 when it uploads a photo for the freshly created recipe.

5. Note what you don't do here:

    - You don't manually refresh `recipes` LiveData. The snapshot listener you attached in Lab 4 sees the new row and updates the list automatically.
    - You don't pop the navigation stack. `CreateRecipeFragment` does that after `onSuccess` (or after the photo upload finishes in Lab 6).
    - You don't validate the email format or the password length; the form fragment does that on the client side and the SDK does it on the server side.

## Task 2: Implement addRating

1. Find the `addRating(...)` stub. It accepts the recipe ID, the rating value (1-5), an optional comment, and a callback.

2. Replace the body with this:

    ```java
    <copy>public void addRating(String recipeId, int value, @Nullable String comment,
                          OnResultListener<Void> cb) {
        FusabaseUser user = authRepo.getCurrentUser().getValue();
        String author = user != null && user.getEmail() != null ? user.getEmail() : "anonymous";

        Map<String, Object> data = new HashMap<>();
        data.put("author", author);
        data.put("rating", value);
        if (comment != null && !comment.isEmpty()) {
            data.put("comment", comment);
        }

        db.collection("recipes").document(recipeId).collection("ratings").add(data)
                .addOnSuccessListener(ref -> cb.onSuccess(null))
                .addOnFailureListener(cb::onFailure);
    }</copy>
    ```

3. Walk through what the code does:

    - The path `recipes/{recipeId}/ratings` is a subcollection. Subcollections behave like top-level collections — `add`, `document(id)`, `addSnapshotListener`, all of it works.
    - You stamp `author` from the email so the rating displays a recognizable name. You don't stamp an `ownerId` here because ratings are write-once: nobody updates a rating, only adds new ones.
    - The recipe document's `averageRating` and `ratingCount` fields are not touched by this write. They live on the recipe doc but are computed from the live ratings list inside `RecipeDetailFragment`. Keeping them out of the write path means the rating flow stays compatible with the owner-only update rule you'll add in Lab 7.

4. The `ratingsListener` you attached in Lab 4 (the subcollection listener inside `startListeningToRecipe`) sees this write in real time. The detail screen's ratings list re-renders with the new entry immediately.

## Task 3: Run and verify

1. Save the file. Click **Run**.

    ![New recipe form](images/run.png =30%x*)


2. Sign in. The recipe list shows the four demo recipes you seeded in Lab 4.

3. Tap the **+** floating action button. The **New recipe** form opens.

    ![New recipe form](images/add.png =30%x*)



4. Fill in the form:

    - Title: "Garlic Butter Shrimp"
    - Description: "Quick weeknight dinner with shrimp tossed in garlic butter and parsley."
    - Category: Dinner
    - Prep time: 20
    - Ingredients: tap **Add ingredient** to add rows for "1 lb large shrimp", "4 tbsp butter", "4 cloves garlic", "1/4 cup parsley", "1 lemon"
    - Instructions: "Melt butter in a skillet over medium-high heat. Add minced garlic and cook for 30 seconds. Add shrimp and cook 2-3 minutes per side until pink. Finish with chopped parsley and a squeeze of lemon."

        ![New recipe form](images/task-3-new-recipe-form.png =30%x*)


5. Tap **Save**. The form closes and you're back on the recipe list — with your new recipe at the top, ahead of all four seeds.

    ![Recipe list with the new shrimp recipe at top](images/task-3-list-with-new-recipe.png =30%x*)

6. Tap your new recipe. The detail screen renders ingredients, instructions, and the rating form.

7. Enter `5` in the **Stars** field, leave the comment empty, and tap **Submit rating**. The new rating appears in the **Ratings** list within a second.

    ![Recipe detail with one rating added](images/task-3-with-rating.png =30%x*)

8. Add a second rating with `4` stars and a comment ("Great with crusty bread"). The list now has two entries.

9. Verify in the Fusabase console: open **Database**, click into the `recipes` collection, find your new shrimp recipe, and click into its `ratings` subcollection. Both rating documents are there with `author`, `rating`, and (for the second) `comment`.

    ![Fusabase console showing the ratings subcollection](images/ratings.png =85%x*)

## Summary

Two methods, ~25 lines of SDK code combined. The Fusabase write API stays consistent across collection levels:

- `db.collection("recipes").add(map)` — top-level collection, auto-id.
- `db.collection("recipes").document(id).collection("ratings").add(map)` — subcollection, auto-id.

The pattern for writes that need to know the new document ID is `addOnSuccessListener(ref -> ref.getId())`. The pattern for writes where you only care about success/failure is `addOnSuccessListener(v -> cb.onSuccess(null))`.

Two patterns worth internalizing:

- **The active listener is the source of truth.** You wrote two new documents in this lab and never told the UI to refresh. The snapshot listeners from Lab 4 picked up both writes and propagated them.
- **Authenticated user state stamps writes.** The current user's `uid` and `email` end up on the document. This is how the security rules in Lab 7 will enforce ownership.

> **Want a clean copy?**
>
> A copy of `RecipeRepository.java` as it should look after this lab is available at `checkpoints/RecipeRepository-after-lab-5.java`.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Last Updated By/Date** - Killian Lynch, May 2026
