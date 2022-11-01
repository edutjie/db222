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


-- 31
CREATE INDEX index_nama_pasien
    ON pasien USING HASH (nama);


-- 32
CREATE INDEX index_perawat
    ON perawat (id_perawat, nama DESC);


-- 33
CREATE INDEX index_nama_dokter
    ON dokter (nama);

CREATE INDEX index_spesialisasi_dokter
    ON dokter (spesialisasi);

-- 34
DROP INDEX index_nama_dokter;

-- 35
EXPLAIN ANALYZE
SELECT *
FROM PASIEN
WHERE jenis_kelamin = 'L';
