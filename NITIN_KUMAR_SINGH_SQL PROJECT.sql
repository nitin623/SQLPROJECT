/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms), 
 both first name and last name are in upper case, customer_email,  customer_creation_year 
 and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
Hint:Use CASE statement. create customer_creation_year column with the help of customer_creation_date,
 no permanent change in the table is required. (Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables
 for your representation. A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.) 
*/

## Answer 1 
SELECT CUSTOMER_ID,IF(CUSTOMER_GENDER = 'F','MS','MR') AS TITLE,upper(concat(CUSTOMER_FNAME,'  ',CUSTOMER_LNAME)) as FULLNAME ,CUSTOMER_EMAIL,year(CUSTOMER_CREATION_DATE) as CUSTOMER_CREATION_YEAR,CUSTOMER_GENDER, 
CASE
    WHEN year(CUSTOMER_CREATION_DATE) < 2005  then 'category A'
    WHEN year(CUSTOMER_CREATION_DATE) >=2005 and year(CUSTOMER_CREATION_DATE)<2011 then 'category B'
    WHEN year(CUSTOMER_CREATION_DATE) >= 2011  then 'category C'
END AS CUSTOMER_CATEGORY
FROM online_customer
LIMIT 52



/* Q2. Write a query to display the following information for the products which
 have not been sold: product_id, product_desc, product_quantity_avail, product_price,
 inventory values (product_quantity_avail * product_price), New_Price after applying discount
 as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 20,000 then apply 20% discount 
ii) If Product Price > 10,000 then apply 15% discount 
iii) if Product Price =< 10,000 then apply 10% discount 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
Hint: Use CASE statement, no permanent change in table required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation.
 A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.)
*/
## Answer 2.
SELECT  PRODUCT_ID,PRODUCT_DESC,PRODUCT_QUANTITY_AVAIL,PRODUCT_PRICE,(PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE) AS INVENTORY_VALUE,
CASE
    WHEN PRODUCT_PRICE > 20000 THEN PRODUCT_PRICE * 0.8
    WHEN PRODUCT_PRICE > 10000 THEN PRODUCT_PRICE * 0.85
    ELSE PRODUCT_PRICE * 0.90
  END AS NEW_PRICE_AFTER_DISCOUNT
FROM orders.product
ORDER BY INVENTORY_VALUE DESC
LIMIT 13



/*Q3. Write a query to display Product_class_code, Product_class_desc, Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price). Information should be displayed for only those
 product_class_code which have more than 1,00,000 Inventory Value. Sort the output with respect to decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
Hint: 'count of product type in each product class' is the count of product_id based on product_class_code.
*/

## Answer 3.
SELECT P.PRODUCT_CLASS_CODE,C.PRODUCT_CLASS_DESC,(P.PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE) AS INVANTORY_VALUECOUNT 
FROM PRODUCT P  INNER JOIN PRODUCT_CLASS C
ON P.PRODUCT_CLASS_CODE = C.PRODUCT_CLASS_CODE
WHERE (P.PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE) > 100000
ORDER BY INVANTORY_VALUECOUNT DESC
LIMIT 9

TOTAL_COUNT

SELECT P.PRODUCT_CLASS_CODE, C.PRODUCT_CLASS_DESC, COUNT(*) AS PRODUCT_TYPE_COUNT
FROM PRODUCT P
INNER JOIN PRODUCT_CLASS C ON P.PRODUCT_CLASS_CODE = C.PRODUCT_CLASS_CODE
WHERE (P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) > 100000
GROUP BY P.PRODUCT_CLASS_CODE, C.PRODUCT_CLASS_DESC;



/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER]
Hint: USE SUBQUERY
*/
 
## Answer 4.
SELECT o. CUSTOMER_ID,upper(concat(o.CUSTOMER_FNAME,'  ',o.CUSTOMER_LNAME)) as FULLNAME,
o.CUSTOMER_EMAIL,o.CUSTOMER_PHONE,h.ORDER_STATUS,a.COUNTRY
FROM online_customer o  inner join order_header h
on o.CUSTOMER_ID = h.CUSTOMER_ID
inner join address a
on o.ADDRESS_ID = a.ADDRESS_ID 
where ORDER_STATUS = 'cancelled'
LIMIT 1



/*Q5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the shipper in the city ,
 number of consignment delivered to that city for Shipper DHL 
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
Hint: The answer should only be based on Shipper_Name -- DHL. The main intent is to find the number
 of customers and the consignments catered by DHL in each city.
 */

## Answer 5.
SELECT S.SHIPPER_NAME,A.CITY,COUNT(OH.CUSTOMER_ID),COUNT(S.SHIPPER_ID)
FROM SHIPPER S INNER JOIN ORDER_HEADER OH
ON S.SHIPPER_ID = OH.SHIPPER_ID
INNER JOIN ONLINE_CUSTOMER OC 
ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
INNER JOIN ADDRESS A 
ON OC.ADDRESS_ID = A.ADDRESS_ID
WHERE S.SHIPPER_NAME = 'DHL'
GROUP BY S.SHIPPER_NAME,A.CITY 
LIMIT 9
  



/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and 
show inventory Status of products as per below condition: 

a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
Hint:  quantity sold here is product_quantity in order_items table. 
You may use multiple case statements to show inventory status (Low stock, In stock, and Enough stock)
 that meets both the conditions i.e. on products as well as on quantity.
The meaning of the rest of the categories, means products apart from electronics, computers, mobiles, and watches.
*/

## Answer 6.
SELECT P.PRODUCT_ID, P.PRODUCT_DESC, P.PRODUCT_QUANTITY_AVAIL, OI.PRODUCT_QUANTITY,
       PC.PRODUCT_CLASS_DESC, (P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) AS INVENTORY_VALUE,
       CASE
           WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'No Sales in the past, give discount to reduce inventory'
           WHEN PRODUCT_QUANTITY_AVAIL < 0.1 * SUM(OI.PRODUCT_QUANTITY) THEN 'Low inventory, need to add inventory'
           WHEN PRODUCT_QUANTITY_AVAIL < 0.5 * SUM(OI.PRODUCT_QUANTITY) THEN 'Medium inventory, need to add some inventory'
           ELSE 'Sufficient inventory'
       END AS ELEC_COMP_STATUS
FROM PRODUCT P INNER JOIN PRODUCT_CLASS PC 
ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE
INNER JOIN ORDER_ITEMS OI 
ON P.PRODUCT_ID = OI.PRODUCT_ID
WHERE PC.PRODUCT_CLASS_DESC IN ('Electronics','Computer')
GROUP BY P.PRODUCT_ID, P.PRODUCT_DESC, P.PRODUCT_QUANTITY_AVAIL, OI.PRODUCT_QUANTITY, PC.PRODUCT_CLASS_DESC,(P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE)

UNION ALL

SELECT P.PRODUCT_ID, P.PRODUCT_DESC, P.PRODUCT_QUANTITY_AVAIL, OI.PRODUCT_QUANTITY,
       PC.PRODUCT_CLASS_DESC, (P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) AS INVENTORY_VALUE,
       CASE
           WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'No Sales in the past, give discount to reduce inventory'
           WHEN PRODUCT_QUANTITY_AVAIL < 0.2 * SUM(OI.PRODUCT_QUANTITY) THEN 'Low inventory, need to add inventory'
           WHEN PRODUCT_QUANTITY_AVAIL < 0.6 * SUM(OI.PRODUCT_QUANTITY) THEN 'Medium inventory, need to add some inventory'
           ELSE 'Sufficient inventory'
       END AS ELEC_COMP_STATUS
FROM PRODUCT P INNER JOIN PRODUCT_CLASS PC 
ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE
INNER JOIN ORDER_ITEMS OI 
ON P.PRODUCT_ID = OI.PRODUCT_ID
WHERE PC.PRODUCT_CLASS_DESC IN ('Mobiles','Watches')
GROUP BY P.PRODUCT_ID, P.PRODUCT_DESC, P.PRODUCT_QUANTITY_AVAIL, OI.PRODUCT_QUANTITY, PC.PRODUCT_CLASS_DESC,(P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE)

UNION ALL

SELECT P.PRODUCT_ID, P.PRODUCT_DESC, P.PRODUCT_QUANTITY_AVAIL, OI.PRODUCT_QUANTITY,
       PC.PRODUCT_CLASS_DESC, (P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) AS INVENTORY_VALUE,
       CASE
           WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'No Sales in the past, give discount to reduce inventory'
           WHEN PRODUCT_QUANTITY_AVAIL < 0.3 * SUM(OI.PRODUCT_QUANTITY) THEN 'Low inventory'
           WHEN PRODUCT_QUANTITY_AVAIL < 0.7 * SUM(OI.PRODUCT_QUANTITY) THEN 'Medium inventory, need to add some inventory'
           ELSE  'Sufficient inventory'
       END AS ELEC_COMP_STATUS
FROM PRODUCT P INNER JOIN PRODUCT_CLASS PC 
ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE
INNER JOIN ORDER_ITEMS OI 
ON P.PRODUCT_ID = OI.PRODUCT_ID
WHERE PC.PRODUCT_CLASS_DESC IN ('Toys','Clothes','Books','Stationery','Furnitures','Bags','Kitchen Items','Promotion-High Value','Promotion-Medium Value','Promotion-Medium Value')
GROUP BY P.PRODUCT_ID, P.PRODUCT_DESC, P.PRODUCT_QUANTITY_AVAIL, OI.PRODUCT_QUANTITY, PC.PRODUCT_CLASS_DESC,(P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) 
LIMIT 60


/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
Hint: First find the volume of carton id 10 and then find the order id with products having total volume less than the volume of carton id 10
 */

## Answer 7.
SELECT OI.ORDER_ID,(P.LEN*P.WIDTH*P.HEIGHT) AS VOLUME
FROM ORDER_ITEMS OI INNER JOIN PRODUCT P
ON OI.PRODUCT_ID = P.PRODUCT_ID
WHERE (P.LEN*P.WIDTH*P.HEIGHT) < 18000000
ORDER BY VOLUME DESC
LIMIT 1



/*Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) 
shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
*/

## Answer 8.
SELECT OC.CUSTOMER_ID,upper(concat(OC.CUSTOMER_FNAME,'  ',OC.CUSTOMER_LNAME)) as FULLNAME,(OI.PRODUCT_QUANTITY*P.PRODUCT_PRICE) AS TOTAL_VALUE,OH.ORDER_STATUS,OH.PAYMENT_MODE
FROM ONLINE_CUSTOMER OC INNER JOIN ORDER_HEADER OH
ON OC.CUSTOMER_ID = OH.CUSTOMER_ID
INNER JOIN ORDER_ITEMS OI
ON OH.ORDER_ID = OI.ORDER_ID
INNER JOIN PRODUCT P
ON OI.PRODUCT_ID = P.PRODUCT_ID
WHERE (PAYMENT_MODE = 'SHIPPED' OR PAYMENT_MODE = 'CASH') AND OC.CUSTOMER_LNAME LIKE 'G%'
LIMIT 2



/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold together 
with product id 201 and are not shipped to city Bangalore and New Delhi. 
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
Hint: Display the output in descending order with respect to the sum of product_quantity. 
(USE SUB-QUERY) In final output show only those products , 
 product_id’s which are sold with 201 product_id (201 should not be there in output) and are shipped except Bangalore and New Delhi
 */

## Answer 9.
SELECT p.product_id, p.product_desc, SUM(oi.product_quantity) AS total_quantity
FROM order_items oi
JOIN product p 
ON oi.product_id = p.product_id
JOIN order_header oh 
ON oi.order_id = oh.order_id
JOIN online_customer oc 
ON oh.customer_id = oc.customer_id
JOIN address a 
ON oc.address_id = a.address_id
WHERE p.product_id <> 201
  AND a.city NOT IN ('Bangalore', 'New Delhi')
  AND oi.order_id IN (
    SELECT oi2.order_id
    FROM order_items oi2
    WHERE oi2.product_id = 201
  )
GROUP BY p.product_id, p.product_desc
ORDER BY total_quantity DESC



/* Q10. Write a query to display the order_id, customer_id and customer fullname, 
total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS]	
 */

## Answer 10.
SELECT OH.ORDER_ID, OC.CUSTOMER_ID, upper(concat(OC.CUSTOMER_FNAME,'  ',OC.CUSTOMER_LNAME)) as FULLNAME, SUM(OI.PRODUCT_QUANTITY) AS total_quantity
FROM ORDER_HEADER OH INNER JOIN ONLINE_CUSTOMER OC 
ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
INNER JOIN ORDER_ITEMS OI 
ON OH.ORDER_ID = OI.ORDER_ID
JOIN ADDRESS A 
ON OC.ADDRESS_ID = A.ADDRESS_ID
WHERE OH.order_id % 2 = 0
  AND A.pincode NOT LIKE '5%'
GROUP BY OH.order_id, OC.customer_id, FULLNAME
LIMIT 15; 

