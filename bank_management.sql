CREATE DATABASE bank;
USE bank;

CREATE TABLE Branch(
	branch_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_name VARCHAR(50) NOT NULL,
    branch_address VARCHAR(100) NOT NULL,
    branch_phone_no VARCHAR(20) NOT NULL
);

desc Branch;

INSERT INTO Branch (branch_name, branch_address, branch_phone_no) 
VALUES 
    ('Downtown', '123 Main Street, New York, NY 10001', '212-555-0101'),
    ('Uptown', '456 Oak Avenue, Chicago, IL 60601', '312-555-0202'),
    ('Suburban', '789 Pine Road, Los Angeles, CA 90001', '213-555-0303'),
    ('Central', '101 Elm Street, Houston, TX 77002', '713-555-0404'),
    ('Riverside', '202 Maple Drive, Miami, FL 33101', '305-555-0505'),
    ('Hilltop', '303 Cedar Lane, Seattle, WA 98101', '206-555-0606'),
    ('Lakeside', '404 Birch Boulevard, Boston, MA 02108', '617-555-0707'),
    ('Parkway', '505 Spruce Street, Denver, CO 80202', '303-555-0808'),
    ('Westside', '606 Willow Way, San Francisco, CA 94102', '415-555-0909'),
    ('Eastend', '707 Ash Avenue, Atlanta, GA 30301', '404-555-1010');
    
SELECT * FROM Branch;
    
CREATE TABLE Customer(
	customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    Address VARCHAR(100) NOT NULL,
    phone_no VARCHAR(20) UNIQUE,
    email VARCHAR(30) UNIQUE,
    Date_of_birth DATE 
);

desc Customer;

INSERT INTO Customer (first_name, last_name, Address, phone_no, email, Date_of_birth)
VALUES 
	('John', 'Doe', '123 Main St, New York, NY 10001', '212-555-1111', 'john.doe@example.com', '1985-03-15'),
    ('Jane', 'Smith', '456 Oak Ave, Chicago, IL 60601', '312-555-2222', 'jane.smith@example.com', '1990-07-22'),
    ('Alice', 'Johnson', '789 Pine Rd, Los Angeles, CA 90001', '213-555-3333', 'alice.j@example.com', '1978-11-10'),
    ('Bob', 'Brown', '101 Elm St, Houston, TX 77002', '713-555-4444', 'bob.brown@example.com', '1982-06-05'),
    ('Emma', 'Davis', '202 Maple Dr, Miami, FL 33101', '305-555-5555', 'emma.davis@example.com', '1995-09-18'),
    ('Tom', 'Wilson', '303 Cedar Ln, Seattle, WA 98101', '206-555-6666', 'tom.wilson@example.com', '1988-12-25'),
    ('Sara', 'Lee', '404 Birch Blvd, Boston, MA 02108', '617-555-7777', 'sara.lee@example.com', '1992-04-30'),
    ('Mike', 'Taylor', '505 Spruce St, Denver, CO 80202', '303-555-8888', 'mike.taylor@example.com', '1980-01-12'),
    ('Lisa', 'Adams', '606 Willow Way, San Francisco, CA 94102', '415-555-9999', 'lisa.adams@example.com', '1987-08-08'),
    ('Peter', 'Clark', '707 Ash Ave, Atlanta, GA 30301', '404-555-0000', 'peter.clark@example.com', '1993-02-14');

select * from Customer;


CREATE TABLE Account (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    branch_id INT,
    account_type ENUM('Savings', 'Checking', 'Fixed Deposit') NOT NULL,
    balance DECIMAL(15, 2) DEFAULT 0.00,
    date_opened DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id) ON DELETE SET NULL
);

desc Account;

INSERT INTO Account (customer_id, branch_id, account_type, balance, date_opened) 
VALUES 
    (1, 1, 'Savings', 1500.75, '2024-01-15'),
    (2, 1, 'Checking', 250.30, '2024-03-22'),
    (3, 2, 'Fixed Deposit', 5000.00, '2023-11-10'),
    (4, 2, 'Savings', 3200.50, '2024-06-01'),
    (5, 3, 'Checking', 800.25, '2024-02-14'),
    (6, 3, 'Savings', 1200.00, '2024-07-19'),
    (7, 1, 'Fixed Deposit', 10000.00, '2023-12-05'),
    (8, 2, 'Checking', 450.90, '2024-04-30'),
    (9, 3, 'Savings', 2750.60, '2024-08-12'),
    (10, 1, 'Checking', 600.15, '2024-09-25');

select * from Account;

CREATE TABLE Transaction (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT,
    transaction_type ENUM('Deposit', 'Withdrawal', 'Transfer') NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(100),
    FOREIGN KEY (account_id) REFERENCES Account(account_id) ON DELETE CASCADE
);

desc Transaction;

INSERT INTO Transaction (account_id, transaction_type, amount, transaction_date, description) 
VALUES 
    (1, 'Deposit', 500.00, '2024-02-01 10:30:00', 'Salary deposit'),
    (2, 'Withdrawal', 100.00, '2024-03-25 14:15:00', 'ATM withdrawal'),
    (3, 'Deposit', 2000.00, '2024-01-15 09:00:00', 'Fixed deposit interest'),
    (4, 'Transfer', 300.50, '2024-06-10 16:45:00', 'Transfer to savings'),
    (5, 'Withdrawal', 50.25, '2024-02-20 11:20:00', 'Grocery purchase'),
    (6, 'Deposit', 400.00, '2024-07-25 13:10:00', 'Freelance payment'),
    (7, 'Transfer', 1500.00, '2024-01-10 08:30:00', 'Transfer to investment'),
    (8, 'Withdrawal', 200.90, '2024-05-05 15:00:00', 'Online shopping'),
    (9, 'Deposit', 750.60, '2024-08-15 12:00:00', 'Bonus deposit'),
    (10, 'Transfer', 300.00, '2024-09-30 17:30:00', 'Transfer to family');

select * from Transaction;

CREATE TABLE Employee (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    branch_id INT,
    position VARCHAR(50),
    hire_date DATE,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id) ON DELETE SET NULL
);

desc Employee;

INSERT INTO Employee (first_name, last_name, branch_id, position, hire_date) 
VALUES 
    ('Michael', 'Scott', 1, 'Branch Manager', '2020-05-15'),
    ('Pamela', 'Beesly', 1, 'Teller', '2021-03-22'),
    ('Dwight', 'Schrute', 2, 'Loan Officer', '2020-11-10'),
    ('Angela', 'Martin', 2, 'Accountant', '2022-06-01'),
    ('Jim', 'Halpert', 3, 'Customer Service Rep', '2021-09-14'),
    ('Kelly', 'Kapoor', 3, 'Teller', '2023-02-19'),
    ('Ryan', 'Howard', 4, 'Financial Advisor', '2020-12-05'),
    ('Erin', 'Hannon', 5, 'Teller', '2022-04-30'),
    ('Stanley', 'Hudson', 6, 'Branch Manager', '2021-08-12'),
    ('Phyllis', 'Vance', 7, 'Loan Officer', '2023-01-25');
    
select * from Employee;



