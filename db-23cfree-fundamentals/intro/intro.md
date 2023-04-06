# Introduction

## About JSON Relational Duality Views

TO BE UPDATED BY RANJAN

### **About Oracle REST Database Service (ORDS) and AutoREST**

Interacting with your Oracle Database with HTTPS and REST APIs can be as simple as picking the objects in your database you want to start working with.

Our REST API technology includes a feature known as ‘AutoREST,’ where one or more objects are enabled, and REST API endpoints are automatically published. For example, a TABLE can be enabled for GET, PUT, POST, DELETE operations to get one or more rows, insert or update rows, delete rows, or even batchload multiple rows in a single request. This feature has been enhanced for 23c to include similar REST access for JSON-Relational duality views. 

This tutorial will walk through the basic use cases for working with a REST Enabled JSON-Relational duality views. 

If you are familiar with SQL Developer Web, you may optionally use it to REST Enable your DVs, explore your REST APIs, and use the built-in OpenAPI doc to use the APIs based on the examples in this document. 

These tutorials include the SQL, PL/SQL, and cURL commands to work with the examples from your favorite command-line interface. 

For the sake of simplicity, these REST APIs are unprotected. Oracle Database REST APIs offer performance AND secure access for application developers, and it is recommended you protect your endpoints with the proper web privileges and roles.


> **Note**: Currently, this workshop is not supported in an Always Free environment. If you are using the _Run on LiveLabs_ option, please note that Oracle Database 23c Free Developer Release has already been installed on the virtual machine.


## Acknowledgements

- **Authors**- William Masdon, Product Manager, Database; Jeff Smith, Distinguished Product Manager, Database; Ranjan Priyadarshi, Senior Director, Database Product Management
- **Last Updated By/Date** - William Masdon, Product Manager, Database, April 2023
