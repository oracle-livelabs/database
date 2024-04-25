# Tables in LiveLabs

## Tables are cool!

You can define a table in Markdown just like so:

```
| Tables        |      Are      |  Cool |
| ------------- | :-----------: | ----: |
| **col 3 is**  | right-aligned | $1600 |
| col 2 is      |  *centered*   |   $12 |
| zebra stripes | ~~are neat~~  |    $1 |
```
The result looks like this:

| Tables        |      Are      |  Cool |
| ------------- | :-----------: | ----: |
| **col 3 is**  | right-aligned | $1600 |
| col 2 is      |  *centered*   |   $12 |
| zebra stripes | ~~are neat~~  |    $1 |

You can see that there is a default table caption provided which is by default a concatenation of the workshop title and the lab title.

If you don't like the default, you can also provide your own table title by adding the below the table definition:

```
{: title="My table title"}
```

The complete markdown looks like this:

```
| Tables        |      Are      |  Cool |
| ------------- | :-----------: | ----: |
| **col 3 is**  | right-aligned | $1600 |
| col 2 is      |  *centered*   |   $12 |
| zebra stripes | ~~are neat~~  |    $1 |
{: title="My table title"}
```

Now our table looks like this:

| Tables        |      Are      |  Cool |
| ------------- | :-----------: | ----: |
| **col 3 is**  | right-aligned | $1600 |
| col 2 is      |  *centered*   |   $12 |
| zebra stripes | ~~are neat~~  |    $1 |
{: title="My table title"}

As you can see, the numbering is added automatically.

Isn't that cool?

You can also refer to the [LiveLabs Markdown Cheatsheet](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/labfiles/LiveLabs_MD_Cheat_Sheet.pdf)