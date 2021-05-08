--1. Who are the first 10 authors ordered by date_of_birth?
SELECT id, name, to_char(date_of_birth, 'yyyy-mm-dd') date_of_birth
FROM authors
ORDER BY date_of_birth
LIMIT 10;

--2. What is the sales total for the author named “Lorelai Gilmore”?
SELECT a.name, SUM(c.item_price * c.quantity) total
FROM sale_items c
         JOIN books b
         JOIN authors a ON a.name = 'Lorelai Gilmore' AND a.id = b.author_id ON b.id = c.book_id
GROUP BY a.name;

--3. What are the top 10 performing authors, ranked by sales revenue?
SELECT a.name
FROM sale_items c
         JOIN books b
         JOIN authors a on a.id = b.author_id ON b.id = c.book_id
GROUP BY a.id
ORDER BY SUM(c.item_price * c.quantity) DESC
LIMIT 10