-- 1
SELECT nama
FROM DOKTER
WHERE id_dokter = 'DO04';


-- 2
SELECT nama, jenis, kapasitas
FROM KAMAR
ORDER BY harga;


-- 3a
SELECT *
FROM KAMAR
WHERE (kapasitas >= 2)
  AND (kapasitas <= 4);


-- 3b
SELECT *
FROM KAMAR
WHERE (kapasitas BETWEEN 2 AND 4);


-- 4
SELECT nama, email
FROM PERAWAT
WHERE nama LIKE 'Karen%';


-- 5
(SELECT *
 FROM DOKTER
 WHERE spesialisasi = 'anak')
UNION
(SELECT *
 FROM DOKTER
 WHERE spesialisasi = 'bedah');


-- 6
(SELECT *
 FROM DOKTER
 WHERE nama LIKE 'C%')
INTERSECT
(SELECT *
 FROM DOKTER
 WHERE spesialisasi = 'bedah');


-- 7
(SELECT *
 FROM DOKTER
 WHERE nama LIKE 'C%')
EXCEPT
(SELECT *
 FROM DOKTER
 WHERE spesialisasi = 'bedah');


-- 8
SELECT nama
FROM PASIEN
WHERE EXTRACT(DECADE FROM tgl_lahir) = '199';


-- 9
SELECT P.nama
FROM PASIEN P,
     KAMAR K,
     RAWAT_INAP R
WHERE R.id_pasien = P.id_pasien
  AND R.id_kamar = K.id_kamar
  AND K.nama = 'Merak 1';


-- 10
SELECT *
FROM PERAWAT
         CROSS JOIN SHIFT_PERAWAT;


-- 11
SELECT *
FROM PERAWAT P
         JOIN SHIFT_PERAWAT S
              ON P.id_perawat = S.id_perawat;


-- 12
SELECT *
FROM PERAWAT P
         LEFT OUTER JOIN SHIFT_PERAWAT S
                         ON P.id_perawat = S.id_perawat;


-- 13
SELECT *
FROM SHIFT_PERAWAT S
         RIGHT OUTER JOIN PERAWAT P
                          ON P.id_perawat = S.id_perawat;


-- 14
SELECT *
FROM OBAT O
         FULL OUTER JOIN PEMBERIAN_OBAT PO
                         ON O.id_obat = PO.id_obat;


-- 15
SELECT *
FROM PERAWAT
         NATURAL JOIN SHIFT_PERAWAT;


-- 16
SELECT id_pasien
FROM RAWAT_INAP
WHERE tgl_keluar IS NOT NULL;


-- 17
SELECT id_pasien
FROM RAWAT_INAP
WHERE tgl_keluar IS NULL;


-- 18
SELECT O.nama
FROM OBAT O
WHERE O.id_obat IN (SELECT PO.id_obat
                    FROM PEMBERIAN_OBAT PO,
                         SHIFT_PERAWAT SP,
                         PERAWAT P
                    WHERE PO.id_shift_perawat = SP.id_shift_perawat
                      AND SP.id_perawat = P.id_perawat
                      AND P.nama = 'Mitchell Greger');


-- 19
SELECT P.id_perawat, P.nama
FROM PERAWAT P
WHERE NOT EXISTS(
        SELECT *
        FROM PEMBERIAN_OBAT PO,
             SHIFT_PERAWAT SP
        WHERE PO.id_shift_perawat = SP.id_shift_perawat
          AND SP.id_perawat = P.id_perawat
    );


-- 20
SELECT MIN(harga)
FROM KAMAR;


-- 21
SELECT MAX(harga)
FROM KAMAR;


-- 22
SELECT COUNT(*)
FROM KAMAR;


-- 23
SELECT SUM(kapasitas)
FROM KAMAR;


-- 24
SELECT AVG(harga)
FROM KAMAR;


-- 25a
SELECT jenis, SUM(kapasitas)
FROM KAMAR
GROUP BY jenis;


-- 25b
SELECT EXTRACT(YEAR FROM P.tgl_lahir) AS TAHUN, COUNT(*)
FROM PASIEN P
GROUP BY EXTRACT(YEAR FROM P.tgl_lahir);


-- 26
SELECT K.jenis, COUNT(K.id_kamar)
FROM KAMAR K,
     RAWAT_INAP RI
WHERE RI.id_kamar = K.id_kamar
GROUP BY K.jenis
HAVING COUNT(K.id_kamar) >= 5;
