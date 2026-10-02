DROP VIEW  IF EXISTS vw_faturamento_por_voo;
DROP VIEW  IF EXISTS vw_painel_aeroporto;
DROP TABLE IF EXISTS passagens;
DROP TABLE IF EXISTS voos;
DROP TABLE IF EXISTS passageiros;
DROP TABLE IF EXISTS pilotos;
DROP TABLE IF EXISTS aeronaves;

CREATE TABLE aeronaves (
    id           SERIAL PRIMARY KEY,
    modelo       VARCHAR(100) NOT NULL,
    codigo_cauda VARCHAR(10)  NOT NULL UNIQUE,
    capacidade   INT NOT NULL CHECK (capacidade > 0)
);

CREATE TABLE pilotos (
    id          SERIAL PRIMARY KEY,
    nome        VARCHAR(100) NOT NULL,
    codigo_anac CHAR(6) NOT NULL UNIQUE,
    horas_voo   INT DEFAULT 0 CHECK (horas_voo >= 0)
);

CREATE TABLE voos (
    id          SERIAL PRIMARY KEY,
    aeronave_id INT NOT NULL REFERENCES aeronaves(id),
    piloto_id   INT NOT NULL REFERENCES pilotos(id),
    numero_voo  VARCHAR(10) NOT NULL,
    origem      VARCHAR(50) NOT NULL,
    destino     VARCHAR(50) NOT NULL,
    data_hora   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status      VARCHAR(20) DEFAULT 'Agendado'
    CHECK (status IN ('Agendado', 'Em Voo', 'Concluido', 'Cancelado'))
);

CREATE TABLE passageiros (
    id    SERIAL PRIMARY KEY,
    nome  VARCHAR(100) NOT NULL,
    cpf   CHAR(11) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE passagens (
    id            SERIAL PRIMARY KEY,
    voo_id        INT NOT NULL REFERENCES voos(id),
    passageiro_id INT NOT NULL REFERENCES passageiros(id),
    assento       VARCHAR(4) NOT NULL,
    classe        VARCHAR(20) DEFAULT 'Economica'
      CHECK (classe IN ('Economica', 'Executiva')),
    valor         DECIMAL(10,2) NOT NULL CHECK (valor > 0)
);

INSERT INTO aeronaves (modelo, codigo_cauda, capacidade) VALUES
('Boeing 737',   'PR-ABC1', 180),
('Airbus A320',  'PR-DEF2', 174),
('Embraer E195', 'PR-GHI3', 118),
('ATR 72',       'PR-JKL4', 70),
('Airbus A330',  'PR-MNO5', 280);

INSERT INTO pilotos (nome, codigo_anac, horas_voo) VALUES
('Carlos Silva',   '100001', 5200),
('Ana Souza',      '100002', 3100),
('Pedro Lima',     '100003', 8700),
('Marina Costa',   '100004', 1500),
('Rafael Oliveira','100005', 6400);

INSERT INTO passageiros (nome, cpf, email) VALUES
('João Pereira',  '11111111111', 'joao@email.com'),
('Maria Santos',  '22222222222', 'maria@email.com'),
('Lucas Almeida', '33333333333', 'lucas@email.com'),
('Julia Ferreira','44444444444', 'julia@email.com'),
('Bruno Rocha',   '55555555555', 'bruno@email.com');

INSERT INTO voos (aeronave_id, piloto_id, numero_voo, origem, destino, data_hora, status) VALUES
(1, 1, 'AT1001', 'Florianópolis', 'São Paulo',      '2026-10-10 08:00', 'Agendado'),
(2, 2, 'AT1002', 'São Paulo',     'Rio de Janeiro', '2026-10-02 14:30', 'Em Voo'),
(3, 3, 'AT1003', 'Curitiba',      'Brasília',       '2026-09-28 10:15', 'Concluido'),
(4, 4, 'AT1004', 'Porto Alegre',  'Florianópolis',  '2026-10-15 17:45', 'Cancelado'),
(5, 5, 'AT1005', 'Rio de Janeiro','Lisboa',         '2026-10-20 22:00', 'Agendado');

INSERT INTO passagens (voo_id, passageiro_id, assento, classe, valor) VALUES
(1, 1, '12A', 'Economica', 450.00),
(1, 2, '01B', 'Executiva', 950.00),
(2, 3, '15C', 'Economica', 380.00),
(5, 4, '02A', 'Executiva', 1500.00),
(3, 5, '20D', 'Economica', 520.00);

SELECT v.numero_voo, v.origem, v.destino, a.modelo, p.nome AS piloto
FROM voos v
JOIN aeronaves a ON a.id = v.aeronave_id
JOIN pilotos   p ON p.id = v.piloto_id
WHERE v.status IN ('Agendado', 'Em Voo');

SELECT classe, SUM(valor) AS total_arrecadado
FROM passagens
GROUP BY classe;

SELECT pa.nome, v.numero_voo, ps.assento, ps.valor
FROM passagens ps
JOIN passageiros pa ON pa.id = ps.passageiro_id
JOIN voos v         ON v.id  = ps.voo_id
WHERE ps.classe = 'Executiva' AND ps.valor > 800
ORDER BY ps.valor DESC;

CREATE VIEW vw_painel_aeroporto AS
SELECT v.numero_voo, v.data_hora, v.origem, v.destino,
       a.modelo, a.codigo_cauda, v.status
FROM voos v
JOIN aeronaves a ON a.id = v.aeronave_id;

CREATE VIEW vw_faturamento_por_voo AS
SELECT v.id AS voo_id, v.numero_voo, v.destino,
       COUNT(ps.id) AS total_passageiros,
       COALESCE(SUM(ps.valor), 0) AS receita_total
FROM voos v
LEFT JOIN passagens ps ON ps.voo_id = v.id
GROUP BY v.id, v.numero_voo, v.destino;

SELECT * FROM vw_painel_aeroporto;
SELECT * FROM vw_faturamento_por_voo;