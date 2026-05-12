# Lab 3: Authentication

## Introduction

In this lab, you will implement email/password authentication so users can sign up, sign in, and sign out. All four method bodies you'll write live in `AuthRepository.java` — the Fragments observing this repository are already wired and will start working the moment you fill in the SDK calls.

### Objectives

In this lab, you will:

- Attach a state-change listener so the UI tracks the signed-in user
- Implement sign-up with `createUserWithEmailAndPassword`
- Implement sign-in with `signInWithEmailAndPassword`
- Implement sign-out with `signOut`
- Surface error messages to the UI through LiveData

Estimated Time: 10 minutes

## Task 1: Open AuthRepository.java

1. In Android Studio's **Project** view, expand `app/src/main/java/com/oracle/fusabase/recipeshare/auth/` and open `AuthRepository.java`.

2. Read through the class. The pieces that are already in place:

    - `private final FusabaseAuth auth = FusabaseAuth.getInstance();` — the SDK handle.
    - `currentUser`, `errorMessage`, `isLoading` — `MutableLiveData` fields the UI observes.
    - Public getters that return them as read-only `LiveData`.

3. The four methods at the bottom — `listenToAuthState`, `signUp`, `signIn`, `signOut` — are stubs marked **TODO Lab 3**. You'll fill these in.

    ![Sign-up form filled in on the emulator](images/task1.png =30%x*)


## Task 2: Listen to the auth state

1. The Fusabase auth module emits an event whenever a user signs in, signs up, or signs out. The `AuthStateListener` interface is the SDK's hook for receiving those events. By posting the result to `currentUser`, the rest of the app — `MainActivity`, `AuthFragment`, `RecipeListFragment` — gets notified through LiveData.

2. Replace the body of `listenToAuthState()` with this:

    ```java
    <copy>public void listenToAuthState() {
        authStateListener = fusabaseAuth -> currentUser.postValue(fusabaseAuth.getCurrentUser());
        auth.addAuthStateListener(authStateListener);
    }</copy>
    ```
    ![Sign-up form filled in on the emulator](images/code1.png =30%x*)
    ![Sign-up form filled in on the emulator](images/code2.png =30%x*)


3. Walk through what the code does:

    - `FusabaseAuth.AuthStateListener` is a single-method interface (`onAuthStateChanged(FusabaseAuth)`), so you can write it as a lambda.
    - The listener is invoked with the `FusabaseAuth` instance. You ask it for the latest current user — which may be null if a sign-out just happened — and post that value to `currentUser`.
    - `postValue(...)` is the thread-safe way to update LiveData. The SDK may invoke the listener on a background thread, so use `postValue` rather than `setValue`.
    - You stash the listener in the `authStateListener` field. The constructor calls `listenToAuthState()` once, so this listener stays alive for the app's lifetime.

4. With the listener attached, anything observing `getCurrentUser()` automatically updates whenever the auth state changes. `MainActivity` uses this to switch between the auth screen and the recipe list.

## Task 3: Implement sign-up

1. Replace the body of `signUp(String email, String password)` with this:

    ```java
    <copy>public void signUp(String email, String password) {
        isLoading.setValue(true);
        errorMessage.setValue(null);
        auth.createUserWithEmailAndPassword(email, password)
                .addOnSuccessListener(result -> isLoading.postValue(false))
                .addOnFailureListener(error -> {
                    isLoading.postValue(false);
                    errorMessage.postValue(error.getMessage());
                });
    }</copy>
    ```

2. Walk through what the code does:

    - `setValue(true)` flips the loading flag on the main thread before the network call. The auth fragment is observing `isLoading` and disables the buttons / shows a spinner while it's true.
    - `auth.createUserWithEmailAndPassword(email, password)` is the Fusabase SDK call. It returns a `Task<AuthResult>` — the SDK's async primitive.
    - On success, you clear the loading flag. You don't need to do anything with the user here — the auth state listener you attached in Task 2 fires automatically and updates `currentUser`.
    - On failure, you clear the loading flag and post the error message so the auth fragment can display it.

3. Take note of the threading model:

    The SDK invokes success and failure listeners on the main thread by default, so `setValue` would also work. Using `postValue` everywhere keeps the code uniform and safe in case any listener fires from a different thread.

## Task 4: Implement sign-in

1. Sign-in follows the exact same shape as sign-up — only the SDK method changes.

2. Replace the body of `signIn(String email, String password)` with this:

    ```java
    <copy>public void signIn(String email, String password) {
        isLoading.setValue(true);
        errorMessage.setValue(null);
        auth.signInWithEmailAndPassword(email, password)
                .addOnSuccessListener(result -> isLoading.postValue(false))
                .addOnFailureListener(error -> {
                    isLoading.postValue(false);
                    errorMessage.postValue(error.getMessage());
                });
    }</copy>
    ```

3. Same flow:

    - The SDK call returns a `Task<AuthResult>`.
    - Success means a session is established; the auth state listener fires; `currentUser` updates; the auth fragment observes the change and navigates to the recipe list.
    - Failure surfaces an error message — invalid credentials, unknown email, etc. — straight from the SDK exception.

## Task 5: Implement sign-out

1. Sign-out is the simplest of the four. The SDK clears the session token and the auth state listener fires with a null current user.

2. Replace the body of `signOut()` with this:

    ```java
    <copy>public void signOut() {
        auth.signOut()
                .addOnFailureListener(error -> errorMessage.postValue(error.getMessage()));
    }</copy>
    ```

3. Walk through what the code does:

    - `auth.signOut()` returns a `Task<Void>`. There's nothing meaningful to do on success — the auth state listener handles the UI transition.
    - On failure, you surface the error. Sign-out failures are rare in practice but possible if the network is down at exactly the wrong moment.

## Task 6: Run and verify

1. Save `AuthRepository.java`. Click **Run** in Android Studio (Ctrl+R / Ctrl+R) to redeploy to the emulator.

2. The sign-in screen appears. Tap **Need an account? Create one** to switch to sign-up mode.

    ![Sign-up form filled in on the emulator](images/phone.png =30%x*)


3. Enter any email and password (for example, `test@example.com` / `password123`) and tap **Create account**.

    ![Sign-up form filled in on the emulator](images/task-6-sign-up.png =30%x*)

4. The form spinner appears briefly, then the app navigates to the (still empty) recipe list. The Fusabase auth module accepted the signup and the auth state listener flipped `currentUser` to your new user, which `AuthFragment` observed and acted on.

5. You have succesfully created your first app user!

    ![Empty recipe list after sign-in](images/task-6-recipe-list-empty.png =30%x*)

5. Tap the overflow menu in the toolbar and choose **Sign out**. The app returns to the sign-in screen. The same auth state listener fired with a null user, and `MainActivity` followed it back.

    ![Toolbar overflow menu showing the Sign out option](images/task-6-sign-out-menu.png =30%x*)

6. Tap **Sign in** mode and re-enter your credentials. The session is established and you're back at the recipe list.

7. Verify in the Fusabase console: open your project, click **Authentication** in the left navigation, and confirm your new user appears.

    ![Fusabase console Authentication tab showing the new user](images/task-6-console-user.png =85%x*)

## Summary

You wrote four methods, totaling about a dozen lines of SDK code. The Fusabase Android auth module follows a consistent shape:

- `FusabaseAuth.getInstance()` to get the singleton.
- `auth.createUserWithEmailAndPassword(email, password)` returns a `Task<AuthResult>`.
- `auth.signInWithEmailAndPassword(email, password)` returns a `Task<AuthResult>`.
- `auth.signOut()` returns a `Task<Void>`.
- `auth.addAuthStateListener(listener)` keeps the UI in sync without any explicit polling.

Tasks expose three listener hooks: `addOnSuccessListener`, `addOnFailureListener`, and `addOnCompleteListener`. You used the first two — they cover most call sites. Use `addOnCompleteListener` when you want to handle success and failure in the same callback.

The auth state listener is the key idea. Once attached, the SDK keeps it informed about every transition: sign-up, sign-in, sign-out, token refresh, and persisted-session restoration on app launch. The rest of your app observes one piece of state (`currentUser`) and reacts to changes, instead of imperatively updating the UI from each call site.

> **Want a clean copy?**
>
> A copy of `AuthRepository.java` as it should look after this lab is available at `checkpoints/AuthRepository-after-lab-3.java`. Drop it into `starter/RecipeShare/app/src/main/java/com/oracle/fusabase/recipeshare/auth/` any time you'd like a fresh baseline. Keep your own `app/fusabase-config.json` — checkpoints don't include your project config.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Last Updated By/Date** - Killian Lynch, May 2026
