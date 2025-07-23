-- COMP3311 25T2 Week 07-- Constraints, Triggers, and Aggregates
-- Schema:-- Employee(id INTEGER, name TEXT, works_in INTEGER, salary INTEGER, ...)-- Department(id INTEGER, name TEXT, manager INTEGER, ...)-- works_in is a foreign key to Department(id)-- manager is a foreign key to Employee(id)
-- Q2: Write an assertion to ensure that each manager also works in the department they manage.create assertion manager_works_in_departmentcheck  (not exists (select * from employee e join depratment d on e.id = d.manager where e.works_in <> d.id));-- Q3: Write an assertion to ensure that no employee in a department earns more than the manager.create assertion employee_manager_salarycheck  (not exists (select * from employee e join department d on d.id=e.works_in where e.salary > (select salary from employees where id = d.manager)));-- Q4: What is the SQL command to define a trigger in PostgreSQL?-- And what is the command to remove it?

-- Q5: Triggers can be BEFORE or AFTER. What are they before or after?


-- Q6: Give examples when you might use BEFORE and AFTER triggers-- an INSERT operation:-- BEFORE:
-- AFTER:
-- an UPDATE operation:-- BEFORE:
-- AFTER:
-- a DELETE operation:-- BEFORE:
-- AFTER:

-- Q7: Given schema:-- R(a INT, b INT, c TEXT, PRIMARY KEY(a,b));-- S(x INT PRIMARY KEY, y INT);-- T(j INT PRIMARY KEY, k INT REFERENCES S(x));
-- State how you could use triggers to implement the following constraint checking:-- a) primary key constraint on Rcreate trigger pk_check_R before insert or update on R execute procedure pk_R();
create or replace function pk_R() returns trigger as $$begin    if (new.a is null or new.b is null) then        raise exception 'Partial key not allowed'    end if    if TG_OP = 'UDPATE' and old.a=new.a and old.b=new.b then        return;    end if    select * from R where a = new.a and b = new.b    if found then        raise exception 'Not unique'    end ifend;$$ language plpgsql;
-- b) foreign key constraint between T.k and S.xcreate trigger fk_check before insert or update on T for each row execute procedure fk_check_T();
create trigger fk_delete before update or delete on S for each rom execute procedure fk_check_S();
create or replace function fk_check_T() returns trigger as $$begin    select * from S where x = new.k;    if (not found) then        raise exception    end if;end;$$ language plpgsql;
create or replce function fk_check_S() returns trigger as $$begin    select k from T where k = old.x;    if (found) then        raise exception    end if;end;$$ language plpgsql;


-- Q8: Explain difference between these two triggers:

-- Q9: What problems might be caused by these triggers?
-- Q10: Given:-- Emp(empname TEXT, salary INTEGER, last_date TIMESTAMP, last_usr TEXT)-- Define a trigger that on INSERT or UPDATE:-- - Sets current username and time-- - Checks empname is provided-- - Salary is positive
insert into Emp(empname, salary) values (('alls',5-),()'Joe', 100000)
create trigger update_employee before insert or update on Emp for each row execute procedure upd_Emp();
create or replace function upd_Emp() returns trigger as $$begin    if new.empname is null then        raise exception    end if;    if new.salary < 0 then        raise exception    end if;    new.last_date := now()    new.last_usr := user();    return new;end;$$ language plpgsql;






-- Q11: Enrolment(course CHAR(8), sid INTEGER, mark INTEGER)--        Course(code CHAR(8), lic TEXT, quota INTEGER, numStudes INTEGER)-- Define triggers to:-- - Keep numStudes in Course in sync with Enrolment count-- - Reject new Enrolment if quota would be exceededcreate trigger quota_chk before update or insert on Enrolment for each row execute procedure chk_quota();
create or replace function chk_quota() as $$begin    if (select numStudes >= quota from Course where code = new.course) then        raise exception ' quota exceeded';    end if;end;$$ language plpgsql;
create trigger update_students after insert or update or delete on enrolment for each row execute procedure update_Stu();
create or replace function update_Stu() reutrns trigger as $$begin    if TG_OP = 'INSERT'then        update course set numStudes := numStudes + 1 where code = new.course;        return new;    elsif TG_OP = 'DELETE' then        update course set numStudes := numStudes - 1 where code = old.course;        return old;    else         if old.course <> new.course then            update course set numStudes := numStudes + 1 where code = new.course;            update course set numStudes := numStudes - 1 where code = old.course;        end if;         return new;    end if;end;$$ language plpgsql;




-- Q12: Schema:-- Shipments(id INTEGER, customer INTEGER, isbn TEXT, ship_date TIMESTAMP)-- Editions(isbn TEXT, title TEXT, publisher INTEGER, published DATE, ...)-- Stock(isbn TEXT, numInStock INTEGER, numSold INTEGER)-- Customer(id INTEGER, name TEXT, ...)
-- Define new_shipment() function that does:-- - Validates customer and ISBN-- - INSERT: stock--, sold++-- - UPDATE: if ISBN changed, undo old stock/sold and apply new-- - Set shipment id and ship_date-- insert into Shipments(customer,isbn) values (9300035,'0-8053-1755-4');create function new_shipment() returns trigger as $$declare    new_id integer;begin    -- valid customer    select * from Customer where id = new.customer    if (not found) then        raise exception 'Not a customer'    end if;    -- valid edition    select * from Editions where isbn=new.isbn;    if (not found) then        raise exception 'Not an edition'    end if;    if TG_OP = 'INSERT' then        update stock set numInStock := numInStock - 1 where isbn = new.isbn;        update stock set numSold := numSold + 1 where isbn = new.isbn;    elsif TG_OP = 'UPDATE' and old.isbn <> new.isbn then        update stock set numInStock := numInStock - 1 where isbn = new.isbn;        update stock set numSold := numSold + 1 where isbn = new.isbn;        update stock set numInStock := numInStock + 1 where isbn = old.isbn;        update stock set numSold := numSold - 1 where isbn = old.isbn;    end if;    select max(id) + 1 into new_id from Shipments;    new.id := new_id;    new.ship_date := now();    return new;end;$$ language plpgsql;
create trigger shipment_new before insert or update on Shipments for each row execute procedure new_shipment();    

-- Q13: CREATE TABLE definition to support the above functionalityShipments(    id serial,     customer INTEGER REFERENCES Customer(id),     isbn TEXT REFERENCES editions(new_id),     ship_date TIMESTAMP default now(),)
-- Q14: PostgreSQL user-defined aggregates-- CREATE AGGREGATE AggName(BaseType) (--     stype     = ...,--     initcond  = ...,--     sfunc     = ...,--     finalfunc = ...,-- );
-- Q15: Define a user-defined aggregate 'mean' that calculates averagecreate type StateType as ( sum numeric, count numeric );
create or replace function updateState (s StateType, n numeric) returns StateType as $$begin    s.sum := s.sum + n;    s.count := s.count + 1;    return s;end;$$ language plpgsql;
create or replace function computeMean(s StateType) returns numeric as $$begin    if (s.count > 0) then
        return s.sum / s.count;    else        return null;    end if;end;$$ language plpgsql;
CREATE AGGREGATE mean(StateType) (    stype     = StateType,    initcond  = (0,0),    sfunc     = updateState,    finalfunc = computeMean,);
select mean(select age from employees);
CREATE AGGREGATE mean(numeric[]) (    stype     = numeric[],    initcond  = {},    sfunc     = updateState,    finalfunc = computeMean,);
create or replace function updateState (s numeric[], n numeric) returns StateType as $$begin    return s || n;end;$$ language plpgsql;
create or replace function computeMean(s numeric) returns numeric as $$declare    su\m     countbegin    for i in range 1..length(s) loop     add them upp
calculate herereutnr     end;$$ language plpgsql;

-- Q16: How to get mean of values without defining a custom aggregate?
select sum(a)::numeric / count(a) from table;

