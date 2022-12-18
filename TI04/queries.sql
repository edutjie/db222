-- 1
SELECT *
FROM restaurant
WHERE rbranch = 'Margonda'
  AND rating > 4;


-- 2
SELECT DISTINCT rname, rbranch
FROM food
WHERE price > 50000;


-- 3
SELECT r.rname, r.rbranch, roh.endhours - roh.starthours AS OperatingDuration
FROM restaurant r
         INNER JOIN restaurant_operating_hours roh ON r.rname = roh.name AND r.rbranch = roh.branch
WHERE r.city = 'Bandung'
  AND r.province = 'Jawa Barat';


-- 4
SELECT r.rname, r.rbranch, rc.name
FROM restaurant r
         INNER JOIN restaurant_category rc ON rc.id = r.rcategory
WHERE r.province = 'DI Yogyakarta';


-- 5
SELECT f.foodname, i.name
FROM food f
         NATURAL JOIN food_ingredient fi
         JOIN ingredient i ON fi.ingredient = i.id
WHERE rname = 'KFC'
  AND rbranch = 'Margonda';


-- 6
SELECT ta.nik, u.fname || ' ' || u.lname AS fullname
FROM customer c
         INNER JOIN transaction_actor ta USING (email)
         INNER JOIN user_acc u USING (email)
WHERE C.sex = 'F';


-- 7
SELECT u.fname || ' ' || u.lname AS fullname, pm.id
FROM transaction t
         INNER JOIN user_acc u USING (email)
         INNER JOIN payment_method pm ON t.pmid = pm.id;
-- ÷
SELECT DISTINCT id
FROM payment_method;


-- 8
SELECT COUNT(foodname), AVG(price)
FROM food
WHERE rname = 'KFC'
  AND rbranch = 'Margonda';


-- 9
SELECT rname,
       COUNT(rbranch) AS TotalBranch,
       AVG(rating)    AS AvgRating
FROM restaurant
GROUP BY rname;


-- 10
SELECT rc.id, rc.name, COUNT(DISTINCT r.rname) AS count_restaurant
FROM restaurant r
         INNER JOIN restaurant_category rc
                    ON r.rcategory = rc.id
WHERE r.province = 'DKI Jakarta'
GROUP BY rc.id, rc.name;