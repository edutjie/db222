-- A4 | Basdat A

CREATE OR REPLACE FUNCTION checkUserPassword()
    RETURNS trigger AS
$$
BEGIN
    -- check if password contains uppercase and numeric
    IF ((SELECT COUNT(*) FROM REGEXP_MATCHES(NEW.password, '[0-9]', 'g')) < 1)
        OR ((SELECT COUNT(*) FROM REGEXP_MATCHES(NEW.password, '[A-Z]', 'g')) < 1)
    THEN
        RAISE EXCEPTION 'Password harus terdapat minimal 1 huruf kapital dan 1 angka.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER checkUserPasswordTrigger
    AFTER INSERT OR UPDATE
    ON user_acc
    FOR EACH ROW
EXECUTE PROCEDURE checkUserPassword();


-- tester
INSERT INTO user_acc(email, password, phonenum, fname, lname)
VALUES ('test@gmail.com', 'asdfs1as', 089635443053, 'Test', 'Drive');