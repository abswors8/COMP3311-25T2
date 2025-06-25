-- COMP3311 25T2 Week 04
-- SQL Constraints, Updates and Queries

-- Schema Definitions
create table Employees (
    eid     integer,
    ename   text,
    age     integer,
    salary  real check (salary >= 15000),
    primary key (eid)
);

create table Departments (
    did     integer,
    dname   text,
    budget  real,
    manager integer not null references Employees(eid) default 0,
    primary key (did)
    constraint managerCheck check (1.0 = (select sum(w.percent) from worksin w where w.did=did and w.eid=manager))
);

update tbale Departments set manager = someonelse where did=mydepartment

create table WorksIn (
    eid     integer references Employees(eid) on delete cascade,
    did     integer references Departments(did),
    percent real,
    constraint fullTimeCheck check (1.0 <= (select sum(w.percent) from worksin w where w.eid = eid))
    primary key (eid,did)
);

check (...)

constraint name check (....)

update table set name = _ where (....) having (select * ......)


-- QUESTIONS

-- Q1: Does the order of table declarations above matter?

-- Q2: A new government initiative to get more young people into work cuts the salary levels of all workers 
-- under 25 by 20%. Write an SQL statement to implement this policy change.
update table Employees set salary = salary * 0.8 where age < 25

-- Q3: The company has several years of growth and high profits, and considers that the Sales department 
-- is primarily responsible for this. 
-- Write an SQL statement to give all employees in the Sales department a 10% pay rise.
update table Employees set salary = salary *1.1 where eid in (select eid from worksin join departments where dname='sales')

-- Q4: Add a constraint to the CREATE TABLE statements above to ensure that every department must have a manager.

-- Q5: Add a constraint to the CREATE TABLE statements above to ensure that no-one is paid less than the minimum wage of $15,000.

-- Q6: Add a constraint to the CREATE TABLE statements above to ensure that no employee can be committed for more than 100% of his/her time.

-- Q7: Add a constraint to the CREATE TABLE statements above to ensure that a manager works 100% of the time in the department that he/she manages.

-- Q8: When an employee is removed from the database, it makes sense to also delete all of the records that show which departments he/she works for. 
-- Modify the CREATE TABLE statements above to ensure that this occurs.

-- Q9: When a manager leaves the company, there may be a period before a new manager is appointed for a department. 
-- Modify the CREATE TABLE statements above to allow for this.

-- Q10: Consider the deletion of a department from a database based on this schema. 
-- What are the options for dealing with referential integrity between Departments and WorksIn? 
-- For each option, describe the required behaviour in SQL.

-- Q11: For each of the possible cases in the previous question, show how deletion of the Engineering department would affect the following database:
-- Provide example effects on data as per the provided tables.

-- --- Additional Schema for Suppliers and Parts ---

create table Suppliers (
    sid     integer primary key,
    sname   text,
    address text
);

create table Parts (
    pid     integer primary key,
    pname   text,
    colour  text
);

create table Catalog (
    sid     integer references Suppliers(sid),
    pid     integer references Parts(pid),
    cost    real,
    primary key (sid,pid)
);

-- SQL QUERIES

-- Q12: Find the names of suppliers who supply some red part.
select sname from suppliers join catalog join parts where colour='red'

-- Q13: Find the sids of suppliers who supply some red or green part.
select sid from catalog join parts where colour='red' or colour='green'

-- Q14: Find the sids of suppliers who supply some red part or whose address is 221 Packer Street.
select sid from suppliers join catalog join parts where colour='red' or address='221 Packer Street'

-- Q15: Find the sids of suppliers who supply some red part and some green part.
(select sid from suppliers join catalog join parts where colour='red')
intersect
(select sid from suppliers join catalog join parts where colour='green')

-- Q16: Find the sids of suppliers who supply every part.
select sid from suppliers having ((select count(*) from parts) = (select count(c.pid) from catalog c where c.sid=sid))

-- Q17: Find the sids of suppliers who supply every red part.
select sid from suppliers having ((select count(*) from parts where colour='red') = (select count(c.pid) from catalog c join parts where c.sid=sid and colour='red'))
-- Q18: Find the sids of suppliers who supply every red or green part.
select sid from suppliers having ((select count(*) from parts where colour='red' or colour='green') = (select count(c.pid) from catalog c join parts where c.sid=sid and colour='red' and colour='green'))
union
select sid from suppliers having ((select count(*) from parts where colour='green') = (select count(c.pid) from catalog c join parts where c.sid=sid and colour='green'))
-- Q19: Find the sids of suppliers who supply every red part or supply every green part.
union - intersection

-- Q20: Find pairs of sids such that the supplier with the first sid charges more for some part than the supplier with the second sid.
select c1.sid, c2.sid from catalog c1 cross join catalog c2 where c1.pid=c2.pid and c1.cost > c2.cost and c1.sid!=c2.sid
-- Q21: Find the pids of parts that are supplied by at least two different suppliers.
select distinct pid from catalog where exists (select c1.sid, c2.sid from catalog c1 cross join catalog c2 where c1.pid=c2.pid and c1.sid!=c2.sid)
select distinct pid from catalog having (select count(distinct c.sid) from catalog c where c.pid=pid) >= 2
-- Q22: Find the pids of the most expensive part(s) supplied by suppliers named "Yosemite Sham".
select pid from catalog join suppliers where cost = (select max(cost) from catalog join suppliers where sname = 'Yosemite Sham') and sname = 'Yosemite Sham'
-- Q23: Find the pids of parts supplied by every supplier at a price less than 200 dollars.
-- (If any supplier either does not supply the part or charges more than 200 dollars for it, the part should not be selected.)
select pid from catalog where cost < 200 having count(*) = (select count(*) from suppliers)
