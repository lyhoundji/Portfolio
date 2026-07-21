-- ============================
-- TABLES FINALES
-- ============================

-- Table des clients
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name VARCHAR(100)
);

-- Table des produits
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(100),
    price NUMERIC(10,2)
);

-- Table des commandes
CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    product_id INTEGER REFERENCES products(product_id),
    order_date DATE,
    quantity INTEGER,
    total NUMERIC(10,2),
    payment_method VARCHAR(50),
    status VARCHAR(50)
);

-- ============================
-- TABLE DE STAGING (données brutes, avant nettoyage)
-- ============================

-- Table intermédiaire : reçoit le CSV tel quel, tout en texte, pour éviter les erreurs d'import dues aux données mal typées
CREATE TABLE raw_sales (
    id VARCHAR(20),
    customer_name VARCHAR(100),
    order_id VARCHAR(20),
    order_date VARCHAR(20),
    product VARCHAR(100),
    category VARCHAR(100),
    quantity VARCHAR(20),
    price VARCHAR(20),
    payment_method VARCHAR(50),
    status VARCHAR(50),
    total VARCHAR(20)
);