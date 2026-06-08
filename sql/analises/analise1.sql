-- Município que teve a maior quantidade de leitos em 2024
-- Soma dos 12 meses de de 2024, ou seja, o valor fica 12 vezes maior que a quantidade de utis sus, mas a comparação ainda tem o resultado desejado.
SELECT t.ano, e.municipio, sum(f.leitos_sus) 
  FROM elt.fato_leitos_mensais f 
JOIN elt.dim_estabelecimento_saude e on e.id_estabelecimento = f.id_estabelecimento
JOIN elt.dim_tempo t on t.id_tempo = f.id_tempo
WHERE t.ano = 2024
GROUP BY t.ano, e.uf, e.municipio 
ORDER BY sum(f.leitos_sus) desc limit 1;
