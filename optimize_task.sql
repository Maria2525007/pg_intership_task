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

-- Решение ()
CREATE INDEX idx_t1_name ON t1(name);
EXPLAIN ANALYZE
SELECT max(day)
FROM t2
WHERE EXISTS (
  SELECT 1
  FROM t1
  WHERE t1.id = t2.t_id AND t1.name LIKE 'a%'
);


    /*

   */


-- Задание 3
EXPLAIN (ANALYZE, BUFFERS)
SELECT day FROM t2 WHERE t_id NOT IN (SELECT id FROM t1);

    /*

   */


-- Решение (добавить индекс на t1(id))


    /*

   */

-- Задание 4

EXPLAIN (ANALYZE, BUFFERS)
SELECT day
FROM t2
WHERE t_id IN (
  SELECT t1.id FROM t1 WHERE t2.t_id = t1.id
)
AND day > TO_CHAR(DATE_TRUNC('day', now() - INTERVAL '1 month'), 'yyyymmdd');

    /*

   */


-- Решение (добавить индекс на t1(id))


    /*

   */

-- Задание 5

CREATE OR REPLACE FUNCTION random(left BIGINT, right BIGINT) RETURNS BIGINT AS $$
SELECT trunc(random.left + random()*(random.right - random.left))::BIGINT;
$$ LANGUAGE sql;

    /*

   */


-- Решение (добавить индекс на t1(id))


    /*

   */

-- Задание 3

    /*

   */


-- Решение (добавить индекс на t1(id))


    /*

   */

-- Задание 3

    /*

   */


-- Решение (добавить индекс на t1(id))


    /*

   */