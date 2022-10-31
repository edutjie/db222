-- 2
SELECT o.nama
FROM obat o
         INNER JOIN pemberian_obat po USING (id_obat)
WHERE po.id_shift_perawat IN (SELECT sp.id_shift_perawat
                              FROM shift_perawat sp
                                       INNER JOIN perawat p USING (id_perawat)
                              WHERE p.jenis_kelamin = 'P');


-- 3
SELECT DISTINCT o.nama
FROM obat o
         INNER JOIN pemberian_obat po USING (id_obat)
         INNER JOIN shift_perawat sp USING (id_shift_perawat)
         INNER JOIN rawat_inap ri USING (id_rawat_inap);


-- 4
SELECT *
FROM dokter
WHERE id_dokter NOT IN (SELECT id_dokter
                        FROM dokter_rawat_inap);


-- 5
SELECT d.nama,
       SUM(CASE WHEN dri.id_rawat_inap IS NOT NULL THEN 1 ELSE 0 END) AS jumlah_pasien_ri
FROM dokter d
         LEFT JOIN dokter_rawat_inap dri USING (id_dokter)
GROUP BY 1
ORDER BY 1;


-- 6
SELECT EXTRACT(MONTH FROM tgl_lahir) AS bulan, nama
FROM pasien
ORDER BY 1, 2;


-- 7
SELECT jenis, AVG(harga) AS avg_harga
FROM kamar k
GROUP BY 1;


-- 8
SELECT p.nama AS nama_pasien, ri.id_kamar, d.nama AS nama_dokter
FROM pasien p
         INNER JOIN rawat_inap ri USING (id_pasien)
         INNER JOIN dokter_rawat_inap dri USING (id_rawat_inap)
         INNER JOIN dokter d USING (id_dokter)
WHERE ri.tgl_keluar IS NULL;


-- 9
SELECT ri.tgl_masuk, ri.tgl_keluar
FROM pasien p
         INNER JOIN rawat_inap ri USING (id_pasien)
WHERE LOWER(p.nama) NOT LIKE '%e%';


-- 10
SELECT nama, no_telp
FROM pasien
WHERE id_pasien NOT IN (SELECT id_pasien
                        FROM rawat_inap);


-- 11
SELECT *
FROM pasien
         INNER JOIN rawat_inap ri USING (id_pasien)
         INNER JOIN kamar k USING (id_kamar)
WHERE k.jenis LIKE 'VIP%'
UNION
SELECT *
FROM pasien
         INNER JOIN rawat_inap ri USING (id_pasien)
         INNER JOIN kamar k USING (id_kamar)
WHERE k.jenis = 'VVIP';


-- 12
SELECT p2.nama, p2.jenis_kelamin
FROM perawat p2
         INNER JOIN shift_perawat sp USING (id_perawat)
         INNER JOIN rawat_inap ri USING (id_rawat_inap)
         INNER JOIN pasien p USING (id_pasien)
WHERE p.jenis_kelamin = 'P'
GROUP BY 1, 2
HAVING COUNT(DISTINCT id_pasien) = (SELECT COUNT(*) FROM pasien WHERE jenis_kelamin = 'P');