-- Dimensão geográfica (região, UF, município)

DROP TABLE IF EXISTS elt.dim_localidade;
CREATE TABLE elt.dim_localidade AS
SELECT
    ROW_NUMBER() OVER (ORDER BY regiao, uf, municipio) AS id_localidade,
    regiao,
    uf,
    municipio
FROM (
    SELECT DISTINCT
        regiao,
        uf,
        municipio
    FROM elt.vw_staging
    ORDER BY regiao, uf, municipio
) l;
