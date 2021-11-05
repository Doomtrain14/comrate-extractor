--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: comrate_extractor; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE comrate_extractor WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


ALTER DATABASE comrate_extractor OWNER TO postgres;

\connect comrate_extractor

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: sheet; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sheet (
    id integer NOT NULL,
    name text
);

INSERT INTO sheet (name) VALUES ('income');
INSERT INTO sheet (name) VALUES ('balance');
INSERT INTO sheet (name) VALUES ('cashflow');

ALTER TABLE public.sheet OWNER TO postgres;

--
-- Name: sheet_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sheet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sheet_id_seq OWNER TO postgres;

--
-- Name: sheet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE sheet_id_seq OWNED BY sheet.id;


--
-- Name: sheet_param; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sheet_param (
    id integer NOT NULL,
    sheet_id integer,
    name text,
    sign character(1),
    collect boolean
);


ALTER TABLE public.sheet_param OWNER TO postgres;

--
-- Name: sheet_param_eqn; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sheet_param_eqn (
    id integer NOT NULL,
    param_id integer,
    eqn_type text,
    num_comps integer
);


ALTER TABLE public.sheet_param_eqn OWNER TO postgres;

--
-- Name: sheet_param_eqn_comp; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sheet_param_eqn_comp (
    id integer NOT NULL,
    eqn_id integer,
    param_id integer
);


ALTER TABLE public.sheet_param_eqn_comp OWNER TO postgres;

--
-- Name: sheet_param_eqn_comp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sheet_param_eqn_comp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sheet_param_eqn_comp_id_seq OWNER TO postgres;

--
-- Name: sheet_param_eqn_comp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE sheet_param_eqn_comp_id_seq OWNED BY sheet_param_eqn_comp.id;


--
-- Name: sheet_param_eqn_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sheet_param_eqn_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sheet_param_eqn_id_seq OWNER TO postgres;

--
-- Name: sheet_param_eqn_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE sheet_param_eqn_id_seq OWNED BY sheet_param_eqn.id;


--
-- Name: sheet_param_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sheet_param_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sheet_param_id_seq OWNER TO postgres;

--
-- Name: sheet_param_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE sheet_param_id_seq OWNED BY sheet_param.id;


--
-- Name: sheet_param_synonym; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sheet_param_synonym (
    id integer NOT NULL,
    sheet_param_id integer,
    synonym text
);


ALTER TABLE public.sheet_param_synonym OWNER TO postgres;

--
-- Name: sheet_param_synonym_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sheet_param_synonym_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sheet_param_synonym_id_seq OWNER TO postgres;

--
-- Name: sheet_param_synonym_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE sheet_param_synonym_id_seq OWNED BY sheet_param_synonym.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sheet ALTER COLUMN id SET DEFAULT nextval('sheet_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sheet_param ALTER COLUMN id SET DEFAULT nextval('sheet_param_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sheet_param_eqn ALTER COLUMN id SET DEFAULT nextval('sheet_param_eqn_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sheet_param_eqn_comp ALTER COLUMN id SET DEFAULT nextval('sheet_param_eqn_comp_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sheet_param_synonym ALTER COLUMN id SET DEFAULT nextval('sheet_param_synonym_id_seq'::regclass);


--
-- Name: sheet_param_eqn_comp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sheet_param_eqn_comp
    ADD CONSTRAINT sheet_param_eqn_comp_pkey PRIMARY KEY (id);


--
-- Name: sheet_param_eqn_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sheet_param_eqn
    ADD CONSTRAINT sheet_param_eqn_pkey PRIMARY KEY (id);


--
-- Name: sheet_param_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sheet_param
    ADD CONSTRAINT sheet_param_pkey PRIMARY KEY (id);


--
-- Name: sheet_param_synonym_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sheet_param_synonym
    ADD CONSTRAINT sheet_param_synonym_pkey PRIMARY KEY (id);


--
-- Name: sheet_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sheet
    ADD CONSTRAINT sheet_pkey PRIMARY KEY (id);


--
-- Name: sheet_param_eqn_comp_eqn_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sheet_param_eqn_comp
    ADD CONSTRAINT sheet_param_eqn_comp_eqn_id_fkey FOREIGN KEY (eqn_id) REFERENCES sheet_param_eqn(id);


--
-- Name: sheet_param_eqn_comp_param_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sheet_param_eqn_comp
    ADD CONSTRAINT sheet_param_eqn_comp_param_id_fkey FOREIGN KEY (param_id) REFERENCES sheet_param(id);


--
-- Name: sheet_param_eqn_param_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sheet_param_eqn
    ADD CONSTRAINT sheet_param_eqn_param_id_fkey FOREIGN KEY (param_id) REFERENCES sheet_param(id);


--
-- Name: sheet_param_sheet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sheet_param
    ADD CONSTRAINT sheet_param_sheet_id_fkey FOREIGN KEY (sheet_id) REFERENCES sheet(id);


--
-- Name: sheet_param_synonym_sheet_param_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sheet_param_synonym
    ADD CONSTRAINT sheet_param_synonym_sheet_param_id_fkey FOREIGN KEY (sheet_param_id) REFERENCES sheet_param(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: sheet; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE sheet FROM PUBLIC;
REVOKE ALL ON TABLE sheet FROM postgres;
GRANT ALL ON TABLE sheet TO postgres;
GRANT ALL ON TABLE sheet TO comrate_user;


--
-- Name: sheet_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE sheet_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sheet_id_seq FROM postgres;
GRANT ALL ON SEQUENCE sheet_id_seq TO postgres;
GRANT ALL ON SEQUENCE sheet_id_seq TO comrate_user;


--
-- Name: sheet_param; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE sheet_param FROM PUBLIC;
REVOKE ALL ON TABLE sheet_param FROM postgres;
GRANT ALL ON TABLE sheet_param TO postgres;
GRANT ALL ON TABLE sheet_param TO comrate_user;


--
-- Name: sheet_param_eqn; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE sheet_param_eqn FROM PUBLIC;
REVOKE ALL ON TABLE sheet_param_eqn FROM postgres;
GRANT ALL ON TABLE sheet_param_eqn TO postgres;
GRANT ALL ON TABLE sheet_param_eqn TO comrate_user;


--
-- Name: sheet_param_eqn_comp; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE sheet_param_eqn_comp FROM PUBLIC;
REVOKE ALL ON TABLE sheet_param_eqn_comp FROM postgres;
GRANT ALL ON TABLE sheet_param_eqn_comp TO postgres;
GRANT ALL ON TABLE sheet_param_eqn_comp TO comrate_user;


--
-- Name: sheet_param_eqn_comp_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE sheet_param_eqn_comp_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sheet_param_eqn_comp_id_seq FROM postgres;
GRANT ALL ON SEQUENCE sheet_param_eqn_comp_id_seq TO postgres;
GRANT ALL ON SEQUENCE sheet_param_eqn_comp_id_seq TO comrate_user;


--
-- Name: sheet_param_eqn_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE sheet_param_eqn_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sheet_param_eqn_id_seq FROM postgres;
GRANT ALL ON SEQUENCE sheet_param_eqn_id_seq TO postgres;
GRANT ALL ON SEQUENCE sheet_param_eqn_id_seq TO comrate_user;


--
-- Name: sheet_param_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE sheet_param_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sheet_param_id_seq FROM postgres;
GRANT ALL ON SEQUENCE sheet_param_id_seq TO postgres;
GRANT ALL ON SEQUENCE sheet_param_id_seq TO comrate_user;


--
-- Name: sheet_param_synonym; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE sheet_param_synonym FROM PUBLIC;
REVOKE ALL ON TABLE sheet_param_synonym FROM postgres;
GRANT ALL ON TABLE sheet_param_synonym TO postgres;
GRANT ALL ON TABLE sheet_param_synonym TO comrate_user;


--
-- Name: sheet_param_synonym_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE sheet_param_synonym_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE sheet_param_synonym_id_seq FROM postgres;
GRANT ALL ON SEQUENCE sheet_param_synonym_id_seq TO postgres;
GRANT ALL ON SEQUENCE sheet_param_synonym_id_seq TO comrate_user;


--
-- PostgreSQL database dump complete
--

