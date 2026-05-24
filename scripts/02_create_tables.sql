CONNECT mon_user/mon_mdp@XEPDB1
-- 02_create_tables.sql
-- Création des tables avec contraintes

-- Table des départements
CREATE TABLE departments (
    dept_id     NUMBER PRIMARY KEY,
    dept_name   VARCHAR2(50) NOT NULL UNIQUE,
    location    VARCHAR2(100),
    budget      NUMBER(12,2) CHECK (budget >= 0),
    created_date DATE DEFAULT SYSDATE
);

-- Table des employés
CREATE TABLE employees (
    emp_id       NUMBER PRIMARY KEY,
    first_name   VARCHAR2(50) NOT NULL,
    last_name    VARCHAR2(50) NOT NULL,
    email        VARCHAR2(100) UNIQUE NOT NULL,
    phone        VARCHAR2(20),
    hire_date    DATE DEFAULT SYSDATE,
    job_title    VARCHAR2(50),
    salary       NUMBER(10,2) CHECK (salary > 0),
    commission_pct NUMBER(4,2) DEFAULT 0,
    dept_id      NUMBER,
    manager_id   NUMBER,
    CONSTRAINT fk_dept    FOREIGN KEY (dept_id)    REFERENCES departments(dept_id) ON DELETE SET NULL,
    CONSTRAINT fk_manager FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
);

-- Table des projets
CREATE TABLE projects (
    project_id   NUMBER PRIMARY KEY,
    project_name VARCHAR2(100) NOT NULL,
    start_date   DATE,
    end_date     DATE,
    budget       NUMBER(12,2),
    status       VARCHAR2(20) DEFAULT 'PLANNED'
                     CHECK (status IN ('PLANNED','ACTIVE','COMPLETED','CANCELLED'))
);

-- Table d'affectation des employés aux projets (relation many-to-many)
CREATE TABLE employee_projects (
    emp_id           NUMBER,
    project_id       NUMBER,
    assignment_date  DATE DEFAULT SYSDATE,
    role             VARCHAR2(50),
    hours_allocated  NUMBER,
    PRIMARY KEY (emp_id, project_id),
    CONSTRAINT fk_emp_proj_emp  FOREIGN KEY (emp_id)       REFERENCES employees(emp_id)  ON DELETE CASCADE,
    CONSTRAINT fk_emp_proj_proj FOREIGN KEY (project_id)   REFERENCES projects(project_id) ON DELETE CASCADE
);

-- Index pour optimiser les performances
CREATE INDEX idx_emp_dept    ON employees(dept_id);
CREATE INDEX idx_emp_manager ON employees(manager_id);
CREATE INDEX idx_emp_proj_emp ON employee_projects(emp_id);
CREATE INDEX idx_proj_status ON projects(status);

-- Séquences pour les IDs
CREATE SEQUENCE seq_emp_id     START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE seq_dept_id    START WITH 10  INCREMENT BY 1;
CREATE SEQUENCE seq_project_id START WITH 1000 INCREMENT BY 1;

BEGIN
    DBMS_OUTPUT.PUT_LINE('✅ Tables créées avec succès');
END;
/
