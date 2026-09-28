-- Invented records only. DEMO-ID values are deliberately not national IDs.
-- Run in the separate demo database after raw_schema.sql.
BEGIN;

INSERT INTO raw.hazardous_chemical_management_training
(source_file_name, source_sheet_name, source_row_number, ingestion_timestamp, amount_raw, collection_status_raw, coordinator_name_raw, trainee_name_raw, national_id_raw, education_level_raw, company_name_raw, training_type_raw, operation_category_raw, initial_certificate_date_raw)
VALUES
('synthetic','demo',1,'2026-06-01','700','已收款','DemoCoordinator01','DemoLearner01','DEMO-ID-001','本科','Demo Company A','新训','危险化学品经营单位安全管理人员',to_char(current_date - interval '36 months' + interval '45 days','YYYY-MM-DD')),
('synthetic','demo',2,'2026-06-01','650','未收款','DemoCoordinator01','DemoLearner02','DEMO-ID-002','高中','Demo Company B','新训','危险化学品经营单位安全管理人员',to_char(current_date - interval '36 months' - interval '45 days','YYYY-MM-DD'));

INSERT INTO raw.occupational_health_training
(source_file_name, source_sheet_name, source_row_number, ingestion_timestamp, amount_raw, collection_status_raw, coordinator_name_raw, company_name_raw, trainee_name_raw, national_id_raw, education_level_raw, training_type_raw, certificate_number_raw)
VALUES
('synthetic','demo',1,'2026-06-01','400','已收款','DemoCoordinator01','Demo Company A','DemoLearner03','DEMO-ID-003','本科','新训','DEMOCERT003'),
('synthetic','demo',2,'2026-06-01','350','未收款','DemoCoordinator01','无','DemoLearner04','DEMO-ID-004','高中','复训',NULL),
('synthetic','demo',3,'2026-06-01','0',NULL,'DemoCancelled','Demo Company B','DemoLearner05','DEMO-ID-005','本科','新训',NULL),
('synthetic','demo',4,'2026-06-02','400','990000000001','DemoCoordinator01','Demo Company B','DemoLearner05','DEMO-ID-005','本科','新训',NULL);

INSERT INTO raw.safety_training_certificate_summary
(source_file_name, source_sheet_name, source_row_number, ingestion_timestamp, trainee_name_raw, unnamed_e_raw, education_level_raw, training_type_raw, company_name_raw, remarks_raw, amount_raw, collection_status_raw, training_period_raw)
VALUES
('synthetic','demo',1,'2026-06-01','DemoLearner06','DEMO-ID-006','本科','新训','Demo Company A','DemoCoordinator01','300','已收款',to_char(current_date - 20,'YYYY-MM-DD') || '至' || to_char(current_date - 10,'YYYY-MM-DD')),
('synthetic','demo',2,'2026-06-01','DemoLearner07','DEMO-ID-007','高中','新训','无','DemoCoordinator01','280','未收款',to_char(current_date - 2,'YYYY-MM-DD') || '至' || to_char(current_date + 20,'YYYY-MM-DD'));

INSERT INTO raw.safety_training_offline_class
(source_file_name, source_sheet_name, source_row_number, ingestion_timestamp, unnamed_a_raw, trainee_name_raw, unnamed_e_raw, education_level_raw, training_type_raw, company_name_raw, job_position_raw, coordinator_name_raw, collection_status_raw, training_period_raw, unnamed_b_raw)
VALUES
('synthetic','demo',1,'2026-06-01','450','DemoLearner08','DEMO-ID-008','本科','新训','Demo Company B','有限空间','DemoCoordinator01','已收款','2026年1月1日至1月5日','DemoOfflineBatch');

INSERT INTO raw.special_equipment_training
(source_file_name, source_sheet_name, source_row_number, ingestion_timestamp, amount_raw, collection_status_raw, coordinator_name_raw, training_type_raw, trainee_name_raw, national_id_raw, operation_item_code_raw, certificate_expiry_date_raw, company_name_raw)
VALUES
('synthetic','demo',1,'2026-06-01','900','已收款','DemoCoordinator01','新训','DemoLearner09','DEMO-ID-009','N1',to_char(current_date - interval '2 months','YYYY-MM'),'Demo Company A'),
('synthetic','demo',2,'2026-06-01','850','未收款','DemoCoordinator01','换证','DemoLearner10','DEMO-ID-010','N1',to_char(current_date + interval '2 months','YYYY-MM'),'Demo Company B');

INSERT INTO raw.special_operation_training
(source_file_name, source_sheet_name, source_row_number, ingestion_timestamp, coordinator_name_raw, training_time_raw, amount_raw, collection_notes_raw, trainee_name_raw, national_id_raw, education_level_raw, operation_item_raw, training_type_raw, initial_certificate_date_raw, company_name_raw)
VALUES
('synthetic','demo',1,'2026-06-01','DemoCoordinator01','3月7日-3月13日','800','已收款','DemoLearner11','DEMO-ID-011','本科','电工作业-低压电工作业','新训',to_char(current_date - interval '72 months' + interval '45 days','YYYY-MM-DD'),'Demo Company A'),
('synthetic','demo',2,'2026-06-01','DemoCoordinator01','12月1日-12月5日','750','未收款','DemoLearner12','DEMO-ID-012','高中','电工作业-低压电工作业','复训',to_char(current_date - interval '72 months' - interval '45 days','YYYY-MM-DD'),'Demo Company B');

-- Non-contactable placeholders satisfy required source fields without real phones.
UPDATE raw.hazardous_chemical_management_training SET phone_number_raw = 'DEMO-NOT-CONTACTABLE';
UPDATE raw.occupational_health_training SET phone_number_raw = 'DEMO-NOT-CONTACTABLE';
UPDATE raw.safety_training_certificate_summary SET phone_number_raw = 'DEMO-NOT-CONTACTABLE';
UPDATE raw.safety_training_offline_class SET phone_number_raw = 'DEMO-NOT-CONTACTABLE', class_title_raw = 'DemoOfflineBatch', unnamed_b_raw = NULL;
UPDATE raw.special_equipment_training SET phone_number_raw = 'DEMO-NOT-CONTACTABLE';
UPDATE raw.special_operation_training SET phone_number_raw = 'DEMO-NOT-CONTACTABLE';

COMMIT;
