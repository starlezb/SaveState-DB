-- =========================================
-- PROJETO: LOCADORA DE JOGOS
-- SCRIPT 2: TESTES DOS REQUISITOS SQL
-- =========================================

-- 1. CRIAÇÃO DO BANCO DE TESTES

CREATE DATABASE IF NOT EXISTS testes_locadora_jogos;

USE testes_locadora_jogos;

SELECT DATABASE();

CREATE TABLE Dados_Extras (
    id_extra INT AUTO_INCREMENT PRIMARY KEY,
    data_registro DATETIME NOT NULL,
    observacoes TEXT,
    informacoes JSON
);

DESCRIBE Dados_Extras;

INSERT INTO Dados_Extras (
    data_registro,
    observacoes,
    informacoes
)
VALUES (
    NOW(),
    'Registro de demonstracao da locadora.',
    '{"jogo": "Minecraft", "plataforma": "Nintendo Switch", "preco": 15.00}'
);

SELECT * FROM Dados_Extras;

SELECT
    JSON_EXTRACT(informacoes, '$.jogo') AS nome_jogo,
    JSON_EXTRACT(informacoes, '$.plataforma') AS plataforma
FROM Dados_Extras;

UPDATE Dados_Extras
SET informacoes = JSON_SET(
    informacoes,
    '$.classificacao',
    14
)
WHERE id_extra = 1;

SELECT informacoes
FROM Dados_Extras
WHERE id_extra = 1;

CREATE TABLE Teste_Check (
    id INT AUTO_INCREMENT PRIMARY KEY,
    preco DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_preco_positivo CHECK (preco > 0)
);

DESCRIBE Teste_Check;

INSERT INTO Teste_Check (preco)
VALUES (15.00);

INSERT INTO Teste_Check (preco)
VALUES (-5.00);

SELECT *
FROM Dados_Extras
WHERE informacoes LIKE '%Minecraft%';

INSERT INTO Dados_Extras (
    data_registro,
    observacoes,
    informacoes
)
VALUES
(
    NOW(),
    'Registro de teste.',
    '{"jogo": "Stardew Valley", "preco": 13.00}'
),
(
    NOW(),
    'Registro de teste.',
    '{"jogo": "Resident Evil Village", "preco": 18.00}'
);

SELECT
    JSON_EXTRACT(informacoes, '$.jogo') AS jogo,
    JSON_EXTRACT(informacoes, '$.preco') AS preco
FROM Dados_Extras
WHERE CAST(JSON_UNQUOTE(JSON_EXTRACT(informacoes, '$.preco')) AS DECIMAL(10,2))
BETWEEN 12 AND 16;

SELECT
    JSON_EXTRACT(informacoes, '$.jogo') AS jogo,
    JSON_EXTRACT(informacoes, '$.preco') AS preco
FROM Dados_Extras
WHERE JSON_UNQUOTE(JSON_EXTRACT(informacoes, '$.jogo'))
IN ('Minecraft', 'Resident Evil Village');

CREATE TABLE Categorias_JOIN (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome_categoria VARCHAR(50) NOT NULL
);

CREATE TABLE Jogos_JOIN (
    id_jogo INT AUTO_INCREMENT PRIMARY KEY,
    nome_jogo VARCHAR(100) NOT NULL,
    id_categoria INT,
    FOREIGN KEY (id_categoria)
        REFERENCES Categorias_JOIN(id_categoria)
);

INSERT INTO Categorias_JOIN (nome_categoria)
VALUES
    ('Aventura'),
    ('Terror'),
    ('Simulacao'),
    ('Corrida');

INSERT INTO Jogos_JOIN (nome_jogo, id_categoria)
VALUES
    ('Minecraft', 1),
    ('Silent Hill f', 2),
    ('Stardew Valley', 3),
    ('Jogo sem categoria', NULL);

SELECT
    Jogos_JOIN.nome_jogo,
    Categorias_JOIN.nome_categoria
FROM Jogos_JOIN
INNER JOIN Categorias_JOIN
    ON Jogos_JOIN.id_categoria = Categorias_JOIN.id_categoria;

SELECT
    Jogos_JOIN.nome_jogo,
    Categorias_JOIN.nome_categoria
FROM Jogos_JOIN
LEFT JOIN Categorias_JOIN
    ON Jogos_JOIN.id_categoria = Categorias_JOIN.id_categoria;

SELECT
    Jogos_JOIN.nome_jogo,
    Categorias_JOIN.nome_categoria
FROM Jogos_JOIN
RIGHT JOIN Categorias_JOIN
    ON Jogos_JOIN.id_categoria = Categorias_JOIN.id_categoria;

SELECT
    Jogos_JOIN.nome_jogo,
    Categorias_JOIN.nome_categoria
FROM Jogos_JOIN
CROSS JOIN Categorias_JOIN;

CREATE TABLE Teste_Alteracoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);

ALTER TABLE Teste_Alteracoes
ADD COLUMN observacao VARCHAR(50);

ALTER TABLE Teste_Alteracoes
MODIFY COLUMN observacao VARCHAR(100);

ALTER TABLE Teste_Alteracoes
CHANGE COLUMN observacao comentario VARCHAR(100);

ALTER TABLE Teste_Alteracoes
DROP COLUMN comentario;

CREATE TABLE Teste_Manipulacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) NOT NULL
);

DESCRIBE Teste_Manipulacao;

INSERT INTO Teste_Manipulacao (nome, preco)
VALUES
    ('Minecraft', 15.00),
    ('Stardew Valley', 13.00);

UPDATE Teste_Manipulacao
SET preco = 17.00
WHERE id = 1;

SELECT * 
FROM Teste_Manipulacao;

DELETE FROM Teste_Manipulacao
WHERE id = 2;

CREATE TABLE Teste_Transacoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

START TRANSACTION;

INSERT INTO Teste_Transacoes (descricao)
VALUES ('Registro que sera desfeito');

ROLLBACK;

SELECT * FROM Teste_Transacoes;

START TRANSACTION;

INSERT INTO Teste_Transacoes (descricao)
VALUES ('Registro confirmado com COMMIT');

COMMIT;

SELECT * FROM Teste_Transacoes;

DROP TABLE Teste_Alteracoes;

SELECT DATABASE();

DROP DATABASE testes_locadora_jogos;