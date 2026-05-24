CONNECT mon_user/mon_mdp@XEPDB1
-- 05_create_functions.sql
-- Fonctions stockées

-- Fonction pour calculer le salaire annuel
CREATE OR REPLACE FUNCTION get_annual_salary(p_emp_id IN NUMBER)
RETURN NUMBER AS
    v_monthly_salary employees.salary%TYPE;
    v_commission     employees.commission_pct%TYPE;
BEGIN
    SELECT salary, NVL(commission_pct, 0)
    INTO   v_monthly_salary, v_commission
    FROM   employees
    WHERE  emp_id = p_emp_id;

    RETURN v_monthly_salary * 12 * (1 + v_commission);

EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
END get_annual_salary;
/

-- Fonction pour obtenir le nombre d'employés par département
CREATE OR REPLACE FUNCTION get_dept_employee_count(p_dept_id IN NUMBER)
RETURN NUMBER AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM employees WHERE dept_id = p_dept_id;
    RETURN v_count;
END get_dept_employee_count;
/

-- Fonction pour calculer le coût estimé d'un projet
CREATE OR REPLACE FUNCTION get_project_cost(p_project_id IN NUMBER)
RETURN NUMBER AS
    v_total_cost NUMBER;
BEGIN
    SELECT SUM(e.salary * ep.hours_allocated / 160)
    INTO   v_total_cost
    FROM   employee_projects ep
    JOIN   employees e ON ep.emp_id = e.emp_id
    WHERE  ep.project_id = p_project_id;

    RETURN NVL(v_total_cost, 0);
END get_project_cost;
/

-- Package avec curseur pour les rapports de département
CREATE OR REPLACE PACKAGE dept_report AS
    TYPE dept_cursor IS REF CURSOR;
    FUNCTION get_dept_details(p_dept_id NUMBER) RETURN dept_cursor;
END dept_report;
/

CREATE OR REPLACE PACKAGE BODY dept_report AS
    FUNCTION get_dept_details(p_dept_id NUMBER) RETURN dept_cursor AS
        v_cursor dept_cursor;
    BEGIN
        OPEN v_cursor FOR
            SELECT e.emp_id,
                   e.first_name,
                   e.last_name,
                   e.job_title,
                   e.salary,
                   NVL((SELECT SUM(hours_allocated)
                        FROM   employee_projects
                        WHERE  emp_id = e.emp_id), 0) AS total_hours
            FROM   employees e
            WHERE  e.dept_id = p_dept_id;
        RETURN v_cursor;
    END get_dept_details;
END dept_report;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('✅ Fonctions créées avec succès');
END;
/
