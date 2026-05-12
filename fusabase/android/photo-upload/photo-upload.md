# Lab 6: Photo Upload

## Introduction

In this lab, you will implement `uploadRecipePhoto` so users can attach a picture to each recipe they create. The Photo Picker UI is already wired in `CreateRecipeFragment` — what's missing is the SDK code that uploads the bytes to Fusabase Storage and stamps the resulting URL onto the parent recipe document.

### Objectives

In this lab, you will:

- Build a `StorageReference` from a path under the `recipes/{recipeId}/` namespace
- Upload bytes with `putBytes` and watch the returned `UploadTask`
- Fetch a download URL with `getDownloadUrl`
- Update the parent recipe with `update("photoURL", url)` so the list view picks up the image

Estimated Time: 10 minutes

### Prerequisites

This lab assumes you have:

- Successfully completed all previous labs.

## Task 1: Implement uploadRecipePhoto

1. Open `RecipeRepository.java` and find the `uploadRecipePhoto(...)` stub.

2. Replace the body with this:

    ```java
    <copy>public void uploadRecipePhoto(String recipeId, byte[] bytes,
                                  OnResultListener<String> cb) {
        String filename = UUID.randomUUID() + ".jpg";
        String path = "recipes/" + recipeId + "/" + filename;
        StorageReference ref = storage.getReference().child(path);

        UploadTask task = ref.putBytes(bytes);
        task.addOnSuccessListener(snapshot -> ref.getDownloadUrl()
                .addOnSuccessListener(uri -> {
                    String url = uri != null ? uri.toString() : "";
                    Map<String, Object> patch = new HashMap<>();
                    patch.put("photoURL", url);
                    db.collection("recipes").document(recipeId).update(patch)
                            .addOnSuccessListener(v -> cb.onSuccess(url))
                            .addOnFailureListener(cb::onFailure);
                })
                .addOnFailureListener(cb::onFailure))
            .addOnFailureListener(cb::onFailure);
    }</copy>
    ```

3. Add the imports:

    ```java
    <copy>import com.oracle.mobile.fusabase.storage.StorageReference;
    import com.oracle.mobile.fusabase.storage.UploadTask;
    import java.util.UUID;</copy>
    ```

4. Walk through what the code does. There are three SDK calls chained together — the upload, the URL fetch, and the document update.

    **Step 1 — Build the storage path.**

    - `Storage.getInstance()` (assigned to `storage` at the top of the class) is the SDK singleton.
    - `storage.getReference()` returns the bucket root. Calling `.child(path)` returns a `StorageReference` pointing at a specific object location.
    - The path uses the `recipeId` as a folder so each recipe's photo is namespaced. The filename is a fresh UUID so re-uploading doesn't collide with a prior photo, and the storage rule in Lab 7 can target the `recipes/{recipeId}/{fileName}` shape.

    **Step 2 — Upload the bytes.**

    - `ref.putBytes(bytes)` returns an `UploadTask`. Like the regular `Task`, an `UploadTask` exposes `addOnSuccessListener` and `addOnFailureListener`. It also exposes progress and pause/resume APIs you don't need here.
    - On success the task delivers an `UploadTask.TaskSnapshot`, but you don't read anything from it — the bytes have landed and you have the reference, which is all you need.

    **Step 3 — Fetch the download URL.**

    - `ref.getDownloadUrl()` returns a `Task<Uri>`. The URL is a long-lived signed URL the recipe list uses to render the image with Glide.
    - `Uri.toString()` is what you save on the document.

    **Step 4 — Stamp the URL on the recipe.**

    - `db.collection("recipes").document(recipeId).update(map)` writes only the fields in the map. You're sending just `photoURL`, so the rest of the document is untouched.
    - On success, you call back with the URL. The snapshot listener attached in Lab 4 sees the document mutation and refreshes the list cell with the new photo through Glide.

5. The error path: any of the three SDK calls can fail (no network, server error, permission denied). Each `addOnFailureListener(cb::onFailure)` forwards the SDK exception straight to the caller. `CreateRecipeFragment` displays it in a Snackbar.

## Task 2: How the form invokes upload

You don't need to change `CreateRecipeFragment.java`, but it helps to know the flow.

1. The fragment registers a Photo Picker launcher in a field initializer:

    ```java
    private final ActivityResultLauncher<PickVisualMediaRequest> pickPhoto =
            registerForActivityResult(new ActivityResultContracts.PickVisualMedia(), uri -> {
                if (uri == null) return;
                selectedPhotoUri = uri;
                selectedPhotoBytes = readBytes(uri);
                // ...show preview with Glide
            });
    ```


2. The **Pick a photo** button launches the picker:

    ```java
    binding.pickPhotoButton.setOnClickListener(v ->
            pickPhoto.launch(new PickVisualMediaRequest.Builder()
                    .setMediaType(ActivityResultContracts.PickVisualMedia.ImageOnly.INSTANCE)
                    .build()));
    ```

3. When the user picks an image, the fragment buffers the bytes via `ContentResolver.openInputStream(uri)` and shows a preview.

4. When the user taps **Save**:

    - First the fragment calls `RecipeRepository.createRecipe(...)` (your Lab 5 code) and gets the new `recipeId`.
    - Then, if a photo was selected, it calls `RecipeRepository.uploadRecipePhoto(recipeId, bytes, ...)`.
    - When upload completes (or if no photo was selected), the fragment pops the back stack.

The two-step flow (create-then-upload) is deliberate: the storage path needs the `recipeId`, which only exists after the document write succeeds.

## Task 3: Run and verify

1. **First, put a sample photo on the emulator** — the Photo Picker reads from the emulator's media gallery, which is empty on a fresh AVD. Use the built-in Chrome browser to grab one:

    1. Press the **home** button (circle) at the bottom of the emulator.

        ![Fusabase console showing the uploaded image and the photoURL field](images/home.png =25%x*)

    2. Tap **Chrome**. Dismiss any first-run prompts.
    3. Tap the searc bar, type `lemon herb pasta`, and press Enter.
    4. Tap the **Images** tab under the search box.
    5. Tap any result to expand it, then **long-press** the expanded image until a menu appears.
    6. Tap **Download image**. A "Image downloaded" toast confirms it.
        ![Fusabase console showing the uploaded image and the photoURL field](images/download.png =25%x*)

    7. Press the **recents** button (square) at the bottom of the emulator and switch back to RecipeShare — or just relaunch it from the app drawer.

    The downloaded photo now lives in the emulator's `Download` folder and will show up the next time the Photo Picker opens.

2.  Tap the **+** FAB to open the **New recipe** form.

4. Fill in the form for a new recipe. Suggested:

    - Title: "Lemon Herb Pasta"
    - Description: "Bright pasta with butter, lemon, and fresh herbs."
    - Category: Dinner
    - Prep time: 25
    - Ingredients: "1 lb pasta", "1/2 cup butter", "2 lemons", "Fresh parsley", "Parmesan"
    - Instructions: "Cook pasta to al dente. Melt butter; whisk in lemon zest and juice. Toss pasta with sauce and herbs. Finish with grated Parmesan."

5. Tap **Pick a photo**. The Android Photo Picker opens — your downloaded image is there under **Recents**.

    ![Android Photo Picker showing the downloaded pasta image](images/p2.png =30%x*)

6. Pick the image. The picker dismisses and the form shows a preview below the **Pick a photo** button.

7. Tap **Save**. The form shows a brief "Uploading photo…" message while the bytes go up, then dismisses to the list. Your new recipe is at the top, with the image rendered in the card.

    ![Recipe list with the new pasta recipe and its image](images/task-3-list-with-photo.png =30%x*)

9. Verify in the Fusabase console: open **Storage**, navigate to `recipes/{your-recipe-id}/`, and confirm the image is there. You can also open the recipe document under **Database > recipes** and confirm the `photoURL` field holds the same URL the SDK returned to your code.

    ![Fusabase console showing the uploaded image and the photoURL field](images/task-3-console-storage.png =85%x*)

## Summary

The Fusabase Storage module follows the same Task-based shape as Auth and Oracledb:

- `Storage.getInstance().getReference().child(path)` — addresses an object location.
- `ref.putBytes(byte[])` — returns an `UploadTask`.
- `ref.getDownloadUrl()` — returns a `Task<Uri>`.
- For files on disk, `ref.putFile(uri)` works the same way and avoids reading bytes into memory first. `putBytes` was the right call here because the picker delivers a content URI without a stable local path.

The chained-callback pattern (upload → url → update) is the most common shape for "upload an asset and link it from a document." Three SDK calls, all returning Tasks, all checked for failure.

Two ideas worth keeping:

- **Storage is just bytes; the database is just structure.** Storage holds the file; the database holds the URL. The recipe is the source of truth — the URL on the document tells the UI which image to fetch.
- **The snapshot listener does the rest.** Once `update("photoURL", url)` writes back to the recipe doc, your Lab 4 listener sees the change and re-renders the list cell. No manual refresh.

> **Want a clean copy?**
>
> A copy of `RecipeRepository.java` as it should look after this lab is available at `checkpoints/RecipeRepository-after-lab-6.java`.

You may now **proceed to the next lab**.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Last Updated By/Date** - Killian Lynch, May 2026
