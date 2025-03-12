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

-- inserindo dados dos usuarios
CALL insert_user('Lucas', 'Mendes', 'lucas.mendes@email.com', 'Brasília', '6677889900', 'senha105');
CALL insert_user('Mariana', 'Ferreira', 'mariana.ferreira@email.com', 'Belo Horizonte', '7788990011', 'senha106');
CALL insert_user('André', 'Almeida', 'andre.almeida@email.com', 'Manaus', '8899001122', 'senha107');
CALL insert_user('Camila', 'Lima', 'camila.lima@email.com', 'Florianópolis', '9900112233', 'senha108');
CALL insert_user('Thiago', 'Gonçalves', 'thiago.goncalves@email.com', 'Goiânia', '2233445566', 'senha109');
CALL insert_user('Beatriz', 'Carvalho', 'beatriz.carvalho@email.com', 'Belém', '3344556677', 'senha110');
CALL insert_user('Ricardo', 'Souza', 'ricardo.souza@email.com', 'Natal', '5566778899', 'senha111');
CALL insert_user('Larissa', 'Barbosa', 'larissa.barbosa@email.com', 'João Pessoa', '6677889900', 'senha112');
CALL insert_user('Gustavo', 'Ramos', 'gustavo.ramos@email.com', 'Teresina', '7788990011', 'senha113');
CALL insert_user('Tatiane', 'Araújo', 'tatiane.araujo@email.com', 'São Luís', '8899001122', 'senha114');
CALL insert_user('Renato', 'Figueiredo', 'renato.figueiredo@email.com', 'Campo Grande', '9900112233', 'senha115');
CALL insert_user('Isabela', 'Correia', 'isabela.correia@email.com', 'Maceió', '2233445566', 'senha116');
CALL insert_user('Bruno', 'Pires', 'bruno.pires@email.com', 'Boa Vista', '3344556677', 'senha117');
CALL insert_user('Vanessa', 'Neves', 'vanessa.neves@email.com', 'Macapá', '4455667788', 'senha118');
CALL insert_user('Luana', 'Ferreira', 'luana.ferreira@email.com', 'Belo Horizonte', '1234598765', 'senha105');
CALL insert_user('Ricardo', 'Gomes', 'ricardo.gomes@email.com', 'Brasília', '9876543210', 'senha106');
CALL insert_user('Fernanda', 'Almeida', 'fernanda.almeida@email.com', 'Curitiba', '5647382910', 'senha107');
CALL insert_user('André', 'Pereira', 'andre.pereira@email.com', 'Rio de Janeiro', '4433221100', 'senha108');
CALL insert_user('Larissa', 'Martins', 'larissa.martins@email.com', 'São Paulo', '6677889900', 'senha109');
CALL insert_user('Gustavo', 'Costa', 'gustavo.costa@email.com', 'Porto Alegre', '1230984567', 'senha110');
CALL insert_user('Mariana', 'Mendes', 'mariana.mendes@email.com', 'Salvador', '1122339988', 'senha111');
CALL insert_user('Felipe', 'Lima', 'felipe.lima@email.com', 'Fortaleza', '2233445566', 'senha112');
CALL insert_user('Tatiane', 'Souza', 'tatiane.souza@email.com', 'Recife', '3344556677', 'senha113');
CALL insert_user('Juliano', 'Silva', 'juliano.silva@email.com', 'São Paulo', '4455667788', 'senha114');
CALL insert_user('Roberta', 'Oliveira', 'roberta.oliveira@email.com', 'Florianópolis', '5566778899', 'senha115');
CALL insert_user('Thiago', 'Rocha', 'thiago.rocha@email.com', 'Vitória', '6677889900', 'senha116');
CALL insert_user('Vanessa', 'Santos', 'vanessa.santos@email.com', 'Manaus', '7788990011', 'senha117');
CALL insert_user('Daniela', 'Pinto', 'daniela.pinto@email.com', 'Campinas', '8899001122', 'senha118');
CALL insert_user('Marco', 'Tavares', 'marco.tavares@email.com', 'Belém', '9900112233', 'senha119');
CALL insert_user('Carla', 'Martins', 'carla.martins@email.com', 'Niterói', '1234678901', 'senha120');
CALL insert_user('Robson', 'Mota', 'robson.mota@email.com', 'Aracaju', '2345789012', 'senha121');
CALL insert_user('Aline', 'Lopes', 'aline.lopes@email.com', 'Maceió', '3456890123', 'senha122');
CALL insert_user('Henrique', 'Campos', 'henrique.campos@email.com', 'São Luís', '4567901234', 'senha123');
CALL insert_user('Beatriz', 'Costa', 'beatriz.costa@email.com', 'Cuiabá', '5678012345', 'senha124');
CALL insert_user('Jéssica', 'Dias', 'jessica.dias@email.com', 'João Pessoa', '6789012345', 'senha125');
CALL insert_user('Samuel', 'Alves', 'samuel.alves@email.com', 'São Bernardo do Campo', '7890123456', 'senha126');
CALL insert_user('Gabriela', 'Lima', 'gabriela.lima@email.com', 'Santos', '8901234567', 'senha127');
CALL insert_user('Rafael', 'Vieira', 'rafael.vieira@email.com', 'Uberlândia', '9012345678', 'senha128');
CALL insert_user('Patrícia', 'Macedo', 'patricia.macedo@email.com', 'Londrina', '1234598765', 'senha129');
CALL insert_user('Igor', 'Barbosa', 'igor.barbosa@email.com', 'Maringá', '2345678901', 'senha130');
CALL insert_user('Priscila', 'Cavalcanti', 'priscila.cavalcanti@email.com', 'Porto Velho', '3456789012', 'senha131');
CALL insert_user('Felipe', 'Silveira', 'felipe.silveira@email.com', 'Rio Branco', '4567890123', 'senha132');
CALL insert_user('Bruna', 'Gomes', 'bruna.gomes@email.com', 'Palmas', '5678901234', 'senha133');
CALL insert_user('Vinícius', 'Santos', 'vinicius.santos@email.com', 'Caxias do Sul', '6789012345', 'senha134');
CALL insert_user('Lucas', 'Henrique', 'lucas.henrique@email.com', 'Boa Vista', '7890123456', 'senha135');
CALL insert_user('Marta', 'Costa', 'marta.costa@email.com', 'Caruaru', '8901234567', 'senha136');
CALL insert_user('Eduardo', 'Martins', 'eduardo.martins@email.com', 'Teresina', '9012345678', 'senha137');
CALL insert_user('Eliane', 'Pereira', 'eliane.pereira@email.com', 'Macapá', '1234598765', 'senha138');
CALL insert_user('Guilherme', 'Souza', 'guilherme.souza@email.com', 'Petrolina', '2345678901', 'senha139');
CALL insert_user('Juliana', 'Oliveira', 'juliana.oliveira@email.com', 'São José do Rio Preto', '3456789012', 'senha140');
CALL insert_user('Roberto', 'Silva', 'roberto.silva@email.com', 'Arapiraca', '4567890123', 'senha141');
CALL insert_user('Sílvia', 'Ribeiro', 'silvia.ribeiro@email.com', 'Itajaí', '5678901234', 'senha142');
CALL insert_user('Marcos', 'Lima', 'marcos.lima@email.com', 'Governador Valadares', '6789012345', 'senha143');
CALL insert_user('Adriana', 'Santos', 'adriana.santos@email.com', 'Bauru', '7890123456', 'senha144');
CALL insert_user('Ana', 'Souza', 'ana.souza@email.com', 'Rio de Janeiro', '7891234567', 'senha145');
CALL insert_user('Carlos', 'Silva', 'carlos.silva@email.com', 'Belo Horizonte', '8902345678', 'senha146');
CALL insert_user('Fernanda', 'Mendes', 'fernanda.mendes@email.com', 'Fortaleza', '9013456789', 'senha147');
CALL insert_user('Luiz', 'Oliveira', 'luiz.oliveira@email.com', 'São Paulo', '2345678901', 'senha148');
CALL insert_user('Patrícia', 'Costa', 'patricia.costa@email.com', 'Curitiba', '3456789012', 'senha149');
CALL insert_user('Rafael', 'Pereira', 'rafael.pereira@email.com', 'Recife', '4567890123', 'senha150');
CALL insert_user('Juliana', 'Lima', 'juliana.lima@email.com', 'Porto Alegre', '5678901234', 'senha151');
CALL insert_user('Tiago', 'Santos', 'tiago.santos@email.com', 'Salvador', '6789012345', 'senha152');
CALL insert_user('Renata', 'Rocha', 'renata.rocha@email.com', 'Natal', '7890123456', 'senha153');
CALL insert_user('Robson', 'Barbosa', 'robson.barbosa@email.com', 'Manaus', '8901234567', 'senha154');
CALL insert_user('Lucas', 'Martins', 'lucas.martins@email.com', 'São Paulo', '1234567890', 'senha155');
CALL insert_user('Carla', 'Oliveira', 'carla.oliveira@email.com', 'Fortaleza', '2345678901', 'senha156');
CALL insert_user('Fernando', 'Costa', 'fernando.costa@email.com', 'Fortaleza', '3456789012', 'senha157');
CALL insert_user('Roberto', 'Gomes', 'roberto.gomes@email.com', 'Belo Horizonte', '4567890123', 'senha158');

-- inserindo livros
CALL insert_book(9, 'As Crônicas de Nárnia', 'C.S. Lewis', 'Fantasia', 'Novo', '1950-10-16', 'Histórias mágicas em Nárnia.', 'Encantador para todas as idades.', 'HarperCollins', TRUE);
CALL insert_book(10, 'Crime e Castigo', 'Fiódor Dostoiévski', 'Romance', 'Usado', '1866-01-01', 'O drama psicológico de um assassino.', 'Clássico profundo e instigante.', 'Editora ABC', TRUE);
CALL insert_book(11, 'Memórias Póstumas de Brás Cubas', 'Machado de Assis', 'Romance', 'Novo', '1881-01-01', 'Narrado por um defunto, com ironia e crítica social.', 'Uma obra-prima do realismo.', 'Companhia das Letras', TRUE);
CALL insert_book(12, 'A Revolução dos Bichos', 'George Orwell', 'Distopia', 'Usado', '1945-08-17', 'Uma fábula satírica sobre totalitarismo.', 'Impactante e atemporal.', 'Editora XYZ', TRUE);
CALL insert_book(13, 'Cem Anos de Solidão', 'Gabriel García Márquez', 'Realismo Fantástico', 'Novo', '1967-05-30', 'A saga da família Buendía.', 'Uma narrativa hipnotizante.', 'Editora UVW', TRUE);
CALL insert_book(14, 'O Homem Invisível', 'H.G. Wells', 'Ficção Científica', 'Desgastado', '1897-06-01', 'Um cientista descobre o segredo da invisibilidade.', 'Clássico da ficção científica.', 'Editora KLM', TRUE);
CALL insert_book(15, 'O Conde de Monte Cristo', 'Alexandre Dumas', 'Aventura', 'Novo', '1844-08-28', 'A vingança de Edmond Dantès.', 'Obra-prima da literatura clássica.', 'Editora Clássica', TRUE);
CALL insert_book(16, 'Duna', 'Frank Herbert', 'Ficção Científica', 'Usado', '1965-08-01', 'A saga do planeta desértico Arrakis.', 'Um clássico da ficção científica.', 'Aleph', TRUE);
CALL insert_book(17, 'It: A Coisa', 'Stephen King', 'Terror', 'Novo', '1986-09-15', 'O terror do palhaço Pennywise.', 'Extremamente assustador e envolvente.', 'Suma de Letras', TRUE);
CALL insert_book(18, 'A Metamorfose', 'Franz Kafka', 'Ficção', 'Usado', '1915-10-01', 'A história de Gregor Samsa e sua transformação.', 'Uma alegoria brilhante.', 'Editora Cultura', TRUE);
CALL insert_book(19, 'A Menina que Roubava Livros', 'Markus Zusak', 'Drama', 'Desgastado', '2005-09-01', 'A Segunda Guerra narrada pela Morte.', 'Uma leitura emocionante.', 'Intrínseca', TRUE);
CALL insert_book(20, 'O Hobbit', 'J.R.R. Tolkien', 'Fantasia', 'Novo', '1937-09-21', 'As aventuras de Bilbo Bolseiro.', 'Leitura essencial para fãs de fantasia.', 'HarperCollins', TRUE);
CALL insert_book(9, 'A Revolução dos Bichos', 'George Orwell', 'Distopia', 'Usado', '1945-08-17', 'Uma fábula política sobre uma fazenda onde os animais tomam o poder.', 'Leitura essencial para entender regimes totalitários.', 'Companhia das Letras', TRUE);
CALL insert_book(10, 'As Crônicas de Nárnia', 'C.S. Lewis', 'Fantasia', 'Novo', '1950-10-16', 'Sete histórias sobre um mundo mágico chamado Nárnia.', 'Obra atemporal e inspiradora.', 'HarperCollins', TRUE);
CALL insert_book(11, 'O Nome do Vento', 'Patrick Rothfuss', 'Fantasia', 'Novo', '2007-03-27', 'A história de Kvothe, um jovem talentoso que busca respostas sobre seu passado.', 'Uma das melhores fantasias modernas.', 'Arqueiro', TRUE);
CALL insert_book(12, 'A Menina que Roubava Livros', 'Markus Zusak', 'Ficção Histórica', 'Novo', '2005-09-01', 'Durante a Segunda Guerra Mundial, uma menina encontra consolo nos livros.', 'História emocionante e impactante.', 'Intrínseca', TRUE);
CALL insert_book(13, 'O Código Da Vinci', 'Dan Brown', 'Suspense', 'Usado', '2003-03-18', 'Uma busca por segredos ocultos dentro da história da arte e da religião.', 'Mistério envolvente do começo ao fim.', 'Arqueiro', TRUE);
CALL insert_book(14, 'O Hobbit', 'J.R.R. Tolkien', 'Fantasia', 'Novo', '1937-09-21', 'A jornada de Bilbo Bolseiro ao lado de anões em busca de um tesouro.', 'Um clássico da literatura fantástica.', 'HarperCollins', TRUE);
CALL insert_book(15, 'Os Sete Maridos de Evelyn Hugo', 'Taylor Jenkins Reid', 'Romance', 'Novo', '2017-06-13', 'A história de uma lendária atriz e seus segredos.', 'Emocionante e surpreendente.', 'Paralela', TRUE);
CALL insert_book(16, 'Sherlock Holmes - Um Estudo em Vermelho', 'Arthur Conan Doyle', 'Mistério', 'Usado', '1887-11-01', 'O primeiro caso de Sherlock Holmes e Dr. Watson.', 'O início de um detetive icônico.', 'L&PM', TRUE);
CALL insert_book(17, 'O Senhor das Moscas', 'William Golding', 'Ficção', 'Usado', '1954-09-17', 'Garotos isolados em uma ilha precisam criar suas próprias regras.', 'Uma análise brutal da natureza humana.', 'Alfaguara', TRUE);
CALL insert_book(18, 'Crime e Castigo', 'Fiódor Dostoiévski', 'Clássico', 'Novo', '1866-01-01', 'O conflito psicológico de um jovem após cometer um crime.', 'Uma obra-prima da literatura russa.', 'Editora 34', TRUE);
CALL insert_book(19, 'Grande Sertão: Veredas', 'João Guimarães Rosa', 'Clássico', 'Novo', '1956-05-01', 'Uma jornada pelo sertão brasileiro narrada por Riobaldo.', 'Obra-prima da literatura brasileira.', 'Nova Fronteira', TRUE);
CALL insert_book(20, 'O Sol é Para Todos', 'Harper Lee', 'Ficção', 'Usado', '1960-07-11', 'A luta contra o racismo e a injustiça no sul dos Estados Unidos.', 'Leitura essencial sobre empatia e justiça.', 'José Olympio', TRUE);
CALL insert_book(21, 'Duna', 'Frank Herbert', 'Ficção Científica', 'Novo', '1965-08-01', 'Uma saga épica em um mundo desértico onde a especiaria é o bem mais valioso.', 'Uma das maiores ficções científicas de todos os tempos.', 'Aleph', TRUE);
CALL insert_book(22, 'O Conto da Aia', 'Margaret Atwood', 'Distopia', 'Novo', '1985-09-01', 'Um futuro sombrio onde mulheres são forçadas a servir um regime totalitário.', 'Uma leitura impactante e perturbadora.', 'Rocco', TRUE);
CALL insert_book(23, 'Cem Anos de Solidão', 'Gabriel García Márquez', 'Realismo Mágico', 'Novo', '1967-05-30', 'A história da família Buendía na cidade fictícia de Macondo.', 'Uma obra-prima da literatura latino-americana.', 'Record', TRUE);
CALL insert_book(24, 'Neuromancer', 'William Gibson', 'Ficção Científica', 'Usado', '1984-07-01', 'O livro que criou o conceito do cyberpunk.', 'Influenciou toda a cultura hacker e sci-fi.', 'Aleph', TRUE);
CALL insert_book(25, 'Orgulho e Preconceito', 'Jane Austen', 'Romance', 'Novo', '1813-01-28', 'O clássico romance entre Elizabeth Bennet e Mr. Darcy.', 'Um dos romances mais amados da literatura.', 'Penguin Books', TRUE);
CALL insert_book(26, 'Drácula', 'Bram Stoker', 'Terror', 'Novo', '1897-05-26', 'O romance que deu origem ao mito moderno do vampiro.', 'Um clássico gótico essencial.', 'DarkSide Books', TRUE);
CALL insert_book(27, 'O Médico e o Monstro', 'Robert Louis Stevenson', 'Terror', 'Usado', '1886-01-05', 'A dualidade entre o bem e o mal dentro de um homem.', 'Uma história atemporal sobre a psicologia humana.', 'Zahar', TRUE);
CALL insert_book(28, 'A Metamorfose', 'Franz Kafka', 'Ficção', 'Novo', '1915-10-01', 'Um homem acorda transformado em um inseto e precisa lidar com a rejeição.', 'Uma obra icônica do absurdo.', 'Companhia das Letras', TRUE);
CALL insert_book(29, 'Os Homens que Não Amavam as Mulheres', 'Stieg Larsson', 'Suspense', 'Novo', '2005-08-01', 'Investigação sobre um desaparecimento que revela segredos obscuros.', 'Primeiro livro da trilogia Millennium.', 'Companhia das Letras', TRUE);
CALL insert_book(30, 'O Silmarillion', 'J.R.R. Tolkien', 'Fantasia', 'Novo', '1977-09-15', 'A mitologia do mundo de O Senhor dos Anéis.', 'Indispensável para fãs de Tolkien.', 'HarperCollins', TRUE);
CALL insert_book(1, 'A Sombra do Vento', 'Carlos Ruiz Zafón', 'Mistério', 'Novo', '2001-04-01', 'Um jovem encontra um livro misterioso e descobre um segredo oculto.', 'Uma história envolvente e cheia de mistério.', 'Suma de Letras', TRUE);
CALL insert_book(2, 'O Colecionador', 'John Fowles', 'Suspense', 'Usado', '1963-01-01', 'Um homem obcecado por uma jovem decide sequestrá-la.', 'Um thriller psicológico perturbador.', 'Alfaguara', TRUE);
CALL insert_book(3, 'Os Irmãos Karamázov', 'Fiódor Dostoiévski', 'Clássico', 'Novo', '1880-01-01', 'O drama de três irmãos e seus conflitos filosóficos e morais.', 'Um dos maiores romances da literatura russa.', 'Editora 34', TRUE);
CALL insert_book(4, 'A Biblioteca da Meia-Noite', 'Matt Haig', 'Ficção', 'Novo', '2020-08-13', 'Uma mulher tem a chance de viver vidas alternativas através de uma biblioteca mágica.', 'Reflexivo e emocionante.', 'Bertrand Brasil', TRUE);
CALL insert_book(5, 'O Pintassilgo', 'Donna Tartt', 'Ficção', 'Usado', '2013-10-22', 'A vida de um garoto muda após uma tragédia e um roubo inesperado.', 'Um romance moderno intenso e cativante.', 'Companhia das Letras', TRUE);
CALL insert_book(6, 'A Paciente Silenciosa', 'Alex Michaelides', 'Suspense', 'Novo', '2019-02-05', 'Uma mulher assassinou seu marido e nunca mais falou uma palavra.', 'Um thriller psicológico brilhante.', 'Record', TRUE);
CALL insert_book(7, 'O Lado Bom da Vida', 'Matthew Quick', 'Ficção', 'Usado', '2008-02-02', 'Um homem tenta reconstruir sua vida após sair de uma instituição psiquiátrica.', 'Inspirador e emocionante.', 'Intrínseca', TRUE);
CALL insert_book(8, 'O Jogo do Anjo', 'Carlos Ruiz Zafón', 'Mistério', 'Novo', '2008-04-17', 'Um escritor recebe uma proposta misteriosa para escrever um livro.', 'Atmosfera sombria e viciante.', 'Suma de Letras', TRUE);
CALL insert_book(9, 'O Homem Invisível', 'H.G. Wells', 'Ficção Científica', 'Usado', '1897-01-01', 'Um cientista descobre o segredo da invisibilidade, mas paga um preço alto.', 'Um clássico da ficção científica.', 'Zahar', TRUE);
CALL insert_book(10, 'A Guerra dos Tronos', 'George R.R. Martin', 'Fantasia', 'Novo', '1996-08-06', 'Intrigas políticas e batalhas em um mundo medieval repleto de traições.', 'Início da saga épica de Westeros.', 'Suma', TRUE);
CALL insert_book(11, 'Os Testamentos', 'Margaret Atwood', 'Distopia', 'Novo', '2019-09-10', 'A continuação de O Conto da Aia, revelando mais sobre Gilead.', 'Um retorno poderoso ao universo distópico.', 'Rocco', TRUE);
CALL insert_book(12, 'Sapiens: Uma Breve História da Humanidade', 'Yuval Noah Harari', 'História', 'Novo', '2011-06-04', 'Uma análise do desenvolvimento da humanidade e suas mudanças ao longo do tempo.', 'Livro essencial para entender nossa história.', 'Companhia das Letras', TRUE);
CALL insert_book(13, 'O Poder do Hábito', 'Charles Duhigg', 'Autoajuda', 'Novo', '2012-02-28', 'Um estudo sobre como os hábitos moldam nossas vidas e como podemos mudá-los.', 'Transformador e baseado em ciência.', 'Objetiva', TRUE);
CALL insert_book(14, 'A Sutil Arte de Ligar o F*da-se', 'Mark Manson', 'Autoajuda', 'Usado', '2016-09-13', 'Um guia honesto sobre como viver uma vida autêntica sem se preocupar com tudo.', 'Leitura direta e divertida.', 'Intrínseca', TRUE);
CALL insert_book(15, 'O Poder da Ação', 'Paulo Vieira', 'Autoajuda', 'Novo', '2015-06-01', 'Um guia para desenvolver hábitos e alcançar seus objetivos.', 'Livro motivacional prático.', 'Gente', TRUE);
CALL insert_book(16, 'A Cor Púrpura', 'Alice Walker', 'Ficção', 'Novo', '1982-01-01', 'A luta de uma mulher negra no sul dos EUA no início do século XX.', 'História poderosa e emocionante.', 'José Olympio', TRUE);
CALL insert_book(17, 'O Velho e o Mar', 'Ernest Hemingway', 'Ficção', 'Novo', '1952-09-01', 'A história de um pescador e sua batalha contra um peixe gigante.', 'Uma metáfora sobre perseverança.', 'Bertrand Brasil', TRUE);
CALL insert_book(18, 'Admirável Mundo Novo', 'Aldous Huxley', 'Distopia', 'Usado', '1932-01-01', 'Uma sociedade futurista onde a liberdade foi substituída pelo controle absoluto.', 'Um clássico da ficção distópica.', 'Biblioteca Azul', TRUE);
CALL insert_book(19, 'As Vinhas da Ira', 'John Steinbeck', 'Ficção', 'Novo', '1939-04-14', 'Uma família luta para sobreviver durante a Grande Depressão.', 'Um retrato intenso da luta por dignidade.', 'Penguin Books', TRUE);
CALL insert_book(20, 'Inferno', 'Dan Brown', 'Suspense', 'Novo', '2013-05-14', 'Robert Langdon se vê envolvido em uma conspiração inspirada em Dante Alighieri.', 'Thriller emocionante e repleto de referências históricas.', 'Arqueiro', TRUE);
CALL insert_book(1, 'Percy Jackson', 'Rick Riordan', 'Aventura', 'Novo', '2005-05-01', 'História de um jovem semideus.', 'Excelente livro para jovens', 'Intrínseca', TRUE);
CALL insert_book(2, 'Harry Potter', 'J.K. Rowling', 'Fantasia', 'Novo', '1997-06-26', 'A jornada de um bruxo em um mundo mágico.', 'Muito bom e envolvente', 'Rocco', TRUE);
CALL insert_book(3, 'O Alquimista', 'Paulo Coelho', 'Ficção', 'Usado', '1988-01-01', 'A história de Santiago, um jovem pastor em busca de um tesouro.', 'Excelente livro de autodescoberta', 'HarperCollins', TRUE);
CALL insert_book(4, 'O Senhor dos Anéis', 'J.R.R. Tolkien', 'Fantasia', 'Novo', '1954-07-29', 'Aventura épica pela Terra-média.', 'Uma obra-prima', 'HarperCollins', TRUE);
CALL insert_book(5, 'Dom Casmurro', 'Machado de Assis', 'Romance', 'Novo', '1900-01-01', 'A história de Bentinho e Capitu.', 'Obra fundamental para a literatura brasileira', 'Companhia das Letras', TRUE);
CALL insert_book(6, '1984', 'George Orwell', 'Distopia', 'Desgastado', '1949-06-08', 'A luta de Winston contra o regime totalitário.', 'Muito impactante', 'Companhia das Letras', TRUE);
CALL insert_book(7, 'O Diário de Anne Frank', 'Anne Frank', 'Biografia', 'Usado', '1947-06-25', 'Relatos de uma adolescente judia escondida durante a Segunda Guerra.', 'Livro tocante e poderoso', 'Record', TRUE);
CALL insert_book(8, 'O Pequeno Príncipe', 'Antoine de Saint-Exupéry', 'Literatura Infantil', 'Novo', '1943-04-06', 'Uma fábula filosófica sobre amor, amizade e a essência da vida.', 'Uma leitura encantadora e cheia de significados profundos.', 'Editora DEF', TRUE);
CALL insert_book(1, 'Corte de Espinhos e Rosas', 'Sarah J. Maas', 'Fantasia', 'Novo', '2015-05-05', 'Uma jovem humana é levada para um mundo mágico, onde enfrenta desafios e sentimentos intensos.', 'Uma fantasia envolvente cheia de magia, mistério e romance.', 'Bloomsbury Publishing', FALSE);

CALL insert_exchange(9, 10, 9, 10, 'envio');
CALL insert_exchange(11, 12, 11, 12, 'presencial');
CALL insert_exchange(13, 14, 13, 14, 'envio');
CALL insert_exchange(7, 12, 7, 12, 'presencial');
CALL insert_exchange(5, 13, 5, 13, 'envio');
CALL insert_exchange(15, 16, 15, 16, 'envio');
CALL insert_exchange(17, 18, 17, 18, 'presencial');
CALL insert_exchange(19, 20, 19, 20, 'envio');
CALL insert_exchange(10, 17, 10, 17, 'presencial');
CALL insert_exchange(14, 19, 14, 19, 'envio');
CALL insert_exchange(1, 2, 1, 2, 'envio');
CALL insert_exchange(3, 4, 3, 4, 'presencial');
CALL insert_exchange(5, 6, 5, 6, 'envio');
CALL insert_exchange(7, 8, 7, 8, 'presencial');

CALL insert_user_rating(9, 10, 5, 'Troca rápida e livro em ótimo estado.');
CALL insert_user_rating(10, 9, 4, 'O livro tinha algumas anotações, mas estava bem conservado.');
CALL insert_user_rating(11, 12, 5, 'Muito bem organizado, recomendo!');
CALL insert_user_rating(13, 14, 3, 'O livro estava um pouco danificado, mas a troca foi tranquila.');
CALL insert_user_rating(7, 12, 5, 'Ótima experiência, o livro veio até embalado.');
CALL insert_user_rating(15, 16, 5, 'Livro em ótimo estado e troca rápida.');
CALL insert_user_rating(16, 15, 4, 'Muito bom, mas poderia estar mais conservado.');
CALL insert_user_rating(17, 18, 5, 'Excelente experiência, recomendo!');
CALL insert_user_rating(19, 20, 3, 'O livro estava bem desgastado, mas a troca foi tranquila.');
CALL insert_user_rating(10, 17, 5, 'Ótima troca! Livro veio como novo.');
CALL insert_user_rating(14, 19, 4, 'O livro tinha algumas páginas dobradas, mas nada grave.');
CALL insert_user_rating(1, 2, 5, 'Excelente experiência, muito atencioso!');
CALL insert_user_rating(2, 1, 5, 'Amei o livro, muito bom!');
CALL insert_user_rating(3, 4, 4, 'Ótima troca de livros, o livro estava em bom estado.');
CALL insert_user_rating(5, 4, 3, 'A troca foi boa, mas o livro tinha algumas marcas de uso.');
CALL insert_user_rating(7, 8, 5, 'Adorei o livro, estava em perfeito estado e a troca foi rápida.');

CALL insert_literary_group('As Crônicas de Nárnia', 'Grupo para fãs da série As Crônicas de Nárnia e suas histórias encantadoras.', 9);
CALL insert_literary_group('Crime e Castigo', 'Grupo de leitura e discussão sobre Crime e Castigo, um romance psicológico.', 10);
CALL insert_literary_group('Memórias Póstumas de Brás Cubas', 'Grupo dedicado a debater a ironia e crítica social da obra.', 11);
CALL insert_literary_group('A Revolução dos Bichos', 'Grupo para análise dos temas políticos e sociais da fábula de Orwell.', 12);
CALL insert_literary_group('Cem Anos de Solidão', 'Grupo literário para explorar o universo mágico de García Márquez.', 13);
CALL insert_literary_group('O Conde de Monte Cristo', 'Grupo de discussão sobre a trama de vingança e justiça do clássico de Alexandre Dumas.', 15);
CALL insert_literary_group('Duna', 'Grupo para explorar o universo de Arrakis e debater a ficção científica de Frank Herbert.', 16);
CALL insert_literary_group('It: A Coisa', 'Grupo de leitura e análise dos elementos de terror da obra de Stephen King.', 17);
CALL insert_literary_group('A Metamorfose', 'Grupo literário dedicado à interpretação das metáforas e simbolismos da obra de Kafka.', 18);
CALL insert_literary_group('A Menina que Roubava Livros', 'Grupo para reflexão sobre a Segunda Guerra sob a perspectiva da literatura.', 19);
CALL insert_literary_group('O Hobbit', 'Grupo voltado para a leitura e debate sobre a jornada de Bilbo Bolseiro.', 20);
CALL insert_literary_group('Percy Jackson', 'Grupo dedicado à leitura de Percy Jackson e discussão sobre a aventura e mitologia.', 1);
CALL insert_literary_group('Harry Potter', 'Grupo de leitura e discussão sobre a série Harry Potter e seu mundo mágico.', 2);
CALL insert_literary_group('O Alquimista', 'Grupo para discutir as lições de autodescoberta e o simbolismo de O Alquimista.', 3);
CALL insert_literary_group('O Senhor dos Anéis', 'Grupo literário focado na leitura e análise da obra épica de Tolkien, O Senhor dos Anéis.', 4);
CALL insert_literary_group('Dom Casmurro', 'Grupo de leitura e discussão sobre a obra-prima de Machado de Assis e seus dilemas morais.', 5);
CALL insert_literary_group('1984', 'Grupo dedicado a explorar os temas distópicos e políticos de 1984, de George Orwell.', 6);
CALL insert_literary_group('O Diário de Anne Frank', 'Grupo literário voltado para a leitura e reflexão sobre o testemunho de Anne Frank.', 7);

CALL insert_user_group(9, 9);
CALL insert_user_group(10, 9);
CALL insert_user_group(11, 10);
CALL insert_user_group(12, 10);
CALL insert_user_group(13, 11);
CALL insert_user_group(14, 12);
CALL insert_user_group(7, 13);
CALL insert_user_group(5, 13);
CALL insert_user_group(15, 15);
CALL insert_user_group(16, 16);
CALL insert_user_group(17, 17);
CALL insert_user_group(18, 18);
CALL insert_user_group(19, 19);
CALL insert_user_group(20, 20);
CALL insert_user_group(10, 16);
CALL insert_user_group(14, 19);
CALL insert_user_group(1, 1);
CALL insert_user_group(2, 1);
CALL insert_user_group(3, 2);
CALL insert_user_group(4, 2);
CALL insert_user_group(5, 2);
CALL insert_user_group(6, 3);
CALL insert_user_group(7, 4);
CALL insert_user_group(8, 4);

-- atualizando
UPDATE book
SET id_user = 2, 
    updated_at = NOW()
WHERE id_book = 1;

UPDATE book
SET id_user = 1, 
    updated_at = NOW()
WHERE id_book = 2;

UPDATE book
SET id_user = 3, 
    updated_at = NOW()
WHERE id_book = 4;

UPDATE book
SET id_user = 4, 
    updated_at = NOW()
WHERE id_book = 3;