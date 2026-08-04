# Healthcare Workshop SQL Loader

Upload `healthcare-platform-handoff-loader.sql` when the sandbox provisioning system accepts one SQL initialization file. Run it through SQLcl while connected as `ADMIN`:

```text
@healthcare-platform-handoff-loader.sql "<lluser-password>" "<service-alias>"
```

This is a self-contained loader. It performs both required phases without calling another local file:

1. The ADMIN phase creates `LLUSER` when needed, or unlocks an existing `LLUSER` without forcing a password-policy reset, and grants the required privileges.
2. `02-lluser-create-healthcare-objects.sql` reconnects as `LLUSER`, recreates the healthcare objects, loads the deterministic dataset, builds the vectors, graph, spatial indexes, and OML model, and prints validation counts.

The two numbered scripts remain available as troubleshooting copies, but they are not required when the self-contained platform loader is uploaded.

The loader prints a final, table-shaped release summary for the connected schema, all six tracked data layers, their 14,796-record total, supporting location counts, OML model, and invalid objects.

The loader does not contain a password, wallet path, or Autonomous Database service name. Supply those values at runtime.

The documented application baseline contains 14,796 tracked records across these six layers:

- 187 care services
- 5,000 signal bulletins
- 3,000 service requests
- 187 service vectors
- 5,000 signal vectors
- 1,422 semantic matches

Supporting records include 2,000 care sites, 30 logistics sites, forecasts, graph records, and OML training data.
