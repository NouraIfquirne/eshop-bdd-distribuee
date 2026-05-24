-- ============================================================
-- ESHOP BDD DISTRIBUEE - SCHEMA CENTRAL
-- Connexion : EShop@localhost:1522/XEPDB1
-- ============================================================

-- Creation du user EShop (a executer en tant que system/admin)
-- CREATE USER EShop IDENTIFIED BY EShop123;
-- GRANT CONNECT, RESOURCE, UNLIMITED TABLESPACE TO EShop;

CREATE TABLE Categories (
    idcateg     NUMBER PRIMARY KEY,
    nomcateg    VARCHAR2(50) NOT NULL
);

CREATE TABLE Produits (
    idproduit       NUMBER PRIMARY KEY,
    idcateg         NUMBER NOT NULL,
    designation     VARCHAR2(100) NOT NULL,
    prixunitaire    NUMBER(10,2) NOT NULL,
    CONSTRAINT fk_prod_categ FOREIGN KEY (idcateg) REFERENCES Categories(idcateg)
);

CREATE TABLE Clients (
    idclient        NUMBER PRIMARY KEY,
    codeclient      VARCHAR2(20) NOT NULL,
    societe         VARCHAR2(100),
    ville           VARCHAR2(50),
    pays            VARCHAR2(50)
);

CREATE TABLE Employes (
    idemploye       NUMBER PRIMARY KEY,
    nom             VARCHAR2(50) NOT NULL,
    prenom          VARCHAR2(50),
    fonction        VARCHAR2(50)
);

CREATE TABLE Commandes (
    idcommande      NUMBER PRIMARY KEY,
    idclient        NUMBER NOT NULL,
    idemploye       NUMBER,
    datecommande    DATE NOT NULL,
    CONSTRAINT fk_cmd_client  FOREIGN KEY (idclient)  REFERENCES Clients(idclient),
    CONSTRAINT fk_cmd_employe FOREIGN KEY (idemploye) REFERENCES Employes(idemploye)
);

CREATE TABLE LigneCommandes (
    idlignecommande NUMBER PRIMARY KEY,
    idcommande      NUMBER NOT NULL,
    idproduit       NUMBER NOT NULL,
    quantite        NUMBER NOT NULL,
    remise          NUMBER(5,2) DEFAULT 0,
    CONSTRAINT fk_lc_commande FOREIGN KEY (idcommande) REFERENCES Commandes(idcommande),
    CONSTRAINT fk_lc_produit  FOREIGN KEY (idproduit)  REFERENCES Produits(idproduit)
);
