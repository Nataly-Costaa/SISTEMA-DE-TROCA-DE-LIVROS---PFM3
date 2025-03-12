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


