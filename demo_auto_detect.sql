-- Demo: DuckDB Custom Date Extension with Auto-Detection
-- Load the custom_date extension
LOAD 'build/release/extension/custom_date/custom_date.duckdb_extension';

-- 1. Analyze CSV file for YYYY.MM.DD format detection
SELECT analyze_csv_date_formats('test/data/auto_detect_test.csv') AS suggestion;

-- 2. Check individual date strings
SELECT 
    '1990.05.15' AS date_string,
    is_custom_date_format('1990.05.15') AS is_custom_format;

SELECT 
    '1990-05-15' AS date_string,
    is_custom_date_format('1990-05-15') AS is_custom_format;

-- 3. Read CSV as strings first (no auto-detection)
SELECT * FROM read_csv('test/data/auto_detect_test.csv', auto_detect=false, header=true, 
                      columns={'id': 'INTEGER', 'name': 'VARCHAR', 'birth_date': 'VARCHAR', 'join_date': 'VARCHAR'});

-- 4. Automatic conversion via custom cast function
-- The extension automatically converts YYYY.MM.DD to proper DATE types
SELECT 
    id, 
    name, 
    birth_date::DATE AS birth_date_converted, 
    join_date::DATE AS join_date_converted,
    typeof(birth_date::DATE) AS birth_date_type
FROM read_csv('test/data/auto_detect_test.csv', auto_detect=false, header=true, 
              columns={'id': 'INTEGER', 'name': 'VARCHAR', 'birth_date': 'VARCHAR', 'join_date': 'VARCHAR'});

-- 5. Date arithmetic works with converted dates
SELECT 
    name,
    birth_date::DATE AS birth_date,
    join_date::DATE AS join_date,
    join_date::DATE - birth_date::DATE AS days_between_birth_and_join,
    date_part('year', age(join_date::DATE, birth_date::DATE)) AS age_at_join
FROM read_csv('test/data/auto_detect_test.csv', auto_detect=false, header=true, 
              columns={'id': 'INTEGER', 'name': 'VARCHAR', 'birth_date': 'VARCHAR', 'join_date': 'VARCHAR'})
WHERE birth_date::DATE IS NOT NULL;