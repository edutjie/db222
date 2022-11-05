-- 2a
CREATE VIEW dokter AS
SELECT *
FROM dokter;

-- 2b

-- 2c
-- ASUMSI: durasi bekerja yang dilakukan oleh perawat itu maksudnya
-- total jam kerja yang sudah dilakukan perawat
CREATE VIEW perawat_durasikerja AS
SELECT p.nama, SUM(EXTRACT(HOURS FROM sp.waktu_akhir - sp.waktu_mulai)) AS durasi_kerja
FROM perawat p
         INNER JOIN shift_perawat sp USING (id_perawat)
GROUP BY 1;


-- 2d
CREATE VIEW pasien_perawat AS
SELECT p.id_pasien, p.nama, STRING_AGG(p2.nama, ', ') AS nama_perawat
FROM perawat p2
         INNER JOIN shift_perawat sp USING (id_perawat)
         INNER JOIN rawat_inap ri USING (id_rawat_inap)
         INNER JOIN pasien p USING (id_pasien)
WHERE ri.tgl_keluar IS NULL
GROUP BY 1, 2;


-- 3a
EXPLAIN ANALYZE
SELECT *
FROM kamar
ORDER BY harga DESC;

EXPLAIN ANALYZE
SELECT *
FROM rawat_inap
WHERE tgl_keluar IS NULL;

EXPLAIN ANALYZE
SELECT *
FROM perawat
WHERE nama LIKE 'T%';

EXPLAIN ANALYZE
SELECT *
FROM pasien
ORDER BY alamat
LIMIT 10;

-- 3b
CREATE INDEX index_harga_kamar
    ON kamar (harga);

CREATE INDEX index_tgl_keluar_rawat_inap
    ON rawat_inap (tgl_keluar);

CREATE INDEX index_nama_perawat
    ON perawat (nama);

CREATE INDEX index_alamat_pasien
    ON pasien (alamat);

DROP INDEX index_harga_kamar;
DROP INDEX index_tgl_keluar_rawat_inap;
DROP INDEX index_nama_perawat;
DROP INDEX index_alamat_pasien;
