CONNECT mon_user/mon_mdp@XEPDB1
-- 03_insert_data.sql
-- Insertion des données de test

-- Insertion des départements
INSERT INTO departments (dept_id, dept_name, location, budget) VALUES (seq_dept_id.NEXTVAL, 'Informatique',        'Casablanca', 500000);
INSERT INTO departments (dept_id, dept_name, location, budget) VALUES (seq_dept_id.NEXTVAL, 'Ressources Humaines', 'Rabat',      200000);
INSERT INTO departments (dept_id, dept_name, location, budget) VALUES (seq_dept_id.NEXTVAL, 'Marketing',           'Casablanca', 300000);
INSERT INTO departments (dept_id, dept_name, location, budget) VALUES (seq_dept_id.NEXTVAL, 'Finance',             'Tanger',     400000);
INSERT INTO departments (dept_id, dept_name, location, budget) VALUES (seq_dept_id.NEXTVAL, 'Commercial',          'Marrakech',  350000);

-- Insertion des employés
INSERT INTO employees (emp_id, first_name, last_name, email, phone, hire_date, job_title, salary, dept_id)
VALUES (seq_emp_id.NEXTVAL, 'Ahmed',   'Benali',    'ahmed.benali@company.com',    '0612345678', DATE '2020-01-15', 'Directeur Informatique', 80000, 10);
INSERT INTO employees (emp_id, first_name, last_name, email, phone, hire_date, job_title, salary, dept_id)
VALUES (seq_emp_id.NEXTVAL, 'Fatima',  'Zahra',     'fatima.zahra@company.com',    '0623456789', DATE '2020-03-20', 'Développeur Senior',     60000, 10);
INSERT INTO employees (emp_id, first_name, last_name, email, phone, hire_date, job_title, salary, dept_id)
VALUES (seq_emp_id.NEXTVAL, 'Mohamed', 'El Amrani', 'mohamed.elamrani@company.com','0634567890', DATE '2021-06-10', 'Développeur',            45000, 10);
INSERT INTO employees (emp_id, first_name, last_name, email, phone, hire_date, job_title, salary, dept_id)
VALUES (seq_emp_id.NEXTVAL, 'Khadija', 'Mansouri',  'khadija.mansouri@company.com','0645678901', DATE '2021-01-05', 'Responsable RH',         55000, 11);
INSERT INTO employees (emp_id, first_name, last_name, email, phone, hire_date, job_title, salary, dept_id)
VALUES (seq_emp_id.NEXTVAL, 'Youssef', 'Karimi',    'youssef.karimi@company.com',  '0656789012', DATE '2022-02-15', 'Chargé RH',              38000, 11);
INSERT INTO employees (emp_id, first_name, last_name, email, phone, hire_date, job_title, salary, dept_id)
VALUES (seq_emp_id.NEXTVAL, 'Nadia',   'Fathi',     'nadia.fathi@company.com',     '0667890123', DATE '2020-09-01', 'Chef Marketing',         58000, 12);
INSERT INTO employees (emp_id, first_name, last_name, email, phone, hire_date, job_title, salary, dept_id)
VALUES (seq_emp_id.NEXTVAL, 'Hassan',  'Rami',      'hassan.rami@company.com',     '0678901234', DATE '2021-11-20', 'Analyste Marketing',     42000, 12);
INSERT INTO employees (emp_id, first_name, last_name, email, phone, hire_date, job_title, salary, dept_id)
VALUES (seq_emp_id.NEXTVAL, 'Samira',  'Bensaid',   'samira.bensaid@company.com',  '0689012345', DATE '2020-05-10', 'Contrôleur Financier',   62000, 13);
INSERT INTO employees (emp_id, first_name, last_name, email, phone, hire_date, job_title, salary, dept_id)
VALUES (seq_emp_id.NEXTVAL, 'Karim',   'Idrissi',   'karim.idrissi@company.com',   '0690123456', DATE '2022-07-01', 'Commercial',             40000, 14);
INSERT INTO employees (emp_id, first_name, last_name, email, phone, hire_date, job_title, salary, dept_id)
VALUES (seq_emp_id.NEXTVAL, 'Leila',   'Cherkaoui', 'leila.cherkaoui@company.com', '0691234567', DATE '2021-08-15', 'Commercial Senior',      48000, 14);

-- Mise à jour des managers
UPDATE employees SET manager_id = 100 WHERE emp_id IN (101, 102);
UPDATE employees SET manager_id = 103 WHERE emp_id IN (104, 105);
UPDATE employees SET manager_id = 105 WHERE emp_id IN (106);
UPDATE employees SET manager_id = 107 WHERE emp_id IN (108, 109);

-- Insertion des projets
INSERT INTO projects (project_id, project_name, start_date, end_date, budget, status)
VALUES (seq_project_id.NEXTVAL, 'Migration Cloud',        DATE '2024-01-01', DATE '2024-12-31', 250000, 'ACTIVE');
INSERT INTO projects (project_id, project_name, start_date, end_date, budget, status)
VALUES (seq_project_id.NEXTVAL, 'Application Mobile',     DATE '2024-02-01', DATE '2024-08-31', 150000, 'ACTIVE');
INSERT INTO projects (project_id, project_name, start_date, end_date, budget, status)
VALUES (seq_project_id.NEXTVAL, 'Formation RH',           DATE '2024-03-01', DATE '2024-06-30',  50000, 'PLANNED');
INSERT INTO projects (project_id, project_name, start_date, end_date, budget, status)
VALUES (seq_project_id.NEXTVAL, 'Campagne Marketing 2024',DATE '2024-01-15', DATE '2024-07-15',  80000, 'ACTIVE');
INSERT INTO projects (project_id, project_name, start_date, end_date, budget, status)
VALUES (seq_project_id.NEXTVAL, 'Audit Financier',        DATE '2024-04-01', DATE '2024-09-30', 100000, 'PLANNED');

-- Affectation des employés aux projets
INSERT INTO employee_projects (emp_id, project_id, role, hours_allocated) VALUES (100, 1000, 'Chef de projet',             160);
INSERT INTO employee_projects (emp_id, project_id, role, hours_allocated) VALUES (101, 1000, 'Développeur',                 140);
INSERT INTO employee_projects (emp_id, project_id, role, hours_allocated) VALUES (102, 1000, 'Développeur',                 120);
INSERT INTO employee_projects (emp_id, project_id, role, hours_allocated) VALUES (100, 1001, 'Architecte',                   80);
INSERT INTO employee_projects (emp_id, project_id, role, hours_allocated) VALUES (101, 1001, 'Développeur Mobile',           160);
INSERT INTO employee_projects (emp_id, project_id, role, hours_allocated) VALUES (103, 1002, 'Responsable Formation',        100);
INSERT INTO employee_projects (emp_id, project_id, role, hours_allocated) VALUES (104, 1002, 'Assistant',                    60);
INSERT INTO employee_projects (emp_id, project_id, role, hours_allocated) VALUES (105, 1003, 'Chef de projet Marketing',    120);
INSERT INTO employee_projects (emp_id, project_id, role, hours_allocated) VALUES (106, 1003, 'Analyste',                    100);
INSERT INTO employee_projects (emp_id, project_id, role, hours_allocated) VALUES (107, 1004, 'Auditeur',                    160);
INSERT INTO employee_projects (emp_id, project_id, role, hours_allocated) VALUES (108, 1004, 'Support',                      80);

COMMIT;

DECLARE
    v_emp NUMBER;
    v_dept NUMBER;
    v_proj NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_emp  FROM employees;
    SELECT COUNT(*) INTO v_dept FROM departments;
    SELECT COUNT(*) INTO v_proj FROM projects;
    DBMS_OUTPUT.PUT_LINE('Donnees inserees avec succes');
    DBMS_OUTPUT.PUT_LINE('Employes    : ' || v_emp);
    DBMS_OUTPUT.PUT_LINE('Departements: ' || v_dept);
    DBMS_OUTPUT.PUT_LINE('Projets     : ' || v_proj);
END;
/
