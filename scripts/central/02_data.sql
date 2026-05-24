-- ============================================================
-- ESHOP BDD DISTRIBUEE - DONNEES INITIALES
-- Connexion : EShop@localhost:1522/XEPDB1
-- ============================================================

-- CATEGORIES
INSERT INTO Categories VALUES (10, 'Informatique');
INSERT INTO Categories VALUES (20, 'Bureautique');
INSERT INTO Categories VALUES (35, 'Electronique');
INSERT INTO Categories VALUES (50, 'Telephonie');
INSERT INTO Categories VALUES (60, 'Accessoires');

-- PRODUITS
INSERT INTO Produits VALUES (1,  50, 'iPhone 14',         999.99);
INSERT INTO Produits VALUES (2,  50, 'Samsung Galaxy S23', 899.99);
INSERT INTO Produits VALUES (3,  50, 'Xiaomi 12',          699.99);
INSERT INTO Produits VALUES (4,  35, 'TV Samsung 55"',     799.99);
INSERT INTO Produits VALUES (5,  35, 'TV LG 65"',          999.99);
INSERT INTO Produits VALUES (6,  35, 'Ecran PC 27"',       349.99);
INSERT INTO Produits VALUES (7,  10, 'Laptop Dell',       1199.99);
INSERT INTO Produits VALUES (8,  10, 'Laptop HP',          999.99);
INSERT INTO Produits VALUES (9,  20, 'Imprimante Canon',   299.99);
INSERT INTO Produits VALUES (10, 60, 'Souris Logitech',     49.99);

-- CLIENTS
INSERT INTO Clients VALUES (1, 'CLI001', 'TechCorp',   'Casablanca', 'Maroc');
INSERT INTO Clients VALUES (2, 'CLI002', 'InfoSoft',   'Rabat',      'Maroc');
INSERT INTO Clients VALUES (3, 'CLI003', 'DigiWorld',  'Paris',      'France');
INSERT INTO Clients VALUES (4, 'CLI004', 'MegaStore',  'Lyon',       'France');
INSERT INTO Clients VALUES (5, 'CLI005', 'TechMarket', 'Tunis',      'Tunisie');

-- EMPLOYES
INSERT INTO Employes VALUES (1, 'Alami',   'Youssef', 'Commercial');
INSERT INTO Employes VALUES (2, 'Bennani', 'Sara',    'Commercial');
INSERT INTO Employes VALUES (3, 'Dupont',  'Pierre',  'Manager');

-- COMMANDES
INSERT INTO Commandes VALUES (1,  1, 1, TO_DATE('2026-01-10','YYYY-MM-DD'));
INSERT INTO Commandes VALUES (2,  1, 2, TO_DATE('2026-02-15','YYYY-MM-DD'));
INSERT INTO Commandes VALUES (3,  2, 1, TO_DATE('2026-01-20','YYYY-MM-DD'));
INSERT INTO Commandes VALUES (4,  2, 3, TO_DATE('2026-03-05','YYYY-MM-DD'));
INSERT INTO Commandes VALUES (5,  3, 2, TO_DATE('2026-01-25','YYYY-MM-DD'));
INSERT INTO Commandes VALUES (6,  3, 1, TO_DATE('2026-02-28','YYYY-MM-DD'));
INSERT INTO Commandes VALUES (7,  4, 3, TO_DATE('2026-03-15','YYYY-MM-DD'));
INSERT INTO Commandes VALUES (8,  5, 2, TO_DATE('2026-04-01','YYYY-MM-DD'));
INSERT INTO Commandes VALUES (9,  1, 1, TO_DATE('2026-04-10','YYYY-MM-DD'));
INSERT INTO Commandes VALUES (10, 5, 3, TO_DATE('2026-05-01','YYYY-MM-DD'));

-- LIGNECOMMANDES
-- Scenario 1 Site1 : idcateg=50 AND quantite>100
INSERT INTO LigneCommandes VALUES (1,  1,  1, 150, 5);
INSERT INTO LigneCommandes VALUES (2,  1,  2, 120, 3);
INSERT INTO LigneCommandes VALUES (3,  2,  1, 200, 10);
INSERT INTO LigneCommandes VALUES (4,  3,  3, 110, 0);
INSERT INTO LigneCommandes VALUES (5,  9,  2, 130, 7);
-- Scenario 1 Site2 : idcateg=35 AND quantite>50
INSERT INTO LigneCommandes VALUES (6,  4,  4, 80,  5);
INSERT INTO LigneCommandes VALUES (7,  5,  5, 60,  0);
INSERT INTO LigneCommandes VALUES (8,  6,  6, 75,  3);
INSERT INTO LigneCommandes VALUES (9,  7,  4, 90,  8);
INSERT INTO LigneCommandes VALUES (10, 10, 5, 55,  0);
-- Autres lignes
INSERT INTO LigneCommandes VALUES (11, 2,  7, 5,   0);
INSERT INTO LigneCommandes VALUES (12, 3,  8, 3,   2);
INSERT INTO LigneCommandes VALUES (13, 4,  9, 10,  0);
INSERT INTO LigneCommandes VALUES (14, 8,  10,20,  0);
INSERT INTO LigneCommandes VALUES (15, 6,  7, 2,   5);

COMMIT;
