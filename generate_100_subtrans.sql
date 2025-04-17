-- \set запрещен в pgbench, поэтому я немного подправила

SELECT string_agg(sql_line, E'\n')
FROM (
  SELECT random(1,10000000)::bigint::text AS sql_line
  UNION ALL
  SELECT 'BEGIN;'
  UNION ALL
  SELECT
    'savepoint v' || gs.id || ';' || E'\n' ||
    'update t1 set name = name where id = :id;' AS sql_line
  FROM generate_series(1, 100) AS gs(id)
  UNION ALL
  SELECT 'COMMIT;'
) AS lines;