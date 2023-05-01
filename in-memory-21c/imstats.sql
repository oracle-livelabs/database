set numwidth 20
col name format a50;
select
  t1.name,
  t2.value
FROM
  v$sysstat t1,
  v$mystat t2
WHERE
  ( t1.name IN (
      'CPU used by this session',
      'physical reads',
      'session logical reads',
      'session logical reads - IM',
      'session pga memory',
      'table scans (IM)',
      'table scan disk IMC fallback'
    )
    OR ( t1.name like 'IM scan%' )
    OR ( t1.name like 'IM simd%' )
  )
  AND t1.statistic# = t2.statistic#
  AND t2.value != 0
ORDER BY
  t1.name;

