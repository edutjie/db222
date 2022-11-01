-- 2a
-- 2b
-- 2c
SELECT p.nama, SUM(EXTRACT(HOURS FROM sp.waktu_akhir - sp.waktu_mulai)) AS jam_kerja
FROM perawat p
         INNER JOIN shift_perawat sp USING (id_perawat)
GROUP BY 1;


-- 2d
SELECT p2.nama, p.id_pasien, p.nama
FROM perawat p2
         INNER JOIN shift_perawat sp USING (id_perawat)
         INNER JOIN rawat_inap ri USING (id_rawat_inap)
         INNER JOIN pasien p USING (id_pasien)
WHERE ri.tgl_keluar IS NULL
ORDER BY 2, 3