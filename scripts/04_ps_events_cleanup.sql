USE lab;

DELIMITER $$
CREATE PROCEDURE ps_cleanup()
BEGIN
    TRUNCATE TABLE performance_schema.events_statements_summary_global_by_event_name;
	TRUNCATE TABLE performance_schema.events_statements_summary_by_account_by_event_name;
	TRUNCATE TABLE performance_schema.events_statements_summary_by_user_by_event_name;
	TRUNCATE TABLE performance_schema.events_statements_summary_by_host_by_event_name;
	TRUNCATE TABLE performance_schema.events_statements_summary_by_thread_by_event_name;
	TRUNCATE TABLE performance_schema.events_statements_summary_by_digest;
	--
	TRUNCATE TABLE performance_schema.events_statements_history;
	TRUNCATE TABLE performance_schema.events_statements_history_long;
END$$
DELIMITER ;

-- CALL ps_cleanup();