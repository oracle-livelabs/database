# Final Quiz

```quiz-config
passing: 75
badge: images/badge.png
```

## Introduction

This final quiz checks the key Seer Equity concepts from the workshop. Use it to confirm that you can connect the application story to Oracle Database features.

### Objectives

- Check your understanding of the Seer Equity architecture.
- Reinforce the database features used in the labs.
- Confirm that you can separate source-backed behavior from optional setup.

Estimated Time: 10 minutes

## Final Quiz

Answer all eight questions. You need a passing score of 75 percent. Each question has one correct answer.

```quiz score
Q: What is the best description of the Seer Equity backend API layer in this workshop?
* Express routes connect directly to Oracle Database with node-oracledb.
- ORDS is the only API layer used by the React app.
- The frontend reads database tables directly with SQLcl.
- The quiz service generates all database responses.
> The source-backed API layer is Express with node-oracledb. ORDS can appear in deployment files, but the app routes use the Express backend.

Q: Which package root is the source of truth for schema, SQL, PL/SQL, and database feature behavior?
- frontend-source/
* database-source/
- backend-source/
- workshops/
> The workshop treats database-source/ as the technical truth for objects such as tables, views, VPD policies, graph definitions, vector objects, spatial functions, and agent tables.

Q: Why does the workshop preserve object names such as orders, products, and social_posts even when the prose uses finance terms?
- The names are placeholders that learners should rename before every query.
* They are source-owned compatibility names that the SQL and application routes still use.
- They prove that the application is not a finance application.
- They exist only in screenshots and not in the database.
> The app is finance-branded, but some source objects keep compatibility names. The workshop uses finance-friendly explanations while keeping runnable SQL object names intact.

Q: What does JSON Relational Duality help the application do?
- Replace every relational table with a file-based document store.
* Return document-shaped JSON while Oracle preserves relational data and SQL access.
- Disable constraints so the frontend can write any payload.
- Convert spatial data into graph edges automatically.
> Duality views let an app consume JSON documents while the database still manages relational structures and SQL access.

Q: In the vector search lab, what does a lower cosine distance indicate?
* A closer semantic match between the query vector and stored embedding.
- A weaker match that belongs at the top of the ranking.
- A larger transaction amount.
- A VPD policy failure.
> The workshop ranks vector matches by distance. Lower distance means the vectors are closer for the chosen distance metric.

Q: Which Oracle feature supports the financial crime network investigation tasks?
- Unified auditing only
- JSON search indexes only
* Property Graph with SQL/PGQ GRAPH_TABLE queries
- SQL Loader control files
> The graph lab uses source-backed property graph objects and GRAPH_TABLE queries to explore connected risk entities and relationships.

Q: What does sc_security_ctx.set_user_context help demonstrate?
- Vector embedding generation
* VPD-aware role and region filtering for demo users
- JSON serialization formatting
- Frontend CSS theming
> The backend can pass a demo user context, and the database package sets context for VPD policy behavior.

Q: Why does the workshop treat Select AI and agent setup as optional?
- The application has no AI-related files.
- The quiz requires external certification content.
* Those scripts depend on database packages, OCI credentials, network access, and model availability.
- Oracle Database cannot store agent logs.
> The package includes AI profiles and agent objects, but full setup depends on environment-specific services and credentials. The workshop avoids overclaiming turnkey behavior.
```

## Review your result

If you missed a question, return to the related lab and review the source-backed explanation. Confirm that you can explain the path from Seer Equity screens to Express routes and Oracle Database objects. Confirm that you can identify optional setup items before you run them in a real environment.

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle LiveLabs, May 2026
