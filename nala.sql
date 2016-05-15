-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler  version: 0.8.1-alpha
-- PostgreSQL version: 9.3
-- Project Site: pgmodeler.com.br
-- Model Author: ---

SET check_function_bodies = false;
-- ddl-end --


-- Database creation must be done outside an multicommand file.
-- These commands were put in this file only for convenience.
-- -- object: nala | type: DATABASE --
-- -- DROP DATABASE IF EXISTS nala;
-- CREATE DATABASE nala
-- ;
-- -- ddl-end --
-- 

-- object: auth | type: SCHEMA --
-- DROP SCHEMA IF EXISTS auth CASCADE;
CREATE SCHEMA auth;
-- ddl-end --
ALTER SCHEMA auth OWNER TO postgres;
-- ddl-end --

-- object: crawler | type: SCHEMA --
-- DROP SCHEMA IF EXISTS crawler CASCADE;
CREATE SCHEMA crawler;
-- ddl-end --
ALTER SCHEMA crawler OWNER TO postgres;
-- ddl-end --

-- object: backend | type: SCHEMA --
-- DROP SCHEMA IF EXISTS backend CASCADE;
CREATE SCHEMA backend;
-- ddl-end --
ALTER SCHEMA backend OWNER TO postgres;
-- ddl-end --

-- object: analysis | type: SCHEMA --
-- DROP SCHEMA IF EXISTS analysis CASCADE;
CREATE SCHEMA analysis;
-- ddl-end --
ALTER SCHEMA analysis OWNER TO postgres;
-- ddl-end --

-- object: dictionary | type: SCHEMA --
-- DROP SCHEMA IF EXISTS dictionary CASCADE;
CREATE SCHEMA dictionary;
-- ddl-end --
ALTER SCHEMA dictionary OWNER TO postgres;
-- ddl-end --

SET search_path TO pg_catalog,public,auth,crawler,backend,analysis,dictionary;
-- ddl-end --

-- object: crawler.crawler_hash_generator | type: FUNCTION --
-- DROP FUNCTION IF EXISTS crawler.crawler_hash_generator(IN integer) CASCADE;
CREATE FUNCTION crawler.crawler_hash_generator (OUT result bigint, IN table_id integer DEFAULT 1)
	RETURNS bigint
	LANGUAGE plpgsql
	VOLATILE 
	STRICT
	SECURITY INVOKER
	COST 1
	AS $$
DECLARE
    our_epoch bigint := 1314220021721;
    seq_id bigint;
    now_millis bigint;
BEGIN
    SELECT nextval('crawler.crawler_hash_seq') % 1024 INTO seq_id;

SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) INTO now_millis;
    result := (now_millis - our_epoch) << 23;
    result := result | (table_id << 10);
    result := result | (seq_id);
END;
$$;
-- ddl-end --
ALTER FUNCTION crawler.crawler_hash_generator(IN integer) OWNER TO postgres;
-- ddl-end --

-- object: crawler.crawler_hash_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS crawler.crawler_hash_seq CASCADE;
CREATE SEQUENCE crawler.crawler_hash_seq
	INCREMENT BY 1
	MINVALUE 0
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE crawler.crawler_hash_seq OWNER TO postgres;
-- ddl-end --

-- object: auth.administrators | type: TABLE --
-- DROP TABLE IF EXISTS auth.administrators CASCADE;
CREATE TABLE auth.administrators(
	id serial NOT NULL,
	user_name character varying(30) NOT NULL,
	password character(32) NOT NULL,
	last_login timestamp with time zone,
	last_login_ip inet,
	login_attempts smallint NOT NULL DEFAULT 0,
	last_login_attempt timestamp with time zone,
	CONSTRAINT "administrators_PKEY" PRIMARY KEY (id),
	CONSTRAINT "administrators_user_name_UNIQ" UNIQUE (user_name)

);
-- ddl-end --
COMMENT ON COLUMN auth.administrators.password IS 'Utilizar md5 con sal';
-- ddl-end --
COMMENT ON COLUMN auth.administrators.login_attempts IS 'Cantidad de intentos de login, se resetea a 0 si el usuario se loguea correctamente o si last_login_attempt supera el rango de tiempo establecido';
-- ddl-end --
ALTER TABLE auth.administrators OWNER TO postgres;
-- ddl-end --

-- Appended SQL commands --
INSERT INTO auth.administrators (user_name,password) VALUES ('felipe',md5(concat('12345','HD#D@)@D@D(@D@HD@DJ@F#B#F#)')));
-- ddl-end --

-- object: "admin_user_name_INX" | type: INDEX --
-- DROP INDEX IF EXISTS auth."admin_user_name_INX" CASCADE;
CREATE INDEX "admin_user_name_INX" ON auth.administrators
	USING btree
	(
	  user_name ASC NULLS LAST
	);
-- ddl-end --

-- object: backend.targets | type: TABLE --
-- DROP TABLE IF EXISTS backend.targets CASCADE;
CREATE TABLE backend.targets(
	id serial NOT NULL,
	url character varying(2000) NOT NULL,
	name character varying(30) NOT NULL,
	first_crawl date,
	last_crawl date,
	status bool NOT NULL DEFAULT true,
	exploration_frequency smallint NOT NULL DEFAULT 0,
	CONSTRAINT "targets_PKEY" PRIMARY KEY (id),
	CONSTRAINT "targets_name_UNIQ" UNIQUE (name)

);
-- ddl-end --
COMMENT ON COLUMN backend.targets.exploration_frequency IS 'Cantidad de dias entre exploracion';
-- ddl-end --
ALTER TABLE backend.targets OWNER TO postgres;
-- ddl-end --

-- Appended SQL commands --
INSERT INTO backend.targets (url,name,status,exploration_frequency) VALUES ('http://www.pol.una.py','FP-UNA',true,7);
-- ddl-end --

-- object: crawler.urls | type: TABLE --
-- DROP TABLE IF EXISTS crawler.urls CASCADE;
CREATE TABLE crawler.urls(
	id serial NOT NULL,
	full_url character varying(2000) NOT NULL,
	target_id integer NOT NULL,
	CONSTRAINT "urls_url_PKEY" PRIMARY KEY (id),
	CONSTRAINT "urls_url_UNIQ" UNIQUE (full_url)

);
-- ddl-end --
ALTER TABLE crawler.urls OWNER TO postgres;
-- ddl-end --

-- object: "urls_target_INX" | type: INDEX --
-- DROP INDEX IF EXISTS crawler."urls_target_INX" CASCADE;
CREATE INDEX "urls_target_INX" ON crawler.urls
	USING btree
	(
	  target_id ASC NULLS LAST
	);
-- ddl-end --

-- object: backend.notifications | type: TABLE --
-- DROP TABLE IF EXISTS backend.notifications CASCADE;
CREATE TABLE backend.notifications(
	id serial NOT NULL,
	emails character varying(50)[],
	notification_event_id integer NOT NULL,
	CONSTRAINT "notifications_PKEY" PRIMARY KEY (id),
	CONSTRAINT "notifications_event_UNIQ" UNIQUE (notification_event_id)

);
-- ddl-end --
COMMENT ON COLUMN backend.notifications.emails IS 'Lista de emails a ser notificados por event';
-- ddl-end --
ALTER TABLE backend.notifications OWNER TO postgres;
-- ddl-end --

-- Appended SQL commands --
INSERT INTO backend.notifications (emails,notification_event_id) VALUES ('{felipeklez@gmail.com}',1);
INSERT INTO backend.notifications (emails,notification_event_id) VALUES ('{felipeklez@gmail.com}',2);
INSERT INTO backend.notifications (emails,notification_event_id) VALUES ('{felipeklez@gmail.com}',3);
-- ddl-end --

-- object: backend.notification_events | type: TABLE --
-- DROP TABLE IF EXISTS backend.notification_events CASCADE;
CREATE TABLE backend.notification_events(
	id serial NOT NULL,
	code character(5) NOT NULL,
	description character varying(100) NOT NULL,
	CONSTRAINT "notif_events_PKEY" PRIMARY KEY (id),
	CONSTRAINT "notif_events_code_UNIQ" UNIQUE (code)

);
-- ddl-end --
ALTER TABLE backend.notification_events OWNER TO postgres;
-- ddl-end --

-- Appended SQL commands --
INSERT INTO backend.notification_events (code,description) VALUES ('START','Crawler Empieza');
INSERT INTO backend.notification_events (code,description) VALUES ('DONE','Crawler Finaliza');
INSERT INTO backend.notification_events (code,description) VALUES ('FAIL','Crawler Falla');
-- ddl-end --

-- object: "notifications_event_INX" | type: INDEX --
-- DROP INDEX IF EXISTS backend."notifications_event_INX" CASCADE;
CREATE INDEX "notifications_event_INX" ON backend.notifications
	USING btree
	(
	  notification_event_id ASC NULLS LAST
	);
-- ddl-end --

-- object: "notif_event_code_INX" | type: INDEX --
-- DROP INDEX IF EXISTS backend."notif_event_code_INX" CASCADE;
CREATE INDEX "notif_event_code_INX" ON backend.notification_events
	USING btree
	(
	  code ASC NULLS LAST
	);
-- ddl-end --

-- object: crawler.crawler_status | type: TYPE --
-- DROP TYPE IF EXISTS crawler.crawler_status CASCADE;
CREATE TYPE crawler.crawler_status AS
 ENUM ('execution','done','failed');
-- ddl-end --
ALTER TYPE crawler.crawler_status OWNER TO postgres;
-- ddl-end --

-- object: crawler.crawler_logs | type: TABLE --
-- DROP TABLE IF EXISTS crawler.crawler_logs CASCADE;
CREATE TABLE crawler.crawler_logs(
	id serial NOT NULL,
	target_id integer NOT NULL,
	starting timestamp with time zone NOT NULL,
	ending timestamp with time zone,
	log text,
	http_petitions integer NOT NULL DEFAULT 0,
	http_errors integer NOT NULL DEFAULT 0,
	html_crawled integer NOT NULL DEFAULT 0,
	js_crawled integer NOT NULL DEFAULT 0,
	css_crawled integer NOT NULL DEFAULT 0,
	img_crawled integer NOT NULL DEFAULT 0,
	status crawler.crawler_status NOT NULL DEFAULT 'execution',
	CONSTRAINT "crawler_logs_PKEY" PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE crawler.crawler_logs OWNER TO postgres;
-- ddl-end --

-- object: "crawler_logs_target_INDEX" | type: INDEX --
-- DROP INDEX IF EXISTS crawler."crawler_logs_target_INDEX" CASCADE;
CREATE INDEX "crawler_logs_target_INDEX" ON crawler.crawler_logs
	USING btree
	(
	  target_id ASC NULLS LAST
	);
-- ddl-end --

-- object: crawler.meta_data_files | type: TABLE --
-- DROP TABLE IF EXISTS crawler.meta_data_files CASCADE;
CREATE TABLE crawler.meta_data_files(
	id serial NOT NULL,
	mime character varying(100) NOT NULL,
	size integer NOT NULL DEFAULT 0,
	url_id integer NOT NULL,
	hash character(32) NOT NULL DEFAULT crawler.crawler_hash_generator(1),
	created timestamp with time zone NOT NULL DEFAULT current_timestamp,
	last_modified timestamp with time zone,
	checksum character varying(32) NOT NULL,
	crawler_log_id integer NOT NULL,
	CONSTRAINT "meta_data_files_PKEY" PRIMARY KEY (id),
	CONSTRAINT hash UNIQUE (hash),
	CONSTRAINT "meta_data_files_url_crawler_log_UNIQ" UNIQUE (crawler_log_id,url_id)

);
-- ddl-end --
COMMENT ON TABLE crawler.meta_data_files IS 'Contiene informacion descriptiva sobre los archivos almacenados por el crawler';
-- ddl-end --
COMMENT ON COLUMN crawler.meta_data_files.size IS 'Tamaño en bytes del archivo';
-- ddl-end --
COMMENT ON COLUMN crawler.meta_data_files.url_id IS 'Url original del archivo';
-- ddl-end --
COMMENT ON COLUMN crawler.meta_data_files.hash IS 'Hash unico que identifica al archivo, el webservice se basa en la peticion de este HASH!';
-- ddl-end --
COMMENT ON COLUMN crawler.meta_data_files.checksum IS 'MD5 del archivo';
-- ddl-end --
COMMENT ON CONSTRAINT hash ON crawler.meta_data_files  IS 'Identifica al archivo en el webservice';
-- ddl-end --
ALTER TABLE crawler.meta_data_files OWNER TO postgres;
-- ddl-end --

-- object: "targets_status_INX" | type: INDEX --
-- DROP INDEX IF EXISTS backend."targets_status_INX" CASCADE;
CREATE INDEX "targets_status_INX" ON backend.targets
	USING btree
	(
	  status ASC NULLS LAST
	);
-- ddl-end --

-- object: "targets_name_INX" | type: INDEX --
-- DROP INDEX IF EXISTS backend."targets_name_INX" CASCADE;
CREATE INDEX "targets_name_INX" ON backend.targets
	USING btree
	(
	  name ASC NULLS LAST
	);
-- ddl-end --

-- object: "urls_url_INX" | type: INDEX --
-- DROP INDEX IF EXISTS crawler."urls_url_INX" CASCADE;
CREATE INDEX "urls_url_INX" ON crawler.urls
	USING btree
	(
	  full_url ASC NULLS LAST
	);
-- ddl-end --

-- object: "meta_data_files_url_INX" | type: INDEX --
-- DROP INDEX IF EXISTS crawler."meta_data_files_url_INX" CASCADE;
CREATE INDEX "meta_data_files_url_INX" ON crawler.meta_data_files
	USING btree
	(
	  url_id ASC NULLS LAST
	);
-- ddl-end --

-- object: "meta_data_files_hash_INX" | type: INDEX --
-- DROP INDEX IF EXISTS crawler."meta_data_files_hash_INX" CASCADE;
CREATE INDEX "meta_data_files_hash_INX" ON crawler.meta_data_files
	USING btree
	(
	  hash ASC NULLS LAST
	);
-- ddl-end --

-- object: "meta_data_files_created_INX" | type: INDEX --
-- DROP INDEX IF EXISTS crawler."meta_data_files_created_INX" CASCADE;
CREATE INDEX "meta_data_files_created_INX" ON crawler.meta_data_files
	USING btree
	(
	  created ASC NULLS LAST,
	  url_id ASC NULLS LAST
	);
-- ddl-end --

-- object: crawler.data_files | type: TABLE --
-- DROP TABLE IF EXISTS crawler.data_files CASCADE;
CREATE TABLE crawler.data_files(
	id serial NOT NULL,
	file bytea NOT NULL,
	meta_data_file_id integer NOT NULL,
	CONSTRAINT "data_files_PKEY" PRIMARY KEY (id),
	CONSTRAINT "data_files_file_UNIQ" UNIQUE (meta_data_file_id)

);
-- ddl-end --
ALTER TABLE crawler.data_files OWNER TO postgres;
-- ddl-end --

-- object: "data_files_file_INX" | type: INDEX --
-- DROP INDEX IF EXISTS crawler."data_files_file_INX" CASCADE;
CREATE INDEX "data_files_file_INX" ON crawler.data_files
	USING btree
	(
	  meta_data_file_id ASC NULLS LAST
	);
-- ddl-end --

-- object: analysis.htmldoc_links | type: TABLE --
-- DROP TABLE IF EXISTS analysis.htmldoc_links CASCADE;
CREATE TABLE analysis.htmldoc_links(
	id serial NOT NULL,
	meta_data_file_id integer NOT NULL,
	hashes character varying(32)[],
	CONSTRAINT "htmldoc_links_PKEY" PRIMARY KEY (id)

);
-- ddl-end --
COMMENT ON TABLE analysis.htmldoc_links IS 'Almacena las urls de vinculos, imagenes, css y js externos que contenga el documento HTML analizado';
-- ddl-end --
COMMENT ON COLUMN analysis.htmldoc_links.hashes IS 'Contiene los hashes de cada url capturada para su referencia en la tabla de archivos. La correspondencia del indice con respecto a la url debe mantenerse';
-- ddl-end --
ALTER TABLE analysis.htmldoc_links OWNER TO postgres;
-- ddl-end --

-- object: "htmldoc_links_file_INX" | type: INDEX --
-- DROP INDEX IF EXISTS analysis."htmldoc_links_file_INX" CASCADE;
CREATE INDEX "htmldoc_links_file_INX" ON analysis.htmldoc_links
	USING btree
	(
	  meta_data_file_id ASC NULLS LAST
	);
-- ddl-end --

-- object: dictionary.notable_words | type: TABLE --
-- DROP TABLE IF EXISTS dictionary.notable_words CASCADE;
CREATE TABLE dictionary.notable_words(
	id serial NOT NULL,
	word character varying(30) NOT NULL,
	CONSTRAINT "notable_words_PKEY" PRIMARY KEY (id),
	CONSTRAINT "notable_words_UNIQ" UNIQUE (word)

);
-- ddl-end --
ALTER TABLE dictionary.notable_words OWNER TO postgres;
-- ddl-end --

-- object: "notable_words_INX" | type: INDEX --
-- DROP INDEX IF EXISTS dictionary."notable_words_INX" CASCADE;
CREATE INDEX "notable_words_INX" ON dictionary.notable_words
	USING btree
	(
	  word ASC NULLS LAST
	);
-- ddl-end --

-- object: dictionary.names | type: TABLE --
-- DROP TABLE IF EXISTS dictionary.names CASCADE;
CREATE TABLE dictionary.names(
	id serial NOT NULL,
	name character varying(50) NOT NULL,
	CONSTRAINT "names_PKEY" PRIMARY KEY (id),
	CONSTRAINT "names_UNIQ" UNIQUE (name)

);
-- ddl-end --
ALTER TABLE dictionary.names OWNER TO postgres;
-- ddl-end --

-- object: "names_INX" | type: INDEX --
-- DROP INDEX IF EXISTS dictionary."names_INX" CASCADE;
CREATE INDEX "names_INX" ON dictionary.names
	USING btree
	(
	  name ASC NULLS LAST
	);
-- ddl-end --

-- object: analysis.htmldoc_notable_words | type: TABLE --
-- DROP TABLE IF EXISTS analysis.htmldoc_notable_words CASCADE;
CREATE TABLE analysis.htmldoc_notable_words(
	id serial NOT NULL,
	meta_data_file_id integer NOT NULL,
	notable_word_id integer NOT NULL,
	quantity integer NOT NULL DEFAULT 0,
	CONSTRAINT "htmldoc_notable_words_PKEY" PRIMARY KEY (id)

);
-- ddl-end --
COMMENT ON TABLE analysis.htmldoc_notable_words IS 'Almacena las urls de vinculos, imagenes, css y js externos que contenga el documento HTML analizado';
-- ddl-end --
ALTER TABLE analysis.htmldoc_notable_words OWNER TO postgres;
-- ddl-end --

-- object: "htmldoc_notable_words_word_INX" | type: INDEX --
-- DROP INDEX IF EXISTS analysis."htmldoc_notable_words_word_INX" CASCADE;
CREATE INDEX "htmldoc_notable_words_word_INX" ON analysis.htmldoc_notable_words
	USING btree
	(
	  notable_word_id ASC NULLS LAST
	);
-- ddl-end --

-- object: "htmldoc_notable_words_file_INX" | type: INDEX --
-- DROP INDEX IF EXISTS analysis."htmldoc_notable_words_file_INX" CASCADE;
CREATE INDEX "htmldoc_notable_words_file_INX" ON analysis.htmldoc_notable_words
	USING btree
	(
	  meta_data_file_id ASC NULLS LAST
	);
-- ddl-end --

-- object: analysis.htmldoc_names | type: TABLE --
-- DROP TABLE IF EXISTS analysis.htmldoc_names CASCADE;
CREATE TABLE analysis.htmldoc_names(
	id serial NOT NULL,
	meta_data_file_id integer NOT NULL,
	name_id integer NOT NULL,
	quantity integer NOT NULL DEFAULT 0,
	CONSTRAINT "htmldoc_names_PKEY" PRIMARY KEY (id)

);
-- ddl-end --
COMMENT ON TABLE analysis.htmldoc_names IS 'Almacena las urls de vinculos, imagenes, css y js externos que contenga el documento HTML analizado';
-- ddl-end --
ALTER TABLE analysis.htmldoc_names OWNER TO postgres;
-- ddl-end --

-- object: "htmldoc_names_name_INX" | type: INDEX --
-- DROP INDEX IF EXISTS analysis."htmldoc_names_name_INX" CASCADE;
CREATE INDEX "htmldoc_names_name_INX" ON analysis.htmldoc_names
	USING btree
	(
	  name_id ASC NULLS LAST
	);
-- ddl-end --

-- object: "htmldoc_names_file_INX" | type: INDEX --
-- DROP INDEX IF EXISTS analysis."htmldoc_names_file_INX" CASCADE;
CREATE INDEX "htmldoc_names_file_INX" ON analysis.htmldoc_names
	USING btree
	(
	  meta_data_file_id ASC NULLS LAST
	);
-- ddl-end --

-- object: analysis.htmldoc_full_texts | type: TABLE --
-- DROP TABLE IF EXISTS analysis.htmldoc_full_texts CASCADE;
CREATE TABLE analysis.htmldoc_full_texts(
	id serial NOT NULL,
	meta_data_file_id integer NOT NULL,
	h1 character varying(50),
	title character varying(50),
	doctext text,
	CONSTRAINT "htmldoc_full_texts_PKEY" PRIMARY KEY (id),
	CONSTRAINT "htmldoc_full_texts_file_UNIQ" UNIQUE (meta_data_file_id)

);
-- ddl-end --
ALTER TABLE analysis.htmldoc_full_texts OWNER TO postgres;
-- ddl-end --

-- object: "htmldoc_full_texts_file_INX" | type: INDEX --
-- DROP INDEX IF EXISTS analysis."htmldoc_full_texts_file_INX" CASCADE;
CREATE INDEX "htmldoc_full_texts_file_INX" ON analysis.htmldoc_full_texts
	USING btree
	(
	  meta_data_file_id ASC NULLS LAST
	);
-- ddl-end --

-- object: "htmldoc_full_texts_title_INX" | type: INDEX --
-- DROP INDEX IF EXISTS analysis."htmldoc_full_texts_title_INX" CASCADE;
CREATE INDEX "htmldoc_full_texts_title_INX" ON analysis.htmldoc_full_texts
	USING btree
	(
	  title ASC NULLS LAST
	);
-- ddl-end --

-- object: "htmldoc_full_texts_h1_INX" | type: INDEX --
-- DROP INDEX IF EXISTS analysis."htmldoc_full_texts_h1_INX" CASCADE;
CREATE INDEX "htmldoc_full_texts_h1_INX" ON analysis.htmldoc_full_texts
	USING btree
	(
	  h1 ASC NULLS LAST
	);
-- ddl-end --

-- object: "meta_data_files_crawler_log_INDEX" | type: INDEX --
-- DROP INDEX IF EXISTS crawler."meta_data_files_crawler_log_INDEX" CASCADE;
CREATE INDEX "meta_data_files_crawler_log_INDEX" ON crawler.meta_data_files
	USING btree
	(
	  crawler_log_id ASC NULLS LAST
	);
-- ddl-end --

-- object: "meta_data_files_url_crawler_log_INX" | type: INDEX --
-- DROP INDEX IF EXISTS crawler."meta_data_files_url_crawler_log_INX" CASCADE;
CREATE UNIQUE INDEX "meta_data_files_url_crawler_log_INX" ON crawler.meta_data_files
	USING btree
	(
	  url_id ASC NULLS LAST,
	  crawler_log_id ASC NULLS LAST
	);
-- ddl-end --

-- object: "urls_target_FKEY" | type: CONSTRAINT --
-- ALTER TABLE crawler.urls DROP CONSTRAINT IF EXISTS "urls_target_FKEY" CASCADE;
ALTER TABLE crawler.urls ADD CONSTRAINT "urls_target_FKEY" FOREIGN KEY (target_id)
REFERENCES backend.targets (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "notif_events_FKEY" | type: CONSTRAINT --
-- ALTER TABLE backend.notifications DROP CONSTRAINT IF EXISTS "notif_events_FKEY" CASCADE;
ALTER TABLE backend.notifications ADD CONSTRAINT "notif_events_FKEY" FOREIGN KEY (notification_event_id)
REFERENCES backend.notification_events (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "crawler_logs_target_FKEY" | type: CONSTRAINT --
-- ALTER TABLE crawler.crawler_logs DROP CONSTRAINT IF EXISTS "crawler_logs_target_FKEY" CASCADE;
ALTER TABLE crawler.crawler_logs ADD CONSTRAINT "crawler_logs_target_FKEY" FOREIGN KEY (target_id)
REFERENCES backend.targets (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "meta_data_files_url_FKEY" | type: CONSTRAINT --
-- ALTER TABLE crawler.meta_data_files DROP CONSTRAINT IF EXISTS "meta_data_files_url_FKEY" CASCADE;
ALTER TABLE crawler.meta_data_files ADD CONSTRAINT "meta_data_files_url_FKEY" FOREIGN KEY (url_id)
REFERENCES crawler.urls (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "crawler_log_id_FKEY" | type: CONSTRAINT --
-- ALTER TABLE crawler.meta_data_files DROP CONSTRAINT IF EXISTS "crawler_log_id_FKEY" CASCADE;
ALTER TABLE crawler.meta_data_files ADD CONSTRAINT "crawler_log_id_FKEY" FOREIGN KEY (crawler_log_id)
REFERENCES crawler.crawler_logs (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "data_files_file_FKEY" | type: CONSTRAINT --
-- ALTER TABLE crawler.data_files DROP CONSTRAINT IF EXISTS "data_files_file_FKEY" CASCADE;
ALTER TABLE crawler.data_files ADD CONSTRAINT "data_files_file_FKEY" FOREIGN KEY (meta_data_file_id)
REFERENCES crawler.meta_data_files (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "htmldoc_links_file_FKEY" | type: CONSTRAINT --
-- ALTER TABLE analysis.htmldoc_links DROP CONSTRAINT IF EXISTS "htmldoc_links_file_FKEY" CASCADE;
ALTER TABLE analysis.htmldoc_links ADD CONSTRAINT "htmldoc_links_file_FKEY" FOREIGN KEY (meta_data_file_id)
REFERENCES crawler.meta_data_files (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "htmldoc_notable_words_file_FKEY" | type: CONSTRAINT --
-- ALTER TABLE analysis.htmldoc_notable_words DROP CONSTRAINT IF EXISTS "htmldoc_notable_words_file_FKEY" CASCADE;
ALTER TABLE analysis.htmldoc_notable_words ADD CONSTRAINT "htmldoc_notable_words_file_FKEY" FOREIGN KEY (meta_data_file_id)
REFERENCES crawler.meta_data_files (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "htmldoc_notable_words_word_FKEY" | type: CONSTRAINT --
-- ALTER TABLE analysis.htmldoc_notable_words DROP CONSTRAINT IF EXISTS "htmldoc_notable_words_word_FKEY" CASCADE;
ALTER TABLE analysis.htmldoc_notable_words ADD CONSTRAINT "htmldoc_notable_words_word_FKEY" FOREIGN KEY (notable_word_id)
REFERENCES dictionary.notable_words (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "htmldoc_names_file_FKEY" | type: CONSTRAINT --
-- ALTER TABLE analysis.htmldoc_names DROP CONSTRAINT IF EXISTS "htmldoc_names_file_FKEY" CASCADE;
ALTER TABLE analysis.htmldoc_names ADD CONSTRAINT "htmldoc_names_file_FKEY" FOREIGN KEY (meta_data_file_id)
REFERENCES crawler.meta_data_files (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "htmldoc_names_word_FKEY" | type: CONSTRAINT --
-- ALTER TABLE analysis.htmldoc_names DROP CONSTRAINT IF EXISTS "htmldoc_names_word_FKEY" CASCADE;
ALTER TABLE analysis.htmldoc_names ADD CONSTRAINT "htmldoc_names_word_FKEY" FOREIGN KEY (name_id)
REFERENCES dictionary.names (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "htmldoc_full_text_file_FKEY" | type: CONSTRAINT --
-- ALTER TABLE analysis.htmldoc_full_texts DROP CONSTRAINT IF EXISTS "htmldoc_full_text_file_FKEY" CASCADE;
ALTER TABLE analysis.htmldoc_full_texts ADD CONSTRAINT "htmldoc_full_text_file_FKEY" FOREIGN KEY (meta_data_file_id)
REFERENCES crawler.meta_data_files (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --


