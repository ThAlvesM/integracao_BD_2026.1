-- Dimensão geográfica (região, UF, município)

CREATE OR REPLACE VIEW elt.vw_dim_localidade AS
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
