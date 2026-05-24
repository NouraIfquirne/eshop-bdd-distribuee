-- ============================================================
-- ESHOP BDD DISTRIBUEE - FRAGMENTS SITE1 SCENARIO 1
-- Connexion : EShop@localhost:1523/XEPDB1
-- Critere   : idcateg=50 AND quantite>100
-- Prerequis : DB Link central_link deja cree
-- ============================================================

CREATE TABLE Produits1 AS
SELECT DISTINCT p.*
FROM Produits@central_link p, LigneCommandes@central_link lc
WHERE p.idproduit = lc.idproduit
AND p.idcateg = 50
AND lc.quantite > 100;

CREATE TABLE LigneCommandes1 AS
SELECT * FROM LigneCommandes@central_link
WHERE idproduit IN (SELECT idproduit FROM Produits1)
AND quantite > 100;

CREATE TABLE Commandes1 AS
SELECT DISTINCT * FROM Commandes@central_link
WHERE idcommande IN (SELECT idcommande FROM LigneCommandes1);

CREATE TABLE Clients1 AS
SELECT DISTINCT * FROM Clients@central_link
WHERE idclient IN (SELECT idclient FROM Commandes1);

-- Contraintes d'integrite
ALTER TABLE Clients1        ADD CONSTRAINT pk_cli1 PRIMARY KEY (idclient);
ALTER TABLE Produits1       ADD CONSTRAINT pk_pro1 PRIMARY KEY (idproduit);
ALTER TABLE Commandes1      ADD CONSTRAINT pk_cmd1 PRIMARY KEY (idcommande);
ALTER TABLE LigneCommandes1 ADD CONSTRAINT pk_lc1  PRIMARY KEY (idlignecommande);

ALTER TABLE Commandes1 ADD CONSTRAINT fk_cmd1_cli
    FOREIGN KEY (idclient) REFERENCES Clients1(idclient) ON DELETE CASCADE;

ALTER TABLE LigneCommandes1 ADD CONSTRAINT fk_lc1_cmd
    FOREIGN KEY (idcommande) REFERENCES Commandes1(idcommande) ON DELETE CASCADE;

ALTER TABLE LigneCommandes1 ADD CONSTRAINT fk_lc1_pro
    FOREIGN KEY (idproduit) REFERENCES Produits1(idproduit) ON DELETE CASCADE;

-- Index sur les fragments
CREATE INDEX idx_lc1_cmd  ON LigneCommandes1(idcommande);
CREATE INDEX idx_lc1_prod ON LigneCommandes1(idproduit);
CREATE INDEX idx_cmd1_cli ON Commandes1(idclient);

-- Verification
-- SELECT 'Produits1', COUNT(*) FROM Produits1 UNION ALL
-- SELECT 'LigneCommandes1', COUNT(*) FROM LigneCommandes1 UNION ALL
-- SELECT 'Commandes1', COUNT(*) FROM Commandes1 UNION ALL
-- SELECT 'Clients1', COUNT(*) FROM Clients1;
