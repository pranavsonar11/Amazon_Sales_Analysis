use amazon_sales_analysis
-- 1. Categories
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(20) NOT NULL
);

-- 2. Customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(25) NOT NULL,
    last_name VARCHAR(25) NOT NULL,
    state VARCHAR(25),
    address VARCHAR(50) DEFAULT 'XXX'
);

-- 3. Sellers
CREATE TABLE sellers (
    seller_id INT PRIMARY KEY,
    seller_name VARCHAR(25) NOT NULL,
    origin VARCHAR(25)
);

-- 4. Products
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    category_id INT,
    CONSTRAINT product_Category_fk FOREIGN KEY (category_id) REFERENCES categories(category_id)
)

-- 5. Orders


CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id INT,
    seller_id INT,
    order_status VARCHAR(15),
	CONSTRAINT orders_customers_fk FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
	CONSTRAINT orders_sellers_fk FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

-- 6. Order Items
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_date DATETIME NOT NULL,
    payment_status VARCHAR(20),
    transaction_status VARCHAR(15),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS shipping;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE shipping (
    shipping_id INT PRIMARY KEY,
    order_id INT,
    shipping_date DATE NOT NULL,
    return_date DATE,
    shipping_provider VARCHAR(50),
    delivery_status VARCHAR(20),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);


-- 9. Inventory
CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY,
    product_id INT,
    warehouse_id INT NOT NULL,
    stock INT NOT NULL,
    last_stock_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);