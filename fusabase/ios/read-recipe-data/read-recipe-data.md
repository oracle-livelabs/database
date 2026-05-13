# Lab 4: Read Recipe Data

## Introduction

In this lab, you will use the Oracle Backend for Firebase Anywhere (Fusabase) iOS SDK to query recipe data and display it in the app. You will implement a single async function that reads from the `recipes` collection with optional category filtering, then verify the read end-to-end by tapping the in-app "Add Sample Recipes" button.

### Objectives

In this lab, you will:

- implement `RecipeService.loadRecipes(category:)` to query recipes with category filtering and sorting
- seed the demo data using the built-in **Add Sample Recipes** button
- verify that recipes appear in the list and that category pills filter correctly

Estimated Time: 12 minutes

### Prerequisites

This lab assumes you have:

- Successfully completed all previous labs.

## Task 1: Open the service file

1. In Xcode's **Project navigator** (the left sidebar), expand **RecipeShare > Services** and open `RecipeService.swift`.

    This is the file you will return to in Labs 5, 6, and 7. You fill in one method in this lab; the other lab methods are still stubs.

    ![Xcode project navigator with Services > RecipeService.swift selected](images/task-1-open-service.png =60%x*)


2. Fusabase is organized into collections, documents, fields, and subcollections. The app stores each recipe as a document in a top-level collection called `recipes`. Later, each rating is stored in a subcollection called `ratings` under each recipe.

    ![Recipe Share data model showing the recipes collection, recipe document fields, ratings subcollection, and rating document](images/recipe-share-data-model.svg =45%x*)


## Task 2: Implement loadRecipes

1. Find the `loadRecipes(category:)` stub. It looks like:

    ```swift
    func loadRecipes(category: String?) async throws {
        // TODO: Implement in Lab 4 — read and recipe data
        // See: workshop/read-recipe-data/read-recipe-data.md
        throw NSError(
            domain: "RecipeShare",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "RecipeService.loadRecipes — implement in Lab 4."]
        )
    }
    ```

2. Replace the entire function body with this:

    ```swift
    <copy>func loadRecipes(category: String?) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var query: Query = db.collection("recipes")
            if let category {
                query = query.whereFilter(
                    Filter(field: "category", op: "==", value: category)
                )
            }
            query = query
                .order(by: "createdAt", descending: true)
                .limit(to: 24)

            let snapshot = try await query.getDocuments()
            let mapped: [Recipe] = snapshot.documents.compactMap { doc in
                Recipe(documentID: doc.documentID, data: doc.data() ?? [:])
            }
            self.recipes = mapped
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }</copy>
    ```

    ![Recipe Share data model showing the recipes collection, recipe document fields, ratings subcollection, and rating document](images/read.png =60%x*)


3. Walk through how the SDK query works:

    - `db.collection("recipes")` creates a reference to the top-level `recipes` collection. This tells the SDK where to read from.
    - `whereFilter(Filter(field: "category", op: "==", value: category))` adds a filter only when the user picked a category. If `category` is nil, that filter is skipped and the query reads all recipes.
    - `order(by: "createdAt", descending: true)` sorts the results so the newest recipes appear first.
    - `limit(to: 24)` keeps the query bounded so the app reads a reasonable number of recipe documents.
    - `getDocuments()` runs the query once and returns a `QuerySnapshot` with the matching documents.
    - The `compactMap` turns each SDK document snapshot into a `Recipe` value the SwiftUI views can render. `Recipe(documentID:data:)` is a failable initializer pre-built in `Models/Recipe.swift`, so any malformed document is silently dropped.


4. Save the file (**Cmd+S**).

## Task 3: Seed demo data and verify

1. Press **Cmd+R** to build and run. You should still be signed in from Lab 3 — the app opens directly on the recipe list. (If you signed out, sign back in.)

2. The list shows "No recipes yet" with an **Add Sample Recipes** button. The database is empty — that's expected.

    ![Empty recipe list with the Add Sample Recipes button](images/task-3-empty-list.png =30%x*)


4. Tap **Add Sample Recipes**.

    The button calls a pre-built `seedRecipes()` helper that writes four demo recipes to the `recipes` collection — Avocado Toast, Caprese Salad, Chicken Noodle Soup, and Chocolate Chip Cookies. After the writes complete, it calls your new `loadRecipes(category: nil)` to refresh the list. You will learn writing data in the next lab.

5. The recipe list now shows the four demo recipes (newest first).

    ![Recipe list populated with four demo recipes](images/task-3-seeded-list.png =30%x*)


6. Tap a category pill (for example, **Breakfast**). The list filters to just the matching recipes.

    Behind the scenes, the view re-invokes `loadRecipes(category: "Breakfast")`, your function adds the `whereFilter` clause, and the SDK returns only the matching documents.

    ![Recipe list filtered to Breakfast](images/task-3-filtered-list.png =30%x*)

7. Tap **All** and confirm the full list returns.

8. Open the Fusabase console in your browser and navigate to **Database**. You should see the four new documents in the `recipes` collection. You've just written your first data to the database!

    ![Fusabase console showing the recipes collection populated](images/task-3-console-recipes.png =60%x*)


9. Leave the app and console open for the next lab.

If the recipes don't appear after seeding, see the Appendix below.

## Appendix

### Troubleshooting

- **"Tapping Add Sample Recipes does nothing."** Open Xcode's debug console (**View > Debug Area > Activate Console**) and look for an error from the SDK. Common causes: the `fusabase-config.json` values from Lab 2 are wrong, or the local Fusabase compose stack isn't running. Run `curl http://localhost:8080/ords/` from a terminal to confirm ORDS is reachable.

- **"Recipes seed but the list stays empty."** Your `loadRecipes` body might still be the stub. Confirm you saved `RecipeService.swift` (the title bar should not show the unsaved-changes dot) and rebuild with **Cmd+B**.

- **"Build error: cannot find Filter in scope."** `Filter` and `Query` come from `FusabaseOracledb`. The file already has `import FusabaseOracledb` at the top — don't remove it.

- **"Same recipe appears multiple times after re-seeding."** The seed helper isn't idempotent. Each tap of **Add Sample Recipes** writes a fresh batch. Either delete the duplicates from the Fusabase console, or just ignore them — they don't affect the rest of the workshop.

> **Want a clean copy?**
>
> A copy of `RecipeService.swift` as it should look after this lab is available at `checkpoints/RecipeService-after-lab-4.swift`. Drop it into `starter/RecipeShare/Services/` any time you'd like a fresh baseline before moving on. Keep your own `starter/RecipeShare/Resources/fusabase-config.json` — checkpoints don't include your project config.

You may now **proceed to the next lab**.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Last Updated By/Date** - Killian Lynch, May 2026
