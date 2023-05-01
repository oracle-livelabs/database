@../aim_login.sql

set pages 999
set lines 200

set echo on

alter table MEDTAB1 inmemory;
alter table MEDTAB2 inmemory;
alter table MEDTAB3 inmemory;
alter table LRGTAB1 inmemory;
alter table LRGTAB2 inmemory;
alter table LRGTAB3 inmemory;
alter table LRGTAB4 inmemory;
alter table SMTAB1  inmemory;
alter table SMTAB2  inmemory;
alter table SMTAB3  inmemory;

set echo off

