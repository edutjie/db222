-- Eduardus Tjitrahardja | 2106653602 | Basdat A
-- Latihan Soal - Trigger and Stored Procedure

-- 1
CREATE OR REPLACE FUNCTION totalSalary(frontname varchar(15), midinit char, lastname varchar(15))
    RETURNS numeric(10, 2) AS
$$
DECLARE
    base_salary numeric(10, 2);
    curr_ssn    char(9);
    n_dependent integer;
BEGIN
    SELECT salary, ssn
    INTO base_salary, curr_ssn
    FROM employee
    WHERE fname = frontname
      AND minit = midinit
      AND lname = lastname;

    SELECT COUNT(*)
    INTO n_dependent
    FROM dependent
    WHERE essn = curr_ssn;

    base_salary := base_salary + (n_dependent * 100);
    RETURN base_salary;
END;
$$ LANGUAGE plpgsql;


SELECT totalSalary('Franklin', 'T', 'Wong');


-- 2
CREATE OR REPLACE FUNCTION checkTotalDependent()
    RETURNS trigger AS
$$
DECLARE
    n_dependent integer;
BEGIN
    SELECT COUNT(*)
    INTO n_dependent
    FROM dependent
    WHERE essn = NEW.essn;

    IF (n_dependent = 3) THEN
        RAISE EXCEPTION 'Tanggungan yang dimiliki oleh seorang employee tidak boleh lebih dari 3 orang.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER checkTotalDependentTrigger
    BEFORE INSERT
    ON dependent
    FOR EACH ROW
EXECUTE PROCEDURE checkTotalDependent();


INSERT INTO DEPENDENT
VALUES ('123456789', 'Nate', NULL, NULL, 'Son');


-- 3
CREATE OR REPLACE FUNCTION checkSalary()
    RETURNS trigger AS
$$
DECLARE
    mgr_salary numeric(10, 2);
BEGIN
    SELECT e.salary
    INTO mgr_salary
    FROM employee e
    WHERE e.ssn = (SELECT super_ssn
                   FROM employee e2
                   WHERE e2.ssn = NEW.ssn);

    IF (NEW.salary > mgr_salary) THEN
        RAISE EXCEPTION 'Gaji yang diterima oleh employee tidak lebih besar dari gaji yang diterima manajer departemen.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER salaryViolation
    BEFORE INSERT OR UPDATE
    ON employee
    FOR EACH ROW
EXECUTE PROCEDURE checkSalary();


UPDATE employee SET salary = 45000 WHERE ssn = '123456789';