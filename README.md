# Advanced SQL Data Analysis: Amazon Sales Project

## 📋 Project Overview

This is an **advanced SQL portfolio project** analyzing a comprehensive Amazon ecosystem dataset across 9 interconnected tables. The project demonstrates complex SQL concepts including joins, window functions, CTEs, subqueries, and **stored procedures** to solve **19 real-world business problems**.

**Database:** MySQL  
**Database Name:** `amazon_sales_analysis`  
**Tables:** 9 (Categories, Customers, Sellers, Products, Orders, Order Items, Payments, Shipping, Inventory)

---

## 🎯 Learning Objectives

Master advanced SQL techniques through practical business analytics:
- Database design with parent-child relationships and foreign keys
- Complex multi-table joins (4-6 tables per query)
- Window functions (LEAD, LAG, DENSE_RANK, RANK, ROW_NUMBER)
- Common Table Expressions (CTEs)
- Subqueries and nested queries
- Stored procedures for transactional operations
- Data cleaning and EDA
- Performance optimization

---

## 🗄️ Database Schema

### Parent Tables (No Dependencies)
```sql
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
```

### Child Tables (With Foreign Keys)
```sql
-- 4. Products
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    category_id INT,
    CONSTRAINT product_Category_fk FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

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

-- 7. Payments
CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_date DATETIME NOT NULL,
    payment_status VARCHAR(20),
    transaction_status VARCHAR(15),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- 8. Shipping
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
```

---

## 📊 Business Problems Solved (19 Total)

| # | Problem | Key SQL Concepts | Difficulty |
|---|---------|------------------|-----------|
| 1 | Top 10 Selling Products | GROUP BY, ORDER BY, SUBQUERY | Easy |
| 2 | Revenue by Category with % Contribution | GROUP BY, SUM, Window Functions | Medium |
| 3 | Average Order Value (AOV) per Customer (>5 orders) | GROUP BY, HAVING, CONCAT | Easy |
| 4 | Monthly Sales Trend with MoM Change | CTE, LAG Window Function, Date Functions | Hard |
| 5 | Customers with No Purchases | LEFT JOIN, WHERE NULL | Easy |
| 6 | Least-Selling Category by State | Window Functions (ROW_NUMBER), CTE, PARTITION BY | Hard |
| 7 | Customer Lifetime Value (CLTV) Ranking | SUM, RANK Window Function, GROUP BY | Medium |
| 8 | Inventory Stock Alerts (<10 units) | JOIN, WHERE, Filtering | Easy |
| 9 | Most Returned Products with Return Rate % | CASE WHEN, GROUP BY, Aggregation | Medium |
| 10 | Shipping Delays (>3 days) | JOIN, DATEDIFF, WHERE Filtering | Easy |
| 11 | Top 5 Performing Sellers by Revenue | GROUP BY, SUM, ORDER BY, LIMIT | Easy |
| 12 | Product Profit Margin Analysis | Calculations, RANK Window Function | Medium |
| 13 | Most Returned Products (Count-Based) | CASE WHEN, JOIN, GROUP BY | Medium |
| 14 | Orders Pending Shipment | LEFT JOIN, Multiple WHERE Conditions | Medium |
| 15 | Inactive Sellers (Last 6 Months) | CTE, MAX Date, WHERE Filtering | Medium |
| 16 | Customer Segmentation (Returning vs New) | CASE WHEN, CTE, GROUP BY | Medium |
| 17 | Top 5 Customers per State by Orders | DENSE_RANK, PARTITION BY, WHERE rank ≤ 5 | Hard |
| 18 | Top 10 Products with Highest Decreasing Revenue | CTE, Window Functions, YoY Comparison | Hard |
| 19 | **Final Task: Stored Procedure - Auto Inventory Update** | **Stored Procedure, DECLARE, IF ELSE, UPDATE** | **Advanced** |

---

## 🚀 Getting Started

### Prerequisites
- MySQL 5.7 or higher
- MySQL Workbench or DBeaver (optional GUI)
- SQL command line or terminal access

### Installation Steps

1. **Create Database**
```sql
CREATE DATABASE amazon_sales_analysis;
USE amazon_sales_analysis;
```

2. **Run Schema File**
   - Execute `Amazon_sales_Database_Schema.sql` to create all 9 tables
   - Order matters: Parent tables first, then child tables

3. **Import Data**
   - Use MySQL `LOAD DATA INFILE` or GUI import wizard
   - Data order: categories → customers → sellers → products → orders → order_items → payments → shipping → inventory

4. **Run Business Queries**
   - Execute `Amazon_sales_Business_Problems.sql` to run all 19 solutions

---

## 📝 Key Queries by Problem

### Q1: Top 10 Selling Products
```sql
SELECT sub.product_id, p.product_name, sub.tot_qty, sub.tot_sales
FROM (
    SELECT product_id, 
           SUM(quantity) tot_qty, 
           ROUND(SUM(total_sales)) as tot_sales
    FROM order_items
    GROUP BY product_id
    ORDER BY tot_sales DESC
    LIMIT 10
) sub
JOIN products p ON sub.product_id = p.product_id;
```

### Q4: Monthly Sales Trend with MoM Change (Window Functions)
```sql
WITH cte AS (
    SELECT 
        EXTRACT(MONTH FROM o.order_date) as month,
        MONTHNAME(o.order_date) as month_name,
        ROUND(SUM(total_sales)) as curr_month_sale
    FROM order_items ot
    JOIN orders o ON ot.order_id = o.order_id
    GROUP BY EXTRACT(MONTH FROM o.order_date), MONTHNAME(o.order_date)
    ORDER BY month ASC
),
cte2 AS (
    SELECT *,
           LAG(curr_month_sale) OVER() as prev_month_sale
    FROM cte
)
SELECT
    month, month_name, curr_month_sale, prev_month_sale,
    (curr_month_sale - prev_month_sale) AS mom_change,
    ROUND((curr_month_sale - prev_month_sale) * 100.0 / prev_month_sale, 2) AS mom_percentage_change
FROM cte2
ORDER BY month;
```

### Q6: Least-Selling Category by State (Advanced Window Functions)
```sql
WITH state_sales AS (
    SELECT
        c.state,
        ctg.category_name,
        SUM(ot.total_sales) AS total_sales
    FROM order_items ot
    JOIN orders o ON ot.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN products p ON ot.product_id = p.product_id
    JOIN categories ctg ON p.category_id = ctg.category_id
    GROUP BY c.state, ctg.category_name
),
ranked AS (
    SELECT
        state, category_name, total_sales,
        ROW_NUMBER() OVER (PARTITION BY state ORDER BY total_sales ASC) AS rn,
        ROUND(SUM(total_sales) OVER (PARTITION BY state)) AS state_total_sales
    FROM state_sales
)
SELECT
    state,
    category_name AS least_selling_category,
    total_sales,
    state_total_sales,
    ROUND((total_sales / state_total_sales) * 100, 2) AS percentage_contribution
FROM ranked
WHERE rn = 1
ORDER BY state;
```

### Q7: Customer Lifetime Value (CLTV) Ranking
```sql
WITH customer_cltv AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) as customer_name,
        ROUND(SUM(ot.total_sales)) AS cltv
    FROM order_items ot
    JOIN orders o ON ot.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, CONCAT(c.first_name, ' ', c.last_name)
)
SELECT
    customer_id, customer_name, cltv,
    RANK() OVER (ORDER BY cltv DESC) AS cltv_rank
FROM customer_cltv
ORDER BY cltv DESC;
```

### Q17: Top 5 Customers per State (DENSE_RANK Window Function)
```sql
WITH ranked_customers AS (
    SELECT
        c.customer_id,
        c.full_name,
        c.state,
        COUNT(*) AS total_orders,
        ROUND(SUM(oi.total_sales), 2) AS total_sales,
        DENSE_RANK() OVER (
            PARTITION BY c.state
            ORDER BY COUNT(*) DESC, SUM(oi.total_sales) DESC
        ) AS state_rank
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.full_name, c.state
)
SELECT *
FROM ranked_customers
WHERE state_rank <= 5
ORDER BY state, state_rank;
```

### Q18: Top 10 Products with Highest Decreasing Revenue (YoY Comparison)
```sql
WITH revenue_by_year AS (
    SELECT
        p.product_id, p.product_name, c.category_name,
        YEAR(o.order_date) AS order_year,
        SUM(oi.total_sales) AS total_revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN products p ON oi.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
    GROUP BY p.product_id, p.product_name, c.category_name, YEAR(o.order_date)
),
rev_compare AS (
    SELECT
        r22.product_id, r22.product_name, r22.category_name,
        r22.total_revenue AS revenue_2022,
        r23.total_revenue AS revenue_2023,
        ROUND(((r23.total_revenue - r22.total_revenue) / r22.total_revenue) * 100, 2) AS decrease_ratio
    FROM revenue_by_year r22
    JOIN revenue_by_year r23
        ON r22.product_id = r23.product_id
        AND r22.order_year = 2022
        AND r23.order_year = 2023
)
SELECT product_id, product_name, category_name, revenue_2022, revenue_2023, decrease_ratio
FROM rev_compare
WHERE decrease_ratio < 0
ORDER BY decrease_ratio ASC
LIMIT 10;
```

### Q19: Final Task - Stored Procedure for Auto Inventory Update
```sql
DELIMITER $$

CREATE PROCEDURE add_sales(
    IN p_order_id INT,
    IN p_customer_id INT,
    IN p_seller_id INT,
    IN p_order_item_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_product_name VARCHAR(100);
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock_count INT;

    -- Get product details & stock
    SELECT p.product_name, p.price, i.stock
    INTO v_product_name, v_price, v_stock_count
    FROM products p
    JOIN inventory i ON p.product_id = i.product_id
    WHERE p.product_id = p_product_id;

    -- Check stock availability
    IF v_stock_count < p_quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = CONCAT('Not enough stock for product: ', v_product_name);
    END IF;

    -- Insert into orders table
    INSERT INTO orders (order_id, customer_id, seller_id, order_date, order_status)
    VALUES (p_order_id, p_customer_id, p_seller_id, CURDATE(), 'Confirmed');

    -- Insert into order_items table
    INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price)
    VALUES (p_order_item_id, p_order_id, p_product_id, p_quantity, v_price);

    -- Reduce stock in inventory
    UPDATE inventory
    SET stock = stock - p_quantity
    WHERE product_id = p_product_id;

    SELECT CONCAT('Sale Added | Product: ', v_product_name, ' | Qty: ', p_quantity, ' | Stock Updated') AS message;
END $$

DELIMITER ;
```

**Execute Stored Procedure:**
```sql
CALL add_sales(25001, 102, 7, 35001, 3, 40);
```

---

## 📁 Repository Structure

```
amazon-sql-project/
├── README.md                                    # This file
├── sql/
│   ├── Amazon_sales_Database_Schema.sql         # Table creation (9 tables)
│   └── Amazon_sales_Business_Problems.sql       # All 19 solutions
├── data/
│   ├── categories.csv
│   ├── customers.csv
│   ├── sellers.csv
│   ├── products.csv
│   ├── orders.csv
│   ├── order_items.csv
│   ├── payments.csv
│   ├── shipping.csv
│   └── inventory.csv
└── documentation/
    └── SETUP_GUIDE.md                           # Detailed setup instructions
```

---

## 🎓 Skills Demonstrated

**Advanced SQL Proficiency:**
- ✅ Multi-table JOINs (INNER, LEFT, SELF)
- ✅ Aggregate Functions (SUM, AVG, COUNT, MIN, MAX)
- ✅ Window Functions (ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD)
- ✅ Common Table Expressions (CTEs/WITH clause)
- ✅ Correlated & Scalar Subqueries
- ✅ CASE Statements for conditional logic
- ✅ Date arithmetic (DATEDIFF, YEAR, MONTH, EXTRACT)
- ✅ GROUP BY & HAVING clauses
- ✅ **Stored Procedures with error handling**
- ✅ SIGNAL & exception management

**Database Design:**
- ✅ Relational schema with 9 tables
- ✅ Primary & Foreign key constraints
- ✅ Data integrity enforcement
- ✅ Efficient query optimization

**Business Analytics:**
- ✅ Revenue analysis & forecasting
- ✅ Customer segmentation & lifetime value
- ✅ Inventory management & alerts
- ✅ Operational metrics & KPIs
- ✅ Trend analysis & YoY comparisons

---

## 🔍 Key Query Patterns

### Pattern 1: Window Functions for Ranking
Used in Q7, Q12, Q17 for ranking customers, products, and sellers.

### Pattern 2: CTE for Complex Multi-Step Logic
Used in Q4, Q6, Q7, Q15, Q16, Q18 for readability and organization.

### Pattern 3: Date Calculations
Used in Q4, Q9, Q10, Q15 for time-series and delay analysis.

### Pattern 4: Aggregation with Percentages
Used in Q2, Q6, Q9 for contribution analysis.

### Pattern 5: Subqueries for Filtering
Used in Q1, Q5, Q14 for intermediate calculations.

---

## 💾 How to Use This Repository

### For Learning
1. Clone repository
2. Set up MySQL database following schema file
3. Load data into tables
4. Execute queries from Q1-Q19 progressively
5. Modify queries to explore variations
6. Explain business logic behind each query

### For Portfolio/Interview Preparation
- Reference specific queries demonstrating SQL proficiency
- Explain business context & optimization approach
- Discuss stored procedure for transactional integrity
- Highlight advanced window function usage
- Compare to industry best practices

### For Enhancement
- Add more complex business problems
- Implement additional stored procedures (triggers, events)
- Create views for common aggregations
- Integrate with Power BI/Tableau
- Add performance metrics & execution plans

---

## 📊 Dataset Characteristics

| Metric | Value |
|--------|-------|
| Total Records (Orders) | 1000+ |
| Unique Customers | 700+ |
| Unique Products | 766 |
| Unique Sellers | 55+ |
| Product Categories | 10+ |
| Date Range | 2022-2023 |

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|------|---------|
| MySQL 5.7+ | Database engine |
| MySQL Workbench | GUI management & query editor |
| DBeaver (Optional) | SQL IDE with visualization |
| CSV Files | Data import format |
| Git | Version control |

---

## 📚 References

- [MySQL Window Functions Documentation](https://dev.mysql.com/doc/refman/8.0/en/window-functions.html)
- [MySQL Stored Procedures](https://dev.mysql.com/doc/refman/8.0/en/create-procedure.html)
- [MySQL CTE (Common Table Expressions)](https://dev.mysql.com/doc/refman/8.0/en/with.html)
- Zero Analyst YouTube Channel - Advanced SQL Series

---

## 🎬 Project Source

**Tutorial:** Advanced SQL Data Analysis Resume Project | Complex SQL (Guided)  
**Creator:** Zero Analyst  
**Difficulty:** Advanced (5-6 tables per query, 19 business problems)

---

## ✉️ Contact & Support

For questions or issues:
1. Review SQL comments in each query
2. Check MySQL official documentation
3. Verify database schema and data integrity
4. Test with sample data

---

## 🤝 Contributing

Contributions welcome! Ideas for enhancement:
- Add more complex business scenarios
- Optimize query performance
- Create additional stored procedures
- Build dashboards with results

---

## 📄 License

Educational & Portfolio Use | Free to use and modify

---

**Last Updated:** November 2025  
**Status:** Complete & Production-Ready ✅  
**Database Type:** MySQL  
**Difficulty Level:** Advanced  
**Estimated Learning Time:** 15-20 hours
