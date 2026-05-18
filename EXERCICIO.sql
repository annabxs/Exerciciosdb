CREATE DATABASE	IF NOT EXISTS empresa
CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;

USE empresa;

CREATE TABLE cliente(
	id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(254) UNIQUE,
    stats BOOLEAN DEFAULT TRUE NOT NULL,
    data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP 
)ENGINE=InnoDB;

SHOW TABLES;

DESCRIBE cliente;

SHOW INDEX FROM cliente;

CREATE TABLE categoria(
	id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(50) UNIQUE NOT NULL
)ENGINE=InnoDB;

CREATE TABLE produto(
	id_produto INT PRIMARY KEY AUTO_INCREMENT,
    nome varchar(100) NOT NULL,
	preco DECIMAL(10,2) NOT NULL CHECK (preco > 0),
    qtd_estoque INT NOT NULL DEFAULT 0,
    data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_categoria int NOT NULL,
    CONSTRAINT fk_produto_categoria
		FOREIGN KEY (id_categoria)
		REFERENCES categoria(id_categoria)
		ON DELETE RESTRICT
)ENGINE=InnoDB;

-- PERGUNTAS TÉCNICAS

/*1 - DECIMAL(10,2) Pois aceita valores exatos até 10 milhoes e com duas casas decimais (centavos). 
Mas esse valor pode ser modelado dependendo do modelo de negócios e para casos especificos para ocupar menos espaço. */

/*2 - Porque tem uma precisão aproximada, podendo ter erros de arredondamentos. Sendo assim inviável
para dinheiro e valores monetários. */

/*3 - O impacto gerado pelo uso de float como tipo de dado no sistema financeiro é considerado grave,
podendo resultar em consequências financeiras e técnicas severas, como erros de arredondamento, discrepância
em relatórios e rombos financeiros. */

/*4 - Teriamos problemas na hora de fazer um insert ocultando o valor do estoque, teríamos o seguinte erro:
"Field 'qtd_estoque' doesn't have a default value"
Além disso, em todo insert seríamos obrigados a inserir um valor para o estoque de determinado produto.*/

/*5 - Não é obrigatório, mas é o recomendado. O MySQL utiliza o InnoDb como engine automaticamente, entretanto definimos para termos uma garantia de comportamento, como no caso do InnoDB:
-Transaçoes na tabela
-FK
-Integridade
*/

/*6 Justificativas

-id_categoria: utilizamos o tipo int pois é o suficiente para o grande volume numérico.
-nome: utilizamos varchar(50) pois permite armazenar o nome de diversas categorias com o tamanho adequado.
*/

/*7 - Para garantir que o nome da categoria não se repita, ou seja, seja realmente único.*/

/*8 - Poderia ter redundância de nomes no sistema, duas categorias calçados, por exemplo.*/

/*9 - A tabela não tem integridade e nem se relacionaria com o restante do sistema, o que é inviável, já que trabalhamos com um sistema de banco relacional.*/

/*10 - Utilizamos ON DELETE RESTRICT pois ele garante que nenhuma categoria seja apagada se ainda houver registros de categorias na tabela.*/

/*11 - ON DELETE CASCADE deve ser utilizado quando os registros dependentes não fazem sentido sem o registro principal e o utilizamos assim para removê-los automaticamente ao deletar uma chave, ou seja, exluir o registro pai, também apaga os registros filhos.*/

/*12 - ON DELETE RESTRICT deve ser utilizado quando não permitimos a exclusão de um registro que possua dependências. Ele é essencial para podemos preservar a intengridade dos dados entre tabelas.*/

/*13 - Permitir SET NULL faz com que, ao excluir o registro pai, a chave estrangeira nos registros filhos seja definida como NULL.*/

/*14 - A regra no banco de dados garante a integridade das informações de forma centralizada e independente da aplicação,
evitando inconsistências mesmo em casos de falha ou múltiplos acessos. Já a regra na aplicação depende da implementação do sistema, podendo ser ignorada ou falhar,
o que compromete a confiabilidade dos dados.
*/

CREATE TABLE pedido(
	id_pedido INT PRIMARY KEY AUTO_INCREMENT,
	id_cliente INT NOT NULL,
    data_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_pedido DECIMAL(10,2) NOT NULL CHECK (valor_pedido > 0),
	CONSTRAINT fk_pedido_cliente
		FOREIGN KEY (id_cliente)
		REFERENCES cliente(id_cliente)
		ON DELETE CASCADE
        ON UPDATE CASCADE
)ENGINE=InnoDB;

CREATE TABLE pedido_item (
	id_item INT AUTO_INCREMENT PRIMARY KEY,
	id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    qtd INT NOT NULL CHECK (qtd > 0),
    preco_un DECIMAL(10,2) NOT NULL,
        
    CONSTRAINT fk_item_pedido
		FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
	CONSTRAINT fk_item_pedido_produto
		FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto)
        ON DELETE RESTRICT
)ENGINE=InnoDB;

INSERT INTO cliente (nome, email)
VALUES 
('Gabriel', 'gabrieldcarmo1@gmail.com'),
('Anna', 'annabxs1@gmail.com'),
('Enildo', 'enildocandido@gmail.com');
DELIMITER $$

INSERT INTO pedido (valor_pedido, id_cliente)
VALUES 
(200.00, 1),
(199.00, 2),
(198.00, 3);

/*ERRO PROPOSITAL:
INSERT INTO pedido (valor_pedido, id_cliente)
VALUES (302.00, 999);*/

/*
CALL inserir_pedido(302, 999)	Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`empresa`.`pedido`, CONSTRAINT `fk_pedido_cliente` FOREIGN KEY (`id_cliente`) 
REFERENCES `cliente` (`id_cliente`) ON DELETE CASCADE ON UPDATE CASCADE)	0.016 sec

O erro ocorre porque foi tentado inserir um pedido com um identificador de cliente inexistente.
*/

DELETE FROM cliente WHERE id_cliente = 1;

SELECT * FROM pedido WHERE id_cliente = 1;

/*Os pedidos do cliente foram apagados graças ao metodo ON DELETE CASCADE.*/

ALTER TABLE pedido
ADD desconto DECIMAL(5,2) NOT NULL;

ALTER TABLE pedido
ADD CONSTRAINT chk_desconto
CHECK (desconto >= 0 AND desconto <= 100);

INSERT INTO pedido (valor_pedido, id_cliente, desconto)
VALUES (150.00, 2, 10);

SELECT * FROM pedido where id_cliente = 2;

/* Foi utilizado ON DELETE CASCADE na tabela pedido_item em relação ao pedido, pois os itens não podem existir sem o pedido ao qual pertencem, estão totalmente relacionados. 
Dessa forma, ao excluir um pedido, todos os seus itens são automaticamente removidos*/

/* A regra ON DELETE RESTRICT é mais segura para a tabela produto, pois impede a exclusão de produtos que ainda estão associados a pedidos. Isso evita a perda de informações importantes e garante a consistência histórica das vendas */



