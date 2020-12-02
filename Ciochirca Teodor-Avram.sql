DROP DATABASE CS_STORE;
CREATE DATABASE CS_Store;
USE CS_Store;

CREATE TABLE Customers(
birth_day DATE,
first_name VARCHAR(20),
last_name VARCHAR(20),
c_id INT,
CONSTRAINT PK_customers PRIMARY KEY (c_id)
);

CREATE TABLE Employees(
birth_day DATE,
first_name VARCHAR(20),
last_name VARCHAR(20),
e_id INT,
CONSTRAINT PK_employees PRIMARY KEY (e_id)
);

CREATE TABLE Transactions(
e_id INT,
c_id INT,
date DATE,
t_id INT,
CONSTRAINT PK_transactions PRIMARY KEY (t_id),
CONSTRAINT FK_employees FOREIGN KEY (e_id)
REFERENCES Employees (e_id),
CONSTRAINT FK_customers FOREIGN KEY (c_id)
REFERENCES Customers (c_id)
);

CREATE TABLE Items(
price_for_each INT,
amount INT,
name VARCHAR(20),
CONSTRAINT PK_items PRIMARY KEY (name)
);

CREATE TABLE Promotions(
discount INT,
p_id INT,
CONSTRAINT PK_promotions PRIMARY KEY (p_id)
);

CREATE TABLE ItemsInPromotions(
name VARCHAR(20),
p_id INT,
amount INT,
CONSTRAINT FK_items FOREIGN KEY (name)
REFERENCES Items (name),
CONSTRAINT FK_promotions FOREIGN KEY (p_id)
REFERENCES Promotions (p_id)
);

CREATE TABLE ItemsInTransactions(
name VARCHAR(20),
t_id INT,
amount INT,
CONSTRAINT FK_items2 FOREIGN KEY (name)
REFERENCES Items (name),
CONSTRAINT FK_transactions2 FOREIGN KEY (t_id)
REFERENCES Transactions (t_id)
);

-- Data for Customers(birth_day, first_name, last_name, c_id)
INSERT INTO Customers VALUES ('1993-07-11','Victor','Davis',1);
INSERT INTO Customers VALUES ('2001-03-28','Katarina','Williams',2);
INSERT INTO Customers VALUES ('1965-12-11','David','Jones',3);
INSERT INTO Customers VALUES ('1980-10-10','Evelyn','Lee',4);
-- Data for Employees(birth_day, first_name, last_name, e_id)
INSERT INTO Employees VALUES ('1983-09-02','David','Smith',1);
INSERT INTO Employees VALUES ('1990-07-23','Olivia','Brown',2);
INSERT INTO Employees VALUES ('1973-05-11','David','Johnson',3);
INSERT INTO Employees VALUES ('1999-11-21','Mia','Taylor',4);
-- Data for Transactions(e_id*, c_id*, date, t_id)
INSERT INTO Transactions VALUES (1,1,'2020-8-11',1);
INSERT INTO Transactions VALUES (3,1,'2020-8-15',2);
INSERT INTO Transactions VALUES (1,4,'2020-9-01',3);
INSERT INTO Transactions VALUES (2,2,'2020-9-07',4);
INSERT INTO Transactions VALUES (4,3,'2020-9-07',5);
-- Data for Items(price_for_each, amount, name)
INSERT INTO Items VALUES (110,22,'2l of milk');
INSERT INTO Items VALUES (99,30,'6 cans of lemonade');
INSERT INTO Items VALUES (150,20,'Pack of butter');
INSERT INTO Items VALUES (450,13,'Roast chicken');
INSERT INTO Items VALUES (99,30,'Pack of rice');
INSERT INTO Items VALUES (20,50,'Banana');
INSERT INTO Items VALUES (200,30,'3kg sugar');
INSERT INTO Items VALUES (150,15,'Toast bread');
INSERT INTO Items VALUES (150,18,'Earl Grey tea');
-- Data for Promotions(discount, p_id)
INSERT INTO Promotions VALUES (99,1);
INSERT INTO Promotions VALUES (200,2);
INSERT INTO Promotions VALUES (150,3);
INSERT INTO Promotions VALUES (150,4);
-- Data for ItemsInPromotions(name*, p_id*, amount)
INSERT INTO ItemsInPromotions VALUES ('6 cans of lemonade',1,2);
INSERT INTO ItemsInPromotions VALUES ('Roast chicken',2,1);
INSERT INTO ItemsInPromotions VALUES ('Pack of rice',2,1);
INSERT INTO ItemsInPromotions VALUES ('Pack of butter',3,1);
INSERT INTO ItemsInPromotions VALUES ('Toast bread',3,2);
INSERT INTO ItemsInPromotions VALUES ('2l of milk',4,2);
INSERT INTO ItemsInPromotions VALUES ('Banana',4,3);
INSERT INTO ItemsInPromotions VALUES ('3kg sugar',4,2);
-- Data for ItemsInTransactions(name*, t_id*, amount)
INSERT INTO ItemsInTransactions VALUES ('6 cans of lemonade',1,1);
INSERT INTO ItemsInTransactions VALUES ('Roast chicken',1,1);
INSERT INTO ItemsInTransactions VALUES ('Pack of butter',1,1);
INSERT INTO ItemsInTransactions VALUES ('Toast bread',1,1);
INSERT INTO ItemsInTransactions VALUES ('2l of milk',1,2);
INSERT INTO ItemsInTransactions VALUES ('Banana',1,3);
INSERT INTO ItemsInTransactions VALUES ('3kg sugar',1,1);
INSERT INTO ItemsInTransactions VALUES ('6 cans of lemonade',2,5);
INSERT INTO ItemsInTransactions VALUES ('Pack of rice',2,1);
INSERT INTO ItemsInTransactions VALUES ('6 cans of lemonade',3,3);
INSERT INTO ItemsInTransactions VALUES ('Roast chicken',3,2);
INSERT INTO ItemsInTransactions VALUES ('Pack of rice',3,1);
INSERT INTO ItemsInTransactions VALUES ('Pack of butter',3,1);
INSERT INTO ItemsInTransactions VALUES ('2l of milk',4,5);
INSERT INTO ItemsInTransactions VALUES ('Banana',4,20);
INSERT INTO ItemsInTransactions VALUES ('3kg sugar',4,8);
INSERT INTO ItemsInTransactions VALUES ('6 cans of lemonade',5,10);
INSERT INTO ItemsInTransactions VALUES ('Roast chicken',5,10);
INSERT INTO ItemsInTransactions VALUES ('Pack of rice',5,10);
INSERT INTO ItemsInTransactions VALUES ('Pack of butter',5,10);
INSERT INTO ItemsInTransactions VALUES ('Toast bread',5,10);
INSERT INTO ItemsInTransactions VALUES ('2l of milk',5,10);
INSERT INTO ItemsInTransactions VALUES ('Banana',5,10);
INSERT INTO ItemsInTransactions VALUES ('3kg sugar',5,10);
INSERT INTO ItemsInTransactions VALUES ('Earl Grey tea',5,10);

CREATE VIEW DavidSoldTo AS
SELECT DISTINCT birth_day, first_name, last_name FROM Customers
WHERE c_id IN (SELECT c_id FROM Employees NATURAL JOIN Transactions WHERE first_name='David')
GROUP BY birth_day;

-- SELECT * FROM DavidSoldTo;

CREATE VIEW PeopleInShop AS
SELECT DISTINCT birth_day, first_name, last_name FROM Customers
WHERE c_id IN (SELECT c_id FROM Customers NATURAL JOIN Transactions WHERE date='2020-09-07')
UNION
SELECT DISTINCT birth_day, first_name, last_name FROM Employees
WHERE e_id in (SELECT e_id FROM Employees NATURAL JOIN Transactions WHERE date='2020-09-07')
ORDER BY birth_day;

-- SELECT * FROM PeopleInShop;

CREATE VIEW Intermediate AS
SELECT DISTINCT I.name as name, I.amount AS amount_initial, SUM(IT.amount) AS amount_sold FROM Items I, ItemsInTransactions IT
WHERE I.name=IT.name
GROUP BY name;

CREATE VIEW ItemsLeft AS
SELECT name, amount_initial-amount_sold AS amount_left
FROM Intermediate;

-- SELECT * FROM ItemsLeft;

CREATE VIEW PromotionItemsSatisfiedByTransactions AS
SELECT T.t_id, IP.p_id, IP.name, FLOOR(IF (IT.amount IS NULL, 0, IT.amount)/IP.amount) AS number_of_times FROM `ItemsInPromotions` AS IP
LEFT JOIN Transactions AS T ON 1
LEFT JOIN ItemsInTransactions AS IT ON IP.name = IT.name AND T.t_id = IT.t_id
ORDER BY T.t_id, IP.p_id, IP.name;

-- SELECT * FROM PromotionItemsSatisfiedByTransactions;

CREATE VIEW TransactionsWithoutDiscounts AS
SELECT T.t_id, SUM(IT.amount*price_for_each) AS total
FROM Transactions T
LEFT JOIN ItemsInTransactions IT
ON T.t_id=IT.t_id
LEFT JOIN Items I
ON IT.name=I.name
GROUP BY T.t_id
ORDER BY IT.t_id;

-- SELECT * FROM TransactionsWithDiscounts;

SELECT T.t_id, SUM(IF (IT.amount IS NULL, 0, IT.amount)*I.price_for_each)-(FLOOR(IF (IT.amount IS NULL, 0, IT.amount)/IP.amount))*P.discount AS transaction_total
FROM ItemsInPromotions AS IP
LEFT JOIN Promotions AS P ON IP.p_id=P.p_id
LEFT JOIN Transactions AS T ON 1
LEFT JOIN ItemsInTransactions AS IT ON IP.name=IT.name AND T.t_id=IT.t_id
INNER JOIN Items AS I ON IP.name=I.name
GROUP BY T.t_id
ORDER BY T.t_id, IP.p_id, IP.name;

CREATE VIEW LAA AS
SELECT t_id, p_id, MIN(number_of_times) AS minim FROM PromotionItemsSatisfiedByTransactions GROUP BY t_id, p_id;

CREATE VIEW PriceOfTransaction AS
SELECT TD.t_id, total, total-SUM(discount*minim) AS pret
FROM TransactionsWithoutDiscounts TD
LEFT JOIN LAA L
ON L.t_id=TD.t_id
LEFT JOIN Promotions P
ON L.p_id=P.p_id
GROUP BY t_id;