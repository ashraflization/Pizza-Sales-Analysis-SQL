
 -- ============================================

--  Pizza Sales Analysis using SQL
--  Author: Rehan Ashraf

--  ============================================



--  1. Total Number of Orders
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;



--  2. Total Revenue Generated from Pizza Sales
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;



--  3. Highest Priced Pizza
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;



--  4. Most Common Pizza Size Ordered
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;



--  5. Top 5 Most Ordered Pizza Types
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;



 -- 6. Category-wise Quantity Ordered
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;



--  7. Distribution of Orders by Hour of the Day
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);


--  8. Category-wise Pizza Variety
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;
--  9. Average Number of Pizzas Ordered per Day
SELECT 
    AVG(quantity)
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;



--  10. Top 3 Pizzas by Revenue
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;



--  11. Revenue Contribution by Category 
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price), 2)
        FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;



--  12. Cumulative Revenue Over Time
SELECT 
    order_date,
    SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM
(
    SELECT 
        orders.order_date,
        SUM(order_details.quantity * pizzas.price) AS revenue
    FROM 
        order_details
        JOIN pizzas
            ON order_details.pizza_id = pizzas.pizza_id
        JOIN orders
            ON orders.order_id = order_details.order_id
    GROUP BY 
        orders.order_date
) AS sales;



--  13. Top 3 Revenue-Generating Pizzas by Category
SELECT name, revenue
FROM
(
    SELECT 
        category, 
        name, 
        revenue,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM
    (
        SELECT 
            pizza_types.category,
            pizza_types.name,
            SUM(order_details.quantity * pizzas.price) AS revenue
        FROM 
            pizza_types
            JOIN pizzas
                ON pizza_types.pizza_type_id = pizzas.pizza_type_id
            JOIN order_details
                ON order_details.pizza_id = pizzas.pizza_id
        GROUP BY 
            pizza_types.category, 
            pizza_types.name
    ) AS a
) AS b
WHERE rn <= 3;




