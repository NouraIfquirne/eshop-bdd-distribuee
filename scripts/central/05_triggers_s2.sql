-- ============================================================
-- ESHOP BDD DISTRIBUEE - TRIGGERS SYNCHRONISATION SCENARIO 2
-- Connexion : EShop@localhost:1522/XEPDB1
-- Criteres : quantite>=100 -> Site1 | quantite<100 -> Site2
-- ============================================================

CREATE OR REPLACE TRIGGER SYC_INSERT_LIGNE_S2
BEFORE INSERT ON LigneCommandes
FOR EACH ROW
DECLARE
    NQ LigneCommandes.quantite%TYPE := :NEW.quantite;
BEGIN
    IF (NQ >= 100) THEN
        INSERTligne@site1_s2_link(
            :NEW.idlignecommande, :NEW.idcommande,
            :NEW.idproduit, :NEW.quantite, :NEW.remise);
    ELSE
        INSERTligne@site2_s2_link(
            :NEW.idlignecommande, :NEW.idcommande,
            :NEW.idproduit, :NEW.quantite, :NEW.remise);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER SYC_DELETE_LIGNE_S2
BEFORE DELETE ON LigneCommandes
FOR EACH ROW
DECLARE
    OQ LigneCommandes.quantite%TYPE := :OLD.quantite;
BEGIN
    IF (OQ >= 100) THEN
        DELETEligne@site1_s2_link(:OLD.idlignecommande);
    ELSE
        DELETEligne@site2_s2_link(:OLD.idlignecommande);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER SYC_UPDATE_LIGNE_S2
BEFORE UPDATE ON LigneCommandes
FOR EACH ROW
DECLARE
    OQ LigneCommandes.quantite%TYPE := :OLD.quantite;
    NQ LigneCommandes.quantite%TYPE := :NEW.quantite;
BEGIN
    IF (OQ >= 100) THEN
        IF (NQ >= 100) THEN
            UPDATEligne@site1_s2_link(:NEW.idlignecommande,
                :NEW.idproduit, :NEW.quantite, :NEW.remise);
        ELSE
            DELETEligne@site1_s2_link(:OLD.idlignecommande);
            INSERTligne@site2_s2_link(:NEW.idlignecommande, :NEW.idcommande,
                :NEW.idproduit, :NEW.quantite, :NEW.remise);
        END IF;
    ELSE
        IF (NQ < 100) THEN
            UPDATEligne@site2_s2_link(:NEW.idlignecommande,
                :NEW.idproduit, :NEW.quantite, :NEW.remise);
        ELSE
            DELETEligne@site2_s2_link(:OLD.idlignecommande);
            INSERTligne@site1_s2_link(:NEW.idlignecommande, :NEW.idcommande,
                :NEW.idproduit, :NEW.quantite, :NEW.remise);
        END IF;
    END IF;
END;
/
