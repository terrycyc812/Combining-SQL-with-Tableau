use employees_mod;
# Task 1
/* Create a visualization that provides a breakdown between the male and female employees working in the company each year, starting from 1990.  */

SELECT 
    YEAR(de.from_date) AS calender_year,
    e.gender AS gender,
    COUNT(e.emp_no) AS num_of_employees
FROM
    t_dept_emp de
        INNER JOIN
    t_employees e ON de.emp_no = e.emp_no
WHERE
    YEAR(de.from_date) >= 1990
GROUP BY calender_year , gender
ORDER BY calender_year;


# Task 2
/* Compare the number of male managers to the number of female managers from different departments for each year, starting from 1990. */
SELECT 
    d.dept_name,
    e.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    A.calender_year,
    CASE
        WHEN A.calender_year BETWEEN YEAR(dm.from_date) AND YEAR(dm.to_date) THEN 1
        ELSE 0
    END AS 'active'
FROM
    (with digit as (
    select 0 as d union all 
    select 1 union all select 2 union all select 3 union all
    select 4 union all select 5 union all select 6 union all
    select 7 union all select 8 union all select 9        
),
seq as (
    select a.d + (10 * b.d) as num
    from digit a
        cross join
        digit b
)
select year(sysdate()) - seq.num as calender_year
from seq where year(sysdate()) - seq.num >= 1990) AS A
        CROSS JOIN
    t_employees e
        INNER JOIN
    t_dept_manager dm ON e.emp_no = dm.emp_no
        INNER JOIN
    t_departments d ON dm.dept_no = d.dept_no
ORDER BY d.dept_name , e.gender , dm.emp_no , A.calender_year;



# Task 3
/* Compare the average salary of female versus male employees in the entire company until year 2002, 
and add a filter allowing you to see that per each department. */

SELECT 
    d.dept_name,
    e.gender,
    ROUND(AVG(s.salary), 2) AS salary,
    YEAR(s.from_date) AS calender_year
FROM
    t_departments d
        INNER JOIN
    t_dept_emp de ON d.dept_no = de.dept_no
        INNER JOIN
    t_employees e ON de.emp_no = e.emp_no
        INNER JOIN
    t_salaries s ON de.emp_no = s.emp_no
WHERE
    YEAR(s.from_date) <= 2002
GROUP BY d.dept_name , calender_year , e.gender
ORDER BY d.dept_name;


# Task 4
/* Create an SQL stored procedure that will allow you to obtain the average male and female salary per department 
within a certain salary range. Let this range be defined by two values the user can insert when calling the procedure.
Finally, visualize the obtained result-set in Tableau as a double bar chart. */
drop procedure emp_salary;

delimiter $$
CREATE PROCEDURE filter_salary(IN min_salary FLOAT, IN max_salary FLOAT)
BEGIN
SELECT 
    d.dept_name, e.gender, ROUND(AVG(s.salary), 2) AS avg_salary
FROM
    t_departments d
        INNER JOIN
    t_dept_emp de ON d.dept_no = de.dept_no
        INNER JOIN
    t_employees e ON de.emp_no = e.emp_no
        INNER JOIN
    t_salaries s ON e.emp_no = s.emp_no
WHERE
	s.salary BETWEEN min_salary AND max_salary
GROUP BY d.dept_name , e.gender
ORDER BY d.dept_name;
END$$

delimiter ;

call filter_salary(50000,90000);