WITH tmp AS (SELECT DISTINCT email,
                             rname,
                             rbranch,
                             fname || ' ' || lname AS customer_name,
                             datetime,
                             ts.name               AS status,
                             datetimestatus
             FROM tk_a4.transaction
                      INNER JOIN tk_a4.transaction_food tf USING (email, datetime)
                      INNER JOIN tk_a4.transaction_history th USING (email, datetime)
                      INNER JOIN tk_a4.transaction_status ts ON ts.id = th.tsid
                      INNER JOIN tk_a4.user_acc USING (email)
             WHERE courierid = 'hlownes14@yolasite.com')
SELECT email, rname, rbranch, customer_name, datetime, status
FROM (SELECT email,
             rname,
             rbranch,
             customer_name,
             datetime,
             status,
             ROW_NUMBER() OVER (PARTITION BY email, datetime ORDER BY datetimestatus DESC) AS rn
      FROM tmp) t
WHERE t.rn = 1
  AND status = 'Pesanan Diantar';


SELECT *
FROM tk_a4.food
         INNER JOIN tk_a4.transaction_food tf USING (rname, rbranch, foodname)
WHERE email = 'ecraydone@theatlantic.com'
  AND datetime = '2021-11-09 00:00:00.000000';


SELECT foodname, amount, note
FROM tk_a4.transaction_food
WHERE email = 'ecraydone@theatlantic.com'
  AND datetime = '2021-11-09 00:00:00.000000'


SELECT MAX(id)
FROM tk_a4.ingredient;

SELECT MAX(CAST(REPLACE(id, 'RC', '') AS INT))
FROM tk_a4.restaurant_category