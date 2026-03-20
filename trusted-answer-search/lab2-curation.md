## Curating the Language-to-Report Mapping

Step 1: Create a Search Space Create your first Search Space (e.g., "FINANCE"). Search spaces allow you to group related reports and manage them as a single logical domain.

Step 2: Define Search Targets Add Search Targets to your space. Each target represents a specific outcome, such as an HSA activity report or a checking account summary. Every target is associated with a match document (JSON) that tells your application exactly what to do when a match is found.

Step 3: Prime the AI with Curated Descriptions For each target, add several sample queries that users might ask (e.g., "How is my HSA doing?"). The system uses vector similarity to rank these curated descriptions against incoming user questions.

Step 4: Configure Parameter Extraction Set up Target Value Sets to identify specific variables in a query, such as a date, category, or account type. When configured, the system extracts these values and includes them in the returned JSON document, allowing your application to automatically filter reports for the user.
