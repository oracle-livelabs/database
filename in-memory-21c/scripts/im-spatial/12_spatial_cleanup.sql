@../imlogin.sql

alter table city_points no inmemory;
delete from user_sdo_geom_metadata where table_name = 'CITY_POINTS';
commit;
DROP TABLE city_points;

