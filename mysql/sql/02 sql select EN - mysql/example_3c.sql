WITH cnt AS (
  SELECT COUNT(*) as e_count FROM employees
),
ranked_salaries AS (
  SELECT 
    salary,
    ROW_NUMBER() OVER (ORDER BY salary) as row_num
  FROM employees
)
SELECT AVG(salary) as median_salary
FROM ranked_salaries, cnt
WHERE row_num IN (FLOOR((e_count + 1) / 2), CEIL((e_count + 1) / 2));
