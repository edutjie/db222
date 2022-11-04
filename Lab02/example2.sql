-- 27
CREATE VIEW daftar_dokter AS
SELECT id_dokter, nama
FROM dokter;


-- 28
SELECT *
FROM daftar_dokter;


-- 29
DROP VIEW daftar_dokter;


-- 30
CREATE INDEX index_jenis_kamar ON kamar (jenis);

DROP INDEX index_jenis_kamar;


-- 31
CREATE INDEX index_nama_pasien
    ON pasien USING HASH (nama);

DROP INDEX index_nama_pasien;


-- 32
CREATE INDEX index_perawat
    ON perawat (id_perawat, nama DESC);

DROP INDEX index_perawat;


-- 33
CREATE INDEX index_nama_dokter
    ON dokter (nama);

DROP INDEX index_nama_dokter;

CREATE INDEX index_spesialisasi_dokter
    ON dokter (spesialisasi);

DROP INDEX index_spesialisasi_dokter;

-- 34
DROP INDEX index_nama_dokter;

-- 35
EXPLAIN ANALYZE
SELECT *
FROM PASIEN
WHERE jenis_kelamin = 'L';