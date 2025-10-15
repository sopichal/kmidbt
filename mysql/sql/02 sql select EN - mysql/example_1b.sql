SELECT
  e.employee_id, e.last_name, e.salary, e.job_id
FROM
  employees e,
  (
    select
    a.salary,
    row_number() over (order by salary desc) as row_num
    from (select distinct salary from employees) a
  ) r
where e.salary=r.salary and r.row_num=3
;
