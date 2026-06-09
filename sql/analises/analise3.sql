--  UF da região Nordeste teve maior quantidade de uti sus no ano de 2023
SELECT e.uf, t.ano, SUM(f.uti_total_sus)
FROM elt.dim_estabelecimento_saude e
JOIN elt.fato_leitos_mensais f ON f.id_estabelecimento = e.id_estabelecimento
JOIN elt.dim_tempo t ON t.id_tempo = f.id_tempo
WHERE t.ano = 2023
  AND e.regiao = 'nordeste'
GROUP BY e.uf, t.ano
ORDER BY SUM(f.uti_total_sus) DESC
LIMIT 1;
