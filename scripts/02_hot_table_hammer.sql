-- Hot table hammer workload to study InnoDB behavior and SHOW ENGINE INNODB STATUS
-- Run with: mysql -h 127.0.0.1 -P 3306 -u root -pStrongRootPass123! < 02_hot_table_hammer.sql

USE lab;

DROP PROCEDURE IF EXISTS hammer;
DROP TABLE IF EXISTS hot_table;

CREATE TABLE hot_table (
  id INT PRIMARY KEY,
  value INT NOT NULL
) ENGINE = InnoDB;

INSERT INTO hot_table VALUES (1, 0);

DELIMITER //

CREATE PROCEDURE hammer()
BEGIN
  DECLARE i INT DEFAULT 0;
  WHILE i < 100000 DO
    UPDATE hot_table SET value = value + 1 WHERE id = 1;
    SET i = i + 1;
  END WHILE;
END //

DELIMITER ;

CALL hammer();
