# Lab 5: Write Recipe Data

## Introduction

In this lab, you will implement the write operations for RecipeShare. Now that authentication works from Lab 4, the create-recipe sheet and the rate-recipe form are tied to a real signed-in user. You'll fill in the two service methods that power those forms — writing a new recipe document, and writing a rating into a subcollection while updating the parent recipe's aggregate fields.

### Objectives

In this lab, you will:

- implement `RecipeService.createRecipe(...)` to write a new recipe document with ownership tracking
- implement `RecipeService.addRecipeRating(...)` to write ratings to a subcollection and update aggregate values
- create a recipe and add a rating in the running app to verify both writes

Estimated Time: 12 minutes

## Task 1: Open the service file

1. In Xcode's **Project navigator**, expand **RecipeShare > Services** and open `RecipeService.swift`.

    This is the same file you edited in Lab 4. The `loadRecipes` method you wrote there is still in place — you'll add two new methods alongside it.

## Task 2: Implement createRecipe

1. Find the `createRecipe(...)` stub. It will be toward the bottom of the file. It looks like:

    ```swift
    func createRecipe(
        title: String,
        description: String,
        category: String,
        prepTime: Int?,
        instructions: String,
        ingredients: [String]
    ) async throws -> String {
        // TODO: implement in Lab 5
        throw NSError(
            domain: "RecipeShare",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Not yet implemented (Lab 5)."]
        )
    }
    ```

2. Replace the entire function body with this:

    ```swift
    <copy>func createRecipe(
        title: String,
        description: String,
        category: String,
        prepTime: Int?,
        instructions: String,
        ingredients: [String]
    ) async throws -> String {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let user = authService.user
            let ownerId = user?.uid ?? ""
            let createdBy = user?.email ?? ""

            var data: [String: Any] = [
                "title": title,
                "description": description,
                "category": category,
                "instructions": instructions,
                "ingredients": ingredients,
                "createdAt": Date().timeIntervalSince1970 * 1000.0,
                "averageRating": 0,
                "ratingCount": 0,
                "ownerId": ownerId,
                "createdBy": createdBy
            ]
            if let prepTime {
                data["prepTime"] = prepTime
            }

            let ref = try await db.collection("recipes").addDocument(data: data)
            let newId = ref.documentID

            // Refresh the published list so the new recipe appears immediately.
            try await loadRecipes(category: nil)

            return newId
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }</copy>
    ```

    ![Rating sheet with 4 stars selected and a short comment](images/create.gif =60%x*)



3. Walk through what this function does:

    - `db.collection("recipes")` points at the same `recipes` collection you read in Lab 3.
    - `addDocument(data:)` creates a new document in that collection with an auto-generated ID, and returns a `DocumentReference` to it. We pull `documentID` off the reference so the caller (the create-recipe sheet) can use it for the photo upload in Lab 6.
    - The dictionary includes the form data plus default values for `averageRating`, `ratingCount`, and `createdAt`.
    - `createdAt` is written as milliseconds-since-epoch (a `Double`) so the value matches the web workshop's `Date.now()` format. Your `loadRecipes` query orders by this field so the new recipe appears at the top of the list.
    - `ownerId: user?.uid ?? ""` stores the signed-in user's unique ID. You'll use this field in Lab 7 to enforce a security rule that only allows the recipe creator to edit their own recipes.
    - `createdBy: user?.email ?? ""` stores the signed-in user's email. This is what the recipe detail view shows under "By:".
    - After the write succeeds, we call `loadRecipes(category: nil)` so the published `recipes` array picks up the new document immediately.

4. Save the file.

## Task 3: Implement addRecipeRating

1. Find the `addRecipeRating(...)` stub. This is right below the create Recipe stub.

    ```swift
    func addRecipeRating(
        recipeId: String,
        rating: Int,
        comment: String?
    ) async throws {
        // TODO: Implement in Lab 5 — write recipe data
        // See: workshop/write-recipe-data/write-recipe-data.md
        throw NSError(
            domain: "RecipeShare",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "RecipeService.addRecipeRating — implement in Lab 5."]
        )
    }
    ```

2. Replace the body with this:

    ```swift
    <copy>func addRecipeRating(
        recipeId: String,
        rating: Int,
        comment: String?
    ) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let author = authService.user?.email ?? "anonymous"

            // 1. Write the rating into the subcollection.
            var ratingData: [String: Any] = [
                "author": author,
                "rating": rating,
                "createdAt": Date().timeIntervalSince1970 * 1000.0
            ]
            if let comment, !comment.isEmpty {
                ratingData["comment"] = comment
            }

            let recipeRef = db.collection("recipes").document(recipeId)
            _ = try await recipeRef.collection("ratings").addDocument(data: ratingData)

            // 2. Read parent recipe to recompute aggregates.
            let snap = try await recipeRef.getDocument()
            let data = snap.data() ?? [:]
            let oldAvg = (data["averageRating"] as? Double) ?? 0
            let oldCount = (data["ratingCount"] as? Int) ?? 0

            let newCount = oldCount + 1
            let newAvg = (oldAvg * Double(oldCount) + Double(rating)) / Double(newCount)

            // 3. Write the new aggregates back to the parent.
            try await recipeRef.updateData([
                "averageRating": newAvg,
                "ratingCount": newCount
            ])

            // Refresh the published list so the updated rating summary appears.
            try await loadRecipes(category: nil)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }</copy>
    ```

3. Walk through the three writes:

    - `db.collection("recipes").document(recipeId)` creates a reference to a specific recipe document by ID.
    - `recipeRef.collection("ratings").addDocument(data: ratingData)` writes the rating into a `ratings` subcollection nested under that recipe. Subcollections are how Fusabase stores related records under a parent document.
    - `recipeRef.getDocument()` reads the parent recipe back so we can recompute the running average. The aggregation formula is `newAvg = (oldAvg * oldCount + rating) / (oldCount + 1)`.
    - `recipeRef.updateData(...)` performs a partial update — only `averageRating` and `ratingCount` change; the other fields (title, description, ownerId, etc.) stay untouched.
    - `addDocument` and `updateData` are the two write primitives you'll see throughout the SDK: `addDocument` creates a new document, `updateData` modifies fields on an existing one.


4. Save the file.

## Task 4: Create a recipe and add a rating

1. Press **Cmd+R** to build and run.

2. Sign in with the account you created in Lab 4.

3. Tap the **+** button in the toolbar to open the create-recipe sheet.

    ![Create recipe sheet with empty fields](images/task-4-create-sheet.png =30%x*)


4. Fill in the form. Copy each value below into the matching field — or substitute your own recipe.

    Title:

    ```text
    <copy>Spaghetti Carbonara</copy>
    ```

    Description:

    ```text
    <copy>A classic Roman pasta with eggs, pecorino, guanciale, and black pepper — no cream.</copy>
    ```

    Category: pick **Dinner**.

    Prep time:

    ```text
    <copy>30</copy>
    ```

    Ingredients:

    ```text
    <copy>200g spaghetti
    100g guanciale (or pancetta), diced
    2 large eggs
    1 egg yolk
    50g pecorino romano, finely grated
    Freshly ground black pepper
    Salt for the pasta water</copy>
    ```

    Instructions:

    ```text
    <copy>Bring a large pot of salted water to a boil and cook the spaghetti until al dente.
    While the pasta cooks, render the guanciale in a dry pan over medium heat until crisp.
    In a bowl, whisk the eggs, yolk, and pecorino with plenty of black pepper.
    Reserve a cup of pasta water, then drain the pasta and add it to the pan with the guanciale.
    Off the heat, pour in the egg mixture and toss quickly, loosening with a splash of pasta water until silky.
    Serve immediately with extra pecorino and pepper on top.</copy>
    ```

    Skip the **Choose Photo** field for now — you'll wire photo upload in Lab 6.

5. Tap **Save**.

    ![Rating sheet with 4 stars selected and a short comment](images/dinner.gif =30%x*)


    The sheet closes, and your new recipe appears at the top of the recipe list (newest first, because of the `createdAt` ordering you wrote in Lab 3).

6. Tap the new recipe to open the detail view. It should show your title, description, prep time, instructions, and `By: <your email>`

7. Tap **Rate this recipe** (or the star/rate button — exact label per the pre-built `RecipeDetailView`). Pick a rating (e.g. 4 stars) and an optional comment, then submit.

    ![Rating sheet with 4 stars selected and a short comment](images/task-4-rating-sheet.png =30%x*)


8. The detail view updates to show the new rating in the list and the average rating ticks up. Pop back to the recipe list — the rating summary on the row should reflect your new average.

9. In the Fusabase console, navigate to **Database > recipes**. Find your new recipe, expand it, and confirm:

    - the document has `createdBy` set to your email and `ownerId` set to your auth uid
    - the `ratings` subcollection contains your new rating
    - the parent's `averageRating` and `ratingCount` reflect your write

    ![Fusabase console showing the new recipe document with its ratings subcollection expanded](images/review.gif =60%x*)


10. Leave the app and console open for the next lab.

## Appendix

### Troubleshooting

- **"Save throws 'Not yet implemented (Lab 5)'."** The starter stub for `createRecipe` throws an `NSError` so the project compiles before you fill it in. If you still see that error after editing, you didn't save the file — confirm the title bar shows no unsaved-changes dot, then rebuild.

- **"Recipe creates but doesn't appear in the list."** Make sure you kept the `try await loadRecipes(category: nil)` line at the end of `createRecipe`. The list view binds to `self.recipes`; without the refresh, the new document is in the database but the in-memory array is stale.

- **"Average rating drifts to a weird decimal."** That's just floating-point arithmetic on a running mean. The web workshop rounds to one decimal place; we don't, because the iOS detail view formats the display value with `%.1f`. The stored field is the unrounded `Double` — that's fine.

- **"Tapping Rate does nothing or throws."** Confirm you replaced the entire body of `addRecipeRating`. The starter stub is `// TODO: implement in Lab 5` and silently returns; the rate sheet swallows the empty result and looks like a no-op.

> **Want a clean copy?**
>
> A copy of `RecipeService.swift` as it should look after this lab is available at `checkpoints/RecipeService-after-lab-5.swift`. Drop it into `starter/RecipeShare/Services/` any time you'd like a fresh baseline before moving on. Keep your own `starter/RecipeShare/Resources/fusabase-config.json` — checkpoints don't include your project config.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Last Updated By/Date** - Killian Lynch, May 2026
