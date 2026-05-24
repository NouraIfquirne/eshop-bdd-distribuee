-- ============================================================
-- ESHOP BDD DISTRIBUEE - PROCEDURES SITE2 SCENARIO 1
-- Connexion : EShop@localhost:1524/XEPDB1
-- ============================================================

CREATE TABLE sync_logs (
    id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    operation   VARCHAR2(20),
    table_name  VARCHAR2(50),
    record_id   NUMBER,
    statut      VARCHAR2(10),
    message     VARCHAR2(500),
    log_date    TIMESTAMP DEFAULT SYSTIMESTAMP
);

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
    a LigneCommandes2.idlignecommande%TYPE,
    b LigneCommandes2.idcommande%TYPE,
    c LigneCommandes2.idproduit%TYPE,
    d LigneCommandes2.quantite%TYPE,
    e LigneCommandes2.remise%TYPE
) IS
    nc INTEGER; np INTEGER; n INTEGER;
    Rc  Commandes2%ROWTYPE;
    Rp  Produits2%ROWTYPE;
    Rcl Clients2%ROWTYPE;
    v_id NUMBER;
BEGIN
    v_id := a;
    SELECT COUNT(*) INTO nc FROM Commandes2 WHERE idcommande=b;
    IF (nc=0) THEN
        SELECT * INTO Rc FROM Commandes@central_link WHERE idcommande=b;
        SELECT COUNT(*) INTO n FROM Clients2 WHERE idclient=Rc.idclient;
        IF (n=0) THEN
            SELECT * INTO Rcl FROM Clients@central_link WHERE idclient=Rc.idclient;
            INSERT INTO Clients2 VALUES Rcl;
        END IF;
        INSERT INTO Commandes2 VALUES Rc;
    END IF;
    SELECT COUNT(*) INTO np FROM Produits2 WHERE idproduit=c;
    IF (np=0) THEN
        SELECT * INTO Rp FROM Produits@central_link WHERE idproduit=c;
        INSERT INTO Produits2 VALUES Rp;
    END IF;
    INSERT INTO LigneCommandes2 VALUES (a, b, c, d, e);
    log_sync('INSERT', 'LIGNECOMMANDES2', v_id, 'OK');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        log_sync('INSERT', 'LIGNECOMMANDES2', v_id, 'ERREUR', 'Doublon detecte');
        RAISE;
    WHEN OTHERS THEN
        log_sync('INSERT', 'LIGNECOMMANDES2', v_id, 'ERREUR', SQLERRM);
        RAISE;
END;
/

CREATE OR REPLACE PROCEDURE DELETEligne(
    a LigneCommandes2.idlignecommande%TYPE
) IS
    nc INTEGER; ncL INTEGER;
    idc  Commandes2.idcommande%TYPE;
    idp  Produits2.idproduit%TYPE;
    idcL Clients2.idclient%TYPE;
    v_id NUMBER;
BEGIN
    v_id := a;
    SELECT idcommande, idproduit INTO idc, idp
    FROM LigneCommandes2 WHERE idlignecommande=a;
    DELETE LigneCommandes2 WHERE idlignecommande=a;
    SELECT COUNT(*) INTO nc FROM LigneCommandes2 WHERE idcommande=idc;
    IF (nc=0) THEN
        SELECT idclient INTO idcL FROM Commandes2 WHERE idcommande=idc;
        DELETE Commandes2 WHERE idcommande=idc;
        SELECT COUNT(*) INTO ncL FROM Commandes2 WHERE idclient=idcL;
        IF (ncL=0) THEN DELETE Clients2 WHERE idclient=idcL; END IF;
    END IF;
    SELECT COUNT(*) INTO nc FROM LigneCommandes2 WHERE idproduit=idp;
    IF (nc=0) THEN DELETE Produits2 WHERE idproduit=idp; END IF;
    log_sync('DELETE', 'LIGNECOMMANDES2', v_id, 'OK');
EXCEPTION
    WHEN OTHERS THEN
        log_sync('DELETE', 'LIGNECOMMANDES2', v_id, 'ERREUR', SQLERRM);
        RAISE;
END;
/

CREATE OR REPLACE PROCEDURE UPDATEligne(
    a LigneCommandes2.idlignecommande%TYPE,
    b LigneCommandes2.idproduit%TYPE,
    c LigneCommandes2.quantite%TYPE,
    d LigneCommandes2.remise%TYPE
) IS
    n INTEGER; x INTEGER;
    Rp Produits2%ROWTYPE;
    v_id NUMBER;
BEGIN
    v_id := a;
    SELECT idproduit INTO x FROM LigneCommandes2 WHERE idlignecommande=a;
    SELECT COUNT(*) INTO n FROM Produits2 WHERE idproduit=b;
    IF (n=0) THEN
        SELECT * INTO Rp FROM Produits@central_link WHERE idproduit=b;
        INSERT INTO Produits2 VALUES Rp;
    END IF;
    UPDATE LigneCommandes2 SET idproduit=b, quantite=c, remise=d
    WHERE idlignecommande=a;
    SELECT COUNT(*) INTO n FROM LigneCommandes2 WHERE idproduit=x;
    IF (n=0) THEN DELETE Produits2 WHERE idproduit=x; END IF;
    log_sync('UPDATE', 'LIGNECOMMANDES2', v_id, 'OK');
EXCEPTION
    WHEN OTHERS THEN
        log_sync('UPDATE', 'LIGNECOMMANDES2', v_id, 'ERREUR', SQLERRM);
        RAISE;
END;
/
