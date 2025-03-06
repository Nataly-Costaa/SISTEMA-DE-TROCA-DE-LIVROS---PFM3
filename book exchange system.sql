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