-- =========================================
-- PROJETO: LOCADORA DE JOGOS
-- =========================================

-- 1. CRIAÇÃO DO BANCO E DAS TABELAS
CREATE DATABASE IF NOT EXISTS locadora_jogos;
USE locadora_jogos;

USE locadora_jogos;
SELECT DATABASE();

USE locadora_jogos;
CREATE TABLE Jogos (
    id_jogo INT AUTO_INCREMENT PRIMARY KEY,
    nome_jogo VARCHAR(100) NOT NULL,
    genero VARCHAR(50) NOT NULL,
    preco_diaria DECIMAL(10,2) NOT NULL,
    classificacao_indicativa INT NOT NULL,
    disponibilidade BOOLEAN NOT NULL DEFAULT TRUE
);
SHOW TABLES;
CREATE TABLE Clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    contato VARCHAR(50) NOT NULL
);
CREATE TABLE Funcionarios (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    contato VARCHAR(50) NOT NULL
);
CREATE TABLE Locacoes (
    id_locacao INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_funcionario INT NOT NULL,
    data_locacao DATE NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (id_cliente)
        REFERENCES Clientes(id_cliente),

    FOREIGN KEY (id_funcionario)
        REFERENCES Funcionarios(id_funcionario)
);
CREATE TABLE Itens_Locacao (
    id_item INT AUTO_INCREMENT PRIMARY KEY,
    id_locacao INT NOT NULL,
    id_jogo INT NOT NULL,
    quantidade_dias INT NOT NULL,
    valor_item DECIMAL(10,2) NOT NULL,
    data_devolucao_prevista DATE NOT NULL,
    data_devolucao_real DATE NULL,

    FOREIGN KEY (id_locacao)
        REFERENCES Locacoes(id_locacao),

    FOREIGN KEY (id_jogo)
        REFERENCES Jogos(id_jogo),

    UNIQUE (id_locacao, id_jogo)
);

ALTER TABLE Jogos
ADD COLUMN plataforma VARCHAR(50) NOT NULL;
DESCRIBE Jogos;

USE locadora_jogos;

-- 2. INSERÇÃO DOS DADOS
INSERT INTO Jogos (
    nome_jogo,
    genero,
    preco_diaria,
    classificacao_indicativa,
    disponibilidade,
    plataforma
)
VALUES
('Minecraft', 'Sandbox', 15.00, 14, TRUE, 'Nintendo Switch'),
('Stardew Valley', 'Simulação', 13.00, 12, TRUE, 'Nintendo Switch'),
('Super Mario Kart', 'Corrida', 10.00, 0, TRUE, 'Super Nintendo'),
('Just Dance 2013', 'Música e dança', 12.00, 10, TRUE, 'Nintendo Wii'),
('Crash Bandicoot', 'Plataforma', 12.00, 10, TRUE, 'PlayStation 1'),
('Silent Hill f', 'Terror', 20.00, 18, TRUE, 'PlayStation 5'),
('Resident Evil Village', 'Terror', 18.00, 18, TRUE, 'PlayStation 5'),
('Astro Bot', 'Aventura e plataforma', 18.00, 0, TRUE, 'PlayStation 5'),
('Final Fantasy IX', 'RPG', 16.00, 12, TRUE, 'Nintendo Switch'),
('Mortal Kombat', 'Luta', 10.00, 14, TRUE, 'Super Nintendo');

-- Conferir os jogos cadastrados
SELECT * FROM Jogos;
SELECT COUNT(*) AS total_jogos
FROM Jogos;

-- Inserir cliente de teste
INSERT INTO Clientes (nome, contato)
VALUES ('Cliente Teste', 'teste@email.com');

-- Inserir funcionário de teste
INSERT INTO Funcionarios (nome, cargo, contato)
VALUES ('Funcionario Teste', 'Atendente', '11999999999');
-- 3. CRIAÇÃO DOS TRIGGERS
USE locadora_jogos;

DELIMITER //

CREATE TRIGGER trg_verifica_disponibilidade
BEFORE INSERT ON Itens_Locacao
FOR EACH ROW
BEGIN
    UPDATE Jogos
    SET disponibilidade = FALSE
    WHERE id_jogo = NEW.id_jogo
      AND disponibilidade = TRUE;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Este jogo nao esta disponivel para locacao.';
    END IF;
END//

DELIMITER ;

USE locadora_jogos;

DELIMITER //

CREATE TRIGGER trg_libera_disponibilidade
AFTER UPDATE ON Itens_Locacao
FOR EACH ROW
BEGIN
    IF OLD.data_devolucao_real IS NULL
       AND NEW.data_devolucao_real IS NOT NULL THEN

        UPDATE Jogos
        SET disponibilidade = TRUE
        WHERE id_jogo = NEW.id_jogo;

    END IF;
END//

DELIMITER ;

SHOW TRIGGERS FROM locadora_jogos;


-- 4. CONSULTAS E OPERAÇÕES SQL
SHOW TABLES;

SELECT * FROM Clientes;

USE locadora_jogos;
SELECT
    id_jogo,
    nome_jogo,
    genero,
    plataforma,
    preco_diaria,
    classificacao_indicativa,
    disponibilidade
FROM Jogos
ORDER BY nome_jogo;

-- 2. Listar somente os jogos disponíveis

SELECT
    nome_jogo,
    plataforma,
    preco_diaria
FROM Jogos
WHERE disponibilidade = TRUE
ORDER BY nome_jogo;

-- 3. Consultar locações com clientes, funcionários e jogos

SELECT
    L.id_locacao,
    C.nome AS cliente,
    F.nome AS funcionario,
    J.nome_jogo AS jogo,
    L.data_locacao,
    I.quantidade_dias,
    I.valor_item,
    I.data_devolucao_prevista,
    I.data_devolucao_real
FROM Locacoes L
INNER JOIN Clientes C
    ON L.id_cliente = C.id_cliente
INNER JOIN Funcionarios F
    ON L.id_funcionario = F.id_funcionario
INNER JOIN Itens_Locacao I
    ON L.id_locacao = I.id_locacao
INNER JOIN Jogos J
    ON I.id_jogo = J.id_jogo;

-- 4. Consultar o valor total de cada locação

SELECT
    L.id_locacao,
    C.nome AS cliente,
    SUM(I.valor_item) AS valor_total
FROM Locacoes L
INNER JOIN Clientes C
    ON L.id_cliente = C.id_cliente
INNER JOIN Itens_Locacao I
    ON L.id_locacao = I.id_locacao
GROUP BY
    L.id_locacao,
    C.nome;

-- 5. Registrar a devolução de um jogo

UPDATE Itens_Locacao
SET data_devolucao_real = CURDATE()
WHERE id_locacao = 1
  AND id_jogo = 1;

-- 6. Consultar jogos que ainda estão alugados

SELECT
    L.id_locacao,
    C.nome AS cliente,
    J.nome_jogo,
    I.data_devolucao_prevista
FROM Locacoes L
INNER JOIN Clientes C
    ON L.id_cliente = C.id_cliente
INNER JOIN Itens_Locacao I
    ON L.id_locacao = I.id_locacao
INNER JOIN Jogos J
    ON I.id_jogo = J.id_jogo
WHERE I.data_devolucao_real IS NULL;

USE locadora_jogos;

-- 1. Criar a primeira locação
INSERT INTO Locacoes (
    id_cliente, id_funcionario, data_locacao, valor_total
)
VALUES (1, 1, CURDATE(), 15.00);

-- 2. Adicionar Minecraft à locação
INSERT INTO Itens_Locacao (
    id_locacao, id_jogo, quantidade_dias, valor_item,
    data_devolucao_prevista, data_devolucao_real
)
VALUES (
    1, 1, 1, 15.00,
    DATE_ADD(CURDATE(), INTERVAL 1 DAY), NULL
);

-- 3. Verificar se o jogo ficou indisponível
SELECT id_jogo, nome_jogo, disponibilidade
FROM Jogos
WHERE id_jogo = 1;

-- 4. Criar uma segunda locação para testar o bloqueio
INSERT INTO Locacoes (
    id_cliente, id_funcionario, data_locacao, valor_total
)
VALUES (1, 1, CURDATE(), 15.00);

-- 5. TESTES DO SISTEMA
-- Os comandos abaixo documentam os testes realizados.
-- 5. Tentar alugar novamente o mesmo jogo
-- Resultado esperado: operação bloqueada pela trigger
--INSERT INTO Itens_Locacao (
   -- id_locacao, id_jogo, quantidade_dias, valor_item,
  --  data_devolucao_prevista, data_devolucao_real
--)
--VALUES (
  --  2, 1, 1, 15.00,
  --  DATE_ADD(CURDATE(), INTERVAL 1 DAY), NULL
--);

-- 6. Registrar a devolução
UPDATE Itens_Locacao
SET data_devolucao_real = CURDATE()
WHERE id_locacao = 1 AND id_jogo = 1;

-- 7. Verificar se o jogo voltou a ficar disponível
SELECT id_jogo, nome_jogo, disponibilidade
FROM Jogos
WHERE id_jogo = 1;

-- 6. FIM DO PROJETO