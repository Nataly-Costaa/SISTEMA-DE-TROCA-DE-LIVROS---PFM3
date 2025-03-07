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
offered_book_id INT NOT NULL,
received_book_id INT NOT NULL,
offerer_user_id INT NOT NULL,
receiver_user_id INT NOT NULL,
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