-- 01_create_schema.sql
-- L'image gvenzl cree automatiquement mon_user via APP_USER/APP_USER_PASSWORD
-- Ce script accorde uniquement les privileges supplementaires

GRANT CREATE SESSION, CREATE TABLE, CREATE PROCEDURE,
      CREATE SEQUENCE, CREATE TRIGGER, CREATE VIEW TO mon_user;
GRANT UNLIMITED TABLESPACE TO mon_user;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Privileges accordes a mon_user');
END;
/
