-- Dimensão da natureza jurídica do estabelecimento

DROP TABLE IF EXISTS elt.dim_natureza_juridica;
CREATE TABLE elt.dim_natureza_juridica AS
SELECT
    ROW_NUMBER() OVER (ORDER BY natureza_juridica, desc_natureza_juridica) AS id_natureza_juridica,
    natureza_juridica,
    desc_natureza_juridica
FROM (
    SELECT DISTINCT
        natureza_juridica,
        desc_natureza_juridica
    FROM elt.vw_staging
    ORDER BY natureza_juridica, desc_natureza_juridica
) nj;