-- ============================================================
-- ESHOP BDD DISTRIBUEE - PROCEDURES SITE1 SCENARIO 2
-- Connexion : EShop2@localhost:1523/XEPDB1
-- ============================================================

CREATE OR REPLACE PROCEDURE log_sync(
    p_op   VARCHAR2, p_tbl VARCHAR2,
    p_id   NUMBER,   p_stat VARCHAR2,
    p_msg  VARCHAR2 DEFAULT NULL
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO sync_logs(operation, table_name, record_id, statut, message)
    VALUES (p_op, p_tbl, p_id, p_stat, p_msg);
    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE INSERTligne(
    a LigneCommandes1.idlignecommande%TYPE,
    b LigneCommandes1.idcommande%TYPE,
    c LigneCommandes1.idproduit%TYPE,
    d LigneCommandes1.quantite%TYPE,
    e LigneCommandes1.remise%TYPE
) IS
    nc INTEGER; np INTEGER; n INTEGER;
    Rc  Commandes1%ROWTYPE;
    Rp  Produits1%ROWTYPE;
    Rcl Clients1%ROWTYPE;
    v_id NUMBER;
BEGIN
    v_id := a;
    SELECT COUNT(*) INTO nc FROM Commandes1 WHERE idcommande=b;
    IF (nc=0) THEN
        SELECT * INTO Rc FROM Commandes@central_link WHERE idcommande=b;
        SELECT COUNT(*) INTO n FROM Clients1 WHERE idclient=Rc.idclient;
        IF (n=0) THEN
            SELECT * INTO Rcl FROM Clients@central_link WHERE idclient=Rc.idclient;
            INSERT INTO Clients1 VALUES Rcl;
        END IF;
        INSERT INTO Commandes1 VALUES Rc;
    END IF;
    SELECT COUNT(*) INTO np FROM Produits1 WHERE idproduit=c;
    IF (np=0) THEN
        SELECT * INTO Rp FROM Produits@central_link WHERE idproduit=c;
        INSERT INTO Produits1 VALUES Rp;
    END IF;
    INSERT INTO LigneCommandes1 VALUES (a, b, c, d, e);
    log_sync('INSERT', 'LIGNECOMMANDES1_S2', v_id, 'OK');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        log_sync('INSERT', 'LIGNECOMMANDES1_S2', v_id, 'ERREUR', 'Doublon detecte');
        RAISE;
    WHEN OTHERS THEN
        log_sync('INSERT', 'LIGNECOMMANDES1_S2', v_id, 'ERREUR', SQLERRM);
        RAISE;
END;
/

CREATE OR REPLACE PROCEDURE DELETEligne(
    a LigneCommandes1.idlignecommande%TYPE
) IS
    nc INTEGER; ncL INTEGER;
    idc  Commandes1.idcommande%TYPE;
    idp  Produits1.idproduit%TYPE;
    idcL Clients1.idclient%TYPE;
    v_id NUMBER;
BEGIN
    v_id := a;
    SELECT idcommande, idproduit INTO idc, idp
    FROM LigneCommandes1 WHERE idlignecommande=a;
    DELETE LigneCommandes1 WHERE idlignecommande=a;
    SELECT COUNT(*) INTO nc FROM LigneCommandes1 WHERE idcommande=idc;
    IF (nc=0) THEN
        SELECT idclient INTO idcL FROM Commandes1 WHERE idcommande=idc;
        DELETE Commandes1 WHERE idcommande=idc;
        SELECT COUNT(*) INTO ncL FROM Commandes1 WHERE idclient=idcL;
        IF (ncL=0) THEN DELETE Clients1 WHERE idclient=idcL; END IF;
    END IF;
    SELECT COUNT(*) INTO nc FROM LigneCommandes1 WHERE idproduit=idp;
    IF (nc=0) THEN DELETE Produits1 WHERE idproduit=idp; END IF;
    log_sync('DELETE', 'LIGNECOMMANDES1_S2', v_id, 'OK');
EXCEPTION
    WHEN OTHERS THEN
        log_sync('DELETE', 'LIGNECOMMANDES1_S2', v_id, 'ERREUR', SQLERRM);
        RAISE;
END;
/

CREATE OR REPLACE PROCEDURE UPDATEligne(
    a LigneCommandes1.idlignecommande%TYPE,
    b LigneCommandes1.idproduit%TYPE,
    c LigneCommandes1.quantite%TYPE,
    d LigneCommandes1.remise%TYPE
) IS
    n INTEGER; x INTEGER;
    Rp Produits1%ROWTYPE;
    v_id NUMBER;
BEGIN
    v_id := a;
    SELECT idproduit INTO x FROM LigneCommandes1 WHERE idlignecommande=a;
    SELECT COUNT(*) INTO n FROM Produits1 WHERE idproduit=b;
    IF (n=0) THEN
        SELECT * INTO Rp FROM Produits@central_link WHERE idproduit=b;
        INSERT INTO Produits1 VALUES Rp;
    END IF;
    UPDATE LigneCommandes1 SET idproduit=b, quantite=c, remise=d
    WHERE idlignecommande=a;
    SELECT COUNT(*) INTO n FROM LigneCommandes1 WHERE idproduit=x;
    IF (n=0) THEN DELETE Produits1 WHERE idproduit=x; END IF;
    log_sync('UPDATE', 'LIGNECOMMANDES1_S2', v_id, 'OK');
EXCEPTION
    WHEN OTHERS THEN
        log_sync('UPDATE', 'LIGNECOMMANDES1_S2', v_id, 'ERREUR', SQLERRM);
        RAISE;
END;
/
