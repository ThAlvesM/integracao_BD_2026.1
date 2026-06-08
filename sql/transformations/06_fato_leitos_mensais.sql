-- Tabela fato — chaves substitutas + métricas de leitos e UTIs

DROP TABLE IF EXISTS elt.fato_leitos_mensais;
CREATE TABLE elt.fato_leitos_mensais AS
SELECT

    -- ── Chaves substitutas ────────────────────────────────────────────────
    t.id_tempo,
    e.id_estabelecimento,
    tu.id_tipo_unidade,
    nj.id_natureza_juridica,
    g.id_gestao,

    -- ── Métricas (METRICAS_LEITOS do ETL) ────────────────────────────────
    s.leitos_exist,
    s.leitos_sus,
    s.uti_total_exist,
    s.uti_total_sus,
    s.uti_adulto_exist,
    s.uti_adulto_sus,
    s.uti_pediatrico_exist,
    s.uti_pediatrico_sus,
    s.uti_neonatal_exist,
    s.uti_neonatal_sus,
    s.uti_queimado_exist,
    s.uti_queimado_sus,
    s.uti_coronariana_exist,
    s.uti_coronariana_sus

FROM elt.vw_staging s

-- Join na dimensão tempo (chave: competencia)
LEFT JOIN elt.dim_tempo t
    ON s.competencia = t.competencia

-- Join na dimensão estabelecimento (absorvendo atributos de localidade)
LEFT JOIN elt.dim_estabelecimento_saude e
    ON  s.cnes                = e.cnes
    AND s.nome_estabelecimento = e.nome_estabelecimento
    AND s.razao_social         = e.razao_social
    AND s.regiao               = e.regiao
    AND s.uf                   = e.uf
    AND s.municipio            = e.municipio
    AND s.logradouro           = e.logradouro  -- Corrigido de no_logradouro para logradouro
    AND s.num_endereco         = e.num_endereco
    AND s.no_complemento       = e.no_complemento
    AND s.bairro               = e.bairro
    AND s.cep                  = e.cep
    AND s.telefone             = e.telefone
    AND s.email                = e.email

-- Join na dimensão tipo de unidade
LEFT JOIN elt.dim_tipo_unidade tu
    ON  s.cod_tipo_unidade = tu.cod_tipo_unidade
    AND s.desc_tipo_unidade = tu.desc_tipo_unidade

-- Join na dimensão natureza jurídica
LEFT JOIN elt.dim_natureza_juridica nj
    ON  s.natureza_juridica      = nj.natureza_juridica
    AND s.desc_natureza_juridica  = nj.desc_natureza_juridica

-- Join na dimensão gestão
LEFT JOIN elt.dim_gestao g
    ON  s.tipo_gestao      = g.tipo_gestao
    AND s.descricao_gestao IS NOT DISTINCT FROM g.descricao_gestao;
