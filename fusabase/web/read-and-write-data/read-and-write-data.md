# Build the Public Recipe Experience

## Introduction

In this lab, you will use the Fusabase JavaScript SDK to query recipe data and display it in the app. You will add the SDK read pattern that loads recipes, then seed demo data so you can see your query in action.

### Objectives

In this lab, you will:

- build a query with `collection()`, `query()`, and `getDocs()`
- seed demo data so you can test your query
- verify that recipes appear in the app and that category pills filter correctly

Estimated Time: 15 minutes

## Task 1: Open the app file

1. Return to your code editor and open the starter app file:

    - `starter/scripts/app.js`

2. Find the `refreshRecipes()` function and the Lab 3 TODO comment.

    ![gif finding the section in code.](images/lab3.gif =60%x*)

    ![still shot.](images/place.png =60%x*)

3. Fusabase data is organized into collections, documents, fields, and subcollections. We will store each recipe as a document in a top-level collection called `recipes`. Later, we will store each rating in a subcollection called `ratings` under each recipe.

    ![Recipe Share data model showing the recipes collection, recipe document fields, ratings subcollection, and rating document.](images/recipe-share-data-model.svg =45%x*)

    This collection/document shape is the data model your SDK calls will read and write through the rest of the workshop.


## Task 2: Build a query with `collection()`, `query()`, and `getDocs()`

Steps 1-5 walk through the query pattern piece by piece. Read each step to understand how the SDK query works, then copy the complete code in step 6.

1. In `refreshRecipes()`, start by creating an empty constraints array.

    Query constraints describe how the SDK should filter, sort, and limit the documents returned from a collection.

    ```js
    const constraints = [];
    ```

2. Add a category filter only when the user has selected a category pill.

    `where("category", "==", state.filters.category)` tells the SDK to return only recipe documents whose `category` field matches the selected category. When no category is selected, the app skips this constraint and reads all recipes.

    ```js
    if (state.filters.category) {
      constraints.push(where("category", "==", state.filters.category));
    }
    ```

3. Add the sort order and result limit.

    `orderBy("createdAt", "desc")` sorts the newest recipes first. `limit(24)` keeps the query bounded so the app reads a reasonable number of recipe documents.

    ```js
    constraints.push(orderBy("createdAt", "desc"));
    constraints.push(limit(24));
    ```

4. Build and run the query.

    `collection(db, "recipes")` points at the top-level recipes collection. `query()` composes that collection reference with the constraints you built. `getDocs()` sends the read request and returns a snapshot of matching documents.

    ```js
    const snapshot = await getDocs(
      query(collection(db, "recipes"), ...constraints)
    );
    ```

5. Convert the snapshot into plain JavaScript objects for the app.

    Each document snapshot has an SDK document ID and document data. The app renders regular objects, so map `snapshot.docs` into recipe objects that include both `id` and the document fields.

    ```js
    result = snapshot.docs.map((d) => ({ id: d.id, ...d.data() }));
    ```

6. Check your completed Lab 3 code inside `refreshRecipes()`.

    The Lab 3 code should look like this:

    ```js
    <copy>const constraints = [];

    if (state.filters.category) {
      constraints.push(where("category", "==", state.filters.category));
    }

    constraints.push(orderBy("createdAt", "desc"));
    constraints.push(limit(24));

    const snapshot = await getDocs(
      query(collection(db, "recipes"), ...constraints)
    );

    result = snapshot.docs.map((d) => ({ id: d.id, ...d.data() }));</copy>
    ```

    ![still shot.](images/updated.png =60%x*)


7. Save the file.

## Task 3: Seed demo data and verify

1. Return to the browser tab where the starter app is running.

    If needed, open it again at [http://localhost:8000/starter/](http://localhost:8000/starter/).

2. Refresh the page.

3. The app should connect and show "No recipes yet — upload your first recipe to get started!" in the recipe list. That is expected — the database has no data yet.

4. Click **Seed demo recipes**.

    The button creates demo recipe documents so you can test the query you added with `query()` and `getDocs()`.

5. The recipe list now shows three demo recipes: Chocolate Chip Cookies, Chicken Noodle Soup, and Avocado Toast (newest first).

    ![Animated GIF showing loading the seed data. ](images/recipeshare-seed-data.gif =85%x*)


6. You have now written your first recipes to the database. Go back to the Fusabase console and open the database. You should now see the new documents in the recipes collection!

    ![Animated GIF showing loading the seed data. ](images/data.gif =85%x*)


7. Leave the app and console open for the next lab.

    If `starter/scripts/app.js` does not work after this lab, navigate to the `checkpoints` folder in your repo, open `app-after-lab-3.js`, and use that file's contents to replace `starter/scripts/app.js`. Keep your own `starter/fusabase-config.js`.

    ![Animated GIF showing loading the seed data. ](images/backup.png =85%x*)

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Contributors** - 
* **Last Updated By/Date** - Killian Lynch, April 2026
