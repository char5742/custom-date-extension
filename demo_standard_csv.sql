-- Demo: DuckDB Standard CSV Auto-Detection for YYYY.MM.DD Format
-- This extension modifies DuckDB's built-in CSV auto-detection system

-- 1. Standard read_csv() automatically detects YYYY.MM.DD as DATE type
SELECT * FROM read_csv('test/data/clean_auto_detect_test.csv');

-- 2. Full sample size also works seamlessly  
SELECT * FROM read_csv('test/data/clean_auto_detect_test.csv', sample_size=-1);

-- 3. Verify that types are correctly detected
SELECT 
    'id' as column_name, typeof(id) as detected_type 
FROM read_csv('test/data/clean_auto_detect_test.csv') LIMIT 1
UNION ALL
SELECT 
    'name', typeof(name) 
FROM read_csv('test/data/clean_auto_detect_test.csv') LIMIT 1
UNION ALL
SELECT 
    'birth_date', typeof(birth_date) 
FROM read_csv('test/data/clean_auto_detect_test.csv') LIMIT 1
UNION ALL  
SELECT 
    'join_date', typeof(join_date) 
FROM read_csv('test/data/clean_auto_detect_test.csv') LIMIT 1;

-- 4. Date arithmetic works automatically
SELECT 
    name,
    birth_date,
    join_date,
    join_date - birth_date as days_between_birth_and_join,
    date_part('year', age(join_date, birth_date)) as age_at_join
FROM read_csv('test/data/clean_auto_detect_test.csv');

-- 5. Works with filtering and aggregation
SELECT 
    date_part('year', birth_date) as birth_year,
    count(*) as count
FROM read_csv('test/data/clean_auto_detect_test.csv')
GROUP BY date_part('year', birth_date)
ORDER BY birth_year;