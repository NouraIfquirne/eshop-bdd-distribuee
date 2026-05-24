-- ============================================================
-- ESHOP BDD DISTRIBUEE - FRAGMENTS SITE2 SCENARIO 1
-- Connexion : EShop@localhost:1524/XEPDB1
-- Critere   : idcateg=35 AND quantite>50
-- Prerequis : DB Link central_link deja cree
-- ============================================================

CREATE TABLE Produits2 AS
SELECT DISTINCT p.*
FROM Produits@central_link p, LigneCommandes@central_link lc
WHERE p.idproduit = lc.idproduit
AND p.idcateg = 35
AND lc.quantite > 50;

CREATE TABLE LigneCommandes2 AS
SELECT * FROM LigneCommandes@central_link
WHERE idproduit IN (SELECT idproduit FROM Produits2)
AND quantite > 50;

CREATE TABLE Commandes2 AS
SELECT DISTINCT * FROM Commandes@central_link
WHERE idcommande IN (SELECT idcommande FROM LigneCommandes2);

CREATE TABLE Clients2 AS
SELECT DISTINCT * FROM Clients@central_link
WHERE idclient IN (SELECT idclient FROM Commandes2);

-- Contraintes
ALTER TABLE Clients2        ADD CONSTRAINT pk_cli2 PRIMARY KEY (idclient);
ALTER TABLE Produits2       ADD CONSTRAINT pk_pro2 PRIMARY KEY (idproduit);
ALTER TABLE Commandes2      ADD CONSTRAINT pk_cmd2 PRIMARY KEY (idcommande);
ALTER TABLE LigneCommandes2 ADD CONSTRAINT pk_lc2  PRIMARY KEY (idlignecommande);

ALTER TABLE Commandes2 ADD CONSTRAINT fk_cmd2_cli
    FOREIGN KEY (idclient) REFERENCES Clients2(idclient) ON DELETE CASCADE;

ALTER TABLE LigneCommandes2 ADD CONSTRAINT fk_lc2_cmd
    FOREIGN KEY (idcommande) REFERENCES Commandes2(idcommande) ON DELETE CASCADE;

ALTER TABLE LigneCommandes2 ADD CONSTRAINT fk_lc2_pro
    FOREIGN KEY (idproduit) REFERENCES Produits2(idproduit) ON DELETE CASCADE;

-- Index
CREATE INDEX idx_lc2_cmd  ON LigneCommandes2(idcommande);
CREATE INDEX idx_lc2_prod ON LigneCommandes2(idproduit);
CREATE INDEX idx_cmd2_cli ON Commandes2(idclient);
