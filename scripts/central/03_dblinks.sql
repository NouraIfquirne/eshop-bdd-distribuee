-- ============================================================
-- ESHOP BDD DISTRIBUEE - DATABASE LINKS
-- Connexion : EShop@localhost:1522/XEPDB1
-- Prerequis : GRANT CREATE DATABASE LINK TO EShop; (en tant que system)
-- ============================================================

-- Lien Central -> Site1 (Scenario 1)
CREATE DATABASE LINK site1_link
CONNECT TO EShop IDENTIFIED BY EShop123
USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oracle-site1)(PORT=1521))
       (CONNECT_DATA=(SERVICE_NAME=XEPDB1)))';

-- Lien Central -> Site2 (Scenario 1)
CREATE DATABASE LINK site2_link
CONNECT TO EShop IDENTIFIED BY EShop123
USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oracle-site2)(PORT=1521))
       (CONNECT_DATA=(SERVICE_NAME=XEPDB1)))';

-- Lien Central -> Site1 (Scenario 2)
CREATE DATABASE LINK site1_s2_link
CONNECT TO EShop2 IDENTIFIED BY EShop2123
USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oracle-site1)(PORT=1521))
       (CONNECT_DATA=(SERVICE_NAME=XEPDB1)))';

-- Lien Central -> Site2 (Scenario 2)
CREATE DATABASE LINK site2_s2_link
CONNECT TO EShop2 IDENTIFIED BY EShop2123
USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oracle-site2)(PORT=1521))
       (CONNECT_DATA=(SERVICE_NAME=XEPDB1)))';

-- Tests des liens
-- SELECT COUNT(*) FROM Produits1@site1_link;
-- SELECT COUNT(*) FROM Produits2@site2_link;
-- SELECT COUNT(*) FROM LigneCommandes1@site1_s2_link;
-- SELECT COUNT(*) FROM LigneCommandes2@site2_s2_link;
