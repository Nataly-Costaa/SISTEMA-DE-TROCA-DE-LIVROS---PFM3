CREATE DATABASE exchange_books;
USE exchange_books;

-- criando tabelas
CREATE TABLE user (
	id_user INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    email VARCHAR(100) UNIQUE,
    location VARCHAR(100),
    phone_number VARCHAR(15),
    password VARCHAR(30),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE book(
id_book INT AUTO_INCREMENT PRIMARY KEY,
id_user INT NOT NULL,
title VARCHAR(100) NOT NULL, 
author VARCHAR(60),
category VARCHAR(50) NOT NULL,
preservation_status ENUM('Novo','Usado','Desgastado') NOT NULL,
publication_date DATE,
synopsis TEXT NOT NULL,
user_review TEXT NOT NULL,
publisher VARCHAR(100),
avalible BOOLEAN NOT NULL,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
FOREIGN KEY (id_user) REFERENCES user(id_user)
);

CREATE TABLE exchange (
id_exchange INT AUTO_INCREMENT PRIMARY KEY,
offered_book_id INT NOT NULL, -- o livro oferecido
received_book_id INT NOT NULL, -- o livro que desejado
offerer_user_id INT NOT NULL, -- dono do livro oferecido
receiver_user_id INT NOT NULL, -- dono do livro desejado
form_of_swap ENUM ("envio","presencial"),
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
FOREIGN KEY (offered_book_id) REFERENCES book(id_book),
FOREIGN KEY (received_book_id) REFERENCES book(id_book),
FOREIGN KEY (offerer_user_id) REFERENCES user(id_user),
FOREIGN KEY (receiver_user_id) REFERENCES user(id_user)
);

CREATE TABLE literaly_group (
id_group INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR (100),
description TEXT (900),
id_book INT,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
FOREIGN KEY (id_book) references book (id_book)
);

CREATE TABLE owner_history (
  id_owner INT AUTO_INCREMENT PRIMARY KEY,
  id_book INT NOT NULL,
  id_user INT NOT NULL,
  date_of_acquisition TIMESTAMP NOT NULL,
  exchange_date TIMESTAMP NULL,
  status ENUM('Em posse', 'Trocado', 'Doado', 'Perdido'),
  end_date TIMESTAMP NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  FOREIGN KEY (id_book) REFERENCES book (id_book),
  FOREIGN KEY (id_user) REFERENCES user (id_user)
);

CREATE TABLE exchange_history(
id_exchange_history INT AUTO_INCREMENT PRIMARY KEY,
id_exchange INT NOT NULL,
status ENUM ("pendente", "concluída", "cancelada") NOT NULL,
observations TEXT,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
FOREIGN KEY (id_exchange) REFERENCES exchange (id_exchange)
);

CREATE TABLE user_rating(
id_rating INT AUTO_INCREMENT PRIMARY KEY,
rater_user_id INT NOT NULL,
rated_user_id INT NOT NULL,
score INT CHECK(score BETWEEN 1 AND 5),
comment TEXT,
created_at TIMESTAMP NOT NULL,
updated_at TIMESTAMP NOT NULL,
FOREIGN KEY(rater_user_id) REFERENCES user(id_user),
FOREIGN KEY(rated_user_id) REFERENCES user(id_user)
);

CREATE TABLE user_group (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT NOT NULL,
    id_group INT NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES user(id_user),
    FOREIGN KEY (id_group) REFERENCES literary_group(id_group)
);

-- corrigindo
ALTER TABLE book CHANGE avalible available BOOLEAN NOT NULL;
ALTER TABLE literaly_group CHANGE name group_name VARCHAR (100);
RENAME TABLE literaly_group TO literary_group;

-- excluindo os dados da tabela user para os inserir em uma transaction
SET foreign_key_checks = 0;
TRUNCATE user;
SET foreign_key_checks = 1;

-- inserindo dados
-- criando trigerrs para tabelas de historico
DELIMITER $$
CREATE TRIGGER insert_exchange_history
AFTER INSERT ON exchange
FOR EACH ROW
BEGIN
-- insere automaticamente no historico de trocas
INSERT INTO exchange_history (id_exchange, status, created_at, updated_at)
    VALUES (NEW.id_exchange, 'pendente', NOW(), NOW());
END $$

DELIMITER $$
CREATE TRIGGER insert_owner_history
AFTER INSERT ON book
FOR EACH ROW
BEGIN
-- insere o historico do dono de livro
INSERT INTO owner_history(id_book, id_user, date_of_acquisition, status, created_at, updated_at)
VALUES(NEW.id_book, NEW.id_user, NOW(), 'Em posse', NOW(), NOW());
END $$

DELIMITER $$
CREATE TRIGGER insert_owner_history_on_update
AFTER UPDATE ON book
FOR EACH ROW
BEGIN
IF NEW.id_user != OLD.id_user THEN
-- insere o histórico de posse do livro para o novo dono
INSERT INTO owner_history(id_book, id_user, date_of_acquisition, status, created_at, updated_at)
VALUES(NEW.id_book, NEW.id_user, NOW(), 'Em posse', NOW(), NOW());
-- atualiza o status do dono anterior para "Trocado"
UPDATE owner_history
SET status = 'Trocado', end_date = NOW(), updated_at = NOW()
WHERE id_book = NEW.id_book AND id_user = OLD.id_user AND end_date IS NULL;
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_user(
IN p_first_name VARCHAR(30),
IN p_last_name VARCHAR(80),
IN p_email VARCHAR(100),
IN p_location VARCHAR(100),
IN p_phone_number VARCHAR(15),
IN p_password VARCHAR(30)
)
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = "Erro ao inserir dados de user";    
END;
START TRANSACTION;
INSERT INTO user (first_name, last_name, email, location, phone_number, password, created_at, updated_at)
VALUES (p_first_name, p_last_name, p_email, p_location, p_phone_number, p_password, NOW(), NOW());
    COMMIT;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_book(
IN p_id_user INT, 
IN p_title VARCHAR(100), 
IN p_author VARCHAR(60),
IN p_category VARCHAR(50),
IN p_preservation_status ENUM('Novo','Usado','Desgastado'), 
IN p_publication_date DATE,
IN p_synopsis TEXT,
IN p_user_review TEXT,
IN p_publisher VARCHAR(100), 
IN p_available BOOLEAN
)
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = "Erro ao inserir dados de livro";    
END;
START TRANSACTION;
INSERT INTO book (id_user, title, author, category, preservation_status, publication_date, synopsis, user_review, publisher, available, created_at, updated_at)
VALUES(p_id_user, p_title, p_author, p_category,p_preservation_status, p_publication_date,
p_synopsis,p_user_review,p_publisher, p_available, NOW(), NOW());
COMMIT;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_exchange(
IN p_offered_book_id INT,
IN p_received_book_id INT,
IN p_offerer_user_id INT,
IN p_receiver_user_id INT,
IN p_form_of_swap ENUM ("envio","presencial"))
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = "Erro ao inserir dados de troca";    
END;
START TRANSACTION;
INSERT INTO exchange(offered_book_id, received_book_id, offerer_user_id, receiver_user_id, form_of_swap, created_at, updated_at)
VALUES(p_offered_book_id, p_received_book_id, p_offerer_user_id, p_receiver_user_id, p_form_of_swap, NOW(), NOW());
COMMIT;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_user_rating(
IN p_rater_user_id INT,
IN p_rated_user_id INT,
IN p_score INT,
IN p_comment TEXT
)
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION 
BEGIN
ROLLBACK;
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Erro ao inserir dados da avaliação de usuário';    
END;
START TRANSACTION;
INSERT INTO user_rating (rater_user_id, rated_user_id, score, comment, created_at, updated_at)
VALUES (p_rater_user_id, p_rated_user_id, p_score, p_comment, NOW(), NOW());
COMMIT;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_literary_group(
IN p_group_name VARCHAR(100),
IN p_description TEXT,
IN p_id_book INT
)
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION 
BEGIN
ROLLBACK;
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Erro ao inserir dados do grupo literário';    
END;
START TRANSACTION;
INSERT INTO literary_group (group_name, description, id_book, created_at, updated_at)
VALUES (p_group_name, p_description, p_id_book, NOW(), NOW());
COMMIT;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_user_group(
IN p_id_user INT,
IN p_id_group INT
)
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION 
BEGIN
ROLLBACK;
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Erro ao inserir dados na tabela intermediária de usuário e grupo';    
END;
START TRANSACTION;
INSERT INTO user_group (id_user, id_group, created_at, updated_at)
VALUES (p_id_user, p_id_group, NOW(), NOW());
COMMIT;
END $$
DELIMITER ;

CALL insert_user('João', 'Silva', 'joao.silva@email.com', 'São Paulo', '1234567890', 'senha123');
CALL insert_user('Maria', 'Oliveira', 'maria.oliveira@email.com', 'Rio de Janeiro', '0987654321', 'senha456');
CALL insert_user('Carlos', 'Santos', 'carlos.santos@email.com', 'Recife', '1122334455', 'senha789');
CALL insert_user('Maria', 'Costa', 'ana.costa@email.com', 'Curitiba', '2233445566', 'senha101');
CALL insert_user('Fernanda', 'Pereira', 'fernanda.pereira@email.com', 'Porto Alegre', '3344556677', 'senha102');
CALL insert_user('Pedro', 'Rodrigues', 'pedro.rodrigues@email.com', 'Salvador', '4455667788', 'senha103');
CALL insert_user('Paula', 'Martins', 'paula.martins@email.com', 'Fortaleza', '5566778899', 'senha104');
CALL insert_user('Juliana', 'Souza', 'juliana.souza@email.com', 'São Paulo', '1122334455', 'senha123');

CALL insert_book(1, 'Percy Jackson', 'Rick Riordan', 'Aventura', 'Novo', '2005-05-01', 'História de um jovem semideus.', 'Excelente livro para jovens', 'Intrínseca', TRUE);
CALL insert_book(2, 'Harry Potter', 'J.K. Rowling', 'Fantasia', 'Novo', '1997-06-26', 'A jornada de um bruxo em um mundo mágico.', 'Muito bom e envolvente', 'Rocco', TRUE);
CALL insert_book(3, 'O Alquimista', 'Paulo Coelho', 'Ficção', 'Usado', '1988-01-01', 'A história de Santiago, um jovem pastor em busca de um tesouro.', 'Excelente livro de autodescoberta', 'HarperCollins', TRUE);
CALL insert_book(4, 'O Senhor dos Anéis', 'J.R.R. Tolkien', 'Fantasia', 'Novo', '1954-07-29', 'Aventura épica pela Terra-média.', 'Uma obra-prima', 'HarperCollins', TRUE);
CALL insert_book(5, 'Dom Casmurro', 'Machado de Assis', 'Romance', 'Novo', '1900-01-01', 'A história de Bentinho e Capitu.', 'Obra fundamental para a literatura brasileira', 'Companhia das Letras', TRUE);
CALL insert_book(6, '1984', 'George Orwell', 'Distopia', 'Desgastado', '1949-06-08', 'A luta de Winston contra o regime totalitário.', 'Muito impactante', 'Companhia das Letras', TRUE);
CALL insert_book(7, 'O Diário de Anne Frank', 'Anne Frank', 'Biografia', 'Usado', '1947-06-25', 'Relatos de uma adolescente judia escondida durante a Segunda Guerra.', 'Livro tocante e poderoso', 'Record', TRUE);
CALL insert_book(8, 'O Pequeno Príncipe', 'Antoine de Saint-Exupéry', 'Literatura Infantil', 'Novo', '1943-04-06', 'Uma fábula filosófica sobre amor, amizade e a essência da vida.', 'Uma leitura encantadora e cheia de significados profundos.', 'Editora DEF', TRUE);
CALL insert_book(1, 'Corte de Espinhos e Rosas', 'Sarah J. Maas', 'Fantasia', 'Novo', '2015-05-05', 'Uma jovem humana é levada para um mundo mágico, onde enfrenta desafios e sentimentos intensos.', 'Uma fantasia envolvente cheia de magia, mistério e romance.', 'Bloomsbury Publishing', FALSE);

CALL insert_exchange(1, 2, 1, 2, 'envio');
CALL insert_exchange(3, 4, 3, 4, 'presencial');
CALL insert_exchange(5, 6, 5, 6, 'envio');
CALL insert_exchange(7, 8, 7, 8, 'presencial');

CALL insert_user_rating(1, 2, 5, 'Excelente experiência, muito atencioso!');
CALL insert_user_rating(2, 1, 5, 'Amei o livro, muito bom!');
CALL insert_user_rating(3, 4, 4, 'Ótima troca de livros, o livro estava em bom estado.');
CALL insert_user_rating(5, 4, 3, 'A troca foi boa, mas o livro tinha algumas marcas de uso.');
CALL insert_user_rating(7, 8, 5, 'Adorei o livro, estava em perfeito estado e a troca foi rápida.');

CALL insert_literary_group('Percy Jackson', 'Grupo dedicado à leitura de Percy Jackson e discussão sobre a aventura e mitologia.', 1);
CALL insert_literary_group('Harry Potter', 'Grupo de leitura e discussão sobre a série Harry Potter e seu mundo mágico.', 2);
CALL insert_literary_group('O Alquimista', 'Grupo para discutir as lições de autodescoberta e o simbolismo de O Alquimista.', 3);
CALL insert_literary_group('O Senhor dos Anéis', 'Grupo literário focado na leitura e análise da obra épica de Tolkien, O Senhor dos Anéis.', 4);
CALL insert_literary_group('Dom Casmurro', 'Grupo de leitura e discussão sobre a obra-prima de Machado de Assis e seus dilemas morais.', 5);
CALL insert_literary_group('1984', 'Grupo dedicado a explorar os temas distópicos e políticos de 1984, de George Orwell.', 6);
CALL insert_literary_group('O Diário de Anne Frank', 'Grupo literário voltado para a leitura e reflexão sobre o testemunho de Anne Frank.', 7);

CALL insert_user_group(1, 1);
CALL insert_user_group(2, 1);
CALL insert_user_group(3, 2);
CALL insert_user_group(4, 2);
CALL insert_user_group(5, 2);
CALL insert_user_group(6, 3);
CALL insert_user_group(7, 4);
CALL insert_user_group(8, 4);