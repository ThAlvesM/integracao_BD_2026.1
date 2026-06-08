-- Tabela fato — chaves substitutas + métricas de leitos e UTIs

DROP TABLE IF EXISTS elt.fato_leitos_mensais;
CREATE TABLE elt.fato_leitos_mensais AS
SELECT

    -- ── Chaves substitutas ────────────────────────────────────────────────
    t.id_tempo,
    e.id_estabelecimento,
    l.id_localidade,
    tu.id_tipo_unidade,
    nj.id_natureza_juridica,
    g.id_gestao,

    -- ── Métricas (METRICAS_LEITOS do ETL) ────────────────────────────────
    s.leitos_existentes,
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
LEFT JOIN elt.vw_dim_tempo t
    ON s.competencia = t.competencia

-- Join na dimensão estabelecimento (chave composta, igual ao merge do ETL)
LEFT JOIN elt.vw_dim_estabelecimento_saude e
    ON  s.cnes                = e.cnes
    AND s.nome_estabelecimento = e.nome_estabelecimento
    AND s.razao_social         = e.razao_social
    AND s.no_logradouro        = e.no_logradouro
    AND s.num_endereco         = e.num_endereco
    AND s.no_complemento       = e.no_complemento
    AND s.bairro               = e.bairro
    AND s.cep                  = e.cep
    AND s.telefone             = e.telefone
    AND s.email                = e.email

-- Join na dimensão localidade (chave composta)
LEFT JOIN elt.vw_dim_localidade l
    ON  s.regiao    = l.regiao
    AND s.uf        = l.uf
    AND s.municipio = l.municipio

-- Join na dimensão tipo de unidade
LEFT JOIN elt.vw_dim_tipo_unidade tu
    ON  s.cod_tipo_unidade = tu.cod_tipo_unidade
    AND s.desc_tipo_unidade = tu.desc_tipo_unidade

-- Join na dimensão natureza jurídica
LEFT JOIN elt.vw_dim_natureza_juridica nj
    ON  s.natureza_juridica      = nj.natureza_juridica
    AND s.desc_natureza_juridica  = nj.desc_natureza_juridica

-- Join na dimensão gestão
LEFT JOIN elt.vw_dim_gestao g
    ON  s.tipo_gestao      = g.tipo_gestao
    AND s.descricao_gestao IS NOT DISTINCT FROM g.descricao_gestao;
    -- IS NOT DISTINCT FROM trata NULL = NULL como TRUE,
    -- necessário pois descricao_gestao pode ser NULL para tp_gestao fora do domínio