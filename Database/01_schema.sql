-- =====================================================
-- SUPPORTDESK DATABASE
-- Enterprise Support Analytics Platform
-- Version : 2.0
-- =====================================================

DROP DATABASE IF EXISTS supportdesk_db;
CREATE DATABASE supportdesk_db;
USE supportdesk_db;

CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    launch_date DATE NOT NULL,
    status ENUM('Active','Inactive') DEFAULT 'Active'
);

CREATE TABLE modules (
    module_id VARCHAR(10) PRIMARY KEY,
    product_id VARCHAR(10) NOT NULL,
    module_name VARCHAR(100) NOT NULL,
    module_description VARCHAR(255),
    CONSTRAINT fk_module_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL,
    industry VARCHAR(50),
    country VARCHAR(50),
    contact_name VARCHAR(100),
    contact_email VARCHAR(100) UNIQUE,
    subscription_plan ENUM('Free','Basic','Professional','Enterprise') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE customers
ADD COLUMN contact_number VARCHAR(20) AFTER contact_email;

CREATE TABLE engineers (
    engineer_id VARCHAR(10) PRIMARY KEY,
    engineer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    specialization VARCHAR(100),
    experience_years INT,
    location VARCHAR(50),
    joining_date DATE,
    status ENUM('Active','Inactive') DEFAULT 'Active'
);

CREATE TABLE sla_rules (
    sla_id VARCHAR(10) PRIMARY KEY,
    priority ENUM('Low','Medium','High','Critical') NOT NULL,
    response_hours INT NOT NULL,
    resolution_hours INT NOT NULL
);

CREATE TABLE releases (
    release_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(10) NOT NULL,
    release_number INT NOT NULL,
    version VARCHAR(5) NOT NULL,
    release_date DATE,
    release_notes VARCHAR(255),
    CONSTRAINT fk_release_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

CREATE TABLE knowledge_base (
    kb_id VARCHAR(10) PRIMARY KEY,
    module_id VARCHAR(10) NOT NULL,
    article_title VARCHAR(200) NOT NULL,
    article_content TEXT,
    author VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_kb_module
        FOREIGN KEY (module_id)
        REFERENCES modules(module_id)
);

CREATE TABLE tickets (
    ticket_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL,
    product_id VARCHAR(10) NOT NULL,
    module_id VARCHAR(10) NOT NULL,
    engineer_id VARCHAR(10),
    sla_id VARCHAR(10),
    ticket_type ENUM('Bug','Incident','Service Request','Feature Request','Question') NOT NULL,
    ticket_source ENUM('Portal','Email','Phone','Chat','API') NOT NULL,
    priority ENUM('Low','Medium','High','Critical') NOT NULL,
    severity ENUM('Low','Medium','High','Critical') NOT NULL,
    status ENUM('Open','In Progress','Pending','Resolved','Closed') DEFAULT 'Open',
    ticket_title VARCHAR(200),
    ticket_description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    resolved_at DATETIME,
    CONSTRAINT fk_ticket_customer FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_ticket_product FOREIGN KEY(product_id) REFERENCES products(product_id),
    CONSTRAINT fk_ticket_module FOREIGN KEY(module_id) REFERENCES modules(module_id),
    CONSTRAINT fk_ticket_engineer FOREIGN KEY(engineer_id) REFERENCES engineers(engineer_id),
    CONSTRAINT fk_ticket_sla FOREIGN KEY(sla_id) REFERENCES sla_rules(sla_id)
);

CREATE TABLE feedback (
    feedback_id VARCHAR(10) PRIMARY KEY,
    ticket_id VARCHAR(10) NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_feedback_ticket
        FOREIGN KEY(ticket_id)
        REFERENCES tickets(ticket_id)
);

CREATE INDEX idx_ticket_status ON tickets(status);
CREATE INDEX idx_ticket_priority ON tickets(priority);
CREATE INDEX idx_ticket_created ON tickets(created_at);
CREATE INDEX idx_customer_country ON customers(country);
CREATE INDEX idx_engineer_location ON engineers(location);
CREATE INDEX idx_release_number ON releases(release_number);
