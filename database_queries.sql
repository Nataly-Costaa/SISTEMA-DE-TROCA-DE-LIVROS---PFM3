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
