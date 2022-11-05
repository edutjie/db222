-- Eduardus Tjitrahardja | 2106653602
-- Latihan Soal - Advanced SQL Query  Index - Kelas A

-- 1
SELECT d.dname, COUNT(*)
FROM employee e
         INNER JOIN department d ON d.dnumber = e.dno
GROUP BY 1;


-- 2
SELECT CONCAT(fname, ' ', lname) AS name
FROM employee e
         INNER JOIN department d ON d.dnumber = e.dno
         INNER JOIN dependent d2 ON e.ssn = d2.essn
WHERE d.mgr_ssn = e.ssn
  AND d2.relationship = 'Daughter';


-- 3
SELECT CONCAT(e.fname, ' ', e.lname) AS name,
       e.salary,
       d.dname,
       d2.dependent_name,
       d2.relationship
FROM employee e
         INNER JOIN department d ON d.dnumber = e.dno
         INNER JOIN dependent d2 ON e.ssn = d2.essn;


-- 4
SELECT CONCAT(fname, ' ', lname) AS name
FROM employee
WHERE salary > (SELECT AVG(salary) FROM employee);


-- 5
SELECT CONCAT(fname, ' ', lname) AS name
FROM employee
WHERE ssn IN (SELECT DISTINCT super_ssn
              FROM employee
              WHERE super_ssn IS NOT NULL);


-- 6
SELECT name,
       salary,
       salary + bonus AS salary_after_bonus
FROM (SELECT e.ssn, CONCAT(fname, ' ', lname) AS name, e.salary, SUM(wo.hours * 1000) AS bonus
      FROM employee e
               LEFT JOIN works_on wo ON e.ssn = wo.essn
               LEFT JOIN project p ON p.pnumber = wo.pno
      GROUP BY 1, 2, 3) AS e_bonus;


-- 7
SELECT *
FROM (SELECT CONCAT(e.fname, ' ', e.lname)                          AS name,
             e.ssn,
             SUM(CASE WHEN p.pnumber IS NOT NULL THEN 1 ELSE 0 END) AS n_project
      FROM employee e
               LEFT JOIN works_on wo ON e.ssn = wo.essn
               LEFT JOIN project p ON p.pnumber = wo.pno
      GROUP BY 1, 2) AS e_wo_p
WHERE n_project > 1;



-- 8
CREATE VIEW employee_project AS
SELECT e.*,
       p.pname,
       wo.hours,
       d.dname
FROM employee e
         INNER JOIN department d ON d.dnumber = e.dno
         LEFT JOIN works_on wo ON e.ssn = wo.essn
         LEFT JOIN project p ON wo.pno = p.pnumber;


-- 9
SELECT fname AS employee_fname,
       lname AS employee_lname,
       pname AS "proyek",
       dname AS "departemen"
FROM employee_project;


-- 10
SELECT fname      AS employee_fname,
       lname      AS employee_lname,
       SUM(hours) AS durasi_proyek
FROM employee_project
GROUP BY 1, 2;