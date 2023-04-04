1. Run this as sysdba on the pdb 
create user hol23c identified by welcome123;
@ords_installer_privileges.sql hol23c;

2. Run this in the terminal 
cd /home/oracle/
ords install 
ords config set mongo.enabled true

3. connect to the pdb as the new user and enable ORDS
sqlplus hol23c/welcome123@pdb23c
exec ords.enable_schema;
commit;
exec ords.delete_privilege_mapping('oracle.soda.privilege.developer', '/soda/*');
commit;