# Troca de livros - Banco de Dados SQL

Atualmente, no Brasil, a compra de livros físicos tem se tornado cada vez mais difícil devido ao aumento constante nos preços, o que torna essa prática inacessível para muitas pessoas. Ao mesmo tempo, é comum observarmos prateleiras enormes de livros acumulando poeira em várias casas, já que muitos desses livros são comprados e nunca lidos, ou ficam fora de circulação devido à falta de interesse contínuo. 
Além disso, durante nossa pesquisa, encontramos leitores que, sem com quem discutir as obras que estavam lendo, acabavam desanimando e, com isso, abandonando a prática da leitura.
A solução para esses problemas pode ser encontrada em um sistema de troca de livros, que permitiria que leitores trocassem suas obras, diminuindo o custo e o desperdício de livros acumulados em casa. Juntamente com isso, a criação de grupos literários indicados para facilitar o encontro de pessoas com gostos semelhantes e o incentivo a discussões sobre livros poderia reacender o interesse pela leitura e promover a troca de ideias. Além disso, a implementação de avaliações aos usuários ajudaria a fortalecer a segurança da plataforma, garantindo que as trocas fossem realizadas de forma justa e confiável.
Para viabilizar tudo isso, desenvolvemos um banco de dados que armazena todas essas informações e garante o pleno gerenciamento do sistema.

## Índice

1. [Descrição do Projeto](#descrição-do-projeto)
2. [Tecnologias Usadas](#tecnologias-usadas)
3. [Regra de negócios](#regra-de-negócios)
4. [Estrutura do Banco de Dados](#estrutura-do-banco-de-dados)
5. [Contribuição](#contribuição)
6. [Contato](#contato)

## Descrição do Projeto
- Este banco de dados foi projetado para armazenar e gerenciar as informações de um sistema de troca de livros entre usuários, permitindo não apenas a circulação das obras, mas também incentivando a formação de comunidades literárias.

-Ele armazena:
  Usuários do sistema: Suas informações básicas.
  Livros cadastrados: Dados sobre os livros disponíveis para troca, incluindo seus proprietários originais.
  Transações de troca: Registros de solicitações e confirmações de trocas entre usuários.
  Grupos literários: Espaços onde os leitores podem discutir obras e interagir com outros membros.
  Histórico de trocas e propriedade: Rastreia por onde um livro passou e quem foram seus donos.
  Avaliações de usuários: Permite que leitores avaliem uns aos outros, incentivando trocas seguras e confiáveis.

- O banco de dados organiza a troca de livros e a interação entre os usuários para o sistema. A tabela exchange gerencia os pedidos de troca, enquanto exchange_history registra todas as transações passadas. A propriedade dos livros é monitorada em owner_history. Os usuários podem se conectar em literary_group para discutir leituras, e a confiabilidade das trocas é garantida por meio da user_rating, que permite avaliar os participantes. Essa estrutura mantém as trocas organizadas e incentiva a formação de uma comunidade ativa de leitores.

## Tecnologias Usadas
- **MySQL** – Sistema de Gerenciamento de Banco de Dados (SGBD) escolhido para armazenar e processar as informações.  
- **MySQL Workbench** – Utilizado para modelagem, administração e execução de queries no banco de dados.  
- **DBDiagram** – Ferramenta online usada para criar e visualizar o diagrama entidade-relacionamento (DER).  
- **BrModelo** – Software utilizado para a modelagem conceitual e lógica do banco de dados.

## Regra de negócios
- Um usuário pode ter vários livros, mas um livro só pertence a um usuário 
- Um usuário pode realizar várias trocas, mas cada troca está vinculada a um usuário específico em cada papel(oferecedor e receptor)
- Um livro pode ser trocado várias vezes, mas cada troca é específica para um par de livros, ou seja, uma troca pode envolver um único livro sendo oferecido e outro sendo recebido.
- Um usuário pode fazer várias avaliações, mas cada avaliação só pode ser feita por um usuário 
- Um usuário pode ser avaliado várias vezes, mas cada avaliação só pode ser sobre um usuário 
- Um grupo pode ter vários users, e um user pode estar em vários grupos
- Cada troca tem apenas um histórico, e um histórico pertence a apenas uma troca
- Um livro pode ter vários históricos de donos ao longo do tempo, mas cada histórico pertence a um livro
- Um user pode ter vários históricos de dono (se tiver mais de um livro), mas cada histórico de dono só pertence a um user
- Um livro pode ter vários grupos de conversas sobre ele, mas cada grupo pertence a apenas um livro 

## Estrutura do Banco de Dados
O banco de dados é separado em três arquivos SQL:
1. book exhange system: Contém as oito tabelas principais, interligadas por chaves estrangeiras.
2. inserting-data-into-database: Insere os dados em cada tabela.
3. database_queries: contém possíveis consultas que podem ser feitas no banco de dados

As tabelas interligadas por chaves estrangeiras são:
### 1. Tabela user (Usuário)
Armazena informações dos usuários cadastrados no sistema.
**Chave Primária**: id_user
**Relacionamentos:**
- Relacionada com book (um usuário pode ter vários livros).
- Relacionada com exchange (usuários podem realizar trocas).
- Relacionada com owner_history (histórico de posse dos livros).
- Relacionada com user_rating (avaliação de outros usuários).
- Relacionada com user_group (associação a grupos literários).

### 2. Tabela book (Livro)
Armazena informações dos livros disponíveis na plataforma.
**Chave Primária**: id_book
**Chaves Estrangeiras**:
id_user → user.id_user (indica o proprietário atual).
**Relacionamentos:**
- Relacionada com exchange (livros oferecidos/trocados).
- Relacionada com owner_history (histórico de propriedade).
- Relacionada com literary_group (livro associado a grupos).

### 3. Tabela exchange (Troca de Livros)
Registra informações sobre trocas de livros entre usuários.
**Chave Primária**: id_exchange
**Chaves Estrangeiras**:
offered_book_id → book.id_book (livro ofertado).
received_book_id → book.id_book (livro recebido na troca).
offerer_user_id → user.id_user (usuário que oferece a troca).
receiver_user_id → user.id_user (usuário que recebe a troca).
**Relacionamentos:**
- Relacionada com exchange_history (histórico de trocas).

### 4. Tabela exchange_history (Histórico de Trocas)
Registra o andamento e o status das trocas.
**Chave Primária**: id
**Chave Estrangeira**:
id_exchange → exchange.id_exchange (troca associada).

### 5. Tabela literary_group (Grupo Literário)
Armazena informações sobre grupos literários formados pelos usuários.
**Chave Primária**: id_group
**Chave Estrangeira**:
id_book → book.id_book (livro associado ao grupo).
Relacionamentos:
- Relacionada com user_group (usuários pertencentes ao grupo).

### 6. Tabela owner_history (Histórico de Propriedade)
Registra todas as mudanças de propriedade dos livros.
**Chave Primária**: id
**Chaves Estrangeiras**:
id_book → book.id_book
id_user → user.id_user

### 7. Tabela user_rating (Avaliação de Usuários)
Registra as avaliações feitas por um usuário sobre outro.
**Chave Primária**: id_rating
**Chaves Estrangeiras**:
rater_user_id → user.id_user (quem avaliou).
rated_user_id → user.id_user (quem foi avaliado).

### 8. Tabela user_group (Usuário em Grupo Literário)
Relaciona usuários aos grupos literários dos quais fazem parte.
**Chave Primária**: id
**Chaves Estrangeiras**:
id_user → user.id_user
id_group → literary_group.id_group


![Diagrama Relacional](/images/diagrama%20relacional%20troca%20de%20livros.png)
![Diagrama Conceitual](/images/Diagrama%20conceitual.png)

## Contribuição

### O que aceitamos como contribuição

1. Correções de Bugs
Se você encontrou um bug, entre em contato ou, se já estiver resolvido, envie um pull request com a correção.

2. Novas Funcionalidades
Se você tem uma ideia para uma nova funcionalidade, entre em contato para discutir sua implementação.

3. Melhorias na Documentação
Se você acha que a documentação pode ser melhorada, sinta-se à vontade para propor mudanças!

4. Sugestões e Feedback
Fique à vontade para enviar sugestões sobre como podemos melhorar o projeto.

### Como contribuir
1.	Faça um Fork do Repositório
Comece fazendo um fork deste repositório para criar sua própria versão do projeto.

2.	Clone o Repositório Forkado
Clone o repositório para o seu computador local para começar a fazer alterações:
git clone **https://github.com/seu-usuario/nome-do-repositorio.git**

3.	Crie uma Branch para sua Modificação
Isso ajuda a manter as alterações organizadas e evita conflitos:
**git checkout -b nome-da-sua-branch** 

4.	Faça suas alterações
Implemente as modificações desejadas ou adicione novas funcionalidades.

5.	Adicione e Commit suas Alterações
Após testar suas alterações, adicione e faça o commit das mudanças:
**git add .**
**git commit -m "Descrição clara das alterações feitas"**

6.	Envie um Pull Request (PR)
Após fazer o commit das alterações, envie um pull request (PR) para o repositório principal. Certifique-se de fornecer uma descrição clara e detalhada das alterações que você fez.

7.	Aguarde a Revisão do Código
Um dos mantenedores do projeto revisará suas alterações. Pode ser que você receba sugestões ou pedidos de ajustes antes da aceitação final.

### Dicas para Contribuintes

- Teste suas mudanças: Antes de submeter um pull request, verifique se o código funciona corretamente e se não quebra funcionalidades existentes.
- Seja claro nas mensagens de commit: Tente ser objetivo e explique o que está sendo feito e por quê.
- Siga o estilo de código: Ao contribuir, tente manter o estilo de código que já está sendo utilizado no projeto para garantir que o código seja coeso.

## Conatato
Ficou com alguma dúvida? Entre em contato com nossa squad:

**Bruna Tereza** - Estudante de Tecnologia da Informática e Desenvolvimento Web 
**Participação:** - Banco de Dados, gráficos, documentação
**LinkedIn**: https://www.linkedin.com/in/bruna-tereza-silva-2a20892a8/
**Email**: brunaaasilvaaa261@gmail.com

**Gustavo** - Estudante de Engenharia de Software
**Participação** - Consultas, inserção de dados
**LinkedIn**: https://www.linkedin.com/in/devgustavo-io
**Email**: contatoguillxr@gmail.com

**João** - Estudante de Desenvolvimento Web Full Stack
**Participação** - Diagrama Relacional e Gráficos
**LinkedIn**: https://www.linkedin.com/in/joaopedrodac
**Email**: joaopedrodacdel@gmail.com

**Luiz** - Estudante de Desenvolvimento de Sistemas
**Participação** - Gráficos, Análises
**LinkedIn**: https://www.linkedin.com/in/luiz-vinicius-825387309?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app
**Email**: yluvi2561@gmail.com

**Luiza Pureza** - Estudante de Programação 
**Participação** - Desenvolvimento de gráficos e diagrama
**LinkedIn**: https://www.linkedin.com/in/luiza-pureza-9bb4b4318?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app 
**Email**: luizapda24@gmail.com 

**Luísa Silva** - Estudante de Análise e Desenvolvimento de Sistemas
**Participação** - Gráficos, Documentação, Análise de Dados
**LinkedIn**: https://www.linkedin.com/in/luísa-caetano-silva/
**Email**: luisaregsilva@gmail.com

**Nataly Costa** - Estudante de Ciência da Computação
**Participação** - Gráficos, Consultas, Diagrama Relacional
**LinkedIn**: https://www.linkedin.com/in/natalycosta-dev/
**Email**: natalynaty653@gmail.com