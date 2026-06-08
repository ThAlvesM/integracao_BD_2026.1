-- Dimensão do tipo de unidade de saúde

DROP TABLE IF EXISTS elt.dim_tipo_unidade;
CREATE OR REPLACE TABLE elt.dim_tipo_unidade AS
SELECT
    ROW_NUMBER() OVER (ORDER BY cod_tipo_unidade, desc_tipo_unidade) AS id_tipo_unidade,
    cod_tipo_unidade,
    desc_tipo_unidade
FROM (
    SELECT DISTINCT
        cod_tipo_unidade,
        desc_tipo_unidade
    FROM elt.vw_staging
    ORDER BY cod_tipo_unidade, desc_tipo_unidade
) tu;