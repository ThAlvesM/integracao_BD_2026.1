{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (
        ORDER BY cnes, nome_estabelecimento, razao_social,
                 regiao, uf, municipio,
                 logradouro, num_endereco, no_complemento,
                 bairro, cep, telefone, email
    ) AS id_estabelecimento,
    cnes,
    nome_estabelecimento,
    razao_social,
    regiao,
    uf,
    municipio,
    logradouro,
    num_endereco,
    no_complemento,
    bairro,
    cep,
    telefone,
    email
FROM (
    SELECT DISTINCT
        cnes, nome_estabelecimento, razao_social,
        regiao, uf, municipio,
        logradouro, num_endereco, no_complemento,
        bairro, cep, telefone, email
    FROM {{ ref('vw_staging') }}
    ORDER BY
        cnes, nome_estabelecimento, razao_social,
        regiao, uf, municipio,
        logradouro, num_endereco, no_complemento,
        bairro, cep, telefone, email
) e
