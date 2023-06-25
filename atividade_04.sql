-- -------------------------------------------------------------------------------
-- -----------------------------------#1-------------------------------------------
create table funcionario
(
    nome     varchar(60) not null,
    email    varchar(60) not null,
    sexo     varchar(10) not null,
    ddd      integer,
    salario  real,
    telefone varchar(8),
    ativo    varchar(1),
    endereco varchar(70) not null,
    cpf      varchar(11) not null,
    cidade   varchar(20) not null,
    estado   varchar(2)  not null,
    bairro   varchar(20) not null,
    pais     varchar(20) not null,
    login    varchar(12) not null,
    senha    varchar(12) not null,
    news     varchar(8),
    id       integer     not null
        constraint funcionario_pk
            primary key
);


CREATE OR REPLACE FUNCTION DiminuirSalario(cpfToFind funcionario.cpf%TYPE, percentualDiminuiacao integer) RETURNS real as
'
    DECLARE
        funcionarioSelected funcionario%rowtype;
        newSalario funcionario.salario%TYPE;

    BEGIN
        select * into strict funcionarioSelected from funcionario where funcionario.cpf = cpfToFind;
        newSalario = funcionarioSelected.salario - (funcionarioSelected.salario * (percentualDiminuiacao / 100.00)) ;
        update funcionario set salario = newSalario where funcionario.cpf = funcionarioSelected.cpf;
        return newSalario;
    END;
' language plpgsql;


-- PERFORM DiminuirSalario('48507368824', 1);


-- -------------------------------------------------------------------------------
-- -----------------------------------#2-------------------------------------------
create table controle_falta
(
    funcionario_id integer not null
        constraint controle_falta_funcionario_id_fk
            references funcionario (id),
    data           date,
    justificativa  varchar(140) default true,
    constraint controle_falta_pk
        primary key (data, funcionario_id)
);


CREATE OR REPLACE FUNCTION HandleControleFalta () RETURNS trigger as
'
    DECLARE
        totalFaltasFuncionario INTEGER;
    BEGIN
        SELECT into totalFaltasFuncionario COUNT(*) as total from controle_falta where funcionario_id = new.funcionario_id;

        IF totalFaltasFuncionario = 5 THEN
            UPDATE funcionario SET ativo = ''N'' WHERE funcionario.id = new.funcionario_id;
        END IF;

        RETURN new;

    END;
' language plpgsql;


CREATE TRIGGER controle_faltas_trigger AFTER INSERT OR UPDATE ON controle_falta
    FOR EACH ROW EXECUTE PROCEDURE HandleControleFalta();


-- -------------------------------------------------------------------------------
-- -----------------------------------#3-------------------------------------------

create table controle_promocao
(
    funcionario_id integer not null constraint controle_promocao_funcionario_id_fk references funcionario (id),
    data           date,
    cargo  varchar(20) default true,
    nivel  varchar(5),
    constraint controle_promocao_pk primary key (data, funcionario_id, nivel)
);

CREATE TRIGGER controle_promocao_trigger BEFORE INSERT OR UPDATE ON controle_promocao
    FOR EACH ROW EXECUTE PROCEDURE HandleControlePromocao();


CREATE OR REPLACE FUNCTION HandleControlePromocao () RETURNS trigger as
'
    DECLARE
        lastPromotion controle_promocao%rowtype;
        lastNivel integer;
        currentNivel integer;
    BEGIN
        select * into lastPromotion from controle_promocao where new.funcionario_id = funcionario_id ORDER BY data DESC limit 1;

        IF lastPromotion IS NULL THEN
            return new;
        END IF;

        IF lastPromotion.cargo != new.cargo THEN
            raise exception '' Cargos Diferentes, não é permitido '';
        END IF;

        IF  ((new.data - lastPromotion.data) < 365 * 3) THEN
            raise exception '' Ultima promoçao aconteceu há menos de 3 anos. '';
        END IF;


        lastNivel       := CAST(lastPromotion.nivel as INTEGER);
        currentNivel    := CAST(new.nivel as INTEGER);

        IF currentNivel > 7 THEN
            raise exception ''O nível pode variar entre 1 e 7'';
        END IF;

        IF lastNivel = 0 and currentNivel = 1 THEN
            return new;
        ELSIF lastNivel = 1 and currentNivel = 2 THEN
            return new;
        ELSIF lastNivel = 2 and currentNivel = 3 THEN
            return new;
        ELSIF lastNivel = 3 and currentNivel = 4 THEN
            return new;
        ELSEIF lastNivel = 4 and currentNivel = 5 THEN
            return new;
        ELSEIF lastNivel = 5 and currentNivel = 6 THEN
            return new;
        ELSEIF lastNivel = 6 and currentNivel = 7 THEN
            return new;
        ELSE raise exception '' Acao Proibidida! Um funcionário só pode ser promovido para o nível imediatamente superior ao atual. '';
        END IF;

    END;
' language plpgsql;
