@../imlogin.sql

set pages 999
set lines 200

set echo on

-- Show populate_wait query

-- Return code:
--   -1 = POPULATE_TIMEOUT
--    0 = POPULATE_SUCCESS
--    1 = POPULATE_OUT_OF_MEMORY
--    2 = POPULATE_NO_INMEMORY_OBJECTS
--    3 = POPULATE_INMEMORY_SIZE_ZERO 

select dbms_inmemory_admin.populate_wait(priority=>'NONE',percentage=>100,timeout=>60) pop_status from dual;

set echo off
