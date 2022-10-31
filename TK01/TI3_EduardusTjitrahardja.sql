-- Eduardus Tjitrahardja | 2106653602 | TI3

-- 1
SELECT rname, rbranch
FROM restaurant
WHERE city = 'Yogyakarta'
  AND rating > 4.5;

-- 2
SELECT foodname
FROM food
WHERE price BETWEEN 10000 AND 50000;


-- 3
-- ASUMSI: Mengquery semua ingredient yang mengandung kata kacang
SELECT f.foodname
FROM food f
WHERE f.rname = 'ABX'
  AND f.foodname IN (SELECT fi.foodname
                     FROM food_ingredient fi
                              INNER JOIN ingredient i ON i.id = fi.ingredient
                     WHERE i.name LIKE '%kacang%');


-- 4
SELECT tf.foodname, tf.note
FROM transaction_food tf
WHERE EXISTS(
        SELECT CONCAT(u.fname, ' ', u.lname)
        FROM user_acc u
                 INNER JOIN transaction t USING (email)
        WHERE CONCAT(u.fname, ' ', u.lname) = 'Dannel Joel'
          AND tf.email = t.email
          AND tf.datetime = t.datetime
    )
  AND tf.note IS NULL;


-- 5
WITH courier_transaction AS (SELECT *
                             FROM user_acc
                                      INNER JOIN courier USING (email)
                                      INNER JOIN transaction USING (email)
                                      INNER JOIN transaction_food USING (email, datetime))
SELECT CONCAT(ct.fname, ' ', ct.lname) AS couriername
FROM courier_transaction ct
WHERE rname = 'KFC'
  AND rbranch = 'Margonda'
  AND ct.email NOT IN (SELECT ct2.email
                       FROM courier_transaction ct2
                       WHERE ct2.rname = 'KFC'
                         AND ct2.rbranch = 'Lenteng Agung');


-- 6
SELECT CONCAT(u.fname, ' ', u.lname) AS name, u.email
FROM user_acc u
WHERE u.email NOT IN (SELECT t.email
                      FROM transaction t);


-- 7
SELECT CONCAT(u.fname, ' ', u.lname) AS name, u.email
FROM (SELECT t.email
      FROM transaction t
      GROUP BY 1
      HAVING COUNT(*) = (SELECT COUNT(*) FROM payment_method)) t_pm
         INNER JOIN user_acc u USING (email);


-- 8
-- ASUMSI: Yang paling laku artinya cuman query 1 teratas
WITH jumlahpembelian_food AS (SELECT f.foodname, f.price, f.rname, f.rbranch, SUM(amount) AS jumlahpembelian
                              FROM transaction_food tf
                                       INNER JOIN food f USING (rname, rbranch, foodname)
                              GROUP BY 1, 2, 3, 4)
SELECT foodname, price
FROM jumlahpembelian_food
WHERE rname = 'KFC'
  AND rbranch = 'Margonda'
ORDER BY jumlahpembelian DESC
LIMIT 1;


-- 9
SELECT COUNT(*) AS jumlahmenu, MIN(price) AS minprice, MAX(price) AS maxprice
FROM food f
GROUP BY rname, rbranch


-- 10
-- ASUMSI: min_transaction_promo selalu valid dan special_day_promo hanya valid jika hari ini adalah hari spesialnya
SELECT p.promoname
FROM (SELECT pid
      FROM restaurant_promo t
      GROUP BY 1
      HAVING COUNT(*) >= 10) AS rp_pid
         INNER JOIN promo p ON rp_pid.pid = p.id_promo
WHERE p.id_promo IN (SELECT id_special_day_promo
                     FROM special_day_promo
                     WHERE date = CURRENT_DATE
                     UNION
                     SELECT id_min_transaction_promo
                     FROM min_transaction_promo);