# Lab 4: Read Recipe Data

## Introduction

In this lab, you will subscribe to the `recipes` collection with a real-time snapshot listener so the recipe list updates automatically whenever a document is added, changed, or removed on the server. You'll also wire a per-document listener for the recipe detail screen and a subcollection listener for ratings.

All work in this lab happens in `RecipeRepository.java`.

### Objectives

In this lab, you will:

- Build a query with `whereEqualTo`, `orderBy`, and `limit`
- Subscribe to a query with `addSnapshotListener` and a `QuerySnapshot` event listener
- Convert query documents into `Recipe` POJOs with `QueryDocumentSnapshot.toObject(Recipe.class)`
- Detach listeners with `ListenerRegistration.remove()` to avoid leaks
- Subscribe to a single document for the detail screen

Estimated Time: 15 minutes

### Prerequisites

This lab assumes you have:

- Successfully completed all previous labs.

## Task 1: Open RecipeRepository.java

1. In Android Studio, expand `app/src/main/java/com/oracle/fusabase/recipeshare/recipes/` and open `RecipeRepository.java`.

    ![Empty recipe list with the Add demo recipes button](images/read.png =30%x*)


2. Read through the class. The pieces that are already in place:

    - `private final FusabaseOracledb db = FusabaseOracledb.getInstance();` — the database SDK handle.
    - `private final Storage storage = Storage.getInstance();` — the storage SDK handle (you'll use this in Lab 6).
    - `recipes`, `currentRecipe`, `currentRatings` — `MutableLiveData` fields the Fragments observe.
    - Three `ListenerRegistration` fields that hold the live subscriptions you're about to create.
    - `seedDemoRecipes(...)` — a pre-built helper that writes four demo recipes to the collection. You don't edit this method; it's there so the **Add demo recipes** button works the moment you finish Tasks 2–5.

3. The four methods you'll fill in — `startListeningToRecipes`, `stopListeningToRecipes`, `startListeningToRecipe`, `stopListeningToRecipe` — are stubs at the top of the file.

## Task 2: Subscribe to the recipes collection

1. Replace the body of `startListeningToRecipes(@Nullable String category)` with this:

    ```java
    <copy>public void startListeningToRecipes(@Nullable String category) {
        Query q = db.collection("recipes");
        if (category != null) {
            q = q.whereEqualTo("category", category);
        }
        q = q.orderBy("createdAt", Query.Direction.DESCENDING).limit(24);

        recipesListener = q.addSnapshotListener((snapshot, error) -> {
            if (error != null) {
                errorMessage.postValue(error.getMessage());
                return;
            }
            if (snapshot == null) return;
            List<Recipe> mapped = new ArrayList<>();
            for (QueryDocumentSnapshot doc : snapshot) {
                Recipe r = doc.toObject(Recipe.class);
                if (r != null) {
                    r.setId(doc.getId());
                    mapped.add(r);
                }
            }
            recipes.postValue(mapped);
        });
    }</copy>
    ```

2. You'll need three new imports — Android Studio offers them on hover. The full set is:

    ```java
    <copy>import com.oracle.mobile.fusabase.oracledb.Query;
    import com.oracle.mobile.fusabase.oracledb.QueryDocumentSnapshot;
    import java.util.ArrayList;
    import java.util.List;</copy>
    ```
    ![Empty recipe list with the Add demo recipes button](images/imports.png =30%x*)

3. Walk through what the code does:

    - `db.collection("recipes")` returns a `CollectionReference`, which extends `Query`. Every chained call (`whereEqualTo`, `orderBy`, `limit`) returns a new `Query` with the constraint applied.
    - `whereEqualTo("category", category)` filters to documents whose `category` field equals the chip the user picked. When `category` is null, the chip is **All** and the filter is skipped.
    - `orderBy("createdAt", Query.Direction.DESCENDING)` sorts newest-first.
    - `limit(24)` caps the result set so the list view doesn't fetch the entire collection.
    - `addSnapshotListener((snapshot, error) -> { ... })` is the Fusabase real-time subscription. It returns a `ListenerRegistration` you save into `recipesListener`.
    - The lambda is the SDK's `EventListener<QuerySnapshot>` — invoked once with the initial snapshot, then again every time the underlying data changes. Either `snapshot` or `error` is non-null on each call; never both.
    - `QueryDocumentSnapshot.toObject(Recipe.class)` converts each document into your `Recipe` POJO. The SDK matches JSON keys to bean setters by name; it skips fields it can't map.
    - You stamp the document ID onto the bean (the SDK doesn't do this automatically), then post the list to LiveData. The `RecipeListFragment` observer pushes the new list to the RecyclerView.

4. The crucial property: this listener is **live**. Every write to the `recipes` collection — your seed call later in this lab, the `createRecipe` write you'll add in Lab 5, the `update` you'll add in Lab 7 — re-fires the lambda with a fresh snapshot. There is no manual refresh anywhere in the app.

## Task 3: Detach the recipes listener

1. The listener you attached in Task 2 stays alive until you explicitly remove it. If the `RecipeListFragment` is destroyed (when the user navigates away or rotates the device) and you don't detach the listener, the lambda holds a reference to the old fragment's LiveData and the SDK keeps spending bytes on a stream nobody reads.

2. Replace the body of `stopListeningToRecipes()` with this:

    ```java
    <copy>public void stopListeningToRecipes() {
        if (recipesListener != null) {
            recipesListener.remove();
            recipesListener = null;
        }
    }</copy>
    ```

3. `RecipeListFragment` already calls this from `onDestroyView()` — you don't need to wire it up. The fragment also calls it whenever the user changes the category chip; `startListeningToRecipes` is then called with the new filter. Stopping and starting like this is the standard pattern when filter parameters change.

## Task 4: Subscribe to a single recipe and its ratings

1. The recipe detail screen needs two streams — the recipe document itself and the `ratings` subcollection beneath it.

2. Replace the body of `startListeningToRecipe(String recipeId)` with this:

    ```java
    <copy>public void startListeningToRecipe(String recipeId) {
        DocumentReference doc = db.collection("recipes").document(recipeId);

        recipeDetailListener = doc.addSnapshotListener((snapshot, error) -> {
            if (error != null) {
                errorMessage.postValue(error.getMessage());
                return;
            }
            if (snapshot == null || !snapshot.exists()) return;
            Recipe r = snapshot.toObject(Recipe.class);
            if (r != null) {
                r.setId(snapshot.getId());
                currentRecipe.postValue(r);
            }
        });

        ratingsListener = doc.collection("ratings").addSnapshotListener((snapshot, error) -> {
            if (error != null) {
                errorMessage.postValue(error.getMessage());
                return;
            }
            if (snapshot == null) return;
            List<Rating> mapped = new ArrayList<>();
            for (QueryDocumentSnapshot d : snapshot) {
                Rating r = d.toObject(Rating.class);
                if (r != null) {
                    r.setId(d.getId());
                    mapped.add(r);
                }
            }
            currentRatings.postValue(mapped);
        });
    }</copy>
    ```

3. Add the import:

    ```java
    <copy>import com.oracle.mobile.fusabase.oracledb.DocumentReference;</copy>
    ```
    ![Empty recipe list with the Add demo recipes button](images/import2.png =30%x*)

4. Walk through what the code does:

    - `db.collection("recipes").document(recipeId)` returns a `DocumentReference`. Document references are how you address one row in a collection.
    - `doc.addSnapshotListener(...)` subscribes to **just that document**. The lambda receives a `DocumentSnapshot`, not a `QuerySnapshot` — there's a single doc to read, not a list.
    - `doc.collection("ratings")` opens the subcollection nested under the recipe. Subcollections behave like top-level collections — they have their own queries, listeners, and writes.
    - The ratings listener follows the same pattern as the recipes one in Task 2: iterate `getDocuments()`, map to POJOs, post to LiveData.

5. Both listeners are stored separately so you can detach them independently in the next task.

## Task 5: Detach the detail listeners

1. Replace the body of `stopListeningToRecipe()` with this:

    ```java
    <copy>public void stopListeningToRecipe() {
        if (recipeDetailListener != null) {
            recipeDetailListener.remove();
            recipeDetailListener = null;
        }
        if (ratingsListener != null) {
            ratingsListener.remove();
            ratingsListener = null;
        }
        currentRecipe.postValue(null);
        currentRatings.postValue(Collections.emptyList());
    }</copy>
    ```

2. The fragment calls this from `onDestroyView()`. You also clear the LiveData so the next time the user opens a different recipe, they don't see the previous recipe flash on screen before the new listener delivers its first snapshot.

## Task 6: Run and verify

1. Save `RecipeRepository.java`. Click **Run**.

    ![Empty recipe list with the Add demo recipes button](images/run.png =30%x*)


2. Sign in to your account. The recipe list opens in its empty state with the **Add demo recipes** button visible.

    ![Empty recipe list with the Add demo recipes button](images/task-6-empty-state.png =30%x*)

3. Tap **Add demo recipes**. Within a couple of seconds, four cards appear — Avocado Toast, Caprese Salad, Chicken Noodle Soup, Chocolate Chip Cookies.

    The button calls the pre-built `seedDemoRecipes` helper, which writes four recipe documents to the collection (we will learn writing data in the next lab). The listener you wrote in Task 2 sees those writes in real time and pushes them straight to the RecyclerView. **You don't see any flicker or refresh; the snapshot listener delivers the rows as they're written.**

    ![Recipe list populated with the four demo recipes](images/task-6-seeded-list.png =30%x*)

4. Tap **Lunch** in the chip filter. The list switches to just Caprese Salad. The fragment called `stopListeningToRecipes()` then `startListeningToRecipes("Lunch")` — a new listener with a `whereEqualTo("category", "Lunch")` filter — and the previous one was detached.

    ![Recipe list filtered to the Lunch category showing only Caprese Salad](images/task-6-filter-applied.png =30%x*)

5. Tap **All** to clear the filter. All four recipes return.

6. Tap any recipe to open the detail screen. The single-document listener delivers the full recipe (ingredients, instructions, prep time). The ratings list shows "No ratings yet" because the subcollection is empty.

    ![Recipe detail screen with ingredients and instructions](images/task-6-detail.png =30%x*)

7. Tap back. The fragment calls `stopListeningToRecipe()`. Both detail listeners are detached.

## Summary

You wrote four methods totaling about 50 lines of SDK code. The Fusabase Android Oracledb module follows a consistent shape:

- `db.collection(name)` returns a `CollectionReference`. Chain `whereEqualTo`, `orderBy`, `limit` to build a `Query`.
- `query.addSnapshotListener(listener)` returns a `ListenerRegistration` and starts streaming. Call `remove()` when you're done with it.
- `EventListener<T>.onEvent(value, error)` — exactly one of the two arguments is non-null on each invocation.
- `QueryDocumentSnapshot.toObject(MyClass.class)` reads bean fields by name. `getId()` returns the document ID separately.
- `db.collection("a").document("id").collection("b")` opens a subcollection. Subcollections support the same query and listener API as top-level collections.
- `collection.add(map)` writes a new document with an auto-generated ID and returns a `Task<DocumentReference>`.

Two ideas to keep in mind:

- **Listener cleanup is your responsibility.** Always pair `addSnapshotListener` with a corresponding `remove()` that runs on the appropriate lifecycle event. The Fragments in this workshop call `stop*` methods from `onDestroyView()`.
- **Snapshot listeners replace polling.** You don't need a manual refresh after every write. Whatever you write through `add` / `update` / `set` is pushed back to your active listeners by the SDK.

> **Want a clean copy?**
>
> A copy of `RecipeRepository.java` as it should look after this lab is available at `checkpoints/RecipeRepository-after-lab-4.java`. Drop it into `starter/RecipeShare/app/src/main/java/com/oracle/fusabase/recipeshare/recipes/` any time you'd like a fresh baseline.

You may now **proceed to the next lab**.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Last Updated By/Date** - Killian Lynch, May 2026
