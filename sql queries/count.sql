USE master;
GO

ALTER DATABASE OlistDB
SET RECOVERY SIMPLE;
GO

DBCC SHRINKFILE (OlistDB_log, 1024);
GO

ALTER DATABASE OlistDB
SET RECOVERY FULL;
GO

USE OlistDB;
GO

SELECT 
    name,
    type_desc,
    size * 8 / 1024 AS size_mb
FROM sys.database_files;


USE OlistDB;
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;


SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'payments', COUNT(*)
FROM payments

UNION ALL

SELECT 'reviews', COUNT(*)
FROM reviews

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'sellers', COUNT(*)
FROM sellers

UNION ALL

SELECT 'geolocation', COUNT(*)
FROM geolocation

UNION ALL

SELECT 'category_translation', COUNT(*)
FROM category_translation;