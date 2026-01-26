# **DBMS Lab – Worksheet 1**  
## **Design and Implementation of Sample Database System using DDL, DML and DCL**

---

## 👨‍🎓 **Student Details**  
**Name:** Anindita Dhar  
**UID:** 25MCA20259  
**Branch:** MCA(GENERAL)  
**Semester:** 2nd  
**Section/Group:** 1/A  
**Subject:** TECHNICAL TRAINING 
**Date of Performance:** 06/01/2026  

---

## 🎯 **Aim**  
To design and implement a sample database system using DDL, DML, and DCL commands for managing departments, employees, and projects, and to apply role-based access control for secure data handling.

---
## 💻 **Software Requirements**

- PostgreSQL (Database Server)  
- pgAdmin
- Windows Operating System  

---
## 📌 **Objective**  
- To understand the use of DDL commands to create and modify database structures.  
- To perform DML operations such as INSERT, UPDATE, DELETE, and SELECT.  
- To implement relationships using primary and foreign keys.  
- To apply DCL commands to manage roles and privileges.  
- To analyze input and output of SQL queries in a real database environment.  

---

## 🛠️ **Practical / Experiment Steps**  
- Design the database schema for Department, Employee, and Project tables.  
- Create tables using appropriate constraints.  
- Insert sample records into tables.  
- Perform update and delete operations.  
- Retrieve data using SELECT queries.  
- Create a role and grant and revoke privileges.  
- Alter and drop database objects.  

---

## 🗄️ **Database Design**  

The database is designed to manage Departments, Employees, and Projects within an organization.

### **Tables**  
- Department  
- Employee  
- Project  

### **Constraints Used**  
- PRIMARY KEY – to uniquely identify each record  
- FOREIGN KEY – to maintain relationships between tables  
- NOT NULL – to avoid missing important values  
- UNIQUE – to prevent duplicate entries  

---
# ⚙️ **Procedure**

# ⚙️ **Step 1: Table Creation (DDL)**  

### **Department Table**
```sql
create table Department(
Dept_id int primary key,
Dept_name varchar(20) not null unique
);
```

### **Employee Table**
```sql
create table Employee(
Emp_id int primary key ,
Emp_name varchar(20) not null,
Emp_email varchar(20) unique not null,
Emp_phone varchar(20) unique not null,
Dept_id int,
foreign key (Dept_id) references Department(Dept_id)
);
```

### **Project Table**
```sql
create table Project(
Proj_id integer primary key,
Proj_name varchar(20) not null,
Proj_startDate varchar(20) not null,
Proj_EndDate varchar(20) not null,
Proj_Assign_Emp int,
foreign key (Proj_Assign_Emp) references Employee(Emp_id)
);
```

---

# 🧾 **Step 2: Data Manipulation (DML)**  

### **Insert into Department**
```sql
insert into Department (Dept_id,Dept_name)
values
(1, 'Human Resources'),
(2, 'Engineering'),
(3, 'Marketing'),
(4, 'Finance');
```
<img width="613" height="347" alt="image" src="https://github.com/user-attachments/assets/9a2fa0fc-e3d9-4a69-99ca-b0863338a475" />

### **Insert into Employee**
```sql
insert into Employee (Emp_id,Emp_name,Emp_email,Emp_phone,Dept_id)
values
(101, 'Amit Sharma', 'amit@gmail.com', '9876543210', 2),
(102, 'Neha Verma', 'neha@gmail.com', '9123456780', 2),
(103, 'Rohit Singh', 'rohit@gmail.com', '9988776655', 1),
(104, 'Priya Mehta', 'priya@gmail.com', '9090909090', 3),
(105, 'Ram Sen', 'Ram@gmail.com', '555555555', 4);
```
<img width="1064" height="273" alt="image" src="https://github.com/user-attachments/assets/b1d45099-8e57-41cf-84dd-41f46aae56bd" />

### **Insert into Project**
```sql
insert into Project(Proj_id, Proj_name, Proj_startDate, Proj_EndDate, Proj_Assign_Emp)
values
(1, 'AI Chatbot', '2026-01-01', '2026-06-30', 101),
(2, 'E-Commerce App', '2026-02-01', '2026-07-31', 102),
(3, 'HR Portal', '2026-03-15', '2026-05-30', 103),
(4, 'Marketing Website', '2026-01-20', '2026-04-20', 104),
(5, 'Finance Website', '2025-01-20', '2026-04-20', 105);
```
<img width="1125" height="270" alt="image" src="https://github.com/user-attachments/assets/3bf0fb00-0831-49ef-98b4-90acd17cf098" />

---

# ✏️ **Step 3: UPDATE Operation**  
```sql
update Employee set Dept_id=4 where Emp_id=103;
```
<img width="681" height="175" alt="image" src="https://github.com/user-attachments/assets/44bc8930-5e9f-4e41-a680-4ae90e679b03" />

---

# 🗑️ **Step 4: DELETE Operations**  

(Employee 105 was assigned to a project, so the project record was deleted first.)

```sql
delete from Project where Proj_Assign_Emp=105;
delete from Employee where Emp_id=105;
```
<img width="1125" height="236" alt="image" src="https://github.com/user-attachments/assets/5f1dfd6d-a0d4-4397-83ce-2ef5fec265dc" />
<img width="1061" height="239" alt="image" src="https://github.com/user-attachments/assets/2053e1d5-f20f-4b3a-bd82-0d57519f2a28" />

---

# 🔐 **Step 5: Create Role and Assign Privileges**

### **Create Role**
```sql
create role CEO login password 'CEO';
```
<img width="834" height="502" alt="image" src="https://github.com/user-attachments/assets/cbac5c37-f9b3-42e7-bcfa-e16e31f0098b" />
<img width="883" height="59" alt="image" src="https://github.com/user-attachments/assets/f486ad9e-05a9-4967-b3c9-7218ee585537" />

### **Grant SELECT Privileges**
```sql
grant select on Employee, Department, Project to CEO;
```

### **Revoke Privilege**
```sql
revoke select on Department from CEO;
```

---

# 🏗️ **Step 6: Schema Modification**

### **Add Column**
```sql
alter table Employee add Address varchar(30);
```
<img width="1125" height="205" alt="image" src="https://github.com/user-attachments/assets/f6187e70-e176-4308-a0c0-d9219ad9ce5d" />

### **Drop Table**
```sql
drop table Project;
```
<img width="541" height="227" alt="image" src="https://github.com/user-attachments/assets/70c9e752-6f25-4932-a467-1ce1ab9d1d2b" />

---
## 📥📤 I/O Analysis (Input / Output)

### 🔹 Input
- Department, Employee, and Project table creation queries  
- Records inserted into all tables using INSERT commands  
- Update query to modify employee department  
- Delete queries to remove project and employee records  
- Role creation and privilege assignment queries  
- ALTER and DROP table commands  

### 🔹 Output
- Department, Employee, and Project tables created successfully  
- Records inserted, updated, and deleted correctly  
- Referential integrity maintained between tables  
- Data displayed correctly using SELECT queries  
- Role-based access verified using GRANT and REVOKE  
- Table structure modified and Project table dropped successfully  

📸 Screenshots of execution and obtained results are attached.

---

## 📘 **Learning Outcomes**  
- Understood the basics of relational database design using tables, keys, and relationships.  
- Learned to apply primary and foreign key constraints to maintain data integrity.  
- Gained hands-on experience with INSERT, UPDATE, and DELETE operations.  
- Understood role-based access control using GRANT and REVOKE.  
- Learned how to create read-only users for secure data access.  
- Practiced ALTER TABLE and DROP TABLE commands for schema management.  

---
