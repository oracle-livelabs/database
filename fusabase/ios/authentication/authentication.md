# Lab 3: Authentication

## Introduction

In this lab, you will add authentication to the RecipeShare app using `FusabaseAuth`. When you are done, users can sign up, sign in, and sign out. The sign-in form already exists in the SwiftUI views — you are filling in the four service methods that the views call.

### Objectives

In this lab, you will:

- implement `AuthService.listenToAuthState()` to react to sign-in / sign-out events
- implement `signUp(email:password:)` to create new accounts
- implement `signIn(email:password:)` to authenticate existing users
- implement `signOut()` to end a session
- verify that the app correctly switches between the sign-in screen and the recipe list

Estimated Time: 10 minutes

### Prerequisites

This lab assumes you have:

- Successfully completed all previous labs.

## Task 1: Open the auth file

1. In Xcode's **Project navigator**, expand **RecipeShare > Services** and open `AuthService.swift`.

    ![Xcode project navigator with Services > AuthService.swift selected](images/task-1-open-auth.png =60%x*)

2. The file already declares the published state (`user`, `isLoading`, `errorMessage`), the listener handle, and the four method signatures. You'll fill in the bodies in this lab.

## Task 2: Implement listenToAuthState

1. Find the `listenToAuthState()` stub at the bottom of the file. It looks like:

    ```swift
    func listenToAuthState() {
        // TODO: implement in Lab 3
    }
    ```

    ![Xcode project navigator with Services > AuthService.swift selected](images/listen.png =60%x*)


2. Replace the entire function body with this:

    ```swift
    <copy>func listenToAuthState() {
        listenerHandle = FusabaseAuth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
            }
        }
    }</copy>
    ```
    ![Xcode project navigator with Services > AuthService.swift selected](images/done-listen.png =60%x*)

3. Walk through what this does:

    - `FusabaseAuth.auth().addStateDidChangeListener` registers a callback that fires whenever the user signs in, signs out, or the auth state is restored from a previous session.
    - The callback receives a `FusabaseUser?` — non-nil when signed in, nil when signed out.
    - We hop to the main actor with `Task { @MainActor in ... }` and assign `self?.user`. SwiftUI views observing the `@Published var user` re-render automatically.
    - `listenerHandle` retains the listener for the app's lifetime. The `init()` you can see at the top of the file calls `listenToAuthState()` once, so this is the only listener in the app — every other read in the codebase is a one-shot async call.

4. Save the file.

## Task 3: Implement signUp

1. Find the `signUp(email:password:)` stub. It looks like:

    ```swift
    func signUp(email: String, password: String) async throws {
        // TODO: implement in Lab 3
    }
    ```

2. Replace the body with this:

    ```swift
    <copy>func signUp(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            _ = try await FusabaseAuth.auth().createUser(withEmail: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }</copy>
    ```
    ![Xcode project navigator with Services > AuthService.swift selected](images/signup.png =70%x*)

3. `createUser(withEmail:password:)` creates a new user and immediately signs them in. The state-change listener you set up in Task 2 fires with the new `FusabaseUser`, which updates `self.user` and flips the root view from `AuthView` to `RecipeListView`.

    `isLoading` toggles around the call so the **Sign Up** button can show a spinner; `errorMessage` is reset at the start so a stale error from a previous attempt doesn't linger.

4. Save the file.

## Task 4: Implement signIn

1. Find the `signIn(email:password:)` stub.

    ```swift
    func signIn(email: String, password: String) async throws {
        // TODO: Implement in Lab 3
        fatalError("AuthService.signIn — implement in Lab 3")
    }
    ```

2. Replace the body with this:

    ```swift
    <copy>func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            _ = try await FusabaseAuth.auth().signIn(withEmail: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }</copy>
    ```

    ![Xcode project navigator with Services > AuthService.swift selected](images/signin.png =70%x*)

3. `signIn(withEmail:password:)` authenticates an existing user. Same shape as `signUp` — the auth state listener does the work of updating `self.user`. If the credentials are wrong, the SDK throws and `errorMessage` is set so the auth view can display "incorrect email or password."

4. Save the file.

## Task 5: Implement signOut

1. Find the `signOut()` stub.

    ```swift
    func signOut() async throws {
        // TODO: Implement in Lab 3
        fatalError("AuthService.signOut — implement in Lab 3")
    }
    ```

2. Replace the body with this:

    ```swift
    <copy>func signOut() async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await FusabaseAuth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }</copy>
    ```

    ![Xcode project navigator with Services > AuthService.swift selected](images/signout.png =70%x*)


3. `signOut()` ends the current session. The auth state listener fires with `nil`, `self.user` becomes nil, and the root view switches back to `AuthView`.

4. Save the file.

## Task 6: Create an app user

1. Press **Cmd+R** to build and run.

2. The Simulator launches to the **Sign In** screen. Toggle to **Sign Up** mode.

3. Enter a test account (for example `test@test.com` / `test1234`) and tap **Sign Up**.

    The app calls `signUp`, the SDK creates the account, the state listener fires, and the root view replaces `AuthView` with the recipe list automatically.

    > **Note:** The recipe list shows an **Add Demo Recipes** button, but it's **disabled (greyed out)** until you implement `loadRecipes` in Lab 4. That's expected — the button stays disabled to prevent accidental duplicate writes before the list can refresh. For now, you've verified that auth navigates past the sign-in screen, which is the goal of this lab.

    ![Sign-up screen with test credentials filled in](images/user.gif =30%x*)
    ![Recipe list shown after successful sign-up](images/task-6-signed-in.png =30%x*)


7. Open the Fusabase console in your browser and navigate to **Authentication**. The user account you just created should be listed. You've just added your first app user!

    ![Fusabase console authentication screen with the new user listed](images/task-6-console-user.png =60%x*)


8. Leave the app and console open for the next lab.

If sign-up or sign-in throws unexpectedly, see the Appendix.

## Appendix

### Troubleshooting

- **"Sign-up succeeds in the SDK but the app doesn't switch screens."** Your `listenToAuthState` body might still be the stub. The published `user` only updates from inside the listener — without it, `signUp`/`signIn` silently authenticate the user without telling SwiftUI. Confirm the Task 2 code is in place and rebuild.

- **"Email already in use."** The Fusabase auth store remembers users between runs. Sign in with the existing password instead, or pick a different email. There's no "delete user" flow in this workshop.

- **"Auth network error."** Confirm your `fusabase-config.json` from Lab 2 is correct and your local Fusabase compose stack is running. Run `curl http://localhost:8080/ords/` from a terminal.

- **"Build error: cannot find FusabaseUser in scope."** The file imports `FusabaseAuth` at the top — don't remove it. `FusabaseUser` and `AuthStateDidChangeListenerHandle` are both vended by that module.

- **"App stays on Sign In screen even after restart, but I was signed in."** The state listener may not be re-attaching on cold launch. Confirm `init()` calls `listenToAuthState()` (it does in the starter — don't change it).

> **Want a clean copy?**
>
> A copy of `AuthService.swift` as it should look after this lab is available at `checkpoints/AuthService-after-lab-3.swift`. Drop it into `starter/RecipeShare/Services/` any time you'd like a fresh baseline before moving on. Keep your own `starter/RecipeShare/Resources/fusabase-config.json` — checkpoints don't include your project config.

You may now **proceed to the next lab**.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Last Updated By/Date** - Killian Lynch, May 2026
