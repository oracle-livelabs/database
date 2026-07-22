# Ship It Like It's 2015 — The Embedded Menu (MongoDB API)

## Introduction

You are the lead developer for a five-store restaurant franchise, and you model it the way the document world taught us all: **one embedded document per store** — menus inside the store, categories inside the menus, items inside the categories. The whole application object in one read.

This lab is the bet. You place it with unchanged MongoDB tooling running against Oracle Autonomous AI Database, and you enjoy exactly what made document databases famous. Write the margin note now: *what happens when corporate changes one price?*

Estimated Lab Time: 8 minutes

### Objectives

* Create and seed the `stores` collection through the MongoDB API
* Run the point read and projected read that make the document model feel great
* Record the three-dials bet you just placed

## Task 1: Seed the Franchise

1. In **mongosh**, paste the seed (also in `scripts/01_seed_stores.mongo.js`). Five stores; note that **all five sell the Classic Cheeseburger (`item_id: 1000`)** — chain menu, chain item. That detail becomes load-bearing in Lab 3.

    ```
    <copy>
    db.stores.insertMany([
      { "_id": "s_100", "name": "Burger Palace",
        "menus": [ { "menu_id": 10, "name": "Lunch Menu",
          "categories": [ { "category_id": 100, "name": "Burgers",
            "items": [
              { "item_id": 1000, "name": "Lunch Classic",
                "description": "Char-grilled smash patty, aged cheddar, brioche bun",
                "price": 1299, "active": true },
              { "item_id": 1002, "name": "French Fries",
                "description": "Twice-fried golden potato fries with sea salt",
                "price": 499, "active": true } ] } ] } ] },
      { "_id": "s_101", "name": "Burger Palace Uptown",
        "menus": [ { "menu_id": 11, "name": "Lunch Menu",
          "categories": [ { "category_id": 110, "name": "Burgers",
            "items": [
              { "item_id": 1000, "name": "Classic Cheeseburger",
                "description": "Char-grilled smash patty, aged cheddar, brioche bun",
                "price": 1299, "active": true },
              { "item_id": 1003, "name": "Garden Salad",
                "description": "Crisp greens, heirloom tomato, house vinaigrette",
                "price": 899, "active": true } ] } ] } ] },
      { "_id": "s_102", "name": "Noodle House",
        "menus": [ { "menu_id": 12, "name": "All Day Menu",
          "categories": [ { "category_id": 120, "name": "Wok",
            "items": [
              { "item_id": 2001, "name": "Szechuan Tofu Stir-Fry",
                "description": "Crispy tofu, fiery chili-garlic sauce, seasonal vegetables, no meat",
                "price": 1199, "active": true },
              { "item_id": 2002, "name": "Beef Chow Fun",
                "description": "Wide rice noodles, wok-seared beef, scallion",
                "price": 1399, "active": true },
              { "item_id": 1000, "name": "Classic Cheeseburger",
                "description": "Char-grilled smash patty, aged cheddar, brioche bun",
                "price": 1299, "active": true } ] } ] } ] },
      { "_id": "s_103", "name": "Taco Verde",
        "menus": [ { "menu_id": 13, "name": "Lunch Menu",
          "categories": [ { "category_id": 130, "name": "Tacos",
            "items": [
              { "item_id": 3001, "name": "Carnitas Taco Plate",
                "description": "Slow-braised pork, salsa verde, corn tortillas",
                "price": 1099, "active": true },
              { "item_id": 1000, "name": "Classic Cheeseburger",
                "description": "Char-grilled smash patty, aged cheddar, brioche bun",
                "price": 1299, "active": true } ] } ] } ] },
      { "_id": "s_104", "name": "Burger Palace Airport",
        "menus": [ { "menu_id": 14, "name": "All Day Menu",
          "categories": [ { "category_id": 140, "name": "Burgers",
            "items": [
              { "item_id": "1000", "name": "Classic Cheeseburger",
                "description": "Char-grilled smash patty, aged cheddar, brioche bun",
                "price": 1299, "active": true },
              { "item_id": 1002, "name": "French Fries",
                "description": "Twice-fried golden potato fries with sea salt",
                "price": 499, "active": true } ] } ] } ] }
    ])
    </copy>
    ```

    **What you should see:** `insertedCount: 5` (mongosh prints it as `insertedIds` with five entries and `acknowledged: true`).

    > Look closely at `s_104`: an old ingest script wrote its `item_id` as the **string** `"1000"`. Nothing complained. Remember that.

## Task 2: Enjoy the 90%

1. The point read that made document databases famous:

    ```
    <copy>
    db.stores.findOne({ _id: "s_100" })
    </copy>
    ```

    **What you should see:** the entire Burger Palace menu in one read. That's just your application object — no joins, no ORM, no mapping layer. This is Part 1 of the Ask Tom sessions in one line: *store data the way you use it.*

2. A projected read — just names and prices:

    ```
    <copy>
    db.stores.findOne(
      { _id: "s_100" },
      { name: 1, "menus.categories.items.name": 1, "menus.categories.items.price": 1 }
    )
    </copy>
    ```

    **What you should see:** the same document, trimmed to the fields you asked for.

## Task 3: Record the Bet

![The three dials — every pattern is a bet on these settings](images/three-dials.svg "The three dials")

You just set three dials, whether you meant to or not:

| Dial | Your setting |
|---|---|
| Pattern complexity | LOW — one dominant read (the store's menu) |
| Read/write mix | Read-heavy — menus rarely change |
| Update size vs read size | Whole-document reads; and, so far, no updates |

The embedded model is the *correct* choice for these settings. Every document pattern is a bet on these dials. Margin note for Lab 3: **what happens when corporate changes one price on a chain-wide item?**

> A JSON collection created through the MongoDB API is also reachable through **SODA**, Oracle's native document API — same collection, another door. We don't exercise SODA today.

## Learn More

* [Modeling for the Access Pattern (Ask Tom series)](https://asktom.oracle.com/)

## Acknowledgements
* **Author** - Rick Houlihan, Field CTO, Oracle Data & AI Platform
* **Last Updated By/Date** - Rick Houlihan, July 2026
