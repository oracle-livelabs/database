# Photo Upload

## Introduction

In this lab, you will add photo upload to the Recipe Share app using the Fusabase JavaScript SDK storage module. When you are done, users will be able to upload a photo for a recipe and see it displayed on the recipe card.

You will complete the Lab 6 TODO in `starter/scripts/app.js` and unhide the photo field in `starter/index.html`.

### Objectives

In this lab, you will:

- use `getStorage(app)` to access the storage service
- use `ref(storage, path)` to point at a recipe photo location
- use `uploadBytes()` to upload an image file
- use `getDownloadURL()` to get a browser-displayable image URL
- use `updateDoc()` to save `photoURL` on the recipe document
- upload a photo and verify that it appears on the recipe card after publish and refresh

Estimated Time: 10 minutes

## Task 1: Show the photo field

1. Return to your code editor and open `starter/index.html`.

2. Find the photo field (line 167):

    ```html
    <label class="form-field" id="modalPhotoField" hidden>
      <span>Photo</span>
      <input id="modalPhotoFile" name="photo" type="file" accept="image/*" class="form-input" />
    </label>
    ```

3. Remove the `hidden` attribute from `#modalPhotoField`:

    ```html
    <copy><label class="form-field" id="modalPhotoField">
      <span>Photo</span>
      <input id="modalPhotoFile" name="photo" type="file" accept="image/*" class="form-input" />
    </label></copy>
    ```

    ![shows the code. ](images/hidden.png =85%x*)

4. Save the file.

## Task 2: Upload a photo after recipe creation

Steps 1-4 walk through the storage upload pattern piece by piece. Read each step to understand how the SDK stores the photo and saves its URL, then copy the complete code in step 5.

1. Open `starter/scripts/app.js`.

2. Find the Lab 6 TODO that uploads a new recipe photo:

    ```js
    // ── Lab 6 TODO: Upload the new recipe photo with the SDK ──
    // After adding this code, remove hidden from #modalPhotoField in index.html.
    ```

3. Read the SDK calls that upload the file and save its URL:

    ```js
    storage = getStorage(app);
    const photoRef = ref(storage, `recipes/${recipeRef.id}/${photoFile.name}`);
    await uploadBytes(photoRef, photoFile, { contentType: photoFile.type || "image/png" });
    const photoURL = await getDownloadURL(photoRef);
    await updateDoc(doc(collection(db, "recipes"), recipeRef.id), { photoURL });
    ```

4. Walk through what this code does:

    - `getStorage(app)` accesses the storage service for this app.
    - `ref(storage, path)` creates a reference to a specific storage object. The path `recipes/{recipeId}/{file.name}` keeps each photo under its recipe ID.
    - `uploadBytes(photoRef, photoFile, { contentType: ... })` uploads the selected file and stores its MIME type.
    - `getDownloadURL(photoRef)` returns a URL the browser can use to display the uploaded image.
    - `updateDoc()` saves that URL on the recipe document.

    `photoURL` is the recipe field that stores the uploaded image URL. The SDK stores the image bytes in storage, and Recipe Share saves the storage object's download URL on the recipe document so the browser can display it.

5. Your new recipe photo upload code should now include this checkpoint:

    ```js
    <copy>const photoFile = fd.get("photo");
    if (photoFile && photoFile.size > 0) {
      // ── Lab 6 TODO: Upload the new recipe photo with the SDK ──
      // After adding this code, remove hidden from #modalPhotoField in index.html.
      storage = getStorage(app);
      const photoRef = ref(storage, `recipes/${recipeRef.id}/${photoFile.name}`);
      await uploadBytes(photoRef, photoFile, { contentType: photoFile.type || "image/png" });
      const photoURL = await getDownloadURL(photoRef);
      await updateDoc(doc(collection(db, "recipes"), recipeRef.id), { photoURL });
    }</copy>
    ```

    ![shows the code. ](images/photo.png =85%x*)


6. Save the file.

## Task 3: Upload a photo and verify

1. Return to the browser and refresh the page.

2. Sign in if needed so the recipe form is enabled.

3. Click **Upload Recipe** to open the create recipe modal.

4. Fill in the recipe form with this sample data:

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

5. In the **Photo** field, choose the sample image from your repo:

    - `starter/images/lemon-herb-pasta.png`

    ![shows the code. ](images/pasta.png =60%x*)


6. Click **Publish recipe**.

7. Wait for the request to complete. You should see a success message in the status banner.

8. The new recipe should appear in the recipe list, and its card should display the uploaded photo.

    ![shows the code. ](images/dinner.png =60%x*)

9. Verify the saved recipe in Fusabase:

    Return to the **Database** workspace in the Fusabase console. Find your recipe in the `recipes` collection and confirm that it has a `photoURL` field.

    ![shows the code. ](images/confirm.png =60%x*)

    Click **Storage** in the Fusabase console and open the `recipes` folder.

    You should see a folder called recipes with the recipe ID and the uploaded image file inside it.

    ![shows the code. ](images/storage.png =60%x*)

10. Return to the app and refresh the page. The recipe card should still display the photo.

11. Leave the app and console open for the next lab.

    If the starter app does not work after this lab, navigate to the `checkpoints` folder in your repo, open `app-after-lab-6.js` and `index-after-lab-6.html`, then use those files' contents to replace `starter/scripts/app.js` and `starter/index.html`. Keep your own `starter/fusabase-config.js`.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Contributors** - 
* **Last Updated By/Date** - Killian Lynch, April 2026
