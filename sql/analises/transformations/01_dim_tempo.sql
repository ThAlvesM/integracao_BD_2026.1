-- Dimensão temporal derivada da coluna COMP (formato AAAAMM)

DROP TABLE IF EXISTS elt.dim_tempo;
CREATE TABLE elt.dim_tempo AS
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
    FROM elt.vw_staging
    ORDER BY competencia
) t;
