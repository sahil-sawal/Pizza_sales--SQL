-- BASIC QUESTIONS

-- 1] Retrieve the total number of orders placed. 

select count(order_id) as Total_order from orders;


-- 2] Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS Total_sales
FROM
    order_detail AS o
        JOIN
    pizzas AS p ON o.Pizza_id = p.pizza_id;


-- 3] Identify the highest-priced pizza.

SELECT 
    p.name, o.price
FROM
    pizza_types AS p
        JOIN
    pizzas AS o ON p.pizza_type_id = o.pizza_type_id
ORDER BY o.price DESC
LIMIT 5;

-- 4] Identify the most common pizza size ordered. 

SELECT 
    p.size, 
	sum(o.Quantity)
FROM
    pizzas AS p
        JOIN
    order_detail AS o ON p.pizza_id = o.Pizza_id
GROUP BY p.size
ORDER BY sum(o.Quantity) DESC;


-- 5] List the top 5 most ordered pizza types along with their quantities

SELECT 
    p.name, SUM(o.quantity) AS Quantity
FROM
    pizza_types AS p
        JOIN
    pizzas AS q ON p.pizza_type_id = q.pizza_type_id
        JOIN
    order_detail AS o ON o.Pizza_id = q.pizza_id
GROUP BY p.name
ORDER BY SUM(o.quantity) DESC
LIMIT 5;



-- INTERMIDIATE QUESTIONS

-- 1] Join the necessary tables to find the 
--    total quantity of each pizza category ordered.

SELECT 
    p.category, SUM(o.quantity)
FROM
    pizza_types AS p
        JOIN
    pizzas AS q ON p.pizza_type_id = q.pizza_type_id
        JOIN
    order_detail AS o ON o.Pizza_id = q.pizza_id
GROUP BY p.category
ORDER BY SUM(o.quantity) DESC;

-- 2] Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(Order_time), COUNT(Order_id)
FROM
    orders
GROUP BY HOUR(Order_time);


-- 3] Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


-- 4] Group the orders by date and calculate the average 
--    number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quant), 0)
FROM
    (SELECT 
        o.Order_date, SUM(q.quantity) AS quant
    FROM
        orders AS o
    JOIN order_detail AS q ON o.Order_id = q.Order_id
    GROUP BY o.Order_date) AS ordered_quantity;


-- 5] Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    p.name, SUM(o.quantity * q.price) AS revenue
FROM
    pizza_types AS p
        JOIN
    pizzas AS q ON p.pizza_type_id = q.pizza_type_id
        JOIN
    order_detail AS o ON o.Pizza_id = q.pizza_id
GROUP BY p.name
ORDER BY revenue DESC
LIMIT 3;


-- ADVANCED QUESTIONS

-- 1] Calculate the percentage contribution of each 
--    pizza type to total revenue.

SELECT 
    p.category,
    round((SUM(o.Quantity * q.price) / (SELECT 
            ROUND(SUM(o.quantity * q.price), 2) AS Total_sales
        FROM
            order_detail AS o
                JOIN
            pizzas AS q ON o.Pizza_id = q.pizza_id)) * 100, 2) AS revenue
FROM
    pizza_types AS p
        JOIN
    pizzas AS q ON p.pizza_type_id = q.pizza_type_id
        JOIN
    order_detail AS o ON o.Pizza_id = q.pizza_id
GROUP BY p.category
ORDER BY revenue DESC;

-- 2] Analyze the cumulative revenue generated over time.

select Order_date, 
sum(revenue) over(order by Order_date) as cum_revenue
 from
(select o.Order_date,
sum(q.quantity * p.price) as revenue
from order_detail as q
join pizzas as p
on q.Pizza_id = p.Pizza_id
join orders as o
on o.Order_id = q.Order_id
group by o.Order_date) as sales;


-- 3] Determine the top 3 most ordered pizza types based on 
--    revenue for each pizza category.

select	category, name, revenue, 
rank() over(partition by category order by revenue) as Ranks 
from
(select p.category, p.name,
sum(o.quantity * q.price) as revenue
from pizza_types as p
join pizzas as q
on p.pizza_type_id = q.pizza_type_id
join order_detail as o
on o.Pizza_id = q.pizza_id
group by p.category, p.name) as a;