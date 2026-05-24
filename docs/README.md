\# EShop — Bases de Données Distribuées Oracle XE + Docker



\## Description

Projet de BDD Distribuées implémentant une fragmentation horizontale sur 3 conteneurs Oracle XE interconnectés via Docker.



\## Architecture

\- \*\*Central\*\* (port 1522) : BDD globale EShop

\- \*\*Site1\*\* (port 1523) : Fragments catégorie 50 (qte>100) / volume >= 100

\- \*\*Site2\*\* (port 1524) : Fragments catégorie 35 (qte>50) / volume < 100



\## Technologies

\- Oracle XE 21c (gvenzl/oracle-xe:21-slim-faststart)

\- Docker + Docker Compose

\- PL/SQL (Procédures, Triggers, Database Links)

\- SQL Developer



\## Fonctionnalités

\- Fragmentation horizontale (2 scénarios)

\- Database Links bidirectionnels

\- Procédures PL/SQL avec gestion d'erreurs

\- Triggers de synchronisation automatique

\- Logs de synchronisation (PRAGMA AUTONOMOUS\_TRANSACTION)

\- Vérification de cohérence Central <-> Sites

\- Vues matérialisées

\- Index fonctionnels optimisés

\- Dashboard de monitoring

\- Sécurité (rôles, utilisateurs dédiés, audit)



\## Démarrage rapide

```bash

docker-compose up -d

```



\## Structure





scripts/

├── central/     # Schéma, données, triggers, DB Links

├── site1/       # Fragments et procédures Site1

├── site2/       # Fragments et procédures Site2

└── monitoring/  # Dashboard et requêtes de monitoring

docs/

└── README.md





\## Scénario 1 — Fragmentation par catégorie



| Site | Critère |

|------|---------|

| Site1 | idcateg=50 AND quantite>100 |

| Site2 | idcateg=35 AND quantite>50 |



\## Scénario 2 — Fragmentation par volume



| Site | Critère |

|------|---------|

| Site1 | quantite >= 100 (Grossistes) |

| Site2 | quantite < 100 (Détail) |

