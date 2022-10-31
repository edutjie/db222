CREATE TABLE nama_schema.nama_table(
    nama_atribut1tipe_atribut1 [NOT NULL],
    nama_atribut2tipe_atribut2 [NOT NULL],
: PRIMARY KEY (nama_atribut1,...) FOREIGN KEY (nama_atribut) REFERENCES nama_tabel_yang_di - refer(nama_atribut_yang_di - refer) [ON DELETE RESTRICT | CASCADE | SET NULL | SET DEFAULT] [ON UPDATE RESTRICT | CASCADE ]
);
CREATE TABLE SIWANAP.DOKTER(
    id_dokter VARCHAR(10) NOT NULL,
    nama VARCHAR(100) NOT NULL,
    no_telp VARCHAR(14) NOT NULL,
    email VARCHAR(50) NOT NULL,
    spesialisasi TEXT NOT NULL,
    PRIMARY KEY (id_dokter)
);
CREATE TABLE SIWANAP.PASIEN(
    id_pasien VARCHAR(10) NOT NULL,
    nama VARCHAR(100) NOT NULL,
    alamat TEXT NOT NULL,
    no_telp VARCHAR(14) NOT NULL,
    email VARCHAR(50) NOT NULL,
    tgl_lahir DATE NOT NULL,
    jenis_kelamin CHAR(1) NOT NULL,
    PRIMARY KEY (id_pasien)
);
CREATE TABLE SIWANAP.PERAWAT(
    id_perawat VARCHAR(10) NOT NULL,
    nama VARCHAR(100) NOT NULL,
    no_telp VARCHAR(14) NOT NULL,
    email VARCHAR(50) NOT NULL,
    jenis_kelamin CHAR(1) NOT NULL,
    PRIMARY KEY (id_perawat)
);
CREATE TABLE SIWANAP.KAMAR(
    id_kamar VARCHAR(10) NOT NULL,
    nama VARCHAR(30) NOT NULL,
    jenis VARCHAR(10) NOT NULL,
    kapasitas SMALLINT NOT NULL,
    harga INT NOT NULL,
    PRIMARY KEY (id_kamar)
);
CREATE TABLE SIWANAP.OBAT(
    id_obat VARCHAR(10) NOT NULL,
    nama TEXT NOT NULL,
    PRIMARY KEY (id_obat)
);
CREATE TABLE SIWANAP.RAWAT_INAP(
    id_rawat_inap VARCHAR(10) NOT NULL,
    id_kamar VARCHAR(10) NOT NULL,
    id_pasien VARCHAR(10) NOT NULL,
    tgl_masuk DATE NOT NULL,
    tgl_keluar DATE,
    PRIMARY KEY (id_rawat_inap),
    FOREIGN KEY (id_kamar) REFERENCES SIWANAP.KAMAR(id_kamar) ON DELETE CASCADE,
    FOREIGN KEY (id_pasien) REFERENCES SIWANAP.PASIEN(id_pasien) ON DELETE CASCADE
);
CREATE TABLE SIWANAP.SHIFT_PERAWAT(
    id_shift_perawat VARCHAR(10) NOT NULL,
    id_perawat VARCHAR(10) NOT NULL,
    id_rawat_inap VARCHAR(10) NOT NULL,
    waktu_mulai TIMESTAMP NOT NULL,
    waktu_akhir TIMESTAMP,
    PRIMARY KEY (id_shift_perawat),
    FOREIGN KEY (id_perawat) REFERENCES SIWANAP.PERAWAT(id_perawat) ON DELETE CASCADE,
    FOREIGN KEY (id_rawat_inap) REFERENCES SIWANAP.RAWAT_INAP(id_rawat_inap) ON DELETE CASCADE
);
CREATE TABLE SIWANAP.DOKTER_RAWAT_INAP(
    id_dokter VARCHAR(10) NOT NULL,
    id_rawat_inap VARCHAR(10) NOT NULL,
    PRIMARY KEY (id_dokter, id_rawat_inap),
    FOREIGN KEY (id_dokter) REFERENCES SIWANAP.DOKTER(id_dokter) ON DELETE CASCADE,
    FOREIGN KEY (id_rawat_inap) REFERENCES SIWANAP.RAWAT_INAP(id_rawat_inap) ON DELETE CASCADE
);
CREATE TABLE SIWANAP.PEMBERIAN_OBAT(
    id_pemberian_obat VARCHAR(10) NOT NULL,
    id_shift_perawat VARCHAR(10) NOT NULL,
    id_obat VARCHAR(10) NOT NULL,
    dosis VARCHAR(10) NOT NULL,
    PRIMARY KEY (id_pemberian_obat),
    FOREIGN KEY (id_shift_perawat) REFERENCES SIWANAP.SHIFT_PERAWAT(id_shift_perawat) ON DELETE CASCADE,
    FOREIGN KEY (id_obat) REFERENCES SIWANAP.OBAT(id_obat) ON DELETE CASCADE
);