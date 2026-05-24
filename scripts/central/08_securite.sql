-- ============================================================
-- ESHOP BDD DISTRIBUEE - SECURITE
-- Connexion : system@localhost:1522/XEPDB1
-- ============================================================

-- Role lecture seule pour les DB Links
CREATE ROLE eshop_reader;
GRANT SELECT ON EShop.Produits        TO eshop_reader;
GRANT SELECT ON EShop.Clients         TO eshop_reader;
GRANT SELECT ON EShop.Commandes       TO eshop_reader;
GRANT SELECT ON EShop.LigneCommandes  TO eshop_reader;
GRANT SELECT ON EShop.Categories      TO eshop_reader;

-- User dedie pour les DB Links (lecture seule)
CREATE USER dblink_user IDENTIFIED BY "DbLink2024!";
GRANT eshop_reader TO dblink_user;
GRANT CREATE SESSION TO dblink_user;

-- Audit des tables sensibles
AUDIT SELECT, INSERT, UPDATE, DELETE ON EShop.LigneCommandes BY ACCESS;
AUDIT SELECT, INSERT, UPDATE, DELETE ON EShop.Commandes BY ACCESS;

-- Consulter les logs d'audit
-- SELECT username, obj_name, action_name, timestamp
-- FROM dba_audit_trail
-- WHERE obj_name IN ('LIGNECOMMANDES','COMMANDES')
-- ORDER BY timestamp DESC;
