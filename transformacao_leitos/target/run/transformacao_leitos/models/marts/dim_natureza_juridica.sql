
  
    

  create  table "projeto"."elt_elt"."dim_natureza_juridica__dbt_tmp"
  
  
    as
  
  (
    

SELECT
    ROW_NUMBER() OVER (ORDER BY natureza_juridica, desc_natureza_juridica) AS id_natureza_juridica,
    natureza_juridica,
    desc_natureza_juridica
FROM (
    SELECT DISTINCT
        natureza_juridica,
        desc_natureza_juridica
    FROM "projeto"."elt"."vw_staging"
    ORDER BY natureza_juridica, desc_natureza_juridica
) nj
  );
  