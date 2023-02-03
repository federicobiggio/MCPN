--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3
-- Dumped by pg_dump version 14.1

-- Started on 2022-01-14 09:27:31 CET

SET role = opentheso;
SET schema 'public';

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
-- TOC entry 2 (class 3079 OID 43944)
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--


--
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!! Important !!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- pour créer ces extensions, il faut avoir des privilèves Superuser sur Postgres
--
CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;
COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;
COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';
--
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!! Fin !!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



--
-- TOC entry 759 (class 1247 OID 44031)
-- Name: alignement_format; Type: TYPE; Schema: public; Owner: opentheso
--

CREATE TYPE public.alignement_format AS ENUM (
    'skos',
    'json',
    'xml'
);


ALTER TYPE public.alignement_format OWNER TO opentheso;

--
-- TOC entry 762 (class 1247 OID 44038)
-- Name: alignement_type_rqt; Type: TYPE; Schema: public; Owner: opentheso
--

CREATE TYPE public.alignement_type_rqt AS ENUM (
    'SPARQL',
    'REST'
);


ALTER TYPE public.alignement_type_rqt OWNER TO opentheso;

--
-- TOC entry 765 (class 1247 OID 44044)
-- Name: auth_method; Type: TYPE; Schema: public; Owner: opentheso
--

CREATE TYPE public.auth_method AS ENUM (
    'DB',
    'LDAP',
    'FILE',
    'test'
);


ALTER TYPE public.auth_method OWNER TO opentheso;

--
-- TOC entry 332 (class 1255 OID 44053)
-- Name: f_unaccent(text); Type: FUNCTION; Schema: public; Owner: opentheso
--

CREATE FUNCTION public.f_unaccent(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
SELECT public.unaccent('public.unaccent', $1)
$_$;


ALTER FUNCTION public.f_unaccent(text) OWNER TO opentheso;

--
-- TOC entry 333 (class 1255 OID 44054)
-- Name: unaccent_string(text); Type: FUNCTION; Schema: public; Owner: opentheso
--

CREATE FUNCTION public.unaccent_string(text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE
input_string text := $1;
BEGIN

input_string := translate(input_string, 'âãäåāăąÁÂÃÄÅĀĂĄ', 'aaaaaaaaaaaaaaa');
input_string := translate(input_string, 'èééêëēĕėęěĒĔĖĘĚÉ', 'eeeeeeeeeeeeeeee');
input_string := translate(input_string, 'ìíîïìĩīĭÌÍÎÏÌĨĪĬ', 'iiiiiiiiiiiiiiii');
input_string := translate(input_string, 'óôõöōŏőÒÓÔÕÖŌŎŐ', 'ooooooooooooooo');
input_string := translate(input_string, 'ùúûüũūŭůÙÚÛÜŨŪŬŮ', 'uuuuuuuuuuuuuuuu');
input_string := translate(input_string, '-_/()', '     ');

return input_string;
END;
$_$;


ALTER FUNCTION public.unaccent_string(text) OWNER TO opentheso;

--
-- TOC entry 202 (class 1259 OID 44055)
-- Name: alignement_id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.alignement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.alignement_id_seq OWNER TO opentheso;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 203 (class 1259 OID 44057)
-- Name: alignement; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.alignement (
    id integer DEFAULT nextval('public.alignement_id_seq'::regclass) NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    modified timestamp without time zone DEFAULT now() NOT NULL,
    author integer,
    concept_target character varying,
    thesaurus_target character varying,
    uri_target character varying,
    alignement_id_type integer NOT NULL,
    internal_id_thesaurus character varying NOT NULL,
    internal_id_concept character varying,
    id_alignement_source integer
);


ALTER TABLE public.alignement OWNER TO opentheso;

--
-- TOC entry 204 (class 1259 OID 44066)
-- Name: alignement_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.alignement_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.alignement_preferences_id_seq OWNER TO opentheso;

--
-- TOC entry 205 (class 1259 OID 44068)
-- Name: alignement_preferences; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.alignement_preferences (
    id integer DEFAULT nextval('public.alignement_preferences_id_seq'::regclass) NOT NULL,
    id_thesaurus character varying NOT NULL,
    id_user integer NOT NULL,
    id_concept_depart character varying NOT NULL,
    id_concept_tratees character varying,
    id_alignement_source integer NOT NULL
);


ALTER TABLE public.alignement_preferences OWNER TO opentheso;

--
-- TOC entry 206 (class 1259 OID 44075)
-- Name: alignement_source__id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.alignement_source__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.alignement_source__id_seq OWNER TO opentheso;

--
-- TOC entry 207 (class 1259 OID 44077)
-- Name: alignement_source; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.alignement_source (
    source character varying,
    requete character varying,
    type_rqt public.alignement_type_rqt NOT NULL,
    alignement_format public.alignement_format NOT NULL,
    id integer DEFAULT nextval('public.alignement_source__id_seq'::regclass) NOT NULL,
    id_user integer,
    description character varying,
    gps boolean DEFAULT false,
    source_filter character varying DEFAULT 'Opentheso'::character varying NOT NULL
);


ALTER TABLE public.alignement_source OWNER TO opentheso;

--
-- TOC entry 208 (class 1259 OID 44086)
-- Name: alignement_type; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.alignement_type (
    id integer NOT NULL,
    label text NOT NULL,
    isocode text NOT NULL,
    label_skos character varying
);


ALTER TABLE public.alignement_type OWNER TO opentheso;

--
-- TOC entry 209 (class 1259 OID 44092)
-- Name: bt_type; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.bt_type (
    id integer NOT NULL,
    relation character varying,
    description_fr character varying,
    description_en character varying
);


ALTER TABLE public.bt_type OWNER TO opentheso;

--
-- TOC entry 210 (class 1259 OID 44098)
-- Name: candidat_messages_id_message_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.candidat_messages_id_message_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.candidat_messages_id_message_seq OWNER TO opentheso;

--
-- TOC entry 211 (class 1259 OID 44100)
-- Name: candidat_messages; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.candidat_messages (
    id_message integer DEFAULT nextval('public.candidat_messages_id_message_seq'::regclass) NOT NULL,
    value text NOT NULL,
    id_user integer,
    id_concept integer,
    id_thesaurus character varying,
    date text
);


ALTER TABLE public.candidat_messages OWNER TO opentheso;

--
-- TOC entry 212 (class 1259 OID 44107)
-- Name: candidat_status; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.candidat_status (
    id_concept character varying NOT NULL,
    id_status integer,
    date date DEFAULT now() NOT NULL,
    id_user integer,
    id_thesaurus character varying,
    message text,
    id_user_admin integer
);


ALTER TABLE public.candidat_status OWNER TO opentheso;

--
-- TOC entry 213 (class 1259 OID 44114)
-- Name: candidat_vote; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.candidat_vote (
    id_vote integer NOT NULL,
    id_user integer,
    id_concept character varying,
    id_thesaurus character varying,
    type_vote character varying(30),
    id_note character varying(30)
);


ALTER TABLE public.candidat_vote OWNER TO opentheso;

--
-- TOC entry 214 (class 1259 OID 44120)
-- Name: candidat_vote_id_vote_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.candidat_vote_id_vote_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.candidat_vote_id_vote_seq OWNER TO opentheso;

--
-- TOC entry 4105 (class 0 OID 0)
-- Dependencies: 214
-- Name: candidat_vote_id_vote_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: opentheso
--

ALTER SEQUENCE public.candidat_vote_id_vote_seq OWNED BY public.candidat_vote.id_vote;


--
-- TOC entry 215 (class 1259 OID 44122)
-- Name: compound_equivalence; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.compound_equivalence (
    id_split_nonpreferredterm text NOT NULL,
    id_preferredterm text NOT NULL
);


ALTER TABLE public.compound_equivalence OWNER TO opentheso;

--
-- TOC entry 216 (class 1259 OID 44128)
-- Name: concept__id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.concept__id_seq
    START WITH 43
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.concept__id_seq OWNER TO opentheso;

--
-- TOC entry 217 (class 1259 OID 44130)
-- Name: concept; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.concept (
    id_concept character varying NOT NULL,
    id_thesaurus character varying NOT NULL,
    id_ark character varying DEFAULT ''::character varying,
    created timestamp with time zone DEFAULT now() NOT NULL,
    modified timestamp with time zone DEFAULT now() NOT NULL,
    status character varying,
    notation character varying DEFAULT ''::character varying,
    top_concept boolean,
    id integer DEFAULT nextval('public.concept__id_seq'::regclass),
    gps boolean DEFAULT false,
    id_handle character varying DEFAULT ''::character varying,
    id_doi character varying DEFAULT ''::character varying,
    creator integer DEFAULT '-1'::integer,
    contributor integer DEFAULT '-1'::integer
);


ALTER TABLE public.concept OWNER TO opentheso;

--
-- TOC entry 218 (class 1259 OID 44144)
-- Name: concept_candidat__id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.concept_candidat__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.concept_candidat__id_seq OWNER TO opentheso;

--
-- TOC entry 219 (class 1259 OID 44146)
-- Name: concept_candidat; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.concept_candidat (
    id_concept character varying NOT NULL,
    id_thesaurus character varying NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    modified timestamp with time zone DEFAULT now() NOT NULL,
    status character varying DEFAULT 'a'::character varying,
    id integer DEFAULT nextval('public.concept_candidat__id_seq'::regclass),
    admin_message character varying,
    admin_id integer
);


ALTER TABLE public.concept_candidat OWNER TO opentheso;

--
-- TOC entry 220 (class 1259 OID 44156)
-- Name: concept_facet; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.concept_facet (
    id_facet character varying NOT NULL,
    id_thesaurus text NOT NULL,
    id_concept text NOT NULL
);


ALTER TABLE public.concept_facet OWNER TO opentheso;

--
-- TOC entry 221 (class 1259 OID 44162)
-- Name: concept_group__id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.concept_group__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.concept_group__id_seq OWNER TO opentheso;

--
-- TOC entry 222 (class 1259 OID 44164)
-- Name: concept_group; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.concept_group (
    idgroup text NOT NULL,
    id_ark text NOT NULL,
    idthesaurus text NOT NULL,
    idtypecode text DEFAULT 'MT'::text NOT NULL,
    notation text,
    id integer DEFAULT nextval('public.concept_group__id_seq'::regclass) NOT NULL,
    numerotation integer,
    id_handle character varying DEFAULT ''::character varying,
    id_doi character varying DEFAULT ''::character varying
);


ALTER TABLE public.concept_group OWNER TO opentheso;

--
-- TOC entry 223 (class 1259 OID 44174)
-- Name: concept_group_concept; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.concept_group_concept (
    idgroup text NOT NULL,
    idthesaurus text NOT NULL,
    idconcept text NOT NULL
);


ALTER TABLE public.concept_group_concept OWNER TO opentheso;

--
-- TOC entry 224 (class 1259 OID 44180)
-- Name: concept_group_historique__id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.concept_group_historique__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.concept_group_historique__id_seq OWNER TO opentheso;

--
-- TOC entry 225 (class 1259 OID 44182)
-- Name: concept_group_historique; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.concept_group_historique (
    idgroup text NOT NULL,
    id_ark text NOT NULL,
    idthesaurus text NOT NULL,
    idtypecode text NOT NULL,
    idparentgroup text,
    notation text,
    idconcept text,
    id integer DEFAULT nextval('public.concept_group_historique__id_seq'::regclass) NOT NULL,
    modified timestamp(6) with time zone DEFAULT now() NOT NULL,
    id_user integer NOT NULL
);


ALTER TABLE public.concept_group_historique OWNER TO opentheso;

--
-- TOC entry 226 (class 1259 OID 44190)
-- Name: concept_group_label_id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.concept_group_label_id_seq
    START WITH 60
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.concept_group_label_id_seq OWNER TO opentheso;

--
-- TOC entry 227 (class 1259 OID 44192)
-- Name: concept_group_label; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.concept_group_label (
    id integer DEFAULT nextval('public.concept_group_label_id_seq'::regclass) NOT NULL,
    lexicalvalue text NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    modified timestamp without time zone DEFAULT now() NOT NULL,
    lang character varying NOT NULL,
    idthesaurus text NOT NULL,
    idgroup text NOT NULL
);


ALTER TABLE public.concept_group_label OWNER TO opentheso;

--
-- TOC entry 228 (class 1259 OID 44201)
-- Name: concept_group_label_historique__id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.concept_group_label_historique__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.concept_group_label_historique__id_seq OWNER TO opentheso;

--
-- TOC entry 229 (class 1259 OID 44203)
-- Name: concept_group_label_historique; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.concept_group_label_historique (
    id integer DEFAULT nextval('public.concept_group_label_historique__id_seq'::regclass) NOT NULL,
    lexicalvalue text NOT NULL,
    modified timestamp(6) without time zone DEFAULT now() NOT NULL,
    lang character varying(5) NOT NULL,
    idthesaurus text NOT NULL,
    idgroup text NOT NULL,
    id_user integer NOT NULL
);


ALTER TABLE public.concept_group_label_historique OWNER TO opentheso;

--
-- TOC entry 230 (class 1259 OID 44211)
-- Name: concept_group_type; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.concept_group_type (
    code text NOT NULL,
    label text NOT NULL,
    skoslabel text
);


ALTER TABLE public.concept_group_type OWNER TO opentheso;

--
-- TOC entry 231 (class 1259 OID 44217)
-- Name: concept_historique__id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.concept_historique__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.concept_historique__id_seq OWNER TO opentheso;

--
-- TOC entry 232 (class 1259 OID 44219)
-- Name: concept_historique; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.concept_historique (
    id_concept character varying NOT NULL,
    id_thesaurus character varying NOT NULL,
    id_ark character varying,
    modified timestamp(6) with time zone DEFAULT now() NOT NULL,
    status character varying,
    notation character varying DEFAULT ''::character varying,
    top_concept boolean,
    id_group character varying NOT NULL,
    id integer DEFAULT nextval('public.concept_historique__id_seq'::regclass),
    id_user integer NOT NULL
);


ALTER TABLE public.concept_historique OWNER TO opentheso;

--
-- TOC entry 233 (class 1259 OID 44228)
-- Name: concept_replacedby; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.concept_replacedby (
    id_concept1 character varying NOT NULL,
    id_concept2 character varying NOT NULL,
    id_thesaurus character varying NOT NULL,
    modified timestamp with time zone DEFAULT now() NOT NULL,
    id_user integer NOT NULL
);


ALTER TABLE public.concept_replacedby OWNER TO opentheso;

--
-- TOC entry 234 (class 1259 OID 44235)
-- Name: concept_term_candidat; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.concept_term_candidat (
    id_concept character varying NOT NULL,
    id_term character varying NOT NULL,
    id_thesaurus character varying NOT NULL
);


ALTER TABLE public.concept_term_candidat OWNER TO opentheso;

--
-- TOC entry 235 (class 1259 OID 44241)
-- Name: copyright; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.copyright (
    id_thesaurus character varying NOT NULL,
    copyright character varying
);


ALTER TABLE public.copyright OWNER TO opentheso;

--
-- TOC entry 236 (class 1259 OID 44247)
-- Name: corpus_link; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.corpus_link (
    id_theso character varying NOT NULL,
    corpus_name character varying NOT NULL,
    uri_count character varying,
    uri_link character varying NOT NULL,
    active boolean DEFAULT false,
    only_uri_link boolean DEFAULT false,
    sort integer
);


ALTER TABLE public.corpus_link OWNER TO opentheso;

--
-- TOC entry 237 (class 1259 OID 44254)
-- Name: custom_concept_attribute; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.custom_concept_attribute (
    "idConcept" character varying NOT NULL,
    "lexicalValue" character varying,
    "customAttributeType" character varying,
    lang character varying
);


ALTER TABLE public.custom_concept_attribute OWNER TO opentheso;

--
-- TOC entry 238 (class 1259 OID 44260)
-- Name: custom_term_attribute; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.custom_term_attribute (
    identifier character varying NOT NULL,
    "lexicalValue" character varying,
    "customAttributeType" character varying,
    lang character varying
);


ALTER TABLE public.custom_term_attribute OWNER TO opentheso;

--
-- TOC entry 239 (class 1259 OID 44266)
-- Name: external_images; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.external_images (
    id_concept character varying NOT NULL,
    id_thesaurus character varying NOT NULL,
    image_name character varying NOT NULL,
    image_copyright character varying NOT NULL,
    id_user integer,
    external_uri character varying DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.external_images OWNER TO opentheso;

--
-- TOC entry 240 (class 1259 OID 44273)
-- Name: facet_id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.facet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.facet_id_seq OWNER TO opentheso;

--
-- TOC entry 241 (class 1259 OID 44275)
-- Name: gps; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.gps (
    id_concept character varying NOT NULL,
    id_theso character varying NOT NULL,
    latitude double precision,
    longitude double precision
);


ALTER TABLE public.gps OWNER TO opentheso;

--
-- TOC entry 242 (class 1259 OID 44281)
-- Name: gps_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.gps_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.gps_preferences_id_seq OWNER TO opentheso;

--
-- TOC entry 243 (class 1259 OID 44283)
-- Name: gps_preferences; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.gps_preferences (
    id integer DEFAULT nextval('public.gps_preferences_id_seq'::regclass) NOT NULL,
    id_thesaurus character varying NOT NULL,
    id_user integer NOT NULL,
    gps_integrertraduction boolean DEFAULT true,
    gps_reemplacertraduction boolean DEFAULT true,
    gps_alignementautomatique boolean DEFAULT true,
    id_alignement_source integer NOT NULL
);


ALTER TABLE public.gps_preferences OWNER TO opentheso;

--
-- TOC entry 244 (class 1259 OID 44293)
-- Name: hierarchical_relationship; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.hierarchical_relationship (
    id_concept1 character varying NOT NULL,
    id_thesaurus character varying NOT NULL,
    role character varying NOT NULL,
    id_concept2 character varying NOT NULL
);


ALTER TABLE public.hierarchical_relationship OWNER TO opentheso;

--
-- TOC entry 245 (class 1259 OID 44299)
-- Name: hierarchical_relationship_historique; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.hierarchical_relationship_historique (
    id_concept1 character varying NOT NULL,
    id_thesaurus character varying NOT NULL,
    role character varying NOT NULL,
    id_concept2 character varying NOT NULL,
    modified timestamp(6) with time zone DEFAULT now() NOT NULL,
    id_user integer NOT NULL,
    action character varying NOT NULL
);


ALTER TABLE public.hierarchical_relationship_historique OWNER TO opentheso;

--
-- TOC entry 246 (class 1259 OID 44306)
-- Name: homepage; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.homepage (
    htmlcode character varying,
    lang character varying
);


ALTER TABLE public.homepage OWNER TO opentheso;

--
-- TOC entry 247 (class 1259 OID 44312)
-- Name: images; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.images (
    id_concept character varying NOT NULL,
    id_thesaurus character varying NOT NULL,
    image_name character varying NOT NULL,
    image_copyright character varying NOT NULL,
    id_user integer,
    external_uri character varying DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.images OWNER TO opentheso;

--
-- TOC entry 248 (class 1259 OID 44319)
-- Name: info; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.info (
    version_opentheso character varying NOT NULL,
    version_bdd character varying NOT NULL,
    googleanalytics character varying
);


ALTER TABLE public.info OWNER TO opentheso;

--
-- TOC entry 249 (class 1259 OID 44325)
-- Name: languages_id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.languages_id_seq OWNER TO opentheso;

--
-- TOC entry 250 (class 1259 OID 44327)
-- Name: languages_iso639; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.languages_iso639 (
    iso639_1 character varying,
    iso639_2 character varying,
    english_name character varying,
    french_name character varying,
    id integer DEFAULT nextval('public.languages_id_seq'::regclass) NOT NULL
);


ALTER TABLE public.languages_iso639 OWNER TO opentheso;

--
-- TOC entry 251 (class 1259 OID 44334)
-- Name: thesaurus_array_facet_id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.thesaurus_array_facet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.thesaurus_array_facet_id_seq OWNER TO opentheso;

--
-- TOC entry 252 (class 1259 OID 44336)
-- Name: node_label; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.node_label (
    id_thesaurus character varying NOT NULL,
    lexical_value character varying,
    created timestamp with time zone DEFAULT now() NOT NULL,
    modified timestamp with time zone DEFAULT now() NOT NULL,
    lang character varying NOT NULL,
    id integer DEFAULT nextval('public.thesaurus_array_facet_id_seq'::regclass) NOT NULL,
    id_facet character varying NOT NULL
);


ALTER TABLE public.node_label OWNER TO opentheso;

--
-- TOC entry 253 (class 1259 OID 44345)
-- Name: non_preferred_term; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.non_preferred_term (
    id_term character varying NOT NULL,
    lexical_value character varying NOT NULL,
    lang character varying NOT NULL,
    id_thesaurus text NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    modified timestamp with time zone DEFAULT now() NOT NULL,
    source character varying,
    status character varying,
    hiden boolean DEFAULT false NOT NULL
);


ALTER TABLE public.non_preferred_term OWNER TO opentheso;

--
-- TOC entry 254 (class 1259 OID 44354)
-- Name: non_preferred_term_historique; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.non_preferred_term_historique (
    id_term character varying NOT NULL,
    lexical_value character varying NOT NULL,
    lang character varying NOT NULL,
    id_thesaurus text NOT NULL,
    modified timestamp(6) with time zone DEFAULT now() NOT NULL,
    source character varying,
    status character varying,
    hiden boolean DEFAULT false NOT NULL,
    id_user integer NOT NULL,
    action character varying NOT NULL
);


ALTER TABLE public.non_preferred_term_historique OWNER TO opentheso;

--
-- TOC entry 255 (class 1259 OID 44362)
-- Name: note__id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.note__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.note__id_seq OWNER TO opentheso;

--
-- TOC entry 256 (class 1259 OID 44364)
-- Name: note; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.note (
    id integer DEFAULT nextval('public.note__id_seq'::regclass) NOT NULL,
    notetypecode text NOT NULL,
    id_thesaurus character varying NOT NULL,
    id_term character varying,
    id_concept character varying,
    lang character varying NOT NULL,
    lexicalvalue character varying NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    modified timestamp without time zone DEFAULT now() NOT NULL,
    id_user integer
);


ALTER TABLE public.note OWNER TO opentheso;

--
-- TOC entry 257 (class 1259 OID 44373)
-- Name: note_historique__id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.note_historique__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.note_historique__id_seq OWNER TO opentheso;

--
-- TOC entry 258 (class 1259 OID 44375)
-- Name: note_historique; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.note_historique (
    id integer DEFAULT nextval('public.note_historique__id_seq'::regclass) NOT NULL,
    notetypecode text NOT NULL,
    id_thesaurus character varying NOT NULL,
    id_term character varying,
    id_concept character varying,
    lang character varying NOT NULL,
    lexicalvalue character varying NOT NULL,
    modified timestamp(6) without time zone DEFAULT now() NOT NULL,
    id_user integer NOT NULL,
    action_performed character varying
);


ALTER TABLE public.note_historique OWNER TO opentheso;

--
-- TOC entry 259 (class 1259 OID 44383)
-- Name: note_type; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.note_type (
    code text NOT NULL,
    isterm boolean NOT NULL,
    isconcept boolean NOT NULL,
    label_fr character varying,
    label_en character varying,
    CONSTRAINT chk_not_false_values CHECK ((NOT ((isterm = false) AND (isconcept = false))))
);


ALTER TABLE public.note_type OWNER TO opentheso;

--
-- TOC entry 260 (class 1259 OID 44390)
-- Name: nt_type; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.nt_type (
    id integer NOT NULL,
    relation character varying,
    description_fr character varying,
    description_en character varying
);


ALTER TABLE public.nt_type OWNER TO opentheso;

--
-- TOC entry 261 (class 1259 OID 44396)
-- Name: permuted; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.permuted (
    ord integer NOT NULL,
    id_concept character varying NOT NULL,
    id_group character varying NOT NULL,
    id_thesaurus character varying NOT NULL,
    id_lang character varying NOT NULL,
    lexical_value character varying NOT NULL,
    ispreferredterm boolean NOT NULL,
    original_value character varying
);


ALTER TABLE public.permuted OWNER TO opentheso;

--
-- TOC entry 262 (class 1259 OID 44402)
-- Name: pref__id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.pref__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pref__id_seq OWNER TO opentheso;

--
-- TOC entry 263 (class 1259 OID 44404)
-- Name: preferences; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.preferences (
    id_pref integer DEFAULT nextval('public.pref__id_seq'::regclass) NOT NULL,
    id_thesaurus character varying NOT NULL,
    source_lang character varying DEFAULT 'fr'::character varying,
    identifier_type integer DEFAULT 2,
    path_image character varying DEFAULT '/var/www/images/'::character varying,
    dossier_resize character varying DEFAULT 'resize'::character varying,
    bdd_active boolean DEFAULT false,
    bdd_use_id boolean DEFAULT false,
    url_bdd character varying DEFAULT 'http://www.mondomaine.fr/concept/##value##'::character varying,
    url_counter_bdd character varying DEFAULT 'http://mondomaine.fr/concept/##conceptId##/total'::character varying,
    z3950actif boolean DEFAULT false,
    collection_adresse character varying DEFAULT 'KOHA/biblios'::character varying,
    notice_url character varying DEFAULT 'http://catalogue.mondomaine.fr/cgi-bin/koha/opac-search.pl?type=opac&op=do_search&q=an=terme'::character varying,
    url_encode character varying(10) DEFAULT 'UTF-8'::character varying,
    path_notice1 character varying DEFAULT '/var/www/notices/repositories.xml'::character varying,
    path_notice2 character varying DEFAULT '/var/www/notices/SchemaMappings.xml'::character varying,
    chemin_site character varying DEFAULT 'http://mondomaine.fr/'::character varying,
    webservices boolean DEFAULT true,
    use_ark boolean DEFAULT false,
    server_ark character varying DEFAULT 'http://ark.mondomaine.fr/ark:/'::character varying,
    id_naan character varying DEFAULT '66666'::character varying NOT NULL,
    prefix_ark character varying DEFAULT 'crt'::character varying NOT NULL,
    user_ark character varying,
    pass_ark character varying,
    use_handle boolean DEFAULT false,
    user_handle character varying,
    pass_handle character varying,
    path_key_handle character varying DEFAULT '/certificat/key.p12'::character varying,
    path_cert_handle character varying DEFAULT '/certificat/cacerts2'::character varying,
    url_api_handle character varying DEFAULT 'https://handle-server.mondomaine.fr:8001/api/handles/'::character varying NOT NULL,
    prefix_handle character varying DEFAULT '66.666.66666'::character varying NOT NULL,
    private_prefix_handle character varying DEFAULT 'crt'::character varying NOT NULL,
    preferredname character varying,
    original_uri character varying,
    original_uri_is_ark boolean DEFAULT false,
    original_uri_is_handle boolean DEFAULT false,
    uri_ark character varying DEFAULT 'https://ark.mom.fr/ark:/'::character varying,
    generate_handle boolean DEFAULT false,
    auto_expand_tree boolean DEFAULT true,
    sort_by_notation boolean DEFAULT false,
    tree_cache boolean DEFAULT false,
    original_uri_is_doi boolean DEFAULT false,
    use_ark_local boolean DEFAULT false,
    naan_ark_local character varying DEFAULT ''::character varying,
    prefix_ark_local character varying DEFAULT ''::character varying,
    sizeid_ark_local integer DEFAULT 10
);


ALTER TABLE public.preferences OWNER TO opentheso;

--
-- TOC entry 264 (class 1259 OID 44445)
-- Name: preferences_sparql; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.preferences_sparql (
    adresse_serveur character varying,
    mot_de_passe character varying,
    nom_d_utilisateur character varying,
    graph character varying,
    synchronisation boolean DEFAULT false NOT NULL,
    thesaurus character varying NOT NULL,
    heure time without time zone
);


ALTER TABLE public.preferences_sparql OWNER TO opentheso;

--
-- TOC entry 265 (class 1259 OID 44452)
-- Name: preferred_term; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.preferred_term (
    id_concept character varying NOT NULL,
    id_term character varying NOT NULL,
    id_thesaurus character varying NOT NULL
);


ALTER TABLE public.preferred_term OWNER TO opentheso;

--
-- TOC entry 266 (class 1259 OID 44458)
-- Name: proposition; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.proposition (
    id_concept character varying NOT NULL,
    id_user integer NOT NULL,
    id_thesaurus character varying NOT NULL,
    note text,
    created timestamp with time zone DEFAULT now() NOT NULL,
    modified timestamp with time zone DEFAULT now() NOT NULL,
    concept_parent character varying,
    id_group character varying
);


ALTER TABLE public.proposition OWNER TO opentheso;

--
-- TOC entry 267 (class 1259 OID 44466)
-- Name: relation_group; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.relation_group (
    id_group1 character varying NOT NULL,
    id_thesaurus character varying NOT NULL,
    relation character varying NOT NULL,
    id_group2 character varying NOT NULL
);


ALTER TABLE public.relation_group OWNER TO opentheso;

--
-- TOC entry 268 (class 1259 OID 44472)
-- Name: roles; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying,
    description character varying
);


ALTER TABLE public.roles OWNER TO opentheso;

--
-- TOC entry 269 (class 1259 OID 44478)
-- Name: role_id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.role_id_seq OWNER TO opentheso;

--
-- TOC entry 4106 (class 0 OID 0)
-- Dependencies: 269
-- Name: role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: opentheso
--

ALTER SEQUENCE public.role_id_seq OWNED BY public.roles.id;


--
-- TOC entry 270 (class 1259 OID 44480)
-- Name: routine_mail; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.routine_mail (
    id_thesaurus character varying NOT NULL,
    alert_cdt boolean DEFAULT true,
    debut_env_cdt_propos date NOT NULL,
    debut_env_cdt_valid date NOT NULL,
    period_env_cdt_propos integer NOT NULL,
    period_env_cdt_valid integer NOT NULL
);


ALTER TABLE public.routine_mail OWNER TO opentheso;

--
-- TOC entry 271 (class 1259 OID 44487)
-- Name: split_non_preferred_term; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.split_non_preferred_term (
);


ALTER TABLE public.split_non_preferred_term OWNER TO opentheso;

--
-- TOC entry 272 (class 1259 OID 44490)
-- Name: status; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.status (
    id_status integer NOT NULL,
    value text
);


ALTER TABLE public.status OWNER TO opentheso;

--
-- TOC entry 273 (class 1259 OID 44496)
-- Name: status_id_status_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.status_id_status_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.status_id_status_seq OWNER TO opentheso;

--
-- TOC entry 274 (class 1259 OID 44498)
-- Name: status_id_status_seq1; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.status_id_status_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.status_id_status_seq1 OWNER TO opentheso;

--
-- TOC entry 4107 (class 0 OID 0)
-- Dependencies: 274
-- Name: status_id_status_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: opentheso
--

ALTER SEQUENCE public.status_id_status_seq1 OWNED BY public.status.id_status;


--
-- TOC entry 275 (class 1259 OID 44500)
-- Name: term__id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.term__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.term__id_seq OWNER TO opentheso;

--
-- TOC entry 276 (class 1259 OID 44502)
-- Name: term; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.term (
    id_term character varying NOT NULL,
    lexical_value character varying NOT NULL,
    lang character varying NOT NULL,
    id_thesaurus text NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    modified timestamp with time zone DEFAULT now() NOT NULL,
    source character varying,
    status character varying DEFAULT 'D'::character varying,
    id integer DEFAULT nextval('public.term__id_seq'::regclass) NOT NULL,
    contributor integer,
    creator integer
);


ALTER TABLE public.term OWNER TO opentheso;

--
-- TOC entry 277 (class 1259 OID 44512)
-- Name: term_candidat__id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.term_candidat__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.term_candidat__id_seq OWNER TO opentheso;

--
-- TOC entry 278 (class 1259 OID 44514)
-- Name: term_candidat; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.term_candidat (
    id_term character varying NOT NULL,
    lexical_value character varying NOT NULL,
    lang character varying NOT NULL,
    id_thesaurus text NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    modified timestamp with time zone DEFAULT now() NOT NULL,
    contributor integer NOT NULL,
    id integer DEFAULT nextval('public.term_candidat__id_seq'::regclass) NOT NULL
);


ALTER TABLE public.term_candidat OWNER TO opentheso;

--
-- TOC entry 279 (class 1259 OID 44523)
-- Name: term_historique__id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.term_historique__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.term_historique__id_seq OWNER TO opentheso;

--
-- TOC entry 280 (class 1259 OID 44525)
-- Name: term_historique; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.term_historique (
    id_term character varying NOT NULL,
    lexical_value character varying NOT NULL,
    lang character varying NOT NULL,
    id_thesaurus text NOT NULL,
    modified timestamp(6) with time zone DEFAULT now() NOT NULL,
    source character varying,
    status character varying DEFAULT 'D'::character varying,
    id integer DEFAULT nextval('public.term_historique__id_seq'::regclass) NOT NULL,
    id_user integer NOT NULL,
    action character varying
);


ALTER TABLE public.term_historique OWNER TO opentheso;

--
-- TOC entry 281 (class 1259 OID 44534)
-- Name: thesaurus_id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.thesaurus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.thesaurus_id_seq OWNER TO opentheso;

--
-- TOC entry 282 (class 1259 OID 44536)
-- Name: thesaurus; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.thesaurus (
    id_thesaurus character varying NOT NULL,
    id_ark character varying NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    modified timestamp without time zone DEFAULT now() NOT NULL,
    id integer DEFAULT nextval('public.thesaurus_id_seq'::regclass) NOT NULL,
    private boolean DEFAULT false
);


ALTER TABLE public.thesaurus OWNER TO opentheso;

--
-- TOC entry 283 (class 1259 OID 44546)
-- Name: thesaurus_alignement_source; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.thesaurus_alignement_source (
    id_thesaurus character varying NOT NULL,
    id_alignement_source integer NOT NULL
);


ALTER TABLE public.thesaurus_alignement_source OWNER TO opentheso;

--
-- TOC entry 284 (class 1259 OID 44552)
-- Name: thesaurus_array; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.thesaurus_array (
    id_thesaurus character varying NOT NULL,
    id_concept_parent character varying NOT NULL,
    ordered boolean DEFAULT false NOT NULL,
    notation character varying,
    id_facet character varying NOT NULL
);


ALTER TABLE public.thesaurus_array OWNER TO opentheso;

--
-- TOC entry 285 (class 1259 OID 44559)
-- Name: thesaurus_label; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.thesaurus_label (
    id_thesaurus character varying NOT NULL,
    contributor character varying,
    coverage character varying,
    creator character varying,
    created timestamp without time zone DEFAULT now() NOT NULL,
    modified timestamp without time zone DEFAULT now() NOT NULL,
    description character varying,
    format character varying,
    lang character varying NOT NULL,
    publisher character varying,
    relation character varying,
    rights character varying,
    source character varying,
    subject character varying,
    title character varying NOT NULL,
    type character varying
);


ALTER TABLE public.thesaurus_label OWNER TO opentheso;

--
-- TOC entry 286 (class 1259 OID 44567)
-- Name: thesohomepage; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.thesohomepage (
    htmlcode character varying,
    lang character varying,
    idtheso character varying
);


ALTER TABLE public.thesohomepage OWNER TO opentheso;

--
-- TOC entry 287 (class 1259 OID 44573)
-- Name: user__id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.user__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user__id_seq OWNER TO opentheso;

--
-- TOC entry 288 (class 1259 OID 44575)
-- Name: user_group_label__id_seq; Type: SEQUENCE; Schema: public; Owner: opentheso
--

CREATE SEQUENCE public.user_group_label__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_group_label__id_seq OWNER TO opentheso;

--
-- TOC entry 289 (class 1259 OID 44577)
-- Name: user_group_label; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.user_group_label (
    id_group integer DEFAULT nextval('public.user_group_label__id_seq'::regclass) NOT NULL,
    label_group character varying
);


ALTER TABLE public.user_group_label OWNER TO opentheso;

--
-- TOC entry 290 (class 1259 OID 44584)
-- Name: user_group_thesaurus; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.user_group_thesaurus (
    id_group integer NOT NULL,
    id_thesaurus character varying NOT NULL
);


ALTER TABLE public.user_group_thesaurus OWNER TO opentheso;

--
-- TOC entry 291 (class 1259 OID 44590)
-- Name: user_role_group; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.user_role_group (
    id_user integer NOT NULL,
    id_role integer NOT NULL,
    id_group integer NOT NULL
);


ALTER TABLE public.user_role_group OWNER TO opentheso;

--
-- TOC entry 292 (class 1259 OID 44593)
-- Name: user_role_only_on; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.user_role_only_on (
    id_user integer NOT NULL,
    id_role integer NOT NULL,
    id_theso character varying NOT NULL,
    id_theso_domain character varying DEFAULT 'all'::character varying NOT NULL
);


ALTER TABLE public.user_role_only_on OWNER TO opentheso;

--
-- TOC entry 293 (class 1259 OID 44600)
-- Name: users; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.users (
    id_user integer DEFAULT nextval('public.user__id_seq'::regclass) NOT NULL,
    username character varying NOT NULL,
    password character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    mail character varying NOT NULL,
    passtomodify boolean DEFAULT false,
    alertmail boolean DEFAULT false,
    issuperadmin boolean DEFAULT false
);


ALTER TABLE public.users OWNER TO opentheso;

--
-- TOC entry 294 (class 1259 OID 44611)
-- Name: users2; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.users2 (
    id_user integer DEFAULT nextval('public.user__id_seq'::regclass) NOT NULL,
    login character varying NOT NULL,
    fullname character varying,
    password character varying,
    active boolean DEFAULT true NOT NULL,
    mail character varying,
    authentication public.auth_method DEFAULT 'DB'::public.auth_method
);


ALTER TABLE public.users2 OWNER TO opentheso;

--
-- TOC entry 295 (class 1259 OID 44620)
-- Name: users_historique; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.users_historique (
    id_user integer NOT NULL,
    username character varying,
    created timestamp(6) with time zone DEFAULT now() NOT NULL,
    modified timestamp(6) with time zone DEFAULT now() NOT NULL,
    delete timestamp(6) with time zone
);


ALTER TABLE public.users_historique OWNER TO opentheso;

--
-- TOC entry 296 (class 1259 OID 44628)
-- Name: version_history; Type: TABLE; Schema: public; Owner: opentheso
--

CREATE TABLE public.version_history (
    "idVersionhistory" character varying NOT NULL,
    "idThesaurus" character varying NOT NULL,
    date date,
    "versionNote" character varying,
    "currentVersion" boolean,
    "thisVersion" boolean NOT NULL
);


ALTER TABLE public.version_history OWNER TO opentheso;

--
-- TOC entry 3574 (class 2604 OID 44634)
-- Name: candidat_vote id_vote; Type: DEFAULT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.candidat_vote ALTER COLUMN id_vote SET DEFAULT nextval('public.candidat_vote_id_vote_seq'::regclass);


--
-- TOC entry 3670 (class 2604 OID 44635)
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.role_id_seq'::regclass);


--
-- TOC entry 3672 (class 2604 OID 44636)
-- Name: status id_status; Type: DEFAULT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.status ALTER COLUMN id_status SET DEFAULT nextval('public.status_id_status_seq1'::regclass);


--
-- TOC entry 4004 (class 0 OID 44057)
-- Dependencies: 203
-- Data for Name: alignement; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4006 (class 0 OID 44068)
-- Dependencies: 205
-- Data for Name: alignement_preferences; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4008 (class 0 OID 44077)
-- Dependencies: 207
-- Data for Name: alignement_source; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.alignement_source (source, requete, type_rqt, alignement_format, id, id_user, description, gps, source_filter) VALUES ('IdRefSujets', 'https://www.idref.fr/Sru/Solr?wt=json&version=2.2&start=&rows=100&indent=on&fl=id,ppn_z,affcourt_z&q=subjectheading_t:(##value##)%20AND%20recordtype_z:r', 'REST', 'json', 184, 1, 'alignement avec les Sujets de IdRef ABES Rameaux', false, 'IdRefSujets');
INSERT INTO public.alignement_source (source, requete, type_rqt, alignement_format, id, id_user, description, gps, source_filter) VALUES ('IdRefAuteurs', 'https://www.idref.fr/Sru/Solr?wt=json&q=nom_t:(##nom##)%20AND%20prenom_t:(##prenom##)%20AND%20recordtype_z:a&fl=ppn_z,affcourt_z,prenom_s,nom_s&start=0&rows=30&version=2.2', 'REST', 'json', 185, 1, 'alignement avec les Auteurs de IdRef ABES', false, 'IdRefAuteurs');
INSERT INTO public.alignement_source (source, requete, type_rqt, alignement_format, id, id_user, description, gps, source_filter) VALUES ('local_culture', 'http://localhost:8082/opentheso2/api/search?q=##value##&lang=##lang##&theso=th2', 'REST', 'skos', 39, 1, 'Opentheso', false, 'Opentheso');
INSERT INTO public.alignement_source (source, requete, type_rqt, alignement_format, id, id_user, description, gps, source_filter) VALUES ('local_sarah', 'http://localhost:8082/opentheso2/api/search?q=##value##&lang=##lang##&theso=th1', 'REST', 'skos', 41, 1, 'Opentheso', false, 'Opentheso');
INSERT INTO public.alignement_source (source, requete, type_rqt, alignement_format, id, id_user, description, gps, source_filter) VALUES ('IdRefPersonnes', 'https://www.idref.fr/Sru/Solr?wt=json&q=persname_t:(##value##)&fl=ppn_z,affcourt_z,prenom_s,nom_s&start=0&rows=30&version=2.2', 'REST', 'json', 186, 1, 'alignement avec les Noms de personnes de IdRef ABES', false, 'IdRefPersonnes');
INSERT INTO public.alignement_source (source, requete, type_rqt, alignement_format, id, id_user, description, gps, source_filter) VALUES ('IdRefTitreUniforme', 'https://www.idref.fr/Sru/Solr?wt=json&version=2.2&start=&rows=100&indent=on&fl=id,ppn_z,affcourt_z&q=uniformtitle_t:(##value##)%20AND%20recordtype_z:f', 'REST', 'json', 187, 1, 'alignement avec les titres uniformes de IdRef ABES', false, 'IdRefTitreUniforme');
INSERT INTO public.alignement_source (source, requete, type_rqt, alignement_format, id, id_user, description, gps, source_filter) VALUES ('Getty_AAT', 'http://vocabsservices.getty.edu/AATService.asmx/AATGetTermMatch?term=##value##&logop=and&notes=', 'REST', 'xml', 189, 1, 'alignement avec le thésaurus du Getty AAT', false, 'Getty_AAT');
INSERT INTO public.alignement_source (source, requete, type_rqt, alignement_format, id, id_user, description, gps, source_filter) VALUES ('local_th2', 'http://localhost:8082/opentheso2/api/search?q=##value##&lang=##lang##&theso=th2', 'REST', 'skos', 127, 1, 'pour tester', false, 'Opentheso');
INSERT INTO public.alignement_source (source, requete, type_rqt, alignement_format, id, id_user, description, gps, source_filter) VALUES ('GeoNames', 'http://api.geonames.org/search?q=##value##&maxRows=10&style=FULL&lang=##lang##&username=opentheso', 'REST', 'xml', 190, 1, 'Alignement avec GeoNames', true, 'GeoNames');
INSERT INTO public.alignement_source (source, requete, type_rqt, alignement_format, id, id_user, description, gps, source_filter) VALUES ('Pactols', 'https://pactols.frantiq.fr/opentheso/api/search?q=##value##&lang=##lang##&theso=TH_1', 'REST', 'skos', 191, 1, 'Alignement avec PACTOLS', false, 'Opentheso');
INSERT INTO public.alignement_source (source, requete, type_rqt, alignement_format, id, id_user, description, gps, source_filter) VALUES ('Gemet', 'https://www.eionet.europa.eu/gemet/getConceptsMatchingKeyword?keyword=##value##&search_mode=3&thesaurus_uri=http://www.eionet.europa.eu/gemet/concept/&language=##lang##', 'REST', 'json', 192, 1, 'Alignement avec le thésaurus Gemet', false, 'Gemet');
INSERT INTO public.alignement_source (source, requete, type_rqt, alignement_format, id, id_user, description, gps, source_filter) VALUES ('Agrovoc', 'http://agrovoc.uniroma2.it/agrovoc/rest/v1/search/?query=##value##&lang=##lang##', 'REST', 'json', 193, 1, 'Alignement avec le thésaurus Agrovoc', false, 'Agrovoc');
INSERT INTO public.alignement_source (source, requete, type_rqt, alignement_format, id, id_user, description, gps, source_filter) VALUES ('bnf_instrumentMusique', 'PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX xml: <http://www.w3.org/XML/1998/namespace>
SELECT ?instrument ?prop ?value where {
  <http://data.bnf.fr/ark:/12148/cb119367821> skos:narrower+ ?instrument.
  ?instrument ?prop ?value.
  FILTER( (regex(?prop,skos:prefLabel) || regex(?prop,skos:altLabel))  && regex(?value, ##value##,"i") ) 
    filter(lang(?value) =##lang##)
} LIMIT 20', 'SPARQL', 'skos', 5, 1, '', false, 'Opentheso');
INSERT INTO public.alignement_source (source, requete, type_rqt, alignement_format, id, id_user, description, gps, source_filter) VALUES ('Wikidata_sparql', 'SELECT ?item ?itemLabel ?itemDescription WHERE {
                            ?item rdfs:label "##value##"@##lang##.
                            SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],##lang##". }
                }', 'SPARQL', 'json', 194, 1, 'alignement avec le vocabulaire Wikidata SPARQL', false, 'Wikidata_sparql');
INSERT INTO public.alignement_source (source, requete, type_rqt, alignement_format, id, id_user, description, gps, source_filter) VALUES ('Wikidata_rest', 'https://www.wikidata.org/w/api.php?action=wbsearchentities&language=##lang##&search=##value##&format=json&limit=10', 'REST', 'json', 195, 1, 'alignement avec le vocabulaire Wikidata REST', false, 'Wikidata_rest');


--
-- TOC entry 4009 (class 0 OID 44086)
-- Dependencies: 208
-- Data for Name: alignement_type; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.alignement_type (id, label, isocode, label_skos) VALUES (1, 'Equivalence exacte', '=EQ', 'exactMatch');
INSERT INTO public.alignement_type (id, label, isocode, label_skos) VALUES (2, 'Equivalence inexacte', '~EQ', 'closeMatch');
INSERT INTO public.alignement_type (id, label, isocode, label_skos) VALUES (3, 'Equivalence générique', 'EQB', 'broadMatch');
INSERT INTO public.alignement_type (id, label, isocode, label_skos) VALUES (4, 'Equivalence associative', 'EQR', 'relatedMatch');
INSERT INTO public.alignement_type (id, label, isocode, label_skos) VALUES (5, 'Equivalence spécifique', 'EQS', 'narrowMatch');


--
-- TOC entry 4010 (class 0 OID 44092)
-- Dependencies: 209
-- Data for Name: bt_type; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.bt_type (id, relation, description_fr, description_en) VALUES (1, 'BT', 'Terme générique', 'Broader term');
INSERT INTO public.bt_type (id, relation, description_fr, description_en) VALUES (2, 'BTG', 'Terme générique (generic)', 'Broader term (generic)');
INSERT INTO public.bt_type (id, relation, description_fr, description_en) VALUES (3, 'BTP', 'Terme générique (partitive)', 'Broader term (partitive)');
INSERT INTO public.bt_type (id, relation, description_fr, description_en) VALUES (4, 'BTI', 'Terme générique (instance)', 'Broader term (instance)');


--
-- TOC entry 4012 (class 0 OID 44100)
-- Dependencies: 211
-- Data for Name: candidat_messages; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4013 (class 0 OID 44107)
-- Dependencies: 212
-- Data for Name: candidat_status; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4014 (class 0 OID 44114)
-- Dependencies: 213
-- Data for Name: candidat_vote; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4016 (class 0 OID 44122)
-- Dependencies: 215
-- Data for Name: compound_equivalence; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4018 (class 0 OID 44130)
-- Dependencies: 217
-- Data for Name: concept; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.concept (id_concept, id_thesaurus, id_ark, created, modified, status, notation, top_concept, id, gps, id_handle, id_doi, creator, contributor) VALUES ('2', 'th1', '', '2022-01-12 12:55:26.18484+01', '2022-01-12 12:55:26.18484+01', 'D', 'N1', true, 2, false, '', '', 1, -1);


--
-- TOC entry 4020 (class 0 OID 44146)
-- Dependencies: 219
-- Data for Name: concept_candidat; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4021 (class 0 OID 44156)
-- Dependencies: 220
-- Data for Name: concept_facet; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4023 (class 0 OID 44164)
-- Dependencies: 222
-- Data for Name: concept_group; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.concept_group (idgroup, id_ark, idthesaurus, idtypecode, notation, id, numerotation, id_handle, id_doi) VALUES ('G3', '', 'th1', 'C', '', 4, NULL, '', '');


--
-- TOC entry 4024 (class 0 OID 44174)
-- Dependencies: 223
-- Data for Name: concept_group_concept; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.concept_group_concept (idgroup, idthesaurus, idconcept) VALUES ('G3', 'th1', '2');


--
-- TOC entry 4026 (class 0 OID 44182)
-- Dependencies: 225
-- Data for Name: concept_group_historique; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4028 (class 0 OID 44192)
-- Dependencies: 227
-- Data for Name: concept_group_label; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.concept_group_label (id, lexicalvalue, created, modified, lang, idthesaurus, idgroup) VALUES (2, 'collect1', '2022-01-12 00:00:00', '2022-01-12 00:00:00', 'en', 'th1', 'G3');


--
-- TOC entry 4030 (class 0 OID 44203)
-- Dependencies: 229
-- Data for Name: concept_group_label_historique; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.concept_group_label_historique (id, lexicalvalue, modified, lang, idthesaurus, idgroup, id_user) VALUES (2, 'collect1', '2022-01-12 12:55:11.191981', 'en', 'th1', 'G3', 1);


--
-- TOC entry 4031 (class 0 OID 44211)
-- Dependencies: 230
-- Data for Name: concept_group_type; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.concept_group_type (code, label, skoslabel) VALUES ('MT', 'Microthesaurus', 'MicroThesaurus');
INSERT INTO public.concept_group_type (code, label, skoslabel) VALUES ('G', 'Group', 'ConceptGroup');
INSERT INTO public.concept_group_type (code, label, skoslabel) VALUES ('C', 'Collection', 'Collection');
INSERT INTO public.concept_group_type (code, label, skoslabel) VALUES ('T', 'Theme', 'Theme');


--
-- TOC entry 4033 (class 0 OID 44219)
-- Dependencies: 232
-- Data for Name: concept_historique; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.concept_historique (id_concept, id_thesaurus, id_ark, modified, status, notation, top_concept, id_group, id, id_user) VALUES ('2', 'th1', '', '2022-01-12 12:55:26.18484+01', 'D', 'N1', true, 'G3', 2, 1);


--
-- TOC entry 4034 (class 0 OID 44228)
-- Dependencies: 233
-- Data for Name: concept_replacedby; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4035 (class 0 OID 44235)
-- Dependencies: 234
-- Data for Name: concept_term_candidat; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4036 (class 0 OID 44241)
-- Dependencies: 235
-- Data for Name: copyright; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4037 (class 0 OID 44247)
-- Dependencies: 236
-- Data for Name: corpus_link; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4038 (class 0 OID 44254)
-- Dependencies: 237
-- Data for Name: custom_concept_attribute; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4039 (class 0 OID 44260)
-- Dependencies: 238
-- Data for Name: custom_term_attribute; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4040 (class 0 OID 44266)
-- Dependencies: 239
-- Data for Name: external_images; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4042 (class 0 OID 44275)
-- Dependencies: 241
-- Data for Name: gps; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4044 (class 0 OID 44283)
-- Dependencies: 243
-- Data for Name: gps_preferences; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4045 (class 0 OID 44293)
-- Dependencies: 244
-- Data for Name: hierarchical_relationship; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4046 (class 0 OID 44299)
-- Dependencies: 245
-- Data for Name: hierarchical_relationship_historique; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4047 (class 0 OID 44306)
-- Dependencies: 246
-- Data for Name: homepage; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.homepage (htmlcode, lang) VALUES ('<p>Help and tutorials : <a href="https://opentheso.hypotheses.org" rel="noopener noreferrer" target="_blank" style="color: blue;">https://opentheso.hypotheses.org</a></p><p><strong style="color: rgb(230, 0, 0);">!!!!! To get started, select a thesaurus in the upper right !!!!!</strong></p><p>Opentheso is distributed under a free French law license compatible with the license <a href="http://www.gnu.org/copyleft/gpl.html" rel="noopener noreferrer" target="_blank" style="color: blue;">GNU GPL</a></p><p>It is a multilingual thesaurus manager, developed by the Technological Platform <a href="https://www.mom.fr/plateformes-technologiques/web-semantique-et-thesauri" rel="noopener noreferrer" target="_blank" style="color: blue;">WST</a> (Semantic Web &amp; Thesauri) located at <a href="https://www.mom.fr" rel="noopener noreferrer" target="_blank" style="color: blue;">MOM</a></p><p>in partnership with the <a href="http://www.frantiq.fr" rel="noopener noreferrer" target="_blank" style="color: blue;">GDS-FRANTIQ</a></p><p>&nbsp;</p><p><span style="color: black;">Designer : Brann Etienne</span><strong style="color: black;"> (</strong><a href="http://ithaqstudio.com/" rel="noopener noreferrer" target="_blank" style="color: rgb(149, 79, 114);"><strong>ithaqstudio.com</strong></a><strong style="color: black;">) </strong></p><p>Design integrator : Miled Rousset</p><p>&nbsp;</p><p>The development of Opentheso is supported in part by the consortium <a href="http://masa.hypotheses.org/" rel="noopener noreferrer" target="_blank" style="color: blue;">MASA </a>(Memory of Archaeologists and Archaeological Sites) of the <a href="http://www.huma-num.fr/" rel="noopener noreferrer" target="_blank" style="color: blue;">TGIR Huma-Num.</a></p><p>Project Manager : <strong>Miled Rousset</strong></p><p>Development : <strong>Miled Rousset, Firas Gabsi, Emmanuelle Perrin, Prudham Jean-Marc, Quincy Mbape Eyoke, Antonio Perez, Carole Bonfré</strong></p><p>Partnership, testing and expertise : <strong>The teams of the network </strong><a href="http://www.frantiq.fr" rel="noopener noreferrer" target="_blank" style="color: blue;"><strong>Frantiq</strong></a> and in particular the group <a href="https://www.frantiq.fr/frantiq/organisation/groupes-de-travail-et-projets/pactols-opentheso/" rel="noopener noreferrer" target="_blank" style="color: blue;">PACTOLS</a>.</p><p>The development was carried out with the following technologies :</p><ul><li>PostgreSQL for the database</li><li>Java for the API and business module</li><li>JSF2 and PrimeFaces for the graphic part</li></ul><p>&nbsp;</p><p><strong>Opentheso</strong> is based on the project <a href="http://ark.mom.fr" rel="noopener noreferrer" target="_blank" style="color: blue;">Arkéo</a> of the MOM to generate ark type identifiers <a href="http://fr.wikipedia.org/wiki/Archival_Resource_Key" rel="noopener noreferrer" target="_blank" style="color: blue;">ARK</a></p><p>Partners :</p><ul><li><a href="http://www.cnrs.fr" rel="noopener noreferrer" target="_blank" style="color: blue;">CNRS</a></li><li><a href="http://www.mom.fr" rel="noopener noreferrer" target="_blank" style="color: blue;">MOM</a></li><li><a href="http://www.frantiq.fr" rel="noopener noreferrer" target="_blank" style="color: blue;">Frantiq</a></li><li><a href="http://masa.hypotheses.org/" rel="noopener noreferrer" target="_blank" style="color: blue;">MASA</a></li><li><a href="http://www.huma-num.fr" rel="noopener noreferrer" target="_blank" style="color: blue;">Huma-Num</a></li></ul>', 'en');
INSERT INTO public.homepage (htmlcode, lang) VALUES ('<p>Aide et tutoriels : <a href="https://opentheso.hypotheses.org" rel="noopener noreferrer" target="_blank" style="color: blue;">https://opentheso.hypotheses.org</a></p><p><strong style="color: rgb(230, 0, 0);">!!!!! Pour commencer, sélectionnez un thésaurus en haut à droite !!!!!</strong></p><p>Opentheso est distribué en licence libre de droit français compatible avec la licence <a href="http://www.gnu.org/copyleft/gpl.html" rel="noopener noreferrer" target="_blank" style="color: blue;">GNU GPL</a></p><p>C''est un gestionnaire de thesaurus multilingue, développé par la plateforme Technologique <a href="https://www.mom.fr/plateformes-technologiques/web-semantique-et-thesauri" rel="noopener noreferrer" target="_blank" style="color: blue;">WST</a> (Web Sémantique &amp; Thesauri) située à la <a href="https://www.mom.fr" rel="noopener noreferrer" target="_blank" style="color: blue;">MOM</a></p><p>en partenariat avec le <a href="http://www.frantiq.fr" rel="noopener noreferrer" target="_blank" style="color: blue;">GDS-FRANTIQ</a></p><p>&nbsp;</p><p><span style="color: black;">Designer : Brann Etienne</span><strong style="color: black;"> (</strong><a href="http://ithaqstudio.com/" rel="noopener noreferrer" target="_blank" style="color: rgb(149, 79, 114);"><strong>ithaqstudio.com</strong></a><strong style="color: black;">) </strong></p><p>Intégrateur du design : Miled Rousset</p><p>&nbsp;</p><p>Le développement d''Opentheso est soutenu en partie par le Consortium <a href="http://masa.hypotheses.org/" rel="noopener noreferrer" target="_blank" style="color: blue;">MASA </a>(Mémoire des archéologues et des Sites Archéologiques) de la <a href="http://www.huma-num.fr/" rel="noopener noreferrer" target="_blank" style="color: blue;">TGIR Huma-Num.</a></p><p>Chef de Projet : <strong>Miled Rousset</strong></p><p>Développement : <strong>Miled Rousset, Firas Gabsi, Emmanuelle Perrin, Prudham Jean-Marc, Quincy Mbape Eyoke, Antonio Perez, Carole Bonfré</strong></p><p>Partenariat, test et expertise : <strong>Les équipes du réseau </strong><a href="http://www.frantiq.fr" rel="noopener noreferrer" target="_blank" style="color: blue;"><strong>Frantiq</strong></a> et en particulier le groupe <a href="https://www.frantiq.fr/frantiq/organisation/groupes-de-travail-et-projets/pactols-opentheso/" rel="noopener noreferrer" target="_blank" style="color: blue;">PACTOLS</a>.</p><p>Le développement a été réalisé avec les technologies suivantes :</p><ul><li>PostgreSQL pour la base des données</li><li>Java pour le module API et module métier</li><li>JSF2 et PrimeFaces pour la partie graphique</li></ul><p>&nbsp;</p><p><strong>Opentheso</strong> s''appuie sur le projet <a href="http://ark.mom.fr" rel="noopener noreferrer" target="_blank" style="color: blue;">Arkéo</a> de la MOM pour générer des identifiants type <a href="http://fr.wikipedia.org/wiki/Archival_Resource_Key" rel="noopener noreferrer" target="_blank" style="color: blue;">ARK</a></p><p>Partenaires :</p><ul><li><a href="http://www.cnrs.fr" rel="noopener noreferrer" target="_blank" style="color: blue;">CNRS</a></li><li><a href="http://www.mom.fr" rel="noopener noreferrer" target="_blank" style="color: blue;">MOM</a></li><li><a href="http://www.frantiq.fr" rel="noopener noreferrer" target="_blank" style="color: blue;">Frantiq</a></li><li><a href="http://masa.hypotheses.org/" rel="noopener noreferrer" target="_blank" style="color: blue;">MASA</a></li><li><a href="http://www.huma-num.fr" rel="noopener noreferrer" target="_blank" style="color: blue;">Huma-Num</a></li></ul>', 'fr');


--
-- TOC entry 4048 (class 0 OID 44312)
-- Dependencies: 247
-- Data for Name: images; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4049 (class 0 OID 44319)
-- Dependencies: 248
-- Data for Name: info; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4051 (class 0 OID 44327)
-- Dependencies: 250
-- Data for Name: languages_iso639; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('aa', 'aar', 'Afar', 'afar', 2);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ab', 'abk', 'Abkhazian', 'abkhaze', 3);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('af', 'afr', 'Afrikaans', 'afrikaans', 4);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ak', 'aka', 'Akan', 'akan', 5);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('sq', 'alb (B)
sqi (T)', 'Albanian', 'albanais', 6);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('am', 'amh', 'Amharic', 'amharique', 7);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ar', 'ara', 'Arabic', 'arabe', 8);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('an', 'arg', 'Aragonese', 'aragonais', 9);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('as', 'asm', 'Assamese', 'assamais', 10);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('av', 'ava', 'Avaric', 'avar', 11);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ae', 'ave', 'Avestan', 'avestique', 12);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ay', 'aym', 'Aymara', 'aymara', 13);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('az', 'aze', 'Azerbaijani', 'azéri', 14);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ba', 'bak', 'Bashkir', 'bachkir', 15);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('bm', 'bam', 'Bambara', 'bambara', 16);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('eu', 'baq (B)
eus (T)', 'Basque', 'basque', 17);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('be', 'bel', 'Belarusian', 'biélorusse', 18);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('bn', 'ben', 'Bengali', 'bengali', 19);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('bh', 'bih', 'Bihari languages', 'langues biharis', 20);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('bi', 'bis', 'Bislama', 'bichlamar', 21);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('bs', 'bos', 'Bosnian', 'bosniaque', 22);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('br', 'bre', 'Breton', 'breton', 23);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('bg', 'bul', 'Bulgarian', 'bulgare', 24);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ca', 'cat', 'Catalan; Valencian', 'catalan; valencien', 25);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ch', 'cha', 'Chamorro', 'chamorro', 26);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ce', 'che', 'Chechen', 'tchétchène', 27);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('zh', 'chi (B)
zho (T)', 'Chinese', 'chinois', 28);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('cv', 'chv', 'Chuvash', 'tchouvache', 29);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('kw', 'cor', 'Cornish', 'cornique', 30);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('co', 'cos', 'Corsican', 'corse', 31);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('cr', 'cre', 'Cree', 'cree', 32);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('cy', 'wel (B)
cym (T)', 'Welsh', 'gallois', 33);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('cs', 'cze (B)
ces (T)', 'Czech', 'tchèque', 34);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('da', 'dan', 'Danish', 'danois', 35);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('de', 'ger (B)
deu (T)', 'German', 'allemand', 36);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('dv', 'div', 'Divehi; Dhivehi; Maldivian', 'maldivien', 37);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('dz', 'dzo', 'Dzongkha', 'dzongkha', 38);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('el', 'gre (B)
ell (T)', 'Greek, Modern (1453-)', 'grec moderne (après 1453)', 39);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('en', 'eng', 'English', 'anglais', 40);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('eo', 'epo', 'Esperanto', 'espéranto', 41);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('et', 'est', 'Estonian', 'estonien', 42);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ee', 'ewe', 'Ewe', 'éwé', 43);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('fo', 'fao', 'Faroese', 'féroïen', 44);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('fj', 'fij', 'Fijian', 'fidjien', 45);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('fi', 'fin', 'Finnish', 'finnois', 46);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('fr', 'fre (B)
fra (T)', 'French', 'français', 47);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('fy', 'fry', 'Western Frisian', 'frison occidental', 48);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ff', 'ful', 'Fulah', 'peul', 49);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ka', 'geo (B)
kat (T)', 'Georgian', 'géorgien', 50);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('gd', 'gla', 'Gaelic; Scottish Gaelic', 'gaélique; gaélique écossais', 51);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ga', 'gle', 'Irish', 'irlandais', 52);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('gl', 'glg', 'Galician', 'galicien', 53);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('gv', 'glv', 'Manx', 'manx; mannois', 54);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('gn', 'grn', 'Guarani', 'guarani', 55);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('gu', 'guj', 'Gujarati', 'goudjrati', 56);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ht', 'hat', 'Haitian; Haitian Creole', 'haïtien; créole haïtien', 57);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ha', 'hau', 'Hausa', 'haoussa', 58);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('he', 'heb', 'Hebrew', 'hébreu', 59);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('hz', 'her', 'Herero', 'herero', 60);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('hi', 'hin', 'Hindi', 'hindi', 61);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ho', 'hmo', 'Hiri Motu', 'hiri motu', 62);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('hr', 'hrv', 'Croatian', 'croate', 63);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('hu', 'hun', 'Hungarian', 'hongrois', 64);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('hy', 'arm (B)
hye (T)', 'Armenian', 'arménien', 65);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ig', 'ibo', 'Igbo', 'igbo', 66);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('is', 'ice (B)
isl (T)', 'Icelandic', 'islandais', 67);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('io', 'ido', 'Ido', 'ido', 68);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ii', 'iii', 'Sichuan Yi; Nuosu', 'yi de Sichuan', 69);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('iu', 'iku', 'Inuktitut', 'inuktitut', 70);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ie', 'ile', 'Interlingue; Occidental', 'interlingue', 71);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('id', 'ind', 'Indonesian', 'indonésien', 72);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ik', 'ipk', 'Inupiaq', 'inupiaq', 73);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('it', 'ita', 'Italian', 'italien', 74);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('jv', 'jav', 'Javanese', 'javanais', 75);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ja', 'jpn', 'Japanese', 'japonais', 76);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('kl', 'kal', 'Kalaallisut; Greenlandic', 'groenlandais', 77);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('kn', 'kan', 'Kannada', 'kannada', 78);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ks', 'kas', 'Kashmiri', 'kashmiri', 79);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('kr', 'kau', 'Kanuri', 'kanouri', 80);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('kk', 'kaz', 'Kazakh', 'kazakh', 81);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('km', 'khm', 'Central Khmer', 'khmer central', 82);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ki', 'kik', 'Kikuyu; Gikuyu', 'kikuyu', 83);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('rw', 'kin', 'Kinyarwanda', 'rwanda', 84);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ky', 'kir', 'Kirghiz; Kyrgyz', 'kirghiz', 85);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('kv', 'kom', 'Komi', 'kom', 86);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('kg', 'kon', 'Kongo', 'kongo', 87);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ko', 'kor', 'Korean', 'coréen', 88);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('kj', 'kua', 'Kuanyama; Kwanyama', 'kuanyama; kwanyama', 89);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ku', 'kur', 'Kurdish', 'kurde', 90);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('lo', 'lao', 'Lao', 'lao', 91);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('la', 'lat', 'Latin', 'latin', 92);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('lv', 'lav', 'Latvian', 'letton', 93);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('li', 'lim', 'Limburgan; Limburger; Limburgish', 'limbourgeois', 94);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ln', 'lin', 'Lingala', 'lingala', 95);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('lt', 'lit', 'Lithuanian', 'lituanien', 96);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('lb', 'ltz', 'Luxembourgish; Letzeburgesch', 'luxembourgeois', 97);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('lu', 'lub', 'Luba-Katanga', 'luba-katanga', 98);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('lg', 'lug', 'Ganda', 'ganda', 99);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('mk', 'mac (B)
mkd (T)', 'Macedonian', 'macédonien', 100);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('mh', 'mah', 'Marshallese', 'marshall', 101);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ml', 'mal', 'Malayalam', 'malayalam', 102);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('mr', 'mar', 'Marathi', 'marathe', 103);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ms', 'may (B)
msa (T)', 'Malay', 'malais', 104);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('mg', 'mlg', 'Malagasy', 'malgache', 105);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('mt', 'mlt', 'Maltese', 'maltais', 106);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('mn', 'mon', 'Mongolian', 'mongol', 107);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('mi', 'mao (B)
mri (T)', 'Maori', 'maori', 108);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('my', 'bur (B)
mya (T)', 'Burmese', 'birman', 109);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('na', 'nau', 'Nauru', 'nauruan', 110);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('nv', 'nav', 'Navajo; Navaho', 'navaho', 111);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('nr', 'nbl', 'Ndebele, South; South Ndebele', 'ndébélé du Sud', 112);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('nd', 'nde', 'Ndebele, North; North Ndebele', 'ndébélé du Nord', 113);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ng', 'ndo', 'Ndonga', 'ndonga', 114);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ne', 'nep', 'Nepali', 'népalais', 115);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('nl', 'dut (B)
nld (T)', 'Dutch; Flemish', 'néerlandais; flamand', 116);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('nb', 'nob', 'Bokmål, Norwegian; Norwegian Bokmål', 'norvégien bokmål', 117);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('no', 'nor', 'Norwegian', 'norvégien', 118);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ny', 'nya', 'Chichewa; Chewa; Nyanja', 'chichewa; chewa; nyanja', 119);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('oc', 'oci', 'Occitan (post 1500)', 'occitan (après 1500)', 120);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('oj', 'oji', 'Ojibwa', 'ojibwa', 121);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('or', 'ori', 'Oriya', 'oriya', 122);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('om', 'orm', 'Oromo', 'galla', 123);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('os', 'oss', 'Ossetian; Ossetic', 'ossète', 124);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('pa', 'pan', 'Panjabi; Punjabi', 'pendjabi', 125);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('fa', 'per (B)
fas (T)', 'Persian', 'persan', 126);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('pi', 'pli', 'Pali', 'pali', 127);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('pl', 'pol', 'Polish', 'polonais', 128);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('pt', 'por', 'Portuguese', 'portugais', 129);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ps', 'pus', 'Pushto; Pashto', 'pachto', 130);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('qu', 'que', 'Quechua', 'quechua', 131);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('rm', 'roh', 'Romansh', 'romanche', 132);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ro', 'rum (B)
ron (T)', 'Romanian; Moldavian; Moldovan', 'roumain; moldave', 133);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('rn', 'run', 'Rundi', 'rundi', 134);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ru', 'rus', 'Russian', 'russe', 135);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('sg', 'sag', 'Sango', 'sango', 136);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('sa', 'san', 'Sanskrit', 'sanskrit', 137);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('si', 'sin', 'Sinhala; Sinhalese', 'singhalais', 138);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('sk', 'slo (B)
slk (T)', 'Slovak', 'slovaque', 139);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('sl', 'slv', 'Slovenian', 'slovène', 140);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('se', 'sme', 'Northern Sami', 'sami du Nord', 141);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('sm', 'smo', 'Samoan', 'samoan', 142);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('sn', 'sna', 'Shona', 'shona', 143);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('sd', 'snd', 'Sindhi', 'sindhi', 144);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('so', 'som', 'Somali', 'somali', 145);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('st', 'sot', 'Sotho, Southern', 'sotho du Sud', 146);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('es', 'spa', 'Spanish; Castilian', 'espagnol; castillan', 147);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('sc', 'srd', 'Sardinian', 'sarde', 148);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('sr', 'srp', 'Serbian', 'serbe', 149);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ss', 'ssw', 'Swati', 'swati', 150);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('su', 'sun', 'Sundanese', 'soundanais', 151);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('sw', 'swa', 'Swahili', 'swahili', 152);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('sv', 'swe', 'Swedish', 'suédois', 153);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ty', 'tah', 'Tahitian', 'tahitien', 154);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ta', 'tam', 'Tamil', 'tamoul', 155);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('tt', 'tat', 'Tatar', 'tatar', 156);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('te', 'tel', 'Telugu', 'télougou', 157);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('tg', 'tgk', 'Tajik', 'tadjik', 158);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('tl', 'tgl', 'Tagalog', 'tagalog', 159);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('th', 'tha', 'Thai', 'thaï', 160);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('bo', 'tib (B)
bod (T)', 'Tibetan', 'tibétain', 161);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ti', 'tir', 'Tigrinya', 'tigrigna', 162);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('to', 'ton', 'Tonga (Tonga Islands)', 'tongan (Îles Tonga)', 163);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('tn', 'tsn', 'Tswana', 'tswana', 164);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ts', 'tso', 'Tsonga', 'tsonga', 165);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('tk', 'tuk', 'Turkmen', 'turkmène', 166);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('tr', 'tur', 'Turkish', 'turc', 167);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('tw', 'twi', 'Twi', 'twi', 168);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ug', 'uig', 'Uighur; Uyghur', 'ouïgour', 169);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('uk', 'ukr', 'Ukrainian', 'ukrainien', 170);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ur', 'urd', 'Urdu', 'ourdou', 171);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('uz', 'uzb', 'Uzbek', 'ouszbek', 172);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ve', 'ven', 'Venda', 'venda', 173);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('vi', 'vie', 'Vietnamese', 'vietnamien', 174);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('vo', 'vol', 'Volapük', 'volapük', 175);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('wa', 'wln', 'Walloon', 'wallon', 176);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('wo', 'wol', 'Wolof', 'wolof', 177);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('xh', 'xho', 'Xhosa', 'xhosa', 178);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('yi', 'yid', 'Yiddish', 'yiddish', 179);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('yo', 'yor', 'Yoruba', 'yoruba', 180);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('za', 'zha', 'Zhuang; Chuang', 'zhuang; chuang', 181);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('zu', 'zul', 'Zulu', 'zoulou', 182);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('cu', 'chu', 'Church Slavic; Old Slavonic; Church Slavonic; Old Bulgarian; Old Church Slavonic', 'vieux slave; vieux bulgare', 183);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ia', 'ina', 'Interlingua (International Auxiliary Language Association)', 'interlingua', 184);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('nn', 'nno', 'Norwegian Nynorsk; Nynorsk, Norwegian', 'norvégien nynorsk', 185);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('gr', 'grc', 'Greek, Ancient (to 1453)', 'grec ancien (jusqu''à 1453)', 186);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('iso', 'iso', 'norme ISO 233-2 (1993)', 'norme ISO 233-2 (1993)', 187);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('ala', 'ala', 'ALA-LC Romanization Table (American Library Association-Library of Congress)', 'ALA-LC)', 188);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('mul', 'mul', 'multiple langages', 'multiple langages', 189);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('zh-Hans', 'zh-Hans', 'chinese (simplified)', 'chinois (simplifié)', 190);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('zh-Hant', 'zh-Hant', 'chinese (traditional)', 'chinois (traditionnel)', 191);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('zh-Latn-pinyin', 'zh-Latn-pinyin', 'chinese (pinyin)', 'chinois (pinyin)', 192);
INSERT INTO public.languages_iso639 (iso639_1, iso639_2, english_name, french_name, id) VALUES ('bo-x-ewts', 'bo-x-ewts', 'tibetan (ewts)', 'tibétain (ewts)', 193);


--
-- TOC entry 4053 (class 0 OID 44336)
-- Dependencies: 252
-- Data for Name: node_label; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4054 (class 0 OID 44345)
-- Dependencies: 253
-- Data for Name: non_preferred_term; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4055 (class 0 OID 44354)
-- Dependencies: 254
-- Data for Name: non_preferred_term_historique; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4057 (class 0 OID 44364)
-- Dependencies: 256
-- Data for Name: note; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4059 (class 0 OID 44375)
-- Dependencies: 258
-- Data for Name: note_historique; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4060 (class 0 OID 44383)
-- Dependencies: 259
-- Data for Name: note_type; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.note_type (code, isterm, isconcept, label_fr, label_en) VALUES ('note', false, true, 'Note', 'Note');
INSERT INTO public.note_type (code, isterm, isconcept, label_fr, label_en) VALUES ('historyNote', true, true, 'Note historique', 'History note');
INSERT INTO public.note_type (code, isterm, isconcept, label_fr, label_en) VALUES ('scopeNote', false, true, 'Note d''application', 'Scope note');
INSERT INTO public.note_type (code, isterm, isconcept, label_fr, label_en) VALUES ('example', true, false, 'Exemple', 'Example');
INSERT INTO public.note_type (code, isterm, isconcept, label_fr, label_en) VALUES ('editorialNote', true, false, 'Note éditoriale', 'Editorial note');
INSERT INTO public.note_type (code, isterm, isconcept, label_fr, label_en) VALUES ('definition', true, false, 'Définition', 'Definition');
INSERT INTO public.note_type (code, isterm, isconcept, label_fr, label_en) VALUES ('changeNote', true, false, 'Note de changement', 'Change note');


--
-- TOC entry 4061 (class 0 OID 44390)
-- Dependencies: 260
-- Data for Name: nt_type; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.nt_type (id, relation, description_fr, description_en) VALUES (1, 'NT', 'Term spécifique', 'Narrower term');
INSERT INTO public.nt_type (id, relation, description_fr, description_en) VALUES (2, 'NTG', 'Term spécifique (generic)', 'Narrower term (generic)');
INSERT INTO public.nt_type (id, relation, description_fr, description_en) VALUES (3, 'NTP', 'Term spécifique (partitive)', 'Narrower term (partitive)');
INSERT INTO public.nt_type (id, relation, description_fr, description_en) VALUES (4, 'NTI', 'Term spécifique (instantial)', 'Narrower term (instantial)');


--
-- TOC entry 4062 (class 0 OID 44396)
-- Dependencies: 261
-- Data for Name: permuted; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4064 (class 0 OID 44404)
-- Dependencies: 263
-- Data for Name: preferences; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.preferences (id_pref, id_thesaurus, source_lang, identifier_type, path_image, dossier_resize, bdd_active, bdd_use_id, url_bdd, url_counter_bdd, z3950actif, collection_adresse, notice_url, url_encode, path_notice1, path_notice2, chemin_site, webservices, use_ark, server_ark, id_naan, prefix_ark, user_ark, pass_ark, use_handle, user_handle, pass_handle, path_key_handle, path_cert_handle, url_api_handle, prefix_handle, private_prefix_handle, preferredname, original_uri, original_uri_is_ark, original_uri_is_handle, uri_ark, generate_handle, auto_expand_tree, sort_by_notation, tree_cache, original_uri_is_doi, use_ark_local, naan_ark_local, prefix_ark_local, sizeid_ark_local) VALUES (2, 'th1', 'en', 2, '/var/www/images/', 'resize', false, false, 'http://www.mondomaine.fr/concept/##value##', 'http://mondomaine.fr/concept/##conceptId##/total', false, 'KOHA/biblios', 'http://catalogue.mondomaine.fr/cgi-bin/koha/opac-search.pl?type=opac&op=do_search&q=an=terme', 'UTF-8', '/var/www/notices/repositories.xml', '/var/www/notices/SchemaMappings.xml', 'http://mondomaine.fr/', true, false, 'http://ark.mondomaine.fr/ark:/', '66666', 'crt', 'null', 'null', false, 'null', 'null', '/certificat/key.p12', '/certificat/cacerts2', 'https://handle-server.mondomaine.fr:8001/api/handles/', '66.666.66666', 'crt', 'test', 'null', false, false, 'https://ark.mom.fr/ark:/', false, true, false, false, false, false, '', '', 10);


--
-- TOC entry 4065 (class 0 OID 44445)
-- Dependencies: 264
-- Data for Name: preferences_sparql; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4066 (class 0 OID 44452)
-- Dependencies: 265
-- Data for Name: preferred_term; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.preferred_term (id_concept, id_term, id_thesaurus) VALUES ('2', '1', 'th1');


--
-- TOC entry 4067 (class 0 OID 44458)
-- Dependencies: 266
-- Data for Name: proposition; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4068 (class 0 OID 44466)
-- Dependencies: 267
-- Data for Name: relation_group; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4069 (class 0 OID 44472)
-- Dependencies: 268
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.roles (id, name, description) VALUES (1, 'superAdmin', 'Super Administrateur pour tout gérer tout thésaurus et tout utilisateur');
INSERT INTO public.roles (id, name, description) VALUES (2, 'admin', 'administrateur pour un domaine ou parc de thésaurus');
INSERT INTO public.roles (id, name, description) VALUES (3, 'manager', 'gestionnaire de thésaurus, pas de création de thésaurus');
INSERT INTO public.roles (id, name, description) VALUES (4, 'contributor', 'traducteur, notes, candidats, images');


--
-- TOC entry 4071 (class 0 OID 44480)
-- Dependencies: 270
-- Data for Name: routine_mail; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4072 (class 0 OID 44487)
-- Dependencies: 271
-- Data for Name: split_non_preferred_term; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4073 (class 0 OID 44490)
-- Dependencies: 272
-- Data for Name: status; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.status (id_status, value) VALUES (1, 'En attente');
INSERT INTO public.status (id_status, value) VALUES (2, 'Inséré');
INSERT INTO public.status (id_status, value) VALUES (3, 'Rejeté');


--
-- TOC entry 4077 (class 0 OID 44502)
-- Dependencies: 276
-- Data for Name: term; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.term (id_term, lexical_value, lang, id_thesaurus, created, modified, source, status, id, contributor, creator) VALUES ('1', 'top1', 'en', 'th1', '2022-01-12 12:55:26.18484+01', '2022-01-12 12:55:26.18484+01', '', 'D', 2, 1, 1);


--
-- TOC entry 4079 (class 0 OID 44514)
-- Dependencies: 278
-- Data for Name: term_candidat; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4081 (class 0 OID 44525)
-- Dependencies: 280
-- Data for Name: term_historique; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.term_historique (id_term, lexical_value, lang, id_thesaurus, modified, source, status, id, id_user, action) VALUES ('1', 'top1', 'en', 'th1', '2022-01-12 12:55:26.18484+01', '', 'D', 2, 1, NULL);


--
-- TOC entry 4083 (class 0 OID 44536)
-- Dependencies: 282
-- Data for Name: thesaurus; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.thesaurus (id_thesaurus, id_ark, created, modified, id, private) VALUES ('th1', '', '2022-01-12 00:00:00', '2022-01-12 00:00:00', 2, false);


--
-- TOC entry 4084 (class 0 OID 44546)
-- Dependencies: 283
-- Data for Name: thesaurus_alignement_source; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4085 (class 0 OID 44552)
-- Dependencies: 284
-- Data for Name: thesaurus_array; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4086 (class 0 OID 44559)
-- Dependencies: 285
-- Data for Name: thesaurus_label; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.thesaurus_label (id_thesaurus, contributor, coverage, creator, created, modified, description, format, lang, publisher, relation, rights, source, subject, title, type) VALUES ('th1', 'admin', '', 'admin', '2022-01-12 00:00:00', '2022-01-12 00:00:00', '', '', 'en', '', '', '', '', '', 'test', '');


--
-- TOC entry 4087 (class 0 OID 44567)
-- Dependencies: 286
-- Data for Name: thesohomepage; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.thesohomepage (htmlcode, lang, idtheso) VALUES ('<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0

 style=''border-collapse:collapse;border:none''>

 <tr>

 <td width=94 style=''width:70.65pt;padding:0cm 5.4pt 0cm 5.4pt''>

 <p class=MsoNormal><img width=50 height=65 id="Image 1"

 src="Opentheso.fld/image001.png"

 alt="Une image contenant dessin&#10;&#10;Description générée automatiquement"></p>

 </td>

 <td width=510 style=''width:382.15pt;padding:0cm 5.4pt 0cm 5.4pt''>

 <p class=MsoNormal><b><span style=''font-size:18.0pt;font-family:"Times New Roman",serif''>Opentheso</span></b></p>

 <p class=MsoNormal><span style=''font-size:10.0pt;font-family:"Times New Roman",serif''>Copyright

 ©CNRS</span></p>

 </td>

 </tr>

</table>', 'fr', 'th10');
INSERT INTO public.thesohomepage (htmlcode, lang, idtheso) VALUES ('<p><strong>Espace de travail PACTOLS v2</strong></p><p><br></p><ul><li><strong>Les concepts </strong>présentés ici sont issus de la version publique du thésaurus PACTOLS auxquels ont été ajoutés un certain nombre de concepts suggérés (candidats) et des termes demandés par les spécialistes de certains domaines avec lesquels nous travaillons étroitement.</li></ul><p><br></p><ul><li><strong>L''organisation</strong> des concepts telle qu''elle s''affiche aujourd''hui est provisoire. Les dossiers sont susceptibles de changer de nom et d''emplacement dans l''arbre. Les collections vont aussi évoluer, au fur et à mesure que le travail de réorganisation avancera.</li></ul><p><br></p><ul><li><strong>Les identifiants pérennes de ces concepts</strong> ne doivent pas être utilisés pour le moment, car ils renverront une erreur de direction. Ils pointent en effet sur la version publique du thésaurus, toujours disponible à l''adresse : <a href="https://pactols.frantiq.fr/opentheso" rel="noopener noreferrer" target="_blank">https://pactols.frantiq.fr/opentheso</a></li></ul><p><br></p><p><br></p><p><strong class="ql-size-large">Une nouvelle version du thésaurus PACTOLS est prévue pour la fin de l''année 2021.</strong></p><p><br></p><p><br></p><p><br></p><p><br></p><p><br></p>', 'fr', 'th5');
INSERT INTO public.thesohomepage (htmlcode, lang, idtheso) VALUES ('<p>tets de. ll ùmdqdqsd</p><p><br></p><p>fq</p><p>sf</p><p>sf</p><p> qs</p><p>fd</p><p><br></p><p><br></p><p><br></p><p>f qs</p><p>f qsfqsdfqsdf qsf</p><p><br></p>', 'fr', 'th11');
INSERT INTO public.thesohomepage (htmlcode, lang, idtheso) VALUES ('<p>Mon thésaurus est diffusé en libre sous licence GPL ....</p><p>dqsd qsd qsdqs</p><p>dqs</p>', 'fr', 'th1');
INSERT INTO public.thesohomepage (htmlcode, lang, idtheso) VALUES ('<p>texte pour New Th47</p>', 'fr', 'th47');
INSERT INTO public.thesohomepage (htmlcode, lang, idtheso) VALUES ('<p>texte pour Theso_th54</p>', 'fr', 'th54');
INSERT INTO public.thesohomepage (htmlcode, lang, idtheso) VALUES ('<p>Unesco thésaurus FR</p>', 'fr', 'th44');
INSERT INTO public.thesohomepage (htmlcode, lang, idtheso) VALUES ('<p>Unesco thesaurus EN</p>', 'en', 'th44');
INSERT INTO public.thesohomepage (htmlcode, lang, idtheso) VALUES ('<p>à propos de Essai 1 </p>', 'fr', 'th55');


--
-- TOC entry 4090 (class 0 OID 44577)
-- Dependencies: 289
-- Data for Name: user_group_label; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4091 (class 0 OID 44584)
-- Dependencies: 290
-- Data for Name: user_group_thesaurus; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4092 (class 0 OID 44590)
-- Dependencies: 291
-- Data for Name: user_role_group; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4093 (class 0 OID 44593)
-- Dependencies: 292
-- Data for Name: user_role_only_on; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4094 (class 0 OID 44600)
-- Dependencies: 293
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: opentheso
--

INSERT INTO public.users (id_user, username, password, active, mail, passtomodify, alertmail, issuperadmin) VALUES (1, 'admin', '21232f297a57a5a743894a0e4a801fc3', true, 'admin@domaine.fr', false, false, true);


--
-- TOC entry 4095 (class 0 OID 44611)
-- Dependencies: 294
-- Data for Name: users2; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4096 (class 0 OID 44620)
-- Dependencies: 295
-- Data for Name: users_historique; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4097 (class 0 OID 44628)
-- Dependencies: 296
-- Data for Name: version_history; Type: TABLE DATA; Schema: public; Owner: opentheso
--



--
-- TOC entry 4108 (class 0 OID 0)
-- Dependencies: 202
-- Name: alignement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.alignement_id_seq', 1, false);


--
-- TOC entry 4109 (class 0 OID 0)
-- Dependencies: 204
-- Name: alignement_preferences_id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.alignement_preferences_id_seq', 1, false);


--
-- TOC entry 4110 (class 0 OID 0)
-- Dependencies: 206
-- Name: alignement_source__id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.alignement_source__id_seq', 195, true);


--
-- TOC entry 4111 (class 0 OID 0)
-- Dependencies: 210
-- Name: candidat_messages_id_message_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.candidat_messages_id_message_seq', 13, true);


--
-- TOC entry 4112 (class 0 OID 0)
-- Dependencies: 214
-- Name: candidat_vote_id_vote_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.candidat_vote_id_vote_seq', 19, true);


--
-- TOC entry 4113 (class 0 OID 0)
-- Dependencies: 216
-- Name: concept__id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.concept__id_seq', 2, true);


--
-- TOC entry 4114 (class 0 OID 0)
-- Dependencies: 218
-- Name: concept_candidat__id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.concept_candidat__id_seq', 1, false);


--
-- TOC entry 4115 (class 0 OID 0)
-- Dependencies: 221
-- Name: concept_group__id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.concept_group__id_seq', 4, true);


--
-- TOC entry 4116 (class 0 OID 0)
-- Dependencies: 224
-- Name: concept_group_historique__id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.concept_group_historique__id_seq', 1, false);


--
-- TOC entry 4117 (class 0 OID 0)
-- Dependencies: 228
-- Name: concept_group_label_historique__id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.concept_group_label_historique__id_seq', 2, true);


--
-- TOC entry 4118 (class 0 OID 0)
-- Dependencies: 226
-- Name: concept_group_label_id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.concept_group_label_id_seq', 2, true);


--
-- TOC entry 4119 (class 0 OID 0)
-- Dependencies: 231
-- Name: concept_historique__id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.concept_historique__id_seq', 2, true);


--
-- TOC entry 4120 (class 0 OID 0)
-- Dependencies: 240
-- Name: facet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.facet_id_seq', 1, false);


--
-- TOC entry 4121 (class 0 OID 0)
-- Dependencies: 242
-- Name: gps_preferences_id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.gps_preferences_id_seq', 1, false);


--
-- TOC entry 4122 (class 0 OID 0)
-- Dependencies: 249
-- Name: languages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.languages_id_seq', 193, true);


--
-- TOC entry 4123 (class 0 OID 0)
-- Dependencies: 255
-- Name: note__id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.note__id_seq', 1, false);


--
-- TOC entry 4124 (class 0 OID 0)
-- Dependencies: 257
-- Name: note_historique__id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.note_historique__id_seq', 1, false);


--
-- TOC entry 4125 (class 0 OID 0)
-- Dependencies: 262
-- Name: pref__id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.pref__id_seq', 2, true);


--
-- TOC entry 4126 (class 0 OID 0)
-- Dependencies: 269
-- Name: role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.role_id_seq', 6, true);


--
-- TOC entry 4127 (class 0 OID 0)
-- Dependencies: 273
-- Name: status_id_status_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.status_id_status_seq', 1, false);


--
-- TOC entry 4128 (class 0 OID 0)
-- Dependencies: 274
-- Name: status_id_status_seq1; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.status_id_status_seq1', 1, false);


--
-- TOC entry 4129 (class 0 OID 0)
-- Dependencies: 275
-- Name: term__id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.term__id_seq', 2, true);


--
-- TOC entry 4130 (class 0 OID 0)
-- Dependencies: 277
-- Name: term_candidat__id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.term_candidat__id_seq', 1, false);


--
-- TOC entry 4131 (class 0 OID 0)
-- Dependencies: 279
-- Name: term_historique__id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.term_historique__id_seq', 2, true);


--
-- TOC entry 4132 (class 0 OID 0)
-- Dependencies: 251
-- Name: thesaurus_array_facet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.thesaurus_array_facet_id_seq', 1, false);


--
-- TOC entry 4133 (class 0 OID 0)
-- Dependencies: 281
-- Name: thesaurus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.thesaurus_id_seq', 2, true);


--
-- TOC entry 4134 (class 0 OID 0)
-- Dependencies: 287
-- Name: user__id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.user__id_seq', 2, false);


--
-- TOC entry 4135 (class 0 OID 0)
-- Dependencies: 288
-- Name: user_group_label__id_seq; Type: SEQUENCE SET; Schema: public; Owner: opentheso
--

SELECT pg_catalog.setval('public.user_group_label__id_seq', 1, false);


--
-- TOC entry 3872 (class 2606 OID 44638)
-- Name: version_history VersionHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.version_history
    ADD CONSTRAINT "VersionHistory_pkey" PRIMARY KEY ("idVersionhistory");


--
-- TOC entry 3703 (class 2606 OID 44640)
-- Name: alignement alignement_internal_id_concept_internal_id_thesaurus_uri_ta_key; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.alignement
    ADD CONSTRAINT alignement_internal_id_concept_internal_id_thesaurus_uri_ta_key UNIQUE (internal_id_concept, internal_id_thesaurus, uri_target);


--
-- TOC entry 3705 (class 2606 OID 44642)
-- Name: alignement alignement_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.alignement
    ADD CONSTRAINT alignement_pkey PRIMARY KEY (id);


--
-- TOC entry 3707 (class 2606 OID 44644)
-- Name: alignement_preferences alignement_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.alignement_preferences
    ADD CONSTRAINT alignement_preferences_pkey PRIMARY KEY (id_thesaurus, id_user, id_concept_depart, id_alignement_source);


--
-- TOC entry 3709 (class 2606 OID 44646)
-- Name: alignement_source alignement_source_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.alignement_source
    ADD CONSTRAINT alignement_source_pkey PRIMARY KEY (id);


--
-- TOC entry 3711 (class 2606 OID 44648)
-- Name: alignement_source alignement_source_source_key; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.alignement_source
    ADD CONSTRAINT alignement_source_source_key UNIQUE (source);


--
-- TOC entry 3713 (class 2606 OID 44650)
-- Name: alignement_type alignment_type_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.alignement_type
    ADD CONSTRAINT alignment_type_pkey PRIMARY KEY (id);


--
-- TOC entry 3715 (class 2606 OID 44652)
-- Name: bt_type bt_type_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.bt_type
    ADD CONSTRAINT bt_type_pkey PRIMARY KEY (id);


--
-- TOC entry 3717 (class 2606 OID 44654)
-- Name: bt_type bt_type_relation_key; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.bt_type
    ADD CONSTRAINT bt_type_relation_key UNIQUE (relation);


--
-- TOC entry 3719 (class 2606 OID 44656)
-- Name: candidat_messages candidat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.candidat_messages
    ADD CONSTRAINT candidat_messages_pkey PRIMARY KEY (id_message);


--
-- TOC entry 3721 (class 2606 OID 44658)
-- Name: candidat_status candidat_status_id_concept_id_thesaurus_key; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.candidat_status
    ADD CONSTRAINT candidat_status_id_concept_id_thesaurus_key UNIQUE (id_concept, id_thesaurus);


--
-- TOC entry 3723 (class 2606 OID 44660)
-- Name: candidat_vote candidat_vote_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.candidat_vote
    ADD CONSTRAINT candidat_vote_pkey PRIMARY KEY (id_vote);


--
-- TOC entry 3725 (class 2606 OID 44662)
-- Name: compound_equivalence compound_equivalence_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.compound_equivalence
    ADD CONSTRAINT compound_equivalence_pkey PRIMARY KEY (id_split_nonpreferredterm, id_preferredterm);


--
-- TOC entry 3730 (class 2606 OID 44664)
-- Name: concept_candidat concept_candidat_id_key; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.concept_candidat
    ADD CONSTRAINT concept_candidat_id_key UNIQUE (id);


--
-- TOC entry 3732 (class 2606 OID 44666)
-- Name: concept_candidat concept_candidat_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.concept_candidat
    ADD CONSTRAINT concept_candidat_pkey PRIMARY KEY (id_concept, id_thesaurus);


--
-- TOC entry 3750 (class 2606 OID 44668)
-- Name: concept_historique concept_copy_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.concept_historique
    ADD CONSTRAINT concept_copy_pkey PRIMARY KEY (id_concept, id_thesaurus, id_group, id_user, modified);


--
-- TOC entry 3734 (class 2606 OID 44670)
-- Name: concept_facet concept_facettes_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.concept_facet
    ADD CONSTRAINT concept_facettes_pkey PRIMARY KEY (id_facet, id_thesaurus, id_concept);


--
-- TOC entry 3752 (class 2606 OID 44672)
-- Name: concept_replacedby concept_fusion_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.concept_replacedby
    ADD CONSTRAINT concept_fusion_pkey PRIMARY KEY (id_concept1, id_concept2, id_thesaurus);


--
-- TOC entry 3738 (class 2606 OID 44674)
-- Name: concept_group_concept concept_group_concept_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.concept_group_concept
    ADD CONSTRAINT concept_group_concept_pkey PRIMARY KEY (idgroup, idthesaurus, idconcept);


--
-- TOC entry 3740 (class 2606 OID 44676)
-- Name: concept_group_historique concept_group_copy_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.concept_group_historique
    ADD CONSTRAINT concept_group_copy_pkey PRIMARY KEY (idgroup, idthesaurus, modified, id_user);


--
-- TOC entry 3746 (class 2606 OID 44678)
-- Name: concept_group_label_historique concept_group_label_copy_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.concept_group_label_historique
    ADD CONSTRAINT concept_group_label_copy_pkey PRIMARY KEY (lang, idthesaurus, lexicalvalue, modified, id_user);


--
-- TOC entry 3742 (class 2606 OID 44680)
-- Name: concept_group_label concept_group_label_idgrouplabel_key; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.concept_group_label
    ADD CONSTRAINT concept_group_label_idgrouplabel_key UNIQUE (id);


--
-- TOC entry 3744 (class 2606 OID 44877)
-- Name: concept_group_label concept_group_label_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.concept_group_label
    ADD CONSTRAINT concept_group_label_pkey PRIMARY KEY (lang, idthesaurus, lexicalvalue);


--
-- TOC entry 3736 (class 2606 OID 44684)
-- Name: concept_group concept_group_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.concept_group
    ADD CONSTRAINT concept_group_pkey PRIMARY KEY (idgroup, idthesaurus);


--
-- TOC entry 3748 (class 2606 OID 44686)
-- Name: concept_group_type concept_group_type_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.concept_group_type
    ADD CONSTRAINT concept_group_type_pkey PRIMARY KEY (code, label);


--
-- TOC entry 3728 (class 2606 OID 44688)
-- Name: concept concept_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.concept
    ADD CONSTRAINT concept_pkey PRIMARY KEY (id_concept, id_thesaurus);


--
-- TOC entry 3754 (class 2606 OID 44690)
-- Name: concept_term_candidat concept_term_candidat_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.concept_term_candidat
    ADD CONSTRAINT concept_term_candidat_pkey PRIMARY KEY (id_concept, id_term, id_thesaurus);


--
-- TOC entry 3756 (class 2606 OID 44692)
-- Name: copyright copyright_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.copyright
    ADD CONSTRAINT copyright_pkey PRIMARY KEY (id_thesaurus);


--
-- TOC entry 3758 (class 2606 OID 44694)
-- Name: corpus_link corpus_link_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.corpus_link
    ADD CONSTRAINT corpus_link_pkey PRIMARY KEY (id_theso, corpus_name);


--
-- TOC entry 3760 (class 2606 OID 44696)
-- Name: custom_concept_attribute custom_concept_attribute_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.custom_concept_attribute
    ADD CONSTRAINT custom_concept_attribute_pkey PRIMARY KEY ("idConcept");


--
-- TOC entry 3762 (class 2606 OID 44698)
-- Name: custom_term_attribute custom_term_attribute_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.custom_term_attribute
    ADD CONSTRAINT custom_term_attribute_pkey PRIMARY KEY (identifier);


--
-- TOC entry 3764 (class 2606 OID 44700)
-- Name: external_images external_images_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.external_images
    ADD CONSTRAINT external_images_pkey PRIMARY KEY (id_concept, id_thesaurus, external_uri);


--
-- TOC entry 3766 (class 2606 OID 44702)
-- Name: gps gps_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.gps
    ADD CONSTRAINT gps_pkey PRIMARY KEY (id_concept, id_theso);


--
-- TOC entry 3768 (class 2606 OID 44704)
-- Name: gps_preferences gps_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.gps_preferences
    ADD CONSTRAINT gps_preferences_pkey PRIMARY KEY (id_thesaurus, id_user, id_alignement_source);


--
-- TOC entry 3772 (class 2606 OID 44706)
-- Name: hierarchical_relationship_historique hierarchical_relationship_copy_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.hierarchical_relationship_historique
    ADD CONSTRAINT hierarchical_relationship_copy_pkey PRIMARY KEY (id_concept1, id_thesaurus, role, id_concept2, modified, id_user);


--
-- TOC entry 3770 (class 2606 OID 44708)
-- Name: hierarchical_relationship hierarchical_relationship_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.hierarchical_relationship
    ADD CONSTRAINT hierarchical_relationship_pkey PRIMARY KEY (id_concept1, id_thesaurus, role, id_concept2);


--
-- TOC entry 3774 (class 2606 OID 44710)
-- Name: homepage homepage_lang_key; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.homepage
    ADD CONSTRAINT homepage_lang_key UNIQUE (lang);


--
-- TOC entry 3776 (class 2606 OID 44712)
-- Name: images images_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id_concept, id_thesaurus, external_uri);


--
-- TOC entry 3778 (class 2606 OID 44867)
-- Name: languages_iso639 languages_iso639_iso639_1_key; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.languages_iso639
    ADD CONSTRAINT languages_iso639_iso639_1_key UNIQUE (iso639_1);


--
-- TOC entry 3780 (class 2606 OID 44718)
-- Name: languages_iso639 languages_iso639_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.languages_iso639
    ADD CONSTRAINT languages_iso639_pkey PRIMARY KEY (id);


--
-- TOC entry 3783 (class 2606 OID 44720)
-- Name: non_preferred_term non_prefered_term_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.non_preferred_term
    ADD CONSTRAINT non_prefered_term_pkey PRIMARY KEY (id_term, lexical_value, lang, id_thesaurus);


--
-- TOC entry 3786 (class 2606 OID 44722)
-- Name: non_preferred_term_historique non_preferred_term_copy_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.non_preferred_term_historique
    ADD CONSTRAINT non_preferred_term_copy_pkey PRIMARY KEY (id_term, lexical_value, lang, id_thesaurus, modified, id_user);


--
-- TOC entry 3791 (class 2606 OID 44724)
-- Name: note_historique note_copy_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.note_historique
    ADD CONSTRAINT note_copy_pkey PRIMARY KEY (id, modified, id_user);


--
-- TOC entry 3789 (class 2606 OID 44730)
-- Name: note note_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.note
    ADD CONSTRAINT note_pkey PRIMARY KEY (id);


--
-- TOC entry 3795 (class 2606 OID 44732)
-- Name: nt_type nt_type_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.nt_type
    ADD CONSTRAINT nt_type_pkey PRIMARY KEY (id);


--
-- TOC entry 3797 (class 2606 OID 44734)
-- Name: nt_type nt_type_relation_key; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.nt_type
    ADD CONSTRAINT nt_type_relation_key UNIQUE (relation);


--
-- TOC entry 3800 (class 2606 OID 44736)
-- Name: permuted permuted_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.permuted
    ADD CONSTRAINT permuted_pkey PRIMARY KEY (ord, id_concept, id_group, id_thesaurus, id_lang, lexical_value, ispreferredterm);


--
-- TOC entry 3793 (class 2606 OID 44738)
-- Name: note_type pk_note_type; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.note_type
    ADD CONSTRAINT pk_note_type PRIMARY KEY (code);


--
-- TOC entry 3814 (class 2606 OID 44740)
-- Name: relation_group pk_relation_group; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.relation_group
    ADD CONSTRAINT pk_relation_group PRIMARY KEY (id_group1, id_thesaurus, relation, id_group2);


--
-- TOC entry 3802 (class 2606 OID 44742)
-- Name: preferences preferences_id_thesaurus_key; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.preferences
    ADD CONSTRAINT preferences_id_thesaurus_key UNIQUE (id_thesaurus);


--
-- TOC entry 3804 (class 2606 OID 44744)
-- Name: preferences preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.preferences
    ADD CONSTRAINT preferences_pkey PRIMARY KEY (id_pref);


--
-- TOC entry 3806 (class 2606 OID 44746)
-- Name: preferences preferences_preferredname_key; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.preferences
    ADD CONSTRAINT preferences_preferredname_key UNIQUE (preferredname);


--
-- TOC entry 3808 (class 2606 OID 44748)
-- Name: preferences_sparql preferences_sparql_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.preferences_sparql
    ADD CONSTRAINT preferences_sparql_pkey PRIMARY KEY (thesaurus);


--
-- TOC entry 3810 (class 2606 OID 44750)
-- Name: preferred_term preferred_term_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.preferred_term
    ADD CONSTRAINT preferred_term_pkey PRIMARY KEY (id_concept, id_thesaurus);


--
-- TOC entry 3812 (class 2606 OID 44752)
-- Name: proposition proposition_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.proposition
    ADD CONSTRAINT proposition_pkey PRIMARY KEY (id_concept, id_user, id_thesaurus);


--
-- TOC entry 3816 (class 2606 OID 44754)
-- Name: roles role_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- TOC entry 3818 (class 2606 OID 44756)
-- Name: routine_mail routine_mail_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.routine_mail
    ADD CONSTRAINT routine_mail_pkey PRIMARY KEY (id_thesaurus);


--
-- TOC entry 3820 (class 2606 OID 44758)
-- Name: status status_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.status
    ADD CONSTRAINT status_pkey PRIMARY KEY (id_status);


--
-- TOC entry 3831 (class 2606 OID 44760)
-- Name: term_candidat term_candidat_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.term_candidat
    ADD CONSTRAINT term_candidat_pkey PRIMARY KEY (id_term, lexical_value, lang, id_thesaurus, contributor);


--
-- TOC entry 3834 (class 2606 OID 44762)
-- Name: term_historique term_copy_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.term_historique
    ADD CONSTRAINT term_copy_pkey PRIMARY KEY (id, modified, id_user);


--
-- TOC entry 3823 (class 2606 OID 44764)
-- Name: term term_id_term_key; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.term
    ADD CONSTRAINT term_id_term_key UNIQUE (id_term, lang, id_thesaurus);


--
-- TOC entry 3825 (class 2606 OID 44766)
-- Name: term term_id_term_lexical_value_lang_id_thesaurus_key; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.term
    ADD CONSTRAINT term_id_term_lexical_value_lang_id_thesaurus_key UNIQUE (id_term, lexical_value, lang, id_thesaurus);


--
-- TOC entry 3828 (class 2606 OID 44768)
-- Name: term term_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.term
    ADD CONSTRAINT term_pkey PRIMARY KEY (id);


--
-- TOC entry 3838 (class 2606 OID 44770)
-- Name: thesaurus_alignement_source thesaurus_alignement_source_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.thesaurus_alignement_source
    ADD CONSTRAINT thesaurus_alignement_source_pkey PRIMARY KEY (id_thesaurus, id_alignement_source);


--
-- TOC entry 3840 (class 2606 OID 44772)
-- Name: thesaurus_array thesaurus_array_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.thesaurus_array
    ADD CONSTRAINT thesaurus_array_pkey PRIMARY KEY (id_facet, id_thesaurus, id_concept_parent);


--
-- TOC entry 3842 (class 2606 OID 44774)
-- Name: thesaurus_label thesaurus_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.thesaurus_label
    ADD CONSTRAINT thesaurus_pkey PRIMARY KEY (id_thesaurus, lang, title);


--
-- TOC entry 3836 (class 2606 OID 44776)
-- Name: thesaurus thesaurus_pkey1; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.thesaurus
    ADD CONSTRAINT thesaurus_pkey1 PRIMARY KEY (id_thesaurus, id_ark);


--
-- TOC entry 3846 (class 2606 OID 44778)
-- Name: thesohomepage thesohomepage_idtheso_lang_key; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.thesohomepage
    ADD CONSTRAINT thesohomepage_idtheso_lang_key UNIQUE (idtheso, lang);


--
-- TOC entry 3844 (class 2606 OID 44780)
-- Name: thesaurus_label unique_thesau_lang; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.thesaurus_label
    ADD CONSTRAINT unique_thesau_lang UNIQUE (id_thesaurus, lang);


--
-- TOC entry 3848 (class 2606 OID 44782)
-- Name: user_group_label user_group-label_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.user_group_label
    ADD CONSTRAINT "user_group-label_pkey" PRIMARY KEY (id_group);


--
-- TOC entry 3854 (class 2606 OID 44784)
-- Name: user_role_group user_group_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.user_role_group
    ADD CONSTRAINT user_group_pkey UNIQUE (id_user, id_group);


--
-- TOC entry 3850 (class 2606 OID 44786)
-- Name: user_group_thesaurus user_group_thesaurus_id_thesaurus_key; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.user_group_thesaurus
    ADD CONSTRAINT user_group_thesaurus_id_thesaurus_key UNIQUE (id_thesaurus);


--
-- TOC entry 3852 (class 2606 OID 44788)
-- Name: user_group_thesaurus user_group_thesaurus_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.user_group_thesaurus
    ADD CONSTRAINT user_group_thesaurus_pkey PRIMARY KEY (id_group, id_thesaurus);


--
-- TOC entry 3858 (class 2606 OID 44790)
-- Name: users user_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_pkey PRIMARY KEY (id_user);


--
-- TOC entry 3856 (class 2606 OID 44792)
-- Name: user_role_only_on user_role_only_on_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.user_role_only_on
    ADD CONSTRAINT user_role_only_on_pkey PRIMARY KEY (id_user, id_role, id_theso);


--
-- TOC entry 3870 (class 2606 OID 44794)
-- Name: users_historique users_historique_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.users_historique
    ADD CONSTRAINT users_historique_pkey PRIMARY KEY (id_user);


--
-- TOC entry 3864 (class 2606 OID 44796)
-- Name: users2 users_login_key; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.users2
    ADD CONSTRAINT users_login_key UNIQUE (login);


--
-- TOC entry 3866 (class 2606 OID 44798)
-- Name: users2 users_mail_key; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.users2
    ADD CONSTRAINT users_mail_key UNIQUE (mail);


--
-- TOC entry 3860 (class 2606 OID 44800)
-- Name: users users_mail_key1; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_mail_key1 UNIQUE (mail);


--
-- TOC entry 3868 (class 2606 OID 44802)
-- Name: users2 users_pkey; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.users2
    ADD CONSTRAINT users_pkey PRIMARY KEY (id_user);


--
-- TOC entry 3862 (class 2606 OID 44804)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: opentheso
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 3726 (class 1259 OID 44805)
-- Name: concept_notation_unaccent; Type: INDEX; Schema: public; Owner: opentheso
--

CREATE INDEX concept_notation_unaccent ON public.concept USING gin (public.f_unaccent(lower((notation)::text)) public.gin_trgm_ops);


--
-- TOC entry 3821 (class 1259 OID 44806)
-- Name: index_lexical_value; Type: INDEX; Schema: public; Owner: opentheso
--

CREATE INDEX index_lexical_value ON public.term USING btree (lexical_value);


--
-- TOC entry 3832 (class 1259 OID 44807)
-- Name: index_lexical_value_copy; Type: INDEX; Schema: public; Owner: opentheso
--

CREATE INDEX index_lexical_value_copy ON public.term_historique USING btree (lexical_value);


--
-- TOC entry 3781 (class 1259 OID 44808)
-- Name: index_lexical_value_npt; Type: INDEX; Schema: public; Owner: opentheso
--

CREATE INDEX index_lexical_value_npt ON public.non_preferred_term USING btree (lexical_value);


--
-- TOC entry 3787 (class 1259 OID 44809)
-- Name: note_lexical_value_unaccent; Type: INDEX; Schema: public; Owner: opentheso
--

CREATE INDEX note_lexical_value_unaccent ON public.note USING gin (public.f_unaccent(lower((lexicalvalue)::text)) public.gin_trgm_ops);


--
-- TOC entry 3798 (class 1259 OID 44810)
-- Name: permuted_lexical_value_idx; Type: INDEX; Schema: public; Owner: opentheso
--

CREATE INDEX permuted_lexical_value_idx ON public.permuted USING btree (lexical_value);


--
-- TOC entry 3784 (class 1259 OID 44811)
-- Name: term_lexical_value_npt_unaccent; Type: INDEX; Schema: public; Owner: opentheso
--

CREATE INDEX term_lexical_value_npt_unaccent ON public.non_preferred_term USING gin (public.f_unaccent(lower((lexical_value)::text)) public.gin_trgm_ops);


--
-- TOC entry 3826 (class 1259 OID 44812)
-- Name: term_lexical_value_unaccent; Type: INDEX; Schema: public; Owner: opentheso
--

CREATE INDEX term_lexical_value_unaccent ON public.term USING gin (public.f_unaccent(lower((lexical_value)::text)) public.gin_trgm_ops);


--
-- TOC entry 3829 (class 1259 OID 44813)
-- Name: terms_values_gin; Type: INDEX; Schema: public; Owner: opentheso
--

CREATE INDEX terms_values_gin ON public.term USING gin (lexical_value public.gin_trgm_ops);


-- Completed on 2022-01-14 09:27:32 CET

--
-- PostgreSQL database dump complete
--

