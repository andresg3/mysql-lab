-- Demonstrate how sys.statements_with_full_table_scans captures a full scan
-- Run with: mysql -h127.0.0.1 -P3306 -uroot -pStrongRootPass123! < scripts/03_full_scan_sys_view.sql

USE lab;

-- Reset digest stats so we only see this run in the summary (safe in this lab).
TRUNCATE TABLE performance_schema.events_statements_summary_by_digest;

DROP TABLE IF EXISTS full_scan_demo;
CREATE TABLE full_scan_demo (
  id INT AUTO_INCREMENT PRIMARY KEY,
  description VARCHAR(100) NOT NULL,
  filler CHAR(100) NOT NULL
) ENGINE = InnoDB;

INSERT INTO full_scan_demo (description, filler)
SELECT CONCAT('row-', n), LPAD(n, 100, 'x')
FROM (
  SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
  UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
  UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15
  UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20
) AS nums;

-- Run a query that forces a full table scan (no index on description).
SELECT COUNT(*) AS scan_count
FROM full_scan_demo
WHERE description LIKE '%zzz%';

-- Inspect what sys captured about the full scan.
SELECT
  last_seen,
  schema_name,
  table_names,
  rows_examined,
  exec_count,
  tmp_tables,
  no_index_used,
  no_good_index_used,
  digest_text
FROM sys.statements_with_full_table_scans
WHERE schema_name = 'lab'
ORDER BY last_seen DESC
LIMIT 5;
