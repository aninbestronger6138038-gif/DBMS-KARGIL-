create table Department(
Dept_id int primary key,
Dept_name varchar(20) not null unique
);


create table Employee(
Emp_id int primary key ,
Emp_name varchar(20) not null,
Emp_email varchar(20) unique not null,
Emp_phone varchar(20) unique not null,
Dept_id int,
foreign key (Dept_id) references Department(Dept_id)
);

create table Project(
Proj_id integer primary key,
Proj_name varchar(20) not null,
Proj_startDate varchar(20) not null,
Proj_EndDate varchar(20) not null,
Proj_Assign_Emp int,
foreign key (Proj_Assign_Emp) references Employee(Emp_id)
);

insert into Department (Dept_id,Dept_name)
values
(1, 'Human Resources'),
(2, 'Engineering'),
(3, 'Marketing'),
(4, 'Finance');

insert into Employee (Emp_id,Emp_name,Emp_email,Emp_phone,Dept_id)
values
(101, 'Amit Sharma', 'amit@gmail.com', '9876543210', 2),
(102, 'Neha Verma', 'neha@gmail.com', '9123456780', 2),
(103, 'Rohit Singh', 'rohit@gmail.com', '9988776655', 1),
(104, 'Priya Mehta', 'priya@gmail.com', '9090909090', 3),
(105, 'Ram Sen', 'Ram@gmail.com', '555555555', 4);

insert into Project(Proj_id, Proj_name, Proj_startDate, Proj_EndDate, Proj_Assign_Emp)
values
(1, 'AI Chatbot', '2026-01-01', '2026-06-30', 101),
(2, 'E-Commerce App', '2026-02-01', '2026-07-31', 102),
(3, 'HR Portal', '2026-03-15', '2026-05-30', 103),
(4, 'Marketing Website', '2026-01-20', '2026-04-20', 104),
(5, 'Finance Website', '2025-01-20', '2026-04-20', 105);

update Employee set Dept_id=4 where Emp_id=103;

delete from Project where Proj_Assign_Emp=105;
delete from Employee where Emp_id=105;

create role CEO login password 'CEO';

grant select on Employee, Department, Project to CEO;

revoke select on Department from CEO;

alter table Employee add Address varchar(30);

drop table Project;