# Lab 7: Build an Agent Context Tool

## Introduction

Turn the semantic-search pattern from Lab 6 into a reusable, read-only Python function that an agent can call for current-request context. The function combines natural-language search with optional metadata filters and returns compact, structured park information for the agent to use.

Estimated Time: X

### Objectives

- Define a clear function contract for an agent-facing retrieval tool.
- Convert tool arguments into safe metadata filters.
- Run semantic search with optional geographic and record exclusions.
- Return compact, JSON-serializable context with source identifiers.
- Describe the function with a framework-neutral tool schema.

### Prerequisites

- Complete Lab 6: Run Baseline Semantic Search.
- Keep the `vecdb` client initialized in your OML Notebook.
- Keep the `parks` table loaded with the National Parks records.

## Task 1: Define the Context Tool Contract

An agent tool should have a small, predictable interface. The required `query` describes the information the agent needs. Optional `states` and `exclude_park_codes` values constrain retrieval, while `top_k` limits the amount of context returned.

The function will search the existing `parks` table. It will not create a table, write records, save conversation history, or modify the database.

1. Add a new Python paragraph and run the following code to define the function signature and validate its inputs.

    ```python
    %python
    from typing import Optional

    def normalize_filter_values(values, field_name, transform):
        if values is None:
            return []
        if not isinstance(values, list) or any(
            not isinstance(value, str) or not value.strip()
            for value in values
        ):
            raise ValueError(f"{field_name} must be a list of non-empty strings")
        return [transform(value.strip()) for value in values]

    def validate_context_tool_inputs(
        query: str,
        states: Optional[list[str]] = None,
        exclude_park_codes: Optional[list[str]] = None,
        top_k: int = 5,
    ):
        if not isinstance(query, str) or not query.strip():
            raise ValueError("query must be a non-empty string")

        if isinstance(top_k, bool) or not isinstance(top_k, int) or not 1 <= top_k <= 10:
            raise ValueError("top_k must be an integer from 1 through 10")

        clean_states = normalize_filter_values(states, "states", str.upper)
        clean_exclusions = normalize_filter_values(
            exclude_park_codes,
            "exclude_park_codes",
            str.lower,
        )

        return query.strip(), clean_states, clean_exclusions, top_k
    ```

2. Confirm that the paragraph completes without an error. The validation keeps the tool bounded and prevents an empty request from being sent to the database.

3. Confirm that malformed filter values are rejected instead of being silently ignored.

    ```python
    %python
    try:
        validate_context_tool_inputs(
            query="waterfalls",
            states=["MD", 7],
        )
    except ValueError as error:
        print(error)
    ```

    The paragraph should print a validation error. Rejecting the request prevents an invalid filter from accidentally becoming an unfiltered search.

## Task 2: Build Metadata Filters from Tool Arguments

The agent can provide optional constraints without needing to know the VecDB filter syntax. The function translates those arguments into the `$and`, `$in`, and `$ne` expressions introduced in Lab 6.

1. Add a new Python paragraph and run the following code.

    ```python
    %python
    def build_park_filters(states=None, exclude_park_codes=None):
        clauses = []

        if states:
            clauses.append({"states": {"$in": states}})

        for park_code in exclude_park_codes or []:
            clauses.append({"park_code": {"$ne": park_code}})

        if not clauses:
            return None
        if len(clauses) == 1:
            return clauses[0]
        return {"$and": clauses}
    ```

2. Add a new Python paragraph and run the following code to inspect the filter produced for a restricted request.

    ```python
    %python
    example_filters = build_park_filters(
        states=["DC", "MD"],
        exclude_park_codes=["whho"],
    )

    print(example_filters)
    ```

3. Review the output. The filter requires a park to match one of the requested states and excludes the White House record. With no optional arguments, the helper returns `None`, allowing an unfiltered semantic search.

## Task 3: Create the Agent Context Function

The context function is the tool boundary. It calls `vecdb.query()` with text and the generated filters, then projects each result into a compact dictionary. The agent receives useful source content and identifiers rather than database-specific response objects or embedding vectors.

1. Add a new Python paragraph and run the following code.

    ```python
    %python
    def search_parks_context(
        query: str,
        states: Optional[list[str]] = None,
        exclude_park_codes: Optional[list[str]] = None,
        top_k: int = 5,
    ):
        """Return National Parks context for an agent's current request."""
        query, states, exclude_park_codes, top_k = validate_context_tool_inputs(
            query=query,
            states=states,
            exclude_park_codes=exclude_park_codes,
            top_k=top_k,
        )

        result = vecdb.query(
            table_name="parks",
            query_by={"text": query},
            filters=build_park_filters(
                states=states,
                exclude_park_codes=exclude_park_codes,
            ),
            top_k=top_k,
        )

        context = []
        for item in result.items or []:
            metadata = item.metadata or {}
            context.append(
                {
                    "id": item.id,
                    "park_code": metadata.get("park_code"),
                    "name": metadata.get("name"),
                    "states": metadata.get("states"),
                    "description": metadata.get("description"),
                    "distance": item.distance,
                }
            )

        return context
    ```

2. Add a new Python paragraph and run the following code to call the function with the same kind of request used in Lab 6.

    ```python
    %python
    context = search_parks_context(
        query="waterfalls and other natural water features",
        states=["DC", "MD"],
        exclude_park_codes=["whho"],
        top_k=5,
    )

    print(context)
    ```

3. Review the output. Each item contains the park fields an agent can use as context, together with its record ID and distance. The function only reads from `parks`; it does not create or update any other table.

## Task 4: Describe and Test the Tool

Agents need a description of what a tool does and the arguments it accepts. The following framework-neutral schema can be adapted to the tool-registration format used by an agent library.

1. Add a new Python paragraph and run the following code.

    ```python
    %python
    import json

    search_parks_tool = {
        "name": "search_parks_context",
        "description": (
            "Find National Parks relevant to a request and return concise context "
            "with source identifiers. Use states or exclude_park_codes to constrain results."
        ),
        "parameters": {
            "type": "object",
            "properties": {
                "query": {
                    "type": "string",
                    "description": "The information the agent is looking for.",
                },
                "states": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Optional state abbreviations such as DC or MD.",
                },
                "exclude_park_codes": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Optional park codes to exclude from the results.",
                },
                "top_k": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 10,
                    "description": "Maximum number of context items to return.",
                },
            },
            "required": ["query"],
            "additionalProperties": False,
        },
    }

    print(json.dumps(search_parks_tool, indent=2))
    ```

2. Test an unrestricted request.

    ```python
    %python
    print(
        json.dumps(
            search_parks_context(
                query="historic battlefield from the civil war",
                top_k=3,
            ),
            indent=2,
        )
    )
    ```

3. Test a request with metadata constraints.

    ```python
    %python
    print(
        json.dumps(
            search_parks_context(
                query="parks suitable for picnics",
                states=["MD"],
                top_k=3,
            ),
            indent=2,
        )
    )
    ```

You now have a read-only retrieval function and a framework-neutral tool schema. These provide the pieces an agent framework can register as a tool; this lab does not depend on a specific agent library or perform that registration. A production agent can use the returned park descriptions as context within its own workflow.

You have now **completed the workshop.**

## Learn More

- [Oracle VecDB query operation](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/api-guide/query.html)
- [Oracle VecDB query response](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/response-objects/query-response.html)
- [Oracle VecDB record and metadata concepts](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/how-oracle-vecdb-works/record.html)

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - September 28, 2026
