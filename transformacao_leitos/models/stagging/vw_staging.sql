-- models/staging/vw_staging.sql
-- View de staging: limpeza e padronização da base bruta
-- Materializada como VIEW — recalculada a cada consulta das marts

{{ config(materialized='view') }}

SELECT

    -- ── CÓDIGOS (texto, zeros à esquerda garantidos) ──────────────────────
    LPAD(REGEXP_REPLACE(TRIM(comp::TEXT),              '\.0$', ''), 6, '0') AS competencia,
    LPAD(REGEXP_REPLACE(TRIM(cnes::TEXT),              '\.0$', ''), 7, '0') AS cnes,
    LPAD(REGEXP_REPLACE(TRIM(co_tipo_unidade::TEXT),   '\.0$', ''), 2, '0') AS cod_tipo_unidade,
    LPAD(REGEXP_REPLACE(TRIM(natureza_juridica::TEXT),  '\.0$', ''), 4, '0') AS natureza_juridica,
    LPAD(REGEXP_REPLACE(TRIM(co_cep::TEXT),            '\.0$', ''), 8, '0') AS cep,
    LPAD(REGEXP_REPLACE(TRIM(nu_endereco::TEXT),       '\.0$', ''), 0, '0') AS num_endereco,

    -- ── TEXTOS (strip + lower + nulo → nao_informado) ─────────────────────
    COALESCE(LOWER(TRIM(regiao::TEXT)),                'nao_informado') AS regiao,
    COALESCE(LOWER(TRIM(uf::TEXT)),                    'nao_informado') AS uf,
    COALESCE(LOWER(TRIM(municipio::TEXT)),             'nao_informado') AS municipio,
    COALESCE(LOWER(TRIM(nome_estabelecimento::TEXT)),  'nao_informado') AS nome_estabelecimento,
    COALESCE(LOWER(TRIM(razao_social::TEXT)),          'nao_informado') AS razao_social,
    COALESCE(LOWER(TRIM(tp_gestao::TEXT)),             'nao_informado') AS tipo_gestao,
    COALESCE(LOWER(TRIM(ds_tipo_unidade::TEXT)),       'nao_informado') AS desc_tipo_unidade,
    COALESCE(LOWER(TRIM(desc_natureza_juridica::TEXT)), 'nao_informado') AS desc_natureza_juridica,
    COALESCE(LOWER(TRIM(no_logradouro::TEXT)),         'nao_informado') AS logradouro,
    COALESCE(LOWER(TRIM(no_complemento::TEXT)),        'nao_informado') AS no_complemento,
    COALESCE(LOWER(TRIM(no_bairro::TEXT)),             'nao_informado') AS bairro,
    COALESCE(LOWER(TRIM(nu_telefone::TEXT)),           'nao_informado') AS telefone,
    COALESCE(LOWER(TRIM(no_email::TEXT)),              'nao_informado') AS email,

    -- ── GESTÃO (descrição via CASE) ───────────────────────────────────────
    COALESCE(LOWER(TRIM(tp_gestao::TEXT)), 'nao_informado') AS tipo_gestao_raw,
    CASE LOWER(TRIM(tp_gestao::TEXT))
        WHEN 'm' THEN 'municipal'
        WHEN 'e' THEN 'estadual'
        WHEN 'd' THEN 'dupla'
        ELSE NULL
    END AS descricao_gestao,

    -- ── TEMPORAL (derivado de COMP = AAAAMM) ──────────────────────────────
    TO_DATE(
        LPAD(REGEXP_REPLACE(TRIM(comp::TEXT), '\.0$', ''), 6, '0') || '01',
        'YYYYMMDD'
    ) AS data_competencia,

    EXTRACT(YEAR FROM
        TO_DATE(LPAD(REGEXP_REPLACE(TRIM(comp::TEXT), '\.0$', ''), 6, '0') || '01', 'YYYYMMDD')
    )::INT AS ano,

    EXTRACT(MONTH FROM
        TO_DATE(LPAD(REGEXP_REPLACE(TRIM(comp::TEXT), '\.0$', ''), 6, '0') || '01', 'YYYYMMDD')
    )::INT AS mes,

    EXTRACT(QUARTER FROM
        TO_DATE(LPAD(REGEXP_REPLACE(TRIM(comp::TEXT), '\.0$', ''), 6, '0') || '01', 'YYYYMMDD')
    )::INT AS trimestre,

    CASE EXTRACT(MONTH FROM
        TO_DATE(LPAD(REGEXP_REPLACE(TRIM(comp::TEXT), '\.0$', ''), 6, '0') || '01', 'YYYYMMDD')
    )::INT
        WHEN 1  THEN 'janeiro'    WHEN 2  THEN 'fevereiro'
        WHEN 3  THEN 'marco'      WHEN 4  THEN 'abril'
        WHEN 5  THEN 'maio'       WHEN 6  THEN 'junho'
        WHEN 7  THEN 'julho'      WHEN 8  THEN 'agosto'
        WHEN 9  THEN 'setembro'   WHEN 10 THEN 'outubro'
        WHEN 11 THEN 'novembro'   WHEN 12 THEN 'dezembro'
    END AS nome_mes,

    -- ── MÉTRICAS (nulo → 0) ───────────────────────────────────────────────
    COALESCE(leitos_existentes::INT,     0) AS leitos_existentes,
    COALESCE(leitos_sus::INT,            0) AS leitos_sus,
    COALESCE(uti_total_exist::INT,       0) AS uti_total_exist,
    COALESCE(uti_total_sus::INT,         0) AS uti_total_sus,
    COALESCE(uti_adulto_exist::INT,      0) AS uti_adulto_exist,
    COALESCE(uti_adulto_sus::INT,        0) AS uti_adulto_sus,
    COALESCE(uti_pediatrico_exist::INT,  0) AS uti_pediatrico_exist,
    COALESCE(uti_pediatrico_sus::INT,    0) AS uti_pediatrico_sus,
    COALESCE(uti_neonatal_exist::INT,    0) AS uti_neonatal_exist,
    COALESCE(uti_neonatal_sus::INT,      0) AS uti_neonatal_sus,
    COALESCE(uti_queimado_exist::INT,    0) AS uti_queimado_exist,
    COALESCE(uti_queimado_sus::INT,      0) AS uti_queimado_sus,
    COALESCE(uti_coronariana_exist::INT, 0) AS uti_coronariana_exist,
    COALESCE(uti_coronariana_sus::INT,   0) AS uti_coronariana_sus

FROM leitos_raw.leitos_bruto
-- motivo_desabilitacao descartada
