# Introduction

## Encryption & Key Management with Wallets of Oracle Multitenant Databases

With the increased risk of a cyberattacks protection of one of your most valuable asset’s, your data, is vital.  Data within the Oracle database is generally the most vital and/or sensitive data within the company.  The best way to start protecting that data is with Transparent Data Encryption (TDE).  Some of the benefits of using TDE are:

- Helps address security and compliance needs
- There is no need to change the applications that are accessing  the database
- Users and applications are not aware the data is encrypted
- There is little downtime involved
- Your data is safe, even if the media is stolen

TDE encrypts sensitive data stored in data files. To prevent unauthorized decryption, TDE stores the encryption keys in a security module external to the database, called a keystore.  In this module we will focus on how to encrypt the database when working with Pluggable databases (PDB) , containers (CDB) and wallets as the keystore.  There will be a future LiveLabs using OKV as the keystore, so keep an eye out for that.

As you go through the lesson we have also added best practices throughout the module.  There are things that you should be careful of when working with TDE and moving PDB’s between containers, like what happens if you have moved a database to a different container, but need to retore the current version from the previous container.  

*Estimated Workshop Time*: 1.5 hours

Watch the video below for an overview of Oracle Multitenant.

[Back to Basics with Transparent Data Encryption (TDE)](https://youtu.be/JflshZKgxYs)

Please *proceed to the next lab*.

# Learn more

[Oracle Advanced Security Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/asoag/introduction-to-oracle-advanced-security.html)

[Introduction to TDE](https://docs.oracle.com/en/database/oracle/oracle-database/19/asoag/introduction-to-transparent-data-encryption.html)

# Acknowledgements

- **Authors/Contributors** - Sean Provost, Mike Sweeney, Bryan Grenn, Bill Pritchett, Rene Fontcha
- **Last Updated By/Date** - Sean Provost, Enterprise Architect, May 2023
