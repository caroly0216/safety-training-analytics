--
-- PostgreSQL database dump
--

\restrict xiZ9CgJhJ8bsnNr6BZlWmmRa57aSBFdZlwvWc8kpAtnp05aYBCBINeIwHpALwZg

-- Dumped from database version 16.11
-- Dumped by pg_dump version 16.11

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
-- Name: raw; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA raw;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: hazardous_chemical_management_training; Type: TABLE; Schema: raw; Owner: -
--

CREATE TABLE raw.hazardous_chemical_management_training (
    raw_record_id bigint NOT NULL,
    source_file_name text,
    source_sheet_name text,
    source_row_number integer,
    ingestion_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    amount_raw text,
    collection_status_raw text,
    coordinator_name_raw text,
    training_time_raw text,
    certificate_validity_raw text,
    sequence_number_raw text,
    written_report_number_raw text,
    trainee_name_raw text,
    gender_raw text,
    birth_date_raw text,
    national_id_raw text,
    education_level_raw text,
    phone_number_raw text,
    contact_address_raw text,
    job_title_raw text,
    professional_title_raw text,
    initial_certificate_date_raw text,
    operation_category_raw text,
    operation_item_raw text,
    training_type_raw text,
    training_provider_raw text,
    training_days_raw text,
    exam_type_raw text,
    practical_exam_score_raw text,
    company_name_raw text,
    company_nature_raw text,
    enterprise_category_raw text,
    company_region_raw text,
    invoice_type_raw text,
    invoice_company_name_raw text,
    invoice_tax_number_raw text,
    remarks_raw text
);


--
-- Name: occupational_health_training; Type: TABLE; Schema: raw; Owner: -
--

CREATE TABLE raw.occupational_health_training (
    raw_record_id bigint NOT NULL,
    source_file_name text,
    source_sheet_name text,
    source_row_number integer,
    ingestion_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    amount_raw text,
    collection_status_raw text,
    coordinator_name_raw text,
    declared_class_raw text,
    company_name_raw text,
    trainee_name_raw text,
    training_date_raw text,
    gender_raw text,
    job_title_raw text,
    education_level_raw text,
    assessment_result_raw text,
    certificate_number_raw text,
    national_id_raw text,
    phone_number_raw text,
    training_type_raw text
);


--
-- Name: safety_training_certificate_summary; Type: TABLE; Schema: raw; Owner: -
--

CREATE TABLE raw.safety_training_certificate_summary (
    raw_record_id bigint NOT NULL,
    source_file_name text,
    source_sheet_name text,
    source_row_number integer,
    ingestion_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    sequence_number_raw text,
    certificate_number_raw text,
    trainee_name_raw text,
    gender_raw text,
    unnamed_e_raw text,
    birth_date_raw text,
    phone_number_raw text,
    job_position_raw text,
    education_level_raw text,
    score_raw text,
    training_type_raw text,
    initial_certificate_date_raw text,
    validity_start_date_raw text,
    validity_end_date_raw text,
    retraining_date_raw text,
    training_provider_raw text,
    training_days_raw text,
    company_name_raw text,
    industry_category_raw text,
    remarks_raw text,
    amount_raw text,
    declared_class_raw text,
    collection_status_raw text,
    training_period_raw text,
    unnamed_y_raw text,
    unnamed_z_raw text
);


--
-- Name: safety_training_offline_class; Type: TABLE; Schema: raw; Owner: -
--

CREATE TABLE raw.safety_training_offline_class (
    raw_record_id bigint NOT NULL,
    source_file_name text,
    source_sheet_name text,
    source_row_number integer,
    ingestion_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    class_title_raw text,
    unnamed_a_raw text,
    unnamed_b_raw text,
    trainee_name_raw text,
    gender_raw text,
    unnamed_e_raw text,
    birth_date_raw text,
    phone_number_raw text,
    job_position_raw text,
    education_level_raw text,
    score_raw text,
    training_type_raw text,
    initial_certificate_date_raw text,
    validity_start_date_raw text,
    validity_end_date_raw text,
    retraining_date_raw text,
    training_provider_raw text,
    training_days_raw text,
    company_name_raw text,
    industry_category_raw text,
    remarks_raw text,
    coordinator_name_raw text,
    unit_price_raw text,
    declared_class_raw text,
    collection_status_raw text,
    training_period_raw text,
    exam_time_raw text
);


--
-- Name: special_equipment_training; Type: TABLE; Schema: raw; Owner: -
--

CREATE TABLE raw.special_equipment_training (
    raw_record_id bigint NOT NULL,
    source_file_name text,
    source_sheet_name text,
    source_row_number integer,
    ingestion_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    amount_raw text,
    collection_status_raw text,
    coordinator_name_raw text,
    declared_class_raw text,
    training_type_raw text,
    trainee_name_raw text,
    national_id_raw text,
    phone_number_raw text,
    operation_item_code_raw text,
    certificate_expiry_date_raw text,
    company_name_raw text,
    session_end_date_raw text,
    sub_organization_raw text,
    payment_status_raw text,
    learning_card_type_code_raw text
);


--
-- Name: special_operation_training; Type: TABLE; Schema: raw; Owner: -
--

CREATE TABLE raw.special_operation_training (
    raw_record_id bigint NOT NULL,
    source_file_name text,
    source_sheet_name text,
    source_row_number integer,
    ingestion_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    coordinator_name_raw text,
    training_time_raw text,
    amount_raw text,
    collection_notes_raw text,
    sequence_number_raw text,
    written_report_number_raw text,
    trainee_name_raw text,
    gender_raw text,
    birth_date_raw text,
    national_id_raw text,
    education_level_raw text,
    phone_number_raw text,
    contact_address_raw text,
    operation_category_raw text,
    operation_item_raw text,
    training_type_raw text,
    training_provider_raw text,
    initial_certificate_date_raw text,
    training_days_raw text,
    exam_type_raw text,
    practical_exam_score_raw text,
    company_name_raw text,
    company_nature_raw text,
    enterprise_category_raw text,
    company_region_raw text,
    invoice_type_raw text,
    invoice_company_name_raw text,
    invoice_tax_number_raw text,
    remarks_raw text
);


--
-- Name: hazardous_chemical_management_training_raw_record_id_seq; Type: SEQUENCE; Schema: raw; Owner: -
--

ALTER TABLE raw.hazardous_chemical_management_training ALTER COLUMN raw_record_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME raw.hazardous_chemical_management_training_raw_record_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: occupational_health_training_raw_record_id_seq; Type: SEQUENCE; Schema: raw; Owner: -
--

ALTER TABLE raw.occupational_health_training ALTER COLUMN raw_record_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME raw.occupational_health_training_raw_record_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: safety_training_certificate_summary_raw_record_id_seq; Type: SEQUENCE; Schema: raw; Owner: -
--

ALTER TABLE raw.safety_training_certificate_summary ALTER COLUMN raw_record_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME raw.safety_training_certificate_summary_raw_record_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: safety_training_offline_class_raw_record_id_seq; Type: SEQUENCE; Schema: raw; Owner: -
--

ALTER TABLE raw.safety_training_offline_class ALTER COLUMN raw_record_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME raw.safety_training_offline_class_raw_record_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: special_equipment_training_raw_record_id_seq; Type: SEQUENCE; Schema: raw; Owner: -
--

ALTER TABLE raw.special_equipment_training ALTER COLUMN raw_record_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME raw.special_equipment_training_raw_record_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: special_operation_training_raw_record_id_seq; Type: SEQUENCE; Schema: raw; Owner: -
--

ALTER TABLE raw.special_operation_training ALTER COLUMN raw_record_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME raw.special_operation_training_raw_record_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: hazardous_chemical_management_training hazardous_chemical_management_training_pkey; Type: CONSTRAINT; Schema: raw; Owner: -
--

ALTER TABLE ONLY raw.hazardous_chemical_management_training
    ADD CONSTRAINT hazardous_chemical_management_training_pkey PRIMARY KEY (raw_record_id);


--
-- Name: occupational_health_training occupational_health_training_pkey; Type: CONSTRAINT; Schema: raw; Owner: -
--

ALTER TABLE ONLY raw.occupational_health_training
    ADD CONSTRAINT occupational_health_training_pkey PRIMARY KEY (raw_record_id);


--
-- Name: safety_training_certificate_summary safety_training_certificate_summary_pkey; Type: CONSTRAINT; Schema: raw; Owner: -
--

ALTER TABLE ONLY raw.safety_training_certificate_summary
    ADD CONSTRAINT safety_training_certificate_summary_pkey PRIMARY KEY (raw_record_id);


--
-- Name: safety_training_offline_class safety_training_offline_class_pkey; Type: CONSTRAINT; Schema: raw; Owner: -
--

ALTER TABLE ONLY raw.safety_training_offline_class
    ADD CONSTRAINT safety_training_offline_class_pkey PRIMARY KEY (raw_record_id);


--
-- Name: special_equipment_training special_equipment_training_pkey; Type: CONSTRAINT; Schema: raw; Owner: -
--

ALTER TABLE ONLY raw.special_equipment_training
    ADD CONSTRAINT special_equipment_training_pkey PRIMARY KEY (raw_record_id);


--
-- Name: special_operation_training special_operation_training_pkey; Type: CONSTRAINT; Schema: raw; Owner: -
--

ALTER TABLE ONLY raw.special_operation_training
    ADD CONSTRAINT special_operation_training_pkey PRIMARY KEY (raw_record_id);


--
-- PostgreSQL database dump complete
--

\unrestrict xiZ9CgJhJ8bsnNr6BZlWmmRa57aSBFdZlwvWc8kpAtnp05aYBCBINeIwHpALwZg

