# Integration

## Introduction
Connect your search service to your applications using the provided developer tools.

**Estimated time:** 20 minutes.

### Objectives
* Integrate the Javascript search widget.
* Utilize the PL/SQL API for custom search experiences.

## Task 1: Embed the Javascript Widget
For a rapid deployment, you can use the out-of-the-box **Javascript search widget** which can be added to any webpage. This widget handles the communication with the backend API and renders search results for the user.

## Task 2: Call the PL/SQL API
Developers needing full control over the look and feel can call the **PL/SQL API** directly. You can test the underlying vector similarity logic using a SQL statement similar to this to find semantically relevant documents:

```sql
SELECT match_document 
FROM   search_targets 
WHERE  space_id = :my_space 
ORDER  BY VECTOR_DISTANCE(target_vector, :user_query_vector)
FETCH FIRST 1 ROWS ONLY;
```
The API will return the **JSON match document** for your application to interpret and execute the next deterministic step.

You may now **proceed to the next lab**

## Acknowledgements
**Authors**
* Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - March, 2026
