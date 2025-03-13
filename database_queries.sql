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

-- autores com 2 ou mais livros que não foram trocados
SELECT b.author, COUNT(*) AS total_books
FROM book b
LEFT JOIN exchange e ON b.id_book = e.offered_book_id OR b.id_book = e.received_book_id
WHERE e.id_exchange IS NULL
GROUP BY b.author
HAVING total_books >= 2
ORDER BY total_books DESC;


-- Nataly
-- Mostrar apenas os primeiros nomes iguais que têm 3 ou mais pessoas
SELECT first_name, COUNT(*) AS number_user
FROM user
GROUP BY first_name
HAVING COUNT(*) >=3;

-- Conta quantos livros estão disponíveis e quantos não
SELECT 
    available, 
    COUNT(*) AS number_books
FROM book
GROUP BY available;

-- Conta quantos usuários tem o as combinações “ia”, “eu”, e quantos não tem essas combinações em seus nomes
SELECT 
    COUNT(CASE WHEN first_name LIKE '%ia%' THEN 1 END) AS total_ia,
    COUNT(CASE WHEN first_name LIKE '%eu%' THEN 1 END) AS total_eu,
    COUNT(CASE WHEN first_name NOT LIKE '%ia%' AND first_name NOT LIKE '%eu%' THEN 1 END) AS total_others
FROM user;

-- Luiza Pureza
-- Conta quantos livros tem cada estado de preservação
SELECT preservation_status, COUNT(*) AS number_books
FROM book 
GROUP BY preservation_status;

-- Conta quantos livros tem cada categoria
SELECT category, COUNT(*) AS number_books
FROM book 
GROUP BY category;

-- Conta quantos usuários moram nas cidades mais populosas do nordeste(Salvador, Fortaleza e Recife), e quantos moram em outras cidades.
SELECT 
CASE 
WHEN location IN ('Salvador', 'Fortaleza', 'Recife') THEN 'Cidades mais populosas do Nordeste'
ELSE 'Outras cidades'
END AS city,
COUNT(*) AS user_count
FROM user
GROUP BY city;

-- Luísa Silva
-- Conta quantos usuários tem o primeiro nome que começa com cada letra existente no sistema. Por exemplo: Quantos usuários começam com a letra A?
SELECT LEFT(first_name, 1) AS inicial, COUNT(*) AS total_users
FROM user
GROUP BY LEFT(first_name, 1)
ORDER BY inicial;

-- Conta quantos títulos dos livros começam com A ou O
SELECT 
    COUNT(CASE WHEN title LIKE 'A%' THEN 1 END) AS total_A_books,
    COUNT(CASE WHEN title LIKE 'O%' THEN 1 END) AS total_O_books
    FROM book;

-- Conta quantos usuários foram cadastrados por mês
SELECT
YEAR(created_at) AS year, MONTH(created_at) AS month,
COUNT(*) AS total_users
FROM user
GROUP BY YEAR(created_at), MONTH(created_at)
ORDER BY year, month;

-- Bruna Tereza
-- Conta a média das avaliações de cada usuário 
SELECT rated_user_id, AVG(score) AS average_rating
FROM user_rating
GROUP BY rated_user_id
LIMIT 10;

-- Conta quantas avaliações cada livro recebeu e sua média
SELECT book.title, COUNT(user_rating.id_rating) AS total_ratings,
AVG(user_rating.score) AS average_score
FROM book
JOIN user_rating ON book.id_book = user_rating.rated_user_id
GROUP BY book.id_book
ORDER BY total_ratings DESC
LIMIT 10;

-- Conta quantas mudanças de posse cada livro teve
SELECT book.title, COUNT(*) AS total_owner_changes
FROM book
JOIN owner_history ON book.id_book = owner_history.id_book
GROUP BY book.id_book
ORDER BY total_owner_changes DESC
LIMIT 10;