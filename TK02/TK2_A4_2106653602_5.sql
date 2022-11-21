-- Eduardus Tjitrahardja | 2106653602 | Basdat A | A4

CREATE OR REPLACE FUNCTION checkPesananSelsai()
    RETURNS trigger AS
$$
DECLARE
    dfee       double precision;
    ffee       double precision;
    cid        varchar(50);
    restname   varchar(50);
    restbranch varchar(25);
BEGIN
    -- check if status = 'Pesanan Selesai'
    IF (NEW.tsid = (SELECT id
                    FROM transaction_status
                    WHERE name = 'Pesanan Selesai')) THEN
        -- get delivery fee
        SELECT deliveryfee, totalfood, courierid
        INTO dfee, ffee, cid
        FROM transaction
        WHERE email = NEW.email
          AND datetime = NEW.datetime;

        -- update courier's RestoPay
        UPDATE transaction_actor
        SET restopay = restopay + dfee
        WHERE email = cid;

        -- get restaurant's pk
        SELECT rname, rbranch
        INTO restname, restbranch
        FROM transaction_food
        WHERE email = NEW.email
          AND datetime = NEW.datetime;

        -- update restaurant's RestoPay
        UPDATE transaction_actor
        SET restopay = restopay + ffee
        WHERE email = (SELECT r.email
                       FROM restaurant r
                       WHERE rname = restname
                         AND rbranch = restbranch);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER checkPesananSelsaiTrigger
    AFTER INSERT
    ON transaction_history
    FOR EACH ROW
EXECUTE PROCEDURE checkPesananSelsai();


-- tester
INSERT INTO transaction_history(email, datetime, tsid, datetimestatus)
VALUES ('gtinseyc@tuttocitta.it', '2022-09-10 00:00:00.000000', '63569189fc13ae3f8d0000ef',
        '2022-09-14 00:15:00.000000');




