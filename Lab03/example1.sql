--	Contoh 1
CREATE OR REPLACE FUNCTION SIWANAP.diskon_harga(idkamar VARCHAR(10))
    RETURNS INTEGER AS
$$
DECLARE
    harga_awal   INTEGER;
    harga_diskon INTEGER;
BEGIN
    SELECT harga
    INTO harga_awal
    FROM KAMAR
    WHERE id_kamar = idkamar;

    harga_diskon := (harga_awal * 9 / 10);

    UPDATE KAMAR
    SET harga = harga_diskon
    WHERE id_kamar = idkamar;

    RETURN harga_diskon;
END;
$$
    LANGUAGE plpgsql;

\df

\df+


--	Contoh 2
SELECT diskon_harga('KA01');


--	Contoh 3
SELECT diskon_harga(id_kamar)
FROM KAMAR;


--	Contoh 4
CREATE OR REPLACE FUNCTION diskon_semua_harga()
    RETURNS void AS
$$
DECLARE
    temp_row     RECORD;
    harga_diskon INTEGER;
BEGIN
    FOR temp_row IN
        SELECT *
        FROM KAMAR
        LOOP
            harga_diskon := (temp_row.harga * 9 / 10);

            UPDATE KAMAR
            SET harga = harga_diskon
            WHERE id_kamar = temp_row.id_kamar;
        END LOOP;
END;
$$
    LANGUAGE plpgsql;

SELECT diskon_semua_harga();


--	Contoh 5
DROP FUNCTION diskon_harga(idkamar VARCHAR(10));


--	Contoh 6
CREATE OR REPLACE FUNCTION cek_jumlah_shift()
    RETURNS trigger AS
$$
DECLARE
    shift_count integer;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        SELECT COUNT(*)
        INTO shift_count
        FROM SHIFT_PERAWAT
        WHERE id_perawat = NEW.id_perawat
        GROUP BY id_perawat;
        IF (shift_count >= 5) THEN
            RAISE EXCEPTION 'Maaf, perawat tidak boleh memiliki shift melebihi 5';
        END IF;
        RETURN NEW;
    END IF;
END;
$$
    LANGUAGE plpgsql;


--	Contoh 7
CREATE TRIGGER trigger_cek_jumlah_shift
    BEFORE INSERT
    ON SHIFT_PERAWAT
    FOR EACH ROW
EXECUTE PROCEDURE cek_jumlah_shift();


--	Contoh 8
INSERT INTO SHIFT_PERAWAT (id_shift_perawat, id_perawat, id_rawat_inap, waktu_mulai, waktu_akhir)
VALUES ('SP101', 'PE13', 'RI20', '2020-11-30 00:00', '2020-11-30 12:00');

INSERT INTO SHIFT_PERAWAT (id_shift_perawat, id_perawat, id_rawat_inap, waktu_mulai, waktu_akhir)
VALUES ('SP101', 'PE11', 'RI20', '2020-11-30 00:00', '2020-11-30 12:00');

