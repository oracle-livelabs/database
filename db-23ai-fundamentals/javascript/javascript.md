# Using JavaScript Stored Procedures in Oracle Database 23ai

## Introduction

Welcome to JavaScript Stored Procedures in Oracle Database 23ai! Imagine you're building a small online bookstore. Traditionally, you'd need to write all your business logic (like calculating prices, discounts, and shipping) in PL/SQL. But what if you're more comfortable with JavaScript? Good news! With Oracle Database's Multilingual Engine (MLE), you can now write this logic in JavaScript and run it directly inside the database.

Think of it like having a JavaScript engine inside your database. Instead of sending data back and forth between your application and the database, you can process it right where it lives - in the database itself. This makes your applications faster and simpler to maintain.

Estimated Lab Time: 15 minutes

### Objectives:
* Create JavaScript stored procedures for bookstore calculations
* Work with JavaScript modules for price processing
* Run dynamic JavaScript code for testing
* Look at basic debugging techniques

### Prerequisites:
* Access to Oracle Database 23ai
* Basic understanding of JavaScript and SQL

## Task 1: Creating Your First JavaScript Stored Procedure

1. In this task, we'll create a simple function to calculate book discounts. Let's break down what we're doing and why each step matters.
    
    First, let's access our SQL workspace. If you haven't done so already, from the Autonomous Database home page, **click** Database Actions and then **click** SQL.
    ![click SQL](../common-images/im1.png =50%x*)

    Using the ADMIN user isn’t typically advised due to the high level of access and security concerns it poses. **However**, for this demo, we’ll use it to simplify the setup and ensure we can show the full range of features effectively. 

2. Before we begin, this lab will be using Database Actions Web. If you're unfamiliar, please see the picture below for a simple explanation of the tool. You can click on the photo to enlarge it.

    ![click SQL](images/simple-db-actions.png =50%x*)


3. Now, let's create our first JavaScript function. We'll start with something simple - calculating a discounted book price:

    ```
    <copy>
    create or replace mle module bookstore_module 
    language javascript as
    /**
     * Calculates the final price after discount
     * @param {number} price - Original book price
     * @param {number} discountPercent - Discount percentage (e.g., 20 for 20% off)
     * @returns {number} The final price after discount
     */
    function calculateDiscountedPrice(price, discountPercent) {
        const discount = price * (discountPercent / 100);
        return price - discount;
    }
    export { calculateDiscountedPrice }
    /
    </copy>
    ```

    Let's break this down:
    - `CREATE OR REPLACE MLE MODULE` tells Oracle to create a new JavaScript module (or replace it if it already exists)
    - The function takes two parameters: the original price and the discount percentage
    - We calculate the discount amount and subtract it from the original price
    - The `export` statement makes our function available to be called from SQL and PL/SQL

    ![click SQL](images/im7.png =50%x*)


4. Now we need to create a way to call our JavaScript function from SQL. This is called a "wrapper function":

    ```
    <copy>
    create or replace function get_final_price(
        price number,
        discount number
    ) return number as
    mle module bookstore_module
    signature 'calculateDiscountedPrice';
    /
    </copy>
    ```

    This wrapper acts as a connection between SQL and JavaScript:
    - It takes the same parameters as our JavaScript function
    - `MLE MODULE bookstore_module` tells Oracle which JavaScript module to use
    - `SIGNATURE 'calculateDiscountedPrice'` says which function to call in that module

    ![wrapper](images/im8.png =50%x*)


5. Now comes the fun part - testing our function. Let's calculate the price of a $20 book with a 20% discount:

    ```
    <copy>
    select get_final_price(20, 20) as final_price;
    </copy>
    ```

    The function took our $20 book, applied a 20% discount ($4 off), and returned the final price of $16.

    ![wrapper](images/im9.png =50%x*)


## Task 2: Working with JavaScript Modules

Now that we understand basic functions, let's take it a step further. We'll add shipping calculations and show how different JavaScript modules can work together. 

1. First, we need to set up an environment that tells the database how our modules will work together:

    ```
    <copy>
    create or replace mle env bookstore_env
    imports (
        'bookstore_module' module bookstore_module
    );
    </copy>
    ```

    This tells JavaScript where to find different pieces of code. Here, we're saying "when code asks for 'bookstore_module', use the module we created earlier."

    ![wrapper](images/im10.png =50%x*)


2. Now let's create a new module that handles shipping calculations:

    ```
    <copy>
    create or replace mle module shipping_module
    language javascript as
    import * as bookstore from "bookstore_module";

    /**
     * calculates total cost including shipping
     * @param {number} price - book price
     * @param {number} discount - discount percentage
     * @param {number} weight - book weight in pounds
     * @returns {number} total cost including shipping
     */
    export function calculateTotalWithShipping(price, discount, weight) {
        const baseShippingRate = 2;  // $2 base rate
        const pricePerPound = 1.5;   // $1.50 per pound
        
        // First calculate the discounted price using our previous function
        const finalPrice = bookstore.calculateDiscountedPrice(price, discount);
        
        // Calculate shipping based on weight
        const shippingCost = baseShippingRate + (weight * pricePerPound);
        
        // Log the breakdown for transparency
        console.log(`Book price after discount: $${finalPrice}`);
        console.log(`Shipping cost: $${shippingCost}`);
        
        return finalPrice + shippingCost;
    }
    /
    </copy>
    ```

    Let's examine what's happening here:
    - `import * as bookstore` lets us use functions from our previous module
    - We define shipping costs: $2 base rate plus $1.50 per pound
    - We first calculate the discounted price using our previous function
    - Then we calculate shipping based on the book's weight
    - `console.log` prints information we can see when running the function
    - Finally, we return the total cost (discounted price + shipping)

    ![wrapper](images/im11.png =50%x*)


3. Just like before, we need to create a wrapper function to call our shipping calculator from SQL:

    ```
    <copy>
    create or replace function get_total_with_shipping(
        price number,
        discount number,
        weight number
    ) return number as
    mle module shipping_module
    env bookstore_env
    signature 'calculateTotalWithShipping';
    /
    </copy>
    ```

    Notice something new here? We added `ENV bookstore_env` - this tells Oracle to use the environment we created that knows about our modules.
    ![wrapper](images/im12.png =50%x*)


4. Let's test our shipping calculator with a real example - a $20 book that's 20% off and weighs 2 pounds:

    ```
    <copy>
    select get_total_with_shipping(20, 20, 2) as total_cost;
    </copy>
    ```

    Let's break down what happened:
    - original price: $20
    - after 20% discount: $16
    - shipping: $2 base + (2 pounds × $1.50) = $5
    - total cost: $16 + $5 = $21

    ![wrapper](images/im13.png =50%x*)


## Task 3: Dynamic JavaScript Execution

Sometimes you want to try out JavaScript code quickly without creating permanent modules. Oracle 23ai provides the DBMS_MLE package for this purpose.

1. Let's try some quick price calculations for different books:

    ```
    <copy>
    declare
        l_ctx dbms_mle.context_handle_t;
    begin
        dbms_output.enable(null);
        l_ctx := dbms_mle.create_context();
        
        dbms_mle.eval(
            context_handle => l_ctx,
            language_id => 'JAVASCRIPT',
            source => q'~
                // Create an array of books with prices and discounts
                const books = [
                    {name: "JavaScript Guide", price: 29.99, discount: 15},
                    {name: "Database Basics", price: 24.99, discount: 10}
                ];
                
                // Calculate final price for each book
                books.forEach(book => {
                    const finalPrice = book.price * (1 - book.discount/100);
                    console.log(`${book.name}: $${finalPrice.toFixed(2)} (${book.discount}% off)`);
                });
            ~'
        );
        
        dbms_mle.drop_context(l_ctx);
    end;
    /
    </copy>
    ```

    Let's understand what's happening here:
    - `dbms_mle.create_context()` creates a temporary javascript environment
    - we use the q'~...~' syntax to write multiple lines of javascript
    - we create an array of books, each with a name, price, and discount
    - the foreach loop processes each book and calculates its final price
    - `tofixed(2)` formats the price to show exactly 2 decimal places
    - finally, we clean up by dropping the context

    ![wrapper](images/im14.png =50%x*)


## Task 4: Simple Debugging

When writing JavaScript code, things don't always work perfectly the first time. Let's learn how to add debug messages to help us understand what's happening in our code.

1. Here's an example that shows step-by-step what's happening in our calculations:

    ```
    <copy>
    declare
        l_ctx dbms_mle.context_handle_t;
    begin
        dbms_output.enable(null);
        l_ctx := dbms_mle.create_context();
        
        dbms_mle.eval(
            context_handle => l_ctx,
            language_id => 'JAVASCRIPT',
            source => q'~
                function calculateOrder(bookPrice, quantity, discountPercent) {
                    // Start with basic information
                    console.log(`Debug: Starting calculation for order...`);
                    console.log(`Debug: Input values:`);
                    console.log(`  - Book price: $${bookPrice}`);
                    console.log(`  - Quantity: ${quantity}`);
                    console.log(`  - Discount: ${discountPercent}%`);
                    
                    // Calculate subtotal
                    const subtotal = bookPrice * quantity;
                    console.log(`Debug: Subtotal (${bookPrice} × ${quantity}): $${subtotal}`);
                    
                    // Calculate discount amount
                    const discount = subtotal * (discountPercent / 100);
                    console.log(`Debug: Discount calculation:`);
                    console.log(`  - ${discountPercent}% of $${subtotal}`);
                    console.log(`  - Discount amount: $${discount}`);
                    
                    // Calculate final price
                    const final = subtotal - discount;
                    console.log(`Debug: Final price: $${final}`);
                    return final;
                }
                
                // Test the function with a real order
                console.log('Testing order calculation...');
                calculateOrder(19.99, 3, 15);
            ~'
        );
        
        dbms_mle.drop_context(l_ctx);
    end;
    /
    </copy>
    ```
    ![wrapper](images/im15.png =50%x*)

    These debug messages help you:
    - Verify that your function received the right values
    - Check the calculation steps are working like you expect them to 
    - Find where things might be going wrong if you get unexpected results

2. In this workshop, you've learned how to:
    1. Create JavaScript functions that run inside the database
    2. Connect JavaScript modules together to build more complex functionality
    3. Run quick JavaScript tests using dynamic execution
    4. Add debug messages to help troubleshoot your code


## Learn More

* [JavaScript Programming in Oracle Databas](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/index.html)
* [DBMS_MLE Package Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/DBMS_MLE.html)

## Acknowledgements
* **Author** - Killian Lynch, Database Product Management
* **Contributors**
* **Last Updated By/Date** - Killian Lynch, December 2024
