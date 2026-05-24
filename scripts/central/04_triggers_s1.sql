-- ============================================================
-- ESHOP BDD DISTRIBUEE - TRIGGERS SYNCHRONISATION SCENARIO 1
-- Connexion : EShop@localhost:1522/XEPDB1
-- Criteres : categ=50 qte>100 -> Site1 | categ=35 qte>50 -> Site2
-- ============================================================

CREATE OR REPLACE TRIGGER SYC_INSERT_LIGNE
BEFORE INSERT ON LigneCommandes
FOR EACH ROW
DECLARE
    Cat Categories.idcateg%TYPE;
    NQ  LigneCommandes.quantite%TYPE := :NEW.quantite;
BEGIN
    SELECT idcateg INTO Cat
    FROM Produits WHERE idproduit = :NEW.idproduit;

    IF (Cat=50 AND NQ>100) THEN
        INSERTligne@site1_link(
            :NEW.idlignecommande, :NEW.idcommande,
            :NEW.idproduit, :NEW.quantite, :NEW.remise);
    ELSIF (Cat=35 AND NQ>50) THEN
        INSERTligne@site2_link(
            :NEW.idlignecommande, :NEW.idcommande,
            :NEW.idproduit, :NEW.quantite, :NEW.remise);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER SYC_DELETE_LIGNE
BEFORE DELETE ON LigneCommandes
FOR EACH ROW
DECLARE
    Cat Categories.idcateg%TYPE;
    OQ  LigneCommandes.quantite%TYPE := :OLD.quantite;
BEGIN
    SELECT idcateg INTO Cat
    FROM Produits WHERE idproduit = :OLD.idproduit;

    IF (Cat=50 AND OQ>100) THEN
        DELETEligne@site1_link(:OLD.idlignecommande);
    ELSIF (Cat=35 AND OQ>50) THEN
        DELETEligne@site2_link(:OLD.idlignecommande);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER SYC_UPDATE_LIGNE
BEFORE UPDATE ON LigneCommandes
FOR EACH ROW
DECLARE
    OP   Produits.idproduit%TYPE   := :OLD.idproduit;
    NP   Produits.idproduit%TYPE   := :NEW.idproduit;
    OQ   LigneCommandes.quantite%TYPE := :OLD.quantite;
    NQ   LigneCommandes.quantite%TYPE := :NEW.quantite;
    OCat Produits.idcateg%TYPE;
    NCat Produits.idcateg%TYPE;
BEGIN
    SELECT idcateg INTO OCat FROM Produits WHERE idproduit=OP;
    SELECT idcateg INTO NCat FROM Produits WHERE idproduit=NP;

    IF (OCat=50 AND OQ>100) THEN
        IF (NCat=50 AND NQ>100) THEN
            UPDATEligne@site1_link(:NEW.idlignecommande,
                :NEW.idproduit, :NEW.quantite, :NEW.remise);
        ELSE
            DELETEligne@site1_link(:OLD.idlignecommande);
            IF (NCat=35 AND NQ>50) THEN
                INSERTligne@site2_link(:NEW.idlignecommande, :NEW.idcommande,
                    :NEW.idproduit, :NEW.quantite, :NEW.remise);
            END IF;
        END IF;
    ELSIF (OCat=35 AND OQ>50) THEN
        IF (NCat=35 AND NQ>50) THEN
            UPDATEligne@site2_link(:NEW.idlignecommande,
                :NEW.idproduit, :NEW.quantite, :NEW.remise);
        ELSE
            DELETEligne@site2_link(:OLD.idlignecommande);
            IF (NCat=50 AND NQ>100) THEN
                INSERTligne@site1_link(:NEW.idlignecommande, :NEW.idcommande,
                    :NEW.idproduit, :NEW.quantite, :NEW.remise);
            END IF;
        END IF;
    ELSIF (NCat=50 AND NQ>100) THEN
        INSERTligne@site1_link(:NEW.idlignecommande, :NEW.idcommande,
            :NEW.idproduit, :NEW.quantite, :NEW.remise);
    ELSIF (NCat=35 AND NQ>50) THEN
        INSERTligne@site2_link(:NEW.idlignecommande, :NEW.idcommande,
            :NEW.idproduit, :NEW.quantite, :NEW.remise);
    END IF;
END;
/
