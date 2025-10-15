SELECT employee_id, first_name, last_name, salary
FROM employees e1
WHERE 1 = (
	SELECT COUNT(DISTINCT salary)
	FROM employees e2 WHERE e2.salary>e1.salary
);
