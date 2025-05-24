-- Custom Date Extension Usage Examples
-- =====================================

-- Load the extension (after building)
-- LOAD 'build/release/extension/custom_date/custom_date.duckdb_extension';

-- Example 1: Automatic casting of YYYY.MM.DD format
SELECT '2023.01.15'::DATE as custom_date;
SELECT CAST('2024.12.25' AS DATE) as christmas;

-- Example 2: Invalid dates return NULL
SELECT '2023.13.01'::DATE as invalid_month;  -- NULL
SELECT '2023.02.30'::DATE as invalid_day;    -- NULL

-- Example 3: Standard formats still work
SELECT '2023-01-15'::DATE as standard_date;

-- Example 4: Reading CSV with YYYY.MM.DD dates (recommended)
SELECT * FROM read_csv('test_custom_date.csv', dateformat='%Y.%m.%d');

-- Example 5: Reading CSV with automatic casting
SELECT 
    id::INTEGER as id,
    name,
    date_of_birth::DATE as date_of_birth,
    amount::DECIMAL(10,2) as amount
FROM read_csv('test_custom_date.csv', 
    columns={
        'id': 'INTEGER', 
        'name': 'VARCHAR', 
        'date_of_birth': 'VARCHAR', 
        'amount': 'DOUBLE'
    });

-- Example 6: Using in WHERE clauses
SELECT * 
FROM (VALUES 
    ('2023.01.15'),
    ('2023.06.30'),
    ('2023.12.25')
) AS t(date_str)
WHERE date_str::DATE > '2023.06.01'::DATE;