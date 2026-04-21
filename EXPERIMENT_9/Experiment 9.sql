DROP TABLE employee CASCADE;
CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    working_hours INT,
    perhour_salary NUMERIC,
    total_payable_amount NUMERIC
);


CREATE OR REPLACE FUNCTION CALCULATE_PAYABLE_AMOUNT() RETURNS TRIGGER
AS
$$
  BEGIN
		NEW.total_payable_amount:=NEW.perhour_salary*New.working_hours;

		IF NEW.total_payable_amount>25000 THEN
		RAISE EXCEPTION 'INVALID ENTRY BECAUSE PAYABLE AMOUNT CAN NOT BE GREATER THAN 25000';
		END IF;

		RETURN NEW;
   END;

$$ LANGUAGE PLPGSQL;





CREATE OR REPLACE TRIGGER automated_payable_amount_calculation
    BEFORE INSERT ON employee
    FOR EACH ROW
    EXECUTE FUNCTION calculate_payable_amount();


INSERT INTO employee (emp_id, emp_name, working_hours, perhour_salary)
VALUES (1, 'AKASH', 10, 1000);
