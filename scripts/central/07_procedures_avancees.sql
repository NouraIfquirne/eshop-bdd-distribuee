-- ============================================================
-- ESHOP BDD DISTRIBUEE - PROCEDURES AVANCEES
-- Connexion : EShop@localhost:1522/XEPDB1
-- ============================================================

-- ============================================================
-- STATISTIQUES DES 3 SITES
-- ============================================================
CREATE OR REPLACE PROCEDURE get_stats_site IS
    v_central_lc  NUMBER; v_central_cmd NUMBER; v_central_cli NUMBER;
    v_s1_lc       NUMBER; v_s1_cmd      NUMBER; v_s1_cli      NUMBER;
    v_s2_lc       NUMBER; v_s2_cmd      NUMBER; v_s2_cli      NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_central_lc  FROM LigneCommandes;
    SELECT COUNT(*) INTO v_central_cmd FROM Commandes;
    SELECT COUNT(*) INTO v_central_cli FROM Clients;
    SELECT COUNT(*) INTO v_s1_lc  FROM LigneCommandes1@site1_link;
    SELECT COUNT(*) INTO v_s1_cmd FROM Commandes1@site1_link;
    SELECT COUNT(*) INTO v_s1_cli FROM Clients1@site1_link;
    SELECT COUNT(*) INTO v_s2_lc  FROM LigneCommandes2@site2_link;
    SELECT COUNT(*) INTO v_s2_cmd FROM Commandes2@site2_link;
    SELECT COUNT(*) INTO v_s2_cli FROM Clients2@site2_link;

    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('       STATISTIQUES DES 3 SITES             ');
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('                CENTRAL    SITE1    SITE2');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('LigneCommandes: ' ||
        RPAD(v_central_lc,10) || RPAD(v_s1_lc,9) || v_s2_lc);
    DBMS_OUTPUT.PUT_LINE('Commandes:      ' ||
        RPAD(v_central_cmd,10) || RPAD(v_s1_cmd,9) || v_s2_cmd);
    DBMS_OUTPUT.PUT_LINE('Clients:        ' ||
        RPAD(v_central_cli,10) || RPAD(v_s1_cli,9) || v_s2_cli);
    DBMS_OUTPUT.PUT_LINE('============================================');
END;
/

-- ============================================================
-- CA PAR SITE
-- ============================================================
CREATE OR REPLACE PROCEDURE get_ca_par_site IS
    v_ca_s1 NUMBER; v_ca_s2 NUMBER; v_ca_total NUMBER;
BEGIN
    SELECT NVL(SUM(p.prixunitaire * lc.quantite * (1 - lc.remise/100)), 0)
    INTO v_ca_s1
    FROM LigneCommandes1@site1_link lc
    JOIN Produits1@site1_link p ON lc.idproduit = p.idproduit;

    SELECT NVL(SUM(p.prixunitaire * lc.quantite * (1 - lc.remise/100)), 0)
    INTO v_ca_s2
    FROM LigneCommandes2@site2_link lc
    JOIN Produits2@site2_link p ON lc.idproduit = p.idproduit;

    v_ca_total := v_ca_s1 + v_ca_s2;

    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('      CHIFFRE D AFFAIRES PAR SITE           ');
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('Site1 (Telephonie qte>100) : ' ||
        TO_CHAR(v_ca_s1, '999,999,999.99'));
    DBMS_OUTPUT.PUT_LINE('Site2 (Electronique qte>50): ' ||
        TO_CHAR(v_ca_s2, '999,999,999.99'));
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('TOTAL DISTRIBUE            : ' ||
        TO_CHAR(v_ca_total, '999,999,999.99'));
    DBMS_OUTPUT.PUT_LINE('============================================');
END;
/

-- ============================================================
-- TOP N PRODUITS
-- ============================================================
CREATE OR REPLACE PROCEDURE get_top_produits(p_top NUMBER DEFAULT 5) IS
    CURSOR c_top IS
        SELECT p.designation,
               SUM(lc.quantite) AS total_qte,
               SUM(p.prixunitaire * lc.quantite * (1 - lc.remise/100)) AS ca
        FROM LigneCommandes lc
        JOIN Produits p ON lc.idproduit = p.idproduit
        GROUP BY p.designation
        ORDER BY ca DESC
        FETCH FIRST p_top ROWS ONLY;
    v_rang NUMBER := 1;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('        TOP ' || p_top || ' PRODUITS PAR CA');
    DBMS_OUTPUT.PUT_LINE('============================================');
    FOR rec IN c_top LOOP
        DBMS_OUTPUT.PUT_LINE(
            v_rang || '. ' || RPAD(rec.designation, 25) ||
            ' CA: ' || TO_CHAR(rec.ca, '999,999.99') ||
            ' Qte: ' || rec.total_qte);
        v_rang := v_rang + 1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('============================================');
END;
/

-- ============================================================
-- VERIFICATION COHERENCE SITE1
-- ============================================================
CREATE OR REPLACE PROCEDURE check_coherence_site1 IS
    v_count_central NUMBER; v_count_site1 NUMBER;
    v_ok BOOLEAN := TRUE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('   VERIFICATION COHERENCE CENTRAL <-> SITE1 ');
    DBMS_OUTPUT.PUT_LINE('============================================');

    SELECT COUNT(*) INTO v_count_central FROM LigneCommandes
    WHERE idproduit IN (SELECT idproduit FROM Produits WHERE idcateg=50)
    AND quantite > 100;
    SELECT COUNT(*) INTO v_count_site1 FROM LigneCommandes1@site1_link;
    DBMS_OUTPUT.PUT_LINE('LigneCommandes:');
    DBMS_OUTPUT.PUT_LINE('  Central : ' || v_count_central);
    DBMS_OUTPUT.PUT_LINE('  Site1   : ' || v_count_site1);
    IF v_count_central = v_count_site1 THEN
        DBMS_OUTPUT.PUT_LINE('  Statut  : [OK]');
    ELSE
        DBMS_OUTPUT.PUT_LINE('  Statut  : [ALERTE] Incoherence detectee!');
        v_ok := FALSE;
    END IF;

    SELECT COUNT(*) INTO v_count_central FROM Commandes
    WHERE idcommande IN (SELECT idcommande FROM LigneCommandes
        WHERE idproduit IN (SELECT idproduit FROM Produits WHERE idcateg=50)
        AND quantite > 100);
    SELECT COUNT(*) INTO v_count_site1 FROM Commandes1@site1_link;
    DBMS_OUTPUT.PUT_LINE('Commandes:');
    DBMS_OUTPUT.PUT_LINE('  Central : ' || v_count_central);
    DBMS_OUTPUT.PUT_LINE('  Site1   : ' || v_count_site1);
    IF v_count_central = v_count_site1 THEN
        DBMS_OUTPUT.PUT_LINE('  Statut  : [OK]');
    ELSE
        DBMS_OUTPUT.PUT_LINE('  Statut  : [ALERTE] Incoherence detectee!');
        v_ok := FALSE;
    END IF;

    SELECT COUNT(*) INTO v_count_central FROM Clients
    WHERE idclient IN (SELECT idclient FROM Commandes WHERE idcommande IN (
        SELECT idcommande FROM LigneCommandes
        WHERE idproduit IN (SELECT idproduit FROM Produits WHERE idcateg=50)
        AND quantite > 100));
    SELECT COUNT(*) INTO v_count_site1 FROM Clients1@site1_link;
    DBMS_OUTPUT.PUT_LINE('Clients:');
    DBMS_OUTPUT.PUT_LINE('  Central : ' || v_count_central);
    DBMS_OUTPUT.PUT_LINE('  Site1   : ' || v_count_site1);
    IF v_count_central = v_count_site1 THEN
        DBMS_OUTPUT.PUT_LINE('  Statut  : [OK]');
    ELSE
        DBMS_OUTPUT.PUT_LINE('  Statut  : [ALERTE] Incoherence detectee!');
        v_ok := FALSE;
    END IF;

    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    IF v_ok THEN
        DBMS_OUTPUT.PUT_LINE('RESULTAT GLOBAL : [OK] Sites coherents');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULTAT GLOBAL : [ALERTE] Verifier les logs!');
    END IF;
    DBMS_OUTPUT.PUT_LINE('============================================');
END;
/

-- ============================================================
-- VERIFICATION COHERENCE SITE2
-- ============================================================
CREATE OR REPLACE PROCEDURE check_coherence_site2 IS
    v_count_central NUMBER; v_count_site2 NUMBER;
    v_ok BOOLEAN := TRUE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('   VERIFICATION COHERENCE CENTRAL <-> SITE2 ');
    DBMS_OUTPUT.PUT_LINE('============================================');

    SELECT COUNT(*) INTO v_count_central FROM LigneCommandes
    WHERE idproduit IN (SELECT idproduit FROM Produits WHERE idcateg=35)
    AND quantite > 50;
    SELECT COUNT(*) INTO v_count_site2 FROM LigneCommandes2@site2_link;
    DBMS_OUTPUT.PUT_LINE('LigneCommandes:');
    DBMS_OUTPUT.PUT_LINE('  Central : ' || v_count_central);
    DBMS_OUTPUT.PUT_LINE('  Site2   : ' || v_count_site2);
    IF v_count_central = v_count_site2 THEN DBMS_OUTPUT.PUT_LINE('  Statut  : [OK]');
    ELSE DBMS_OUTPUT.PUT_LINE('  Statut  : [ALERTE]'); v_ok := FALSE; END IF;

    SELECT COUNT(*) INTO v_count_central FROM Commandes
    WHERE idcommande IN (SELECT idcommande FROM LigneCommandes
        WHERE idproduit IN (SELECT idproduit FROM Produits WHERE idcateg=35)
        AND quantite > 50);
    SELECT COUNT(*) INTO v_count_site2 FROM Commandes2@site2_link;
    DBMS_OUTPUT.PUT_LINE('Commandes:');
    DBMS_OUTPUT.PUT_LINE('  Central : ' || v_count_central);
    DBMS_OUTPUT.PUT_LINE('  Site2   : ' || v_count_site2);
    IF v_count_central = v_count_site2 THEN DBMS_OUTPUT.PUT_LINE('  Statut  : [OK]');
    ELSE DBMS_OUTPUT.PUT_LINE('  Statut  : [ALERTE]'); v_ok := FALSE; END IF;

    SELECT COUNT(*) INTO v_count_central FROM Clients
    WHERE idclient IN (SELECT idclient FROM Commandes WHERE idcommande IN (
        SELECT idcommande FROM LigneCommandes
        WHERE idproduit IN (SELECT idproduit FROM Produits WHERE idcateg=35)
        AND quantite > 50));
    SELECT COUNT(*) INTO v_count_site2 FROM Clients2@site2_link;
    DBMS_OUTPUT.PUT_LINE('Clients:');
    DBMS_OUTPUT.PUT_LINE('  Central : ' || v_count_central);
    DBMS_OUTPUT.PUT_LINE('  Site2   : ' || v_count_site2);
    IF v_count_central = v_count_site2 THEN DBMS_OUTPUT.PUT_LINE('  Statut  : [OK]');
    ELSE DBMS_OUTPUT.PUT_LINE('  Statut  : [ALERTE]'); v_ok := FALSE; END IF;

    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    IF v_ok THEN DBMS_OUTPUT.PUT_LINE('RESULTAT GLOBAL : [OK] Sites coherents');
    ELSE DBMS_OUTPUT.PUT_LINE('RESULTAT GLOBAL : [ALERTE] Verifier les logs!'); END IF;
    DBMS_OUTPUT.PUT_LINE('============================================');
END;
/

-- ============================================================
-- VERIFICATION TOUS LES SITES
-- ============================================================
CREATE OR REPLACE PROCEDURE check_all_sites IS
BEGIN
    check_coherence_site1;
    DBMS_OUTPUT.PUT_LINE('');
    check_coherence_site2;
END;
/

-- ============================================================
-- DEMO INSERT SITE1
-- ============================================================
CREATE OR REPLACE PROCEDURE demo_insert_site1 IS
    v_before NUMBER; v_after NUMBER; v_test_id NUMBER := 98;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('   DEMO INSERT -> SITE1 (categ=50, qte>100)');
    DBMS_OUTPUT.PUT_LINE('============================================');
    SELECT COUNT(*) INTO v_before FROM LigneCommandes1@site1_link;
    DBMS_OUTPUT.PUT_LINE('Avant INSERT - Site1 LigneCommandes: ' || v_before);
    INSERT INTO LigneCommandes VALUES (v_test_id, 1, 1, 150, 0);
    COMMIT;
    SELECT COUNT(*) INTO v_after FROM LigneCommandes1@site1_link;
    DBMS_OUTPUT.PUT_LINE('Apres INSERT - Site1 LigneCommandes: ' || v_after);
    IF v_after = v_before + 1 THEN
        DBMS_OUTPUT.PUT_LINE('RESULTAT: [OK] Synchronisation Site1 reussie!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULTAT: [ECHEC] Synchronisation echouee!');
    END IF;
    DELETE FROM LigneCommandes WHERE idlignecommande=v_test_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Nettoyage effectue.');
    DBMS_OUTPUT.PUT_LINE('============================================');
END;
/

-- ============================================================
-- DEMO INSERT SITE2
-- ============================================================
CREATE OR REPLACE PROCEDURE demo_insert_site2 IS
    v_before NUMBER; v_after NUMBER; v_test_id NUMBER := 97;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('   DEMO INSERT -> SITE2 (categ=35, qte>50) ');
    DBMS_OUTPUT.PUT_LINE('============================================');
    SELECT COUNT(*) INTO v_before FROM LigneCommandes2@site2_link;
    DBMS_OUTPUT.PUT_LINE('Avant INSERT - Site2 LigneCommandes: ' || v_before);
    INSERT INTO LigneCommandes VALUES (v_test_id, 4, 4, 80, 0);
    COMMIT;
    SELECT COUNT(*) INTO v_after FROM LigneCommandes2@site2_link;
    DBMS_OUTPUT.PUT_LINE('Apres INSERT - Site2 LigneCommandes: ' || v_after);
    IF v_after = v_before + 1 THEN
        DBMS_OUTPUT.PUT_LINE('RESULTAT: [OK] Synchronisation Site2 reussie!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULTAT: [ECHEC] Synchronisation echouee!');
    END IF;
    DELETE FROM LigneCommandes WHERE idlignecommande=v_test_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Nettoyage effectue.');
    DBMS_OUTPUT.PUT_LINE('============================================');
END;
/

-- ============================================================
-- DEMO COMPLETE
-- ============================================================
CREATE OR REPLACE PROCEDURE demo_full IS
    v_s1_before NUMBER; v_s1_after NUMBER;
    v_s2_before NUMBER; v_s2_after NUMBER;
    v_test_id1 NUMBER := 95; v_test_id2 NUMBER := 96;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('     DEMONSTRATION COMPLETE ESHOP DISTRIBUE ');
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('--- ETAT INITIAL ---');
    SELECT COUNT(*) INTO v_s1_before FROM LigneCommandes1@site1_link;
    SELECT COUNT(*) INTO v_s2_before FROM LigneCommandes2@site2_link;
    DBMS_OUTPUT.PUT_LINE('Site1 LigneCommandes: ' || v_s1_before);
    DBMS_OUTPUT.PUT_LINE('Site2 LigneCommandes: ' || v_s2_before);

    DBMS_OUTPUT.PUT_LINE('--- INSERT categ=50, qte=150 -> SITE1 ---');
    INSERT INTO LigneCommandes VALUES (v_test_id1, 1, 1, 150, 0);
    COMMIT;
    SELECT COUNT(*) INTO v_s1_after FROM LigneCommandes1@site1_link;
    IF v_s1_after = v_s1_before + 1 THEN
        DBMS_OUTPUT.PUT_LINE('[OK] Site1: ' || v_s1_before || ' -> ' || v_s1_after);
    ELSE DBMS_OUTPUT.PUT_LINE('[ECHEC] Site1 non synchronise!'); END IF;

    DBMS_OUTPUT.PUT_LINE('--- INSERT categ=35, qte=80 -> SITE2 ---');
    INSERT INTO LigneCommandes VALUES (v_test_id2, 4, 4, 80, 0);
    COMMIT;
    SELECT COUNT(*) INTO v_s2_after FROM LigneCommandes2@site2_link;
    IF v_s2_after = v_s2_before + 1 THEN
        DBMS_OUTPUT.PUT_LINE('[OK] Site2: ' || v_s2_before || ' -> ' || v_s2_after);
    ELSE DBMS_OUTPUT.PUT_LINE('[ECHEC] Site2 non synchronise!'); END IF;

    DBMS_OUTPUT.PUT_LINE('--- CHIFFRE D AFFAIRES DISTRIBUE ---');
    get_ca_par_site();

    DBMS_OUTPUT.PUT_LINE('--- DERNIERS LOGS SITE1 ---');
    FOR rec IN (
        SELECT operation, record_id, statut,
               TO_CHAR(log_date,'DD/MM HH24:MI:SS') AS log_date
        FROM sync_logs@site1_link
        ORDER BY log_date DESC
        FETCH FIRST 3 ROWS ONLY
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.log_date || ' | ' ||
            rec.operation || ' | ID=' || rec.record_id || ' | ' || rec.statut);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('--- NETTOYAGE ---');
    DELETE FROM LigneCommandes WHERE idlignecommande IN (v_test_id1, v_test_id2);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Donnees test supprimees.');
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('   FIN DE LA DEMONSTRATION                  ');
    DBMS_OUTPUT.PUT_LINE('============================================');
END;
/
