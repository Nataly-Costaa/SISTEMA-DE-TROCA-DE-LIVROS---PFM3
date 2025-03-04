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

-- corrigindo
ALTER TABLE book CHANGE avalible available BOOLEAN NOT NULL;
ALTER TABLE literaly_group CHANGE name group_name VARCHAR (100);
RENAME TABLE literaly_group TO literary_group;

-- inserindo dados
INSERT INTO user (first_name, last_name, email, location, phone_number, password, created_at, updated_at)
VALUES
('João', 'Silva', 'joao.silva@email.com', 'São Paulo', '1234567890', 'senha123', NOW(), NOW()),
('Maria', 'Oliveira', 'maria.oliveira@email.com', 'Rio de Janeiro', '0987654321', 'senha456', NOW(), NOW()),
('Carlos', 'Santos', 'carlos.santos@email.com', 'Belo Horizonte', '1122334455', 'senha789', NOW(), NOW()),
('Ana', 'Costa', 'ana.costa@email.com', 'Curitiba', '2233445566', 'senha101', NOW(), NOW()),
('Fernanda', 'Pereira', 'fernanda.pereira@email.com', 'Porto Alegre', '3344556677', 'senha102', NOW(), NOW()),
('Pedro', 'Rodrigues', 'pedro.rodrigues@email.com', 'Salvador', '4455667788', 'senha103', NOW(), NOW()),
('Paula', 'Martins', 'paula.martins@email.com', 'Fortaleza', '5566778899', 'senha104', NOW(), NOW()),
('Lucas', 'Lima', 'lucas.lima@email.com', 'Manaus', '6677889900', 'senha105', NOW(), NOW()),
('Juliana', 'Dias', 'juliana.dias@email.com', 'Recife', '7788990011', 'senha106', NOW(), NOW()),
('Roberto', 'Gomes', 'roberto.gomes@email.com', 'Belém', '8899001122', 'senha107', NOW(), NOW()),
('Cláudia', 'Souza', 'claudia.souza@email.com', 'Natal', '9900112233', 'senha108', NOW(), NOW()),
('Ricardo', 'Alves', 'ricardo.alves@email.com', 'João Pessoa', '1100223344', 'senha109', NOW(), NOW()),
('Marcela', 'Mendes', 'marcela.mendes@email.com', 'Vitória', '2200334455', 'senha110', NOW(), NOW()),
('Tiago', 'Ribeiro', 'tiago.ribeiro@email.com', 'Goiânia', '3300445566', 'senha111', NOW(), NOW()),
('Maria', 'Cardoso', 'maria.cardoso@email.com', 'Campo Grande', '4400556677', 'senha112', NOW(), NOW());