# Write Recipe Data

## Introduction

In this lab, you will add write operations to the Recipe Share app with the Fusabase JavaScript SDK. Now that authentication is working from Lab 4, the recipe creation modal and the rating form in the detail card are enabled when you are signed in.

You will complete the Lab 5 TODOs in `starter/scripts/app.js`: one for creating recipes and one for adding ratings.

### Objectives

In this lab, you will:

- use `addDoc(collection(...))` to create recipe documents
- use `auth.currentUser` to store recipe ownership fields
- write rating records to a recipe `ratings` subcollection
- create a recipe and add a rating to verify that writes work

Estimated Time: 10 minutes

## Task 1: Create recipes with the SDK

1. Return to your code editor and open `starter/scripts/app.js`.

2. Find the Lab 5 TODO for creating recipes:

    ```js
    // ── Lab 5 TODO: Create recipes with the SDK ──
    // Use addDoc(collection(db, "recipes"), data) to save this form.
    ```

    The starter code has already collected the form values into `formInput`.

3. Replace the commented example with working SDK code:

    ```js
    <copy>recipeRef = await addDoc(collection(db, "recipes"), {
      title: formInput.title.trim(),
      description: formInput.description.trim(),
      category: formInput.category,
      prepTime: Number(formInput.prepTime),
      instructions: formInput.instructions.trim(),
      createdAt: Timestamp.now(),
      ingredients: formInput.ingredients,
      createdBy: auth.currentUser.email,
      ownerId: auth.currentUser.uid
    });</copy>
    ```

4. **Remove the placeholder guard after the TODO:**

    ```js
    if (!recipeRef) {
      throw new Error("Complete Lab 5 to create recipes.");
    }
    ```
5. The code should look like this:

      ![shows the code. ](images/code.png =85%x*)


5. What this does:

    - `collection(db, "recipes")` points the SDK at the recipes collection, the same collection you read in Lab 3.
    - `addDoc()` creates a new document in that collection and returns a document reference.
    - Storing the returned value in `recipeRef` lets Recipe Share refresh the page with the new recipe selected.
    - `auth.currentUser.email` and `auth.currentUser.uid` come from the signed-in user and are saved as ownership fields.

    These fields are the recipe data this app stores and displays. For example, Recipe Share uses `title`, `description`, `category`, `prepTime`, `instructions`, and `ingredients` to render recipe cards and details. The `ingredients` value comes from the textarea in the upload modal and is parsed into an array of trimmed lines so the detail view can render it as a bulleted list. Lab 7 will use `ownerId` when you add security rules for recipe edits.

6. Save the file.

## Task 2: Add ratings with the SDK

Steps 1-4 walk through the rating write pattern piece by piece. Read each step to understand how the SDK writes a rating into a subcollection, then copy the complete code in step 5.

1. In `starter/scripts/app.js`, find the Lab 5 TODO for adding ratings:

    ```js
    // ── Lab 5 TODO: Add ratings with the SDK ─────
    // Use doc() and addDoc(collection(recipeRef, "ratings"), ...) to save
    // a rating into the recipe's ratings subcollection.
    ```

2. Build a reference to the currently selected recipe:

    ```js
    const recipeRef = doc(collection(db, "recipes"), state.activeRecipeId);
    ```

    `doc()` creates a reference to one document. Here, `state.activeRecipeId` is the recipe selected in the UI.

3. Write the rating to a subcollection under the recipe:

    ```js
    await addDoc(collection(recipeRef, "ratings"), {
      author: auth.currentUser.email,
      rating: Number(fd.get("rating") ?? "5"),
      comment: String(fd.get("comment") ?? "").trim()
    });
    ```

    `collection(recipeRef, "ratings")` points to a subcollection under the parent recipe document. `addDoc()` creates a new rating document in that subcollection. The author is filled from the signed-in user.

    The rating write is one operation. Recipe Share computes the average rating live in the detail view by reading the `ratings` subcollection — there is no cached `averageRating` field on the parent recipe to keep in sync. Lab 7 will explain why this matters: the owner-only update rule you add there only applies to the recipe document, so any signed-in user can rate any recipe without bumping into ownership checks.

4. **Remove the placeholder throw after the TODO:**

    ```js
    throw new Error("Complete Lab 5 to add ratings.");
    ```

5. Your rating code should now include this checkpoint:

    ```js
    <copy>// ── Lab 5 TODO: Add ratings with the SDK ─────
    // Use doc() and addDoc(collection(recipeRef, "ratings"), ...) to save
    // a rating into the recipe's ratings subcollection.
    const recipeRef = doc(collection(db, "recipes"), state.activeRecipeId);

    await addDoc(collection(recipeRef, "ratings"), {
      author: auth.currentUser.email,
      rating: Number(fd.get("rating") ?? "5"),
      comment: String(fd.get("comment") ?? "").trim()
    });</copy>
    ```

6. Save the file.

## Task 3: Create a recipe and add a rating

1. Return to the web app and refresh the page.

2. Click **Upload Recipe** in the navbar to open the recipe creation modal.

      ![shows the code. ](images/add.png =55%x*)

3. Fill in the form. Copy each value below into the matching field — or substitute your own recipe.

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

4. Click **Publish recipe**.

5. You should see "Recipe created." in the status banner. The modal closes automatically and your new recipe should appear at the top of the recipe list.

6. Click on your new recipe to select it.

      ![shows the code. ](images/add-new.png =85%x*)


7. In the "Add a Rating" form below the recipe detail:

    - Rating: pick a value
    - Comment: write a short review

    The author is set automatically from your signed-in email. You do not need to enter it manually.

8. Click **Save rating**.

9. The recipe detail should update to show your rating in the ratings list, and the rating summary above the list should reflect the new average and count.

      ![shows the code. ](images/rating.png =85%x*)


10. Verify in Fusabase:

    Return to the **Database** workspace in the Fusabase console. Find your new recipe in the `recipes` collection and confirm that it has a `createdBy` field set to your email address. Open the recipe and confirm the `ratings` subcollection has your new rating.

    ![shows the code. ](images/rating.gif =85%x*)


11. Leave the app and console open for the next lab.

    If `starter/scripts/app.js` does not work after this lab, navigate to the `checkpoints` folder in your repo, open `app-after-lab-5.js`, and use that file's contents to replace `starter/scripts/app.js`. Keep your own `starter/fusabase-config.js`.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Contributors** - 
* **Last Updated By/Date** - Killian Lynch, April 2026
