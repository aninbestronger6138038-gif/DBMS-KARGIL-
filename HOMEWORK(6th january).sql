CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100) NOT NULL,
    available_copies INT CHECK (available_copies >= 0)
);

CREATE TABLE members (
    member_id INT PRIMARY KEY,
    member_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

CREATE TABLE book_issue (
    issue_id INT PRIMARY KEY,
    book_id INT REFERENCES books(book_id),
    member_id INT REFERENCES members(member_id),
    issue_date DATE,
    return_date DATE
);

INSERT INTO books VALUES
(1, 'DBMS Concepts', 'Silberschatz', 5),
(2, 'Operating System', 'Galvin', 3);



INSERT INTO members VALUES
(101, 'Amit Kumar', 'amit@gmail.com'),
(102, 'Neha Sharma', 'neha@gmail.com');

-- BOOK ISSUE
INSERT INTO book_issue(issue_id,book_id,member_id,issue_date,
return_date)
VALUES
(1001, 1, 101, '2025-01-10', NULL);


SELECT * FROM books;
SELECT * FROM book_issue;

CREATE ROLE LIBRARIAN1
WITH LOGIN PASSWORD 'Anin#1';
GRANT  SELECT ON book_issue TO LIBRARIAN1


