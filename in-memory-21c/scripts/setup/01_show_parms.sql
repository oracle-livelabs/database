@../imlogin.sql

set pages 9999
set lines 200
set echo on

-- Shows the SGA init.ora parameters

show parameter sga

show parameter db_keep_cache_size

show parameter heat_map

show parameter inmemory_size

set echo off
