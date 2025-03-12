-- Consultando

-- Luiz Vinicius
-- Seleciona a quantidade trocas por método de envio
SELECT 
	CASE 
		WHEN form_of_swap = 'presencial' THEN 'Entregue presencialmente'
        WHEN form_of_swap = 'envio' THEN 'Entregue via transportadora'
          END AS form_of_swap,
COUNT(*) AS number_exchanges
FROM exchange
GROUP BY form_of_swap;

-- conta quantos livros foram publicados em cada decada
SELECT CONCAT(FLOOR(YEAR(publication_date) / 10) * 10) AS decade, COUNT(*) AS number_books
FROM book
GROUP BY decade
ORDER BY decade;

-- lista os livros que nunca foram trocados
SELECT b.title, b.author
FROM book b
LEFT JOIN exchange e ON b.id_book = e.offered_book_id OR b.id_book = e.received_book_id
WHERE e.id_exchange IS NULL;


-- João Pedro 
-- Conta quantos livros existem em cada mudança de posse
SELECT status, COUNT(*) AS total_books
FROM owner_history
GROUP BY status;

-- Conta o total de livros disponíveis por cada user
SELECT user.first_name, user.last_name, COUNT(*) AS total_books_available
FROM user
JOIN book ON book.id_user = user.id_user
WHERE book.available = TRUE
GROUP BY user.id_user
ORDER BY total_books_available DESC;

-- Conta o quantos livros foram publicados antes de 1900, entre 1900 e 1999, e nos anos 2000
SELECT 
    CASE 
        WHEN publication_date < '1900-01-01' THEN 'Antes de 1900'
        WHEN publication_date BETWEEN '1900-01-01' AND '1999-12-31' THEN '1900-1999'
        ELSE 'Anos 2000'
    END AS year,
    COUNT(*) AS number_books
FROM book
GROUP BY year;

-- lista os usuarios que mais realizaram trocas
SELECT u.first_name, u.last_name, COUNT(e.id_exchange) AS number_trades
FROM user u
JOIN exchange e ON u.id_user = e.offerer_user_id OR u.id_user = e.receiver_user_id
GROUP BY u.first_name, u.last_name
ORDER BY number_trades DESC;

-- lista as cidades com mais usuarios cadastrados
SELECT location, COUNT(*) AS number_users
FROM user
GROUP BY location
ORDER BY number_users DESC
LIMIT 10;

-- busca os usuários que possuem livros da mesma categoria que outro usuario
SELECT 
    CONCAT(u1.first_name, ' ', u1.last_name) AS first_user,
    CONCAT(u2.first_name, ' ', u2.last_name) AS last_user,
    b.category
FROM book b
JOIN user u1 ON b.id_user = u1.id_user
JOIN book b2 ON b.category = b2.category AND b.id_user <> b2.id_user
JOIN user u2 ON b2.id_user = u2.id_user
GROUP BY first_user, last_user, b.category;
