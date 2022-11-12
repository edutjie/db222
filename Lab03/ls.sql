-- 2
CREATE OR REPLACE FUNCTION siwanap.check_validity()
    RETURNS trigger AS
$$
BEGIN
    IF (NEW.tgl_masuk >= NEW.tgl_keluar) THEN
        RAISE EXCEPTION 'Input tidak valid pastikan bahwa tanggal masuk sebelum tanggal keluar';
    END IF;
    RETURN NEW;
END;
$$
    LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_validity
    BEFORE INSERT
    ON rawat_inap
    FOR EACH ROW
EXECUTE PROCEDURE check_validity();

DROP TRIGGER trigger_check_validity ON rawat_inap;

INSERT INTO RAWAT_INAP
VALUES ('RI51', 'KA01', 'PA03', '2022-11-06', '2022-11-08');

INSERT INTO RAWAT_INAP
VALUES ('RI52', 'KA05', 'PA18', '2022-11-10', '2022-11-08');

INSERT INTO RAWAT_INAP
VALUES ('RI53', 'KA01', 'PA38', '2022-11-11', '2022-11-11');


-- 3
ALTER TABLE rawat_inap
    ADD jml_biaya INTEGER
        DEFAULT (0);

CREATE OR REPLACE FUNCTION siwanap.calculate_cost()
    RETURNS trigger AS
$$
DECLARE
    jml_biaya INTEGER;
BEGIN
    IF (NEW.tgl_keluar IS NOT NULL) THEN
        jml_biaya := (NEW.tgl_keluar - NEW.tgl_masuk) *
                     (SELECT k.harga
                      FROM kamar k
                      WHERE k.id_kamar = NEW.id_kamar);

        NEW.jml_biaya := jml_biaya;

        RETURN NEW;
    END IF;
END;
$$
    LANGUAGE plpgsql;


CREATE TRIGGER trigger_calculate_cost
    BEFORE INSERT OR UPDATE
    ON rawat_inap
    FOR EACH ROW
EXECUTE PROCEDURE calculate_cost();


INSERT INTO RAWAT_INAP
VALUES ('RI52', 'KA05', 'PA18', '2022-11-10', '2022-11-12');

SELECT *
FROM RAWAT_INAP
WHERE id_rawat_inap = 'RI52';



ALTER TABLE rawat_inap
    DROP COLUMN jml_biaya;

DROP TRIGGER trigger_calculate_cost ON rawat_inap;
