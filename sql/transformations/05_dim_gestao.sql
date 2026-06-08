-- Dimensão do tipo de gestão do estabelecimento

DROP TABLE IF EXISTS elt.dim_gestao;
CREATE TABLE elt.dim_gestao AS
SELECT
    ROW_NUMBER() OVER (ORDER BY tipo_gestao, descricao_gestao NULLS LAST) AS id_gestao,
    tipo_gestao,
    descricao_gestao
FROM (
    SELECT DISTINCT
        tipo_gestao,
        descricao_gestao
    FROM elt.vw_staging
    ORDER BY tipo_gestao, descricao_gestao NULLS LAST
) g;