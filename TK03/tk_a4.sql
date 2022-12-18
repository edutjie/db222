--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.26
-- Dumped by pg_dump version 11.17 (Debian 11.17-0+deb10u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: tk_a4; Type: SCHEMA; Schema: -; Owner: db22a004
--

CREATE SCHEMA tk_a4;


ALTER SCHEMA tk_a4 OWNER TO db22a004;

--
-- Name: biaya_pengantaran_pesanan(); Type: FUNCTION; Schema: tk_a4; Owner: db22a004
--

CREATE FUNCTION tk_a4.biaya_pengantaran_pesanan() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
        biaya_provinsi DOUBLE PRECISION;
        tipe_kendaraan VARCHAR(15);
    BEGIN
        IF (TG_OP = 'INSERT' or TG_OP = 'UPDATE') THEN
            SELECT vehicletype INTO tipe_kendaraan
            FROM courier
            WHERE NEW.courierid = email;
                
            IF (tipe_kendaraan = 'Mobil') THEN
                SELECT carfee INTO biaya_provinsi
                FROM delivery_fee_per_km dfpk
                WHERE dfpk.id = NEW.dfid;
            ELSE
                SELECT motorfee INTO biaya_provinsi
                FROM delivery_fee_per_km dfpk
                WHERE dfpk.id = NEW.dfid;
            END IF;

            NEW.deliveryfee := biaya_provinsi * 2;
            NEW.totalprice := NEW.totalfood - NEW.totaldiscount + NEW.deliveryfee;
            RETURN NEW;
        END IF;
    END;
$$;


ALTER FUNCTION tk_a4.biaya_pengantaran_pesanan() OWNER TO db22a004;

--
-- Name: cekpromo(); Type: FUNCTION; Schema: tk_a4; Owner: db22a004
--

CREATE FUNCTION tk_a4.cekpromo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$  
 DECLARE 
    tanggalPromo DATE;
 BEGIN
  tanggalPromo = (SELECT date FROM SPECIAL_DAY_PROMO WHERE id_special_day_promo = NEW.pid);
  IF (NEW.start_promo > tanggalPromo OR NEW.end_promo < tanggalPromo ) THEN
   RAISE EXCEPTION 'Tanggal tidak valid';
  
  END IF; 
  RETURN NEW;
 END;
$$;


ALTER FUNCTION tk_a4.cekpromo() OWNER TO db22a004;

--
-- Name: checkpesananselsai(); Type: FUNCTION; Schema: tk_a4; Owner: db22a004
--

CREATE FUNCTION tk_a4.checkpesananselsai() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    dfee       double precision;
    ffee       double precision;
    cid        varchar(50);
    restname   varchar(50);
    restbranch varchar(25);
BEGIN
    -- check if status = 'Pesanan Selesai'
    IF (NEW.tsid = (SELECT id
                    FROM transaction_status
                    WHERE name = 'Pesanan Selesai')) THEN
        -- get delivery fee
        SELECT deliveryfee, totalfood, courierid
        INTO dfee, ffee, cid
        FROM transaction
        WHERE email = NEW.email
          AND datetime = NEW.datetime;

        -- update courier's RestoPay
        UPDATE transaction_actor
        SET restopay = restopay + dfee
        WHERE email = cid;

        -- get restaurant's pk
        SELECT rname, rbranch
        INTO restname, restbranch
        FROM transaction_food
        WHERE email = NEW.email
          AND datetime = NEW.datetime;

        -- update restaurant's RestoPay
        UPDATE transaction_actor
        SET restopay = restopay + ffee
        WHERE email = (SELECT r.email
                       FROM restaurant r
                       WHERE rname = restname
                         AND rbranch = restbranch);
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION tk_a4.checkpesananselsai() OWNER TO db22a004;

--
-- Name: checkrestaurantcategory(); Type: FUNCTION; Schema: tk_a4; Owner: db22a004
--

CREATE FUNCTION tk_a4.checkrestaurantcategory() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    dfee       double precision;
    ffee       double precision;
    cid        varchar(50);
    restname   varchar(50);
    restbranch varchar(25);
BEGIN
    -- check if status = 'Pesanan Selesai'
    IF (NEW.tsid = (SELECT id
                    FROM transaction_status
                    WHERE name = 'Pesanan Selesai')) THEN
        -- get delivery fee
        SELECT deliveryfee, totalfood, courierid
        INTO dfee, ffee, cid
        FROM transaction
        WHERE email = NEW.email
          AND datetime = NEW.datetime;

        -- update courier's RestoPay
        UPDATE transaction_actor
        SET restopay = restopay + dfee
        WHERE email = cid;

        -- get restaurant's pk
        SELECT rname, rbranch
        INTO restname, restbranch
        FROM transaction_food
        WHERE email = NEW.email
          AND datetime = NEW.datetime;

        -- update restaurant's RestoPay
        UPDATE transaction_actor
        SET restopay = restopay + ffee
        WHERE email = (SELECT r.email
                       FROM restaurant r
                       WHERE rname = restname
                         AND rbranch = restbranch);
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION tk_a4.checkrestaurantcategory() OWNER TO db22a004;

--
-- Name: checkuserpassword(); Type: FUNCTION; Schema: tk_a4; Owner: db22a004
--

CREATE FUNCTION tk_a4.checkuserpassword() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- check if password contains uppercase and numeric
    IF ((SELECT COUNT(*) FROM REGEXP_MATCHES(NEW.password, '[0-9]', 'g')) < 1)
        OR ((SELECT COUNT(*) FROM REGEXP_MATCHES(NEW.password, '[A-Z]', 'g')) < 1)
    THEN
        RAISE EXCEPTION 'Password harus terdapat minimal 1 huruf kapital dan 1 angka.';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION tk_a4.checkuserpassword() OWNER TO db22a004;

--
-- Name: checkwithdraw(); Type: FUNCTION; Schema: tk_a4; Owner: db22a004
--

CREATE FUNCTION tk_a4.checkwithdraw() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 IF(TG_OP='UPDATE') THEN
  IF(NEW.restopay < 0) THEN
   RAISE EXCEPTION 'Jumlah yang Anda masukkan tidak mencukupi saldo Anda.';
  END IF;
  RETURN NEW;
 END IF;
END;
$$;


ALTER FUNCTION tk_a4.checkwithdraw() OWNER TO db22a004;

--
-- Name: validasi_tarif_per_km(); Type: FUNCTION; Schema: tk_a4; Owner: db22a004
--

CREATE FUNCTION tk_a4.validasi_tarif_per_km() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    limit_bawah CONSTANT INTEGER := 2000;
    limit_atas CONSTANT INTEGER := 7000;
  BEGIN
    IF (TG_OP = 'UPDATE' OR TG_OP = 'INSERT') THEN
      IF (NEW.carfee < limit_bawah OR NEW.motorfee < limit_bawah) THEN
        RAISE EXCEPTION 'Tarif tidak boleh di bawah 2000';
      END IF;

      IF (NEW.carfee > limit_atas OR NEW.motorfee > limit_atas) THEN
        RAISE EXCEPTION 'Tarif tidak boleh di atas 7000';
      END IF;

      IF (NEW.motorfee >= NEW.carfee) THEN
        RAISE EXCEPTION 'Tarif motor harus lebih rendah dari tarif mobil';
      END IF;
    END IF;
  END;
$$;


ALTER FUNCTION tk_a4.validasi_tarif_per_km() OWNER TO db22a004;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admin; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.admin (
    email character varying(50) NOT NULL
);


ALTER TABLE tk_a4.admin OWNER TO db22a004;

--
-- Name: courier; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.courier (
    email character varying(50) NOT NULL,
    platenum character varying(10) NOT NULL,
    drivinglicensenum character varying(20) NOT NULL,
    vehicletype character varying(15) NOT NULL,
    vehiclebrand character varying(15) NOT NULL
);


ALTER TABLE tk_a4.courier OWNER TO db22a004;

--
-- Name: customer; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.customer (
    email character varying(50) NOT NULL,
    birthdate date NOT NULL,
    sex character(1) NOT NULL
);


ALTER TABLE tk_a4.customer OWNER TO db22a004;

--
-- Name: delivery_fee_per_km; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.delivery_fee_per_km (
    id character varying(20) NOT NULL,
    province character varying(25) NOT NULL,
    motorfee integer NOT NULL,
    carfee integer NOT NULL
);


ALTER TABLE tk_a4.delivery_fee_per_km OWNER TO db22a004;

--
-- Name: food; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.food (
    rname character varying(25) NOT NULL,
    rbranch character varying(25) NOT NULL,
    foodname character varying(50) NOT NULL,
    description text,
    stock integer NOT NULL,
    price bigint NOT NULL,
    fcategory character varying(20) NOT NULL
);


ALTER TABLE tk_a4.food OWNER TO db22a004;

--
-- Name: food_category; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.food_category (
    id character varying(20) NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE tk_a4.food_category OWNER TO db22a004;

--
-- Name: food_ingredient; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.food_ingredient (
    rname character varying(25) NOT NULL,
    rbranch character varying(25) NOT NULL,
    foodname character varying(50) NOT NULL,
    ingredient character varying(25) NOT NULL
);


ALTER TABLE tk_a4.food_ingredient OWNER TO db22a004;

--
-- Name: ingredient; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.ingredient (
    id character varying(25) NOT NULL,
    name character varying(25) NOT NULL
);


ALTER TABLE tk_a4.ingredient OWNER TO db22a004;

--
-- Name: min_transaction_promo; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.min_transaction_promo (
    id_min_transaction_promo character varying(25) NOT NULL,
    minimumtransactionnum integer NOT NULL
);


ALTER TABLE tk_a4.min_transaction_promo OWNER TO db22a004;

--
-- Name: payment_method; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.payment_method (
    id character varying(25) NOT NULL,
    name character varying(25) NOT NULL
);


ALTER TABLE tk_a4.payment_method OWNER TO db22a004;

--
-- Name: payment_status; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.payment_status (
    id character varying(25) NOT NULL,
    name character varying(25) NOT NULL
);


ALTER TABLE tk_a4.payment_status OWNER TO db22a004;

--
-- Name: promo; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.promo (
    id_promo character varying(25) NOT NULL,
    promoname character varying(25) NOT NULL,
    discount integer NOT NULL,
    CONSTRAINT promo_discount_check CHECK ((discount > 0)),
    CONSTRAINT promo_discount_check1 CHECK ((discount <= 100))
);


ALTER TABLE tk_a4.promo OWNER TO db22a004;

--
-- Name: restaurant; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.restaurant (
    rname character varying(25) NOT NULL,
    rbranch character varying(25) NOT NULL,
    email character varying(50) NOT NULL,
    rphonenum character varying(18) NOT NULL,
    street character varying(30) NOT NULL,
    district character varying(20) NOT NULL,
    city character varying(20) NOT NULL,
    province character varying(20) NOT NULL,
    rating integer DEFAULT 0 NOT NULL,
    rcategory character varying(20) NOT NULL,
    CONSTRAINT restaurant_rating_check CHECK (((rating >= 0) AND (rating <= 10)))
);


ALTER TABLE tk_a4.restaurant OWNER TO db22a004;

--
-- Name: restaurant_category; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.restaurant_category (
    id character varying(20) NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE tk_a4.restaurant_category OWNER TO db22a004;

--
-- Name: restaurant_operating_hours; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.restaurant_operating_hours (
    name character varying(25) NOT NULL,
    branch character varying(25) NOT NULL,
    day character varying(10) NOT NULL,
    starthours time without time zone NOT NULL,
    endhours time without time zone NOT NULL
);


ALTER TABLE tk_a4.restaurant_operating_hours OWNER TO db22a004;

--
-- Name: restaurant_promo; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.restaurant_promo (
    rname character varying(25) NOT NULL,
    rbranch character varying(25) NOT NULL,
    foodname character varying(50) NOT NULL,
    pid character varying(25) NOT NULL,
    start_promo timestamp without time zone NOT NULL,
    end_promo timestamp without time zone NOT NULL
);


ALTER TABLE tk_a4.restaurant_promo OWNER TO db22a004;

--
-- Name: special_day_promo; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.special_day_promo (
    id_special_day_promo character varying(25) NOT NULL,
    date date NOT NULL
);


ALTER TABLE tk_a4.special_day_promo OWNER TO db22a004;

--
-- Name: tipe_kendaraan; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.tipe_kendaraan (
    vehicletype character varying(15)
);


ALTER TABLE tk_a4.tipe_kendaraan OWNER TO db22a004;

--
-- Name: transaction; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.transaction (
    email character varying(50) NOT NULL,
    datetime timestamp without time zone NOT NULL,
    street character varying(30) NOT NULL,
    district character varying(30) NOT NULL,
    city character varying(25) NOT NULL,
    province character varying(25) NOT NULL,
    totalfood double precision NOT NULL,
    totaldiscount double precision NOT NULL,
    deliveryfee double precision NOT NULL,
    totalprice double precision NOT NULL,
    rating integer,
    pmid character varying(25) NOT NULL,
    psid character varying(25) NOT NULL,
    dfid character varying(20) NOT NULL,
    courierid character varying(50)
);


ALTER TABLE tk_a4.transaction OWNER TO db22a004;

--
-- Name: transaction_actor; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.transaction_actor (
    email character varying(50) NOT NULL,
    nik character varying(20) NOT NULL,
    bankname character varying(20) NOT NULL,
    accountno character varying(20) NOT NULL,
    restopay bigint DEFAULT 0 NOT NULL,
    adminid character varying(50) NOT NULL
);


ALTER TABLE tk_a4.transaction_actor OWNER TO db22a004;

--
-- Name: transaction_food; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.transaction_food (
    email character varying(50) NOT NULL,
    datetime timestamp without time zone NOT NULL,
    rname character varying(50) NOT NULL,
    rbranch character varying(25) NOT NULL,
    foodname character varying(50) NOT NULL,
    amount integer NOT NULL,
    note character varying(255)
);


ALTER TABLE tk_a4.transaction_food OWNER TO db22a004;

--
-- Name: transaction_history; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.transaction_history (
    email character varying(50) NOT NULL,
    datetime timestamp without time zone NOT NULL,
    tsid character varying(25) NOT NULL,
    datetimestatus timestamp without time zone NOT NULL
);


ALTER TABLE tk_a4.transaction_history OWNER TO db22a004;

--
-- Name: transaction_status; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.transaction_status (
    id character varying(25) NOT NULL,
    name character varying(25) NOT NULL
);


ALTER TABLE tk_a4.transaction_status OWNER TO db22a004;

--
-- Name: user_acc; Type: TABLE; Schema: tk_a4; Owner: db22a004
--

CREATE TABLE tk_a4.user_acc (
    email character varying(50) NOT NULL,
    password character varying(50) NOT NULL,
    phonenum character varying(20) NOT NULL,
    fname character varying(15) NOT NULL,
    lname character varying(15) NOT NULL
);


ALTER TABLE tk_a4.user_acc OWNER TO db22a004;

--
-- Data for Name: admin; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.admin (email) FROM stdin;
eclibbery0@cisco.com
olowthian1@parallels.com
awilshaw2@about.me
jcarrodus3@redcross.org
kbutterfield4@cam.ac.uk
\.


--
-- Data for Name: courier; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.courier (email, platenum, drivinglicensenum, vehicletype, vehiclebrand) FROM stdin;
kmcdermottrowz@google.co.uk	B6808ZM	1507607059	Motor	Honda
lsanderson10@cam.ac.uk	AD4078HS	1035965856	Mobil	Hyundai
cmeatcher11@deliciousdays.com	B5097LT	1057722535	Motor	Yamaha
hbellchamber12@wiley.com	F6924LP	1343338222	Motor	Suzuki
cgoodread13@hugedomains.com	D9873IDR	1738610293	Motor	Kawasaki
hlownes14@yolasite.com	AA3526UOE	1324184572	Mobil	Toyota
alantry15@youtu.be	F8823FQ	1260113534	Motor	Honda
eprimett16@tumblr.com	BK3071BTK	1452226835	Motor	Yamaha
egolledge17@harvard.edu	D8898SHA	2085853500	Motor	Yamaha
lobispo18@cornell.edu	BB9030TVR	1317866437	Mobil	Toyota
\.


--
-- Data for Name: customer; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.customer (email, birthdate, sex) FROM stdin;
zmandre5@cafepress.com	2009-03-04	M
ecosterd6@goo.ne.jp	1993-02-16	F
djoel7@google.nl	1992-09-25	M
estorton8@comsenz.com	2001-07-23	F
vbestwerthick9@gov.uk	2009-02-23	M
acardenosaa@earthlink.net	2010-07-13	F
scutillb@vinaora.com	2001-02-01	F
gtinseyc@tuttocitta.it	1993-03-04	M
efavilld@dell.com	2010-05-30	M
ecraydone@theatlantic.com	2000-02-12	M
tchristenef@army.mil	2005-02-11	M
cwaszczykg@mediafire.com	1999-01-31	F
brishworthh@miitbeian.gov.cn	2008-10-11	M
vvandenhofi@indiatimes.com	1997-06-17	M
qwakelingj@zimbio.com	2009-01-04	M
pyarek@tuttocitta.it	1999-01-11	F
bgrievesl@wordpress.com	1999-07-01	F
mliccardim@addthis.com	2008-06-28	M
smerceyn@mapy.cz	2004-01-23	M
bcasacchiao@geocities.jp	1997-12-09	M
\.


--
-- Data for Name: delivery_fee_per_km; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.delivery_fee_per_km (id, province, motorfee, carfee) FROM stdin;
1	Jawa Timur	13000	20000
2	Jawa Barat	14000	30000
3	Kalimantan Timur	10000	15000
4	Sumatera Utara	10000	14000
5	Aceh	10000	13000
6	Jakarta	20000	30000
7	Bangka Belitung	11000	20000
8	Sulawesi Tengah	10000	18000
9	Bengkulu	13000	20000
10	Bali	50000	100000
\.


--
-- Data for Name: food; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.food (rname, rbranch, foodname, description, stock, price, fcategory) FROM stdin;
Feedburner Eats	Bubutan	Risotto	Fluffy and warm risotto	7	20000	FC3
Feedburner Eats	Bubutan	Casserole	Calming casserole	8	25000	FC3
Feedburner Eats	Bubutan	Carbonara	Soothing carbonara	9	28000	FC3
Warung Webs	Penjaringan	Risotto	Warm and fluffy risotto	10	18000	FC3
Warung Webs	Penjaringan	Casserole	Delightful casserole	11	29000	FC3
Warung Webs	Penjaringan	Carbonara	Creamy carbonara	12	24000	FC3
Stanford Resto	Setiabudi	Salmon Sashimi	Fresh cuts of salmon	13	45000	FC4
Stanford Resto	Setiabudi	Yakisoba	Chill and cold noodles	14	48000	FC4
Stanford Resto	Setiabudi	Tuna Nigiri	Thin slice of tuna over rice	5	30000	FC4
NatGeo Eats	Semarang Selatan	Salmon Sashimi	Fresh cuts of salmon	6	45000	FC4
NatGeo Eats	Semarang Selatan	Yakisoba	Chill and cold noodles	7	48000	FC4
NatGeo Eats	Semarang Selatan	Tuna Nigiri	Thin slice of tuna over rice	8	30000	FC4
Ovh Diner	Kebon Jeruk	Rujak Cingur	Fruits and veggies with sauce	9	15000	FC2
Ovh Diner	Kebon Jeruk	Rawon	Hearty beef stew	10	20000	FC2
Ovh Diner	Kebon Jeruk	Gudeg	Sweet and filling	11	22000	FC2
RM Xrea	Medan Kota	Rujak Cingur	Fruits and veggies with sauce	12	15000	FC2
RM Xrea	Medan Kota	Rawon	Hearty beef stew	13	20000	FC2
RM Xrea	Medan Kota	Gudeg	Sweet and filling	14	22000	FC2
Warteg Yellowbook	Pakualaman	Pad Thai	Spicy stir-fried noodles	5	34000	FC5
Warteg Yellowbook	Pakualaman	Tom Yum	Warm and sour soup	6	24000	FC5
Warteg Yellowbook	Pakualaman	Som Tam	Papaya salad	7	20000	FC5
Image Shack	Pademangan	Pad Thai	Spicy stir-fried noodles	8	34000	FC5
Image Shack	Pademangan	Tom Yum	Warm and sour soup	9	24000	FC5
Image Shack	Pademangan	Som Tam	Papaya salad	10	20000	FC5
Warmindo Imgur	Taman Sari	Rendang Sapi	Dry and flavorful beef	11	20000	FC1
Warmindo Imgur	Taman Sari	Dendeng Batoko	Spicy and flavorful beef slices	12	20000	FC1
Warmindo Imgur	Taman Sari	Ikan Asam Padeh	Sour and spicy fish	13	20000	FC1
Warkop Ihg	Kacapiring	Rendang Sapi	Dry and flavorful beef	14	30000	FC1
Warkop Ihg	Kacapiring	Dendeng Batoko	Spicy and flavorful beef slices	5	30000	FC1
Warkop Ihg	Kacapiring	Ikan Asam Padeh	Dry and flavorful beef	6	30000	FC1
\.


--
-- Data for Name: food_category; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.food_category (id, name) FROM stdin;
FC1	Padang
FC2	Java
FC3	Western
FC4	Japanese
FC5	Thai
\.


--
-- Data for Name: food_ingredient; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.food_ingredient (rname, rbranch, foodname, ingredient) FROM stdin;
Feedburner Eats	Bubutan	Risotto	4
Feedburner Eats	Bubutan	Risotto	7
Feedburner Eats	Bubutan	Risotto	10
Feedburner Eats	Bubutan	Risotto	18
Stanford Resto	Setiabudi	Salmon Sashimi	13
Stanford Resto	Setiabudi	Salmon Sashimi	8
Warmindo Imgur	Taman Sari	Rendang Sapi	2
Warmindo Imgur	Taman Sari	Rendang Sapi	3
Warmindo Imgur	Taman Sari	Rendang Sapi	6
Warmindo Imgur	Taman Sari	Rendang Sapi	7
Warmindo Imgur	Taman Sari	Rendang Sapi	8
Warmindo Imgur	Taman Sari	Rendang Sapi	12
Warmindo Imgur	Taman Sari	Rendang Sapi	14
Warmindo Imgur	Taman Sari	Rendang Sapi	16
Warung Webs	Penjaringan	Carbonara	1
Warung Webs	Penjaringan	Carbonara	2
Warung Webs	Penjaringan	Carbonara	6
Warung Webs	Penjaringan	Carbonara	15
Warung Webs	Penjaringan	Carbonara	17
Feedburner Eats	Bubutan	Carbonara	1
Feedburner Eats	Bubutan	Carbonara	2
Feedburner Eats	Bubutan	Carbonara	6
Feedburner Eats	Bubutan	Carbonara	15
Feedburner Eats	Bubutan	Carbonara	17
Feedburner Eats	Bubutan	Casserole	1
Feedburner Eats	Bubutan	Casserole	2
Feedburner Eats	Bubutan	Casserole	3
Feedburner Eats	Bubutan	Casserole	5
Feedburner Eats	Bubutan	Casserole	10
Feedburner Eats	Bubutan	Casserole	15
\.


--
-- Data for Name: ingredient; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.ingredient (id, name) FROM stdin;
1	Telur
2	Tomat
3	Kentang
4	Nasi
5	Bawang Bombay
6	Bawang Putih
7	Bawang Merah
8	Kecap Asin
9	Kecap Manis
10	Jamur
11	Saus Tiram
12	Tepung
13	Daging Ikan
14	Daging Sapi
15	Daging Ayam
16	Wortel
17	Daun Bawang
18	Kaldu Ayam
19	Roti
20	Brokoli
\.


--
-- Data for Name: min_transaction_promo; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.min_transaction_promo (id_min_transaction_promo, minimumtransactionnum) FROM stdin;
P1	170000
P11	50000
P3	125000
P13	300000
P5	250000
P15	400000
P7	350000
P17	430000
P9	100000
P19	110000
\.


--
-- Data for Name: payment_method; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.payment_method (id, name) FROM stdin;
1	GoPay
2	QRIS
3	Cash
4	Dana
5	ShopeePay
\.


--
-- Data for Name: payment_status; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.payment_status (id, name) FROM stdin;
635690f2fc13ae44b700022c	Paid
635690f2fc13ae44b700022d	Unpaid
635690f2fc13ae44b700022e	Failed
\.


--
-- Data for Name: promo; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.promo (id_promo, promoname, discount) FROM stdin;
P1	tumblr day	64
P2	tasty	91
P3	golden	48
P4	howard	71
P5	hoky	26
P6	mulaiajadulu	7
P7	hariindah	93
P8	genz	37
P9	pahlawan	5
P10	buatkamu	74
P11	halloween	33
P12	valentine	32
P13	harisantri	10
P14	patahati	81
P15	kasihsayang	30
P16	mantanterindah	11
P17	temantan	44
P18	cashback10k	58
P19	makanterus	66
P20	stopdiet	67
\.


--
-- Data for Name: restaurant; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.restaurant (rname, rbranch, email, rphonenum, street, district, city, province, rating, rcategory) FROM stdin;
Feedburner Eats	Bubutan	ctindlep@feedburner.com	2158139651.0	Jl Semarang 136-B	Bubutan	Surabaya	Jawa Timur	10	RC3
Warung Webs	Penjaringan	rborlandq@webs.com	5052407045.0	Jl Pluit Karang Cantik XIII	Penjaringan	Jakarta	DKI Jakarta	1	RC3
Stanford Resto	Setiabudi	kcastagner@stanford.edu	5053797983.0	Jl HR Rasuna Said Kav 1	Setiabudi	Jakarta	DKI Jakarta	2	RC4
NatGeo Eats	Semarang Selatan	stucks@nationalgeographic.com	3708693106.0	Jl Letjen Haryono MT 992-994	Semarang Selatan	Semarang	Jawa Tengah	3	RC4
Ovh Diner	Kebon Jeruk	jebbuttt@ovh.net	4437408211.0	Jl Kedoya Utr 4	Kebon Jeruk	Jakarta	DKI Jakarta	4	RC2
RM Xrea	Medan Kota	gironu@xrea.com	2397527263.0	Jl Jend Gatot Subroto 152 A	Medan Kota	Medan	Sumatera Utara	5	RC2
Warteg Yellowbook	Pakualaman	lsandeyv@yellowbook.com	8009742944.0	Jl Sultan Agung 34	Pakualaman	Yogyakarta	DI Yogyakarta	6	RC5
Image Shack	Pademangan	dbarnettw@imageshack.us	6028283069.0	Jl Baruna II 2	Pademangan	Jakarta	DKI Jakarta	7	RC5
Warmindo Imgur	Taman Sari	tvigarx@imgur.com	6857081354.0	Jl Pancoran 42 A	Taman Sari	Jakarta	DKI Jakarta	8	RC1
Warkop Ihg	Kacapiring	jwandsy@ihg.com	9897877032.0	Jl Jend A Yani 238	Kacapiring	Bandung	Jawa Barat	9	RC1
\.


--
-- Data for Name: restaurant_category; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.restaurant_category (id, name) FROM stdin;
RC1	Padang
RC2	Java
RC3	Western
RC4	Japanese
RC5	Thai
\.


--
-- Data for Name: restaurant_operating_hours; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.restaurant_operating_hours (name, branch, day, starthours, endhours) FROM stdin;
Feedburner Eats	Bubutan	Senin	09:00:00	21:00:00
Feedburner Eats	Bubutan	Selasa	07:00:00	19:00:00
Feedburner Eats	Bubutan	Rabu	08:00:00	20:00:00
Warung Webs	Penjaringan	Kamis	09:00:00	21:00:00
Warung Webs	Penjaringan	Jumat	07:00:00	19:00:00
Warung Webs	Penjaringan	Sabtu	08:00:00	20:00:00
Stanford Resto	Setiabudi	Minggu	09:00:00	21:00:00
Stanford Resto	Setiabudi	Senin	07:00:00	19:00:00
Stanford Resto	Setiabudi	Selasa	08:00:00	20:00:00
NatGeo Eats	Semarang Selatan	Rabu	09:00:00	21:00:00
NatGeo Eats	Semarang Selatan	Kamis	07:00:00	19:00:00
NatGeo Eats	Semarang Selatan	Jumat	08:00:00	20:00:00
Ovh Diner	Kebon Jeruk	Sabtu	09:00:00	21:00:00
Ovh Diner	Kebon Jeruk	Minggu	07:00:00	19:00:00
Ovh Diner	Kebon Jeruk	Senin	08:00:00	20:00:00
RM Xrea	Medan Kota	Selasa	09:00:00	21:00:00
RM Xrea	Medan Kota	Rabu	07:00:00	19:00:00
RM Xrea	Medan Kota	Kamis	08:00:00	20:00:00
Warteg Yellowbook	Pakualaman	Jumat	09:00:00	21:00:00
Warteg Yellowbook	Pakualaman	Sabtu	07:00:00	19:00:00
Warteg Yellowbook	Pakualaman	Minggu	08:00:00	20:00:00
Image Shack	Pademangan	Senin	09:00:00	21:00:00
Image Shack	Pademangan	Selasa	07:00:00	19:00:00
Image Shack	Pademangan	Rabu	08:00:00	20:00:00
Warmindo Imgur	Taman Sari	Kamis	09:00:00	21:00:00
Warmindo Imgur	Taman Sari	Jumat	07:00:00	19:00:00
Warmindo Imgur	Taman Sari	Sabtu	08:00:00	20:00:00
Warkop Ihg	Kacapiring	Minggu	09:00:00	21:00:00
Warkop Ihg	Kacapiring	Senin	07:00:00	19:00:00
Warkop Ihg	Kacapiring	Selasa	08:00:00	20:00:00
\.


--
-- Data for Name: restaurant_promo; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.restaurant_promo (rname, rbranch, foodname, pid, start_promo, end_promo) FROM stdin;
Warung Webs	Penjaringan	Risotto	P3	2022-02-02 12:00:00	2022-02-08 00:00:00
Feedburner Eats	Bubutan	Carbonara	P3	2022-01-03 00:00:00	2022-01-05 12:00:00
Warteg Yellowbook	Pakualaman	Som Tam	P4	2021-03-15 00:00:00	2021-03-15 21:00:00
Image Shack	Pademangan	Pad Thai	P3	2021-08-02 00:00:00	2021-08-04 12:00:00
Warmindo Imgur	Taman Sari	Ikan Asam Padeh	P4	2021-03-15 00:00:00	2021-03-15 21:00:00
Warkop Ihg	Kacapiring	Rendang Sapi	P5	2021-12-28 00:00:00	2021-12-29 00:00:00
Ovh Diner	Kebon Jeruk	Gudeg	P2	2022-08-12 00:00:00	2022-08-12 21:00:00
RM Xrea	Medan Kota	Rujak Cingur	P17	2022-08-13 12:00:00	2022-08-27 00:00:00
NatGeo Eats	Semarang Selatan	Yakisoba	P17	2022-03-22 00:00:00	2022-03-29 12:00:00
NatGeo Eats	Semarang Selatan	Tuna Nigiri	P19	2022-03-28 00:00:00	2022-04-10 12:00:00
Ovh Diner	Kebon Jeruk	Gudeg	P12	2022-08-13 00:00:00	2022-08-15 21:00:00
Warung Webs	Penjaringan	Risotto	P4	2021-03-15 00:00:00	2021-03-16 00:00:00
\.


--
-- Data for Name: special_day_promo; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.special_day_promo (id_special_day_promo, date) FROM stdin;
P2	2022-08-12
P12	2020-11-29
P4	2021-03-15
P14	2020-11-12
P6	2021-04-28
P16	2021-05-01
P8	2021-07-31
P18	2020-04-15
P10	2021-12-03
P20	2020-12-02
\.


--
-- Data for Name: tipe_kendaraan; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.tipe_kendaraan (vehicletype) FROM stdin;
Mobil
\.


--
-- Data for Name: transaction; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.transaction (email, datetime, street, district, city, province, totalfood, totaldiscount, deliveryfee, totalprice, rating, pmid, psid, dfid, courierid) FROM stdin;
zmandre5@cafepress.com	2017-07-23 00:00:00	Jln. Penyu No. 02	Air Putih	Batubara	Sumatera Utara	120000	1000	12939	131939	5	1	635690f2fc13ae44b700022c	3	kmcdermottrowz@google.co.uk
ecosterd6@goo.ne.jp	2020-12-30 00:00:00	Jln. Kemayoran No. 37	Pandau Hulu	Medan	Sumatera Utara	100000	32000	15424	83424	5	1	635690f2fc13ae44b700022d	1	lsanderson10@cam.ac.uk
djoel7@google.nl	2021-10-05 00:00:00	Jln. Basdat No. 86	Tambora	Angke	Jakarta Barat	59000	32100	13114	40014	4	2	635690f2fc13ae44b700022d	2	cmeatcher11@deliciousdays.com
estorton8@comsenz.com	2018-05-12 00:00:00	Jln. Soekarno Baru No. 57	Johar Baru	Johar Baru	Jakarta Tengah	34000	10102	15341	39239	3	1	635690f2fc13ae44b700022c	5	hbellchamber12@wiley.com
vbestwerthick9@gov.uk	2019-10-10 00:00:00	Jln. Masyarakat No. 59	Anggana	Kutai Kartanegara	Kalimantan Timur	55900	12041	54253	98112	4	3	635690f2fc13ae44b700022c	4	cgoodread13@hugedomains.com
acardenosaa@earthlink.net	2017-05-05 00:00:00	Jln. Merdeka Lama No. 10	Muara Komam	Paser	Kalimantan Timur	300040	15103	12142	297079	5	1	635690f2fc13ae44b700022c	7	hlownes14@yolasite.com
scutillb@vinaora.com	2022-05-07 00:00:00	Jln. Lee Hiong Hee No. 98	Air Buaya	Buru	Maluku	50190	12901	15251	52540	4	1	635690f2fc13ae44b700022c	9	alantry15@youtu.be
gtinseyc@tuttocitta.it	2022-09-10 00:00:00	Jln. Tiduran No. 100	Anyar	Serang	Banten	20000	0	15345	35345	5	5	635690f2fc13ae44b700022e	8	eprimett16@tumblr.com
efavilld@dell.com	2021-01-24 00:00:00	Jln. Kuku No. 7	Binuang	Polewali Mandar	Sulawesi Barat	68900	12310	63565	120155	1	4	635690f2fc13ae44b700022d	6	egolledge17@harvard.edu
ecraydone@theatlantic.com	2021-11-09 00:00:00	Jln. Kebahagiaan No. 29 	Dliingo	Bantul	D.I.Y	79000	3100	12415	88315	2	3	635690f2fc13ae44b700022e	10	lobispo18@cornell.edu
\.


--
-- Data for Name: transaction_actor; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.transaction_actor (email, nik, bankname, accountno, restopay, adminid) FROM stdin;
zmandre5@cafepress.com	6944428483436901	BCA	632099774	9355541	eclibbery0@cisco.com
ecosterd6@goo.ne.jp	6598703736999154	BCA	889098935	7696029	olowthian1@parallels.com
djoel7@google.nl	8073014204799137	BNI	892244888	6198574	awilshaw2@about.me
estorton8@comsenz.com	9392173763907738	MANDIRI	820825064	2561942	jcarrodus3@redcross.org
vbestwerthick9@gov.uk	9916836340330542	BRI	474900059	3625881	kbutterfield4@cam.ac.uk
acardenosaa@earthlink.net	7122066732672256	BCA	157106833	8473136	eclibbery0@cisco.com
scutillb@vinaora.com	4837972819648851	BNI	618796287	5272643	olowthian1@parallels.com
gtinseyc@tuttocitta.it	9993120925305212	CIMB	160665202	455596	awilshaw2@about.me
efavilld@dell.com	3854511336135941	BRI	895861772	2876138	jcarrodus3@redcross.org
ecraydone@theatlantic.com	3629973397697040	MANDIRI	524768873	6513939	kbutterfield4@cam.ac.uk
tchristenef@army.mil	7371281203210164	BRI	440267675	3150001	eclibbery0@cisco.com
cwaszczykg@mediafire.com	4462883173905348	CIMB	614606205	1540871	olowthian1@parallels.com
brishworthh@miitbeian.gov.cn	9338469176643732	BCA	190199884	5817162	awilshaw2@about.me
vvandenhofi@indiatimes.com	8028921004165409	BNI	290162928	1168687	jcarrodus3@redcross.org
qwakelingj@zimbio.com	8185803233843922	BNI	938350715	3186746	kbutterfield4@cam.ac.uk
pyarek@tuttocitta.it	4144734471887260	BNI	394873917	120938	eclibbery0@cisco.com
bgrievesl@wordpress.com	9739838696830966	MANDIRI	551552952	4355379	olowthian1@parallels.com
mliccardim@addthis.com	9841465640366453	CIMB	828288253	7679049	awilshaw2@about.me
smerceyn@mapy.cz	9016713196310897	MANDIRI	915918554	2232100	jcarrodus3@redcross.org
bcasacchiao@geocities.jp	7145381878561580	BRI	672552707	9096914	kbutterfield4@cam.ac.uk
ctindlep@feedburner.com	2281138984254599	CIMB	782470843	2711522	eclibbery0@cisco.com
rborlandq@webs.com	7943570707172799	BCA	618456476	8128675	olowthian1@parallels.com
kcastagner@stanford.edu	7585724999079610	MANDIRI	693355137	9419291	awilshaw2@about.me
stucks@nationalgeographic.com	7459621916969757	MANDIRI	155342137	7007091	jcarrodus3@redcross.org
jebbuttt@ovh.net	2130649103594117	BCA	912854236	8501991	kbutterfield4@cam.ac.uk
gironu@xrea.com	8181384464390068	BRI	837177987	8360719	eclibbery0@cisco.com
dbarnettw@imageshack.us	6174451167380750	BNI	536287208	3283794	awilshaw2@about.me
tvigarx@imgur.com	8194601851764000	BNI	706242072	362215	jcarrodus3@redcross.org
jwandsy@ihg.com	4118676100969636	BNI	405872506	2186589	kbutterfield4@cam.ac.uk
kmcdermottrowz@google.co.uk	9112792661728895	CIMB	759732747	7305648	eclibbery0@cisco.com
lsanderson10@cam.ac.uk	7424825263482585	CIMB	764343639	394481	olowthian1@parallels.com
cmeatcher11@deliciousdays.com	2311762524035020	BNI	581445087	7691537	awilshaw2@about.me
hbellchamber12@wiley.com	1772569432199822	MANDIRI	662048181	2557840	jcarrodus3@redcross.org
cgoodread13@hugedomains.com	6869326298110539	BCA	774924277	8919473	kbutterfield4@cam.ac.uk
hlownes14@yolasite.com	4810606214654054	BRI	798676021	5061661	eclibbery0@cisco.com
alantry15@youtu.be	5579239399934826	MANDIRI	14003723	8262041	olowthian1@parallels.com
egolledge17@harvard.edu	9049905109844172	BRI	109709520	8639226	jcarrodus3@redcross.org
lobispo18@cornell.edu	4227296852688809	BNI	129419978	765959	kbutterfield4@cam.ac.uk
eprimett16@tumblr.com	4207531361822717	BCA	926569823	3343544	awilshaw2@about.me
lsandeyv@yellowbook.com	2137850867615788	BRI	543378332	6804889	olowthian1@parallels.com
\.


--
-- Data for Name: transaction_food; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.transaction_food (email, datetime, rname, rbranch, foodname, amount, note) FROM stdin;
zmandre5@cafepress.com	2017-07-23 00:00:00	Feedburner Eats	Bubutan	Risotto	7	Extra Sauce
ecosterd6@goo.ne.jp	2020-12-30 00:00:00	Warung Webs	Penjaringan	Casserole	1	No onion
djoel7@google.nl	2021-10-05 00:00:00	Stanford Resto	Setiabudi	Tuna Nigiri	5	\N
estorton8@comsenz.com	2018-05-12 00:00:00	NatGeo Eats	Semarang Selatan	Salmon Sashimi	2	No spicy
vbestwerthick9@gov.uk	2019-10-10 00:00:00	Ovh Diner	Kebon Jeruk	Gudeg	7	\N
acardenosaa@earthlink.net	2017-05-05 00:00:00	Warung Webs	Penjaringan	Carbonara	6	\N
scutillb@vinaora.com	2022-05-07 00:00:00	RM Xrea	Medan Kota	Rujak Cingur	9	Extra Sauce
gtinseyc@tuttocitta.it	2022-09-10 00:00:00	Warteg Yellowbook	Pakualaman	Tom Yum	3	\N
efavilld@dell.com	2021-01-24 00:00:00	Image Shack	Pademangan	Pad Thai	2	Extra Cheese
ecraydone@theatlantic.com	2021-11-09 00:00:00	Warmindo Imgur	Taman Sari	Dendeng Batoko	1	\N
\.


--
-- Data for Name: transaction_history; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.transaction_history (email, datetime, tsid, datetimestatus) FROM stdin;
zmandre5@cafepress.com	2017-07-23 00:00:00	63569189fc13ae3f8d0000ef	2017-07-25 00:00:00
ecosterd6@goo.ne.jp	2020-12-30 00:00:00	63569189fc13ae3f8d0000f2	2020-12-31 00:00:00
djoel7@google.nl	2021-10-05 00:00:00	63569189fc13ae3f8d0000ef	2021-10-08 00:00:00
estorton8@comsenz.com	2018-05-12 00:00:00	63569189fc13ae3f8d0000f2	2018-05-15 00:00:00
vbestwerthick9@gov.uk	2019-10-10 00:00:00	63569189fc13ae3f8d0000f0	2019-10-12 00:00:00
acardenosaa@earthlink.net	2017-05-05 00:00:00	63569189fc13ae3f8d0000f2	2017-05-06 00:00:00
scutillb@vinaora.com	2022-05-07 00:00:00	63569189fc13ae3f8d0000f3	2022-05-14 00:00:00
gtinseyc@tuttocitta.it	2022-09-10 00:00:00	63569189fc13ae3f8d0000f1	2022-09-14 00:00:00
efavilld@dell.com	2021-01-24 00:00:00	63569189fc13ae3f8d0000ef	2021-01-26 00:00:00
ecraydone@theatlantic.com	2021-11-09 00:00:00	63569189fc13ae3f8d0000f3	2021-11-12 00:00:00
gtinseyc@tuttocitta.it	2022-09-10 00:00:00	63569189fc13ae3f8d0000ef	2022-09-14 00:15:00
\.


--
-- Data for Name: transaction_status; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.transaction_status (id, name) FROM stdin;
63569189fc13ae3f8d0000f2	Cancelled
63569189fc13ae3f8d0000f3	Refunded
63569189fc13ae3f8d0000ef	Pesanan Selesai
63569189fc13ae3f8d0000f1	Kurir Sedang Mengantar
63569189fc13ae3f8d0000f0	Mencari Kurir
\.


--
-- Data for Name: user_acc; Type: TABLE DATA; Schema: tk_a4; Owner: db22a004
--

COPY tk_a4.user_acc (email, password, phonenum, fname, lname) FROM stdin;
eclibbery0@cisco.com	4ihCBC	3112589459	Emmi	Clibbery
olowthian1@parallels.com	ORJhH31Y	3824762971	Ophelia	Lowthian
awilshaw2@about.me	RYaSpb9rJvQo	6311864984	Antonius	Wilshaw
jcarrodus3@redcross.org	m8EqD1Ueh3	1622201048	Jill	Carrodus
kbutterfield4@cam.ac.uk	DopOnw3eTimD	7531097680	Keefer	Butterfield
zmandre5@cafepress.com	2OEEGF	2336907982	Zia	Mandre
ecosterd6@goo.ne.jp	yKhbNJQ	2867478186	Erek	Costerd
djoel7@google.nl	pltnrTr9Ia	6344702588	Dannel	Joel
estorton8@comsenz.com	kEtl567	6369716408	Ellissa	Storton
vbestwerthick9@gov.uk	t3SSAWOW	3045789153	Vinnie	Bestwerthick
acardenosaa@earthlink.net	eJFqMQ	2662706779	Arvy	Cardenosa
scutillb@vinaora.com	qhWa8J	7083297155	Shane	Cutill
gtinseyc@tuttocitta.it	tvuxpx	5148258341	Goddart	Tinsey
efavilld@dell.com	3WljVdvJ	5035698815	Editha	Favill
ecraydone@theatlantic.com	cyvCjj73xa	6214095822	Enrica	Craydon
tchristenef@army.mil	BuA9Mbkv93h	5685336311	Tony	Christene
cwaszczykg@mediafire.com	oWxb7NBeUbJ9	2859778017	Crissy	Waszczyk
brishworthh@miitbeian.gov.cn	rlc1aO7xbz3N	9978935937	Brenda	Rishworth
vvandenhofi@indiatimes.com	HjpvzhfU	5823641991	Vassili	Van den Hof
qwakelingj@zimbio.com	Z9yCdy	1155978355	Quintilla	Wakeling
pyarek@tuttocitta.it	TVQTVLNM1	4752809971	Phineas	Yare
bgrievesl@wordpress.com	rqVvBDXC	7039991267	Brenden	Grieves
mliccardim@addthis.com	qZuxw8vMBGsQ	8081080960	Meggy	Liccardi
smerceyn@mapy.cz	mS7m38MKwYU	9268598156	Susann	Mercey
bcasacchiao@geocities.jp	YVzRZj0lUKW7	4123057237	Billie	Casacchia
ctindlep@feedburner.com	xi2DEPwx	4644601691	Chalmers	Tindle
rborlandq@webs.com	JRXgTyTVk	6768077374	Rebeca	Borland
kcastagner@stanford.edu	lzOS304	5167970156	Kane	Castagne
stucks@nationalgeographic.com	nGL08Szbr	8357271165	Salaidh	Tuck
jebbuttt@ovh.net	Lfmtoyj2ni0	5128494960	Janette	Ebbutt
gironu@xrea.com	pnpxvnSE11	7265906742	George	Iron
lsandeyv@yellowbook.com	CsvgstSRww	2624520099	Lin	Sandey
dbarnettw@imageshack.us	B7MHESFkp	7242013498	Dallon	Barnett
tvigarx@imgur.com	yk4SdUhvuiU	4952548685	Tootsie	Vigar
jwandsy@ihg.com	vXGvSY	4662887178	Jerrie	Wands
kmcdermottrowz@google.co.uk	hVtI8Z2d	2549232944	Kain	McDermott-Row
lsanderson10@cam.ac.uk	MUsi9Qf5	3331770021	Lesly	Sanderson
cmeatcher11@deliciousdays.com	5EueIb6Vaq6	5055057379	Celisse	Meatcher
hbellchamber12@wiley.com	D1MQPW2	5986152852	Harrison	Bellchamber
cgoodread13@hugedomains.com	8wALWCC	9224972919	Clay	Goodread
hlownes14@yolasite.com	GVFJDMdFr	2639309671	Helen-elizabeth	Lownes
alantry15@youtu.be	DkmKNy0Sl	2158450657	Anselm	Lantry
eprimett16@tumblr.com	7Rh7aCD	9715477710	Emmalyn	Primett
egolledge17@harvard.edu	vJbJrUZKmTY2	1977650643	Eba	Golledge
lobispo18@cornell.edu	mReDjxmIyv	3679530899	Lissa	Obispo
\.


--
-- Name: admin admin_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (email);


--
-- Name: courier courier_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.courier
    ADD CONSTRAINT courier_pkey PRIMARY KEY (email);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (email);


--
-- Name: delivery_fee_per_km delivery_fee_per_km_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.delivery_fee_per_km
    ADD CONSTRAINT delivery_fee_per_km_pkey PRIMARY KEY (id);


--
-- Name: food_category food_category_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.food_category
    ADD CONSTRAINT food_category_pkey PRIMARY KEY (id);


--
-- Name: food_ingredient food_ingredient_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.food_ingredient
    ADD CONSTRAINT food_ingredient_pkey PRIMARY KEY (rname, rbranch, foodname, ingredient);


--
-- Name: food food_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.food
    ADD CONSTRAINT food_pkey PRIMARY KEY (rname, rbranch, foodname);


--
-- Name: ingredient ingredient_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.ingredient
    ADD CONSTRAINT ingredient_pkey PRIMARY KEY (id);


--
-- Name: min_transaction_promo min_transaction_promo_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.min_transaction_promo
    ADD CONSTRAINT min_transaction_promo_pkey PRIMARY KEY (id_min_transaction_promo);


--
-- Name: payment_method payment_method_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.payment_method
    ADD CONSTRAINT payment_method_pkey PRIMARY KEY (id);


--
-- Name: payment_status payment_status_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.payment_status
    ADD CONSTRAINT payment_status_pkey PRIMARY KEY (id);


--
-- Name: promo promo_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.promo
    ADD CONSTRAINT promo_pkey PRIMARY KEY (id_promo);


--
-- Name: restaurant_category restaurant_category_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.restaurant_category
    ADD CONSTRAINT restaurant_category_pkey PRIMARY KEY (id);


--
-- Name: restaurant_operating_hours restaurant_operating_hours_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.restaurant_operating_hours
    ADD CONSTRAINT restaurant_operating_hours_pkey PRIMARY KEY (name, branch, day);


--
-- Name: restaurant restaurant_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.restaurant
    ADD CONSTRAINT restaurant_pkey PRIMARY KEY (rname, rbranch);


--
-- Name: restaurant_promo restaurant_promo_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.restaurant_promo
    ADD CONSTRAINT restaurant_promo_pkey PRIMARY KEY (rname, rbranch, foodname, pid);


--
-- Name: special_day_promo special_day_promo_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.special_day_promo
    ADD CONSTRAINT special_day_promo_pkey PRIMARY KEY (id_special_day_promo);


--
-- Name: transaction_actor transaction_actor_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.transaction_actor
    ADD CONSTRAINT transaction_actor_pkey PRIMARY KEY (email);


--
-- Name: transaction_food transaction_food_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.transaction_food
    ADD CONSTRAINT transaction_food_pkey PRIMARY KEY (email, datetime, rname, rbranch, foodname);


--
-- Name: transaction_history transaction_history_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.transaction_history
    ADD CONSTRAINT transaction_history_pkey PRIMARY KEY (email, datetime, tsid);


--
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (email, datetime);


--
-- Name: transaction_status transaction_status_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.transaction_status
    ADD CONSTRAINT transaction_status_pkey PRIMARY KEY (id);


--
-- Name: user_acc user_acc_pkey; Type: CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.user_acc
    ADD CONSTRAINT user_acc_pkey PRIMARY KEY (email);


--
-- Name: transaction_history checkpesananselsaitrigger; Type: TRIGGER; Schema: tk_a4; Owner: db22a004
--

CREATE TRIGGER checkpesananselsaitrigger AFTER INSERT ON tk_a4.transaction_history FOR EACH ROW EXECUTE PROCEDURE tk_a4.checkpesananselsai();


--
-- Name: user_acc checkuserpasswordtrigger; Type: TRIGGER; Schema: tk_a4; Owner: db22a004
--

CREATE TRIGGER checkuserpasswordtrigger AFTER INSERT OR UPDATE ON tk_a4.user_acc FOR EACH ROW EXECUTE PROCEDURE tk_a4.checkuserpassword();


--
-- Name: transaction trigger_biaya_pemesanan; Type: TRIGGER; Schema: tk_a4; Owner: db22a004
--

CREATE TRIGGER trigger_biaya_pemesanan BEFORE INSERT OR UPDATE ON tk_a4.transaction FOR EACH ROW EXECUTE PROCEDURE tk_a4.biaya_pengantaran_pesanan();


--
-- Name: restaurant_promo trigger_cekpromo; Type: TRIGGER; Schema: tk_a4; Owner: db22a004
--

CREATE TRIGGER trigger_cekpromo BEFORE INSERT OR UPDATE ON tk_a4.restaurant_promo FOR EACH ROW EXECUTE PROCEDURE tk_a4.cekpromo();


--
-- Name: delivery_fee_per_km trigger_validasi_tarif_per_km; Type: TRIGGER; Schema: tk_a4; Owner: db22a004
--

CREATE TRIGGER trigger_validasi_tarif_per_km BEFORE INSERT OR UPDATE ON tk_a4.delivery_fee_per_km FOR EACH ROW EXECUTE PROCEDURE tk_a4.validasi_tarif_per_km();


--
-- Name: transaction_actor triggercheckwithdraw; Type: TRIGGER; Schema: tk_a4; Owner: db22a004
--

CREATE TRIGGER triggercheckwithdraw BEFORE UPDATE ON tk_a4.transaction_actor FOR EACH ROW EXECUTE PROCEDURE tk_a4.checkwithdraw();


--
-- Name: admin admin_email_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.admin
    ADD CONSTRAINT admin_email_fkey FOREIGN KEY (email) REFERENCES tk_a4.user_acc(email) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: courier courier_email_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.courier
    ADD CONSTRAINT courier_email_fkey FOREIGN KEY (email) REFERENCES tk_a4.transaction_actor(email) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer customer_email_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.customer
    ADD CONSTRAINT customer_email_fkey FOREIGN KEY (email) REFERENCES tk_a4.transaction_actor(email) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: food food_fcategory_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.food
    ADD CONSTRAINT food_fcategory_fkey FOREIGN KEY (fcategory) REFERENCES tk_a4.food_category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: food_ingredient food_ingredient_ingredient_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.food_ingredient
    ADD CONSTRAINT food_ingredient_ingredient_fkey FOREIGN KEY (ingredient) REFERENCES tk_a4.ingredient(id);


--
-- Name: food_ingredient food_ingredient_rname_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.food_ingredient
    ADD CONSTRAINT food_ingredient_rname_fkey FOREIGN KEY (rname, rbranch, foodname) REFERENCES tk_a4.food(rname, rbranch, foodname);


--
-- Name: food food_rname_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.food
    ADD CONSTRAINT food_rname_fkey FOREIGN KEY (rname, rbranch) REFERENCES tk_a4.restaurant(rname, rbranch) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: min_transaction_promo min_transaction_promo_id_min_transaction_promo_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.min_transaction_promo
    ADD CONSTRAINT min_transaction_promo_id_min_transaction_promo_fkey FOREIGN KEY (id_min_transaction_promo) REFERENCES tk_a4.promo(id_promo) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: restaurant restaurant_email_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.restaurant
    ADD CONSTRAINT restaurant_email_fkey FOREIGN KEY (email) REFERENCES tk_a4.transaction_actor(email) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: restaurant_operating_hours restaurant_operating_hours_name_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.restaurant_operating_hours
    ADD CONSTRAINT restaurant_operating_hours_name_fkey FOREIGN KEY (name, branch) REFERENCES tk_a4.restaurant(rname, rbranch) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: restaurant_promo restaurant_promo_pid_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.restaurant_promo
    ADD CONSTRAINT restaurant_promo_pid_fkey FOREIGN KEY (pid) REFERENCES tk_a4.promo(id_promo) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: restaurant_promo restaurant_promo_rname_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.restaurant_promo
    ADD CONSTRAINT restaurant_promo_rname_fkey FOREIGN KEY (rname, rbranch, foodname) REFERENCES tk_a4.food(rname, rbranch, foodname) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: restaurant restaurant_rcategory_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.restaurant
    ADD CONSTRAINT restaurant_rcategory_fkey FOREIGN KEY (rcategory) REFERENCES tk_a4.restaurant_category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: special_day_promo special_day_promo_id_special_day_promo_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.special_day_promo
    ADD CONSTRAINT special_day_promo_id_special_day_promo_fkey FOREIGN KEY (id_special_day_promo) REFERENCES tk_a4.promo(id_promo) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction_actor transaction_actor_adminid_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.transaction_actor
    ADD CONSTRAINT transaction_actor_adminid_fkey FOREIGN KEY (adminid) REFERENCES tk_a4.admin(email) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction_actor transaction_actor_email_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.transaction_actor
    ADD CONSTRAINT transaction_actor_email_fkey FOREIGN KEY (email) REFERENCES tk_a4.user_acc(email) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction transaction_courierid_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.transaction
    ADD CONSTRAINT transaction_courierid_fkey FOREIGN KEY (courierid) REFERENCES tk_a4.courier(email);


--
-- Name: transaction transaction_dfid_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.transaction
    ADD CONSTRAINT transaction_dfid_fkey FOREIGN KEY (dfid) REFERENCES tk_a4.delivery_fee_per_km(id);


--
-- Name: transaction transaction_email_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.transaction
    ADD CONSTRAINT transaction_email_fkey FOREIGN KEY (email) REFERENCES tk_a4.customer(email);


--
-- Name: transaction_food transaction_food_email_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.transaction_food
    ADD CONSTRAINT transaction_food_email_fkey FOREIGN KEY (email, datetime) REFERENCES tk_a4.transaction(email, datetime) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction_food transaction_food_rname_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.transaction_food
    ADD CONSTRAINT transaction_food_rname_fkey FOREIGN KEY (rname, rbranch, foodname) REFERENCES tk_a4.food(rname, rbranch, foodname) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction_history transaction_history_email_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.transaction_history
    ADD CONSTRAINT transaction_history_email_fkey FOREIGN KEY (email, datetime) REFERENCES tk_a4.transaction(email, datetime) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction_history transaction_history_tsid_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.transaction_history
    ADD CONSTRAINT transaction_history_tsid_fkey FOREIGN KEY (tsid) REFERENCES tk_a4.transaction_status(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction transaction_pmid_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.transaction
    ADD CONSTRAINT transaction_pmid_fkey FOREIGN KEY (pmid) REFERENCES tk_a4.payment_method(id);


--
-- Name: transaction transaction_psid_fkey; Type: FK CONSTRAINT; Schema: tk_a4; Owner: db22a004
--

ALTER TABLE ONLY tk_a4.transaction
    ADD CONSTRAINT transaction_psid_fkey FOREIGN KEY (psid) REFERENCES tk_a4.payment_status(id);


--
-- PostgreSQL database dump complete
--

