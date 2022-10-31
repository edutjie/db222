CREATE TABLE sirest.payment_status
(
    id   varchar(25) NOT NULL
        PRIMARY KEY,
    name varchar(25) NOT NULL
);

ALTER TABLE sirest.payment_status
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.transaction_status
(
    id   varchar(25) NOT NULL
        PRIMARY KEY,
    name varchar(25) NOT NULL
);

ALTER TABLE sirest.transaction_status
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.ingredient
(
    id   varchar(25) NOT NULL
        PRIMARY KEY,
    name varchar(25) NOT NULL
);

ALTER TABLE sirest.ingredient
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.user_acc
(
    email    varchar(50) NOT NULL
        PRIMARY KEY,
    password varchar(50) NOT NULL,
    phonenum varchar(20) NOT NULL,
    fname    varchar(15) NOT NULL,
    lname    varchar(15) NOT NULL
);

ALTER TABLE sirest.user_acc
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.admin
(
    email varchar(50) NOT NULL
        PRIMARY KEY
        REFERENCES sirest.user_acc
            ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE sirest.admin
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.payment_method
(
    id   varchar(25) NOT NULL
        PRIMARY KEY,
    name varchar(25) NOT NULL
);

ALTER TABLE sirest.payment_method
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.transaction_actor
(
    email     varchar(50)      NOT NULL
        PRIMARY KEY
        REFERENCES sirest.user_acc
            ON UPDATE CASCADE ON DELETE CASCADE,
    nik       varchar(20)      NOT NULL,
    bankname  varchar(20)      NOT NULL,
    accountno varchar(20)      NOT NULL,
    restopay  bigint DEFAULT 0 NOT NULL,
    adminid   varchar(50)      NOT NULL
        REFERENCES sirest.admin
            ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE sirest.transaction_actor
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.courier
(
    email             varchar(50) NOT NULL
        PRIMARY KEY
        REFERENCES sirest.transaction_actor
            ON UPDATE CASCADE ON DELETE CASCADE,
    platenum          varchar(10) NOT NULL,
    drivinglicensenum varchar(20) NOT NULL,
    vehicletype       varchar(15) NOT NULL,
    vehiclebrand      varchar(15) NOT NULL
);

ALTER TABLE sirest.courier
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.delivery_fee_per_km
(
    id       varchar(20) NOT NULL
        PRIMARY KEY,
    province varchar(25) NOT NULL,
    motorfee integer     NOT NULL,
    carfee   integer     NOT NULL
);

ALTER TABLE sirest.delivery_fee_per_km
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.customer
(
    email     varchar(50) NOT NULL
        PRIMARY KEY
        REFERENCES sirest.transaction_actor
            ON UPDATE CASCADE ON DELETE CASCADE,
    birthdate date        NOT NULL,
    sex       char        NOT NULL
);

ALTER TABLE sirest.customer
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.transaction
(
    email         varchar(50)      NOT NULL
        REFERENCES sirest.customer,
    datetime      timestamp        NOT NULL,
    street        varchar(30)      NOT NULL,
    district      varchar(30)      NOT NULL,
    city          varchar(25)      NOT NULL,
    province      varchar(25)      NOT NULL,
    totalfood     integer          NOT NULL,
    totaldiscount double precision NOT NULL,
    deliveryfee   double precision NOT NULL,
    totalprice    double precision NOT NULL,
    rating        integer          NOT NULL,
    pmid          varchar(25)      NOT NULL
        REFERENCES sirest.payment_method,
    psid          varchar(25)      NOT NULL
        REFERENCES sirest.payment_status,
    dfid          varchar(20)      NOT NULL
        REFERENCES sirest.delivery_fee_per_km,
    courierid     varchar(50)      NOT NULL
        REFERENCES sirest.courier,
    PRIMARY KEY (email, datetime)
);

ALTER TABLE sirest.transaction
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.transaction_history
(
    email          varchar(50) NOT NULL,
    datetime       timestamp   NOT NULL,
    tsid           varchar(25) NOT NULL
        REFERENCES sirest.transaction_status
            ON UPDATE CASCADE ON DELETE CASCADE,
    datetimestatus timestamp   NOT NULL,
    PRIMARY KEY (email, datetime, tsid),
    CONSTRAINT transaction_history_email_fkey
        FOREIGN KEY (email, datetime) REFERENCES sirest.transaction
            ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE sirest.transaction_history
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.restaurant_category
(
    id   varchar(20) NOT NULL
        PRIMARY KEY,
    name varchar(50) NOT NULL
);

ALTER TABLE sirest.restaurant_category
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.food_category
(
    id   varchar(20) NOT NULL
        PRIMARY KEY,
    name varchar(50) NOT NULL
);

ALTER TABLE sirest.food_category
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.restaurant
(
    rname     varchar(25)       NOT NULL,
    rbranch   varchar(25)       NOT NULL,
    email     varchar(50)       NOT NULL
        REFERENCES sirest.transaction_actor
            ON UPDATE CASCADE ON DELETE CASCADE,
    rphonenum varchar(18)       NOT NULL,
    street    varchar(30)       NOT NULL,
    district  varchar(20)       NOT NULL,
    city      varchar(20)       NOT NULL,
    province  varchar(20)       NOT NULL,
    rating    integer DEFAULT 0 NOT NULL
        CONSTRAINT restaurant_rating_check
            CHECK ((rating >= 0) AND (rating <= 10)),
    rcategory varchar(20)       NOT NULL
        REFERENCES sirest.restaurant_category
            ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (rname, rbranch)
);

ALTER TABLE sirest.restaurant
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.restaurant_operating_hours
(
    name       varchar(25) NOT NULL,
    branch     varchar(25) NOT NULL,
    day        varchar(10) NOT NULL,
    starthours time        NOT NULL,
    endhours   time        NOT NULL,
    PRIMARY KEY (name, branch, day),
    CONSTRAINT restaurant_operating_hours_name_fkey
        FOREIGN KEY (name, branch) REFERENCES sirest.restaurant
            ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE sirest.restaurant_operating_hours
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.food
(
    rname       varchar(25) NOT NULL,
    rbranch     varchar(25) NOT NULL,
    foodname    varchar(50) NOT NULL,
    description text,
    stock       integer     NOT NULL,
    price       bigint      NOT NULL,
    fcategory   varchar(20) NOT NULL
        REFERENCES sirest.food_category
            ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (rname, rbranch, foodname),
    CONSTRAINT food_rname_fkey
        FOREIGN KEY (rname, rbranch) REFERENCES sirest.restaurant
            ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE sirest.food
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.food_ingredient
(
    rname      varchar(25) NOT NULL,
    rbranch    varchar(25) NOT NULL,
    foodname   varchar(50) NOT NULL,
    ingredient varchar(25) NOT NULL
        REFERENCES sirest.ingredient,
    PRIMARY KEY (rname, rbranch, foodname, ingredient),
    CONSTRAINT food_ingredient_rname_fkey
        FOREIGN KEY (rname, rbranch, foodname) REFERENCES sirest.food
);

ALTER TABLE sirest.food_ingredient
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.transaction_food
(
    email    varchar(50) NOT NULL,
    datetime timestamp   NOT NULL,
    rname    varchar(50) NOT NULL,
    rbranch  varchar(25) NOT NULL,
    foodname varchar(50) NOT NULL,
    amount   integer     NOT NULL,
    note     varchar(255),
    PRIMARY KEY (email, datetime, rname, rbranch, foodname),
    CONSTRAINT transaction_food_email_fkey
        FOREIGN KEY (email, datetime) REFERENCES sirest.transaction
            ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT transaction_food_rname_fkey
        FOREIGN KEY (rname, rbranch, foodname) REFERENCES sirest.food
            ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE sirest.transaction_food
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.promo
(
    id_promo  varchar(25) NOT NULL
        PRIMARY KEY,
    promoname varchar(25) NOT NULL,
    discount  integer     NOT NULL
        CONSTRAINT promo_discount_check
            CHECK (discount > 0)
        CONSTRAINT promo_discount_check1
            CHECK (discount <= 100)
);

ALTER TABLE sirest.promo
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.min_transaction_promo
(
    id_min_transaction_promo varchar(25) NOT NULL
        PRIMARY KEY
        REFERENCES sirest.promo
            ON UPDATE CASCADE ON DELETE CASCADE,
    minimumtransactionnum    integer     NOT NULL
);

ALTER TABLE sirest.min_transaction_promo
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.special_day_promo
(
    id_special_day_promo varchar(25) NOT NULL
        PRIMARY KEY
        REFERENCES sirest.promo
            ON UPDATE CASCADE ON DELETE CASCADE,
    date                 date        NOT NULL
);

ALTER TABLE sirest.special_day_promo
    OWNER TO "eduardus.tjitrahardja";

CREATE TABLE sirest.restaurant_promo
(
    rname       varchar(25) NOT NULL,
    rbranch     varchar(25) NOT NULL,
    foodname    varchar(50) NOT NULL,
    pid         varchar(25) NOT NULL
        REFERENCES sirest.promo
            ON UPDATE CASCADE ON DELETE CASCADE,
    start_promo timestamp   NOT NULL,
    end_promo   timestamp   NOT NULL,
    PRIMARY KEY (rname, rbranch, foodname, pid),
    CONSTRAINT restaurant_promo_rname_fkey
        FOREIGN KEY (rname, rbranch, foodname) REFERENCES sirest.food
            ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE sirest.restaurant_promo
    OWNER TO "eduardus.tjitrahardja";

