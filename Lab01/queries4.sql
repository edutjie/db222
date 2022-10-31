-- 4.2
SELECT id_rawat_inap
FROM RAWAT_INAP ri
INNER JOIN KAMAR k USING(id_kamar)
WHERE k.jenis = 'VIP B';

-- 4.3
SELECT p.nama, k.nama, k.jenis, d.nama
FROM PASIEN p
INNER JOIN RAWAT_INAP ri USING(id_pasien)
INNER JOIN KAMAR k USING(id_kamar)
INNER JOIN DOKTER_RAWAT_INAP dri USING(id_rawat_inap)
INNER JOIN DOKTER d USING(id_dokter)

-- 4.4
SELECT nama
FROM PERAWAT 
WHERE nama LIKE '%Greger%';


-- 4.5
SELECT nama
FROM KAMAR
WHERE harga < 170000;