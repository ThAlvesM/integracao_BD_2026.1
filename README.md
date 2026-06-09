# 🏥 Projeto de Integração de Dados — Leitos Hospitalares (DATASUS)

## 📋 Sobre o Projeto

Este projeto implementa um pipeline completo de integração e análise de dados de leitos hospitalares do Brasil, provenientes do **Cadastro Nacional de Estabelecimentos de Saúde (CNES/DATASUS)**, abrangendo os anos de 2023 a 2025. O objetivo principal é consolidar múltiplos conjuntos de dados em um Data Warehouse modelado em **Esquema Estrela (Star Schema)**, possibilitando análises sobre a distribuição e disponibilidade de leitos no Sistema Único de Saúde (SUS).

## 🎯 Objetivos

- Integrar e consolidar dados de leitos hospitalares de três anos consecutivos (2023–2025)
- Criar um Data Warehouse estruturado em Esquema Estrela
- Implementar processos de ETL e ELT para transformação e carga de dados
- Facilitar análises complexas sobre disponibilidade de leitos e UTIs por região, UF e município
- Gerar insights relevantes sobre a infraestrutura hospitalar pública brasileira

## 🏗️ Arquitetura do Projeto

### Estrutura de Arquivos

```
integracao_BD_2026.1/
│
├── database/
│   └── data_raw/
│       ├── Leitos_2023.csv
│       ├── Leitos_2024.csv
│       └── Leitos_2025.csv
│
├── notebooks/
│   ├── ETL.ipynb
│   └── ELT.ipynb
│
├── transformacao_leitos/
│   ├── analises/
│   │   ├── analise1.sql
│   │   ├── analise2.sql
│   │   └── analise3.sql
│   │
│   ├── models/
│   │   ├── staging/
│   │   │   └── vw_staging.sql
│   │   └── marts/
│   │       ├── dim_tempo.sql
│   │       ├── dim_estabelecimento_saude.sql
│   │       ├── dim_tipo_unidade.sql
│   │       ├── dim_natureza_juridica.sql
│   │       ├── dim_gestao.sql
│   │       └── fato_leitos_mensais.sql
│   │
│   ├── dbt_project.yml
│   ├── profiles_exemplo.yml
│   └── profiles.yml
│
├── .env_exemplo
├── .gitignore
├── docker-compose.yml
└── README.md
```

## 🗄️ Modelagem do Data Warehouse

### Esquema Estrela (Star Schema)

O projeto implementa um modelo dimensional com as seguintes tabelas:

#### 📊 Tabela Fato

- **fato_leitos_mensais**: Contém as métricas de leitos e UTIs por competência mensal
  - `id_tempo` (FK → dim_tempo)
  - `id_estabelecimento` (FK → dim_estabelecimento_saude)
  - `id_tipo_unidade` (FK → dim_tipo_unidade)
  - `id_natureza_juridica` (FK → dim_natureza_juridica)
  - `id_gestao` (FK → dim_gestao)
  - `leitos_existentes`
  - `leitos_sus`
  - `uti_total_exist` / `uti_total_sus`
  - `uti_adulto_exist` / `uti_adulto_sus`
  - `uti_pediatrico_exist` / `uti_pediatrico_sus`
  - `uti_neonatal_exist` / `uti_neonatal_sus`
  - `uti_queimado_exist` / `uti_queimado_sus`
  - `uti_coronariana_exist` / `uti_coronariana_sus`

#### 📐 Tabelas Dimensão

1. **dim_tempo**: Dimensão temporal
   - `id_tempo` (PK)
   - `competencia`, `data_competencia`, `ano`, `mes`, `nome_mes`, `trimestre`

2. **dim_estabelecimento_saude**: Estabelecimentos e localização geográfica
   - `id_estabelecimento` (PK)
   - `cnes`, `nome_estabelecimento`, `razao_social`
   - `regiao`, `uf`, `municipio`
   - `logradouro`, `num_endereco`, `bairro`, `cep`, `telefone`, `email`

3. **dim_tipo_unidade**: Classificação operacional do estabelecimento
   - `id_tipo_unidade` (PK)
   - `cod_tipo_unidade`, `desc_tipo_unidade`

4. **dim_natureza_juridica**: Estrutura jurídica da mantenedora
   - `id_natureza_juridica` (PK)
   - `natureza_juridica`, `desc_natureza_juridica`

5. **dim_gestao**: Esfera de gestão administrativa do SUS
   - `id_gestao` (PK)
   - `tipo_gestao`, `descricao_gestao`

## 🔄 Processos de Integração

### Pipeline ETL (`notebooks/ETL.ipynb`)

O processo ETL implementa as seguintes etapas:

1. **Extração**:
   - Leitura dos arquivos CSV de 2023, 2024 e 2025
   - Detecção automática de encoding (Latin-1) e separador (`,` ou `;`)
   - Preservação de zeros à esquerda em campos de código (CNES, COMP, CEP)

2. **Transformação** (em Python/Pandas):
   - Padronização de nomes de colunas (lowercase, sem espaços)
   - Limpeza de campos textuais: `strip()` + `lower()` + preenchimento de nulos com `nao_informado`
   - Remoção do sufixo `.0` em campos numéricos lidos como float
   - Restauração de zeros à esquerda via `zfill()`
   - Geração de colunas temporais derivadas: `ano`, `mes`, `trimestre`, `nome_mes`, `data_competencia`
   - Expansão do domínio de gestão: `m → municipal`, `e → estadual`, `d → dupla`
   - Descarte da coluna `motivo_desabilitacao`
   - Conversão de métricas para inteiro com `pd.to_numeric` e `fillna(0)`

3. **Carga**:
   - Criação das 5 tabelas dimensão e 1 tabela fato no schema `elt`
   - Inserção no PostgreSQL via SQLAlchemy com `engine.begin()` e `con=conn`

### Pipeline ELT (`notebooks/ELT.ipynb`)

O processo ELT separa claramente as responsabilidades:

1. **Extração e Carga Raw**:
   - Leitura mínima dos CSVs (sem transformação)
   - Carregamento direto no PostgreSQL, schema `leitos_raw`, tabela `leitos_bruto`
   - 255.843 registros carregados em lotes de 10.000 (`chunksize=10_000`)

2. **Transformação via DBT** (`transformacao_leitos/`):
   - `models/staging/vw_staging.sql`: view de limpeza, padronização e derivação de campos
   - `models/marts/dim_*.sql`: materialização das 5 dimensões como tabelas
   - `models/marts/fato_leitos_mensais.sql`: materialização da tabela fato com joins nas dimensões
   - O DBT resolve automaticamente a ordem de execução pelos relacionamentos entre models

## 🛠️ Tecnologias Utilizadas

- **Python 3.13**: Linguagem principal para os pipelines
- **Pandas**: Manipulação e transformação de dados
- **SQLAlchemy 2.x**: Conexão com o banco de dados
- **PostgreSQL 15**: Sistema gerenciador de banco de dados
- **dbt-postgres 1.9.0**: Transformação e materialização dos models no Data Warehouse
- **Docker**: Containerização do banco de dados
- **Jupyter Notebook**: Ambiente de desenvolvimento interativo

## 📦 Dependências

```bash
pip install pandas sqlalchemy psycopg2-binary python-dotenv dbt-postgres==1.9.0
```

> ⚠️ Não instale `dbt-core` diretamente. O `dbt-postgres==1.9.0` já instala a versão compatível do core automaticamente. Versões 2.x do dbt-core (dbt Fusion) ainda não suportam PostgreSQL.

## ⚙️ Configuração e Instalação

### 1. Configurar Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto baseado no `.env_exemplo`:

```env
DB_USER=postgres
DB_PASSWORD=sua_senha
DB_HOST=localhost
DB_PORT=5432
DB_NAME=projeto
```

### 2. Configurar o profiles.yml

Copie o `profiles_exemplo.yml` para dentro da pasta `transformacao_leitos/` e renomeie para `profiles.yml`, preenchendo com suas credenciais:

```yaml
transformacao_leitos:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      user: seu_usuario
      password: "sua_senha"
      port: 5432
      dbname: nome_do_banco
      schema: elt
      threads: 4
```

> ⚠️ O `profiles.yml` está no `.gitignore` — nunca suba suas credenciais para o repositório.

### 3. Opção A — Subir com Docker

```bash
# Iniciar o container PostgreSQL
docker compose up -d

# Verificar se está rodando
docker ps

# Parar o container
docker compose down
```

### 4. Opção B — PostgreSQL Local

Certifique-se de ter o PostgreSQL instalado e em execução. Crie o banco manualmente:

```sql
CREATE DATABASE projeto;
```

## 🚀 Como Executar

### Opção 1: Pipeline ETL

1. Abra o notebook `notebooks/ETL.ipynb`
2. Execute todas as células sequencialmente
3. Verifique as tabelas criadas:

```sql
SELECT * FROM elt.dim_tempo LIMIT 5;
SELECT COUNT(*) FROM elt.fato_leitos_mensais;
```

### Opção 2: Pipeline ELT

**Passo 1 — Carregar dados brutos:**

1. Abra o notebook `notebooks/ELT.ipynb`
2. Execute as células de Extract e Load
3. Confirme a carga:

```sql
SELECT COUNT(*) FROM leitos_raw.leitos_bruto;
-- Esperado: 255.843 registros
```

**Passo 2 — Executar as transformações com DBT:**

```bash
cd transformacao_leitos

# Verificar conexão com o banco
dbt debug

# Executar todos os models
dbt run

# Executar apenas a staging
dbt run --select staging

# Executar apenas as marts (dimensões + fato)
dbt run --select marts
```

**Resultado esperado:**
```
Running with dbt=1.11.11
Registered adapter: postgres=1.9.0
Found 7 models, 474 macros

Concurrency: 4 threads (target='dev')

1 of 7 START sql view model elt.vw_staging .................. [RUN]
1 of 7 OK created sql view model elt.vw_staging ............. [CREATE VIEW in 0.13s]
2 of 7 START sql table model elt.dim_estabelecimento_saude .. [RUN]
3 of 7 START sql table model elt.dim_gestao ................. [RUN]
4 of 7 START sql table model elt.dim_natureza_juridica ...... [RUN]
5 of 7 START sql table model elt.dim_tempo .................. [RUN]
6 of 7 START sql table model elt.dim_tipo_unidade ........... [RUN]
2 of 7 OK created sql table model elt.dim_estabelecimento_saude  [SELECT 11596 in 1.09s]
3 of 7 OK created sql table model elt.dim_gestao ............ [SELECT 3 in 0.30s]
4 of 7 OK created sql table model elt.dim_natureza_juridica . [SELECT 32 in 0.33s]
5 of 7 OK created sql table model elt.dim_tempo ............. [SELECT 36 in 0.68s]
6 of 7 OK created sql table model elt.dim_tipo_unidade ...... [SELECT 5 in 0.26s]
7 of 7 START sql table model elt.fato_leitos_mensais ........ [RUN]
7 of 7 OK created sql table model elt.fato_leitos_mensais ... [SELECT 255843 in 2.71s]

Finished running 6 table models, 1 view model in 8.09s.
Completed successfully. PASS=7 WARN=0 ERROR=0 SKIP=0 TOTAL=7
```

## 📊 Análises Disponíveis

O projeto inclui três análises SQL na pasta `sql/analises/`:

### 1. Município com mais leitos SUS em 2024

**Arquivo:** `analise1.sql`

Identifica o município brasileiro com maior oferta de leitos SUS no ano de 2024.

```sql
SELECT t.ano, e.municipio, SUM(f.leitos_sus)
FROM elt.fato_leitos_mensais f
JOIN elt.dim_estabelecimento_saude e ON e.id_estabelecimento = f.id_estabelecimento
JOIN elt.dim_tempo t ON t.id_tempo = f.id_tempo
WHERE t.ano = 2024
GROUP BY t.ano, e.uf, e.municipio
ORDER BY SUM(f.leitos_sus) DESC
LIMIT 1;
```

### 2. Média de leitos existentes por UF

**Arquivo:** `analise2.sql`

Calcula a média mensal de leitos existentes por Unidade Federativa, permitindo comparar a infraestrutura hospitalar entre estados.

```sql
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
```

### 3. UF com mais UTIs SUS no Nordeste em 2023

**Arquivo:** `analise3.sql`

Identifica qual estado da Região Nordeste concentrou o maior número de leitos de UTI disponíveis ao SUS em 2023.

```sql
SELECT e.uf, t.ano, SUM(f.uti_total_sus)
FROM elt.dim_estabelecimento_saude e
JOIN elt.fato_leitos_mensais f ON f.id_estabelecimento = e.id_estabelecimento
JOIN elt.dim_tempo t ON t.id_tempo = f.id_tempo
WHERE t.ano = 2023
  AND e.regiao = 'nordeste'
GROUP BY e.uf, t.ano
ORDER BY SUM(f.uti_total_sus) DESC
LIMIT 1;
```

## 🧹 Tratamentos de Dados Aplicados

### Padronização de Códigos

Campos como CNES, COMP e CEP são armazenados como texto com comprimento fixo, restaurando zeros à esquerda perdidos na leitura:

| Campo | Comprimento | Exemplo original | Após tratamento |
|-------|-------------|-----------------|-----------------| 
| COMP | 6 | `202301.0` | `202301` |
| CNES | 7 | `12345.0` | `0012345` |
| CEP | 8 | `50000.0` | `00050000` |
| NATUREZA_JURIDICA | 4 | `1.0` | `0001` |

### Padronização de Textos

- Todos os campos textuais passam por `TRIM()` + `LOWER()`
- Valores nulos substituídos por `nao_informado`
- Encoding Latin-1 detectado e tratado automaticamente

### Expansão do Domínio de Gestão

| Código original | Descrição gerada |
|----------------|-----------------|
| `m` | `municipal` |
| `e` | `estadual` |
| `d` | `dupla` |
| outros | `NULL` |

### Colunas Descartadas

- `motivo_desabilitacao`: sem relevância para as análises propostas

### Tratamento de Métricas Numéricas

- Campos de contagem de leitos lidos como float são convertidos para inteiro
- Valores ausentes substituídos por `0`

## 📈 Métricas do Projeto

| Métrica | Valor |
|---------|-------|
| **Total de Registros Consolidados** | 255.843 |
| **Período Analisado** | 3 anos (2023–2025) |
| **Tabelas Dimensão** | 5 |
| **Tabela Fato** | 1 |
| **Tipos de UTI monitorados** | 5 (adulto, pediátrico, neonatal, queimado, coronariana) |
| **Arquivos-fonte** | 3 CSVs |

## 📝 Notas Importantes

- Os dados são **públicos**, disponibilizados pelo DATASUS/Ministério da Saúde
- O schema `leitos_raw` mantém os dados originais **inalterados**
- O schema `elt` contém os dados **transformados e modelados**
- O DBT resolve automaticamente a ordem de execução — não é necessário rodar os models manualmente
- O `profiles.yml` está no `.gitignore` — nunca suba suas credenciais para o repositório
- Use `dbt-postgres==1.9.0` — versões 2.x (dbt Fusion) ainda não suportam PostgreSQL

## 📚 Referências

- [Dados Abertos — Hospitais e Leitos (DATASUS)](https://dadosabertos.saude.gov.br/dataset/hospitais-e-leitos)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [DBT Documentation](https://docs.getdbt.com/)
- [Pandas Documentation](https://pandas.pydata.org/docs/)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)

## 👥 Equipe

**Grupo 3** — Projeto Banco de Dados

| Nome | Login |
|------|-------|
| Diogo Cavalcanti | `dcca` |
| Felipe Andrade | `fals2` |
| Heitor Nobrega | `hbn` |
| Thiago Alves | `tam6` |

## 📄 Licença

Este projeto é desenvolvido para fins acadêmicos na disciplina de Banco de Dados.

---

**Tecnologias:** Python • PostgreSQL • DBT • Docker • Pandas • Jupyter

**Período:** 2026.1