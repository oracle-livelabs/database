Rem  Copyright (c) Oracle Corporation 2014. All Rights Reserved.
Rem
Rem    NAME
Rem      ords_installer_privileges.sql
Rem
Rem    DESCRIPTION
Rem      Provides privileges required to install, upgrade, validate and uninstall 
Rem      ORDS schema, ORDS proxy user and related database objects.
Rem
Rem    NOTES
Rem      This script includes privileges to packages and views that are normally granted PUBLIC 
Rem      because these privileges may be revoked from PUBLIC.
Rem   
Rem
Rem    ARGUMENT:
Rem      1  : ADMINUSER - The database user that will be granted the privilege
Rem
Rem    REQUIREMENTS
Rem      Oracle Database Release 11.1 or later
Rem
Rem    MODIFIED   (MM/DD/YYYY)
Rem      epaglina  09/25/2019  Grant SELECT object privilege if DB version 12.1.0.1.
Rem      epaglina  05/22/2019  Created.
Rem

set define '^'
set serveroutput on
set termout on

define ADMINUSER = '^1'

--
-- System privileges
--
grant alter any table                   to ^ADMINUSER;
grant alter user                        to ^ADMINUSER with admin option;
grant comment any table                 to ^ADMINUSER;
grant create any context                to ^ADMINUSER;
grant create any index                  to ^ADMINUSER;
grant create any job                    to ^ADMINUSER;
grant create any procedure              to ^ADMINUSER;
grant create any sequence               to ^ADMINUSER;
grant create any synonym                to ^ADMINUSER;
grant create any table                  to ^ADMINUSER;
grant create any trigger                to ^ADMINUSER with admin option;
grant create any type                   to ^ADMINUSER;
grant create any view                   to ^ADMINUSER;
grant create job                        to ^ADMINUSER with admin option;
grant create public synonym             to ^ADMINUSER with admin option;
grant create role                       to ^ADMINUSER;
grant create session                    to ^ADMINUSER with admin option;
grant create synonym                    to ^ADMINUSER with admin option;
grant create user                       to ^ADMINUSER;
grant create view                       to ^ADMINUSER with admin option;
grant delete any table                  to ^ADMINUSER;
grant drop any context                  to ^ADMINUSER;
grant drop any role                     to ^ADMINUSER;
grant drop any table                    to ^ADMINUSER;
grant drop any type                     to ^ADMINUSER;
grant drop any synonym                  to ^ADMINUSER;
grant drop public synonym               to ^ADMINUSER with admin option;
grant drop user                         to ^ADMINUSER;
grant execute any procedure             to ^ADMINUSER;
grant execute any type                  to ^ADMINUSER;
grant grant any object privilege        to ^ADMINUSER;
grant insert any table                  to ^ADMINUSER;
grant select any table                  to ^ADMINUSER;
grant update any table                  to ^ADMINUSER;
grant RESOURCE                          to ^ADMINUSER;
grant SODA_APP                          to ^ADMINUSER;
grant unlimited tablespace              to ^ADMINUSER;

declare
  c_grant_set_con constant varchar2(255)  := 'grant set container to ' || dbms_assert.enquote_name('^ADMINUSER')
                                           || ' with admin option';
begin
  -- Only for Oracle DB 12c and later
  if sys.dbms_db_version.VERSION >= 12 then
    dbms_output.put_line(c_grant_set_con);
    execute immediate c_grant_set_con;
  end if;
end;
/

--
-- Object privileges with grant option
--
grant execute on sys.dbms_assert        to ^ADMINUSER with grant option;
grant execute on sys.dbms_crypto        to ^ADMINUSER with grant option;
grant execute on sys.dbms_lob           to ^ADMINUSER with grant option;
grant execute on sys.dbms_metadata      to ^ADMINUSER with grant option;
grant execute on sys.dbms_output        to ^ADMINUSER with grant option;
grant execute on sys.dbms_scheduler     to ^ADMINUSER with grant option;
grant execute on sys.dbms_session       to ^ADMINUSER with grant option;
grant execute on sys.dbms_utility       to ^ADMINUSER with grant option;
grant execute on sys.dbms_sql           to ^ADMINUSER with grant option;
grant execute on sys.default_job_class  to ^ADMINUSER with grant option;
grant execute on sys.htp                to ^ADMINUSER with grant option;
grant execute on sys.owa                to ^ADMINUSER with grant option;
grant execute on sys.wpiutl             to ^ADMINUSER with grant option;
grant execute on sys.wpg_docload        to ^ADMINUSER with grant option;
grant execute on sys.utl_smtp           to ^ADMINUSER with grant option;

grant select on sys.user_cons_columns   to ^ADMINUSER with grant option;
grant select on sys.user_constraints    to ^ADMINUSER with grant option;
grant select on sys.user_objects        to ^ADMINUSER with grant option;
grant select on sys.user_procedures     to ^ADMINUSER with grant option;
grant select on sys.user_tab_columns    to ^ADMINUSER with grant option;
grant select on sys.user_tables         to ^ADMINUSER with grant option;
grant select on sys.user_views          to ^ADMINUSER with grant option;

--
-- Object privileges
--

-- For Oracle DB 12.1.0.2 and later, grant READ.  Otherwise, grant SELECT.
declare
 type obj_name_list is table of dba_tab_privs.table_name%TYPE;
  list1 obj_name_list := obj_name_list(
                                      'CDB_SERVICES',
                                      'CDB_TABLESPACES',
                                      'DBA_ROLES',
                                      'DBA_SYNONYMS',
                                      'DBA_TABLESPACES',
                                      'DBA_TAB_COLS',
                                      'DBA_TAB_PRIVS',
                                      'DBA_TEMP_FILES',
                                      'PROXY_USERS',
                                      'V_$CONTAINERS',
                                      'V_$DATABASE',
                                      'V_$LISTENER_NETWORK',
                                      'V_$PARAMETER'
                                      );
  -- Include the "with grant option"
  list2 obj_name_list := obj_name_list(
                                      'DBA_OBJECTS',
                                      'DBA_REGISTRY',
                                      'DBA_ROLE_PRIVS',
                                      'DBA_TAB_COLUMNS',
                                      'DBA_USERS',
                                      'SESSION_PRIVS'
                                       );
                                                                           
  c_grant_read constant varchar2(100)  := 'grant read on sys.';
  c_grant_select constant varchar2(100):= 'grant select on sys.';
  c_user_grant constant varchar2(255)  := ' to ' || dbms_assert.enquote_name('^ADMINUSER');
  c_grant_opt constant varchar2(100)   := ' with grant option';
  
  l_use_read boolean          := FALSE;
  l_prod_version varchar2(20) := '';

begin
  if sys.dbms_db_version.VERSION > 12 then
    l_use_read := TRUE;
  elsif sys.dbms_db_version.VERSION = 12 then
    begin
      select version into l_prod_version from sys.v$instance where version like '12.1.0.1.%';
    exception
      when NO_DATA_FOUND then
        -- 12.1.0.2 or later
        l_use_read := TRUE;
      when others then
        null;
    end;
  end if;

  for i in list1.first .. list1.last loop
    if l_use_read then
        -- 12c and later use the READ privilege
      dbms_output.put_line( c_grant_read || list1(i) || c_user_grant);
      execute immediate c_grant_read || list1(i) || c_user_grant;
    elsif (sys.dbms_db_version.VERSION = 12) or
          (sys.dbms_db_version.VERSION = 11 and list1(i) <> 'V_$CONTAINERS') then
      dbms_output.put_line(c_grant_select || list1(i) || c_user_grant);
      execute immediate c_grant_select || list1(i) || c_user_grant;
    end if;
  end loop;
  
  for i in list2.first .. list2.last loop
    if l_use_read then
        -- 12c and later use the READ privilege
      dbms_output.put_line( c_grant_read || list2(i) || c_user_grant || c_grant_opt);
      execute immediate c_grant_read || list2(i) || c_user_grant || c_grant_opt;
    else
      dbms_output.put_line(c_grant_select || list2(i) || c_user_grant || c_grant_opt);
      execute immediate c_grant_select || list2(i) || c_user_grant || c_grant_opt;
    end if;
  end loop;
  
  -- Grant to check if ORDS application is installed in the Application Container
  if (sys.dbms_db_version.version > 12) or (sys.dbms_db_version.version = 12 and sys.dbms_db_version.release > 1) then
    execute immediate c_grant_read || 'DBA_APPLICATIONS' || c_user_grant;
  end if;  
end;
/

-- APEX Support
declare
  c_sel_stmt     constant varchar2(400) := 'select version, schema, status from sys.dba_registry where comp_id = ''APEX''';
  c_grant_select constant varchar2(100) := 'grant select on ';
  c_to_user      constant varchar2(400) := ' to ' || dbms_assert.enquote_name('^ADMINUSER') || ' with grant option';
  l_apex_schema  varchar2(255) := null;
  l_apex_version   varchar2(100) := '';
  l_status         varchar2(100) := null;
  l_tmp_str        varchar2(100) := null;
  l_ver_no         number;
  l_ndx            number;
  
begin
  begin
      execute immediate c_sel_stmt into l_apex_version, l_apex_schema, l_status;
  exception
     when no_data_found then
        null;  -- APEX doesn't exist
  end;
   
  if (l_status is not null) and (l_status = 'VALID') and
      (l_apex_version is not null) and (l_apex_schema is not null) then
   
     l_ndx := instr(l_apex_version, '.');
     l_ndx := l_ndx - 1;
     l_tmp_str := substr(l_apex_version,1,l_ndx);

     l_ver_no := to_number(l_tmp_str);
     
     if (l_ver_no >= 5) or (substr(l_apex_version,1,4) = ('4.2.'))  then
        for c1 in (select table_name from all_tables where owner=l_apex_schema and table_name='WWV_FLOW_RT$MODULES')
        loop
          execute immediate c_grant_select || l_apex_schema || '.' || c1.table_name || c_to_user;
          dbms_output.put_line(c_grant_select || l_apex_schema || '.' || c1.table_name || c_to_user);
        end loop;
        for c1 in (select view_name from all_views where owner=l_apex_schema and view_name='WWV_FLOW_POOL_CONFIG')
        loop
          execute immediate c_grant_select || l_apex_schema || '.' || c1.view_name || c_to_user;
          dbms_output.put_line(c_grant_select || l_apex_schema || '.' || c1.view_name || c_to_user);
        end loop;
     end if;   
   end if;
end;
/