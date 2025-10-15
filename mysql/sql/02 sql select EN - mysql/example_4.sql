SELECT job_id, AVG(salary)
FROM employees
GROUP by job_id
HAVING AVG(salary) > (select avg(salary) from employees)