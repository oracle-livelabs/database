@../imlogin.sql

set pages 9999
set lines 150

-- Cleanup
alter table chicago_data no inmemory;
alter table chicago_data no inmemory text (description);
