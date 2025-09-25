# Introduction

## About this Demo

Oracle True Cache is an in-memory, consistent, and automatically refreshed SQL and key-value (object) cache for Oracle Database 23ai. This interactive demo shows how True Cache offloads read-mostly workloads from the primary database, how read/write routing works, and how you can deploy caches close to applications for low-latency access—without duplicating data models or building complex cache-invalidation logic.

You may add an optional video, using this format: [](youtube:YouTube video id)

[](youtube:REPLACE_WITH_VIDEO_ID)


### Try the Interactive Demo

Launch the HTML demo here:
- <a href="./true-cache-demo.html" target="_blank">Open the Interactive Demo</a>

What you’ll see:
- Introduction: What is Oracle True Cache
- Architecture: Read/write routing and single-query consistency
- Cache behavior: Freshness, invalidation, and automatic management
- Deployment patterns: Middle tier, edge, and multi-cloud
- Use cases: Real-world scenarios and benefits
- Code: Examples of JDBC read/write split and service-based routing


### Why Use Oracle True Cache

True Cache delivers scale and performance for read-mostly workloads while preserving correctness and simplicity.

Key benefits:
- Offload read queries: Reduce load on the primary database and scale out read throughput
- Consistency you can trust: Single-query consistency across joins and objects; up-to-date within a query
- Simpler architecture: Avoid dual writes, external cache drift, and complex invalidation flows
- Close to your app: Deploy near applications or at the edge for lower latency and better user experience
- Enterprise-grade: Built into Oracle Database with security, HA, backup/recovery, and manageability
- Flexible patterns: Use with JDBC 23ai driver read/write split or service-based routing
- Scale with multiple caches: Deploy multiple True Cache instances by workload, geography, or tenant


## Learn More

- True Cache Overview (Docs): https://docs.oracle.com/en/database/oracle/oracle-database/23/odbtc/overview-oracle-true-cache.html
- Product Page: https://www.oracle.com/database/truecache/
- Related LiveLabs Workshop: https://livelabs.oracle.com/pls/apex/r/dbpm/livelabs/view-workshop?wid=11454

## Acknowledgements
- Author — William Masdon
- Contributors — Francis Regalado, Brianna Ambler
- Last Updated By/Date — William Masdon, September 2025
