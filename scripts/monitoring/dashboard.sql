-- ============================================================
-- ESHOP BDD DISTRIBUEE - MONITORING AVANCE
-- Connexion : system@localhost:1522/XEPDB1
-- ============================================================

-- 1. SESSIONS ACTIVES
SELECT s.sid, s.username, s.status,
       TO_CHAR(s.logon_time,'DD/MM HH24:MI:SS') AS connexion,
       s.program
FROM v$session s
WHERE s.username IS NOT NULL
ORDER BY s.logon_time DESC;

-- 2. REQUETES LES PLUS LENTES (Top 10 EShop)
SELECT ROUND(elapsed_time/1000000, 2) AS elapsed_sec,
       executions,
       ROUND(elapsed_time/GREATEST(executions,1)/1000000, 4) AS avg_sec,
       SUBSTR(sql_text, 1, 120) AS sql_text
FROM v$sql
WHERE elapsed_time > 0
AND executions > 0
AND parsing_schema_name = 'ESHOP'
ORDER BY elapsed_time DESC
FETCH FIRST 10 ROWS ONLY;

-- 3. CONSOMMATION MEMOIRE SGA
SELECT name, ROUND(value/1024/1024, 2) AS valeur_mb
FROM v$sga
UNION ALL
SELECT 'PGA_USED', ROUND(value/1024/1024, 2)
FROM v$pgastat WHERE name = 'total PGA inuse';

-- 4. VERROUS ET BLOCAGES
SELECT l.sid, s.username, s.status, o.object_name, l.type,
       DECODE(l.lmode,
           0,'None', 1,'Null', 2,'Row-S',
           3,'Row-X', 4,'Share', 5,'S/Row-X', 6,'Exclusive') AS lock_mode
FROM v$lock l
JOIN v$session s ON l.sid = s.sid
JOIN dba_objects o ON l.id1 = o.object_id
WHERE l.type IN ('TM','TX') AND s.username IS NOT NULL
ORDER BY l.sid;

-- 5. TAILLE TABLESPACES
SELECT tablespace_name,
       ROUND(used_space * 8192/1024/1024, 2) AS used_mb,
       ROUND(tablespace_size * 8192/1024/1024, 2) AS total_mb,
       ROUND(used_percent, 2) AS pct_used
FROM dba_tablespace_usage_metrics
ORDER BY used_percent DESC;

-- 6. STATISTIQUES OPTIMIZER
-- EXEC DBMS_STATS.GATHER_SCHEMA_STATS('ESHOP');
SELECT table_name, num_rows, last_analyzed
FROM user_tables
ORDER BY last_analyzed DESC;

-- ============================================================
-- PROCEDURE DASHBOARD (a executer sur connexion system)
-- ============================================================
CREATE OR REPLACE PROCEDURE monitoring_dashboard AUTHID CURRENT_USER IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('        MONITORING ESHOP DISTRIBUE          ');
    DBMS_OUTPUT.PUT_LINE('  ' || TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('============================================');

    DBMS_OUTPUT.PUT_LINE('--- SESSIONS ACTIVES ---');
    FOR rec IN (
        SELECT username, status,
               TO_CHAR(logon_time,'DD/MM HH24:MI:SS') AS connexion
        FROM v$session WHERE username IS NOT NULL ORDER BY logon_time DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(rec.username,15) || ' | ' ||
            RPAD(rec.status,8)   || ' | ' || rec.connexion);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('--- TABLESPACES ---');
    FOR rec IN (
        SELECT tablespace_name,
               ROUND(used_space*8192/1024/1024,2) AS used_mb,
               ROUND(used_percent,2) AS pct
        FROM dba_tablespace_usage_metrics ORDER BY used_percent DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(rec.tablespace_name,12) || ' | ' ||
            RPAD(TO_CHAR(rec.used_mb) || ' MB',12) || ' | ' ||
            TO_CHAR(rec.pct) || '%');
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('--- TOP 5 REQUETES LENTES (ESHOP) ---');
    FOR rec IN (
        SELECT ROUND(elapsed_time/1000000,2) AS sec,
               executions, SUBSTR(sql_text,1,60) AS sql_text
        FROM v$sql
        WHERE elapsed_time>0 AND executions>0
        AND parsing_schema_name='ESHOP'
        ORDER BY elapsed_time DESC FETCH FIRST 5 ROWS ONLY
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'T:' || RPAD(TO_CHAR(rec.sec)||'s',8) ||
            'Ex:' || RPAD(TO_CHAR(rec.executions),5) || rec.sql_text);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('--- MEMOIRE SGA ---');
    FOR rec IN (SELECT name, ROUND(value/1024/1024,2) AS mb FROM v$sga) LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(rec.name,25) || ' : ' || TO_CHAR(rec.mb) || ' MB');
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('============================================');
END;
/
