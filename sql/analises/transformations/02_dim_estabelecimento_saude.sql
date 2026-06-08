-- 02_dim_estabelecimento_saude.sql
-- Dimensão dos estabelecimentos de saúde

CREATE OR REPLACE VIEW elt.vw_dim_estabelecimento_saude AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY cnes, nome_estabelecimento, razao_social,
                 logradouro, num_endereco, no_complemento,
                 bairro, cep, telefone, email
    ) AS id_estabelecimento,
    cnes,
    nome_estabelecimento,
    razao_social,
    logradouro,
    num_endereco,
    no_complemento,
    bairro,
    cep,
    telefone,
    email
FROM (
    SELECT DISTINCT
        cnes,
        nome_estabelecimento,
        razao_social,
        logradouro,
        num_endereco,
        no_complemento,
        bairro,
        cep,
        telefone,
        email
    FROM elt.vw_staging
    ORDER BY
        cnes, nome_estabelecimento, razao_social,
        logradouro, num_endereco, no_complemento,
        bairro, cep, telefone, email
) e;
