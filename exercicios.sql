create database if not exists DBempresa
character set utf8mb4
collate utf8mb4_general_ci;

use DBempresa;

create table if not exists TBcliente(
id_cli int primary key auto_increment,
nome_cli varchar(150) not null,
email_cli varchar(250) unique not null,
status_cli boolean default true,
data_cli datetime default current_timestamp
)engine = innoDB;

show tables from DBempresa;
describe table TBcliente;
show index from TBcliente;
 
 create table if not exists TBproduto(
	id_pro int primary key auto_increment,
    nome_pro varchar(150) not null,
    preco decimal(10,2) not null check(preco > 0),
    estoque_pro int default(0),
    data_cadastro datetime default current_timestamp
 )engine = innoDB;
 
/* Perguntas:

1 - O tipo de dado mais adequado para preço é DECIMAL(x,y), pois conseguimos definir mais adequadamente e precisamente a quantidade de casas decimais que o banco receberá. Sendo o mais adequado os parâmetros (10,2) INCOMPLETO 