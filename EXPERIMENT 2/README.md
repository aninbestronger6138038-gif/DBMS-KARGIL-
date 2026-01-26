# **DBMS Lab – Worksheet 2**  
## **Implementation of SELECT Queries with Filtering, Grouping and Sorting in PostgreSQL**

---

## 👨‍🎓 **Student Details**  
**Name:** ANINDITA DHAR  
**UID:** 25MCI10167  
**Branch:** MCA(GENERAL) 
**Semester:** II  
**Section/Group:** 1/A  
**Subject:** TECHNICAL TRAINING 
**Date of Performance:** 17/01/2026  

---

## 🎯 **Aim **  
To implement and analyze SQL SELECT queries using filtering, sorting, grouping, and aggregation concepts in PostgreSQL for efficient data retrieval and analytical reporting.

---

## 💻 **Software Requirements**

- PostgreSQL (Database Server)  
- pgAdmin
- Windows Operating System  

---

## 📌 **Objective **  
- To retrieve specific data using filtering conditions  
- To sort query results using single and multiple attributes  
- To perform aggregation using grouping techniques  
- To apply conditions on aggregated data using HAVING clause  
- To understand real-world analytical queries commonly asked in placement interviews  

---

## 🛠️ **Practical / Experiment Steps**  
- Create a sample table representing customer orders  
- Insert realistic records into the table  
- Retrieve filtered data using WHERE clause  
- Sort query results using ORDER BY  
- Group records and apply aggregate functions  
- Apply conditions on grouped data using HAVING  
- Analyze execution order of WHERE and HAVING clauses  

---

# ⚙️ **Procedure**

## **Step 1: Database and Table Creation**

```sql
create database CompanyDB;
```

```sql
create table customer_orders(
order_id serial primary key,
customer_name varchar(20),
product varchar(20),
quantity int,
price numeric(10,2),
order_date date
);
```

---

## **Step 2: Insert Records (DML)**

```sql
insert into customer_orders(customer_name,product,quantity,price,order_date) values
('Amit', 'Laptop', 1, 55000, '2025-01-05'),
('Amit', 'Mouse', 2, 800, '2025-01-06'),
('Riya', 'Mobile', 1, 22000, '2025-01-10'),
('Riya', 'Headphones', 1, 2000, '2025-01-10'),
('Karan', 'Laptop', 1, 60000, '2025-02-02'),
('Karan', 'Keyboard', 1, 1500, '2025-02-05'),
('Neha', 'Mobile', 2, 21000, '2025-02-15'),
('Neha', 'Charger', 3, 900, '2025-02-18');
```

---

## **Step 3: Display All Records**

```sql
select * from customer_orders;
```
<img width="1125" height="387" alt="image" src="https://github.com/user-attachments/assets/bb8f886d-073e-4957-a41a-50968468de3e" />

---

## **Step 4: Filtering Data Using WHERE Clause**

```sql
select order_id, customer_name, product, quantity, price
from customer_orders
where price > 20000;
```
<img width="1020" height="244" alt="image" src="https://github.com/user-attachments/assets/a4da601f-3065-4b24-9193-5375702fd542" />

---

## **Step 5: Sorting Query Results**

### **Ascending Order**
```sql
select order_id, customer_name, product, quantity, price
from customer_orders
where price > 20000
order by price;
```
<img width="1013" height="242" alt="image" src="https://github.com/user-attachments/assets/1645b309-a337-42c5-bd95-ea0b2dbf800f" />

### **Descending Order**
```sql
select order_id, customer_name, product, quantity, price
from customer_orders
where price > 20000
order by price desc;
```
<img width="1005" height="236" alt="image" src="https://github.com/user-attachments/assets/2c7df3d9-182b-4ffb-a21f-7e887b700e29" />

---

## **Step 6: Grouping Data for Aggregation**

```sql
select product, count(*) as total_product_sale
from customer_orders
group by product;
```
<img width="530" height="320" alt="image" src="https://github.com/user-attachments/assets/931b4c80-7d5d-4a05-8b8a-a21df6b2d17f" />

---

## **Step 7: Applying Conditions on Aggregated Data (HAVING)**

```sql
select product,
sum(quantity*price) as total_revenue
from customer_orders
group by product
having sum(quantity*price) > 50000;
```
<img width="656" height="211" alt="image" src="https://github.com/user-attachments/assets/8be53c62-3230-4ba1-8219-7177bc58524e" />

---

## **Step 8: Using WHERE and HAVING Together**

```sql
select product, sum(quantity*price) as total_revenue
from customer_orders
where order_date >= '2025-01-01'
group by product
having sum(quantity*price) > 50000;
```
<img width="728" height="226" alt="image" src="https://github.com/user-attachments/assets/df807258-ae9f-4526-812c-edb81b12b1c0" />

---

## 📥📤 **I/O Analysis (Input / Output)**

### **Input**
- Customer order details  
- Filtering, sorting, grouping, and aggregation queries  

### **Output**
- Filtered customer records  
- Sorted result sets  
- Group-wise sales summary  
- Aggregated revenue reports  

📸 Screenshots of execution and output are attached in this repository.

---

## 📘 **Learning Outcomes**  
- Students understand how data can be filtered to retrieve only relevant records.  
- Students learn how sorting improves readability and usefulness of reports.  
- Students gain the ability to group data for analytical purposes.  
- Students clearly differentiate between WHERE and HAVING clauses.  
- Students develop confidence in writing analytical SQL queries.  
- Students are better prepared for SQL-based placement and interview questions.

---

## 📂 **Repository Contents**
- README.md  
- Worksheet (Word & PDF)  
 
- Screenshots  

---
