-- Média mensal de leitos existentes dos municípios de cada UF
SELECT uf, AVG(leitos_municipio)
FROM (
    SELECT e.uf, t.mes, t.ano, SUM(f.leitos_existentes) AS leitos_municipio
    FROM elt.fato_leitos_mensais f
    JOIN elt.dim_estabelecimento_saude e ON e.id_estabelecimento = f.id_estabelecimento
    JOIN elt.dim_tempo t ON t.id_tempo = f.id_tempo
    GROUP BY e.uf, t.mes, t.ano
) total_por_municipio
GROUP BY uf
ORDER BY AVG(leitos_municipio) DESC;
