-- ssh -i eduardus.tjitrahardja_kawung.key eduardus.tjitrahardja@kawung.cs.ui.ac.id -p 12122
-- psql -U db22a004 -h dbpg.cs.ui.ac.id | 48055

CREATE SCHEMA TK_A4;


-- p
CREATE TABLE TK_A4.PAYMENT_STATUS
(
    id   VARCHAR(25) NOT NULL,
    name VARCHAR(25) NOT NULL,
    PRIMARY KEY (id)
);

INSERT INTO TK_A4.PAYMENT_STATUS (id, name)
VALUES ('635690f2fc13ae44b700022c', 'Paid'),
       ('635690f2fc13ae44b700022d', 'Unpaid'),
       ('635690f2fc13ae44b700022e', 'Failed');


-- q
CREATE TABLE TK_A4.TRANSACTION_STATUS
(
    id   VARCHAR(25) NOT NULL,
    name VARCHAR(25) NOT NULL,
    PRIMARY KEY (id)
);

INSERT INTO TK_A4.TRANSACTION_STATUS (id, name)
VALUES ('63569189fc13ae3f8d0000ef', 'Completed'),
       ('63569189fc13ae3f8d0000f0', 'Processing'),
       ('63569189fc13ae3f8d0000f1', 'Pending'),
       ('63569189fc13ae3f8d0000f2', 'Cancelled'),
       ('63569189fc13ae3f8d0000f3', 'Refunded');


-- r
CREATE TABLE TK_A4.TRANSACTION_FOOD
(
    email    VARCHAR(50) NOT NULL,
    datetime TIMESTAMP   NOT NULL,
    rname    VARCHAR(50) NOT NULL,
    rbranch  VARCHAR(25) NOT NULL,
    foodname VARCHAR(50) NOT NULL,
    amount   INT         NOT NULL,
    note     VARCHAR(255),
    PRIMARY KEY (email, datetime, rname, rbranch, foodname),
    FOREIGN KEY (email, datetime) REFERENCES TK_A4.TRANSACTION (email, datetime) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (rname, rbranch, foodname) REFERENCES TK_A4.FOOD (rname, rbranch, foodname) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE TK_A4.TRANSACTION_FOOD
(
    email    varchar(300),
    datetime varchar(300),
    rname    varchar(300),
    rbranch  varchar(300),
    foodname varchar(300),
    amount   varchar(300),
    note     varchar(300)
);

INSERT INTO TK_A4.TRANSACTION_FOOD (email, datetime, rname, rbranch, foodname, amount, note)
VALUES ('zmandre5@cafepress.com', '2017-07-23', 'Feedburner Eats', 'Bubutan', 'Risotto', '7', 'Extra Sauce'),
       ('ecosterd6@goo.ne.jp', '2020-12-30', 'Warung Webs', 'Penjaringan', 'Casserole', '1', 'No onion'),
       ('djoel7@google.nl', '2021-10-05', 'Stanford Resto', 'Setiabudi', 'Tuna Nigiri', '5', NULL),
       ('estorton8@comsenz.com', '2018-5-12', 'NatGeo Eats', 'Semarang Selatan', 'Salmon Sashimi', '2', 'No spicy'),
       ('vbestwerthick9@gov.uk', '2019-10-10', 'Ovh Diner', 'Kebon Jeruk', 'Gudeg', '7', NULL),
       ('acardenosaa@earthlink.net', '2017-05-05', 'Warung Webs', 'Penjaringan', 'Carbonara', '6', NULL),
       ('scutillb@vinaora.com', '2022-05-07', 'RM Xrea', 'Medan Kota', 'Rujak Cingur', '9', 'Extra Sauce'),
       ('gtinseyc@tuttocitta.it', '2022-09-10', 'Warteg Yellowbook', 'Pakualaman', 'Tom Yum', '3', NULL),
       ('efavilld@dell.com', '2021-01-24', 'Image Shack', 'Pademangan', 'Pad Thai', '2', 'Extra Cheese'),
       ('ecraydone@theatlantic.com', '2021-11-09', 'Warmindo Imgur', 'Taman Sari', 'Dendeng Batoko', '1', NULL);

-- s
CREATE TABLE TK_A4.TRANSACTION_HISTORY
(
    email          VARCHAR(50) NOT NULL,
    datetime       TIMESTAMP   NOT NULL,
    tsid           VARCHAR(25) NOT NULL,
    datetimestatus TIMESTAMP   NOT NULL,
    PRIMARY KEY (email, datetime, tsid),
    FOREIGN KEY (email, datetime) REFERENCES TK_A4.TRANSACTION (email, datetime) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (tsid) REFERENCES TK_A4.TRANSACTION_STATUS (id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO TK_A4.TRANSACTION_HISTORY ("email", "datetime", "tsid", "datetimestatus")
VALUES ('zmandre5@cafepress.com', '2017-07-23', '63569189fc13ae3f8d0000ef', '2017-07-25'),
       ('ecosterd6@goo.ne.jp', '2020-12-30', '63569189fc13ae3f8d0000f2', '2020-12-31'),
       ('djoel7@google.nl', '2021-10-05', '63569189fc13ae3f8d0000ef', '2021-10-08'),
       ('estorton8@comsenz.com', '2018-5-12', '63569189fc13ae3f8d0000f2', '2018-5-15'),
       ('vbestwerthick9@gov.uk', '2019-10-10', '63569189fc13ae3f8d0000f0', '2019-10-12'),
       ('acardenosaa@earthlink.net', '2017-05-05', '63569189fc13ae3f8d0000f2', '2017-05-06'),
       ('scutillb@vinaora.com', '2022-05-07', '63569189fc13ae3f8d0000f3', '2022-05-14'),
       ('gtinseyc@tuttocitta.it', '2022-09-10', '63569189fc13ae3f8d0000f1', '2022-09-14'),
       ('efavilld@dell.com', '2021-01-24', '63569189fc13ae3f8d0000ef', '2021-01-26');