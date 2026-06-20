-- ============================================================
-- DEMO UPDATE : MIGRATION SITE1 -> SITE2
-- Connexion : EShop (port 1522)
-- ============================================================

SET SERVEROUTPUT ON;

-- ============================================================
-- AVANT LA DEMO : VERIFICATION ETAT INITIAL
-- ============================================================

-- Montrer le critere de la ligne 1 AVANT update
-- idcateg=50, qte=150 → critere SITE1 respecte
SELECT lc.idlignecommande,
       p.idproduit, p.designation, p.idcateg, c.nomcateg,
       lc.quantite,
       CASE WHEN p.idcateg = 50 AND lc.quantite > 100
            THEN 'idcateg=50 ET qte>100 → SITE1 ✓'
            ELSE 'critere SITE1 NON respecte'
       END AS critere_site1
FROM   LigneCommandes lc
JOIN   Produits p   ON lc.idproduit = p.idproduit
JOIN   Categories c ON p.idcateg   = c.idcateg
WHERE  lc.idlignecommande = 1;

-- Ligne 1 doit etre sur Site1
SELECT * FROM LigneCommandes1@site1_link WHERE idlignecommande = 1;

-- Ligne 1 doit etre absente de Site2
SELECT COUNT(*) AS doit_etre_zero
FROM LigneCommandes2@site2_link WHERE idlignecommande = 1;

-- ============================================================
-- PENDANT LA DEMO
-- ============================================================

-- Montrer le critere du NOUVEAU produit (idproduit=4) avant update
--  idcateg=35, qte=80 → critere SITE2 respecte
SELECT p.idproduit, p.designation, p.idcateg, c.nomcateg,
       80 AS nouvelle_quantite,
       CASE WHEN p.idcateg = 35 AND 80 > 50
            THEN 'idcateg=35 ET qte=80>50 → SITE2 ✓'
            ELSE 'critere SITE2 NON respecte'
       END AS critere_site2
FROM   Produits p
JOIN   Categories c ON p.idcateg = c.idcateg
WHERE  p.idproduit = 4;

-- Etape 1 : Desactiver Scenario 2 (eviter ORA-02020)
ALTER TRIGGER SYC_INSERT_LIGNE_S2 DISABLE;
ALTER TRIGGER SYC_DELETE_LIGNE_S2 DISABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE_S2 DISABLE;

-- Etape 2 : UPDATE -> migration Site1 vers Site2
UPDATE LigneCommandes
SET idproduit = 4, quantite = 80, remise = 0
WHERE idlignecommande = 1;
COMMIT;

-- Etape 3 : Verifier Site1 (doit etre vide)
SELECT COUNT(*) AS doit_etre_zero
FROM LigneCommandes1@site1_link WHERE idlignecommande = 1;

-- Etape 4 : Verifier Site2 (doit avoir la ligne) + critere verifie
-- voit idcateg=35 ET qte=80>50 → le trigger a bien verifie
SELECT lc.idlignecommande,
       p.idproduit, p.designation, p.idcateg, c.nomcateg,
       lc.quantite,
       CASE WHEN p.idcateg = 35 AND lc.quantite > 50
            THEN 'idcateg=35 ET qte>50 → SITE2 ✓'
            ELSE 'critere SITE2 NON respecte'
       END AS critere_verifie
FROM   LigneCommandes2@site2_link lc
JOIN   Produits2@site2_link p ON lc.idproduit = p.idproduit
JOIN   Categories c           ON p.idcateg   = c.idcateg
WHERE  lc.idlignecommande = 1;

-- Etape 5 : Logs Site1 (DELETE)
SELECT * FROM sync_logs@site1_link
ORDER BY log_date DESC FETCH FIRST 3 ROWS ONLY;

-- Etape 6 : Logs Site2 (INSERT)
SELECT * FROM sync_logs@site2_link
ORDER BY log_date DESC FETCH FIRST 3 ROWS ONLY;

-- Etape 7 : Reactiver Scenario 2
ALTER TRIGGER SYC_INSERT_LIGNE_S2 ENABLE;
ALTER TRIGGER SYC_DELETE_LIGNE_S2 ENABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE_S2 ENABLE;

-- ============================================================
-- APRES LA DEMO : RESTAURATION
-- ============================================================

-- Etape 1 : Desactiver tous les triggers
ALTER TRIGGER SYC_INSERT_LIGNE    DISABLE;
ALTER TRIGGER SYC_DELETE_LIGNE    DISABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE    DISABLE;
ALTER TRIGGER SYC_INSERT_LIGNE_S2 DISABLE;
ALTER TRIGGER SYC_DELETE_LIGNE_S2 DISABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE_S2 DISABLE;

-- Etape 2 : Restaurer Central
UPDATE LigneCommandes
SET idproduit = 1, quantite = 150, remise = 5
WHERE idlignecommande = 1;
COMMIT;

-- ============================================================
-- Etape 3 : Sur EShop_Site2 (port 1524) executer :
-- DELETE FROM LigneCommandes2 WHERE idlignecommande = 1;
-- COMMIT;
-- ============================================================

-- ============================================================
-- Etape 4 : Sur EShop_Site1 (port 1523) executer :
-- INSERT INTO LigneCommandes1 VALUES (1, 1, 1, 150, 5);
-- COMMIT;
-- ============================================================

-- Etape 5 : Reactiver tous les triggers (sur EShop)
ALTER TRIGGER SYC_INSERT_LIGNE    ENABLE;
ALTER TRIGGER SYC_DELETE_LIGNE    ENABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE    ENABLE;
ALTER TRIGGER SYC_INSERT_LIGNE_S2 ENABLE;
ALTER TRIGGER SYC_DELETE_LIGNE_S2 ENABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE_S2 ENABLE;

-- Etape 6 : Verifier etat final + critere
SELECT lc.idlignecommande,
       p.idproduit, p.designation, p.idcateg, c.nomcateg,
       lc.quantite,
       CASE WHEN p.idcateg = 50 AND lc.quantite > 100
            THEN 'idcateg=50 ET qte>100 → SITE1 ✓'
            ELSE 'critere SITE1 NON respecte'
       END AS critere_final
FROM   LigneCommandes lc
JOIN   Produits p   ON lc.idproduit = p.idproduit
JOIN   Categories c ON p.idcateg   = c.idcateg
WHERE  lc.idlignecommande = 1;

SELECT * FROM LigneCommandes1@site1_link WHERE idlignecommande = 1;
SELECT COUNT(*) AS doit_etre_zero
FROM LigneCommandes2@site2_link WHERE idlignecommande = 1;















-- ============================================================
-- AVANT : VERIFICATION ETAT INITIAL
-- ============================================================

-- Ligne 1 doit etre sur Site1
SELECT * FROM LigneCommandes1@site1_link WHERE idlignecommande = 1;

-- Ligne 1 doit etre absente de Site2
SELECT COUNT(*) AS doit_etre_zero
FROM LigneCommandes2@site2_link WHERE idlignecommande = 1;

-- ============================================================
-- PENDANT 
-- ============================================================

-- Etape 1 : Desactiver Scenario 2 (eviter ORA-02020)
ALTER TRIGGER SYC_INSERT_LIGNE_S2 DISABLE;
ALTER TRIGGER SYC_DELETE_LIGNE_S2 DISABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE_S2 DISABLE;


SELECT * FROM LigneCommandes2@site2_link WHERE idlignecommande=6;

-- UPDATE : categ=35 -> categ=50
UPDATE LigneCommandes
SET idproduit=1, quantite=120, remise=0
WHERE idlignecommande=6;
COMMIT;

-- Apres : disparue de Site2, apparue sur Site1
SELECT COUNT(*) AS site2_zero FROM LigneCommandes2@site2_link WHERE idlignecommande=6;
SELECT * FROM LigneCommandes1@site1_link WHERE idlignecommande=6;

ALTER TRIGGER SYC_INSERT_LIGNE_S2 ENABLE;
ALTER TRIGGER SYC_DELETE_LIGNE_S2 ENABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE_S2 ENABLE;




-- Etape 3 : Verifier Site1 (doit etre vide)
SELECT COUNT(*) AS doit_etre_zero
FROM LigneCommandes1@site1_link WHERE idlignecommande = 1;

-- Etape 4 : Verifier Site2 (doit avoir la ligne)
SELECT * FROM LigneCommandes2@site2_link WHERE idlignecommande = 1;

-- Etape 5 : Logs Site1 (DELETE)
SELECT * FROM sync_logs@site1_link
ORDER BY log_date DESC FETCH FIRST 3 ROWS ONLY;

-- Etape 6 : Logs Site2 (INSERT)
SELECT * FROM sync_logs@site2_logs_link
ORDER BY log_date DESC FETCH FIRST 3 ROWS ONLY;

-- Etape 7 : Reactiver Scenario 2
ALTER TRIGGER SYC_INSERT_LIGNE_S2 ENABLE;
ALTER TRIGGER SYC_DELETE_LIGNE_S2 ENABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE_S2 ENABLE;

-- ============================================================
-- APRES : RESTAURATION
-- ============================================================

-- Etape 1 : Desactiver tous les triggers
ALTER TRIGGER SYC_INSERT_LIGNE    DISABLE;
ALTER TRIGGER SYC_DELETE_LIGNE    DISABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE    DISABLE;
ALTER TRIGGER SYC_INSERT_LIGNE_S2 DISABLE;
ALTER TRIGGER SYC_DELETE_LIGNE_S2 DISABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE_S2 DISABLE;

-- Etape 2 : Restaurer Central
UPDATE LigneCommandes
SET idproduit = 1, quantite = 150, remise = 5
WHERE idlignecommande = 1;
COMMIT;

-- ============================================================
-- Etape 3 : Sur EShop_Site2 (port 1524) executer :
-- DELETE FROM LigneCommandes2 WHERE idlignecommande = 1;
-- COMMIT;
-- ============================================================

-- ============================================================
-- Etape 4 : Sur EShop_Site1 (port 1523) executer :
-- INSERT INTO LigneCommandes1 VALUES (1, 1, 1, 150, 5);
-- COMMIT;
-- ============================================================

-- Etape 5 : Reactiver tous les triggers (sur EShop)
ALTER TRIGGER SYC_INSERT_LIGNE    ENABLE;
ALTER TRIGGER SYC_DELETE_LIGNE    ENABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE    ENABLE;
ALTER TRIGGER SYC_INSERT_LIGNE_S2 ENABLE;
ALTER TRIGGER SYC_DELETE_LIGNE_S2 ENABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE_S2 ENABLE;

-- Etape 6 : Verifier etat final
SELECT * FROM LigneCommandes1@site1_link WHERE idlignecommande = 1;
SELECT COUNT(*) AS doit_etre_zero
FROM LigneCommandes2@site2_link WHERE idlignecommande = 1;


-- ============================================================
-- SECTION 1 : VERIFICATION ARCHITECTURE
-- Connexion : Central (system/admin port 1522)
-- ============================================================

-- 1.1 Verifier les 3 conteneurs (dans PowerShell)
-- docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"

-- 1.2 Verifier les connexions SQL Developer
SELECT 'CENTRAL' AS site, USER AS utilisateur,
       SYS_CONTEXT('USERENV','DB_NAME') AS base
FROM DUAL;

-- ============================================================
-- SECTION 2 : SCHEMA ET DONNEES
-- Connexion : EShop (port 1522)
-- ============================================================

-- 2.1 Verifier toutes les tables
SELECT 'Categories'     AS table_name, COUNT(*) AS nb FROM Categories    UNION ALL
SELECT 'Produits',       COUNT(*) FROM Produits      UNION ALL
SELECT 'Clients',        COUNT(*) FROM Clients       UNION ALL
SELECT 'Employes',       COUNT(*) FROM Employes      UNION ALL
SELECT 'Commandes',      COUNT(*) FROM Commandes     UNION ALL
SELECT 'LigneCommandes', COUNT(*) FROM LigneCommandes;

-- 2.2 Voir les categories
SELECT * FROM Categories ORDER BY idcateg;

-- 2.3 Voir les produits avec leur categorie
SELECT p.idproduit, p.designation, p.prixunitaire, c.nomcateg
FROM Produits p JOIN Categories c ON p.idcateg = c.idcateg
ORDER BY c.nomcateg, p.designation;

-- 2.4 Voir les lignes de commandes avec criteres de fragmentation
SELECT lc.idlignecommande, p.designation, c.nomcateg,
       lc.quantite, lc.remise,
       CASE
           WHEN c.idcateg=50 AND lc.quantite>100 THEN 'SITE1 (S1)'
           WHEN c.idcateg=35 AND lc.quantite>50  THEN 'SITE2 (S1)'
           WHEN lc.quantite>=100                  THEN 'SITE1 (S2)'
           ELSE                                        'SITE2 (S2)'
       END AS destination
FROM LigneCommandes lc
JOIN Produits p ON lc.idproduit = p.idproduit
JOIN Categories c ON p.idcateg = c.idcateg
ORDER BY destination;

-- ============================================================
-- SECTION 3 : DATABASE LINKS
-- Connexion : EShop (port 1522)
-- ============================================================

-- 3.1 Verifier les DB Links existants
SELECT db_link, username, host
FROM user_db_links
ORDER BY db_link;

-- 3.2 Tester le lien vers Site1
SELECT COUNT(*) AS nb_produits_site1
FROM Produits1@site1_link;

-- 3.3 Tester le lien vers Site2
SELECT COUNT(*) AS nb_produits_site2
FROM Produits2@site2_link;

-- 3.4 Tester les liens Scenario 2
SELECT COUNT(*) AS nb_lc_site1_s2
FROM LigneCommandes1@site1_s2_link;

SELECT COUNT(*) AS nb_lc_site2_s2
FROM LigneCommandes2@site2_s2_link;

-- ============================================================
-- SECTION 4 : FRAGMENTATION SCENARIO 1
-- Connexion : EShop_Site1 (port 1523) et EShop_Site2 (port 1524)
-- ============================================================

-- 4.1 Sur EShop_Site1 : verifier les fragments
SELECT 'Produits1'        AS table_name, COUNT(*) AS nb FROM Produits1       UNION ALL
SELECT 'LigneCommandes1',  COUNT(*) FROM LigneCommandes1 UNION ALL
SELECT 'Commandes1',       COUNT(*) FROM Commandes1      UNION ALL
SELECT 'Clients1',         COUNT(*) FROM Clients1;

-- 4.2 Sur EShop_Site1 : voir les donnees du fragment
SELECT p.designation, lc.quantite, lc.remise,
       ROUND(p.prixunitaire * lc.quantite * (1 - lc.remise/100), 2) AS montant
FROM LigneCommandes1 lc
JOIN Produits1 p ON lc.idproduit = p.idproduit
ORDER BY montant DESC;

-- 4.3 Sur EShop_Site2 : verifier les fragments
SELECT 'Produits2'        AS table_name, COUNT(*) AS nb FROM Produits2       UNION ALL
SELECT 'LigneCommandes2',  COUNT(*) FROM LigneCommandes2 UNION ALL
SELECT 'Commandes2',       COUNT(*) FROM Commandes2      UNION ALL
SELECT 'Clients2',         COUNT(*) FROM Clients2;

-- ============================================================
-- SECTION 5 : FRAGMENTATION SCENARIO 2
-- Connexion : EShop2_Site1 (port 1523) et EShop2_Site2 (port 1524)
-- ============================================================

-- 5.1 Sur EShop2_Site1 : verifier les fragments
SELECT 'Produits1'        AS table_name, COUNT(*) AS nb FROM Produits1       UNION ALL
SELECT 'LigneCommandes1',  COUNT(*) FROM LigneCommandes1 UNION ALL
SELECT 'Commandes1',       COUNT(*) FROM Commandes1      UNION ALL
SELECT 'Clients1',         COUNT(*) FROM Clients1;

-- 5.2 Sur EShop2_Site2 : verifier les fragments
SELECT 'Produits2'        AS table_name, COUNT(*) AS nb FROM Produits2       UNION ALL
SELECT 'LigneCommandes2',  COUNT(*) FROM LigneCommandes2 UNION ALL
SELECT 'Commandes2',       COUNT(*) FROM Commandes2      UNION ALL
SELECT 'Clients2',         COUNT(*) FROM Clients2;

-- ============================================================
-- SECTION 6 : PROCEDURES STOCKEES
-- Connexion : EShop_Site1 et EShop_Site2
-- ============================================================

-- 6.1 Verifier les procedures
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type IN ('PROCEDURE', 'VIEW')
ORDER BY object_type, object_name;

-- ============================================================
-- SECTION 7 : TRIGGERS SYNCHRONISATION
-- Connexion : EShop (port 1522)
-- ============================================================

-- 7.1 Verifier les triggers
SELECT trigger_name, trigger_type, triggering_event, status
FROM user_triggers
ORDER BY trigger_name;

-- 7.2 Test INSERT -> Site1 (categ=50, qte>100)
INSERT INTO LigneCommandes VALUES (92, 1, 1, 150, 0);
COMMIT;

-- 7.3 Verifier la synchronisation sur Site1
SELECT * FROM LigneCommandes1@site1_link
WHERE idlignecommande = 92;

-- 7.4 Test INSERT -> Site2 (categ=35, qte>50)
INSERT INTO LigneCommandes VALUES (91, 4, 4, 80, 0);
COMMIT;

-- 7.5 Verifier la synchronisation sur Site2
SELECT * FROM LigneCommandes2@site2_link
WHERE idlignecommande = 91;

-- 7.6 Test DELETE -> synchronisation Site1
DELETE FROM LigneCommandes WHERE idlignecommande = 92;
COMMIT;

-- 7.7 Verifier suppression sur Site1
SELECT COUNT(*) AS doit_etre_zero
FROM LigneCommandes1@site1_link
WHERE idlignecommande = 90;

-- 7.8 Nettoyage
DELETE FROM LigneCommandes WHERE idlignecommande = 91;
COMMIT;

-- ============================================================
-- SECTION 8 : REQUETES DISTRIBUEES
-- Connexion : EShop (port 1522)
-- ============================================================

-- 8.1 CA par categorie distribue (Site1 + Site2)
SELECT nomcateg, SUM(CA_Total) AS CA_Total
FROM (
    SELECT cat.nomcateg,
           SUM(p.prixunitaire * lc.quantite * (1-lc.remise/100)) AS CA_Total
    FROM LigneCommandes1@site1_link lc,
         Produits1@site1_link p,
         Categories cat
    WHERE lc.idproduit=p.idproduit AND p.idcateg=cat.idcateg
    GROUP BY cat.nomcateg
    UNION ALL
    SELECT cat.nomcateg,
           SUM(p.prixunitaire * lc.quantite * (1-lc.remise/100)) AS CA_Total
    FROM LigneCommandes2@site2_link lc,
         Produits2@site2_link p,
         Categories cat
    WHERE lc.idproduit=p.idproduit AND p.idcateg=cat.idcateg
    GROUP BY cat.nomcateg
)
GROUP BY nomcateg
ORDER BY CA_Total DESC;

-- 8.2 Nombre de commandes par client en 2026
SELECT c.idclient, c.societe, COUNT(cmd.idcommande) AS nb_commandes
FROM Clients c, Commandes cmd
WHERE c.idclient = cmd.idclient
AND EXTRACT(YEAR FROM cmd.datecommande) = 2026
GROUP BY c.idclient, c.societe
ORDER BY nb_commandes DESC;

-- 8.3 Etat global des 3 sites
SELECT 'CENTRAL' AS site, COUNT(*) AS nb_lignes FROM LigneCommandes
UNION ALL
SELECT 'SITE1',   COUNT(*) FROM LigneCommandes1@site1_link
UNION ALL
SELECT 'SITE2',   COUNT(*) FROM LigneCommandes2@site2_link;

-- ============================================================
-- SECTION 9 : OPTIMISATION SQL
-- Connexion : EShop (port 1522)
-- ============================================================

-- 9.1 Verifier les index existants
SELECT index_name, table_name, column_name, column_position
FROM user_ind_columns
WHERE table_name IN ('COMMANDES','LIGNECOMMANDES')
ORDER BY table_name, index_name;

-- 9.2 EXPLAIN PLAN avec index
EXPLAIN PLAN FOR
SELECT c.idclient, c.societe, COUNT(cmd.idcommande) AS nb_commandes
FROM Clients c, Commandes cmd
WHERE c.idclient = cmd.idclient
AND EXTRACT(YEAR FROM cmd.datecommande) = 2026
GROUP BY c.idclient, c.societe
ORDER BY nb_commandes DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- 9.3 Vues materialisees
SELECT mview_name, last_refresh_date, refresh_mode
FROM user_mviews;

-- 9.4 Interroger les vues materialisees
SELECT * FROM mv_ca_par_categorie ORDER BY ca_total DESC;
SELECT * FROM mv_ca_par_client    ORDER BY ca_total DESC;

-- 9.5 Rafraichir les vues
EXEC DBMS_MVIEW.REFRESH('MV_CA_PAR_CLIENT');
EXEC DBMS_MVIEW.REFRESH('MV_CA_PAR_CATEGORIE');

-- ============================================================
-- SECTION 10 : LOGS DE SYNCHRONISATION
-- Connexion : EShop_Site1 (port 1523)
-- ============================================================

-- 10.1 Voir les derniers logs
SELECT * FROM sync_logs
ORDER BY log_date DESC
FETCH FIRST 10 ROWS ONLY;

-- 10.2 Logs par operation
SELECT operation, COUNT(*) AS nb, MAX(log_date) AS dernier
FROM sync_logs
GROUP BY operation
ORDER BY operation;

-- 10.3 Logs depuis le Central
SELECT * FROM sync_logs@site1_link
ORDER BY log_date DESC
FETCH FIRST 5 ROWS ONLY;

-- ============================================================
-- SECTION 11 : PROCEDURES AVANCEES
-- Connexion : EShop (port 1522)
-- ============================================================

-- 11.1 Statistiques des 3 sites
EXEC get_stats_site;

-- 11.2 CA par site
EXEC get_ca_par_site;

-- 11.3 Top 5 produits
EXEC get_top_produits(5);

-- 11.4 Verification coherence
EXEC check_all_sites;

-- 11.5 Demonstration complete
EXEC demo_full;

-- ============================================================
-- SECTION 12 : VUES CA PAR CATEGORIE
-- Connexion : EShop_Site1 (port 1523)
-- ============================================================

-- 12.1 CA produits categorie 50 depuis Site1
SELECT idproduit, designation, SUM(CA) AS CA_Total
FROM (
    SELECT * FROM View1
    UNION ALL
    SELECT * FROM View2
)
GROUP BY idproduit, designation
ORDER BY CA_Total DESC;

-- Connexion : EShop_Site2 (port 1524)

-- 12.2 CA produits categorie 35 depuis Site2
SELECT idproduit, designation, SUM(CA) AS CA_Total
FROM (
    SELECT * FROM View1_S2
    UNION ALL
    SELECT * FROM View2_S2
)
GROUP BY idproduit, designation
ORDER BY CA_Total DESC;

-- ============================================================
-- SECTION 13 : SECURITE
-- Connexion : Central (system/admin port 1522)
-- ============================================================

-- 13.1 Verifier les roles existants
SELECT role FROM dba_roles
WHERE role IN ('ESHOP_READER')
ORDER BY role;

-- 13.2 Verifier les users dedies
SELECT username, account_status, created
FROM dba_users
WHERE username IN ('ESHOP','ESHOP2','DBLINK_USER','SITE1','SITE2')
ORDER BY username;

-- 13.3 Verifier les privileges du role
SELECT grantee, owner, table_name, privilege
FROM dba_tab_privs
WHERE grantee = 'ESHOP_READER'
ORDER BY table_name;

-- ============================================================
-- SECTION 14 : MONITORING
-- Connexion : Central (system/admin port 1522)
-- ============================================================

-- 14.1 Dashboard complet
EXEC monitoring_dashboard;

-- 14.2 Sessions actives
SELECT sid, username, status,
       TO_CHAR(logon_time,'DD/MM HH24:MI:SS') AS connexion
FROM v$session
WHERE username IS NOT NULL
ORDER BY logon_time DESC;

-- 14.3 Tablespaces
SELECT tablespace_name,
       ROUND(used_space*8192/1024/1024, 2) AS used_mb,
       ROUND(used_percent, 2) AS pct_used
FROM dba_tablespace_usage_metrics
ORDER BY used_percent DESC;

-- 14.4 Memoire SGA
SELECT name, ROUND(value/1024/1024, 2) AS mb
FROM v$sga;

-- 14.5 Top 5 requetes lentes EShop
SELECT ROUND(elapsed_time/1000000, 2) AS sec,
       executions,
       SUBSTR(sql_text, 1, 100) AS sql_text
FROM v$sql
WHERE parsing_schema_name = 'ESHOP'
AND elapsed_time > 0
ORDER BY elapsed_time DESC
FETCH FIRST 5 ROWS ONLY;

-- ============================================================
-- SECTION 15 : TESTS AUTOMATIQUES
-- Connexion : EShop (port 1522)
-- ============================================================

DECLARE
    v_before_s1 NUMBER; v_before_s2 NUMBER;
    v_after_s1  NUMBER; v_after_s2  NUMBER;
    v_test_id   NUMBER := 99;
    v_pass      NUMBER := 0;
    v_fail      NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TESTS AUTOMATIQUES SYNCHRONISATION ===');

    SELECT COUNT(*) INTO v_before_s1 FROM LigneCommandes1@site1_link;
    SELECT COUNT(*) INTO v_before_s2 FROM LigneCommandes2@site2_link;

    -- TEST 1 : INSERT -> Site1
    INSERT INTO LigneCommandes VALUES (v_test_id, 1, 1, 150, 0);
    COMMIT;
    SELECT COUNT(*) INTO v_after_s1 FROM LigneCommandes1@site1_link
    WHERE idlignecommande = v_test_id;
    IF v_after_s1 = 1 THEN
        DBMS_OUTPUT.PUT_LINE('[PASS] TEST 1 : INSERT -> Site1 OK');
        v_pass := v_pass + 1;
    ELSE
        DBMS_OUTPUT.PUT_LINE('[FAIL] TEST 1 : INSERT -> Site1 ECHEC');
        v_fail := v_fail + 1;
    END IF;

    -- TEST 2 : DELETE -> Site1
    DELETE FROM LigneCommandes WHERE idlignecommande = v_test_id;
    COMMIT;
    SELECT COUNT(*) INTO v_after_s1 FROM LigneCommandes1@site1_link
    WHERE idlignecommande = v_test_id;
    IF v_after_s1 = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[PASS] TEST 2 : DELETE -> Site1 OK');
        v_pass := v_pass + 1;
    ELSE
        DBMS_OUTPUT.PUT_LINE('[FAIL] TEST 2 : DELETE -> Site1 ECHEC');
        v_fail := v_fail + 1;
    END IF;

    -- TEST 3 : INSERT -> Site2
    INSERT INTO LigneCommandes VALUES (v_test_id, 4, 4, 80, 0);
    COMMIT;
    SELECT COUNT(*) INTO v_after_s2 FROM LigneCommandes2@site2_link
    WHERE idlignecommande = v_test_id;
    IF v_after_s2 = 1 THEN
        DBMS_OUTPUT.PUT_LINE('[PASS] TEST 3 : INSERT -> Site2 OK');
        v_pass := v_pass + 1;
    ELSE
        DBMS_OUTPUT.PUT_LINE('[FAIL] TEST 3 : INSERT -> Site2 ECHEC');
        v_fail := v_fail + 1;
    END IF;

    -- TEST 4 : DELETE -> Site2
    DELETE FROM LigneCommandes WHERE idlignecommande = v_test_id;
    COMMIT;
    SELECT COUNT(*) INTO v_after_s2 FROM LigneCommandes2@site2_link
    WHERE idlignecommande = v_test_id;
    IF v_after_s2 = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[PASS] TEST 4 : DELETE -> Site2 OK');
        v_pass := v_pass + 1;
    ELSE
        DBMS_OUTPUT.PUT_LINE('[FAIL] TEST 4 : DELETE -> Site2 ECHEC');
        v_fail := v_fail + 1;
    END IF;

    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('RESULTAT : ' || v_pass || ' PASS | ' || v_fail || ' FAIL');
    DBMS_OUTPUT.PUT_LINE('==========================================');
END;
/









-- ============================================================
-- DEMO UPDATE : VERIFICATION VISUELLE DU CRITERE CATEGORIE
-- Connexion : EShop (port 1522, Central)
-- ============================================================

SET SERVEROUTPUT ON;

-- ============================================================
-- ETAPE 1 : MONTRER LES CATEGORIES DES PRODUITS
-- ============================================================

SELECT p.idproduit, p.designation, p.idcateg, c.nomcateg,
       CASE 
           WHEN p.idcateg = 50 THEN 'SITE1 (si qte > 100)'
           WHEN p.idcateg = 35 THEN 'SITE2 (si qte > 50)'
           ELSE 'AUCUN SITE'
       END AS fragment
FROM   Produits p
JOIN   Categories c ON p.idcateg = c.idcateg
ORDER BY p.idcateg;



-- ============================================================
-- ETAPE 2 : ETAT INITIAL DE LA LIGNE 1
-- idproduit=1 (iPhone 14, idcateg=50, qte=150) → sur Site1
-- ============================================================

-- Categorie du produit actuel de la ligne 1
SELECT lc.idlignecommande,
       lc.idproduit,
       p.designation,
       p.idcateg,
       c.nomcateg,
       lc.quantite,
       'CRITERE SITE1 : idcateg=50 ET qte>100 → ' ||
       CASE WHEN p.idcateg = 50 AND lc.quantite > 100 
            THEN 'OUI ✓' ELSE 'NON ✗' END AS critere_site1,
       'CRITERE SITE2 : idcateg=35 ET qte>50  → ' ||
       CASE WHEN p.idcateg = 35 AND lc.quantite > 50  
            THEN 'OUI ✓' ELSE 'NON ✗' END AS critere_site2
FROM   LigneCommandes lc
JOIN   Produits p    ON lc.idproduit = p.idproduit
JOIN   Categories c  ON p.idcateg   = c.idcateg
WHERE  lc.idlignecommande = 1;

-- Presence sur les sites
SELECT 'CENTRAL' AS site, idlignecommande, idproduit, quantite FROM LigneCommandes  WHERE idlignecommande = 1
UNION ALL
SELECT 'SITE1',           idlignecommande, idproduit, quantite FROM LigneCommandes1@site1_link WHERE idlignecommande = 1
UNION ALL
SELECT 'SITE2',           idlignecommande, idproduit, quantite FROM LigneCommandes2@site2_link WHERE idlignecommande = 1;



-- ============================================================
-- ETAPE 3 : MONTRER LE NOUVEAU PRODUIT AVANT L'UPDATE
-- idproduit=4 (TV Samsung 55", idcateg=35) → critere Site2
-- ============================================================

SELECT p.idproduit,
       p.designation,
       p.idcateg,
       c.nomcateg,
       'CRITERE SITE2 : idcateg=35 ET qte=80 > 50 → OUI ✓' AS verification
FROM   Produits p
JOIN   Categories c ON p.idcateg = c.idcateg
WHERE  p.idproduit = 4;



-- ============================================================
-- ETAPE 4 : DESACTIVER SCENARIO 2
-- ============================================================

ALTER TRIGGER SYC_INSERT_LIGNE_S2 DISABLE;
ALTER TRIGGER SYC_DELETE_LIGNE_S2 DISABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE_S2 DISABLE;



-- ============================================================

UPDATE LigneCommandes
SET    idproduit = 4,   -- TV Samsung 55" → idcateg=35 → critere Site2
       quantite  = 80,  -- 80 > 50 → critere Site2 respecte
       remise    = 0
WHERE  idlignecommande = 1;
COMMIT;


-- ============================================================
-- ETAPE 6 : VERIFICATION APRES UPDATE
-- Montrer que le trigger a bien lu la categorie et agi en consequence
-- ============================================================

-- Vue complete sur les 3 noeuds avec les categories
SELECT 'CENTRAL' AS site,
       lc.idlignecommande,
       lc.idproduit,
       p.designation,
       p.idcateg,
       c.nomcateg,
       lc.quantite
FROM   LigneCommandes lc
JOIN   Produits p   ON lc.idproduit = p.idproduit
JOIN   Categories c ON p.idcateg   = c.idcateg
WHERE  lc.idlignecommande = 1

UNION ALL

SELECT 'SITE1',
       lc.idlignecommande,
       lc.idproduit,
       p.designation,
       p.idcateg,
       c.nomcateg,
       lc.quantite
FROM   LigneCommandes1@site1_link lc
JOIN   Produits1@site1_link p   ON lc.idproduit = p.idproduit
JOIN   Categories@central_link c ON p.idcateg  = c.idcateg
WHERE  lc.idlignecommande = 1

UNION ALL

SELECT 'SITE2',
       lc.idlignecommande,
       lc.idproduit,
       p.designation,
       p.idcateg,
       c.nomcateg,
       lc.quantite
FROM   LigneCommandes2@site2_link lc
JOIN   Produits2@site2_link p    ON lc.idproduit = p.idproduit
JOIN   Categories@central_link c ON p.idcateg   = c.idcateg
WHERE  lc.idlignecommande = 1;

-- Resultat attendu :
--   CENTRAL : idproduit=4, idcateg=35, Electronique, qte=80
--   SITE1   : 0 ligne  → supprimee car idcateg=50 ne correspond plus
--   SITE2   : idproduit=4, idcateg=35, Electronique, qte=80 ✓


-- Confirmation explicite du critere respecte sur Site2
SELECT lc.idlignecommande,
       p.idcateg,
       c.nomcateg,
       lc.quantite,
       'idcateg=' || p.idcateg || ' = 35 ✓  ET  qte=' || lc.quantite || ' > 50 ✓' AS critere_verifie
FROM   LigneCommandes2@site2_link lc
JOIN   Produits2@site2_link p    ON lc.idproduit = p.idproduit
JOIN   Categories@central_link c ON p.idcateg   = c.idcateg
WHERE  lc.idlignecommande = 1;
-- Le prof voit : idcateg=35 ET qte=80>50 → le critere est bien respecte


-- Logs Site1 : DELETE effectue
SELECT 'LOG_SITE1' AS source, operation, record_id, statut,
       TO_CHAR(log_date, 'DD/MM HH24:MI:SS') AS heure
FROM   sync_logs@site1_link
ORDER BY log_date DESC
FETCH FIRST 3 ROWS ONLY;

-- Logs Site2 : INSERT effectue
SELECT 'LOG_SITE2' AS source, operation, record_id, statut,
       TO_CHAR(log_date, 'DD/MM HH24:MI:SS') AS heure
FROM   sync_logs@site2_link
ORDER BY log_date DESC
FETCH FIRST 3 ROWS ONLY;


-- ============================================================
-- ETAPE 7 : REACTIVER SCENARIO 2
-- ============================================================

ALTER TRIGGER SYC_INSERT_LIGNE_S2 ENABLE;
ALTER TRIGGER SYC_DELETE_LIGNE_S2 ENABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE_S2 ENABLE;


-- ============================================================
-- ETAPE 8 : RESTAURATION
-- ============================================================

-- Desactiver tous les triggers
ALTER TRIGGER SYC_INSERT_LIGNE    DISABLE;
ALTER TRIGGER SYC_DELETE_LIGNE    DISABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE    DISABLE;
ALTER TRIGGER SYC_INSERT_LIGNE_S2 DISABLE;
ALTER TRIGGER SYC_DELETE_LIGNE_S2 DISABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE_S2 DISABLE;

-- Restaurer le central
UPDATE LigneCommandes
SET idproduit = 1, quantite = 150, remise = 5
WHERE idlignecommande = 1;
COMMIT;

-- ► Sur EShop_Site2 (port 1524) executer :
--   DELETE FROM LigneCommandes2 WHERE idlignecommande = 1;
--   COMMIT;

-- ► Sur EShop_Site1 (port 1523) executer :
--   INSERT INTO LigneCommandes1 VALUES (1, 1, 1, 150, 5);
--   COMMIT;

-- Reactiver tous les triggers
ALTER TRIGGER SYC_INSERT_LIGNE    ENABLE;
ALTER TRIGGER SYC_DELETE_LIGNE    ENABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE    ENABLE;
ALTER TRIGGER SYC_INSERT_LIGNE_S2 ENABLE;
ALTER TRIGGER SYC_DELETE_LIGNE_S2 ENABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE_S2 ENABLE;

-- Verification finale
SELECT 'CENTRAL' AS site, idproduit, quantite FROM LigneCommandes          WHERE idlignecommande = 1
UNION ALL
SELECT 'SITE1',           idproduit, quantite FROM LigneCommandes1@site1_link WHERE idlignecommande = 1
UNION ALL
SELECT 'SITE2',           idproduit, quantite FROM LigneCommandes2@site2_link WHERE idlignecommande = 1;
-- Attendu : idproduit=1, qte=150 sur CENTRAL et SITE1, absent de SITE2

-- ============================================================
-- FIN DEMO
-- ============================================================














-- ============================================================
-- DEMO UPDATE : MIGRATION SITE1 -> SITE2
-- Connexion : EShop (port 1522)
-- ============================================================

SET SERVEROUTPUT ON;

-- ============================================================
-- AVANT LA DEMO : VERIFICATION ETAT INITIAL
-- ============================================================

-- Montrer la categorie du produit actuel de la ligne 1
-- Le prof voit : idcateg=50 (Telephonie) → critere Site1
SELECT p.idproduit, p.designation, p.idcateg, c.nomcateg, lc.quantite,
       'idcateg=50 ET qte=150>100 → SITE1 ✓' AS critere_actuel
FROM   LigneCommandes lc
JOIN   Produits p   ON lc.idproduit = p.idproduit
JOIN   Categories c ON p.idcateg   = c.idcateg
WHERE  lc.idlignecommande = 1;

-- Ligne 1 doit etre sur Site1
SELECT * FROM LigneCommandes1@site1_link WHERE idlignecommande = 1;

-- Ligne 1 doit etre absente de Site2
SELECT COUNT(*) AS doit_etre_zero
FROM LigneCommandes2@site2_link WHERE idlignecommande = 1;

-- ============================================================
-- PENDANT LA DEMO
-- ============================================================

-- Montrer la categorie du NOUVEAU produit avant l'UPDATE
-- Le prof voit : idcateg=35 (Electronique) → critere Site2
SELECT p.idproduit, p.designation, p.idcateg, c.nomcateg,
       'idcateg=35 ET qte=80>50 → SITE2 ✓' AS critere_nouveau
FROM   Produits p
JOIN   Categories c ON p.idcateg = c.idcateg
WHERE  p.idproduit = 4;

-- Etape 1 : Desactiver Scenario 2 (eviter ORA-02020)
ALTER TRIGGER SYC_INSERT_LIGNE_S2 DISABLE;
ALTER TRIGGER SYC_DELETE_LIGNE_S2 DISABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE_S2 DISABLE;

-- Etape 2 : UPDATE -> migration Site1 vers Site2
-- Le trigger lit idcateg=35 du nouveau produit → envoie sur Site2
UPDATE LigneCommandes
SET idproduit = 4, quantite = 80, remise = 0
WHERE idlignecommande = 1;
COMMIT;

-- Etape 3 : Verifier Site1 (doit etre vide)
SELECT COUNT(*) AS doit_etre_zero
FROM LigneCommandes1@site1_link WHERE idlignecommande = 1;

-- Etape 4 : Verifier Site2 (doit avoir la ligne) avec sa categorie
-- Le prof voit idcateg=35 confirmant que le trigger a bien verifie le critere
SELECT lc.idlignecommande, lc.idproduit, p.designation,
       p.idcateg, c.nomcateg, lc.quantite,
       'idcateg=' || p.idcateg || '=35 ✓  ET  qte=' || lc.quantite || '>50 ✓' AS critere_verifie
FROM   LigneCommandes2@site2_link lc
JOIN   Produits2@site2_link p    ON lc.idproduit = p.idproduit
JOIN   Categories@central_link c ON p.idcateg   = c.idcateg
WHERE  lc.idlignecommande = 1;

-- Etape 5 : Logs Site1 (DELETE)
SELECT * FROM sync_logs@site1_link
ORDER BY log_date DESC FETCH FIRST 3 ROWS ONLY;

-- Etape 6 : Logs Site2 (INSERT)
-- CORRECTION : site2_logs_link → site2_link
SELECT * FROM sync_logs@site2_link
ORDER BY log_date DESC FETCH FIRST 3 ROWS ONLY;

-- Etape 7 : Reactiver Scenario 2
ALTER TRIGGER SYC_INSERT_LIGNE_S2 ENABLE;
ALTER TRIGGER SYC_DELETE_LIGNE_S2 ENABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE_S2 ENABLE;

-- ============================================================
-- APRES LA DEMO : RESTAURATION
-- ============================================================

-- Etape 1 : Desactiver tous les triggers
ALTER TRIGGER SYC_INSERT_LIGNE    DISABLE;
ALTER TRIGGER SYC_DELETE_LIGNE    DISABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE    DISABLE;
ALTER TRIGGER SYC_INSERT_LIGNE_S2 DISABLE;
ALTER TRIGGER SYC_DELETE_LIGNE_S2 DISABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE_S2 DISABLE;

-- Etape 2 : Restaurer Central
UPDATE LigneCommandes
SET idproduit = 1, quantite = 150, remise = 5
WHERE idlignecommande = 1;
COMMIT;

-- ============================================================
-- Etape 3 : Sur EShop_Site2 (port 1524) executer :
-- DELETE FROM LigneCommandes2 WHERE idlignecommande = 1;
-- COMMIT;
-- ============================================================

-- ============================================================
-- Etape 4 : Sur EShop_Site1 (port 1523) executer :
-- INSERT INTO LigneCommandes1 VALUES (1, 1, 1, 150, 5);
-- COMMIT;
-- ============================================================

-- Etape 5 : Reactiver tous les triggers (sur EShop)
ALTER TRIGGER SYC_INSERT_LIGNE    ENABLE;
ALTER TRIGGER SYC_DELETE_LIGNE    ENABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE    ENABLE;
ALTER TRIGGER SYC_INSERT_LIGNE_S2 ENABLE;
ALTER TRIGGER SYC_DELETE_LIGNE_S2 ENABLE;
ALTER TRIGGER SYC_UPDATE_LIGNE_S2 ENABLE;

-- Etape 6 : Verifier etat final
SELECT * FROM LigneCommandes1@site1_link WHERE idlignecommande = 1;
SELECT COUNT(*) AS doit_etre_zero
FROM LigneCommandes2@site2_link WHERE idlignecommande = 1;