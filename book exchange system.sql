CREATE DATABASE exchange_books;
USE exchange_books;

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