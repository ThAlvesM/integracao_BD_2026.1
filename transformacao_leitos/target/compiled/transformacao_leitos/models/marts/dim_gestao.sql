

SELECT
    ROW_NUMBER() OVER (ORDER BY tipo_gestao, descricao_gestao NULLS LAST) AS id_gestao,
    tipo_gestao,
    descricao_gestao
FROM (
    SELECT DISTINCT
        tipo_gestao,
        descricao_gestao
    FROM "projeto"."elt"."vw_staging"
    ORDER BY tipo_gestao, descricao_gestao NULLS LAST
) g