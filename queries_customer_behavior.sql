--P1. ¿Cuál es la ganancia total generada por clientes masculinos vs femeninos?
select gender, SUM(purchase_amount) as ganancia
from customer
group by gender

--P2. ¿Qué clientes usaron un descuento pero aun así gastaron más que el promedio?
select customer_id, purchase_amount 
from customer 
where discount_applied = 'Yes' and purchase_amount >= (select AVG(purchase_amount) from customer)

--P3. ¿Cuáles son los 5 principales productos con el mayor promedio de review rating?
select item_purchased, round(avg(review_rating::numeric),2) as "Promedio Product Rating"
from customer
group by item_purchased
order by avg(review_rating) desc
limit 5

--P4. Compara el promedio de monto de las compras entre envio Standard y Express
select shipping_type, 
ROUND(AVG(purchase_amount),2)
from customer
where shipping_type in ('Standard','Express')
group by shipping_type;

--P5. ¿Los clientes subcritos gastan más? Compara el gasto promedio y ganancia total entre clientes subscritos y sin subscripción
SELECT subscription_status,
       COUNT(customer_id) AS total_clientes,
       ROUND(AVG(purchase_amount),2) AS gasto_prom,
       ROUND(SUM(purchase_amount),2) AS ganacia_total
FROM customer
GROUP BY subscription_status
ORDER BY ganacia_total,gasto_prom DESC;

--P6. De los 5 productos más vendidos ¿Qué porcentaje de esas ventas fueron con descuento?
SELECT item_purchased,
       ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS porcentaje_descuento
FROM customer
GROUP BY item_purchased
ORDER BY porcentaje_descuento DESC
LIMIT 5;

--P7. Segmenta los clientes en Nuevo, Recurrente y Leal basado en su número total de compras pasadas y muestra el total de cada segmento
with customer_type as (
SELECT customer_id, previous_purchases,
CASE 
    WHEN previous_purchases = 1 THEN 'Nuevo'
    WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Recurrente'
    ELSE 'Leal'
    END AS customer_segment
FROM customer)

select customer_segment,count(*) AS "Total de clientes" 
from customer_type 
group by customer_segment;

--P8. ¿Cuáles son los 3 productos más comprados en cada categoría?
WITH item_counts AS (
    SELECT category,
           item_purchased,
           COUNT(customer_id) AS total_ordenes,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS rango_producto
    FROM customer
    GROUP BY category, item_purchased
)
SELECT rango_producto,category, item_purchased, total_ordenes
FROM item_counts
WHERE rango_producto <=3;
 
--P9. ¿Los clientes que son compradores recurrentes (más de 5 compras previas) son propensos a subscribirse?
SELECT subscription_status,
       COUNT(customer_id) AS compradores_recurrentes
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;

--P10. ¿Cuál es la contribución a la ganancia de cada grupo de edad? 
SELECT 
    age_group,
    SUM(purchase_amount) AS ganancia_total
FROM customer
GROUP BY age_group
ORDER BY ganancia_total desc;