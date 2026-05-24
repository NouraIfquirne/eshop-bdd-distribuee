# EShop — Bases de Données Distribuées Oracle XE + Docker

## Description
Projet de BDD Distribuées implémentant une fragmentation horizontale sur 3 conteneurs Oracle XE interconnectés via Docker.

## Architecture
| Conteneur | Port | Rôle |
|---|---|---|
| oracle-plsql (Central) | 1522 | BDD globale EShop |
| oracle-site1 | 1523 | Fragments Site1 |
| oracle-site2 | 1524 | Fragments Site2 |

## Technologies
- Oracle XE 21c (`gvenzl/oracle-xe:21-slim-faststart`)
- Docker + Docker Compose
- PL/SQL (Procédures, Triggers, Database Links)
- SQL Developer

## Fonctionnalités
- Fragmentation horizontale (2 scénarios)
- Database Links bidirectionnels (Central ↔ Sites)
- Procédures PL/SQL avec gestion d'erreurs complète
- Triggers de synchronisation automatique
- Logs de synchronisation (PRAGMA AUTONOMOUS_TRANSACTION)
- Vérification de cohérence Central ↔ Sites
- Vues matérialisées (CA par client, CA par catégorie)
- Index fonctionnels optimisés
- Dashboard de monitoring (sessions, mémoire, requêtes lentes)
- Sécurité (rôles, utilisateurs dédiés, audit SQL)

## Démarrage rapide
```bash
docker-compose up -d
```

## Structure des scripts
```
scripts/
├── central/
│   ├── 01_schema.sql              # Tables et contraintes
│   ├── 02_data.sql                # Données initiales
│   ├── 03_dblinks.sql             # Database Links
│   ├── 04_triggers_s1.sql         # Triggers Scenario 1
│   ├── 05_triggers_s2.sql         # Triggers Scenario 2
│   ├── 06_indexes_mviews.sql      # Index + Vues matérialisées
│   ├── 07_procedures_avancees.sql # Procedures stats/coherence/demo
│   └── 08_securite.sql            # Roles, users, audit
├── site1/
│   ├── 01_fragments_s1.sql        # Fragments Scenario 1
│   ├── 02_procedures_s1.sql       # Procedures + logs Scenario 1
│   ├── 03_fragments_s2.sql        # Fragments Scenario 2
│   └── 04_procedures_s2.sql       # Procedures + logs Scenario 2
├── site2/
│   ├── 01_fragments_s1.sql        # Fragments Scenario 1
│   ├── 02_procedures_s1.sql       # Procedures + logs Scenario 1
│   ├── 03_fragments_s2.sql        # Fragments Scenario 2
│   └── 04_procedures_s2.sql       # Procedures + logs Scenario 2
└── monitoring/
    └── dashboard.sql              # Dashboard monitoring complet
```

## Scénario 1 — Fragmentation par catégorie
| Site | Critère | Résultat |
|---|---|---|
| Site1 | idcateg=50 AND quantite>100 | 5 lignes, 3 produits |
| Site2 | idcateg=35 AND quantite>50 | 5 lignes, 3 produits |

## Scénario 2 — Fragmentation par volume
| Site | Critère | Résultat |
|---|---|---|
| Site1 | quantite >= 100 (Grossistes) | 5 lignes |
| Site2 | quantite < 100 (Détail) | 10 lignes |

## Procédures disponibles
```sql
-- Statistiques des 3 sites
EXEC get_stats_site;

-- CA par site
EXEC get_ca_par_site;

-- Top N produits
EXEC get_top_produits(5);

-- Verification coherence
EXEC check_all_sites;

-- Demonstration complete
EXEC demo_full;

-- Monitoring
EXEC monitoring_dashboard;
```

## Connexions SQL Developer
| Nom | User | Port | Service |
|---|---|---|---|
| Central | system | 1522 | XEPDB1 |
| EShop | EShop | 1522 | XEPDB1 |
| EShop_Site1 | EShop | 1523 | XEPDB1 |
| EShop_Site2 | EShop | 1524 | XEPDB1 |
| EShop2_Site1 | EShop2 | 1523 | XEPDB1 |
| EShop2_Site2 | EShop2 | 1524 | XEPDB1 |
