--
-- PostgreSQL database dump
--

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.0

-- Started on 2026-06-17 18:51:19

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 43 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 3927 (class 0 OID 0)
-- Dependencies: 43
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 442 (class 1255 OID 25494)
-- Name: update_doctor_rating(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_doctor_rating() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE bac_si
    SET danh_gia = (
        SELECT ROUND(AVG(so_sao)::numeric, 1)
        FROM danh_gia_bac_si
        WHERE ma_bac_si = COALESCE(NEW.ma_bac_si, OLD.ma_bac_si)
    )
    WHERE ma_bac_si = COALESCE(NEW.ma_bac_si, OLD.ma_bac_si);
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_doctor_rating() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 331 (class 1259 OID 25375)
-- Name: ai_training_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ai_training_rules (
    rule_id character varying(50) NOT NULL,
    rule_name character varying(255) NOT NULL,
    symptom_id character varying(100) NOT NULL,
    symptom_keywords text NOT NULL,
    department_name character varying(100) NOT NULL,
    confidence integer DEFAULT 85,
    priority integer DEFAULT 2,
    advice text
);


ALTER TABLE public.ai_training_rules OWNER TO postgres;

--
-- TOC entry 312 (class 1259 OID 17563)
-- Name: bac_si; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bac_si (
    ma_bac_si integer NOT NULL,
    ho_ten character varying(100) NOT NULL,
    ma_khoa integer,
    ten_benh_vien character varying(200),
    chi_tiet_chuyen_mon text,
    anh_chan_dung_url text,
    danh_gia numeric(2,1) DEFAULT 5.0,
    hoc_vi character varying(50),
    kinh_nghiem text,
    ma_phong_chinh integer,
    trang_thai_hoat_dong boolean DEFAULT true,
    gia_kham integer DEFAULT 150000
);


ALTER TABLE public.bac_si OWNER TO postgres;

--
-- TOC entry 311 (class 1259 OID 17562)
-- Name: bac_si_ma_bac_si_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bac_si_ma_bac_si_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bac_si_ma_bac_si_seq OWNER TO postgres;

--
-- TOC entry 3932 (class 0 OID 0)
-- Dependencies: 311
-- Name: bac_si_ma_bac_si_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bac_si_ma_bac_si_seq OWNED BY public.bac_si.ma_bac_si;


--
-- TOC entry 326 (class 1259 OID 18848)
-- Name: chi_tiet_don_thuoc; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chi_tiet_don_thuoc (
    ma_chi_tiet integer NOT NULL,
    ma_don_thuoc integer NOT NULL,
    ten_thuoc text NOT NULL,
    lieu_luong text,
    so_ngay_dung integer,
    cach_dung text,
    ghi_chu text
);


ALTER TABLE public.chi_tiet_don_thuoc OWNER TO postgres;

--
-- TOC entry 325 (class 1259 OID 18847)
-- Name: chi_tiet_don_thuoc_ma_chi_tiet_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chi_tiet_don_thuoc_ma_chi_tiet_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chi_tiet_don_thuoc_ma_chi_tiet_seq OWNER TO postgres;

--
-- TOC entry 3935 (class 0 OID 0)
-- Dependencies: 325
-- Name: chi_tiet_don_thuoc_ma_chi_tiet_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chi_tiet_don_thuoc_ma_chi_tiet_seq OWNED BY public.chi_tiet_don_thuoc.ma_chi_tiet;


--
-- TOC entry 310 (class 1259 OID 17554)
-- Name: chuyen_khoa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chuyen_khoa (
    ma_khoa integer NOT NULL,
    ten_khoa character varying(100) NOT NULL,
    anh_icon_url text,
    mo_ta text
);


ALTER TABLE public.chuyen_khoa OWNER TO postgres;

--
-- TOC entry 309 (class 1259 OID 17553)
-- Name: chuyen_khoa_ma_khoa_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chuyen_khoa_ma_khoa_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chuyen_khoa_ma_khoa_seq OWNER TO postgres;

--
-- TOC entry 3938 (class 0 OID 0)
-- Dependencies: 309
-- Name: chuyen_khoa_ma_khoa_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chuyen_khoa_ma_khoa_seq OWNED BY public.chuyen_khoa.ma_khoa;


--
-- TOC entry 335 (class 1259 OID 25472)
-- Name: danh_gia_bac_si; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.danh_gia_bac_si (
    id integer NOT NULL,
    ma_bac_si integer,
    so_dien_thoai character varying(20),
    so_sao integer,
    nhan_xet text,
    ngay_danh_gia timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT danh_gia_bac_si_so_sao_check CHECK (((so_sao >= 1) AND (so_sao <= 5)))
);


ALTER TABLE public.danh_gia_bac_si OWNER TO postgres;

--
-- TOC entry 334 (class 1259 OID 25471)
-- Name: danh_gia_bac_si_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.danh_gia_bac_si_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.danh_gia_bac_si_id_seq OWNER TO postgres;

--
-- TOC entry 3941 (class 0 OID 0)
-- Dependencies: 334
-- Name: danh_gia_bac_si_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.danh_gia_bac_si_id_seq OWNED BY public.danh_gia_bac_si.id;


--
-- TOC entry 316 (class 1259 OID 17599)
-- Name: don_thuoc; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.don_thuoc (
    ma_don_thuoc integer NOT NULL,
    ma_lich_hen integer,
    ghi_chu_bac_si text,
    ngay_ke_don date DEFAULT CURRENT_DATE
);


ALTER TABLE public.don_thuoc OWNER TO postgres;

--
-- TOC entry 315 (class 1259 OID 17598)
-- Name: don_thuoc_ma_don_thuoc_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.don_thuoc_ma_don_thuoc_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.don_thuoc_ma_don_thuoc_seq OWNER TO postgres;

--
-- TOC entry 3944 (class 0 OID 0)
-- Dependencies: 315
-- Name: don_thuoc_ma_don_thuoc_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.don_thuoc_ma_don_thuoc_seq OWNED BY public.don_thuoc.ma_don_thuoc;


--
-- TOC entry 330 (class 1259 OID 25361)
-- Name: khoa_tu_khoa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.khoa_tu_khoa (
    id integer NOT NULL,
    ma_khoa integer,
    symptom_id character varying(100) NOT NULL,
    tu_khoa text NOT NULL
);


ALTER TABLE public.khoa_tu_khoa OWNER TO postgres;

--
-- TOC entry 329 (class 1259 OID 25360)
-- Name: khoa_tu_khoa_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.khoa_tu_khoa_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.khoa_tu_khoa_id_seq OWNER TO postgres;

--
-- TOC entry 3947 (class 0 OID 0)
-- Dependencies: 329
-- Name: khoa_tu_khoa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.khoa_tu_khoa_id_seq OWNED BY public.khoa_tu_khoa.id;


--
-- TOC entry 314 (class 1259 OID 17578)
-- Name: lich_hen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lich_hen (
    ma_lich_hen integer NOT NULL,
    so_dien_thoai_bn character varying(15),
    ma_bac_si integer,
    ngay_kham date NOT NULL,
    khung_gio time without time zone NOT NULL,
    trang_thai character varying(30) DEFAULT 'Chờ xác nhận'::character varying,
    trieu_chung text,
    ngay_tao timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    ma_phong integer,
    ly_do_huy text,
    ten_nguoi_kham character varying(100),
    tuoi_nguoi_kham integer,
    danh_gia integer
);


ALTER TABLE public.lich_hen OWNER TO postgres;

--
-- TOC entry 313 (class 1259 OID 17577)
-- Name: lich_hen_ma_lich_hen_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lich_hen_ma_lich_hen_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lich_hen_ma_lich_hen_seq OWNER TO postgres;

--
-- TOC entry 3950 (class 0 OID 0)
-- Dependencies: 313
-- Name: lich_hen_ma_lich_hen_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lich_hen_ma_lich_hen_seq OWNED BY public.lich_hen.ma_lich_hen;


--
-- TOC entry 322 (class 1259 OID 18773)
-- Name: lich_truc; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lich_truc (
    ma_lich_truc integer NOT NULL,
    ma_bac_si integer NOT NULL,
    ngay_truc date NOT NULL,
    ca_truc character varying(20),
    gio_bat_dau time without time zone NOT NULL,
    gio_ket_thuc time without time zone NOT NULL,
    so_luong_toi_da integer DEFAULT 10,
    trang_thai boolean DEFAULT true,
    trang_thai_duyet text DEFAULT 'Đã duyệt'::text,
    ma_phong integer
);


ALTER TABLE public.lich_truc OWNER TO postgres;

--
-- TOC entry 3952 (class 0 OID 0)
-- Dependencies: 322
-- Name: TABLE lich_truc; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.lich_truc IS 'Bảng quản lý ca trực và thời gian rảnh của bác sĩ';


--
-- TOC entry 321 (class 1259 OID 18772)
-- Name: lich_truc_ma_lich_truc_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lich_truc_ma_lich_truc_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lich_truc_ma_lich_truc_seq OWNER TO postgres;

--
-- TOC entry 3954 (class 0 OID 0)
-- Dependencies: 321
-- Name: lich_truc_ma_lich_truc_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lich_truc_ma_lich_truc_seq OWNED BY public.lich_truc.ma_lich_truc;


--
-- TOC entry 308 (class 1259 OID 17545)
-- Name: nguoi_dung; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nguoi_dung (
    so_dien_thoai character varying(15) NOT NULL,
    ho_ten character varying(100) NOT NULL,
    ngay_sinh date,
    gioi_tinh character varying(10),
    dia_chi text,
    ma_dinh_danh character varying(128),
    ngay_dang_ky timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    vai_tro character varying(20) DEFAULT 'BenhNhan'::character varying,
    email text,
    anh_dai_dien_url text,
    nhom_mau character varying(10),
    chieu_cao character varying(10),
    can_nang character varying(10),
    an_thong_tin boolean DEFAULT false
);


ALTER TABLE public.nguoi_dung OWNER TO postgres;

--
-- TOC entry 318 (class 1259 OID 17614)
-- Name: nhac_thuoc; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nhac_thuoc (
    ma_nhac_thuoc integer NOT NULL,
    so_dien_thoai_bn character varying(15),
    ten_thuoc character varying(200) NOT NULL,
    lieu_luong character varying(100),
    gio_nhac time without time zone NOT NULL,
    ngay_bat_dau date,
    ngay_ket_thuc date,
    ghi_chu text,
    dang_hoat_dong boolean DEFAULT true
);


ALTER TABLE public.nhac_thuoc OWNER TO postgres;

--
-- TOC entry 317 (class 1259 OID 17613)
-- Name: nhac_thuoc_ma_nhac_thuoc_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.nhac_thuoc_ma_nhac_thuoc_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.nhac_thuoc_ma_nhac_thuoc_seq OWNER TO postgres;

--
-- TOC entry 3958 (class 0 OID 0)
-- Dependencies: 317
-- Name: nhac_thuoc_ma_nhac_thuoc_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.nhac_thuoc_ma_nhac_thuoc_seq OWNED BY public.nhac_thuoc.ma_nhac_thuoc;


--
-- TOC entry 324 (class 1259 OID 18790)
-- Name: phong; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.phong (
    ma_phong integer NOT NULL,
    ten_phong character varying(100) NOT NULL,
    vi_tri text,
    ma_khoa integer NOT NULL
);


ALTER TABLE public.phong OWNER TO postgres;

--
-- TOC entry 323 (class 1259 OID 18789)
-- Name: phong_ma_phong_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.phong_ma_phong_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.phong_ma_phong_seq OWNER TO postgres;

--
-- TOC entry 3961 (class 0 OID 0)
-- Dependencies: 323
-- Name: phong_ma_phong_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.phong_ma_phong_seq OWNED BY public.phong.ma_phong;


--
-- TOC entry 333 (class 1259 OID 25420)
-- Name: thong_bao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.thong_bao (
    id integer NOT NULL,
    nguoi_nhan_id text NOT NULL,
    vai_tro text NOT NULL,
    tieu_de text NOT NULL,
    noi_dung text NOT NULL,
    loai text DEFAULT 'GENERAL'::text,
    da_doc boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);


ALTER TABLE public.thong_bao OWNER TO postgres;

--
-- TOC entry 332 (class 1259 OID 25419)
-- Name: thong_bao_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.thong_bao_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.thong_bao_id_seq OWNER TO postgres;

--
-- TOC entry 3964 (class 0 OID 0)
-- Dependencies: 332
-- Name: thong_bao_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.thong_bao_id_seq OWNED BY public.thong_bao.id;


--
-- TOC entry 328 (class 1259 OID 18951)
-- Name: trieu_chung_pho_bien; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trieu_chung_pho_bien (
    ma_trieu_chung integer NOT NULL,
    ten_trieu_chung character varying,
    ma_khoa_lien_quan integer,
    tu_khoa text[]
);


ALTER TABLE public.trieu_chung_pho_bien OWNER TO postgres;

--
-- TOC entry 327 (class 1259 OID 18950)
-- Name: trieu_chung_pho_bien_ma_trieu_chung_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.trieu_chung_pho_bien_ma_trieu_chung_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.trieu_chung_pho_bien_ma_trieu_chung_seq OWNER TO postgres;

--
-- TOC entry 3967 (class 0 OID 0)
-- Dependencies: 327
-- Name: trieu_chung_pho_bien_ma_trieu_chung_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.trieu_chung_pho_bien_ma_trieu_chung_seq OWNED BY public.trieu_chung_pho_bien.ma_trieu_chung;


--
-- TOC entry 320 (class 1259 OID 17629)
-- Name: tu_van_ai; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tu_van_ai (
    ma_tu_van integer NOT NULL,
    so_dien_thoai_bn character varying(15),
    cau_hoi_nguoi_dung text,
    phan_hoi_ai text,
    ma_khoa_goi_y integer,
    do_tin_cay double precision,
    anh_phan_tich_url text,
    lich_su_hoi_thoai jsonb,
    ma_bac_si_goi_y integer[],
    trang_thai character varying DEFAULT 'dang_tu_van'::character varying,
    ngay_tao timestamp without time zone DEFAULT now()
);


ALTER TABLE public.tu_van_ai OWNER TO postgres;

--
-- TOC entry 319 (class 1259 OID 17628)
-- Name: tu_van_ai_ma_tu_van_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tu_van_ai_ma_tu_van_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tu_van_ai_ma_tu_van_seq OWNER TO postgres;

--
-- TOC entry 3970 (class 0 OID 0)
-- Dependencies: 319
-- Name: tu_van_ai_ma_tu_van_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tu_van_ai_ma_tu_van_seq OWNED BY public.tu_van_ai.ma_tu_van;


--
-- TOC entry 3654 (class 2604 OID 17566)
-- Name: bac_si ma_bac_si; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bac_si ALTER COLUMN ma_bac_si SET DEFAULT nextval('public.bac_si_ma_bac_si_seq'::regclass);


--
-- TOC entry 3673 (class 2604 OID 18851)
-- Name: chi_tiet_don_thuoc ma_chi_tiet; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chi_tiet_don_thuoc ALTER COLUMN ma_chi_tiet SET DEFAULT nextval('public.chi_tiet_don_thuoc_ma_chi_tiet_seq'::regclass);


--
-- TOC entry 3653 (class 2604 OID 17557)
-- Name: chuyen_khoa ma_khoa; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chuyen_khoa ALTER COLUMN ma_khoa SET DEFAULT nextval('public.chuyen_khoa_ma_khoa_seq'::regclass);


--
-- TOC entry 3682 (class 2604 OID 25475)
-- Name: danh_gia_bac_si id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.danh_gia_bac_si ALTER COLUMN id SET DEFAULT nextval('public.danh_gia_bac_si_id_seq'::regclass);


--
-- TOC entry 3661 (class 2604 OID 17602)
-- Name: don_thuoc ma_don_thuoc; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.don_thuoc ALTER COLUMN ma_don_thuoc SET DEFAULT nextval('public.don_thuoc_ma_don_thuoc_seq'::regclass);


--
-- TOC entry 3675 (class 2604 OID 25364)
-- Name: khoa_tu_khoa id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.khoa_tu_khoa ALTER COLUMN id SET DEFAULT nextval('public.khoa_tu_khoa_id_seq'::regclass);


--
-- TOC entry 3658 (class 2604 OID 17581)
-- Name: lich_hen ma_lich_hen; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lich_hen ALTER COLUMN ma_lich_hen SET DEFAULT nextval('public.lich_hen_ma_lich_hen_seq'::regclass);


--
-- TOC entry 3668 (class 2604 OID 18776)
-- Name: lich_truc ma_lich_truc; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lich_truc ALTER COLUMN ma_lich_truc SET DEFAULT nextval('public.lich_truc_ma_lich_truc_seq'::regclass);


--
-- TOC entry 3663 (class 2604 OID 17617)
-- Name: nhac_thuoc ma_nhac_thuoc; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nhac_thuoc ALTER COLUMN ma_nhac_thuoc SET DEFAULT nextval('public.nhac_thuoc_ma_nhac_thuoc_seq'::regclass);


--
-- TOC entry 3672 (class 2604 OID 18793)
-- Name: phong ma_phong; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.phong ALTER COLUMN ma_phong SET DEFAULT nextval('public.phong_ma_phong_seq'::regclass);


--
-- TOC entry 3678 (class 2604 OID 25423)
-- Name: thong_bao id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.thong_bao ALTER COLUMN id SET DEFAULT nextval('public.thong_bao_id_seq'::regclass);


--
-- TOC entry 3674 (class 2604 OID 18954)
-- Name: trieu_chung_pho_bien ma_trieu_chung; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trieu_chung_pho_bien ALTER COLUMN ma_trieu_chung SET DEFAULT nextval('public.trieu_chung_pho_bien_ma_trieu_chung_seq'::regclass);


--
-- TOC entry 3665 (class 2604 OID 17632)
-- Name: tu_van_ai ma_tu_van; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tu_van_ai ALTER COLUMN ma_tu_van SET DEFAULT nextval('public.tu_van_ai_ma_tu_van_seq'::regclass);


--
-- TOC entry 3917 (class 0 OID 25375)
-- Dependencies: 331
-- Data for Name: ai_training_rules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ai_training_rules (rule_id, rule_name, symptom_id, symptom_keywords, department_name, confidence, priority, advice) FROM stdin;
R_DB_001	Đau đầu dữ dội + cứng gáy + sốt cao → Thần kinh (Viêm màng đạo)	dau_dau_cung_gay	đau đầu dữ dội, cứng gáy, cổ cứng, sốt cao khó hạ, nhức đầu bưng bưng, sợ ánh sáng	Khoa Thần kinh	95	5	• ĐẾN BỆNH VIỆN CẤP CỨU NGAY LẬP TỨC\\n• Triệu chứng nghi ngờ viêm màng não cấp\\n• Nằm nghỉ ngơi tuyệt đối nơi thiếu ánh sáng\\n• Không tự ý dùng thuốc giảm đau liều cao tại nhà
R_DB_002	Tức ngực lan vai trái + vã mồ hôi lạnh → Tim mạch (Nhồi máu cơ tim)	tuc_nguc_vai_trai	đau thắt ngực, tức ngực lan vai trái, đau ép lồng ngực, vã mồ hôi lạnh, ngực như có đá đè, khó thở cấp tính	Khoa Tim mạch	98	5	• GỌI CẤP CỨU 115 NGAY LẬP TỨC\\n• Ngồi hoặc nằm nghỉ ngơi tuyệt đối, không di chuyển\\n• Nới lỏng quần áo\\n• Dùng thuốc giãn mạch dưới lưỡi nếu đã được bác sĩ kê đơn trước đó
R_DB_003	Sụt cân nhanh + khát nước + tiểu đêm → Nội tiết (Đái tháo đường)	sut_can_tieu_nhieu	sụt cân nhanh, sụt ký không rõ nguyên nhân, khát nước liên tục, khô miệng, đi tiểu ban đêm nhiều lần, kiến bâu nước tiểu	Khoa Nội tiết	90	4	• Thực hiện xét nghiệm đường huyết lúc đói và chỉ số HbA1c\\n• Hạn chế tối đa thực phẩm chứa đường và tinh bột hấp thu nhanh\\n• Tăng cường ăn rau xanh và kiểm soát lượng nước nạp vào cơ thể
R_DB_004	Ho đờm đặc xanh/vàng kéo dài + sốt về chiều → Hô hấp	ho_dom_sot_chieu	ho đờm xanh, ho đờm vàng, ho kéo dài trên 2 tuần, sốt nhẹ về chiều, tức ngực khi ho, người gầy sút, khạc đờm đặc	Khoa Hô hấp	88	3	• Cần chụp X-quang phổi và làm xét nghiệm vi sinh đờm\\n• Đeo khẩu trang thường xuyên để bảo vệ đường hô hấp\\n• Bổ sung nhiều nước ấm để làm loãng đờm
R_DB_005	Đau rát thượng vị + ợ chua tăng khi đói/sau ăn → Tiêu hóa	dau_thuong_vi_o_chua	đau rát thượng vị, cồn cào ruột gan, ợ hơi nhiều, ợ chua nóng rát cổ, trào ngược dịch vị, ăn đồ chua cay thấy đau	Khoa Tiêu hóa	88	3	• Đăng ký nội soi thực quản - dạ dày để kiểm tra vết loét hoặc trào ngược\\n• Ăn đúng giờ, nhai kỹ, chia nhỏ các bữa ăn\\n• Tuyệt đối không nằm ngay sau khi ăn trong vòng 2 tiếng\\n• Tránh xa các chất kích thích như rượu bia, cà phê, ớt cay
R_DB_006	Sưng đau các khớp ngón tay đối xứng buổi sáng → Cơ Xương Khớp	viem_khop_dang_thap	cứng khớp buổi sáng, sưng đau khớp ngón tay, đau cổ tay hai bên, bàn tay sưng vù khó nắm, đau nhức các khớp nhỏ	Khoa Cơ Xương Khớp	87	3	• Thăm khám chuyên khoa để làm các xét nghiệm đặc hiệu (RF, Anti-CCP)\\n• Chườm ấm các khớp vào buổi sáng để giảm cảm giác cứng khớp\\n• Tránh mang vác nặng hoặc dùng lực bàn tay quá mức
R_DB_007	Ban đỏ cánh bướm ở mặt + nhạy nắng + rụng tóc → Da liễu / Miễn dịch	ban_do_canh_buom	ban đỏ cánh bướm, ban đỏ hai bên má, rụng tóc từng mảng, nhạy nắng, ra nắng bị rát mặt, đau nhức mỏi cơ thể	Khoa Da liễu	86	3	• Thăm khám chuyên khoa Da liễu hoặc Miễn dịch lâm sàng (nghi ngờ Lupus ban đỏ)\\n• Bôi kem chống nắng phổ rộng SPF 50+ và che chắn kỹ khi đi ra ngoài\\n• Tránh làm việc quá sức hoặc thức khuya
R_DB_008	Tiểu buốt rắt + nước tiểu đục/máu + đau thắt lưng → Tiết niệu	tieu_buot_dau_than	tiểu buốt rát, tiểu lắt nhắt, nước tiểu đục ngầu, đái ra máu, đau quặn hông lưng, đau thắt lưng lan xuống bẹn	Khoa Tiết niệu	90	4	• Thực hiện siêu âm hệ tiết niệu và tổng phân tích nước tiểu\\n• Uống từ 2.5 đến 3 lít nước mỗi ngày để hỗ trợ bài tiết\\n• Tuyệt đối không nhịn tiểu\\n• Tránh các thực phẩm chứa nhiều oxalat (trà đặc, măng, cải bó xôi)
R_DB_009	Mắt mờ đột ngột + nhức hốc mắt dữ dội → Mắt (Glocom cấp)	mo_mat_dot_ngot_glocom	mờ mắt đột ngột, đau nhức hốc mắt dữ dội, nhức mắt lan lên đầu, nhìn đèn thấy quầng xanh đỏ, sờ mắt thấy cứng	Khoa Mắt	95	5	• ĐẾN CƠ SỞ NHÃN KHOA CẤP CỨU NGAY LẬP TỨC\\n• Triệu chứng điển hình của cơn Glocom cấp (thiên đầu thống)\\n• Cần can thiệp hạ nhãn áp khẩn cấp để tránh nguy cơ mù lòa vĩnh viễn
R_DB_010	Trẻ sốt cao liên tục + chấm xuất huyết dưới da → Nhi khoa	sot_xuat_huyet_nhi	trẻ sốt cao liên tục, chấm xuất huyết dưới da, chảy máu cam, chảy máu chân răng, li bì, nôn trớ nhiều, đau bụng vùng gan	Khoa Nhi	92	5	• ĐƯA TRẺ ĐẾN BỆNH VIỆN THĂM KHÁM NGAY\\n• Nghi ngờ Sốt xuất huyết Dengue có dấu hiệu cảnh báo\\n• Tích cực cho trẻ uống bù nước Oresol hoặc nước trái cây\\n• Tuyệt đối không cạo gió hay dùng thuốc hạ sốt Ibuprofen/Aspirin
R_DB_011	Đau quặn bụng dữ dội + bí trung đại tiện + chướng bụng → Ngoại khoa (Tắc ruột)	tac_ruot_ngoai_khoa	đau quặn bụng từng cơn dữ dội, không trung tiện được, không xì hơi được, nôn ra thức ăn cũ, bụng chướng to phình	Khoa Ngoại	95	5	• NHẬP VIỆN CẤP CỨU NGOẠI KHOA KHẨN CẤP\\n• Triệu chứng cảnh báo tắc ruột cơ học\\n• Nhịn ăn uống hoàn toàn\\n• Không tự ý dùng thuốc giảm đau hay thuốc nhuận tràng tại nhà
R_DB_012	Đau họng dữ dội một bên + khó há miệng → Tai Mũi Họng (Áp-xe)	apxe_quanh_amidan	đau họng một bên dữ dội, nuốt nước bọt cực đau, há miệng khít, mủ họng, sốt cao rét run, giọng nói ngậm thị	Khoa Tai Mũi Họng	90	4	• Thăm khám Tai Mũi Họng khẩn cấp để trích rạch dẫn lưu mủ (nghi áp-xe quanh amidan)\\n• Súc họng thường xuyên bằng nước muối sinh lý ấm\\n• Cần tuân thủ liệu trình kháng sinh của bác sĩ
R_DB_013	Kinh thưa + rậm lông + mụn quai hàm + béo bụng → Sản Phụ khoa (PCOS)	buong_trung_da_nang	kinh nguyệt thưa, vài tháng mới có kinh, rậm lông tay chân, mụn nội tiết quai hàm, béo bụng khó giảm, hiếm muộn	Khoa Sản Phụ khoa	88	3	• Siêu âm phụ khoa và kiểm tra các định lượng hormone nội tiết tố\\n• Thực hiện chế độ ăn low-carb để cải thiện độ nhạy insulin\\n• Tăng cường vận động thể chất hàng ngày
R_DB_014	Đau vai gáy lan xuống cánh tay + tê các ngón tay → Cơ Xương Khớp	thoai_hoa_cotsong_co	đau mỏi cổ vai gáy, mỏi vai gáy lan xuống tay, tê rần ngón tay, quay cổ thấy lạo xạo, nhức mỏi bả vai	Khoa Cơ Xương Khớp	85	3	• Chụp X-quang hoặc cộng hưởng từ (MRI) cột sống cổ\\n• Không bẻ vặn cổ đột ngột\\n• Sử dụng gối ngủ thấp, hỗ trợ đường cong sinh lý\\n• Tập các bài tập kéo giãn cơ gáy chuyên dụng
R_DB_015	Da xanh xao + hay hoa mắt chóng mặt khi đứng lên → Nội tổng quát (Thiếu máu)	thieu_mau_noi_khoa	da xanh xao, nhợt nhạt, lòng bàn tay trắng bệch, hay hoa mắt khi đứng lên, tim đập nhanh khi làm việc nhẹ, rụng tóc móng giòn	Khoa Nội tổng quát	85	2	• Làm xét nghiệm công thức máu và kiểm tra lượng Sắt huyết thanh, Ferritin\\n• Tăng cường các thực phẩm giàu sắt (thịt bò đỏ, gan súc vật, rau ngót)\\n• Dùng thực phẩm giàu Vitamin C để tăng cường hấp thu sắt
R_DB_016	Tâm trạng u uất kéo dài + chán nản + mất động lực → Tâm thần (Trầm cảm)	tram_cam_nang	tâm trạng u uất, khóc một mình, muốn buông xuôi, không muốn tiếp xúc ai, chán ghét bản thân, kiệt quệ tinh thần	Khoa Tâm thần	90	4	• Hãy chia sẻ ngay cảm xúc với chuyên gia tâm lý hoặc người thân gần gũi\\n• Dành thời gian hoạt động ngoài trời vào buổi sáng\\n• Tuân thủ chặt chẽ liệu pháp tư vấn và điều trị thuốc của bác sĩ chuyên khoa
R_DB_017	Sờ thấy khối u cứng ở vú + tụt núm vú/chảy dịch → Ung bướu	u_vu_ung_buou	sờ thấy cục ở vú, u vú, sờ thấy khối cứng ở ngực, núm vú tụt vào trong, chảy dịch máu núm vú, da ngực sần cam	Khoa Ung bướu	95	5	• ĐẾN NGAY CƠ SỞ CHUYÊN KHOA UNG BƯỚU ĐỂ KIỂM TRA\\n• Thực hiện siêu âm tuyến vú kết hợp chụp nhũ ảnh (Mammography)\\n• Không xoa bóp hoặc đắp lá vào vùng có khối u
R_DB_018	Đau hố chậu phải + sốt nhẹ + buồn nôn → Ngoại khoa (Viêm ruột thừa)	viem_ruot_thua_cap	đau hố chậu phải, đau ruột thừa, đau chuyển từ rốn xuống góc dưới bên phải bụng, sốt nhẹ kèm nôn, đi lại gập người mới đỡ	Khoa Ngoại	94	5	• ĐẾN BỆNH VIỆN KHÁM CẤP CỨU NGAY\\n• Dấu hiệu cảnh báo viêm ruột thừa cấp tính\\n• Tuyệt đối không tự ý uống thuốc giảm đau làm lu mờ triệu chứng trước khi khám
R_DB_019	Ho khan dai dẳng + khàn tiếng kéo dài ở người hút thuốc → Ung bướu / Tai Mũi Họng	ho_khan_khan_tieng_k_thanh_quan	ho khan dai dẳng, khàn tiếng kéo dài, mất giọng, vướng cổ họng nhiều tháng, nuốt nghẹn, hút thuốc lá nhiều	Khoa Ung bướu	88	4	• Thực hiện nội soi tai mũi họng thanh quản và chụp CT lồng ngực\\n• Tầm soát chuyên sâu các khối u vùng đầu cổ và đường hô hấp\\n• Cai hút thuốc lá ngay lập tức
R_DB_020	Trẻ tiêu chảy ồ ạt + nôn nhiều + khát nước vật vã → Nhi khoa (Mất nước)	tieu_chay_cap_mat_nuoc_nhi	trẻ đi ngoài phân lỏng như nước, tiêu chảy ồ ạt, nôn trớ liên tục, mắt trũng sâu, khóc không có nước mắt, đòi uống nước	Khoa Nhi	95	5	• ĐƯA BÉ ĐẾN CƠ SỞ Y TẾ GẦN NHẤT ĐỂ KỊP THỜI TRUYỀN DỊCH\\n• Trẻ có biểu hiện mất nước cấp tính rất nguy hiểm\\n• Cho uống liên tục dung dịch Oresol từng thìa nhỏ trên đường đi
280718b8-e90c-4c9b-a789-2dde013425cc	Rule cho Nội khoa	SYM_27	đau đầu, chóng mặt, mệt mỏi, sốt, đau nhức cơ thể	Nội khoa	85	1	Với các triệu chứng đau đầu, chóng mặt..., bạn nên thăm khám tại khoa Nội khoa để được bác sĩ tư vấn và điều trị kịp thời.
4df86117-3c12-4323-9a16-05b94e53ae85	Rule cho Nha khoa	SYM_28	đau răng, chảy máu chân răng, nhức răng, sâu răng, hôi miệng	Nha khoa	85	1	Với các triệu chứng đau răng, chảy máu chân răng..., bạn nên thăm khám tại khoa Nha khoa để được bác sĩ tư vấn và điều trị kịp thời.
bc9ad9ee-a0c6-490f-a781-50105cc11b9c	Rule cho Tiểu đường - Nội tiết	SYM_29	tiểu nhiều, khát nước, sụt cân, tuyến giáp, đường huyết cao	Tiểu đường - Nội tiết	85	1	Với các triệu chứng tiểu nhiều, khát nước..., bạn nên thăm khám tại khoa Tiểu đường - Nội tiết để được bác sĩ tư vấn và điều trị kịp thời.
f3e65dcf-5450-4149-b725-6c44880c76bf	Rule cho Phục hồi chức năng 	SYM_30	khám bệnh, tư vấn, sức khỏe	Phục hồi chức năng 	85	1	Với các triệu chứng khám bệnh, tư vấn..., bạn nên thăm khám tại khoa Phục hồi chức năng  để được bác sĩ tư vấn và điều trị kịp thời.
25063558-c175-4196-8b2d-e41f23550df4	Rule cho Tiêu hoá	SYM_31	đau bụng, tiêu chảy, táo bón, buồn nôn, ợ chua, đầy hơi, trào ngược	Tiêu hoá	85	1	Với các triệu chứng đau bụng, tiêu chảy..., bạn nên thăm khám tại khoa Tiêu hoá để được bác sĩ tư vấn và điều trị kịp thời.
0b7d2150-5a65-41c8-af29-3845d90e8b54	Rule cho Ung bướu 	SYM_32	khám bệnh, tư vấn, sức khỏe	Ung bướu 	85	1	Với các triệu chứng khám bệnh, tư vấn..., bạn nên thăm khám tại khoa Ung bướu  để được bác sĩ tư vấn và điều trị kịp thời.
9cd49431-789b-474c-9519-cdf4aff5b3a4	Rule cho Tâm lý	SYM_33	trầm cảm, lo âu, mất ngủ, căng thẳng, rối loạn cảm xúc	Tâm lý	85	1	Với các triệu chứng trầm cảm, lo âu..., bạn nên thăm khám tại khoa Tâm lý để được bác sĩ tư vấn và điều trị kịp thời.
2e2d740f-6bfa-4609-90e6-48e89d7f7bdf	Rule cho Vô sinh - Hiếm muộn	SYM_34	vô sinh, hiếm muộn, thụ tinh nhân tạo, khó có con	Vô sinh - Hiếm muộn	85	1	Với các triệu chứng vô sinh, hiếm muộn..., bạn nên thăm khám tại khoa Vô sinh - Hiếm muộn để được bác sĩ tư vấn và điều trị kịp thời.
029607bb-b6ea-48d3-8deb-6a1cb34e9d98	Rule cho Chấn thương chỉnh hình 	SYM_35	khám bệnh, tư vấn, sức khỏe	Chấn thương chỉnh hình 	85	1	Với các triệu chứng khám bệnh, tư vấn..., bạn nên thăm khám tại khoa Chấn thương chỉnh hình  để được bác sĩ tư vấn và điều trị kịp thời.
c1f122ac-6b72-4e7a-a33f-bc5d5bd1f23e	Rule cho Cơ Xương Khớp	SYM_10	đau nhức xương, sưng khớp, thoái hóa khớp, đau mỏi vai gáy	Cơ Xương Khớp	85	1	Với các triệu chứng đau nhức xương, sưng khớp..., bạn nên thăm khám tại khoa Cơ Xương Khớp để được bác sĩ tư vấn và điều trị kịp thời.
4c67aa55-1b3f-4857-98fd-6698f14d5a8f	Rule cho Thần kinh	SYM_11	co giật, động kinh, đau nửa đầu, mất trí nhớ, tê bì chân tay	Thần kinh	85	1	Với các triệu chứng co giật, động kinh..., bạn nên thăm khám tại khoa Thần kinh để được bác sĩ tư vấn và điều trị kịp thời.
0c4d36c1-f8f2-465b-896a-11fc7bd22bb6	Rule cho Tiêu hoá	SYM_12	đau bụng, tiêu chảy, táo bón, buồn nôn, ợ chua, đầy hơi, trào ngược	Tiêu hoá	85	1	Với các triệu chứng đau bụng, tiêu chảy..., bạn nên thăm khám tại khoa Tiêu hoá để được bác sĩ tư vấn và điều trị kịp thời.
b494bc8c-69bf-4f9c-a4aa-4db4be6b11f0	Rule cho Tim mạch 	SYM_13	khám bệnh, tư vấn, sức khỏe	Tim mạch 	85	1	Với các triệu chứng khám bệnh, tư vấn..., bạn nên thăm khám tại khoa Tim mạch  để được bác sĩ tư vấn và điều trị kịp thời.
3a16c578-ebff-4e90-8b78-3d1a293855b5	Rule cho Tai Mũi Họng	SYM_14	đau họng, sổ mũi, ù tai, viêm xoang, chảy máu cam, ho có đờm	Tai Mũi Họng	85	1	Với các triệu chứng đau họng, sổ mũi..., bạn nên thăm khám tại khoa Tai Mũi Họng để được bác sĩ tư vấn và điều trị kịp thời.
fc6ca313-d0a8-4b45-9bb2-67610436bb37	Rule cho Cột sống	SYM_15	đau lưng, thoát vị đĩa đệm, cong vẹo cột sống, đau thần kinh tọa	Cột sống	85	1	Với các triệu chứng đau lưng, thoát vị đĩa đệm..., bạn nên thăm khám tại khoa Cột sống để được bác sĩ tư vấn và điều trị kịp thời.
7917324a-57a9-4e7b-aa87-984a9e9cfa43	Rule cho Y học Cổ truyền	SYM_16	châm cứu, bấm huyệt, thuốc nam, đau mỏi, suy nhược	Y học Cổ truyền	85	1	Với các triệu chứng châm cứu, bấm huyệt..., bạn nên thăm khám tại khoa Y học Cổ truyền để được bác sĩ tư vấn và điều trị kịp thời.
e727724f-7202-48ea-9afe-b4a286b277b5	Rule cho Châm cứu	SYM_17	châm cứu, đau nhức, liệt dây thần kinh	Châm cứu	85	1	Với các triệu chứng châm cứu, đau nhức..., bạn nên thăm khám tại khoa Châm cứu để được bác sĩ tư vấn và điều trị kịp thời.
865c54df-bb47-4575-9edd-db44047f8161	Rule cho Sản Phụ 	SYM_18	khám bệnh, tư vấn, sức khỏe	Sản Phụ 	85	1	Với các triệu chứng khám bệnh, tư vấn..., bạn nên thăm khám tại khoa Sản Phụ  để được bác sĩ tư vấn và điều trị kịp thời.
b87e864c-3b34-4e8e-9686-45d3ab349dd2	Rule cho Siêu âm thai	SYM_19	siêu âm thai, khám thai định kỳ, thai nhi	Siêu âm thai	85	1	Với các triệu chứng siêu âm thai, khám thai định kỳ..., bạn nên thăm khám tại khoa Siêu âm thai để được bác sĩ tư vấn và điều trị kịp thời.
5b71cdb3-133f-47e6-84eb-4d9634bf1879	Rule cho Nhi	SYM_20	trẻ em, sốt ở trẻ, biếng ăn, trẻ ho, tiêu chảy ở trẻ	Nhi	85	1	Với các triệu chứng trẻ em, sốt ở trẻ..., bạn nên thăm khám tại khoa Nhi để được bác sĩ tư vấn và điều trị kịp thời.
80de522b-616d-40bd-8d5c-022596abd0ff	Rule cho Da liễu 	SYM_21	khám bệnh, tư vấn, sức khỏe	Da liễu 	85	1	Với các triệu chứng khám bệnh, tư vấn..., bạn nên thăm khám tại khoa Da liễu  để được bác sĩ tư vấn và điều trị kịp thời.
a01fa503-8a42-4571-ba6d-bfeb78b4270a	Rule cho Di ứng	SYM_22	khám bệnh, tư vấn, sức khỏe	Di ứng	85	1	Với các triệu chứng khám bệnh, tư vấn..., bạn nên thăm khám tại khoa Di ứng để được bác sĩ tư vấn và điều trị kịp thời.
e2219557-9d3c-478b-89fe-d593913c4029	Rule cho Mắt 	SYM_23	khám bệnh, tư vấn, sức khỏe	Mắt 	85	1	Với các triệu chứng khám bệnh, tư vấn..., bạn nên thăm khám tại khoa Mắt  để được bác sĩ tư vấn và điều trị kịp thời.
d1a0525c-a51c-4aaa-9250-9deabc747e73	Rule cho Hô hấp	SYM_24	khó thở, ho kéo dài, hen suyễn, viêm phổi, đau tức ngực khi thở	Hô hấp	85	1	Với các triệu chứng khó thở, ho kéo dài..., bạn nên thăm khám tại khoa Hô hấp để được bác sĩ tư vấn và điều trị kịp thời.
313c9b36-eebf-4c46-8997-e07c241f6afa	Rule cho Ngoại thần kinh	SYM_25	chấn thương sọ não, u não, mổ cột sống	Ngoại thần kinh	85	1	Với các triệu chứng chấn thương sọ não, u não..., bạn nên thăm khám tại khoa Ngoại thần kinh để được bác sĩ tư vấn và điều trị kịp thời.
3ad88e26-1618-452d-9ebc-5a8adc136b9e	Rule cho Thận - Tiết niệu	SYM_26	tiểu buốt, tiểu ra máu, đau sỏi thận, suy thận	Thận - Tiết niệu	85	1	Với các triệu chứng tiểu buốt, tiểu ra máu..., bạn nên thăm khám tại khoa Thận - Tiết niệu để được bác sĩ tư vấn và điều trị kịp thời.
6670a28d-93ad-4ec7-83ef-0b9c7d1f5b81	Rule cho Ngoại khoa 	SYM_36	khám bệnh, tư vấn, sức khỏe	Ngoại khoa 	85	1	Với các triệu chứng khám bệnh, tư vấn..., bạn nên thăm khám tại khoa Ngoại khoa  để được bác sĩ tư vấn và điều trị kịp thời.
ee06ed7d-9c36-4d72-9893-2e061f1f6149	Tai mũi họng cơ bản	7e77cfee-acec-48d3-952f-1b36c5f8af4f	tai, ù tai, đau tai, ngứa tai, chảy mủ tai, mũi, nghẹt mũi, sổ mũi, họng, ho, đau họng, rát họng, amydan	Tai mũi họng	1	1	Bạn có triệu chứng liên quan đến Tai mũi họng. • Nên đi khám để kiểm tra kỹ niêm mạc. • Uống nhiều nước ấm và giữ ấm vùng cổ.
469d1655-7479-4251-ad25-4a6525183040	Hô hấp	475ccb75-a965-481d-9ce8-e322af56a0dd	khó thở, tức ngực, thở khò khè, ho có đờm, viêm phế quản, hen suyễn	Hô hấp	1	1	Các triệu chứng liên quan đến đường hô hấp. • Hạn chế tiếp xúc khói bụi. • Đeo khẩu trang khi ra ngoài. • Khám sớm nếu khó thở tăng.
cae401b1-8eff-4135-ad1a-d84669903c72	Nội khoa chung	7f91534b-14ea-43f4-a31d-0c3a0fa2ab48	sốt, mệt mỏi, chóng mặt, sụt cân, đau lưng, suy nhược	Nội khoa	1	2	Triệu chứng chung cần bác sĩ Nội khoa kiểm tra tổng quát. • Nghỉ ngơi đầy đủ. • Bổ sung dinh dưỡng. • Đi khám để xét nghiệm máu nếu cần.
068d5bc0-cef9-4db8-9e1a-b6287208cbed	Thần kinh	5e6e954f-4026-4d4f-b923-6e3c66c6102c	đau đầu, chóng mặt, mất ngủ, tê bì chân tay, co giật, run	Thần kinh	1	1	Dấu hiệu liên quan đến hệ thần kinh. • Nghỉ ngơi, giảm căng thẳng. • Không tự ý dùng thuốc an thần. • Khám chuyên khoa thần kinh để được tư vấn.
5cf53a1a-7719-4bb8-aed0-1c02ef02385c	Răng hàm mặt	2f56d02f-69f3-4db9-8275-89fc37838542	đau răng, sâu răng, nhức răng, sưng lợi, chảy máu chân răng, niềng răng	Răng hàm mặt	1	1	Triệu chứng rõ ràng của bệnh lý Răng hàm mặt. • Vệ sinh răng miệng sạch sẽ sau bữa ăn. • Đến nha khoa để kiểm tra và xử lý.
375fd535-a5c3-4307-8d25-b1d0e5ff8f04	Mắt	6c13b5b6-efd8-4242-be30-0eb3c8182c0e	mờ mắt, mỏi mắt, đau mắt đỏ, chảy nước mắt, ngứa mắt, cộm mắt	Mắt	1	1	Triệu chứng liên quan đến Mắt. • Không dùng tay dụi mắt. • Nhỏ nước muối sinh lý. • Đi khám chuyên khoa Mắt sớm.
7e1263ea-4434-4262-aa03-1efcac1b08d6	Da liễu	f558eafa-1a87-44dc-a7f6-1e62f71e231f	ngứa, nổi mẩn đỏ, dị ứng, mụn, nấm da, viêm da, lang ben	Da liễu	1	1	Dấu hiệu về Da liễu. • Không chà xát mạnh vùng da tổn thương. • Mặc đồ thoáng mát. • Đi khám da liễu để được kê đơn thuốc bôi.
f75ef8b3-18dd-4d02-9398-c8fe360bef13	Tiêu hóa	b3f8fe4e-d561-4f37-8bef-5a3cad4e4a75	đau bụng, ợ chua, buồn nôn, tiêu chảy, táo bón, đầy hơi, khó tiêu	Tiêu hóa	1	1	Biểu hiện của hệ Tiêu hóa. • Ăn chín uống sôi. • Hạn chế đồ ăn cay nóng. • Khám chuyên khoa tiêu hóa để siêu âm, nội soi.
62ea5db5-8c7f-4849-9576-b958448d0a7f	Xương khớp	a17234d0-d070-4c5e-938e-eb46a86a256a	đau nhức xương, mỏi khớp, sưng khớp, thoái hóa, đau cột sống, trật khớp	Xương khớp	1	1	Dấu hiệu bệnh lý Xương khớp. • Tránh mang vác nặng. • Tập thể dục nhẹ nhàng. • Đi khám Xương khớp để chụp X-quang.
186591fa-8ffd-4c81-8203-9183c7558190	Sản phụ khoa	f909755a-8e0a-41d8-b31c-5112422cf710	khám thai, kinh nguyệt không đều, rong kinh, đau bụng dưới, siêu âm thai	Sản phụ khoa	1	1	Vấn đề liên quan đến Sản phụ khoa. • Vệ sinh sạch sẽ. • Khám định kỳ theo chỉ định. • Đi khám ngay nếu có dấu hiệu bất thường.
R_AI_101	Tim mạch - Đau ngực khẩn cấp	tim_mach_dau_nguc	đau ngực, nặng ngực, nhói tim, đánh trống ngực, hồi hộp, bóp nghẹt tim, khó thở về đêm	Tim mạch	90	5	Các triệu chứng như đau ngực, đánh trống ngực có thể là dấu hiệu bệnh lý tim mạch nguy hiểm. Vui lòng đến bệnh viện kiểm tra ngay lập tức, đặc biệt nếu đau lan ra tay trái hoặc hàm.
R_AI_102	Tiêu hoá - Đau dạ dày	tieu_hoa_da_day	đau bụng, ợ chua, ợ hơi, buồn nôn, trào ngược, đau dạ dày, đi ngoài phân đen, chướng bụng, đầy hơi	Tiêu hoá	85	3	Triệu chứng của bạn liên quan đến đường tiêu hóa. Bạn nên ăn uống đúng giờ, tránh đồ cay nóng và đăng ký khám chuyên khoa Tiêu hóa để nội soi nếu cần thiết.
R_AI_103	Cơ Xương Khớp - Đau nhức xương	co_xuong_khop_dau	đau lưng, nhức mỏi, mỏi vai gáy, cứng khớp, sưng khớp, thoái hóa, đau gối, tê mỏi chân tay, tê nhức	Cơ Xương Khớp	88	3	Tình trạng đau nhức xương khớp kéo dài cần được thăm khám chuyên khoa Cơ Xương Khớp. Hạn chế mang vác nặng và sai tư thế trong thời gian này.
R_AI_104	Tai Mũi Họng - Viêm họng	tmh_viem	đau họng, nghẹt mũi, sổ mũi, khan tiếng, chảy mủ tai, ù tai, mất giọng, ho có đờm, viêm họng, viêm xoang	Tai Mũi Họng	92	2	Các triệu chứng hô hấp trên cho thấy bạn có thể bị viêm đường tai mũi họng. Hãy giữ ấm cổ, súc miệng nước muối và đi khám chuyên khoa Tai Mũi Họng.
R_AI_105	Thần kinh - Đau đầu chóng mặt	than_kinh_dau_dau	đau đầu, chóng mặt, hoa mắt, nửa đầu, mất ngủ kéo dài, co giật, run tay chân, tê bì nửa người, choáng váng	Thần kinh	85	4	Triệu chứng về thần kinh cần được theo dõi kỹ. Nếu chóng mặt đau đầu đi kèm nôn mửa hoặc yếu liệt, cần đi cấp cứu ngay. Khám Khoa Thần kinh để tìm nguyên nhân.
R_AI_106	Tiểu đường - Nội tiết	noi_tiet_tieu_duong	khát nước nhiều, tiểu nhiều, sụt cân nhanh, thèm ngọt, bướu cổ, mắt lồi, nhịp tim nhanh đổ mồ hôi, đái tháo đường	Tiểu đường - Nội tiết	88	3	Sụt cân, khát nước nhiều là dấu hiệu cảnh báo bệnh lý nội tiết (đặc biệt là đái tháo đường). Hãy làm xét nghiệm đường huyết và khám chuyên khoa Nội tiết.
R_AI_107	Da liễu - Dị ứng da	da_lieu_di_ung	mẩn đỏ, ngứa, nổi mụn, bong tróc, nấm da, rụng tóc, viêm da, nổi mề đay, mụn nhọt, lang ben, hắc lào	Da liễu	95	2	Tình trạng mẩn ngứa trên da cần khám chuyên khoa Da liễu. Không tự ý bôi các loại thuốc không rõ nguồn gốc để tránh tổn thương da nặng hơn.
R_AI_108	Mắt - Giảm thị lực	mat_giam_thi_luc	mờ mắt, đau mắt đỏ, khô mắt, cộm mắt, chảy nước mắt, nhìn đôi, ruồi bay trước mắt, lác, sụp mí, nhức mắt	Mắt	90	3	Bất kỳ bất thường nào về thị lực cũng cần được bác sĩ Nhãn khoa kiểm tra sớm để bảo vệ cửa sổ tâm hồn của bạn. Hạn chế sử dụng điện thoại/máy tính.
R_AI_109	Hô hấp - Viêm phổi / Hen	ho_hap_ho	ho dai dẳng, ho ra máu, tức ngực khi thở, khó thở, thở khò khè, viêm phổi, hen suyễn, lao phổi, thở dốc	Hô hấp	89	4	Ho dai dẳng và khó thở là dấu hiệu bệnh lý Hô hấp. Đặc biệt nếu có ho ra máu hoặc tức ngực nặng, cần đi khám ngay lập tức để chụp X-Quang.
R_AI_110	Thận Tiết niệu - Viêm tiểu	than_tiet_nieu	tiểu buốt, tiểu rắt, tiểu máu, đau thắt lưng, đau mạn sườn, tiểu đêm, phù mặt, phù chân, sỏi thận	Thận - Tiết niệu	92	3	Các rối loạn tiểu tiện (buốt, rắt, ra máu) là dấu hiệu rõ ràng của viêm đường tiết niệu hoặc sỏi thận. Uống nhiều nước và đi khám sớm.
R_AI_111	Nhi khoa	nhi_khoa_chung	trẻ sơ sinh, trẻ nhỏ, bé khóc đêm, trẻ biếng ăn, trẻ sốt cao, trẻ nôn trớ, hăm tã, tay chân miệng, ho gà, sởi ở trẻ	Nhi	95	4	Bệnh lý ở trẻ em diễn biến rất nhanh. Nếu bé có dấu hiệu sốt cao không hạ, nôn mửa hoặc lừ đừ, phụ huynh cần đưa bé đến khoa Nhi cấp cứu ngay.
R_AI_112	Sản Phụ khoa	san_phu_khi_hu	trễ kinh, đau bụng kinh, rong kinh, khí hư, huyết trắng, có thai, nghén, đau bụng dưới, siêu âm thai, ngứa vùng kín, viêm nhiễm phụ khoa	Sản Phụ	90	3	Các dấu hiệu bất thường về chu kỳ kinh nguyệt hoặc viêm nhiễm cần được bác sĩ Sản Phụ khoa thăm khám, vệ sinh vùng kín sạch sẽ hàng ngày.
R_AI_113	Tâm lý	tam_ly_tram_cam	lo âu, trầm cảm, căng thẳng, stress, rối loạn cảm xúc, muốn tự tử, sợ hãi vô cớ, khóc nhiều, mất ngủ do suy nghĩ, buồn chán	Tâm lý	85	4	Sức khỏe tinh thần vô cùng quan trọng. Đừng ngần ngại chia sẻ với bác sĩ Tâm lý để được hỗ trợ vượt qua giai đoạn căng thẳng, rối loạn này.
R_AI_114	Dị ứng - Sốc phản vệ	di_ung_soc	dị ứng hải sản, sưng môi, phù mí mắt, dị ứng thuốc, khó thở do dị ứng, sốc phản vệ, ngứa toàn thân sau ăn	Dị ứng	95	5	CẢNH BÁO: Phù nề mí mắt, sưng môi hoặc khó thở sau khi ăn/dùng thuốc là dấu hiệu sốc phản vệ. CẦN ĐẾN CẤP CỨU NGAY LẬP TỨC.
R_AI_115	Nha khoa	nha_khoa_dau_rang	đau răng, nhức răng, chảy máu chân răng, sưng lợi, sâu răng, ê buốt răng, viêm nướu, hôi miệng, mọc răng khôn	Nha khoa	95	2	Khám Nha khoa sớm sẽ giúp bạn bảo tồn răng thật và giảm thiểu đau đớn. Nên duy trì vệ sinh răng miệng bằng chỉ nha khoa và nước súc miệng.
R_AI_116	Tiêu hoá - Tiêu chảy cấp	tieu_hoa_tieu_chay	tiêu chảy, đi ngoài liên tục, nôn mửa nhiều, mất nước, kiết lỵ, phân lỏng, đau quặn ruột	Tiêu hoá	88	4	Tiêu chảy cấp có nguy cơ gây mất nước nghiêm trọng. Bạn cần bổ sung oresol và đến chuyên khoa Tiêu hóa kiểm tra, không tự ý dùng thuốc cầm tiêu chảy.
R_AI_117	Thần kinh - Thần kinh tọa	than_kinh_toa	đau dọc mặt sau đùi, lan xuống chân, buốt từ lưng xuống gót chân, đi lại khó khăn do đau lưng	Thần kinh	87	3	Các triệu chứng đau lan từ thắt lưng xuống chân thường gặp trong đau thần kinh tọa hoặc thoát vị đĩa đệm. Bạn nên đi khám Thần kinh / Cột sống.
R_AI_118	Nội khoa	noi_khoa_sot_virus	sốt nhẹ, mệt mỏi toàn thân, uể oải, chán ăn, sụt cân nhẹ, người lờ đờ, nhức mỏi cơ, ớn lạnh, cảm cúm	Nội khoa	75	1	Các triệu chứng toàn thân chưa rõ ràng thường cần khám tổng quát tại Nội khoa để làm xét nghiệm máu sơ bộ, từ đó chẩn đoán chính xác.
R_AI_119	Chấn thương chỉnh hình	chan_thuong_xuong	gãy xương, bong gân, trật khớp, sưng to sau tai nạn, bầm tím diện rộng, đứt dây chằng, chấn thương thể thao	Chấn thương chỉnh hình	96	5	Tổn thương xương khớp sau tai nạn cần cố định vùng bị thương và đưa ngay đến viện khoa Chấn thương chỉnh hình để chụp X-Quang và bó bột/phẫu thuật kịp thời.
R_AI_120	Thận Tiết niệu - Nam khoa	nam_khoa_yeu_sinh_ly	yếu sinh lý, xuất tinh sớm, rối loạn cương dương, đau tinh hoàn, viêm niệu đạo nam, chảy mủ niệu đạo	Thận - Tiết niệu	88	2	Các bệnh lý thầm kín của nam giới nên được thăm khám tế nhị tại chuyên khoa Thận - Tiết niệu (hoặc Nam khoa). Đừng e ngại, điều trị sớm sẽ mang lại hiệu quả cao.
\.


--
-- TOC entry 3898 (class 0 OID 17563)
-- Dependencies: 312
-- Data for Name: bac_si; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bac_si (ma_bac_si, ho_ten, ma_khoa, ten_benh_vien, chi_tiet_chuyen_mon, anh_chan_dung_url, danh_gia, hoc_vi, kinh_nghiem, ma_phong_chinh, trang_thai_hoat_dong, gia_kham) FROM stdin;
8	Vũ Văn Hoè	10	\N	Nhận khám từ 7 tuổi trở lên	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_8_93f2757a-e3ba-4fe0-bd12-e3d9abd66ba1.jpg	0.0	PGS.TS	35 năm kinh nghiệm về vực Cột sống, thần kinh, cơ xương khớp.\nPhó chủ tịch hội Phẫu thuật cột sống Việt Nam	\N	t	150000
9	Nguyễn Trần Trung	10	\N	Bác sĩ nhận khám từ 15 tuổi trở lên	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779732292633.jpg	0.0	Thạc sĩ	Nhiều kinh nghiệm trong khám và điều trị Cơ Xương khớp	\N	t	150000
10	Trần Trọng Thắng	10	\N	Nhận tất cả các độ tuổi\n	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779732645337.jpg	0.0	CKII	30 năm kinh nghiệm	\N	t	150000
11	Dương Minh Trí	10	\N	Nhận khám từ 16 tuổi trở lên	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779732786333.jpg	0.0	CKII	25 năm kinh nghiệm	\N	t	150000
12	Nguyễn Văn Doanh	11	\N	Điều trị hiệu quả các bệnh lý thần kinh	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779783400685.jpg	0.0	Tiến sĩ	40 năm	\N	t	150000
13	Nguyễn Ảnh Đạt	11	\N	Nhận khám mọi độ tuổi	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779784180033.jpg	0.0		30 năm	\N	t	150000
14	Nguyễn Việt Đức	11	\N	Nhận khám từ 6 tuổi trở lên	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779784498767.jpg	0.0	Thạc sĩ	Nhiều năm	\N	t	150000
15	Hà Văn Quyết	31	\N	Chuyên điều trị các bệnh lý mãn tính như viêm đại tràng, hội chứng ruột kích thích,...	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779784750782.jpg	0.0	GS.TS	40 năm	\N	t	150000
16	Thẩm Hoàng Hải	31	\N	Nội soi tiêu hoá 	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779785699783.jpg	0.0	Bác sĩ	>5 năm	\N	t	150000
18	Nguyễn Thị Minh Thảo	13	\N	trưởng khoa Tim mạch bệnh viện Tâm Trí Sài Gòn	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779785882101.jpg	0.0		25 năm	\N	t	150000
17	Nguyễn Văn Quýnh	13	\N	Chuyên gia hàng đầu về tim mạch	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779785800874.jpg	0.0		40 năm 	\N	t	150000
19	Nguyễn Thị Hoài An	14	\N	Trưởng khoa Tai Mũi Họng trẻ em bệnh viện Tai Mũi Họng trung ương	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779790335920.jpg	0.0	PGS.TS	40 năm	\N	t	150000
20	Nguyễn Thành Tuấn	14	\N	Từng học tập và tu nghiệp tại Hoa Kì	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779790417008.jpg	0.0	Tiến sĩ	14 năm	\N	t	150000
21	Võ Thị Trúc Phương	16	\N	Trưởng khoa Y học cổ truyền Bệnh viện Hồng Đức III	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779790510282.jpg	0.0	Thạc sĩ	10 năm	\N	t	150000
22	Trần Thái Hà	16	\N	Thầy thuốc ưu tú do Chủ tịch nước phong tặng	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779790684652.jpg	0.0	PGS.TS	10 năm	\N	t	150000
23	Võ Quang Trinh	27	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Nội khoa.	\N	3.6	CKI	1 năm kinh nghiệm	\N	t	150000
24	Hoàng Thanh Tuấn	27	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Nội khoa.	\N	4.3	PGS.TS	3 năm kinh nghiệm	\N	t	150000
25	Ngô Thu Lan	28	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Nha khoa.	\N	4.8	Thạc sĩ	3 năm kinh nghiệm	\N	t	150000
26	Phan Hữu Tuấn	28	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Nha khoa.	\N	4.0	Thạc sĩ	7 năm kinh nghiệm	\N	t	150000
27	Hoàng Văn Trung	29	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Tiểu đường - Nội tiết.	\N	4.8	Thạc sĩ	10 năm kinh nghiệm	\N	t	150000
28	Trần Minh Phong	29	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Tiểu đường - Nội tiết.	\N	3.9	Bác sĩ	3 năm kinh nghiệm	\N	t	150000
29	Trần Tuấn Quân	30	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Phục hồi chức năng .	\N	4.8	Tiến sĩ	1 năm kinh nghiệm	\N	t	150000
30	Đặng Đức Phú	30	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Phục hồi chức năng .	\N	4.6	GS.TS	8 năm kinh nghiệm	\N	t	150000
31	Vũ Văn Hòa	31	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Tiêu hoá.	\N	4.0	GS.TS	4 năm kinh nghiệm	\N	t	150000
32	Phạm Minh Phương	31	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Tiêu hoá.	\N	3.6	CKII	2 năm kinh nghiệm	\N	t	150000
33	Nguyễn Ngọc Phương	32	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Ung bướu .	\N	4.7	Tiến sĩ	10 năm kinh nghiệm	\N	t	150000
34	Dương Công Tiên	32	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Ung bướu .	\N	4.3	PGS.TS	9 năm kinh nghiệm	\N	t	150000
35	Bùi Quang Toàn	33	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Tâm lý.	\N	4.7	CKI	12 năm kinh nghiệm	\N	t	150000
36	Phạm Quang Kiên	33	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Tâm lý.	\N	5.0	Bác sĩ	12 năm kinh nghiệm	\N	t	150000
37	Nguyễn Văn Trang	34	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Vô sinh - Hiếm muộn.	\N	4.0	CKI	2 năm kinh nghiệm	\N	t	150000
38	Đặng Hải Mai	34	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Vô sinh - Hiếm muộn.	\N	3.6	CKII	11 năm kinh nghiệm	\N	t	150000
39	Lý Tuấn Long	35	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Chấn thương chỉnh hình .	\N	4.7	Tiến sĩ	4 năm kinh nghiệm	\N	t	150000
40	Đỗ Thị Vân	35	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Chấn thương chỉnh hình .	\N	4.6	Tiến sĩ	10 năm kinh nghiệm	\N	t	150000
41	Bùi Công Nhung	10	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Cơ Xương Khớp.	\N	4.5	PGS.TS	4 năm kinh nghiệm	\N	t	150000
42	Lý Quang Trung	10	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Cơ Xương Khớp.	\N	4.0	CKI	14 năm kinh nghiệm	\N	t	150000
43	Nguyễn Thị Phú	11	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Thần kinh.	\N	4.4	Thạc sĩ	1 năm kinh nghiệm	\N	t	150000
44	Huỳnh Hoài Huy	11	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Thần kinh.	\N	4.8	Tiến sĩ	11 năm kinh nghiệm	\N	t	150000
45	Dương Hữu Phúc	12	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Tiêu hoá.	\N	3.8	GS.TS	14 năm kinh nghiệm	\N	t	150000
46	Nguyễn Hoài Hương	12	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Tiêu hoá.	\N	4.6	PGS.TS	15 năm kinh nghiệm	\N	t	150000
47	Huỳnh Thanh Lâm	13	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Tim mạch .	\N	4.3	Bác sĩ	19 năm kinh nghiệm	\N	t	150000
48	Dương Văn Minh	13	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Tim mạch .	\N	4.9	GS.TS	4 năm kinh nghiệm	\N	t	150000
49	Bùi Hữu Ngọc	14	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Tai Mũi Họng.	\N	4.8	CKI	16 năm kinh nghiệm	\N	t	150000
50	Đặng Hoài Hà	14	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Tai Mũi Họng.	\N	4.5	GS.TS	12 năm kinh nghiệm	\N	t	150000
53	Phạm Hữu Hiếu	16	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Y học Cổ truyền.	\N	3.5	Bác sĩ	7 năm kinh nghiệm	\N	t	150000
54	Nguyễn Công Minh	16	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Y học Cổ truyền.	\N	4.2	Thạc sĩ	14 năm kinh nghiệm	\N	t	150000
55	Đặng Ngọc Thái	17	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Châm cứu.	\N	3.8	GS.TS	5 năm kinh nghiệm	\N	t	150000
56	Lý Ngọc Bình	17	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Châm cứu.	\N	4.5	CKII	13 năm kinh nghiệm	\N	t	150000
57	Đỗ Minh Trinh	18	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Sản Phụ .	\N	4.6	Thạc sĩ	7 năm kinh nghiệm	\N	t	150000
58	Hoàng Công Tiên	18	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Sản Phụ .	\N	4.7	CKI	1 năm kinh nghiệm	\N	t	150000
59	Lê Thanh Hương	19	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Siêu âm thai.	\N	3.9	Thạc sĩ	19 năm kinh nghiệm	\N	t	150000
60	Lê Hữu Lâm	19	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Siêu âm thai.	\N	4.8	GS.TS	16 năm kinh nghiệm	\N	t	150000
61	Lê Công Vinh	20	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Nhi.	\N	3.7	Thạc sĩ	3 năm kinh nghiệm	\N	t	150000
62	Hoàng Tuấn Thảo	20	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Nhi.	\N	3.8	PGS.TS	9 năm kinh nghiệm	\N	t	150000
63	Trần Hoài Huy	21	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Da liễu .	\N	3.5	GS.TS	3 năm kinh nghiệm	\N	t	150000
64	Hoàng Tuấn Tiên	21	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Da liễu .	\N	3.6	Thạc sĩ	18 năm kinh nghiệm	\N	t	150000
65	Nguyễn Tuấn Nhân	22	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Di ứng.	\N	4.0	Tiến sĩ	7 năm kinh nghiệm	\N	t	150000
66	Trần Hải Kiên	22	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Di ứng.	\N	3.9	GS.TS	8 năm kinh nghiệm	\N	t	150000
67	Phạm Hoài Tiên	23	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Mắt .	\N	4.1	Tiến sĩ	10 năm kinh nghiệm	\N	t	150000
68	Hoàng Thu Thiên	23	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Mắt .	\N	4.8	Thạc sĩ	15 năm kinh nghiệm	\N	t	150000
69	Hồ Đức Hải	24	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Hô hấp.	\N	3.7	Bác sĩ	16 năm kinh nghiệm	\N	t	150000
70	Hoàng Ngọc Quang	24	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Hô hấp.	\N	4.4	Bác sĩ	6 năm kinh nghiệm	\N	t	150000
71	Ngô Ngọc Tú	25	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Ngoại thần kinh.	\N	3.7	Thạc sĩ	6 năm kinh nghiệm	\N	t	150000
72	Huỳnh Minh Hà	25	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Ngoại thần kinh.	\N	4.2	Bác sĩ	4 năm kinh nghiệm	\N	t	150000
73	Nguyễn Thu Trung	26	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Thận - Tiết niệu.	\N	4.0	Bác sĩ	18 năm kinh nghiệm	\N	t	150000
74	Trần Hữu Tường	26	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Thận - Tiết niệu.	\N	3.7	Bác sĩ	3 năm kinh nghiệm	\N	t	150000
75	Hồ Minh Thịnh	36	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Ngoại khoa .	\N	4.1	GS.TS	13 năm kinh nghiệm	\N	t	150000
76	Phan Thu Khánh	36	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Ngoại khoa .	\N	4.7	CKI	6 năm kinh nghiệm	\N	t	150000
51	Huỳnh Thu Phúc	15	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Cột sống.		4.9	GS.TS	15 năm kinh nghiệm	\N	t	150000
52	Phan Hải Minh	15	Bệnh viện HealthMate	Khám và điều trị chuyên sâu các bệnh lý liên quan đến Cột sống.	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779791362671.jpg	3.7	PGS.TS	16 năm kinh nghiệm	\N	t	150000
\.


--
-- TOC entry 3912 (class 0 OID 18848)
-- Dependencies: 326
-- Data for Name: chi_tiet_don_thuoc; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chi_tiet_don_thuoc (ma_chi_tiet, ma_don_thuoc, ten_thuoc, lieu_luong, so_ngay_dung, cach_dung, ghi_chu) FROM stdin;
11	6	Paracetamol	1 viên/1 lần	2	sau ăn	cách nhau 6 tiếng
12	6	NSAIDs	1 viên 1 lần	2	sau ăn	\N
13	7	thuốc 1	1 viên 1 lần	3	sau ăn	\N
14	7	thuốc 2	2 viên 1 lần	3	sau ăn	\N
15	8	thuốc 1 demo	1 /1	4	sau ăn	\N
\.


--
-- TOC entry 3896 (class 0 OID 17554)
-- Dependencies: 310
-- Data for Name: chuyen_khoa; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chuyen_khoa (ma_khoa, ten_khoa, anh_icon_url, mo_ta) FROM stdin;
27	Nội khoa	\N	Khám và Điều trị các bệnh và triệu chứng về Nội khoa
28	Nha khoa	\N	Khám và Điều trị các bệnh và triệu chứng về Nha khoa
29	Tiểu đường - Nội tiết	\N	Khám và Điều trị các bệnh và triệu chứng về Tiểu đường - Nội tiết
30	Phục hồi chức năng 	\N	hỗ trợ bệnh nhân phục hồi chức năng
31	Tiêu hoá	\N	Khám và Điều trị các bệnh và triệu chứng về Tiêu hoá
32	Ung bướu 	\N	Khám và Điều trị các bệnh và triệu chứng về Ung bướu
33	Tâm lý	\N	Khám và Điều trị các bệnh và triệu chứng về Tâm lý
34	Vô sinh - Hiếm muộn	\N	Khám và Điều trị các bệnh và triệu chứng về Vô sinh - Hiếm muộn
35	Chấn thương chỉnh hình 	\N	Khám và Điều trị các bệnh và triệu chứng về Chấn thương chỉnh hình
10	Cơ Xương Khớp	\N	Khám và Điều trị các bệnh và triệu chứng về Cơ xương khớp
11	Thần kinh	\N	Khám và Điều trị các bệnh và triệu chứng về Thần kinh
12	Tiêu hoá	\N	Khám và Điều trị các bệnh và triệu chứng về Tiêu hoá
13	Tim mạch 	\N	Khám và Điều trị các bệnh và triệu chứng về Tim mạch
14	Tai Mũi Họng	\N	Khám và Điều trị các bệnh và triệu chứng về Tai mũi họng
15	Cột sống	\N	Khám và Điều trị các bệnh và triệu chứng về Cột sống
16	Y học Cổ truyền	\N	Khám và Điều trị các bệnh và triệu chứng về Y học Cổ truyền
17	Châm cứu	\N	Khám và Điều trị các bệnh và triệu chứng về Châm cứu
18	Sản Phụ 	\N	Khám và Điều trị các bệnh và triệu chứng về Sản phụ
19	Siêu âm thai	\N	Khám và Điều trị các bệnh và triệu chứng về Siêu âm thai
20	Nhi	\N	Khám và Điều trị các bệnh và triệu chứng về Nhi khoa
21	Da liễu 	\N	Khám và Điều trị các bệnh và triệu chứng về Da liễu
22	Di ứng	\N	Khám và Điều trị các bệnh và triệu chứng về Dị ứng
23	Mắt 	\N	Khám và Điều trị các bệnh và triệu chứng về Mắt
24	Hô hấp	\N	Khám và Điều trị các bệnh và triệu chứng về Hô hấp
25	Ngoại thần kinh	\N	Khám và Điều trị các bệnh và triệu chứng về Ngoại thần kinh
26	Thận - Tiết niệu	\N	Khám và Điều trị các bệnh và triệu chứng về Thận - Tiết niệu
36	Ngoại khoa 	\N	Khám và Điều trị các bệnh và triệu chứng về Ngoại khoa
\.


--
-- TOC entry 3921 (class 0 OID 25472)
-- Dependencies: 335
-- Data for Name: danh_gia_bac_si; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.danh_gia_bac_si (id, ma_bac_si, so_dien_thoai, so_sao, nhan_xet, ngay_danh_gia) FROM stdin;
\.


--
-- TOC entry 3902 (class 0 OID 17599)
-- Dependencies: 316
-- Data for Name: don_thuoc; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.don_thuoc (ma_don_thuoc, ma_lich_hen, ghi_chu_bac_si, ngay_ke_don) FROM stdin;
6	37	\N	2026-05-25
7	39	\N	2026-06-17
8	40	\N	2026-06-19
\.


--
-- TOC entry 3916 (class 0 OID 25361)
-- Dependencies: 330
-- Data for Name: khoa_tu_khoa; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.khoa_tu_khoa (id, ma_khoa, symptom_id, tu_khoa) FROM stdin;
\.


--
-- TOC entry 3900 (class 0 OID 17578)
-- Dependencies: 314
-- Data for Name: lich_hen; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lich_hen (ma_lich_hen, so_dien_thoai_bn, ma_bac_si, ngay_kham, khung_gio, trang_thai, trieu_chung, ngay_tao, ma_phong, ly_do_huy, ten_nguoi_kham, tuoi_nguoi_kham, danh_gia) FROM stdin;
37	0392749458	8	2026-05-25	07:00:00	Đã khám	Nhức mỏi cơ	2026-05-23 10:37:52.571423	\N	\N	Nguyễn Đức Vủ Bảo	19	4
38	0392749458	8	2026-05-26	07:00:00	Vắng	Đau	2026-05-23 16:50:02.476379	\N	\N	Huy	12	\N
39	0392749458	55	2026-06-17	07:30:00	Đã khám	\n	2026-06-15 05:22:28.8378	\N	\N	abc	25	5
41	0392749458	55	2026-06-29	07:30:00	Chờ khám		2026-06-17 10:26:50.477144	\N	\N	Huy	13	\N
42	0392749458	8	2026-06-29	07:30:00	Chờ khám		2026-06-17 10:27:17.845797	\N	\N	Bảo	12	\N
40	0392749458	8	2026-06-19	07:30:00	Đã khám		2026-06-16 13:02:01.847145	\N	\N	abc	14	\N
\.


--
-- TOC entry 3908 (class 0 OID 18773)
-- Dependencies: 322
-- Data for Name: lich_truc; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lich_truc (ma_lich_truc, ma_bac_si, ngay_truc, ca_truc, gio_bat_dau, gio_ket_thuc, so_luong_toi_da, trang_thai, trang_thai_duyet, ma_phong) FROM stdin;
88	8	2026-05-26	Sáng	07:00:00	12:00:00	20	t	Đã duyệt	5
89	8	2026-05-25	Sáng	07:00:00	12:00:00	20	t	Đã duyệt	5
90	8	2026-05-25	Chiều	13:00:00	17:00:00	20	t	Đã duyệt	5
91	8	2026-05-26	Chiều	13:00:00	17:00:00	20	t	Đã duyệt	5
92	8	2026-05-27	Sáng	07:00:00	12:00:00	20	t	Đã duyệt	5
93	8	2026-05-27	Chiều	13:00:00	17:00:00	20	t	Đã duyệt	5
94	8	2026-05-28	Sáng	07:00:00	12:00:00	20	t	Đã duyệt	5
95	8	2026-05-28	Chiều	13:00:00	17:00:00	20	t	Đã duyệt	5
96	8	2026-05-29	Sáng	07:00:00	12:00:00	20	t	Đã duyệt	5
97	8	2026-05-29	Chiều	13:00:00	17:00:00	20	t	Đã duyệt	5
98	9	2026-05-25	Sáng	07:00:00	12:00:00	20	t	Đã duyệt	6
99	9	2026-05-25	Chiều	13:00:00	17:00:00	20	t	Đã duyệt	6
101	8	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
102	8	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
103	8	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
104	8	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
105	8	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
106	8	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
107	8	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
108	8	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
109	8	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
110	8	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
111	8	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
112	8	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
113	8	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
114	8	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
115	8	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
116	8	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
117	8	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
118	8	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
119	8	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
120	8	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
121	8	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
122	8	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
123	8	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
124	8	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
125	8	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
126	8	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
127	8	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
128	8	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
129	8	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
130	8	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
131	8	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
132	8	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
133	8	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
134	8	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
135	8	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
136	8	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
137	8	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
138	8	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
139	8	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
140	8	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
141	8	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
142	8	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
143	9	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
144	9	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
145	9	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
146	9	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
147	9	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
148	9	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
149	9	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
150	9	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
151	9	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
152	9	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
153	9	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
154	9	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
155	9	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
156	9	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
157	9	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
158	9	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
159	9	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
160	9	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
161	9	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
162	9	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
100	14	2026-05-28	Sáng	07:00:00	12:00:00	20	t	Từ chối	\N
163	9	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
164	9	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
165	9	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
166	9	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
167	9	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
168	9	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
169	9	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
170	9	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
171	9	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
172	9	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
173	9	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
174	9	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
175	9	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
176	9	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
177	9	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
178	9	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
179	9	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
180	9	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
181	9	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
182	9	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
183	9	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
184	9	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
185	10	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
186	10	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
187	10	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
188	10	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
189	10	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
190	10	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
191	10	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
192	10	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
193	10	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
194	10	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
195	10	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
196	10	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
197	10	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
198	10	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
199	10	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
200	10	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
201	10	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
202	10	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
203	10	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
204	10	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
205	10	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
206	10	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
207	10	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
208	10	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
209	10	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
210	10	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
211	10	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
212	10	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
213	10	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
214	10	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
215	10	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
216	10	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
217	10	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
218	10	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
219	10	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
220	10	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
221	10	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
222	10	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
223	10	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
224	10	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
225	10	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
226	10	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
227	11	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
228	11	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
229	11	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
230	11	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
231	11	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
232	11	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
233	11	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
234	11	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
235	11	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
236	11	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
237	11	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
238	11	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
239	11	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
240	11	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
241	11	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
242	11	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
243	11	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
244	11	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
245	11	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
246	11	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
247	11	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
248	11	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
249	11	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
250	11	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
251	11	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
252	11	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
253	11	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
254	11	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
255	11	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
256	11	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
257	11	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
258	11	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
259	11	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
260	11	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
261	11	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
262	11	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
263	11	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
264	11	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
265	11	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
266	11	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
267	11	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
268	11	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
269	12	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
270	12	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
271	12	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
272	12	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
273	12	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
274	12	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
275	12	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
276	12	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
277	12	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
278	12	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
279	12	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
280	12	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
281	12	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
282	12	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
283	12	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
284	12	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
285	12	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
286	12	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
287	12	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
288	12	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
289	12	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
290	12	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
291	12	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
292	12	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
293	12	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
294	12	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
295	12	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
296	12	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
297	12	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
298	12	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
299	12	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
300	12	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
301	12	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
302	12	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
303	12	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
304	12	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
305	12	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
306	12	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
307	12	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
308	12	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
309	12	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
310	12	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
311	13	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
312	13	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
313	13	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
314	13	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
315	13	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
316	13	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
317	13	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
318	13	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
319	13	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
320	13	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
321	13	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
322	13	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
323	13	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
324	13	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
325	13	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
326	13	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
327	13	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
328	13	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
329	13	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
330	13	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
331	13	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
332	13	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
333	13	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
334	13	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
335	13	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
336	13	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
337	13	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
338	13	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
339	13	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
340	13	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
341	13	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
342	13	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
343	13	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
344	13	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
345	13	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
346	13	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
347	13	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
348	13	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
349	13	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
350	13	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
351	13	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
352	13	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
353	14	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
354	14	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
355	14	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
356	14	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
357	14	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
358	14	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
359	14	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
360	14	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
361	14	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
362	14	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
363	14	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
364	14	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
365	14	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
366	14	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
367	14	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
368	14	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
369	14	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
370	14	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
371	14	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
372	14	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
373	14	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
374	14	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
375	14	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
376	14	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
377	14	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
378	14	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
379	14	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
380	14	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
381	14	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
382	14	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
383	14	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
384	14	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
385	14	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
386	14	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
387	14	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
388	14	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
389	14	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
390	14	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
391	14	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
392	14	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
393	14	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
394	14	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
395	15	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
396	15	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
397	15	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
398	15	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
399	15	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
400	15	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
401	15	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
402	15	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
403	15	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
404	15	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
405	15	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
406	15	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
407	15	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
408	15	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
409	15	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
410	15	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
411	15	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
412	15	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
413	15	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
414	15	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
415	15	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
416	15	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
417	15	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
418	15	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
419	15	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
420	15	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
421	15	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
422	15	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
423	15	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
424	15	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
425	15	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
426	15	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
427	15	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
428	15	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
429	15	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
430	15	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
431	15	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
432	15	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
433	15	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
434	15	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
435	15	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
436	15	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
437	16	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
438	16	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
439	16	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
440	16	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
441	16	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
442	16	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
443	16	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
444	16	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
445	16	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
446	16	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
447	16	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
448	16	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
449	16	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
450	16	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
451	16	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
452	16	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
453	16	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
454	16	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
455	16	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
456	16	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
457	16	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
458	16	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
459	16	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
460	16	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
461	16	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
462	16	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
463	16	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
464	16	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
465	16	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
466	16	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
467	16	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
468	16	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
469	16	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
470	16	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
471	16	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
472	16	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
473	16	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
474	16	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
475	16	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
476	16	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
477	16	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
478	16	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
479	18	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
480	18	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
481	18	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
482	18	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
483	18	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
484	18	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
485	18	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
486	18	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
487	18	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
488	18	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
489	18	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
490	18	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
491	18	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
492	18	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
493	18	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
494	18	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
495	18	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
496	18	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
497	18	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
498	18	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
499	18	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
500	18	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
501	18	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
502	18	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
503	18	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
504	18	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
505	18	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
506	18	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
507	18	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
508	18	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
509	18	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
510	18	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
511	18	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
512	18	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
513	18	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
514	18	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
515	18	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
516	18	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
517	18	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
518	18	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
519	18	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
520	18	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
521	17	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
522	17	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
523	17	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
524	17	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
525	17	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
526	17	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
527	17	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
528	17	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
529	17	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
530	17	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
531	17	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
532	17	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
533	17	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
534	17	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
535	17	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
536	17	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
537	17	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
538	17	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
539	17	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
540	17	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
541	17	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
542	17	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
543	17	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
544	17	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
545	17	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
546	17	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
547	17	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
548	17	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
549	17	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
550	17	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
551	17	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
552	17	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
553	17	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
554	17	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
555	17	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
556	17	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
557	17	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
558	17	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
559	17	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
560	17	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
561	17	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
562	17	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
563	19	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
564	19	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
565	19	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
566	19	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
567	19	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
568	19	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
569	19	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
570	19	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
571	19	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
572	19	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
573	19	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
574	19	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
575	19	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
576	19	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
577	19	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
578	19	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
579	19	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
580	19	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
581	19	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
582	19	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
583	19	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
584	19	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
585	19	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
586	19	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
587	19	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
588	19	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
589	19	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
590	19	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
591	19	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
592	19	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
593	19	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
594	19	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
595	19	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
596	19	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
597	19	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
598	19	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
599	19	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
600	19	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
601	19	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
602	19	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
603	19	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
604	19	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
605	20	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
606	20	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
607	20	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
608	20	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
609	20	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
610	20	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
611	20	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
612	20	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
613	20	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
614	20	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
615	20	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
616	20	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
617	20	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
618	20	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
619	20	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
620	20	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
621	20	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
622	20	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
623	20	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
624	20	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
625	20	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
626	20	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
627	20	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
628	20	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
629	20	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
630	20	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
631	20	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
632	20	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
633	20	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
634	20	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
635	20	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
636	20	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
637	20	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
638	20	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
639	20	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
640	20	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
641	20	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
642	20	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
643	20	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
644	20	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
645	20	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
646	20	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
647	21	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
648	21	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
649	21	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
650	21	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
651	21	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
652	21	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
653	21	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
654	21	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
655	21	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
656	21	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
657	21	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
658	21	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
659	21	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
660	21	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
661	21	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
662	21	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
663	21	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
664	21	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
665	21	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
666	21	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
667	21	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
668	21	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
669	21	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
670	21	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
671	21	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
672	21	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
673	21	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
674	21	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
675	21	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
676	21	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
677	21	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
678	21	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
679	21	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
680	21	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
681	21	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
682	21	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
683	21	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
684	21	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
685	21	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
686	21	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
687	21	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
688	21	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
689	22	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
690	22	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
691	22	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
692	22	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
693	22	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
694	22	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
695	22	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
696	22	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
697	22	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
698	22	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
699	22	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
700	22	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
701	22	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
702	22	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
703	22	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
704	22	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
705	22	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
706	22	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
707	22	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
708	22	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
709	22	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
710	22	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
711	22	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
712	22	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
713	22	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
714	22	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
715	22	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
716	22	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
717	22	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
718	22	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
719	22	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
720	22	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
721	22	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
722	22	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
723	22	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
724	22	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
725	22	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
726	22	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
727	22	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
728	22	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
729	22	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
730	22	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
731	23	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
732	23	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
733	23	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
734	23	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
735	23	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
736	23	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
737	23	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
738	23	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
739	23	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
740	23	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
741	23	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
742	23	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
743	23	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
744	23	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
745	23	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
746	23	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
747	23	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
748	23	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
749	23	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
750	23	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
751	23	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
752	23	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
753	23	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
754	23	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
755	23	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
756	23	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
757	23	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
758	23	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
759	23	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
760	23	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
761	23	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
762	23	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
763	23	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
764	23	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
765	23	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
766	23	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
767	23	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
768	23	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
769	23	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
770	23	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
771	23	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
772	23	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
773	24	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
774	24	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
775	24	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
776	24	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
777	24	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
778	24	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
779	24	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
780	24	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
781	24	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
782	24	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
783	24	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
784	24	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
785	24	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
786	24	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
787	24	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
788	24	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
789	24	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
790	24	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
791	24	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
792	24	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
793	24	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
794	24	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
795	24	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
796	24	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
797	24	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
798	24	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
799	24	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
800	24	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
801	24	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
802	24	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
803	24	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
804	24	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
805	24	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
806	24	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
807	24	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
808	24	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
809	24	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
810	24	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
811	24	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
812	24	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
813	24	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	11
814	24	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	11
815	25	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
816	25	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
817	25	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
818	25	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
819	25	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
820	25	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
821	25	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
822	25	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
823	25	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
824	25	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
825	25	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
826	25	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
827	25	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
828	25	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
829	25	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
830	25	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
831	25	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
832	25	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
833	25	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
834	25	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
835	25	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
836	25	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
837	25	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
838	25	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
839	25	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
840	25	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
841	25	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
842	25	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
843	25	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
844	25	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
845	25	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
846	25	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
847	25	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
848	25	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
849	25	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
850	25	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
851	25	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
852	25	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
853	25	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
854	25	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
855	25	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
856	25	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
857	26	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
858	26	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
859	26	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
860	26	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
861	26	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
862	26	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
863	26	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
864	26	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
865	26	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
866	26	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
867	26	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
868	26	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
869	26	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
870	26	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
871	26	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
872	26	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
873	26	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
874	26	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
875	26	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
876	26	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
877	26	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
878	26	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
879	26	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
880	26	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
881	26	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
882	26	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
883	26	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
884	26	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
885	26	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
886	26	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
887	26	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
888	26	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
889	26	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
890	26	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
891	26	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
892	26	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
893	26	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
894	26	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
895	26	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
896	26	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
897	26	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	13
898	26	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	13
899	27	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
900	27	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
901	27	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
902	27	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
903	27	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
904	27	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
905	27	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
906	27	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
907	27	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
908	27	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
909	27	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
910	27	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
911	27	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
912	27	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
913	27	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
914	27	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
915	27	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
916	27	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
917	27	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
918	27	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
919	27	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
920	27	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
921	27	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
922	27	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
923	27	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
924	27	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
925	27	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
926	27	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
927	27	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
928	27	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
929	27	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
930	27	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
931	27	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
932	27	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
933	27	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
934	27	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
935	27	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
936	27	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
937	27	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
938	27	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
939	27	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
940	27	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
941	28	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
942	28	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
943	28	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
944	28	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
945	28	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
946	28	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
947	28	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
948	28	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
949	28	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
950	28	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
951	28	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
952	28	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
953	28	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
954	28	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
955	28	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
956	28	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
957	28	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
958	28	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
959	28	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
960	28	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
961	28	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
962	28	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
963	28	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
964	28	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
965	28	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
966	28	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
967	28	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
968	28	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
969	28	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
970	28	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
971	28	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
972	28	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
973	28	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
974	28	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
975	28	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
976	28	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
977	28	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
978	28	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
979	28	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
980	28	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
981	28	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	15
982	28	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	15
983	29	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
984	29	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
985	29	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
986	29	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
987	29	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
988	29	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
989	29	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
990	29	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
991	29	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
992	29	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
993	29	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
994	29	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
995	29	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
996	29	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
997	29	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
998	29	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
999	29	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1000	29	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1001	29	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1002	29	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1003	29	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1004	29	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1005	29	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1006	29	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1007	29	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1008	29	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1009	29	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1010	29	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1011	29	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1012	29	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1013	29	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1014	29	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1015	29	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1016	29	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1017	29	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1018	29	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1019	29	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1020	29	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1021	29	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1022	29	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1023	29	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1024	29	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1025	30	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1026	30	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1027	30	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1028	30	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1029	30	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1030	30	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1031	30	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1032	30	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1033	30	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1034	30	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1035	30	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1036	30	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1037	30	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1038	30	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1039	30	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1040	30	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1041	30	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1042	30	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1043	30	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1044	30	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1045	30	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1046	30	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1047	30	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1048	30	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1049	30	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1050	30	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1051	30	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1052	30	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1053	30	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1054	30	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1055	30	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1056	30	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1057	30	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1058	30	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1059	30	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1060	30	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1061	30	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1062	30	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1063	30	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1064	30	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1065	30	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	17
1066	30	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	17
1067	31	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1068	31	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1069	31	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1070	31	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1071	31	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1072	31	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1073	31	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1074	31	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1075	31	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1076	31	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1077	31	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1078	31	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1079	31	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1080	31	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1081	31	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1082	31	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1083	31	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1084	31	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1085	31	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1086	31	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1087	31	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1088	31	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1089	31	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1090	31	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1091	31	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1092	31	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1093	31	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1094	31	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1095	31	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1096	31	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1097	31	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1098	31	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1099	31	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1100	31	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1101	31	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1102	31	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1103	31	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1104	31	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1105	31	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1106	31	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1107	31	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1108	31	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1109	32	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1110	32	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1111	32	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1112	32	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1113	32	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1114	32	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1115	32	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1116	32	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1117	32	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1118	32	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1119	32	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1120	32	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1121	32	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1122	32	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1123	32	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1124	32	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1125	32	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1126	32	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1127	32	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1128	32	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1129	32	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1130	32	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1131	32	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1132	32	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1133	32	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1134	32	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1135	32	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1136	32	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1137	32	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1138	32	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1139	32	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1140	32	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1141	32	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1142	32	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1143	32	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1144	32	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1145	32	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1146	32	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1147	32	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1148	32	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1149	32	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	19
1150	32	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	19
1151	33	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1152	33	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1153	33	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1154	33	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1155	33	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1156	33	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1157	33	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1158	33	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1159	33	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1160	33	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1161	33	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1162	33	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1163	33	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1164	33	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1165	33	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1166	33	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1167	33	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1168	33	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1169	33	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1170	33	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1171	33	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1172	33	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1173	33	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1174	33	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1175	33	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1176	33	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1177	33	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1178	33	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1179	33	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1180	33	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1181	33	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1182	33	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1183	33	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1184	33	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1185	33	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1186	33	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1187	33	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1188	33	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1189	33	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1190	33	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1191	33	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1192	33	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1193	34	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1194	34	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1195	34	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1196	34	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1197	34	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1198	34	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1199	34	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1200	34	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1201	34	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1202	34	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1203	34	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1204	34	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1205	34	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1206	34	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1207	34	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1208	34	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1209	34	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1210	34	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1211	34	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1212	34	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1213	34	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1214	34	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1215	34	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1216	34	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1217	34	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1218	34	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1219	34	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1220	34	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1221	34	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1222	34	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1223	34	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1224	34	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1225	34	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1226	34	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1227	34	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1228	34	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1229	34	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1230	34	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1231	34	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1232	34	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1233	34	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	21
1234	34	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	21
1235	35	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1236	35	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1237	35	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1238	35	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1239	35	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1240	35	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1241	35	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1242	35	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1243	35	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1244	35	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1245	35	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1246	35	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1247	35	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1248	35	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1249	35	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1250	35	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1251	35	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1252	35	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1253	35	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1254	35	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1255	35	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1256	35	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1257	35	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1258	35	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1259	35	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1260	35	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1261	35	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1262	35	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1263	35	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1264	35	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1265	35	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1266	35	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1267	35	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1268	35	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1269	35	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1270	35	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1271	35	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1272	35	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1273	35	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1274	35	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1275	35	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1276	35	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1277	36	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1278	36	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1279	36	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1280	36	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1281	36	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1282	36	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1283	36	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1284	36	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1285	36	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1286	36	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1287	36	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1288	36	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1289	36	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1290	36	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1291	36	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1292	36	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1293	36	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1294	36	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1295	36	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1296	36	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1297	36	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1298	36	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1299	36	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1300	36	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1301	36	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1302	36	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1303	36	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1304	36	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1305	36	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1306	36	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1307	36	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1308	36	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1309	36	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1310	36	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1311	36	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1312	36	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1313	36	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1314	36	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1315	36	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1316	36	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1317	36	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	23
1318	36	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	23
1319	37	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1320	37	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1321	37	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1322	37	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1323	37	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1324	37	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1325	37	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1326	37	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1327	37	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1328	37	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1329	37	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1330	37	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1331	37	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1332	37	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1333	37	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1334	37	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1335	37	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1336	37	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1337	37	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1338	37	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1339	37	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1340	37	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1341	37	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1342	37	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1343	37	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1344	37	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1345	37	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1346	37	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1347	37	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1348	37	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1349	37	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1350	37	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1351	37	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1352	37	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1353	37	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1354	37	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1355	37	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1356	37	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1357	37	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1358	37	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1359	37	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1360	37	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1361	38	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1362	38	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1363	38	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1364	38	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1365	38	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1366	38	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1367	38	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1368	38	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1369	38	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1370	38	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1371	38	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1372	38	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1373	38	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1374	38	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1375	38	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1376	38	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1377	38	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1378	38	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1379	38	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1380	38	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1381	38	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1382	38	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1383	38	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1384	38	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1385	38	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1386	38	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1387	38	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1388	38	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1389	38	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1390	38	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1391	38	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1392	38	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1393	38	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1394	38	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1395	38	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1396	38	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1397	38	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1398	38	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1399	38	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1400	38	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1401	38	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	25
1402	38	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	25
1403	39	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1404	39	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1405	39	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1406	39	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1407	39	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1408	39	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1409	39	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1410	39	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1411	39	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1412	39	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1413	39	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1414	39	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1415	39	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1416	39	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1417	39	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1418	39	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1419	39	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1420	39	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1421	39	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1422	39	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1423	39	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1424	39	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1425	39	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1426	39	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1427	39	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1428	39	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1429	39	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1430	39	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1431	39	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1432	39	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1433	39	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1434	39	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1435	39	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1436	39	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1437	39	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1438	39	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1439	39	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1440	39	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1441	39	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1442	39	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1443	39	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1444	39	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1445	40	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1446	40	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1447	40	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1448	40	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1449	40	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1450	40	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1451	40	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1452	40	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1453	40	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1454	40	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1455	40	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1456	40	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1457	40	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1458	40	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1459	40	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1460	40	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1461	40	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1462	40	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1463	40	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1464	40	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1465	40	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1466	40	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1467	40	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1468	40	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1469	40	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1470	40	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1471	40	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1472	40	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1473	40	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1474	40	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1475	40	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1476	40	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1477	40	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1478	40	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1479	40	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1480	40	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1481	40	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1482	40	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1483	40	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1484	40	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1485	40	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	9
1486	40	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	9
1487	41	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1488	41	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1489	41	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1490	41	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1491	41	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1492	41	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1493	41	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1494	41	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1495	41	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1496	41	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1497	41	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1498	41	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1499	41	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1500	41	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1501	41	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1502	41	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1503	41	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1504	41	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1505	41	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1506	41	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1507	41	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1508	41	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1509	41	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1510	41	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1511	41	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1512	41	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1513	41	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1514	41	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1515	41	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1516	41	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1517	41	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1518	41	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1519	41	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1520	41	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1521	41	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1522	41	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1523	41	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1524	41	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1525	41	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1526	41	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1527	41	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1528	41	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1529	42	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1530	42	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1531	42	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1532	42	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1533	42	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1534	42	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1535	42	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1536	42	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1537	42	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1538	42	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1539	42	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1540	42	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1541	42	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1542	42	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1543	42	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1544	42	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1545	42	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1546	42	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1547	42	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1548	42	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1549	42	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1550	42	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1551	42	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1552	42	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1553	42	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1554	42	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1555	42	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1556	42	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1557	42	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1558	42	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1559	42	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1560	42	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1561	42	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1562	42	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1563	42	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1564	42	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1565	42	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1566	42	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1567	42	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1568	42	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1569	42	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	5
1570	42	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	5
1571	43	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1572	43	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1573	43	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1574	43	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1575	43	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1576	43	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1577	43	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1578	43	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1579	43	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1580	43	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1581	43	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1582	43	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1583	43	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1584	43	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1585	43	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1586	43	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1587	43	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1588	43	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1589	43	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1590	43	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1591	43	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1592	43	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1593	43	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1594	43	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1595	43	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1596	43	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1597	43	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1598	43	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1599	43	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1600	43	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1601	43	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1602	43	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1603	43	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1604	43	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1605	43	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1606	43	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1607	43	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1608	43	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1609	43	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1610	43	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1611	43	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1612	43	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1613	44	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1614	44	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1615	44	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1616	44	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1617	44	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1618	44	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1619	44	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1620	44	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1621	44	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1622	44	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1623	44	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1624	44	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1625	44	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1626	44	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1627	44	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1628	44	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1629	44	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1630	44	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1631	44	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1632	44	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1633	44	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1634	44	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1635	44	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1636	44	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1637	44	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1638	44	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1639	44	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1640	44	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1641	44	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1642	44	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1643	44	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1644	44	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1645	44	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1646	44	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1647	44	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1648	44	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1649	44	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1650	44	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1651	44	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1652	44	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1653	44	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	27
1654	44	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	27
1655	45	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1656	45	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1657	45	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1658	45	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1659	45	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1660	45	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1661	45	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1662	45	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1663	45	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1664	45	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1665	45	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1666	45	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1667	45	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1668	45	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1669	45	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1670	45	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1671	45	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1672	45	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1673	45	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1674	45	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1675	45	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1676	45	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1677	45	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1678	45	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1679	45	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1680	45	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1681	45	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1682	45	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1683	45	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1684	45	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1685	45	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1686	45	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1687	45	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1688	45	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1689	45	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1690	45	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1691	45	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1692	45	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1693	45	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1694	45	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1695	45	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1696	45	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1697	46	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1698	46	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1699	46	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1700	46	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1701	46	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1702	46	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1703	46	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1704	46	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1705	46	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1706	46	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1707	46	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1708	46	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1709	46	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1710	46	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1711	46	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1712	46	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1713	46	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1714	46	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1715	46	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1716	46	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1717	46	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1718	46	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1719	46	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1720	46	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1721	46	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1722	46	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1723	46	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1724	46	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1725	46	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1726	46	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1727	46	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1728	46	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1729	46	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1730	46	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1731	46	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1732	46	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1733	46	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1734	46	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1735	46	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1736	46	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1737	46	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	29
1738	46	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	29
1739	47	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1740	47	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1741	47	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1742	47	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1743	47	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1744	47	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1745	47	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1746	47	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1747	47	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1748	47	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1749	47	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1750	47	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1751	47	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1752	47	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1753	47	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1754	47	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1755	47	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1756	47	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1757	47	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1758	47	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1759	47	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1760	47	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1761	47	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1762	47	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1763	47	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1764	47	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1765	47	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1766	47	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1767	47	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1768	47	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1769	47	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1770	47	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1771	47	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1772	47	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1773	47	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1774	47	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1775	47	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1776	47	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1777	47	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1778	47	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1779	47	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1780	47	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1781	48	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1782	48	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1783	48	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1784	48	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1785	48	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1786	48	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1787	48	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1788	48	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1789	48	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1790	48	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1791	48	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1792	48	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1793	48	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1794	48	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1795	48	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1796	48	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1797	48	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1798	48	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1799	48	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1800	48	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1801	48	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1802	48	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1803	48	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1804	48	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1805	48	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1806	48	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1807	48	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1808	48	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1809	48	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1810	48	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1811	48	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1812	48	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1813	48	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1814	48	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1815	48	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1816	48	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1817	48	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1818	48	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1819	48	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1820	48	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1821	48	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	31
1822	48	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	31
1823	49	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1824	49	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1825	49	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1826	49	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1827	49	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1828	49	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1829	49	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1830	49	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1831	49	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1832	49	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1833	49	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1834	49	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1835	49	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1836	49	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1837	49	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1838	49	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1839	49	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1840	49	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1841	49	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1842	49	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1843	49	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1844	49	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1845	49	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1846	49	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1847	49	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1848	49	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1849	49	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1850	49	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1851	49	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1852	49	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1853	49	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1854	49	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1855	49	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1856	49	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1857	49	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1858	49	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1859	49	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1860	49	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1861	49	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1862	49	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1863	49	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1864	49	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1865	50	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1866	50	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1867	50	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1868	50	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1869	50	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1870	50	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1871	50	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1872	50	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1873	50	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1874	50	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1875	50	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1876	50	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1877	50	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1878	50	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1879	50	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1880	50	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1881	50	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1882	50	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1883	50	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1884	50	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1885	50	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1886	50	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1887	50	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1888	50	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1889	50	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1890	50	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1891	50	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1892	50	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1893	50	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1894	50	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1895	50	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1896	50	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1897	50	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1898	50	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1899	50	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1900	50	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1901	50	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1902	50	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1903	50	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1904	50	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1905	50	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	33
1906	50	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	33
1907	53	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1908	53	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1909	53	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1910	53	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1911	53	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1912	53	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1913	53	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1914	53	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1915	53	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1916	53	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1917	53	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1918	53	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1919	53	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1920	53	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1921	53	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1922	53	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1923	53	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1924	53	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1925	53	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1926	53	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1927	53	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1928	53	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1929	53	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1930	53	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1931	53	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1932	53	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1933	53	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1934	53	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1935	53	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1936	53	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1937	53	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1938	53	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1939	53	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1940	53	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1941	53	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1942	53	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1943	53	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1944	53	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1945	53	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1946	53	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1947	53	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1948	53	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1949	54	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1950	54	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1951	54	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1952	54	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1953	54	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1954	54	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1955	54	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1956	54	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1957	54	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1958	54	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1959	54	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1960	54	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1961	54	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1962	54	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1963	54	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1964	54	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1965	54	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1966	54	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1967	54	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1968	54	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1969	54	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1970	54	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1971	54	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1972	54	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1973	54	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1974	54	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1975	54	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1976	54	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1977	54	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1978	54	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1979	54	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1980	54	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1981	54	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1982	54	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1983	54	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1984	54	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1985	54	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1986	54	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1987	54	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1988	54	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1989	54	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	37
1990	54	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	37
1991	55	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
1992	55	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
1993	55	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
1994	55	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
1995	55	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
1996	55	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
1997	55	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
1998	55	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
1999	55	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2000	55	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2001	55	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2002	55	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2003	55	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2004	55	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2005	55	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2006	55	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2007	55	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2008	55	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2009	55	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2010	55	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2011	55	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2012	55	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2013	55	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2014	55	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2015	55	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2016	55	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2017	55	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2018	55	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2019	55	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2020	55	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2021	55	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2022	55	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2023	55	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2024	55	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2025	55	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2026	55	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2027	55	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2028	55	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2029	55	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2030	55	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2031	55	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2032	55	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2033	56	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2034	56	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2035	56	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2036	56	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2037	56	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2038	56	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2039	56	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2040	56	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2041	56	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2042	56	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2043	56	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2044	56	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2045	56	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2046	56	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2047	56	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2048	56	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2049	56	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2050	56	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2051	56	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2052	56	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2053	56	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2054	56	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2055	56	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2056	56	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2057	56	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2058	56	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2059	56	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2060	56	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2061	56	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2062	56	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2063	56	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2064	56	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2065	56	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2066	56	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2067	56	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2068	56	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2069	56	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2070	56	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2071	56	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2072	56	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2073	56	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	7
2074	56	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	7
2075	57	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2076	57	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2077	57	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2078	57	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2079	57	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2080	57	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2081	57	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2082	57	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2083	57	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2084	57	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2085	57	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2086	57	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2087	57	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2088	57	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2089	57	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2090	57	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2091	57	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2092	57	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2093	57	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2094	57	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2095	57	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2096	57	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2097	57	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2098	57	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2099	57	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2100	57	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2101	57	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2102	57	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2103	57	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2104	57	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2105	57	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2106	57	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2107	57	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2108	57	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2109	57	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2110	57	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2111	57	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2112	57	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2113	57	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2114	57	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2115	57	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2116	57	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2117	58	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2118	58	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2119	58	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2120	58	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2121	58	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2122	58	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2123	58	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2124	58	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2125	58	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2126	58	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2127	58	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2128	58	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2129	58	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2130	58	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2131	58	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2132	58	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2133	58	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2134	58	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2135	58	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2136	58	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2137	58	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2138	58	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2139	58	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2140	58	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2141	58	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2142	58	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2143	58	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2144	58	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2145	58	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2146	58	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2147	58	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2148	58	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2149	58	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2150	58	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2151	58	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2152	58	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2153	58	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2154	58	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2155	58	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2156	58	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2157	58	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	39
2158	58	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	39
2159	59	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2160	59	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2161	59	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2162	59	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2163	59	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2164	59	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2165	59	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2166	59	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2167	59	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2168	59	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2169	59	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2170	59	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2171	59	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2172	59	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2173	59	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2174	59	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2175	59	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2176	59	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2177	59	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2178	59	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2179	59	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2180	59	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2181	59	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2182	59	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2183	59	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2184	59	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2185	59	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2186	59	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2187	59	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2188	59	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2189	59	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2190	59	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2191	59	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2192	59	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2193	59	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2194	59	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2195	59	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2196	59	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2197	59	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2198	59	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2199	59	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2200	59	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2201	60	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2202	60	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2203	60	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2204	60	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2205	60	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2206	60	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2207	60	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2208	60	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2209	60	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2210	60	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2211	60	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2212	60	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2213	60	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2214	60	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2215	60	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2216	60	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2217	60	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2218	60	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2219	60	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2220	60	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2221	60	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2222	60	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2223	60	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2224	60	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2225	60	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2226	60	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2227	60	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2228	60	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2229	60	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2230	60	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2231	60	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2232	60	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2233	60	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2234	60	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2235	60	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2236	60	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2237	60	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2238	60	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2239	60	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2240	60	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2241	60	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	41
2242	60	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	41
2243	61	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2244	61	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2245	61	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2246	61	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2247	61	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2248	61	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2249	61	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2250	61	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2251	61	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2252	61	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2253	61	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2254	61	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2255	61	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2256	61	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2257	61	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2258	61	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2259	61	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2260	61	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2261	61	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2262	61	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2263	61	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2264	61	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2265	61	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2266	61	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2267	61	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2268	61	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2269	61	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2270	61	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2271	61	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2272	61	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2273	61	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2274	61	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2275	61	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2276	61	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2277	61	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2278	61	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2279	61	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2280	61	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2281	61	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2282	61	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2283	61	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2284	61	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2285	62	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2286	62	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2287	62	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2288	62	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2289	62	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2290	62	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2291	62	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2292	62	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2293	62	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2294	62	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2295	62	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2296	62	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2297	62	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2298	62	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2299	62	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2300	62	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2301	62	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2302	62	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2303	62	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2304	62	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2305	62	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2306	62	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2307	62	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2308	62	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2309	62	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2310	62	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2311	62	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2312	62	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2313	62	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2314	62	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2315	62	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2316	62	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2317	62	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2318	62	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2319	62	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2320	62	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2321	62	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2322	62	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2323	62	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2324	62	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2325	62	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	43
2326	62	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	43
2327	63	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2328	63	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2329	63	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2330	63	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2331	63	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2332	63	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2333	63	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2334	63	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2335	63	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2336	63	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2337	63	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2338	63	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2339	63	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2340	63	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2341	63	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2342	63	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2343	63	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2344	63	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2345	63	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2346	63	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2347	63	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2348	63	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2349	63	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2350	63	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2351	63	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2352	63	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2353	63	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2354	63	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2355	63	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2356	63	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2357	63	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2358	63	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2359	63	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2360	63	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2361	63	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2362	63	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2363	63	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2364	63	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2365	63	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2366	63	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2367	63	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2368	63	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2369	64	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2370	64	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2371	64	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2372	64	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2373	64	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2374	64	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2375	64	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2376	64	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2377	64	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2378	64	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2379	64	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2380	64	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2381	64	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2382	64	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2383	64	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2384	64	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2385	64	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2386	64	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2387	64	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2388	64	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2389	64	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2390	64	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2391	64	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2392	64	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2393	64	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2394	64	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2395	64	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2396	64	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2397	64	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2398	64	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2399	64	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2400	64	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2401	64	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2402	64	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2403	64	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2404	64	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2405	64	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2406	64	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2407	64	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2408	64	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2409	64	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	45
2410	64	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	45
2411	65	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2412	65	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2413	65	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2414	65	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2415	65	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2416	65	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2417	65	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2418	65	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2419	65	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2420	65	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2421	65	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2422	65	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2423	65	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2424	65	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2425	65	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2426	65	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2427	65	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2428	65	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2429	65	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2430	65	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2431	65	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2432	65	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2433	65	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2434	65	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2435	65	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2436	65	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2437	65	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2438	65	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2439	65	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2440	65	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2441	65	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2442	65	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2443	65	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2444	65	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2445	65	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2446	65	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2447	65	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2448	65	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2449	65	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2450	65	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2451	65	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2452	65	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2453	66	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2454	66	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2455	66	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2456	66	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2457	66	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2458	66	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2459	66	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2460	66	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2461	66	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2462	66	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2463	66	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2464	66	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2465	66	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2466	66	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2467	66	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2468	66	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2469	66	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2470	66	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2471	66	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2472	66	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2473	66	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2474	66	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2475	66	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2476	66	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2477	66	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2478	66	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2479	66	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2480	66	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2481	66	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2482	66	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2483	66	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2484	66	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2485	66	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2486	66	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2487	66	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2488	66	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2489	66	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2490	66	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2491	66	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2492	66	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2493	66	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	47
2494	66	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	47
2495	67	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2496	67	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2497	67	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2498	67	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2499	67	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2500	67	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2501	67	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2502	67	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2503	67	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2504	67	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2505	67	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2506	67	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2507	67	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2508	67	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2509	67	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2510	67	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2511	67	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2512	67	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2513	67	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2514	67	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2515	67	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2516	67	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2517	67	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2518	67	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2519	67	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2520	67	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2521	67	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2522	67	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2523	67	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2524	67	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2525	67	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2526	67	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2527	67	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2528	67	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2529	67	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2530	67	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2531	67	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2532	67	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2533	67	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2534	67	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2535	67	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2536	67	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2537	68	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2538	68	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2539	68	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2540	68	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2541	68	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2542	68	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2543	68	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2544	68	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2545	68	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2546	68	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2547	68	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2548	68	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2549	68	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2550	68	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2551	68	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2552	68	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2553	68	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2554	68	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2555	68	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2556	68	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2557	68	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2558	68	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2559	68	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2560	68	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2561	68	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2562	68	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2563	68	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2564	68	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2565	68	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2566	68	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2567	68	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2568	68	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2569	68	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2570	68	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2571	68	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2572	68	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2573	68	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2574	68	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2575	68	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2576	68	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2577	68	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	49
2578	68	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	49
2579	69	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2580	69	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2581	69	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2582	69	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2583	69	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2584	69	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2585	69	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2586	69	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2587	69	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2588	69	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2589	69	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2590	69	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2591	69	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2592	69	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2593	69	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2594	69	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2595	69	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2596	69	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2597	69	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2598	69	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2599	69	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2600	69	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2601	69	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2602	69	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2603	69	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2604	69	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2605	69	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2606	69	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2607	69	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2608	69	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2609	69	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2610	69	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2611	69	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2612	69	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2613	69	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2614	69	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2615	69	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2616	69	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2617	69	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2618	69	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2619	69	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2620	69	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2621	70	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2622	70	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2623	70	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2624	70	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2625	70	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2626	70	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2627	70	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2628	70	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2629	70	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2630	70	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2631	70	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2632	70	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2633	70	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2634	70	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2635	70	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2636	70	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2637	70	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2638	70	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2639	70	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2640	70	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2641	70	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2642	70	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2643	70	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2644	70	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2645	70	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2646	70	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2647	70	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2648	70	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2649	70	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2650	70	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2651	70	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2652	70	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2653	70	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2654	70	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2655	70	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2656	70	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2657	70	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2658	70	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2659	70	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2660	70	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2661	70	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	51
2662	70	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	51
2663	71	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2664	71	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2665	71	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2666	71	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2667	71	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2668	71	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2669	71	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2670	71	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2671	71	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2672	71	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2673	71	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2674	71	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2675	71	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2676	71	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2677	71	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2678	71	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2679	71	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2680	71	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2681	71	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2682	71	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2683	71	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2684	71	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2685	71	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2686	71	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2687	71	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2688	71	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2689	71	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2690	71	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2691	71	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2692	71	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2693	71	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2694	71	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2695	71	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2696	71	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2697	71	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2698	71	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2699	71	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2700	71	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2701	71	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2702	71	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2703	71	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2704	71	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2705	72	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2706	72	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2707	72	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2708	72	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2709	72	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2710	72	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2711	72	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2712	72	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2713	72	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2714	72	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2715	72	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2716	72	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2717	72	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2718	72	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2719	72	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2720	72	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2721	72	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2722	72	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2723	72	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2724	72	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2725	72	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2726	72	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2727	72	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2728	72	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2729	72	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2730	72	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2731	72	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2732	72	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2733	72	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2734	72	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2735	72	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2736	72	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2737	72	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2738	72	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2739	72	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2740	72	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2741	72	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2742	72	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2743	72	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2744	72	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2745	72	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	53
2746	72	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	53
2747	73	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2748	73	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2749	73	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2750	73	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2751	73	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2752	73	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2753	73	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2754	73	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2755	73	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2756	73	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2757	73	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2758	73	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2759	73	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2760	73	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2761	73	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2762	73	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2763	73	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2764	73	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2765	73	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2766	73	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2767	73	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2768	73	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2769	73	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2770	73	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2771	73	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2772	73	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2773	73	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2774	73	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2775	73	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2776	73	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2777	73	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2778	73	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2779	73	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2780	73	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2781	73	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2782	73	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2783	73	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2784	73	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2785	73	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2786	73	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2787	73	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2788	73	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2789	74	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2790	74	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2791	74	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2792	74	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2793	74	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2794	74	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2795	74	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2796	74	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2797	74	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2798	74	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2799	74	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2800	74	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2801	74	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2802	74	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2803	74	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2804	74	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2805	74	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2806	74	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2807	74	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2808	74	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2809	74	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2810	74	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2811	74	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2812	74	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2813	74	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2814	74	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2815	74	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2816	74	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2817	74	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2818	74	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2819	74	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2820	74	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2821	74	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2822	74	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2823	74	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2824	74	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2825	74	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2826	74	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2827	74	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2828	74	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2829	74	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	55
2830	74	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	55
2831	75	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2832	75	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2833	75	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2834	75	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2835	75	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2836	75	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2837	75	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2838	75	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2839	75	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2840	75	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2841	75	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2842	75	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2843	75	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2844	75	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2845	75	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2846	75	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2847	75	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2848	75	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2849	75	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2850	75	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2851	75	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2852	75	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2853	75	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2854	75	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2855	75	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2856	75	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2857	75	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2858	75	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2859	75	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2860	75	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2861	75	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2862	75	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2863	75	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2864	75	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2865	75	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2866	75	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2867	75	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2868	75	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2869	75	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2870	75	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2871	75	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2872	75	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2873	76	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2874	76	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2875	76	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2876	76	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2877	76	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2878	76	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2879	76	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2880	76	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2881	76	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2882	76	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2883	76	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2884	76	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2885	76	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2886	76	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2887	76	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2888	76	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2889	76	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2890	76	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2891	76	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2892	76	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2893	76	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2894	76	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2895	76	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2896	76	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2897	76	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2898	76	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2899	76	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2900	76	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2901	76	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2902	76	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2903	76	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2904	76	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2905	76	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2906	76	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2907	76	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2908	76	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2909	76	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2910	76	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2911	76	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2912	76	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2913	76	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	57
2914	76	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	57
2915	51	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2916	51	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2917	51	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2918	51	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2919	51	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2920	51	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2921	51	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2922	51	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2923	51	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2924	51	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2925	51	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2926	51	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2927	51	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2928	51	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2929	51	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2930	51	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2931	51	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2932	51	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2933	51	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2934	51	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2935	51	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2936	51	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2937	51	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2938	51	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2939	51	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2940	51	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2941	51	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2942	51	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2943	51	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2944	51	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2945	51	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2946	51	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2947	51	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2948	51	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2949	51	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2950	51	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2951	51	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2952	51	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2953	51	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2954	51	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2955	51	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2956	51	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2957	52	2026-06-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2958	52	2026-06-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2959	52	2026-06-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2960	52	2026-06-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2961	52	2026-06-19	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2962	52	2026-06-19	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2963	52	2026-06-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2964	52	2026-06-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2965	52	2026-06-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2966	52	2026-06-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2967	52	2026-06-26	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2968	52	2026-06-26	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2969	52	2026-06-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2970	52	2026-06-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2971	52	2026-07-01	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2972	52	2026-07-01	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2973	52	2026-07-03	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2974	52	2026-07-03	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2975	52	2026-07-06	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2976	52	2026-07-06	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2977	52	2026-07-08	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2978	52	2026-07-08	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2979	52	2026-07-10	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2980	52	2026-07-10	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2981	52	2026-07-13	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2982	52	2026-07-13	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2983	52	2026-07-15	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2984	52	2026-07-15	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2985	52	2026-07-17	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2986	52	2026-07-17	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2987	52	2026-07-20	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2988	52	2026-07-20	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2989	52	2026-07-22	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2990	52	2026-07-22	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2991	52	2026-07-24	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2992	52	2026-07-24	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2993	52	2026-07-27	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2994	52	2026-07-27	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2995	52	2026-07-29	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2996	52	2026-07-29	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
2997	52	2026-07-31	Sáng	07:30:00	11:30:00	20	t	Đã duyệt	35
2998	52	2026-07-31	Chiều	13:30:00	17:00:00	20	t	Đã duyệt	35
\.


--
-- TOC entry 3894 (class 0 OID 17545)
-- Dependencies: 308
-- Data for Name: nguoi_dung; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nguoi_dung (so_dien_thoai, ho_ten, ngay_sinh, gioi_tinh, dia_chi, ma_dinh_danh, ngay_dang_ky, vai_tro, email, anh_dai_dien_url, nhom_mau, chieu_cao, can_nang, an_thong_tin) FROM stdin;
0775424043	Nguyễn Đức Vủ Bảo	2006-04-17	\N	\N	VXVgGmP5ooWaGZRnDW7YgFoTwM92	2026-05-24 03:11:52.536853	PATIENT	baondv@gmail.com		\N	\N	\N	f
0912345678	Nguyễn Bảo	2006-04-17	\N	\N	huSwmpeieResac1HQ3PpYX8xQlD3	2026-05-24 03:16:44.988006	patient	baodv@gmail.com		\N	\N	\N	f
0800000000	Nguyễn Thị Minh Thảo	\N	\N	\N	IteTq1wbgaWm9Xthun063URTFmJ3	2026-06-15 04:03:35.002117	DOCTOR	nguyenthịminhthao0bacsi@gmail.com	\N	\N	\N	\N	f
0123456789	Administrator	\N	\N	\N	F3gugPe2j1dEh1hDCPDShlRaGym2	2026-05-22 16:42:37.28295	ADMIN	admin@gmail.com	\N	\N	\N	\N	f
0989898989	Vũ Văn Hoè	\N	\N	\N	kFr2qB0TS9QzNlmZWhEaJPh8dsx1	2026-05-22 17:50:54.399669	doctor	vuvanhoe@gmail.com	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_8_93f2757a-e3ba-4fe0-bd12-e3d9abd66ba1.jpg	\N	\N	\N	f
0800000001	Nguyễn Thị Hoài An	\N	\N	\N	xLGIG09MPxXFhfJctyWD6NbGf1n2	2026-06-15 04:03:35.937773	DOCTOR	nguyenthịhoaian0bacsi@gmail.com	\N	\N	\N	\N	f
0800000002	Nguyễn Thành Tuấn	\N	\N	\N	3SX9eopimId1OWN2uxIydr4YJjv2	2026-06-15 04:03:36.820775	DOCTOR	nguyenthanhtuan0bacsi@gmail.com	\N	\N	\N	\N	f
0800000003	Võ Thị Trúc Phương	\N	\N	\N	1BOxrBcr9Ab2MXpXldrayLvFJQo2	2026-06-15 04:03:37.704863	DOCTOR	vothịtrucphuong0bacsi@gmail.com	\N	\N	\N	\N	f
0800000004	Trần Thái Hà	\N	\N	\N	ggNlAXgaQGNv0RHg4RFq5Y0KOi82	2026-06-15 04:03:38.63415	DOCTOR	tranthaiha0bacsi@gmail.com	\N	\N	\N	\N	f
0800000005	Võ Quang Trinh	\N	\N	\N	sPAlmrafDYbKcYqgZ2DJIXIFDGy2	2026-06-15 04:03:39.609673	DOCTOR	voquangtrinh0bacsi@gmail.com	\N	\N	\N	\N	f
0392749458	Võ Nhật Huy	2006-10-11	Nam	67 Nguyễ Thi, Hải Châu, Đà Nẵng	y9m4eSTSSxRSrp20FrPeUa9uUCw2	2026-05-22 18:01:14.298228	patient	vonhathuy@gmail.com	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/avatar_0392749458_480a5f06-1aa2-4518-a4a7-3a2e0d94a41d.jpg	O-	165	70	f
0979797979	Nguyễn Trần Trung	\N	\N	\N	FwpnTslh1SYYpWm6ysmoA9VNb4A3	2026-05-22 18:06:35.953414	doctor	nguyentrantrung@gmail.com	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779732292633.jpg	\N	\N	\N	f
0800000006	Hoàng Thanh Tuấn	\N	\N	\N	LoNBLlwDrqdAJqMlvd28d6COUCI3	2026-06-15 04:03:40.499479	DOCTOR	hoangthanhtuan0bacsi@gmail.com	\N	\N	\N	\N	f
0969696969	Trần Trọng Thắng	\N	\N	\N	12hlqNyPl1cp5eHWFpcvzkcyFwn2	2026-05-22 18:12:19.513424	doctor	trantrongthang@gmail.com	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779732645337.jpg	\N	\N	\N	f
0959595959	Dương Minh Trí	\N	\N	\N	KNWuO4vG1TdRHuKZTRxJ48geHJs2	2026-05-22 18:14:17.272243	doctor	duongminhtri@gmail.com	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779732786333.jpg	\N	\N	\N	f
0949494949	Nguyễn Văn Doanh	\N	\N	\N	alaEDHo7XrQbuwWy0vqGzDSuVxu2	2026-05-23 08:36:38.931972	doctor	nguyenvandoanh@gmail.com	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779783400685.jpg	\N	\N	\N	f
0939393939	Nguyễn Ảnh Đạt	\N	\N	\N	y2uOKeLP6FMLoY5f7HILqfQmvUu1	2026-05-23 08:37:26.457862	doctor	nguyenanhdat@gmail.com	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779784180033.jpg	\N	\N	\N	f
0929292929	Nguyễn Việt Đức	\N	\N	\N	9tTPBTJgTFcvX0iW89dBs7aNizQ2	2026-05-23 08:37:51.437879	doctor	nguyenvietduc@gmail.com	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779784498767.jpg	\N	\N	\N	f
0898989898	Hà Văn Quyết	\N	\N	\N	GA5DKv6kvLeUP9KxvOnvtudlqMq2	2026-05-23 08:40:38.339012	doctor	havanquyet@gmail.com	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779784750782.jpg	\N	\N	\N	f
0888888888	Thẩm Hoàng Hải	\N	\N	\N	Vy91HslOZ6VlK1ZtnwcWVlAP6vF3	2026-05-23 08:56:15.349446	doctor	thamhoanghai@gmail.com	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779785699783.jpg	\N	\N	\N	f
0878787878	Nguyễn Văn Quýnh	\N	\N	\N	uGNRENILM4S0DRtZ4DMDpP74wtl2	2026-05-23 08:59:43.242423	doctor	nguyenvanquynh@gmail.com	https://gqgrfvgzfnafnzsbiiid.supabase.co/storage/v1/object/public/avatars/doctor_avatar_1779785800874.jpg	\N	\N	\N	f
0800000007	Ngô Thu Lan	\N	\N	\N	BWEjqP5yZCgH346SfcWYHaSVLI62	2026-06-15 04:03:41.380513	DOCTOR	ngothulan0bacsi@gmail.com	\N	\N	\N	\N	f
0868686868	Huỳnh Thu Phúc	\N	\N	\N	CNsdpllCABRmxrpLIMMXyC4qUJH3	2026-05-23 10:30:16.443591	doctor	huynhthuphuc@gmail.com		\N	\N	\N	f
0800000008	Phan Hữu Tuấn	\N	\N	\N	4VIkSVi2NPYAsuA8sjYYK7Y07G32	2026-06-15 04:03:42.300256	DOCTOR	phanhuutuan0bacsi@gmail.com	\N	\N	\N	\N	f
0800000009	Hoàng Văn Trung	\N	\N	\N	UacEhacjTvhYuoMOh5Q6tQdhdCH3	2026-06-15 04:03:43.142297	DOCTOR	hoangvantrung0bacsi@gmail.com	\N	\N	\N	\N	f
0800000010	Trần Minh Phong	\N	\N	\N	jvRARF5aXyXIXB2UwKilBktVaZI2	2026-06-15 04:03:44.028707	DOCTOR	tranminhphong0bacsi@gmail.com	\N	\N	\N	\N	f
0800000011	Trần Tuấn Quân	\N	\N	\N	aEaFzFZ80vbekJDamqvjBQfk7GE3	2026-06-15 04:03:44.917972	DOCTOR	trantuanquan0bacsi@gmail.com	\N	\N	\N	\N	f
0800000012	Đặng Đức Phú	\N	\N	\N	apTmIABu0jhPnTkGBbd91ygcVqx1	2026-06-15 04:03:45.894072	DOCTOR	dangducphu0bacsi@gmail.com	\N	\N	\N	\N	f
0800000013	Vũ Văn Hòa	\N	\N	\N	9YaFwiu562PcFFC9sD6naZUnmsK2	2026-06-15 04:03:46.79827	DOCTOR	vuvanhoa0bacsi@gmail.com	\N	\N	\N	\N	f
0800000014	Phạm Minh Phương	\N	\N	\N	45v9mNqmgeV034iXp6Mp4yqE4Qs1	2026-06-15 04:03:47.725611	DOCTOR	phamminhphuong0bacsi@gmail.com	\N	\N	\N	\N	f
0800000015	Nguyễn Ngọc Phương	\N	\N	\N	9zPR2N5MspSBu5JWIy6clHfaAy52	2026-06-15 04:03:48.621844	DOCTOR	nguyenngocphuong0bacsi@gmail.com	\N	\N	\N	\N	f
0800000016	Dương Công Tiên	\N	\N	\N	mOREt66avrNM8xlFZPdJe3RsUPW2	2026-06-15 04:03:49.509371	DOCTOR	duongcongtien0bacsi@gmail.com	\N	\N	\N	\N	f
0800000017	Bùi Quang Toàn	\N	\N	\N	eAI7kyh0kBPP65RgX9yDgxuJjIO2	2026-06-15 04:03:50.408261	DOCTOR	buiquangtoan0bacsi@gmail.com	\N	\N	\N	\N	f
0800000018	Phạm Quang Kiên	\N	\N	\N	7itcLS9b07eLL5Ie3VFjx7K32dZ2	2026-06-15 04:03:51.278499	DOCTOR	phamquangkien0bacsi@gmail.com	\N	\N	\N	\N	f
0800000019	Nguyễn Văn Trang	\N	\N	\N	v1sntMAqBHh4QWzGJmIyXUaPs833	2026-06-15 04:03:52.199962	DOCTOR	nguyenvantrang0bacsi@gmail.com	\N	\N	\N	\N	f
0800000020	Đặng Hải Mai	\N	\N	\N	o8FodjJ5veRejgxvYzyHeVvsUhi1	2026-06-15 04:03:53.170482	DOCTOR	danghaimai0bacsi@gmail.com	\N	\N	\N	\N	f
0800000021	Lý Tuấn Long	\N	\N	\N	OgI8VKhDBHd7vRPAZlMgmdyu6NT2	2026-06-15 04:03:54.05235	DOCTOR	lytuanlong0bacsi@gmail.com	\N	\N	\N	\N	f
0800000022	Đỗ Thị Vân	\N	\N	\N	0bjUDlfNfzUr8HXtOX2hj6vefCw1	2026-06-15 04:03:54.973185	DOCTOR	dothịvan0bacsi@gmail.com	\N	\N	\N	\N	f
0800000023	Bùi Công Nhung	\N	\N	\N	KejqArIRTHhXp1o62spKoD7dbMn1	2026-06-15 04:03:55.905014	DOCTOR	buicongnhung0bacsi@gmail.com	\N	\N	\N	\N	f
0800000024	Lý Quang Trung	\N	\N	\N	xDumYAvQkaRLL1VjQQLeTQQIoSu2	2026-06-15 04:03:56.833592	DOCTOR	lyquangtrung0bacsi@gmail.com	\N	\N	\N	\N	f
0800000025	Nguyễn Thị Phú	\N	\N	\N	l20oCkOy4oQxsnDTCQilDzEt3Un1	2026-06-15 04:03:58.73645	DOCTOR	nguyenthịphu0bacsi@gmail.com	\N	\N	\N	\N	f
0800000026	Huỳnh Hoài Huy	\N	\N	\N	Sh3jYqkALfOuKI2vgnkLMTAUWbI3	2026-06-15 04:03:59.77121	DOCTOR	huynhhoaihuy0bacsi@gmail.com	\N	\N	\N	\N	f
0800000027	Dương Hữu Phúc	\N	\N	\N	79MRCICUaEhu3oc0UTT4VW9pRrz2	2026-06-15 04:04:00.641216	DOCTOR	duonghuuphuc0bacsi@gmail.com	\N	\N	\N	\N	f
0800000028	Nguyễn Hoài Hương	\N	\N	\N	wS4reO3q26PCR9rC4LbZDhvHf433	2026-06-15 04:04:01.573829	DOCTOR	nguyenhoaihuong0bacsi@gmail.com	\N	\N	\N	\N	f
0800000029	Huỳnh Thanh Lâm	\N	\N	\N	XevuklqKaiPKhCdNWMUVRkabNUJ2	2026-06-15 04:04:02.437935	DOCTOR	huynhthanhlam0bacsi@gmail.com	\N	\N	\N	\N	f
0800000030	Dương Văn Minh	\N	\N	\N	VKFvCJZKQQdLAiRvhWWT6ogTz172	2026-06-15 04:04:03.385358	DOCTOR	duongvanminh0bacsi@gmail.com	\N	\N	\N	\N	f
0800000032	Đặng Hoài Hà	\N	\N	\N	z6Fn30pBtuV8WCdq9h0UsEcOXRI3	2026-06-15 04:04:05.115187	DOCTOR	danghoaiha0bacsi@gmail.com	\N	\N	\N	\N	f
0800000034	Nguyễn Công Minh	\N	\N	\N	dNjR1BNFDSd7qJxrYIrzsA0S6tb2	2026-06-15 04:04:06.865541	DOCTOR	nguyencongminh0bacsi@gmail.com	\N	\N	\N	\N	f
0800000036	Lý Ngọc Bình	\N	\N	\N	78D901NxbMRFMk7LObuDGriX1Ug1	2026-06-15 04:04:08.87901	DOCTOR	lyngocbinh0bacsi@gmail.com	\N	\N	\N	\N	f
0800000038	Hoàng Công Tiên	\N	\N	\N	ASyJKOeUChPR8GMsTnNpHMh7ajD3	2026-06-15 04:04:10.731444	DOCTOR	hoangcongtien0bacsi@gmail.com	\N	\N	\N	\N	f
0800000040	Lê Hữu Lâm	\N	\N	\N	SU5nYrb63JVYgCHsFhpef28WEL33	2026-06-15 04:04:12.535382	DOCTOR	lehuulam0bacsi@gmail.com	\N	\N	\N	\N	f
0800000042	Hoàng Tuấn Thảo	\N	\N	\N	ccui9ZKXcpX9Vb8x6RNwhLXWydU2	2026-06-15 04:04:14.339417	DOCTOR	hoangtuanthao0bacsi@gmail.com	\N	\N	\N	\N	f
0800000044	Hoàng Tuấn Tiên	\N	\N	\N	I63Bz4aJAjdW44A1S9zNactl7c12	2026-06-15 04:04:16.242301	DOCTOR	hoangtuantien0bacsi@gmail.com	\N	\N	\N	\N	f
0800000046	Trần Hải Kiên	\N	\N	\N	MrO5vS946Ve9GflulIESZGvQ77J3	2026-06-15 04:04:18.006604	DOCTOR	tranhaikien0bacsi@gmail.com	\N	\N	\N	\N	f
0800000048	Hoàng Thu Thiên	\N	\N	\N	wMygXolbTfREXazM5F2LbRoufF62	2026-06-15 04:04:19.912482	DOCTOR	hoangthuthien0bacsi@gmail.com	\N	\N	\N	\N	f
0800000050	Hoàng Ngọc Quang	\N	\N	\N	HXd9DI7FnThh7C9icpNIaoaFKAv2	2026-06-15 04:04:21.634934	DOCTOR	hoangngocquang0bacsi@gmail.com	\N	\N	\N	\N	f
0800000052	Huỳnh Minh Hà	\N	\N	\N	WaOEetl7eydX0n9HuUhblp1g0NP2	2026-06-15 04:04:23.425117	DOCTOR	huynhminhha0bacsi@gmail.com	\N	\N	\N	\N	f
0800000054	Trần Hữu Tường	\N	\N	\N	GVNuFA48N3ONP8FDr6GYvgfFTa73	2026-06-15 04:04:25.284718	DOCTOR	tranhuutuong0bacsi@gmail.com	\N	\N	\N	\N	f
0800000031	Bùi Hữu Ngọc	\N	\N	\N	Hux1kTGYDTYhhvRGgp45Z4g8Fp42	2026-06-15 04:04:04.243544	DOCTOR	buihuungoc0bacsi@gmail.com	\N	\N	\N	\N	f
0800000033	Phạm Hữu Hiếu	\N	\N	\N	ey5qlOByyAd8aQbnLeZygLEfGjj1	2026-06-15 04:04:06.00487	DOCTOR	phamhuuhieu0bacsi@gmail.com	\N	\N	\N	\N	f
0800000037	Đỗ Minh Trinh	\N	\N	\N	KtTnfztocQdcm0kWXE98kprW7dx2	2026-06-15 04:04:09.8809	DOCTOR	dominhtrinh0bacsi@gmail.com	\N	\N	\N	\N	f
0800000039	Lê Thanh Hương	\N	\N	\N	4TDMlL7TOuOi4waeSsc5dBV2f623	2026-06-15 04:04:11.651261	DOCTOR	lethanhhuong0bacsi@gmail.com	\N	\N	\N	\N	f
0800000041	Lê Công Vinh	\N	\N	\N	ylmmLUlDlWeC3R4yRx6xRFMm6bj2	2026-06-15 04:04:13.448844	DOCTOR	lecongvinh0bacsi@gmail.com	\N	\N	\N	\N	f
0800000043	Trần Hoài Huy	\N	\N	\N	DVgRVVQX84REWzljQcfJyvZmuem1	2026-06-15 04:04:15.352559	DOCTOR	tranhoaihuy0bacsi@gmail.com	\N	\N	\N	\N	f
0800000045	Nguyễn Tuấn Nhân	\N	\N	\N	5ATKDWmkSLMqqWCJCpV5OoxAMV52	2026-06-15 04:04:17.139646	DOCTOR	nguyentuannhan0bacsi@gmail.com	\N	\N	\N	\N	f
0800000047	Phạm Hoài Tiên	\N	\N	\N	yY6p4mh1t8MfySRAiMGaHmB85Fx2	2026-06-15 04:04:19.032409	DOCTOR	phamhoaitien0bacsi@gmail.com	\N	\N	\N	\N	f
0800000049	Hồ Đức Hải	\N	\N	\N	owzPLLNflBMPc1ImmU7dvYsyBRZ2	2026-06-15 04:04:20.760299	DOCTOR	hoduchai0bacsi@gmail.com	\N	\N	\N	\N	f
0800000051	Ngô Ngọc Tú	\N	\N	\N	44q7DjlQx8T4tg95f1pf7gpetGq1	2026-06-15 04:04:22.533544	DOCTOR	ngongoctu0bacsi@gmail.com	\N	\N	\N	\N	f
0800000053	Nguyễn Thu Trung	\N	\N	\N	SHkt1VImVwgTYrLQxNpsVMsqVqN2	2026-06-15 04:04:24.310281	DOCTOR	nguyenthutrung0bacsi@gmail.com	\N	\N	\N	\N	f
0800000055	Hồ Minh Thịnh	\N	\N	\N	Yxzb1rPGMca6GQURfHUrcCA1LKc2	2026-06-15 04:04:26.201412	DOCTOR	hominhthịnh0bacsi@gmail.com	\N	\N	\N	\N	f
0800000056	Phan Thu Khánh	\N	\N	\N	zfgL4qKMWoRVBjREEBDJNq8arRI2	2026-06-15 04:04:27.09638	DOCTOR	phanthukhanh0bacsi@gmail.com	\N	\N	\N	\N	f
0800000057	Phan Hải Minh	\N	\N	\N	0GwM5aYeHWgSSvWX5kH7SOvtdw13	2026-06-15 04:04:28.03044	DOCTOR	phanhaiminh0bacsi@gmail.com	\N	\N	\N	\N	f
0800000035	Đặng Ngọc Thái	\N	\N	\N	H7pHGPDWd3NuGtdA8iauTlmwKDM2	2026-06-15 04:04:07.885276	DOCTOR	dangngocthai@gmail.com	\N	\N	\N	\N	f
\.


--
-- TOC entry 3904 (class 0 OID 17614)
-- Dependencies: 318
-- Data for Name: nhac_thuoc; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nhac_thuoc (ma_nhac_thuoc, so_dien_thoai_bn, ten_thuoc, lieu_luong, gio_nhac, ngay_bat_dau, ngay_ket_thuc, ghi_chu, dang_hoat_dong) FROM stdin;
\.


--
-- TOC entry 3910 (class 0 OID 18790)
-- Dependencies: 324
-- Data for Name: phong; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.phong (ma_phong, ten_phong, vi_tri, ma_khoa) FROM stdin;
5	Cơ Xương Khớp 1	Phòng 1 Tầng 1	10
6	Cơ Xương Khớp 2	Phòng 2 Tầng 1	10
7	Châm cứu 1 	Phòng 3 Tầng 1	17
8	Châm cứu 2	Phòng 4 Tầng 1	17
9	Chấn thương chỉnh hình 1	Phòng 5 Tầng 1	35
10	Chấn thương chỉnh hình 2	Phòng 6 Tầng 1	35
11	Phòng Nội khoa 1	Tầng 2	27
12	Phòng Nội khoa 2	Tầng 2	27
13	Phòng Nha khoa 1	Tầng 2	28
14	Phòng Nha khoa 2	Tầng 2	28
15	Phòng Tiểu đường - Nội tiết 1	Tầng 2	29
16	Phòng Tiểu đường - Nội tiết 2	Tầng 2	29
17	Phòng Phục hồi chức năng  1	Tầng 2	30
18	Phòng Phục hồi chức năng  2	Tầng 2	30
19	Phòng Tiêu hoá 1	Tầng 2	31
20	Phòng Tiêu hoá 2	Tầng 2	31
21	Phòng Ung bướu  1	Tầng 2	32
22	Phòng Ung bướu  2	Tầng 2	32
23	Phòng Tâm lý 1	Tầng 2	33
24	Phòng Tâm lý 2	Tầng 2	33
25	Phòng Vô sinh - Hiếm muộn 1	Tầng 2	34
26	Phòng Vô sinh - Hiếm muộn 2	Tầng 2	34
27	Phòng Thần kinh 1	Tầng 2	11
28	Phòng Thần kinh 2	Tầng 2	11
29	Phòng Tiêu hoá 1	Tầng 2	12
30	Phòng Tiêu hoá 2	Tầng 2	12
31	Phòng Tim mạch  1	Tầng 2	13
32	Phòng Tim mạch  2	Tầng 2	13
33	Phòng Tai Mũi Họng 1	Tầng 2	14
34	Phòng Tai Mũi Họng 2	Tầng 2	14
35	Phòng Cột sống 1	Tầng 2	15
36	Phòng Cột sống 2	Tầng 2	15
37	Phòng Y học Cổ truyền 1	Tầng 2	16
38	Phòng Y học Cổ truyền 2	Tầng 2	16
39	Phòng Sản Phụ  1	Tầng 2	18
40	Phòng Sản Phụ  2	Tầng 2	18
41	Phòng Siêu âm thai 1	Tầng 2	19
42	Phòng Siêu âm thai 2	Tầng 2	19
43	Phòng Nhi 1	Tầng 2	20
44	Phòng Nhi 2	Tầng 2	20
45	Phòng Da liễu  1	Tầng 2	21
46	Phòng Da liễu  2	Tầng 2	21
47	Phòng Di ứng 1	Tầng 2	22
48	Phòng Di ứng 2	Tầng 2	22
49	Phòng Mắt  1	Tầng 2	23
50	Phòng Mắt  2	Tầng 2	23
51	Phòng Hô hấp 1	Tầng 2	24
52	Phòng Hô hấp 2	Tầng 2	24
53	Phòng Ngoại thần kinh 1	Tầng 2	25
54	Phòng Ngoại thần kinh 2	Tầng 2	25
55	Phòng Thận - Tiết niệu 1	Tầng 2	26
56	Phòng Thận - Tiết niệu 2	Tầng 2	26
57	Phòng Ngoại khoa  1	Tầng 2	36
58	Phòng Ngoại khoa  2	Tầng 2	36
\.


--
-- TOC entry 3919 (class 0 OID 25420)
-- Dependencies: 333
-- Data for Name: thong_bao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.thong_bao (id, nguoi_nhan_id, vai_tro, tieu_de, noi_dung, loai, da_doc, created_at) FROM stdin;
15	8	DOCTOR	Lịch trực đã được duyệt ✅	Lịch trực ngày 2026-05-26, ca Sáng, phòng 5 đã được Admin duyệt.	SHIFT_APPROVED	f	2026-05-23 10:34:25.236558+00
16	8	DOCTOR	Lịch trực đã được duyệt ✅	Lịch trực ngày 2026-05-25, ca Sáng, phòng 5 đã được Admin duyệt.	SHIFT_APPROVED	f	2026-05-23 10:34:32.767253+00
17	8	DOCTOR	Lịch trực đã được duyệt ✅	Lịch trực ngày 2026-05-25, ca Chiều, phòng 5 đã được Admin duyệt.	SHIFT_APPROVED	f	2026-05-23 10:35:00.338892+00
18	8	DOCTOR	Lịch trực đã được duyệt ✅	Lịch trực ngày 2026-05-26, ca Chiều, phòng 5 đã được Admin duyệt.	SHIFT_APPROVED	f	2026-05-23 10:35:06.907744+00
19	8	DOCTOR	Lịch trực đã được duyệt ✅	Lịch trực ngày 2026-05-27, ca Sáng, phòng 5 đã được Admin duyệt.	SHIFT_APPROVED	f	2026-05-23 10:35:13.087947+00
20	8	DOCTOR	Lịch trực đã được duyệt ✅	Lịch trực ngày 2026-05-27, ca Chiều, phòng 5 đã được Admin duyệt.	SHIFT_APPROVED	f	2026-05-23 10:35:17.921945+00
21	8	DOCTOR	Lịch trực đã được duyệt ✅	Lịch trực ngày 2026-05-28, ca Sáng, phòng 5 đã được Admin duyệt.	SHIFT_APPROVED	f	2026-05-23 10:35:22.618745+00
22	8	DOCTOR	Lịch trực đã được duyệt ✅	Lịch trực ngày 2026-05-28, ca Chiều, phòng 5 đã được Admin duyệt.	SHIFT_APPROVED	f	2026-05-23 10:35:27.462472+00
23	8	DOCTOR	Lịch trực đã được duyệt ✅	Lịch trực ngày 2026-05-29, ca Sáng, phòng 5 đã được Admin duyệt.	SHIFT_APPROVED	f	2026-05-23 10:35:31.204503+00
24	8	DOCTOR	Lịch trực đã được duyệt ✅	Lịch trực ngày 2026-05-29, ca Chiều, phòng 5 đã được Admin duyệt.	SHIFT_APPROVED	f	2026-05-23 10:35:35.329626+00
27	9	DOCTOR	Lịch trực đã được duyệt ✅	Lịch trực ngày 2026-05-25, ca Sáng, phòng 6 đã được Admin duyệt.	SHIFT_APPROVED	f	2026-05-23 10:36:50.501199+00
28	9	DOCTOR	Lịch trực đã được duyệt ✅	Lịch trực ngày 2026-05-25, ca Chiều, phòng 6 đã được Admin duyệt.	SHIFT_APPROVED	f	2026-05-23 10:36:55.120588+00
29	8	DOCTOR	Bệnh nhân đặt lịch khám mới 🗓️	Bệnh nhân (0392749458) đã đặt lịch khám ngày 2026-05-25 lúc 07:00. Vui lòng kiểm tra danh sách khám.	APPOINTMENT_BOOKED	f	2026-05-23 10:37:52.747994+00
31	8	DOCTOR	Bệnh nhân đặt lịch khám mới 🗓️	Bệnh nhân (0392749458) đã đặt lịch khám ngày 2026-05-26 lúc 07:00. Vui lòng kiểm tra danh sách khám.	APPOINTMENT_BOOKED	f	2026-05-23 16:50:02.632302+00
5	ADMIN	ADMIN	Bác sĩ đăng kí lịch trực mới 📅	Vũ Văn Hoè đã đăng kí lịch trực ngày 2026-05-26, ca Sáng. Vui lòng kiểm tra và duyệt.	SHIFT_REGISTERED	t	2026-05-23 10:32:32.601728+00
6	ADMIN	ADMIN	Bác sĩ đăng kí lịch trực mới 📅	Vũ Văn Hoè đã đăng kí lịch trực ngày 2026-05-25, ca Sáng. Vui lòng kiểm tra và duyệt.	SHIFT_REGISTERED	t	2026-05-23 10:32:37.631018+00
7	ADMIN	ADMIN	Bác sĩ đăng kí lịch trực mới 📅	Vũ Văn Hoè đã đăng kí lịch trực ngày 2026-05-25, ca Chiều. Vui lòng kiểm tra và duyệt.	SHIFT_REGISTERED	t	2026-05-23 10:32:40.690409+00
8	ADMIN	ADMIN	Bác sĩ đăng kí lịch trực mới 📅	Vũ Văn Hoè đã đăng kí lịch trực ngày 2026-05-26, ca Chiều. Vui lòng kiểm tra và duyệt.	SHIFT_REGISTERED	t	2026-05-23 10:32:43.321859+00
9	ADMIN	ADMIN	Bác sĩ đăng kí lịch trực mới 📅	Vũ Văn Hoè đã đăng kí lịch trực ngày 2026-05-27, ca Sáng. Vui lòng kiểm tra và duyệt.	SHIFT_REGISTERED	t	2026-05-23 10:32:48.088986+00
30	0392749458	PATIENT	Đặt lịch khám thành công ✅	Lịch khám ngày 2026-05-25 lúc 07:00 đã được đặt thành công. Vui lòng có mặt đúng giờ.	APPOINTMENT_BOOKED	t	2026-05-23 10:37:52.864588+00
32	0392749458	PATIENT	Đặt lịch khám thành công ✅	Lịch khám ngày 2026-05-26 lúc 07:00 đã được đặt thành công. Vui lòng có mặt đúng giờ.	APPOINTMENT_BOOKED	t	2026-05-23 16:50:02.743199+00
10	ADMIN	ADMIN	Bác sĩ đăng kí lịch trực mới 📅	Vũ Văn Hoè đã đăng kí lịch trực ngày 2026-05-27, ca Chiều. Vui lòng kiểm tra và duyệt.	SHIFT_REGISTERED	t	2026-05-23 10:32:51.233524+00
11	ADMIN	ADMIN	Bác sĩ đăng kí lịch trực mới 📅	Vũ Văn Hoè đã đăng kí lịch trực ngày 2026-05-28, ca Sáng. Vui lòng kiểm tra và duyệt.	SHIFT_REGISTERED	t	2026-05-23 10:33:03.178042+00
12	ADMIN	ADMIN	Bác sĩ đăng kí lịch trực mới 📅	Vũ Văn Hoè đã đăng kí lịch trực ngày 2026-05-28, ca Chiều. Vui lòng kiểm tra và duyệt.	SHIFT_REGISTERED	t	2026-05-23 10:33:06.055277+00
13	ADMIN	ADMIN	Bác sĩ đăng kí lịch trực mới 📅	Vũ Văn Hoè đã đăng kí lịch trực ngày 2026-05-29, ca Sáng. Vui lòng kiểm tra và duyệt.	SHIFT_REGISTERED	t	2026-05-23 10:33:10.542092+00
14	ADMIN	ADMIN	Bác sĩ đăng kí lịch trực mới 📅	Vũ Văn Hoè đã đăng kí lịch trực ngày 2026-05-29, ca Chiều. Vui lòng kiểm tra và duyệt.	SHIFT_REGISTERED	t	2026-05-23 10:33:13.397147+00
25	ADMIN	ADMIN	Bác sĩ đăng kí lịch trực mới 📅	Nguyễn Trần Trung đã đăng kí lịch trực ngày 2026-05-25, ca Sáng. Vui lòng kiểm tra và duyệt.	SHIFT_REGISTERED	t	2026-05-23 10:36:10.144596+00
26	ADMIN	ADMIN	Bác sĩ đăng kí lịch trực mới 📅	Nguyễn Trần Trung đã đăng kí lịch trực ngày 2026-05-25, ca Chiều. Vui lòng kiểm tra và duyệt.	SHIFT_REGISTERED	t	2026-05-23 10:36:13.4755+00
33	14	DOCTOR	Lịch trực bị từ chối ❌	Lịch trực ngày 2026-05-28, ca Sáng đã bị Admin từ chối.	SHIFT_REJECTED	f	2026-06-15 04:47:59.818413+00
34	55	DOCTOR	Bệnh nhân đặt lịch khám mới 🗓️	Bệnh nhân (0392749458) đã đặt lịch khám ngày 2026-06-17 lúc 07:30. Vui lòng kiểm tra danh sách khám.	APPOINTMENT_BOOKED	f	2026-06-15 05:22:29.025451+00
36	8	DOCTOR	Bệnh nhân đặt lịch khám mới 🗓️	Bệnh nhân (0392749458) đã đặt lịch khám ngày 2026-06-19 lúc 07:30. Vui lòng kiểm tra danh sách khám.	APPOINTMENT_BOOKED	f	2026-06-16 13:02:01.997849+00
38	55	DOCTOR	Bệnh nhân đặt lịch khám mới 🗓️	Bệnh nhân (0392749458) đã đặt lịch khám ngày 2026-06-29 lúc 07:30. Vui lòng kiểm tra danh sách khám.	APPOINTMENT_BOOKED	f	2026-06-17 10:26:50.664442+00
40	8	DOCTOR	Bệnh nhân đặt lịch khám mới 🗓️	Bệnh nhân (0392749458) đã đặt lịch khám ngày 2026-06-29 lúc 07:30. Vui lòng kiểm tra danh sách khám.	APPOINTMENT_BOOKED	f	2026-06-17 10:27:17.985957+00
35	0392749458	PATIENT	Đặt lịch khám thành công ✅	Lịch khám ngày 2026-06-17 lúc 07:30 đã được đặt thành công. Vui lòng có mặt đúng giờ.	APPOINTMENT_BOOKED	t	2026-06-15 05:22:29.188604+00
37	0392749458	PATIENT	Đặt lịch khám thành công ✅	Lịch khám ngày 2026-06-19 lúc 07:30 đã được đặt thành công. Vui lòng có mặt đúng giờ.	APPOINTMENT_BOOKED	t	2026-06-16 13:02:02.120695+00
39	0392749458	PATIENT	Đặt lịch khám thành công ✅	Lịch khám ngày 2026-06-29 lúc 07:30 đã được đặt thành công. Vui lòng có mặt đúng giờ.	APPOINTMENT_BOOKED	t	2026-06-17 10:26:50.770844+00
41	0392749458	PATIENT	Đặt lịch khám thành công ✅	Lịch khám ngày 2026-06-29 lúc 07:30 đã được đặt thành công. Vui lòng có mặt đúng giờ.	APPOINTMENT_BOOKED	t	2026-06-17 10:27:18.106817+00
\.


--
-- TOC entry 3914 (class 0 OID 18951)
-- Dependencies: 328
-- Data for Name: trieu_chung_pho_bien; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trieu_chung_pho_bien (ma_trieu_chung, ten_trieu_chung, ma_khoa_lien_quan, tu_khoa) FROM stdin;
\.


--
-- TOC entry 3906 (class 0 OID 17629)
-- Dependencies: 320
-- Data for Name: tu_van_ai; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tu_van_ai (ma_tu_van, so_dien_thoai_bn, cau_hoi_nguoi_dung, phan_hoi_ai, ma_khoa_goi_y, do_tin_cay, anh_phan_tich_url, lich_su_hoi_thoai, ma_bac_si_goi_y, trang_thai, ngay_tao) FROM stdin;
\.


--
-- TOC entry 3972 (class 0 OID 0)
-- Dependencies: 311
-- Name: bac_si_ma_bac_si_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bac_si_ma_bac_si_seq', 76, true);


--
-- TOC entry 3973 (class 0 OID 0)
-- Dependencies: 325
-- Name: chi_tiet_don_thuoc_ma_chi_tiet_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chi_tiet_don_thuoc_ma_chi_tiet_seq', 15, true);


--
-- TOC entry 3974 (class 0 OID 0)
-- Dependencies: 309
-- Name: chuyen_khoa_ma_khoa_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chuyen_khoa_ma_khoa_seq', 36, true);


--
-- TOC entry 3975 (class 0 OID 0)
-- Dependencies: 334
-- Name: danh_gia_bac_si_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.danh_gia_bac_si_id_seq', 1, false);


--
-- TOC entry 3976 (class 0 OID 0)
-- Dependencies: 315
-- Name: don_thuoc_ma_don_thuoc_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.don_thuoc_ma_don_thuoc_seq', 8, true);


--
-- TOC entry 3977 (class 0 OID 0)
-- Dependencies: 329
-- Name: khoa_tu_khoa_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.khoa_tu_khoa_id_seq', 1, false);


--
-- TOC entry 3978 (class 0 OID 0)
-- Dependencies: 313
-- Name: lich_hen_ma_lich_hen_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lich_hen_ma_lich_hen_seq', 42, true);


--
-- TOC entry 3979 (class 0 OID 0)
-- Dependencies: 321
-- Name: lich_truc_ma_lich_truc_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lich_truc_ma_lich_truc_seq', 2998, true);


--
-- TOC entry 3980 (class 0 OID 0)
-- Dependencies: 317
-- Name: nhac_thuoc_ma_nhac_thuoc_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.nhac_thuoc_ma_nhac_thuoc_seq', 2, true);


--
-- TOC entry 3981 (class 0 OID 0)
-- Dependencies: 323
-- Name: phong_ma_phong_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.phong_ma_phong_seq', 58, true);


--
-- TOC entry 3982 (class 0 OID 0)
-- Dependencies: 332
-- Name: thong_bao_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.thong_bao_id_seq', 41, true);


--
-- TOC entry 3983 (class 0 OID 0)
-- Dependencies: 327
-- Name: trieu_chung_pho_bien_ma_trieu_chung_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.trieu_chung_pho_bien_ma_trieu_chung_seq', 1, false);


--
-- TOC entry 3984 (class 0 OID 0)
-- Dependencies: 319
-- Name: tu_van_ai_ma_tu_van_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tu_van_ai_ma_tu_van_seq', 1, false);


--
-- TOC entry 3713 (class 2606 OID 25383)
-- Name: ai_training_rules ai_training_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_training_rules
    ADD CONSTRAINT ai_training_rules_pkey PRIMARY KEY (rule_id);


--
-- TOC entry 3690 (class 2606 OID 17571)
-- Name: bac_si bac_si_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bac_si
    ADD CONSTRAINT bac_si_pkey PRIMARY KEY (ma_bac_si);


--
-- TOC entry 3706 (class 2606 OID 18855)
-- Name: chi_tiet_don_thuoc chi_tiet_don_thuoc_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chi_tiet_don_thuoc
    ADD CONSTRAINT chi_tiet_don_thuoc_pkey PRIMARY KEY (ma_chi_tiet);


--
-- TOC entry 3688 (class 2606 OID 17561)
-- Name: chuyen_khoa chuyen_khoa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chuyen_khoa
    ADD CONSTRAINT chuyen_khoa_pkey PRIMARY KEY (ma_khoa);


--
-- TOC entry 3717 (class 2606 OID 25483)
-- Name: danh_gia_bac_si danh_gia_bac_si_ma_bac_si_so_dien_thoai_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.danh_gia_bac_si
    ADD CONSTRAINT danh_gia_bac_si_ma_bac_si_so_dien_thoai_key UNIQUE (ma_bac_si, so_dien_thoai);


--
-- TOC entry 3719 (class 2606 OID 25481)
-- Name: danh_gia_bac_si danh_gia_bac_si_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.danh_gia_bac_si
    ADD CONSTRAINT danh_gia_bac_si_pkey PRIMARY KEY (id);


--
-- TOC entry 3694 (class 2606 OID 17607)
-- Name: don_thuoc don_thuoc_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.don_thuoc
    ADD CONSTRAINT don_thuoc_pkey PRIMARY KEY (ma_don_thuoc);


--
-- TOC entry 3711 (class 2606 OID 25368)
-- Name: khoa_tu_khoa khoa_tu_khoa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.khoa_tu_khoa
    ADD CONSTRAINT khoa_tu_khoa_pkey PRIMARY KEY (id);


--
-- TOC entry 3692 (class 2606 OID 17587)
-- Name: lich_hen lich_hen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lich_hen
    ADD CONSTRAINT lich_hen_pkey PRIMARY KEY (ma_lich_hen);


--
-- TOC entry 3700 (class 2606 OID 18780)
-- Name: lich_truc lich_truc_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lich_truc
    ADD CONSTRAINT lich_truc_pkey PRIMARY KEY (ma_lich_truc);


--
-- TOC entry 3686 (class 2606 OID 17552)
-- Name: nguoi_dung nguoi_dung_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nguoi_dung
    ADD CONSTRAINT nguoi_dung_pkey PRIMARY KEY (so_dien_thoai);


--
-- TOC entry 3696 (class 2606 OID 17622)
-- Name: nhac_thuoc nhac_thuoc_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nhac_thuoc
    ADD CONSTRAINT nhac_thuoc_pkey PRIMARY KEY (ma_nhac_thuoc);


--
-- TOC entry 3704 (class 2606 OID 18797)
-- Name: phong phong_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.phong
    ADD CONSTRAINT phong_pkey PRIMARY KEY (ma_phong);


--
-- TOC entry 3715 (class 2606 OID 25430)
-- Name: thong_bao thong_bao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.thong_bao
    ADD CONSTRAINT thong_bao_pkey PRIMARY KEY (id);


--
-- TOC entry 3708 (class 2606 OID 18958)
-- Name: trieu_chung_pho_bien trieu_chung_pho_bien_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trieu_chung_pho_bien
    ADD CONSTRAINT trieu_chung_pho_bien_pkey PRIMARY KEY (ma_trieu_chung);


--
-- TOC entry 3698 (class 2606 OID 17636)
-- Name: tu_van_ai tu_van_ai_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tu_van_ai
    ADD CONSTRAINT tu_van_ai_pkey PRIMARY KEY (ma_tu_van);


--
-- TOC entry 3702 (class 2606 OID 18782)
-- Name: lich_truc unique_lich_truc_bac_si; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lich_truc
    ADD CONSTRAINT unique_lich_truc_bac_si UNIQUE (ma_bac_si, ngay_truc, gio_bat_dau);


--
-- TOC entry 3709 (class 1259 OID 25374)
-- Name: idx_khoa_tu_khoa_ma; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_khoa_tu_khoa_ma ON public.khoa_tu_khoa USING btree (ma_khoa);


--
-- TOC entry 3736 (class 2620 OID 25495)
-- Name: danh_gia_bac_si trg_update_doctor_rating; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_doctor_rating AFTER INSERT OR DELETE OR UPDATE ON public.danh_gia_bac_si FOR EACH ROW EXECUTE FUNCTION public.update_doctor_rating();


--
-- TOC entry 3720 (class 2606 OID 17572)
-- Name: bac_si bac_si_ma_khoa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bac_si
    ADD CONSTRAINT bac_si_ma_khoa_fkey FOREIGN KEY (ma_khoa) REFERENCES public.chuyen_khoa(ma_khoa);


--
-- TOC entry 3732 (class 2606 OID 18856)
-- Name: chi_tiet_don_thuoc chi_tiet_don_thuoc_ma_don_thuoc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chi_tiet_don_thuoc
    ADD CONSTRAINT chi_tiet_don_thuoc_ma_don_thuoc_fkey FOREIGN KEY (ma_don_thuoc) REFERENCES public.don_thuoc(ma_don_thuoc) ON DELETE CASCADE;


--
-- TOC entry 3734 (class 2606 OID 25484)
-- Name: danh_gia_bac_si danh_gia_bac_si_ma_bac_si_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.danh_gia_bac_si
    ADD CONSTRAINT danh_gia_bac_si_ma_bac_si_fkey FOREIGN KEY (ma_bac_si) REFERENCES public.bac_si(ma_bac_si) ON DELETE CASCADE;


--
-- TOC entry 3735 (class 2606 OID 25489)
-- Name: danh_gia_bac_si danh_gia_bac_si_so_dien_thoai_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.danh_gia_bac_si
    ADD CONSTRAINT danh_gia_bac_si_so_dien_thoai_fkey FOREIGN KEY (so_dien_thoai) REFERENCES public.nguoi_dung(so_dien_thoai) ON DELETE CASCADE;


--
-- TOC entry 3725 (class 2606 OID 17608)
-- Name: don_thuoc don_thuoc_ma_lich_hen_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.don_thuoc
    ADD CONSTRAINT don_thuoc_ma_lich_hen_fkey FOREIGN KEY (ma_lich_hen) REFERENCES public.lich_hen(ma_lich_hen);


--
-- TOC entry 3729 (class 2606 OID 18783)
-- Name: lich_truc fk_bac_si_lich_truc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lich_truc
    ADD CONSTRAINT fk_bac_si_lich_truc FOREIGN KEY (ma_bac_si) REFERENCES public.bac_si(ma_bac_si) ON DELETE CASCADE;


--
-- TOC entry 3721 (class 2606 OID 18803)
-- Name: bac_si fk_bacsi_phong; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bac_si
    ADD CONSTRAINT fk_bacsi_phong FOREIGN KEY (ma_phong_chinh) REFERENCES public.phong(ma_phong);


--
-- TOC entry 3731 (class 2606 OID 18798)
-- Name: phong fk_khoa_phong; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.phong
    ADD CONSTRAINT fk_khoa_phong FOREIGN KEY (ma_khoa) REFERENCES public.chuyen_khoa(ma_khoa) ON DELETE CASCADE;


--
-- TOC entry 3730 (class 2606 OID 18915)
-- Name: lich_truc fk_lich_truc_phong; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lich_truc
    ADD CONSTRAINT fk_lich_truc_phong FOREIGN KEY (ma_phong) REFERENCES public.phong(ma_phong);


--
-- TOC entry 3722 (class 2606 OID 18808)
-- Name: lich_hen fk_lichhen_phong; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lich_hen
    ADD CONSTRAINT fk_lichhen_phong FOREIGN KEY (ma_phong) REFERENCES public.phong(ma_phong);


--
-- TOC entry 3733 (class 2606 OID 25369)
-- Name: khoa_tu_khoa khoa_tu_khoa_ma_khoa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.khoa_tu_khoa
    ADD CONSTRAINT khoa_tu_khoa_ma_khoa_fkey FOREIGN KEY (ma_khoa) REFERENCES public.chuyen_khoa(ma_khoa) ON DELETE CASCADE;


--
-- TOC entry 3723 (class 2606 OID 17593)
-- Name: lich_hen lich_hen_ma_bac_si_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lich_hen
    ADD CONSTRAINT lich_hen_ma_bac_si_fkey FOREIGN KEY (ma_bac_si) REFERENCES public.bac_si(ma_bac_si);


--
-- TOC entry 3724 (class 2606 OID 25456)
-- Name: lich_hen lich_hen_so_dien_thoai_bn_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lich_hen
    ADD CONSTRAINT lich_hen_so_dien_thoai_bn_fkey FOREIGN KEY (so_dien_thoai_bn) REFERENCES public.nguoi_dung(so_dien_thoai) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3726 (class 2606 OID 25461)
-- Name: nhac_thuoc nhac_thuoc_so_dien_thoai_bn_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nhac_thuoc
    ADD CONSTRAINT nhac_thuoc_so_dien_thoai_bn_fkey FOREIGN KEY (so_dien_thoai_bn) REFERENCES public.nguoi_dung(so_dien_thoai) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3727 (class 2606 OID 17642)
-- Name: tu_van_ai tu_van_ai_ma_khoa_goi_y_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tu_van_ai
    ADD CONSTRAINT tu_van_ai_ma_khoa_goi_y_fkey FOREIGN KEY (ma_khoa_goi_y) REFERENCES public.chuyen_khoa(ma_khoa);


--
-- TOC entry 3728 (class 2606 OID 17637)
-- Name: tu_van_ai tu_van_ai_so_dien_thoai_bn_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tu_van_ai
    ADD CONSTRAINT tu_van_ai_so_dien_thoai_bn_fkey FOREIGN KEY (so_dien_thoai_bn) REFERENCES public.nguoi_dung(so_dien_thoai);


--
-- TOC entry 3888 (class 3256 OID 18862)
-- Name: chi_tiet_don_thuoc Allow insert chi_tiet_don_thuoc; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow insert chi_tiet_don_thuoc" ON public.chi_tiet_don_thuoc FOR INSERT WITH CHECK (true);


--
-- TOC entry 3889 (class 3256 OID 25385)
-- Name: ai_training_rules Allow read ai_training_rules; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow read ai_training_rules" ON public.ai_training_rules FOR SELECT USING (true);


--
-- TOC entry 3887 (class 3256 OID 18861)
-- Name: chi_tiet_don_thuoc Allow read chi_tiet_don_thuoc; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow read chi_tiet_don_thuoc" ON public.chi_tiet_don_thuoc FOR SELECT USING (true);


--
-- TOC entry 3892 (class 3256 OID 25433)
-- Name: thong_bao Cho phép cập nhật thông báo; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Cho phép cập nhật thông báo" ON public.thong_bao FOR UPDATE USING (true);


--
-- TOC entry 3890 (class 3256 OID 25431)
-- Name: thong_bao Cho phép người dùng xem thông báo của mình; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Cho phép người dùng xem thông báo của mình" ON public.thong_bao FOR SELECT USING (true);


--
-- TOC entry 3891 (class 3256 OID 25432)
-- Name: thong_bao Cho phép thêm thông báo; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Cho phép thêm thông báo" ON public.thong_bao FOR INSERT WITH CHECK (true);


--
-- TOC entry 3886 (class 0 OID 25375)
-- Dependencies: 331
-- Name: ai_training_rules; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ai_training_rules ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3885 (class 0 OID 18848)
-- Dependencies: 326
-- Name: chi_tiet_don_thuoc; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.chi_tiet_don_thuoc ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3928 (class 0 OID 0)
-- Dependencies: 43
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- TOC entry 3929 (class 0 OID 0)
-- Dependencies: 442
-- Name: FUNCTION update_doctor_rating(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_doctor_rating() TO anon;
GRANT ALL ON FUNCTION public.update_doctor_rating() TO authenticated;
GRANT ALL ON FUNCTION public.update_doctor_rating() TO service_role;


--
-- TOC entry 3930 (class 0 OID 0)
-- Dependencies: 331
-- Name: TABLE ai_training_rules; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ai_training_rules TO anon;
GRANT ALL ON TABLE public.ai_training_rules TO authenticated;
GRANT ALL ON TABLE public.ai_training_rules TO service_role;


--
-- TOC entry 3931 (class 0 OID 0)
-- Dependencies: 312
-- Name: TABLE bac_si; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.bac_si TO anon;
GRANT ALL ON TABLE public.bac_si TO authenticated;
GRANT ALL ON TABLE public.bac_si TO service_role;


--
-- TOC entry 3933 (class 0 OID 0)
-- Dependencies: 311
-- Name: SEQUENCE bac_si_ma_bac_si_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.bac_si_ma_bac_si_seq TO anon;
GRANT ALL ON SEQUENCE public.bac_si_ma_bac_si_seq TO authenticated;
GRANT ALL ON SEQUENCE public.bac_si_ma_bac_si_seq TO service_role;


--
-- TOC entry 3934 (class 0 OID 0)
-- Dependencies: 326
-- Name: TABLE chi_tiet_don_thuoc; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.chi_tiet_don_thuoc TO anon;
GRANT ALL ON TABLE public.chi_tiet_don_thuoc TO authenticated;
GRANT ALL ON TABLE public.chi_tiet_don_thuoc TO service_role;


--
-- TOC entry 3936 (class 0 OID 0)
-- Dependencies: 325
-- Name: SEQUENCE chi_tiet_don_thuoc_ma_chi_tiet_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.chi_tiet_don_thuoc_ma_chi_tiet_seq TO anon;
GRANT ALL ON SEQUENCE public.chi_tiet_don_thuoc_ma_chi_tiet_seq TO authenticated;
GRANT ALL ON SEQUENCE public.chi_tiet_don_thuoc_ma_chi_tiet_seq TO service_role;


--
-- TOC entry 3937 (class 0 OID 0)
-- Dependencies: 310
-- Name: TABLE chuyen_khoa; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.chuyen_khoa TO anon;
GRANT ALL ON TABLE public.chuyen_khoa TO authenticated;
GRANT ALL ON TABLE public.chuyen_khoa TO service_role;


--
-- TOC entry 3939 (class 0 OID 0)
-- Dependencies: 309
-- Name: SEQUENCE chuyen_khoa_ma_khoa_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.chuyen_khoa_ma_khoa_seq TO anon;
GRANT ALL ON SEQUENCE public.chuyen_khoa_ma_khoa_seq TO authenticated;
GRANT ALL ON SEQUENCE public.chuyen_khoa_ma_khoa_seq TO service_role;


--
-- TOC entry 3940 (class 0 OID 0)
-- Dependencies: 335
-- Name: TABLE danh_gia_bac_si; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.danh_gia_bac_si TO anon;
GRANT ALL ON TABLE public.danh_gia_bac_si TO authenticated;
GRANT ALL ON TABLE public.danh_gia_bac_si TO service_role;


--
-- TOC entry 3942 (class 0 OID 0)
-- Dependencies: 334
-- Name: SEQUENCE danh_gia_bac_si_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.danh_gia_bac_si_id_seq TO anon;
GRANT ALL ON SEQUENCE public.danh_gia_bac_si_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.danh_gia_bac_si_id_seq TO service_role;


--
-- TOC entry 3943 (class 0 OID 0)
-- Dependencies: 316
-- Name: TABLE don_thuoc; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.don_thuoc TO anon;
GRANT ALL ON TABLE public.don_thuoc TO authenticated;
GRANT ALL ON TABLE public.don_thuoc TO service_role;


--
-- TOC entry 3945 (class 0 OID 0)
-- Dependencies: 315
-- Name: SEQUENCE don_thuoc_ma_don_thuoc_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.don_thuoc_ma_don_thuoc_seq TO anon;
GRANT ALL ON SEQUENCE public.don_thuoc_ma_don_thuoc_seq TO authenticated;
GRANT ALL ON SEQUENCE public.don_thuoc_ma_don_thuoc_seq TO service_role;


--
-- TOC entry 3946 (class 0 OID 0)
-- Dependencies: 330
-- Name: TABLE khoa_tu_khoa; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.khoa_tu_khoa TO anon;
GRANT ALL ON TABLE public.khoa_tu_khoa TO authenticated;
GRANT ALL ON TABLE public.khoa_tu_khoa TO service_role;


--
-- TOC entry 3948 (class 0 OID 0)
-- Dependencies: 329
-- Name: SEQUENCE khoa_tu_khoa_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.khoa_tu_khoa_id_seq TO anon;
GRANT ALL ON SEQUENCE public.khoa_tu_khoa_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.khoa_tu_khoa_id_seq TO service_role;


--
-- TOC entry 3949 (class 0 OID 0)
-- Dependencies: 314
-- Name: TABLE lich_hen; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.lich_hen TO anon;
GRANT ALL ON TABLE public.lich_hen TO authenticated;
GRANT ALL ON TABLE public.lich_hen TO service_role;


--
-- TOC entry 3951 (class 0 OID 0)
-- Dependencies: 313
-- Name: SEQUENCE lich_hen_ma_lich_hen_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.lich_hen_ma_lich_hen_seq TO anon;
GRANT ALL ON SEQUENCE public.lich_hen_ma_lich_hen_seq TO authenticated;
GRANT ALL ON SEQUENCE public.lich_hen_ma_lich_hen_seq TO service_role;


--
-- TOC entry 3953 (class 0 OID 0)
-- Dependencies: 322
-- Name: TABLE lich_truc; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.lich_truc TO anon;
GRANT ALL ON TABLE public.lich_truc TO authenticated;
GRANT ALL ON TABLE public.lich_truc TO service_role;


--
-- TOC entry 3955 (class 0 OID 0)
-- Dependencies: 321
-- Name: SEQUENCE lich_truc_ma_lich_truc_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.lich_truc_ma_lich_truc_seq TO anon;
GRANT ALL ON SEQUENCE public.lich_truc_ma_lich_truc_seq TO authenticated;
GRANT ALL ON SEQUENCE public.lich_truc_ma_lich_truc_seq TO service_role;


--
-- TOC entry 3956 (class 0 OID 0)
-- Dependencies: 308
-- Name: TABLE nguoi_dung; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.nguoi_dung TO anon;
GRANT ALL ON TABLE public.nguoi_dung TO authenticated;
GRANT ALL ON TABLE public.nguoi_dung TO service_role;


--
-- TOC entry 3957 (class 0 OID 0)
-- Dependencies: 318
-- Name: TABLE nhac_thuoc; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.nhac_thuoc TO anon;
GRANT ALL ON TABLE public.nhac_thuoc TO authenticated;
GRANT ALL ON TABLE public.nhac_thuoc TO service_role;


--
-- TOC entry 3959 (class 0 OID 0)
-- Dependencies: 317
-- Name: SEQUENCE nhac_thuoc_ma_nhac_thuoc_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.nhac_thuoc_ma_nhac_thuoc_seq TO anon;
GRANT ALL ON SEQUENCE public.nhac_thuoc_ma_nhac_thuoc_seq TO authenticated;
GRANT ALL ON SEQUENCE public.nhac_thuoc_ma_nhac_thuoc_seq TO service_role;


--
-- TOC entry 3960 (class 0 OID 0)
-- Dependencies: 324
-- Name: TABLE phong; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.phong TO anon;
GRANT ALL ON TABLE public.phong TO authenticated;
GRANT ALL ON TABLE public.phong TO service_role;


--
-- TOC entry 3962 (class 0 OID 0)
-- Dependencies: 323
-- Name: SEQUENCE phong_ma_phong_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.phong_ma_phong_seq TO anon;
GRANT ALL ON SEQUENCE public.phong_ma_phong_seq TO authenticated;
GRANT ALL ON SEQUENCE public.phong_ma_phong_seq TO service_role;


--
-- TOC entry 3963 (class 0 OID 0)
-- Dependencies: 333
-- Name: TABLE thong_bao; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.thong_bao TO anon;
GRANT ALL ON TABLE public.thong_bao TO authenticated;
GRANT ALL ON TABLE public.thong_bao TO service_role;


--
-- TOC entry 3965 (class 0 OID 0)
-- Dependencies: 332
-- Name: SEQUENCE thong_bao_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.thong_bao_id_seq TO anon;
GRANT ALL ON SEQUENCE public.thong_bao_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.thong_bao_id_seq TO service_role;


--
-- TOC entry 3966 (class 0 OID 0)
-- Dependencies: 328
-- Name: TABLE trieu_chung_pho_bien; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.trieu_chung_pho_bien TO anon;
GRANT ALL ON TABLE public.trieu_chung_pho_bien TO authenticated;
GRANT ALL ON TABLE public.trieu_chung_pho_bien TO service_role;


--
-- TOC entry 3968 (class 0 OID 0)
-- Dependencies: 327
-- Name: SEQUENCE trieu_chung_pho_bien_ma_trieu_chung_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.trieu_chung_pho_bien_ma_trieu_chung_seq TO anon;
GRANT ALL ON SEQUENCE public.trieu_chung_pho_bien_ma_trieu_chung_seq TO authenticated;
GRANT ALL ON SEQUENCE public.trieu_chung_pho_bien_ma_trieu_chung_seq TO service_role;


--
-- TOC entry 3969 (class 0 OID 0)
-- Dependencies: 320
-- Name: TABLE tu_van_ai; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.tu_van_ai TO anon;
GRANT ALL ON TABLE public.tu_van_ai TO authenticated;
GRANT ALL ON TABLE public.tu_van_ai TO service_role;


--
-- TOC entry 3971 (class 0 OID 0)
-- Dependencies: 319
-- Name: SEQUENCE tu_van_ai_ma_tu_van_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.tu_van_ai_ma_tu_van_seq TO anon;
GRANT ALL ON SEQUENCE public.tu_van_ai_ma_tu_van_seq TO authenticated;
GRANT ALL ON SEQUENCE public.tu_van_ai_ma_tu_van_seq TO service_role;


--
-- TOC entry 2410 (class 826 OID 16494)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 2411 (class 826 OID 16495)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 2409 (class 826 OID 16493)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 2413 (class 826 OID 16497)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 2408 (class 826 OID 16492)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- TOC entry 2412 (class 826 OID 16496)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO service_role;


-- Completed on 2026-06-17 18:51:26

--
-- PostgreSQL database dump complete
--

