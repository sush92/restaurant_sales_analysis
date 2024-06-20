-- First, we create the table if it does not already exist.

CREATE TABLE IF NOT EXISTS order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT,
    order_date DATE,
    order_time TIME,
    item_id INT,
    item_name VARCHAR(255),
    category VARCHAR(255),
    price DECIMAL(10, 2)
);

COPY order_details (order_details_id, order_id, order_date, order_time, item_id, item_name, category, price)
FROM 'data/loaddata.csv' 
DELIMITER '|' CSV HEADER;
