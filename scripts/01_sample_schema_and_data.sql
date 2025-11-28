-- Sample schema and seed data for MySQL 8 lab
-- Run with: mysql -h 127.0.0.1 -P 3306 -u root -pStrongRootPass123! < 01_sample_schema_and_data.sql

USE lab;

DROP TABLE IF EXISTS project_assignments;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    UNIQUE KEY uq_departments_name (name)
) ENGINE = InnoDB;

CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_employees_department FOREIGN KEY (department_id) REFERENCES departments (department_id),
    UNIQUE KEY uq_employees_email (email)
) ENGINE = InnoDB;

CREATE TABLE projects (
    project_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE DEFAULT NULL,
    status ENUM ('planned', 'active', 'on_hold', 'complete') NOT NULL DEFAULT 'planned',
    budget DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_projects_department FOREIGN KEY (department_id) REFERENCES departments (department_id),
    UNIQUE KEY uq_projects_name (name)
) ENGINE = InnoDB;

CREATE TABLE project_assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT NOT NULL,
    employee_id INT NOT NULL,
    role VARCHAR(80) NOT NULL,
    allocation_pct TINYINT UNSIGNED NOT NULL CHECK (allocation_pct BETWEEN 0 AND 100),
    assigned_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_assignments_project FOREIGN KEY (project_id) REFERENCES projects (project_id),
    CONSTRAINT fk_assignments_employee FOREIGN KEY (employee_id) REFERENCES employees (employee_id),
    UNIQUE KEY uq_assignments_project_employee (project_id, employee_id)
) ENGINE = InnoDB;

INSERT INTO departments (name, location)
VALUES
    ('Engineering', 'New York'),
    ('Product', 'Austin'),
    ('Marketing', 'Remote'),
    ('Operations', 'Chicago');

INSERT INTO employees (department_id, first_name, last_name, email, hire_date, salary)
VALUES
    (1, 'Alice', 'Nguyen', 'alice.nguyen@example.com', '2021-03-15', 105000.00),
    (1, 'Bruno', 'Diaz', 'bruno.diaz@example.com', '2020-07-01', 98000.00),
    (2, 'Carla', 'Rossi', 'carla.rossi@example.com', '2022-02-10', 95000.00),
    (3, 'Diego', 'Silva', 'diego.silva@example.com', '2019-11-05', 78000.00),
    (4, 'Eva', 'Martin', 'eva.martin@example.com', '2018-01-22', 88000.00);

INSERT INTO projects (department_id, name, start_date, end_date, status, budget)
VALUES
    (1, 'Platform Revamp', '2023-01-01', NULL, 'active', 250000.00),
    (2, 'Mobile App Launch', '2023-05-15', '2023-12-15', 'on_hold', 150000.00),
    (3, 'Brand Refresh', '2022-09-01', '2023-03-31', 'complete', 90000.00),
    (4, 'Logistics Automation', '2023-02-01', NULL, 'planned', 120000.00);

INSERT INTO project_assignments (project_id, employee_id, role, allocation_pct)
VALUES
    (1, 1, 'Tech Lead', 80),
    (1, 2, 'Backend Engineer', 70),
    (2, 3, 'Product Manager', 60),
    (3, 4, 'Marketing Lead', 50),
    (4, 5, 'Ops Manager', 75),
    (1, 3, 'Stakeholder', 15);
