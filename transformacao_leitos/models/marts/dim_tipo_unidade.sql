{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (ORDER BY cod_tipo_unidade, desc_tipo_unidade) AS id_tipo_unidade,
    cod_tipo_unidade,
    desc_tipo_unidade
FROM (
    SELECT DISTINCT
        cod_tipo_unidade,
        desc_tipo_unidade
    FROM {{ ref('vw_staging') }}
    ORDER BY cod_tipo_unidade, desc_tipo_unidade
) tu
