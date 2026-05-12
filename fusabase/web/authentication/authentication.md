# Authentication

## Introduction

In this lab, you will add authentication to the Recipe Share app using the Fusabase JavaScript SDK. When you are done, users will be able to sign up for an account, sign in, and sign out. A Sign in button will appear in the navbar once your code is in place, and the write forms (the recipe creation modal and the rating form in the detail card) will become enabled when you are signed in.

### Objectives

In this lab, you will:

- review the modular Auth SDK APIs in `starter/scripts/app.js`
- initialize Auth with `getAuth(app)`
- observe session changes with `onAuthStateChanged(auth, callback)`
- create accounts with `createUserWithEmailAndPassword`
- authenticate users with `signInWithEmailAndPassword`
- end sessions with `signOut(auth)`

Estimated Time: 15 minutes

## Task 1: Review the Auth SDK imports

1. Return to your code editor and open `starter/scripts/app.js`.

2. At the top of the file, find this import from `fusabase/auth`.

    ```js
    import {
      createUserWithEmailAndPassword,
      getAuth,
      onAuthStateChanged,
      signInWithEmailAndPassword,
      signOut
    } from "fusabase/auth";
    ```

    These are the modular Auth SDK APIs you will call in this lab.

3. Find the `auth` variable.

    ```js
    let auth;
    ```

    You will store the Auth SDK instance in this variable after Fusabase connects.

## Task 2: Start auth and watch for state changes

Steps 1-2 walk through the startup pattern piece by piece. Read each step to understand what each call does, then copy the complete code in step 3.

1. Initialize the Auth SDK.

    `getAuth(app)` creates an auth service instance connected to your Fusabase app. Store that instance in the `auth` variable so the rest of this lab can use it.

    ```js
    auth = getAuth(app);
    ```

2. Listen for auth state changes.

    `onAuthStateChanged(auth, callback)` tells the SDK to run your callback whenever the user signs in, signs out, or the browser restores an existing session. The callback receives a `user` object when signed in, or `null` when signed out. Recipe Share uses that value to show the correct auth controls and enable signed-in actions.

    ```js
    onAuthStateChanged(auth, (user) => {
      state.currentUser = user;
      renderAuthState(el, user);
      syncWriteForms();
    });
    ```

3. Scroll to the `main()` function near the bottom of `starter/scripts/app.js` and find the Lab 4 startup TODO. Replace the commented placeholder with the complete code:

    ```js
    <copy>auth = getAuth(app);
    onAuthStateChanged(auth, (user) => {
      state.currentUser = user;
      renderAuthState(el, user);
      syncWriteForms();
    });</copy>
    ```

    ![shows the code. ](images/done.png =85%x*)

4. Save the file.

## Task 3: Create an account

1. Find the **Create an account** button code in `starter/scripts/app.js`.

    ```js
    el.signUpButton.addEventListener("click", () => {
      runAction("Account created.", async () => {
        // ── Lab 4 TODO: Create an account with the SDK ─
        // await createUserWithEmailAndPassword(auth, el.authEmail.value, el.authPassword.value);
        throw new Error("Complete Lab 4 to create an account.");

        el.authEmail.value = "";
        el.authPassword.value = "";
      });
    });
    ```

2. Replace the Lab 4 TODO which also remove the placeholder `throw new Error(...)` line.

    `createUserWithEmailAndPassword(auth, email, password)` creates a new account with the email and password from the auth popup. After the account is created, the SDK signs in the user and your `onAuthStateChanged` listener runs.

    Your completed code should look like this:

    ```js
    <copy>el.signUpButton.addEventListener("click", () => {
      runAction("Account created.", async () => {
        // ── Lab 4 TODO: Create an account with the SDK ─
        await createUserWithEmailAndPassword(auth, el.authEmail.value, el.authPassword.value);

        el.authEmail.value = "";
        el.authPassword.value = "";
      });
    });</copy>
    ```

    ![shows the code. ](images/create.png =85%x*)

3. Save the file.

## Task 4: Sign in

1. Find the **Sign in** button code in `starter/scripts/app.js`.

    ```js
    el.signInButton.addEventListener("click", () => {
      runAction("Signed in.", async () => {
        // ── Lab 4 TODO: Sign in with the SDK ─────────
        // await signInWithEmailAndPassword(auth, el.authEmail.value, el.authPassword.value);
        throw new Error("Complete Lab 4 to sign in.");

        el.authEmail.value = "";
        el.authPassword.value = "";
      });
    });
    ```

2. Replace the Lab 4 TODO and remove the placeholder `throw new Error(...)` line.

    `signInWithEmailAndPassword(auth, email, password)` authenticates an existing user. If the credentials are wrong, the SDK throws an error that the app catches and displays in the status banner.

    Your completed code should look like this:

    ```js
    <copy>el.signInButton.addEventListener("click", () => {
      runAction("Signed in.", async () => {
        // ── Lab 4 TODO: Sign in with the SDK ─────────
        await signInWithEmailAndPassword(auth, el.authEmail.value, el.authPassword.value);

        el.authEmail.value = "";
        el.authPassword.value = "";
      });
    });</copy>
    ```

    ![shows the code. ](images/sign-in.png =85%x*)

3. Save the file.

## Task 5: Sign out

1. Find the **Sign out** button code in `starter/scripts/app.js`.

    ```js
    el.signOutButton.addEventListener("click", () => {
      runAction("Signed out.", async () => {
        // ── Lab 4 TODO: Sign out with the SDK ────────
        // await signOut(auth);
        throw new Error("Complete Lab 4 to sign out.");
      });
    });
    ```

2. Replace the Lab 4 TODO and remove the placeholder `throw new Error(...)` line.

    `signOut(auth)` ends the current session. The `onAuthStateChanged` listener fires with `null`, and the app switches back to showing the Sign in button.

    Your completed code should look like this:

    ```js
    <copy>el.signOutButton.addEventListener("click", () => {
      runAction("Signed out.", async () => {
        // ── Lab 4 TODO: Sign out with the SDK ────────
        await signOut(auth);
      });
    });</copy>
    ```

    ![shows the code. ](images/sign-out.png =85%x*)

3. Save the file.

## Task 6: Verify authentication

1. Return to the browser and refresh the page.

2. A **Sign in** button should now appear in the navbar.

    ![shows the code. ](images/ui-sign-in.png =85%x*)


3. Click **Sign in** to open the auth popup with email and password fields.

4. Create a test account:

    - enter an email address (for example, `test@example.com`)
    - enter a password
    - click **Create account**

    ![shows the code. ](images/user.png =85%x*)


5. You should see "Account created." in the status banner, and the header should now show your email with a Sign out button. The popup closes automatically.

    ![shows the code. ](images/user-created.png =85%x*)

6. You have successfully just signed in as a new app user. Go back to the Fusabase console and open the authentication section. You should now see the new user in the users tab!

    ![shows the code. ](images/users.gif =85%x*)

7. Review the auth SDK calls you used in this lab:

    - `getAuth(app)` initializes the auth service for your project
    - `onAuthStateChanged(auth, callback)` reacts to auth state changes automatically
    - `createUserWithEmailAndPassword(auth, email, password)` creates accounts
    - `signInWithEmailAndPassword(auth, email, password)` authenticates users
    - `signOut(auth)` ends sessions

8. Leave the app and console open for the next lab.

    If `starter/scripts/app.js` does not work after this lab, navigate to the `checkpoints` folder in your repo, open `app-after-lab-4.js`, and use that file's contents to replace `starter/scripts/app.js`. Keep your own `starter/fusabase-config.js`.

    ![shows the code. ](images/backup.png =85%x*)


## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Contributors** - 
* **Last Updated By/Date** - Killian Lynch, April 2026
