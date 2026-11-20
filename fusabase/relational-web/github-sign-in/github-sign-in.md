# Add GitHub sign-in

## Introduction

In this optional lab, you will add GitHub sign-in to your app with the Oracle Backend with Supabase APIs JavaScript SDK. When you are done, users can sign in with GitHub and RSVP with their GitHub display name.

### Objectives

In this lab, you will:

- register a GitHub OAuth app with the Fusabase redirect URI
- save the GitHub credentials in the Fusabase console
- sign in with GitHub using `client.auth.signInWithOAuth()`
- check the account, RSVP name, restored session, and sign-out

Estimated Time: 15 minutes

### Prerequisites

This lab assumes you have:

- Successfully completed Labs 1–3. You need Labs 4–7 only to check events and RSVPs.
- A GitHub account that can create OAuth apps, with a profile **Name** set, such as Alex Gather.
- A GitHub primary email not already registered in LiveLab through another provider.
- The local backend and `python3 -m http.server 8000` running.

## Task 1: Check the origin and copy the redirect URI

1. In the Fusabase console, open **LiveLab > Project settings > Authorized domains**. You should see `http://localhost:8000` in the list.

    ![Authorized domains showing the local browser origin](images/authorized-domains.png)

2. If it's missing, click **Add domain**, enter `http://localhost:8000` in **Domain name**, and click **Add domain**.

    ![Add domain dialog showing the local browser origin and Add domain](images/add-domain.png)

3. Open **LiveLab > Authentication > Social login**. Click the edit pencil beside **Github**, or choose **Add new provider > Github**.

4. Turn **Enable** on and click **Copy URI**. Keep the dialog open. The URI ends with `/callback`.

    ![Fusabase GitHub configuration with Enable and Copy URI highlighted](images/provider-config.png)

## Task 2: Register a GitHub OAuth app

1. Open [GitHub Developer settings](https://github.com/settings/developers) in a new tab. Select **OAuth Apps > New OAuth App**, or **Register a new application** if this is your first app.

2. Enter these values:

    | Field | Value |
    | --- | --- |
    | Application name | `livelabs-app` |
    | Homepage URL | `http://localhost:8000` |
    | Application description | Optional |
    | Redirect URI (or Authorization callback URL) | The complete URI you copied in Task 1 |

    Leave wildcard matching and Device Flow off. Don't use the local `/starter/` or `/finished/` URL as the callback.

    ![GitHub OAuth app registration with the name, homepage, and callback fields highlighted](images/github-register.png)

3. Click **Register application**. Copy the **Client ID**, then click **Generate a new client secret** and copy the secret right away. If you're reusing an earlier workshop app, use its saved credentials instead.

    ![GitHub OAuth settings showing Client ID and Generate a new client secret](images/github-credentials.png)

## Task 3: Save the GitHub credentials

1. Return to **Configure Github** in the Fusabase console. Paste the GitHub **Client Id** and **Client Secret**, then click **Save**.

2. You should see **Enabled** in the **Github** row.

    ![Fusabase Social login showing Github Enabled](images/provider-enabled.png)

## Task 4: Complete the GitHub action

> Note: If you skipped Lab 8, leave the `googleSignIn` TODO in place. In step 4, use the GitHub-only line.

1. In VS Code, open `starter/actions.js`. GitHub sign-in uses `client.auth`, so you don't need an HTML edit. The **Continue with GitHub** button calls `githubSignIn(client)`.

2. Find `githubSignIn` near the end of the file. Select the whole placeholder function, including its declaration and closing brace. Leave `googleSignIn` as it is.

    ![VS Code selecting the GitHub placeholder with the Google action retained](images/github-before.png)

3. `client.auth.signInWithOAuth()` starts sign-in with a configured provider. Read the code in three parts:

    - `provider: 'github'` selects the provider you enabled.
    - `skipBrowserRedirect: true` opens a popup and waits for it to finish, so your app's page stays open.
    - Check `error` and show a helpful message. The returned `data` holds provider details. The existing `watchAuth()` listener gets the user and reads `user.user_metadata.full_name`.

    Replace the selection with this complete function and save:

    ```javascript
    // Lab 9: Optional GitHub sign-in through the configured backend provider.
    export async function githubSignIn(client) {
      const { data, error } = await client.auth.signInWithOAuth({
        provider: 'github',
        options: { skipBrowserRedirect: true }
      });
      if (error) {
        throw new Error(
          'GitHub sign-in did not finish. Allow popups and check the Lab 9 provider setup, or use email/password.'
        );
      }
      return data;
    }
    ```

    ![VS Code showing the completed GitHub SDK action](images/github-after-ordered.png)

4. Find `socialProviders` above `googleSignIn` and add `'github'` to show its button. If you completed Lab 8, use:

    ```javascript
    export const socialProviders = ['google', 'github'];
    ```

    If you skipped Lab 8, use:

    ```javascript
    export const socialProviders = ['github'];
    ```

    Save the file.

    ![VS Code selecting the provider visibility line](images/providers-before-ordered.png)

    ![VS Code showing both optional providers enabled in actions.js](images/providers-after.png)

## Task 5: Verify GitHub sign-in in your app

1. Reload `http://localhost:8000/starter/`. If you're signed in, open **Account > Sign out**.

2. Click **Sign in > Continue with GitHub**. The sign-in dialog shows a button for each provider you configured.

    ![Gather sign-in with both configured optional provider buttons](images/github-signin.png)

    ![Gather sign-in with GitHub enabled and Google skipped](images/github-only-signin.png)

3. In the popup, review GitHub's request to read your profile and email addresses, not repositories. If the app name and callback match your setup, authorize it.

4. When the popup closes, open **Account**. You should see your GitHub display name. Reload and open **Account** again. You should still be signed in.

    ![Gather Account showing the display name returned by GitHub](images/github-account.png)

5. If you completed Labs 4–7, create an event or open an invitation link. Save an RSVP and click **View guest list**. You should see your name and response, but no email addresses.

    ![Persisted RSVP and guest list showing the GitHub display name](images/github-rsvp.png)

6. Open **Account > Sign out**. You should see **Sign in** again, with no organizer controls or guest list. Signing out of your app doesn't sign you out of GitHub.

    ![Gather after sign-out with public event details and the guest-list prompt](images/github-signed-out.png)

7. To skip GitHub, remove `'github'` from `socialProviders` and use **Sign in** with your email and password.

    ![Gather email/password sign-in with both optional providers skipped](images/github-skipped.png)

8. If `starter/actions.js` does not work after this lab, navigate to the `checkpoints` folder in your repo, open `lab-9/actions.js`, and use that file's contents to replace `starter/actions.js`. Keep your own `starter/config.js`. If you skipped Lab 8, change `socialProviders` to `['github']` in that file.

## Troubleshooting

- **GitHub rejects the redirect URI:** make the callback URL in GitHub match **Copy URI** exactly, then save the GitHub settings.
- **Identity provider unavailable:** check that GitHub is enabled and both credentials come from one OAuth app.
- **Error signing user through IdP:** your GitHub primary email may already belong to another LiveLab account. Use that sign-in method or another GitHub account. Don't delete the existing account to work around the error.
- **The popup is blocked, canceled, or fails:** allow popups for `http://localhost:8000`. Close old popups, hard-reload your app, and retry in a private window.
- **Different accounts show different events:** open the event's invitation link to RSVP with another account.

You may now **proceed to the next lab**.

## Acknowledgements

* **Author** - Killian Lynch, Senior Product Manager, Oracle AI Database
* **Last Updated By/Date** - Killian Lynch, November 2026
