CONNECT mon_user/mon_mdp@XEPDB1
-- 06_create_package.sql
-- Package complet pour la gestion des employés

CREATE OR REPLACE PACKAGE employee_manager AS

    TYPE emp_record IS RECORD (
        emp_id    employees.emp_id%TYPE,
        full_name VARCHAR2(101),
        job_title employees.job_title%TYPE,
        salary    employees.salary%TYPE,
        dept_name departments.dept_name%TYPE
    );

    TYPE emp_table IS TABLE OF emp_record INDEX BY PLS_INTEGER;

    PROCEDURE hire_employee(
        p_first_name VARCHAR2,
        p_last_name  VARCHAR2,
        p_email      VARCHAR2,
        p_job_title  VARCHAR2,
        p_salary     NUMBER,
        p_dept_id    NUMBER,
        p_manager_id NUMBER DEFAULT NULL
    );

    PROCEDURE fire_employee(p_emp_id NUMBER);

    PROCEDURE transfer_employee(p_emp_id NUMBER, p_new_dept_id NUMBER);

    FUNCTION get_employee_details(p_emp_id NUMBER) RETURN emp_record;

    FUNCTION get_dept_statistics(p_dept_id NUMBER) RETURN VARCHAR2;

    PROCEDURE generate_salary_report(p_dept_id NUMBER DEFAULT NULL);

END employee_manager;
/

CREATE OR REPLACE PACKAGE BODY employee_manager AS

    PROCEDURE hire_employee(
        p_first_name VARCHAR2,
        p_last_name  VARCHAR2,
        p_email      VARCHAR2,
        p_job_title  VARCHAR2,
        p_salary     NUMBER,
        p_dept_id    NUMBER,
        p_manager_id NUMBER DEFAULT NULL
    ) AS
        v_new_id    NUMBER;
        v_dept_exists NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_dept_exists FROM departments WHERE dept_id = p_dept_id;
        IF v_dept_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20010, 'Département invalide');
        END IF;

        SELECT seq_emp_id.NEXTVAL INTO v_new_id FROM DUAL;

        INSERT INTO employees (emp_id, first_name, last_name, email, hire_date,
                               job_title, salary, dept_id, manager_id)
        VALUES (v_new_id, p_first_name, p_last_name, p_email, SYSDATE,
                p_job_title, p_salary, p_dept_id, p_manager_id);

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('✅ Employé embauché: ' || p_first_name || ' ' || p_last_name ||
                             ' (ID: ' || v_new_id || ')');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('❌ Email déjà utilisé: ' || p_email);
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('❌ Erreur lors de l''embauche: ' || SQLERRM);
            ROLLBACK;
    END hire_employee;

    PROCEDURE fire_employee(p_emp_id NUMBER) AS
        v_emp_name VARCHAR2(101);
    BEGIN
        SELECT first_name || ' ' || last_name INTO v_emp_name
        FROM   employees WHERE emp_id = p_emp_id;

        DELETE FROM employee_projects WHERE emp_id = p_emp_id;
        DELETE FROM employees          WHERE emp_id = p_emp_id;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('❌ Employé licencié: ' || v_emp_name);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('❌ Employé non trouvé: ' || p_emp_id);
            ROLLBACK;
    END fire_employee;

    PROCEDURE transfer_employee(p_emp_id NUMBER, p_new_dept_id NUMBER) AS
        v_old_dept VARCHAR2(50);
        v_new_dept VARCHAR2(50);
    BEGIN
        SELECT d.dept_name INTO v_old_dept
        FROM   employees e JOIN departments d ON e.dept_id = d.dept_id
        WHERE  e.emp_id = p_emp_id;

        SELECT dept_name INTO v_new_dept FROM departments WHERE dept_id = p_new_dept_id;

        UPDATE employees SET dept_id = p_new_dept_id WHERE emp_id = p_emp_id;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('🔄 Employé ' || p_emp_id ||
                             ' transféré de ' || v_old_dept || ' vers ' || v_new_dept);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('❌ Employé ou département non trouvé');
            ROLLBACK;
    END transfer_employee;

    FUNCTION get_employee_details(p_emp_id NUMBER) RETURN emp_record AS
        v_result emp_record;
    BEGIN
        SELECT e.emp_id,
               e.first_name || ' ' || e.last_name,
               e.job_title,
               e.salary,
               d.dept_name
        INTO   v_result
        FROM   employees e
        LEFT JOIN departments d ON e.dept_id = d.dept_id
        WHERE  e.emp_id = p_emp_id;

        RETURN v_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN NULL;
    END get_employee_details;

    FUNCTION get_dept_statistics(p_dept_id NUMBER) RETURN VARCHAR2 AS
        v_emp_count   NUMBER;
        v_avg_salary  NUMBER;
        v_total_budget NUMBER;
        v_dept_name   VARCHAR2(50);
    BEGIN
        SELECT dept_name INTO v_dept_name FROM departments WHERE dept_id = p_dept_id;

        SELECT COUNT(*), AVG(salary), SUM(salary)
        INTO   v_emp_count, v_avg_salary, v_total_budget
        FROM   employees WHERE dept_id = p_dept_id;

        RETURN 'Département ' || v_dept_name ||
               ' | Employés: '      || v_emp_count ||
               ' | Salaire moyen: ' || TO_CHAR(v_avg_salary,  '999,999.00') ||
               ' | Masse salariale: '|| TO_CHAR(v_total_budget,'999,999.00');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN 'Département non trouvé';
    END get_dept_statistics;

    PROCEDURE generate_salary_report(p_dept_id NUMBER DEFAULT NULL) AS
        CURSOR emp_cursor IS
            SELECT e.first_name, e.last_name, e.job_title, e.salary, d.dept_name
            FROM   employees e JOIN departments d ON e.dept_id = d.dept_id
            WHERE  p_dept_id IS NULL OR e.dept_id = p_dept_id
            ORDER BY d.dept_name, e.salary DESC;
    BEGIN
        DBMS_OUTPUT.PUT_LINE(RPAD('=', 71, '='));
        DBMS_OUTPUT.PUT_LINE('RAPPORT DES SALAIRES - ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI'));
        DBMS_OUTPUT.PUT_LINE(RPAD('=', 71, '='));

        FOR emp IN emp_cursor LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(emp.dept_name, 20) ||
                RPAD(emp.first_name || ' ' || emp.last_name, 25) ||
                RPAD(emp.job_title, 20) ||
                TO_CHAR(emp.salary, '999,999.00')
            );
        END LOOP;

        DBMS_OUTPUT.PUT_LINE(RPAD('=', 71, '='));
    END generate_salary_report;

END employee_manager;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('✅ Package employee_manager créé avec succès');
END;
/
