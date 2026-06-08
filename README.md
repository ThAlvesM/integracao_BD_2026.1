# integracao_BD_2026.1
Projeto de Integração da cadeira de  Banco de Dados usando PostgreSQL

## Arquitetura do Projeto

### Estrutura de Arquivos

```
projeto-receitas-recife/
│
├── database/data_raw
│   ├── Leitos_2023.csv     
|   ├── Leitos_2024.csv
│   └── Leitos_2025.csv                        
│
├── notebooks/
│   ├── ELT.ipynb                   
│   └── ETL.ipynb                   
│
├── transformacao_receitas/
│   ├── analises/
│   │   ├── entidade_menor_receita_anual.sql
│   │   ├── origem_recurso_n_vinculado.sql
│   │   └── receita_media_orgaos_anual.sql
│   │
│   └── transformations/
│       ├── 00_staging.sql
│       ├── 01_dim_tempo.sql
│       ├── 02_dim_establecimento_saude.sql
│       ├── 03_dim_localidade.sql
│       ├── 04_dim_origem_dbt.sql
│       ├── 05_dim_natureza_juridica.sql
│       ├── 06_dim_gestao.sql
│       └── 07_fato_leitos_mensais.sql
│
├── .env_exemplo
├── .gitignore
├── dockr-compose.yml
└── README.md
```

## Modelagem do Data Warehouse

### Esquema Estrela (Star Schema)

O projeto implementa um modelo dimensional com as seguintes tabelas:

#### Tabela Fato
- **fato_leitos_mensais**: Contém as métricas de receitas
  - `id_tempo_sk` (FK)
  - `id_estabelecimento` (FK)
  - `id_tipo_unidade` (FK)
  - `id_natureza_juridica` (FK)
  - `id_gestao` (FK)  
  - `leitos_existentes`
  - `leitos_sus`
  - `uti_total_exist`
  - `uti_total_sus`
  - `uti_adulto_exist`
  - `uti_adulto_sus`
  - `uti_pediatrico_exist`
  - `uti_pediatrico_sus`
  - `uti_neonatal_exist`
  - `uti_neonatal_sus`
  - `uti_queimado_exist`
  - `uti_queimado_sus`
  - `uti_coronariana_exist`
  - `uti_coronariana_sus`

#### Tabelas Dimensão

1. **dim_tempo**: Dimensão temporal
   - `id_tempo` (PK)
   - `competencia`
   - `data_competencia`
   - `ano`
   - `mes`
   - `nome_mes`
   - `trimestre`

2. **dim_enstabelecimento_saude**: Órgãos e unidades administrativas
   - `id_estabelecimento` (PK)
   - `cnes`
   - `nome_estabelecimento`
   - `razao_social`
   - `logradouro`
   - `num_endereco`
   - `bairro`
   - `cep`
   - `telefone`
   - `email`
   - `regiao`
   - `uf`
   - `municipio`

3. **dim_tipo_unidade**: Classificação física e operacional do estabelecimento
   - `id_tipo_unidade` (PK)
   - `cod_tipo_unidade`
   - `desc_tipo_unidade`

4. **dim_natureza_juridica**: Estrutura institucional e jurídica da mantenedora
   - `id_natureza_juridica` (PK)
   - `natureza_juridica`
   - `desc_natureza_juridica`

5. **dim_gestao**: Esfera de comando administrativo e regulação do SUS
   - `id_gestao` (PK)
   - `tipo_gestao`
   - `desc_gestao`


# criar e desligar docker 
docker compose up -d
docker compose down

## Referências

- [Dados Abertos Governo](https://dadosabertos.saude.gov.br/dataset/hospitais-e-leitos)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [DBT Documentation](https://docs.getdbt.com/)
- [Pandas Documentation](https://pandas.pydata.org/docs/)

## Equipe

**Grupo 3** - Projeto Banco de Dados

| Nome | Login |
|------|-------|
| Diogo Cavalcanti | `dcca` |
| Felipe Andrade | `fals2` |
| Heitor Nobrega | `hbn` |
| Thiago Alves | `tam6` |


## Licença

Este projeto é desenvolvido para fins acadêmicos na disciplina de Banco de Dados.

---

**Tecnologias:** Python • PostgreSQL • DBT • Pandas • Jupyter

**Período:** 2026.1
