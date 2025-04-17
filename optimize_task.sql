-- Задание 1
EXPLAIN ANALYZE
SELECT name FROM t1 WHERE id = 50000;
    /*
Seq Scan on t1  (cost=0.00..208392.00 rows=1 width=30) (actual time=12.368..2170.603 rows=1 loops=1)
  Filter: (id = 50000)
  Rows Removed by Filter: 9999999
Planning Time: 1.766 ms
Execution Time: 2170.647 ms
   */

-- Решение (добавить индекс на t1(id))
CREATE INDEX idx_t1_id ON t1(id);

EXPLAIN ANALYZE
SELECT name FROM t1 WHERE id = 50000;

DROP INDEX idx_t1_id;
    /*
Index Scan using idx_t1_id on t1  (cost=0.43..8.45 rows=1 width=30) (actual time=0.036..0.038 rows=1 loops=1)
Index Cond: (id = 50000)
Planning Time: 0.147 ms
Execution Time: 0.069 ms
   */


-- Задание 2
EXPLAIN (ANALYZE, BUFFERS)
SELECT MAX(t2.day)
FROM t2
LEFT JOIN t1 ON t2.t_id = t1.id AND t1.name LIKE 'a%';
    /*
Aggregate  (cost=388238.44..388238.45 rows=1 width=32) (actual time=15186.827..15186.832 rows=1 loops=1)
    Buffers: shared hit=4394 read=110870, temp read=20833 written=20833"
Planning Time: 4.032 ms
Execution Time: 15187.873 ms
   */

-- Решение (LEFT JOIN не влияет на результат, так как MAX(t2.day) вычисляется для всех строк t2, даже если в t1 нет совпадений)
CREATE INDEX idx_t2_day on t2 (day);

EXPLAIN (ANALYZE, BUFFERS)
SELECT MAX(day) FROM t2;

DROP INDEX idx_t2_day;
    /*
Result  (cost=0.45..0.46 rows=1 width=32) (actual time=0.028..0.028 rows=1 loops=1)
Planning Time: 0.112 ms
Execution Time: 0.049 ms
   */


-- Задание 3
EXPLAIN (ANALYZE, BUFFERS)
SELECT day
FROM t2
WHERE t_id NOT IN (SELECT id FROM t1);

    /*
> 4 min
   */

-- Решение

CREATE INDEX idx_t1_id ON t1 (id);
CREATE INDEX idx_t2_t_id_day ON t2 (t_id) INCLUDE (day);
CREATE INDEX idx_t2_day on t2 (day);

SET enable_nestloop = off;
SET enable_hashjoin = on;

EXPLAIN (ANALYZE, BUFFERS)
SELECT day
FROM t2
WHERE NOT EXISTS (
    SELECT 1
    FROM t1
    WHERE t1.id = t2.t_id
);

DROP INDEX idx_t1_id;
DROP INDEX idx_t2_t_id_day;
DROP INDEX idx_t2_day;

    /*
Planning Time: 2.157 ms
Execution Time: 2181.723 ms

   */

-- Задание 4

EXPLAIN (ANALYZE, BUFFERS)
SELECT day
FROM t2
WHERE t_id IN (
  SELECT id FROM t1
  WHERE t2.t_id = t1.id
) AND day > to_char(date_trunc('day', now() - '1 month'::interval), 'yyyymmdd');
    /*
Planning Time: 2.857 ms
Execution Time: 9652.617 ms
   */


-- Решение
CREATE INDEX idx_t1_id ON t1(id);
CREATE INDEX idx_t2_t_id_day ON t2(t_id, day);

EXPLAIN (ANALYZE, BUFFERS)
SELECT day
FROM t2
WHERE t_id in (
SELECT t1.id FROM t1
             WHERE t2.t_id = t1.id
             )
  AND day > to_char(date_trunc('day',now()- '1 months'::interval),'yyyymmdd');

DROP INDEX  idx_t1_id;
DROP INDEX idx_t2_t_id_day;

/*
Planning Time: 3.364 ms
Execution Time: 3894.860 ms
 */

--или

ALTER TABLE t2 ADD COLUMN day_date DATE;
UPDATE t2
SET day_date = to_date(day, 'YYYYMMDD')
WHERE day_date IS NULL;
CREATE INDEX idx_t2_day_date ON t2(day_date);

        EXPLAIN (ANALYZE, BUFFERS)
SELECT day
FROM t2
WHERE EXISTS (
  SELECT 1
  FROM t1
  WHERE t1.id = t2.t_id -- Явное связывание через EXISTS
)
AND day_date > (CURRENT_DATE - INTERVAL '1 month')::date;

    /*
Planning Time: 9.356 ms
Execution Time: 3427.560 ms
   */

-- Задание 5

--Функция
CREATE OR REPLACE FUNCTION random(left bigint, right bigint) RETURNS bigint
AS $$
  SELECT trunc(random.left + random() * (random.right - random.left))::bigint;
$$
LANGUAGE sql;

-- Нагрузка

select '\\set id random(1,10000000)'
union all
select 'BEGIN;'
union all
select 'savepoint v' || v.id || ';' || E'\n'
    || 'update t1 set name = name where id = :id;' || E'\n'
from generate_series(1,100) v(id)
union all
select E'COMMIT;\n'

/*
сократить число savepoint до 10-20
снизить фрагментацию таблицы при update
добавить индексы на id
*/

