-- ============================================================
-- ESHOP BDD DISTRIBUEE - INDEX ET VUES MATERIALISEES
-- Connexion : EShop@localhost:1522/XEPDB1
-- ============================================================

-- INDEX FONCTIONNEL sur l'annee (elimine le FULL SCAN)
CREATE INDEX idx_cmd_year   ON Commandes(EXTRACT(YEAR FROM datecommande));

-- INDEX sur datecommande
CREATE INDEX idx_cmd_date   ON Commandes(datecommande);

-- INDEX sur idclient dans Commandes (jointures)
CREATE INDEX idx_cmd_client ON Commandes(idclient);

-- ============================================================
-- VUES MATERIALISEES
-- Prerequis : GRANT CREATE MATERIALIZED VIEW TO EShop; (system)
-- ============================================================

CREATE MATERIALIZED VIEW mv_ca_par_client
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT c.idclient, c.societe,
       COUNT(DISTINCT cmd.idcommande) AS nb_commandes,
       SUM(p.prixunitaire * lc.quantite * (1 - lc.remise/100)) AS ca_total
FROM Clients c
JOIN Commandes cmd ON c.idclient = cmd.idclient
JOIN LigneCommandes lc ON cmd.idcommande = lc.idcommande
JOIN Produits p ON lc.idproduit = p.idproduit
GROUP BY c.idclient, c.societe;

CREATE MATERIALIZED VIEW mv_ca_par_categorie
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT cat.nomcateg,
       COUNT(DISTINCT lc.idcommande) AS nb_commandes,
       SUM(lc.quantite) AS total_qte,
       SUM(p.prixunitaire * lc.quantite * (1 - lc.remise/100)) AS ca_total
FROM Categories cat
JOIN Produits p ON cat.idcateg = p.idcateg
JOIN LigneCommandes lc ON p.idproduit = lc.idproduit
GROUP BY cat.nomcateg;

-- Rafraichir les vues
-- EXEC DBMS_MVIEW.REFRESH('MV_CA_PAR_CLIENT');
-- EXEC DBMS_MVIEW.REFRESH('MV_CA_PAR_CATEGORIE');

-- Verifier les vues
-- SELECT mview_name, last_refresh_date, refresh_mode FROM user_mviews;
