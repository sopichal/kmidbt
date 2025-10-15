SELECT e1.employee_id, e1.first_name, e1.last_name, e1.salary
FROM
  (SELECT first_name, last_name, employee_id, salary, dense_rank() over (order by salary desc) as salary_rank
   FROM employees) e1
WHERE salary_rank=2;

SELECT employee_id, first_name, last_name, e1.salary, job_id
FROM employees e1,
  (
    select distinct salary
    from employees
    order by salary desc
    LIMIT 1 OFFSET 1
  ) e2
WHERE e1.salary = e2.salary;