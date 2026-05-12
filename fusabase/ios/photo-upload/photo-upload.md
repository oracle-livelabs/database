# Lab 6: Photo Upload

## Introduction

In this lab, you will add photo upload to RecipeShare using `FusabaseStorage`. The create-recipe sheet already has a `PhotosPicker` button wired up to the service — you'll fill in the service method that uploads the bytes, gets the public download URL, and writes that URL to the recipe document.

### Objectives

In this lab, you will:

- implement `RecipeService.uploadRecipePhoto(recipeId:imageData:)` to upload an image and save the URL on the recipe document
- pick a photo from the Simulator's photo library and verify it appears on the recipe card after upload

Estimated Time: 10 minutes

## Task 1: Open the service file

1. In Xcode's **Project navigator**, expand **RecipeShare > Services** and open `RecipeService.swift`.

    Same file as Lab 5. The pre-built `CreateRecipeView` calls `uploadRecipePhoto` automatically when the user picks a photo and taps Save.

## Task 2: Implement uploadRecipePhoto

1. Find the `uploadRecipePhoto(recipeId:imageData:)` stub. It looks like:

    ```swift
    func uploadRecipePhoto(
        recipeId: String,
        imageData: Data
    ) async throws -> String {
        // TODO: implement in Lab 6
        throw NSError(
            domain: "RecipeShare",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Not yet implemented (Lab 6)."]
        )
    }
    ```

2. Replace the entire function body with this:

    ```swift
    <copy>func uploadRecipePhoto(
        recipeId: String,
        imageData: Data
    ) async throws -> String {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // 1. Build a unique storage path under the recipe's folder.
            let filename = "\(UUID().uuidString).jpg"
            let path = "recipes/\(recipeId)/\(filename)"
            let ref = storage.reference().child(path)

            // 2. Upload bytes. `putData` returns a StorageUploadTask whose
            // observers fire on completion — bridge to async/await with a
            // checked continuation. 
            try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
                let task = ref.putData(imageData, metadata: nil)
                task.observe(.success) { _ in
                    cont.resume(returning: ())
                }
                task.observe(.failure) { snapshot in
                    cont.resume(
                        throwing: snapshot.error ?? NSError(
                            domain: "RecipeShare",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Photo upload failed."]
                        )
                    )
                }
            }

            // 3. Fetch a download URL for the freshly uploaded object.
            let url = try await ref.downloadURL()
            let urlString = url.absoluteString

            // 4. Record the download URL on the parent recipe document.
            try await db
                .collection("recipes")
                .document(recipeId)
                .updateData(["photoURL": urlString])

            // Refresh the published list so the new photo appears.
            try await loadRecipes(category: nil)

            return urlString
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }</copy>
    ```

3. Walk through what each block does:

    - **Storage path.** `storage.reference().child("recipes/\(recipeId)/\(UUID().uuidString).jpg")` builds a deterministic path that scopes uploads under the recipe's folder. Each upload gets a fresh UUID filename, so re-uploading creates a new object instead of overwriting.
    - **Upload bytes.** `ref.putData(imageData, metadata: nil)` returns a `StorageUploadTask` — a long-running task with `.success` / `.failure` observers. Because the SDK's async-throwing wrapper isn't exposed here, we bridge the callback-based API to async/await with `withCheckedThrowingContinuation`. The continuation resumes once on whichever observer fires first.
    - **Download URL.** `ref.downloadURL()` returns a public `URL` the app can render directly with `AsyncImage` (no auth tokens required for reads — Lab 7 will revisit storage rules).
    - **Update recipe.** `db.collection("recipes").document(recipeId).updateData(["photoURL": urlString])` writes the URL onto the recipe document so the recipe list and detail views can render the image. We use `updateData` (not `addDocument`) because the recipe already exists — `updateData` performs a partial update, leaving every other field untouched.
    - **Refresh.** `loadRecipes(category: nil)` reloads the published list so the new photo appears in the UI without a manual pull-to-refresh.


4. Save the file.

## Task 3: Make sure the Simulator has a photo to pick

1. Most fresh iOS Simulator builds ship with a few stock images in the **Photos** app. Open the Simulator's home screen and launch **Photos** to confirm.

2. In Xcode's **Project navigator**, expand **RecipeShare > Images** and open drag teh JPG image onto the running Simulator window — it gets added to Photos automatically.

    ![Create recipe sheet with a photo selected](images/speg2.gif =30%x*)


2. If you want to upload a differen image, you can also open **Safari** in the Simulator, navigate to any image online, long-press it, and choose **Save to Photos**. Now the image is available in your Simulator's photo library.


## Task 4: Upload a photo and verify

1. Press **Cmd+R** to build and run.

2. Sign in with the account from Lab 4.

3. Tap **+** to open the create-recipe sheet (or open a recipe and tap **Edit** if you want to add a photo to an existing recipe).

4. Fill in the recipe form. Copy each value below into the matching field — or substitute your own recipe.

    Title:

    ```text
    <copy>Lemon Herb Pasta</copy>
    ```

    Description:

    ```text
    <copy>Bright pasta with lemon and herbs.</copy>
    ```

    Category: pick **Dinner**.

    Prep time:

    ```text
    <copy>30</copy>
    ```

    Ingredients:

    ```text
    <copy>250g spaghetti
    2 tablespoons olive oil
    2 cloves garlic, minced
    Zest and juice of 1 lemon
    1/4 cup chopped flat-leaf parsley
    2 tablespoons chopped basil
    Salt and freshly ground black pepper
    Grated parmesan, to serve</copy>
    ```

    Instructions:

    ```text
    <copy>Cook the pasta, toss it with olive oil, lemon juice, and herbs, then serve warm.</copy>
    ```

    Then tap **Choose Photo**. The Simulator's photo picker opens.

5. Pick any image and confirm. A small thumbnail preview appears in the form. To scroll down on the simulator, **left click** and drag your mouse up.

    ![Create recipe sheet with a photo selected](images/task-4-photo-selected.png =30%x*)


6. Tap **Save**.

    The view runs `createRecipe` first (returning the new document ID), then calls `uploadRecipePhoto(recipeId: id, imageData: data)`. Behind the scenes: bytes go to Storage, the URL comes back, the URL is written to the recipe doc, and the published `recipes` array refreshes.

7. The recipe list now shows your new recipe with its photo. Tap the recipe to confirm the detail view also displays the image.

    ![Recipe list with the new recipe showing its photo](images/task-4-list-with-photo.png =30%x*)


8. Open the Fusabase console and navigate to **Storage**. You should see the file under `recipes/<your-recipe-id>/<uuid>.jpg`.

    ![Fusabase storage console showing the uploaded file under recipes/recipeId/](images/task-4-console-storage.png =60%x*)


9. Open the recipe document in **Database > recipes** and confirm the `photoURL` field now holds the download URL.

10. Leave the app and console open for the next lab.

## Appendix

### Troubleshooting

- **"Save throws 'Not yet implemented (Lab 6)'."** Same as Lab 5 — confirm you replaced the entire stub body and saved the file.

- **"Photo picker opens but no images are visible."** The Simulator's photo library is empty. Save an image from Safari or drag one onto the Simulator window (see Task 3).

- **"Upload hangs forever."** Check the Fusabase compose stack is running and the Storage service is reachable. Look in Xcode's debug console for an SDK error. If the continuation never resumes, the most common cause is the storage bucket name in `fusabase-config.json` doesn't match a real bucket on your project.

- **"Photo uploads but doesn't show on the card."** The recipe's `photoURL` field is the source of truth for the UI. Confirm step 4 of `uploadRecipePhoto` (the `updateData(["photoURL": urlString])` call) actually ran. Easiest check: look at the recipe document in the Fusabase console — if `photoURL` is missing, your code didn't reach that step.

- **"Build error: cannot find Storage in scope."** `Storage` and `StorageUploadTask` come from `FusabaseStorage`. The file already imports it; don't remove it.

> **Want a clean copy?**
>
> A copy of `RecipeService.swift` as it should look after this lab is available at `checkpoints/RecipeService-after-lab-6.swift`. Drop it into `starter/RecipeShare/Services/` any time you'd like a fresh baseline before moving on. Keep your own `starter/RecipeShare/Resources/fusabase-config.json` — checkpoints don't include your project config.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Last Updated By/Date** - Killian Lynch, May 2026
