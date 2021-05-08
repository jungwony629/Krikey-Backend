-------------- INITIALIZE TABLES --------------
DROP TABLE IF EXISTS sale_items CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS authors CASCADE;

CREATE TABLE authors
(
    id            serial PRIMARY KEY,
    name          text,
    date_of_birth timestamp
);
CREATE TABLE books
(
    id        serial PRIMARY KEY,
    author_id integer REFERENCES authors (id),
    isbn      text
);
CREATE TABLE sale_items
(
    id            serial PRIMARY KEY,
    book_id       integer REFERENCES books (id),
    customer_name text,
    item_price    money,
    quantity      int
);

-------------- CREATE FUNCTIONS --------------
CREATE OR REPLACE FUNCTION random_between(low INT, high INT)
    RETURNS INT AS
$$
BEGIN
    RETURN random() * (high - low + 1) + low;
END;
$$ LANGUAGE 'plpgsql' STRICT;

CREATE OR REPLACE FUNCTION get_top_10_authors_by_name(name_pattern VARCHAR)
    RETURNS TABLE
            (
                name  text,
                total money
            )
AS
$$
BEGIN
    IF name_pattern != '' THEN
        RETURN QUERY
            SELECT a.name, SUM(c.item_price * c.quantity) total
            FROM sale_items c
                     JOIN books b
                     JOIN authors a on a.id = b.author_id AND a.name = name_pattern
                          ON b.id = c.book_id
            GROUP BY a.id
            ORDER BY total DESC
            LIMIT 10;
    ELSE
        RETURN QUERY
            SELECT a.name, SUM(c.item_price * c.quantity) total
            FROM sale_items c
                     JOIN books b
                     JOIN authors a on a.id = b.author_id
                          ON b.id = c.book_id
            GROUP BY a.id
            ORDER BY total DESC
            LIMIT 10;
    END IF;
END;
$$ LANGUAGE 'plpgsql' STRICT;

-- SELECT * FROM get_top_10_authors_by_name('');

-------------- CREATE TESTDATASETS --------------
INSERT
INTO authors(name, date_of_birth)
VALUES ('Lorelai Gilmore', now() - INTERVAL '1 DAYS'),
       ('James Smith', now() - INTERVAL '2 DAYS'),
       ('Michael Smith', now() - INTERVAL '3 DAYS'),
       ('Robert Smith', now() - INTERVAL '4 DAYS'),
       ('Maria Garcia', now() - INTERVAL '5 DAYS'),
       ('David Smith', now() - INTERVAL '6 DAYS'),
       ('Maria Rodriguez', now() - INTERVAL '7 DAYS'),
       ('Mary Smith', now() - INTERVAL '8 DAYS'),
       ('Maria Hernandez', now() - INTERVAL '9 DAYS'),
       ('Maria Martinez', now() - INTERVAL '10 DAYS'),
       ('James Johnson', now() - INTERVAL '11 DAYS');

INSERT INTO books(author_id, isbn)
SELECT floor(random_between(1, 10)), md5(RANDOM()::TEXT)
FROM generate_series(0, 1000);

INSERT INTO sale_items(book_id, customer_name, item_price, quantity)
SELECT floor(random_between(1, 1000)),
       md5(RANDOM()::TEXT),
       random() * 10::MONEY,
       floor(random_between(1, 500))
FROM generate_series(0, 1000000);
