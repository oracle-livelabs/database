# Healthcare Workshop SQL Loader

Run `healthcare-platform-handoff-loader.sql` while connected as `ADMIN`. The wrapper performs the two required phases:

1. `01-admin-create-lluser.sql` creates or unlocks `LLUSER` and grants the required privileges.
2. `02-lluser-create-healthcare-objects.sql` reconnects as `LLUSER`, recreates the healthcare objects, loads the deterministic dataset, builds the vectors, graph, spatial indexes, and OML model, and prints validation counts.

SQLcl usage:

```text
@healthcare-platform-handoff-loader.sql "<service-alias>" "<lluser-password>"
```

The loader does not contain a password, wallet path, or Autonomous Database service name. Supply those values at runtime.

The documented application baseline contains 14,796 tracked records across these six layers:

- 187 care services
- 5,000 signal bulletins
- 3,000 service requests
- 187 service vectors
- 5,000 signal vectors
- 1,422 semantic matches

Supporting records include 2,000 care sites, 30 logistics sites, forecasts, graph records, and OML training data.
