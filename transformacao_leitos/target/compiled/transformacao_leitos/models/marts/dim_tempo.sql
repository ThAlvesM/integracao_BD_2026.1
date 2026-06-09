

SELECT
    ROW_NUMBER() OVER (ORDER BY competencia) AS id_tempo,
    competencia,
    data_competencia,
    ano,
    mes,
    nome_mes,
    trimestre
FROM (
    SELECT DISTINCT
        competencia,
        data_competencia,
        ano,
        mes,
        nome_mes,
        trimestre
    FROM "projeto"."elt"."vw_staging"
    ORDER BY competencia
) t