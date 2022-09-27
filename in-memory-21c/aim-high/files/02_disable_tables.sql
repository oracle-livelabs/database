@../aim_login.sql

set pages 9999
set lines 150

set serveroutput on;
declare
  v_ddl varchar2(1000);
begin
  for tab_cursor in (
    select owner, table_name
    from   dba_tables
    where  owner not in ('AUDSYS','SYS')
    and    inmemory = 'ENABLED'
  )
  loop
    v_ddl := 'alter table '||tab_cursor.owner||'.'||tab_cursor.table_name||' no inmemory';
    dbms_output.put_line(v_ddl);
    execute immediate v_ddl;
  end loop;
  --
  for part_cursor in (
    select table_owner, table_name, partition_name
    from   dba_tab_partitions
    where  table_owner not in ('AUDSYS','SYS')
    and    inmemory = 'ENABLED'
  )
  loop
    v_ddl := 'alter table '||part_cursor.table_owner||'.'||part_cursor.table_name||
      ' modify partition '||part_cursor.partition_name||' no inmemory';
    dbms_output.put_line(v_ddl);
    execute immediate v_ddl;
  end loop;
end;
/

