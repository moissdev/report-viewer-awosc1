CREATE USER app_user WITH PASSWORD 'app_password';
GRANT CONNECT ON DATABASE report_db TO app_user;
REVOKE ALL ON schema public FROM app_user;
GRANT USAGE ON SCHEMA public TO app_user;