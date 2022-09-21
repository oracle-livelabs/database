@../aim_login.sql

set pages 9999
set lines 150 

show parameters inmemory_automatic_level

alter system set inmemory_automatic_level=medium;

show parameters inmemory_automatic_level


