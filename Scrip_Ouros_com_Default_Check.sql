/* ScriptSQL do Ouros com DEFAULT e CHECK já implementado */

CREATE TABLE administrador (
	id SERIAL PRIMARY KEY,
	email VARCHAR(255) NOT NULL,
	senha VARCHAR(255) NOT NULL,
	cpf VARCHAR(14) NOT NULL UNIQUE,
        nome VARCHAR(100) NOT NULL,
	foto_perfil_url TEXT,
	
    CONSTRAINT uq_administrador_email UNIQUE (email)
);

CREATE TABLE telefone_admin (
    id SERIAL PRIMARY KEY,
	id_administrador INT NOT NULL,
	telefone VARCHAR(20),
	CONSTRAINT fk_telefone_admin FOREIGN KEY(id_administrador) REFERENCES administrador(id)

);

CREATE TABLE empresa (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone_corporativo VARCHAR(20) NOT NULL,
    email_corporativo VARCHAR(255) NOT NULL,
    cnpj VARCHAR(14) NOT NULL,
	
	CONSTRAINT uq_empresa_cnpj UNIQUE (cnpj)
);

CREATE TABLE granja (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    capacidade_aves INT NOT NULL,
    regiao VARCHAR(50) NOT NULL,
    area_propriedade DECIMAL(10,2) NOT NULL,
    id_empresa INT NOT NULL,
	
	CONSTRAINT fk_granja_empresa FOREIGN KEY(id_empresa) REFERENCES empresa(id)
);

CREATE TABLE proprietario_granja (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    id_granja INT NOT NULL,

	CONSTRAINT uq_proprietario_granja_cpf UNIQUE (cpf),
	CONSTRAINT uq_proprietario_granja_email UNIQUE (email),
	CONSTRAINT fk_proprietario_granja_granja FOREIGN KEY(id_granja) REFERENCES granja(id)
);

CREATE TABLE telefone_proprietario (
    id SERIAL PRIMARY KEY,
    telefone VARCHAR(20) NOT NULL,
    id_proprietario INT NOT NULL,
	
	CONSTRAINT fk_telefone_proprietario_proprietario_granja FOREIGN KEY(id_proprietario) REFERENCES proprietario_granja(id)
);

CREATE TABLE lote (
    id SERIAL PRIMARY KEY,
    galinhas_entregadas INT NOT NULL DEFAULT 0,
    galinhas_recebidas INT NOT NULL,
    dt_nascimento DATE NOT NULL,
    dt_chegada DATE NOT NULL,
    dt_entrega DATE,
    ganho DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    id_granja INT NOT NULL,

	CONSTRAINT chk_lote_galinhas_recebidas CHECK (galinhas_recebidas > 0),
	CONSTRAINT chk_lote_galinhas_entregadas CHECK (galinhas_entregadas <= galinhas_recebidas),
	CONSTRAINT chk_lote_ganho CHECK (ganho >= 0),
	CONSTRAINT chk_lote_ordem_datas CHECK (
        dt_nascimento <= dt_chegada AND 
        (dt_entrega IS NULL OR dt_chegada <= dt_entrega)
	),
	CONSTRAINT fk_lote_granja FOREIGN KEY(id_granja) REFERENCES granja(id)
	
);

CREATE TABLE meta (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    descricao TEXT NOT NULL,
    tipo_meta VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'NAO_INICIADA',
    valor_alvo DECIMAL(10,2) NOT NULL,
    regiao VARCHAR(50),
    estado VARCHAR(50),
    is_individual BOOLEAN NOT NULL DEFAULT FALSE,
    id_granja INT,

	CONSTRAINT chk_meta_tipo_alocacao CHECK (
    (is_individual = TRUE AND id_granja IS NOT NULL) OR 
    (is_individual = FALSE AND id_granja IS NULL)
	),
	CONSTRAINT chk_meta_status CHECK (status IN ('NAO_INICIADA', 'EM_ANDAMENTO', 'FINALIZADA')),
	CONSTRAINT fk_meta_granja FOREIGN KEY(id_granja) REFERENCES granja(id)

);

CREATE TABLE dica (
    id SERIAL PRIMARY KEY,
    descricao TEXT NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    id_granja INT NOT NULL,
	CONSTRAINT fk_dica_granja FOREIGN KEY(id_granja) REFERENCES granja(id)
);

CREATE TABLE avaliacao (
    id SERIAL PRIMARY KEY,
    comentario TEXT,
    nota NUMERIC(2,1) NOT NULL,
    id_dica INT NOT NULL,
    
    CONSTRAINT chk_avaliacao_nota CHECK (nota >= 0.0 AND nota <= 5.0),
    CONSTRAINT fk_avaliacao_dica FOREIGN KEY(id_dica) REFERENCES dica(id)
);

CREATE TABLE registro_energia (
    id SERIAL PRIMARY KEY,
    dt_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    consumo DECIMAL(10,2) NOT NULL,
    id_lote INT NOT NULL,

	CONSTRAINT chk_registro_energia_consumo CHECK (consumo >= 0),
	CONSTRAINT fk_registro_energia_lote FOREIGN KEY(id_lote) REFERENCES lote(id)

);

CREATE TABLE registro_agua (
    id SERIAL PRIMARY KEY,
    dt_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    hidrometro_inicio DECIMAL(10,2) NOT NULL,
    hidrometro_final DECIMAL(10,2) NOT NULL,
    id_lote INT NOT NULL,

	CONSTRAINT chk_registro_agua_hidrometro_inicio CHECK (hidrometro_inicio >= 0),
    CONSTRAINT chk_registro_agua_hidrometro_ordem CHECK (hidrometro_final >= hidrometro_inicio),
	CONSTRAINT fk_registro_agua_lote FOREIGN KEY(id_lote) REFERENCES lote(id)
);


CREATE TABLE funcionario (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) NOT NULL,
    email VARCHAR(255) NOT NULL,
    setor VARCHAR(50) NOT NULL,
	senha VARCHAR(255) NOT NULL,
    id_empresa INT NOT NULL,

	CONSTRAINT uq_funcionario_cpf UNIQUE (cpf),
	CONSTRAINT uq_funcionario_email UNIQUE (email),
	CONSTRAINT fk_funcionario_empresa FOREIGN KEY(id_empresa) REFERENCES empresa(id)
);

CREATE TABLE endereco_proprietario (
    id SERIAL PRIMARY KEY,
    cep VARCHAR(8) NOT NULL,
    numero INT NOT NULL,
    municipio VARCHAR(100),
    estado VARCHAR(50),
    logradouro VARCHAR(150),
    id_proprietario INT NOT NULL,
	pais VARCHAR(100) NOT NULL,
	
	CONSTRAINT fk_endereco_proprietario_proprietario_granja FOREIGN KEY(id_proprietario) REFERENCES proprietario_granja(id)
);

CREATE TABLE endereco_empresa (
    id SERIAL PRIMARY KEY,
    cep VARCHAR(8) NOT NULL,
    numero INT NOT NULL,
    municipio VARCHAR(100),
    estado VARCHAR(50),
    logradouro VARCHAR(150),
	pais VARCHAR(100) NOT NULL,
    id_empresa INT NOT NULL,
	
	CONSTRAINT fk_endereco_empresa_empresa FOREIGN KEY(id_empresa) REFERENCES empresa(id)
);

CREATE TABLE endereco_granja (
    id SERIAL PRIMARY KEY,
    cep VARCHAR(8) NOT NULL,
    numero INT NOT NULL,
    municipio VARCHAR(100),
    estado VARCHAR(50),
    logradouro VARCHAR(150) NOT NULL,
	pais VARCHAR(100) NOT NULL,
    id_granja INT NOT NULL,
	
	CONSTRAINT fk_endereco_granja_granja FOREIGN KEY(id_granja) REFERENCES granja(id)
);

CREATE TABLE telefone_funcionario (
    id SERIAL PRIMARY KEY,
    telefone VARCHAR(20) NOT NULL,
    id_funcionario INT NOT NULL,

	CONSTRAINT fk_telefone_funcionario_funcionario FOREIGN KEY(id_funcionario) REFERENCES funcionario(id)
);