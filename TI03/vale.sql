--1
SELECT RName, RBranch
FROM RESTAURANT
WHERE Province = 'Yogyakarta'
  AND Rating > 4.5;

--2
SELECT FoodName
FROM FOOD
WHERE Price BETWEEN 10000 AND 50000;

--3
SELECT FoodName
FROM FOOD
WHERE RName = 'ABX'
  AND FoodName IN (SELECT FoodName
                   FROM FOOD_INGREDIENT FI
                            INNER JOIN INGREDIENT I ON I.id = FI.Ingredient
                   WHERE LOWER(I.Name) LIKE '%kacang%');

SELECT DISTINCT FoodName
FROM FOOD_INGREDIENT
WHERE Rname = 'ABX'
  AND INGREDIENT IN
      (SELECT Id FROM INGREDIENT WHERE Name = 'Kacang');

--4
SELECT FoodName, Note
FROM TRANSACTION_FOOD TF
WHERE EXISTS(
        SELECT U.Email
        FROM USER_ACC U,
             TRANSACTION T
        WHERE CONCAT(U.FName, ' ', U.LName) = 'Carissa Magnolia'
          AND T.Email = TF.Email
          AND T.Datetime = TF.datetime
          AND U.Email = T.Email
    )
  AND Note <> '';

SELECT TF.FoodName
FROM TRANSACTION_FOOD AS TF,
     USER_acc AS U
WHERE EXISTS(
        SELECT TF.Note
        FROM TRANSACTION_FOOD AS TF,
             USER_acc AS U
        WHERE TF.Note IS NOT NULL
          AND U.FName = 'Carissa'
          AND U.LName = 'Magnolia')
  AND TF.Note IS NOT NULL
  AND U.FName = 'Carissa'
  AND U.LName = 'Magnolia'
  AND u.Email = tf.Email;

SELECT DISTINCT FOODNAME
FROM TRANSACTION_FOOD TF
WHERE EXISTS(
        SELECT *
        FROM user_acc
        WHERE TF.EMAIL = user_acc.EMAIL AND UPPER(user_acc.FNAME) = 'CARISSA' AND UPPER(user_acc.LNAME) = 'MAGNOLIA')
  AND TF.NOTE IS NOT NULL;


--5
SELECT DISTINCT U.FName, U.LName
FROM USER_ACC U,
     TRANSACTION T,
     COURIER C,
     TRANSACTION_ACTOR TA,
     TRANSACTION_FOOD TF
WHERE TF.Email = T.Email
  AND TF.Datetime = T.Datetime
  AND T.CourierId = C.Email
  AND C.Email = TA.Email
  AND TA.Email = U.Email
  AND TF.RName = 'KFC'
  AND TF.RBranch = 'Margonda'
  AND T.CourierId NOT IN (SELECT CourierId
                          FROM TRANSACTION T,
                               TRANSACTION_FOOD TF
                          WHERE TF.RName = 'KFC'
                            AND TF.RBranch = 'Lenteng Agung'
                            AND TF.Email = T.Email
                            AND TF.Datetime = T.Datetime);

SELECT FName, LName
FROM USER_ACC AS U,
     TRANSACTION AS T,
     COURIER AS C
WHERE C.email = T.CourierId
  AND T.RName = 'KFC'
  AND T.RBranch = 'Margonda'
  AND C.Email NOT IN (SELECT Email
                      FROM TRANSACTION_FOOD
                      WHERE RName = 'KFC'
                        AND RBranch = 'Lenteng Agung');


--6
SELECT CONCAT(FName, ' ', LName) AS Name, Email
FROM USER_ACC
WHERE Email NOT IN (SELECT Email
                    FROM TRANSACTION);

--7
SELECT CONCAT(FName, ' ', LName) AS Name, U.Email
FROM USER_ACC U
WHERE U.Email IN (SELECT J.Email
                  FROM (SELECT T.*
                        FROM PAYMENT_METHOD PM
                                 INNER JOIN TRANSACTION T ON T.PMId = PM.Id) J
                  GROUP BY J.Email
                  HAVING COUNT(J.PMId) = (SELECT COUNT(*) FROM PAYMENT_METHOD));

SELECT U.Email, U.FName, U.LName
FROM USER_ACC AS U,
     TRANSACTION AS T,
     PAYMENT_METHOD AS PM
WHERE T.Email = U.Email
GROUP BY 1, 2, 3
HAVING COUNT(DISTINCT T.PMId) = (SELECT COUNT(*) FROM payment_method);

SELECT FName, LName, U.Email
FROM USER_ACC AS U,
     TRANSACTION AS T,
     PAYMENT_METHOD AS PM
WHERE U.Email = T.Email
GROUP BY Fname, Lname, U.Email
HAVING COUNT(DISTINCT PMId) = COUNT(DISTINCT PM.Id)
;


--8.
SELECT FoodName, MAX(Total)
FROM (SELECT rname, rbranch, foodname, SUM(Amount) AS Total
      FROM (SELECT *
            FROM TRANSACTION_FOOD
            WHERE RName = 'KFC'
              AND RBranch = 'Margonda') foo2
      GROUP BY 1, 2, 3) foo
GROUP BY 1
ORDER BY 2 DESC;

SELECT TF.FoodName, F.Price, SUM(Amount) AS JumlahPembelian
FROM TRANSACTION_FOOD AS TF,
     FOOD AS F
WHERE TF.RName = 'KFC'
  AND TF.RBranch = 'Margonda'
  AND F.FoodName = TF.FoodName
GROUP BY TF.FoodName, F.Price
ORDER BY (JumlahPembelian) DESC
LIMIT 1;


--9.
SELECT R.RName, R.RBranch, Amount, MinPrice, MaxPrice
FROM RESTAURANT R,
     (SELECT *, COUNT(*) AS Amount, MAX(Price) AS MaxPrice, MIN(PRICE) AS MinPrice
      FROM FOOD
      GROUP BY 1, 2, 3, 4, 5, 6, 7) J
WHERE R.RName = J.RName
  AND R.RBranch = J.RBranch
GROUP BY R.RName, R.RBranch, 3, 4, 5;

--10.
SELECT PromoName
FROM PROMO
WHERE id_promo IN (SELECT RP.PId
                   FROM RESTAURANT_PROMO RP
                   WHERE CURRENT_TIMESTAMP BETWEEN RP.start_promo AND RP.end_promo
                   GROUP BY RP.PId
                   HAVING COUNT(RP.PId) >= 10);

SELECT DISTINCT PromoName
FROM SPECIAL_DAY_PROMO AS SDP,
     RESTAURANT_PROMO,
     PROMO AS P
WHERE SDP.id_special_day_promo = P.id_promo
  AND CURRENT_TIMESTAMP <= Date
UNION
SELECT DISTINCT PromoName
FROM RESTAURANT_PROMO AS RP,
     PROMO AS P
WHERE RP.PId = P.id_promo
GROUP BY Pid, PromoName
HAVING COUNT(Pid) >= 10;

