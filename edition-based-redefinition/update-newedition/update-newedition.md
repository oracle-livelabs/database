# Run liquibase update for the new changelog

Be sure to cd to the right directory:

SQL> exit

$ cd ebr-human-resources/changes
$ sql /nolog

SQLcl: Release 21.4 Production on Thu Mar 17 18:54:13 2022

Copyright (c) 1982, 2022, Oracle.  All rights reserved.

SQL> set cloudconfig ../../adb_wallet.zip
SQL> connect hr/Welcome#Welcome#123@demoadb_medium
Connected.
SQL> lb update -changelog hr.00002.edition_v2.xml

ScriptRunner Executing: begin
    admin.create_edition('V2');
end;
/
Liquibase Executed:begin
    admin.create_edition('V2');
end;
/
ScriptRunner Executing: ALTER SESSION SET EDITION=V2
Liquibase Executed:ALTER SESSION SET EDITION=V2
ScriptRunner Executing: alter session set DDL_LOCK_TIMEOUT=30
Liquibase Executed:alter session set DDL_LOCK_TIMEOUT=30
ScriptRunner Executing: alter table employees$0 add (
    country_code varchar2(3),
    phone# varchar2(20)
)
Liquibase Executed:alter table employees$0 add (
    country_code varchar2(3),
    phone# varchar2(20)
)
[...]
Liquibase Executed:declare
     type obj_t is record(
         object_name user_objects.object_name%type,
         namespace   user_objects.namespace%type);
     type obj_tt is table of obj_t;

     l_obj_list obj_tt;

     l_obj_count binary_integer := 0;

 begin
     dbms_editions_utilities2.actualize_all;
     loop
         select object_name,namespace
         bulk   collect
         into   l_obj_list
         from   user_objects
         where  edition_name != sys_context('userenv', 'session_edition_name')
         or     status = 'INVALID';

         exit when l_obj_list.count = l_obj_count;

         l_obj_count := l_obj_list.count;

         for i in 1 .. l_obj_count
         loop
             dbms_utility.validate(user, l_obj_list(i).object_name, l_obj_list(i).namespace);
         end loop;
     end loop;
 end;
 /
######## ERROR SUMMARY ##################
Errors encountered:0

######## END ERROR SUMMARY ##################

You have successfully executed the new changelog the HR schema [proceed to the next lab](#next)

## Acknowledgements

- **Author** - Suraj Ramesh
- **Contributors** -
- **Last Updated By/Date** -01-Jul-2022 
