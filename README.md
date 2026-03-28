# DBT BI Metrics Platform

A comprehensive dbt (data build tool) project for building a business intelligence metrics platform. This project transforms raw sales data into structured, analytics-ready marts for reporting and dashboarding.

---

## Table of Contents

1. [What is dbt?](#what-is-dbt)
2. [Project Overview](#project-overview)
3. [Architecture](#architecture)
4. [Project Structure](#project-structure)
5. [Models Explained](#models-explained)
6. [How dbt Works](#how-dbt-works)
7. [Getting Started](#getting-started)
8. [Common Commands](#common-commands)
9. [Best Practices](#best-practices)

---

## What is dbt?

**dbt (data build tool)** is a transformation workflow that lets data analysts and engineers transform, test, and document data in their warehouse using SQL. It follows the **ELT** (Extract, Load, Transform) paradigm where:

- **Extract**: Data is extracted from source systems
- **Load**: Raw data is loaded into the data warehouse
- **Transform**: dbt transforms the data into analytics-ready tables

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Models** | SQL SELECT statements that define transformations. dbt materializes these as tables or views in your warehouse. |
| **Materializations** | Strategies for storing models: `table`, `view`, `incremental`, or `ephemeral`. |
| **Sources** | Raw data tables loaded into your warehouse (not managed by dbt). |
| **Refs** | References to other dbt models, creating a dependency graph. |
| **Macros** | Reusable SQL snippets (like functions in programming). |
| **Tests** | Assertions about your data quality (e.g., uniqueness, not null). |
| **Seeds** | CSV files that dbt loads into your warehouse as tables. |


## 🚀 Why Use dbt for Transformations (When Warehouses Can Do It Too?)

You’re absolutely right to question this—because technically, you **can do all transformations directly in a warehouse** like Snowflake or BigQuery.

But here’s the key point:

> **dbt doesn’t replace the warehouse — it makes working with it structured, scalable, and maintainable.**

Let’s break it down simply 👇

---

### 🧠 Without dbt (just warehouse)

You write SQL like:

```sql id="qzj7pn"
CREATE TABLE final_table AS
SELECT ...
```

Problems start when things grow:

* ❌ Queries scattered across notebooks / tools
* ❌ No clear order of execution
* ❌ Hard to debug
* ❌ No version control
* ❌ Reusability is poor

---

### 🚀 With dbt (data build tool)

dbt brings **software engineering practices to SQL**

---

### 🔑 Why we use dbt instead of only warehouse

#### 🔗 1. Dependency management (automatic order)

With `ref()`:

```sql id="6b1s8p"
FROM {{ ref('stg_orders') }}
```

dbt builds a DAG:

```id="q7yx5u"
stg_orders → customer_orders → final_report
```

👉 No need to manually manage execution order

---

#### 📁 2. Project structure (clean & scalable)

Instead of random queries:

```id="7n4r2m"
models/
  staging/
  intermediate/
  marts/
```

👉 Easy to understand for teams

---

#### 🔄 3. Reusability

* Build once → reuse everywhere
* No repeated SQL logic

---

#### 🧪 4. Testing (big advantage)

You can add tests like:

* unique
* not null
* relationships

👉 Data quality checks built-in

---

#### 🧾 5. Version control (Git)

* Track changes
* Collaborate safely
* Rollback if needed

---

#### ⚙️ 6. Environment handling

dbt automatically handles:

* dev vs prod schemas
* table naming

👉 No manual switching

---

#### ⚡ 7. Incremental models (performance)

Process only new data instead of full tables
👉 Saves cost + time

---

#### 📊 8. Documentation

dbt auto-generates:

* data lineage (graph)
* model descriptions

---

### 🆚 Simple comparison

| Without dbt      | With dbt           |
| ---------------- | ------------------ |
| Raw SQL scripts  | Structured project |
| Manual execution | Automated DAG      |
| No testing       | Built-in tests     |
| Hard to scale    | Easy to scale      |

---

### 🧠 Real-world analogy

* Warehouse = 🏭 Factory (does the heavy work)
* dbt = 🧠 Manager/system organizing the factory

---

### 🎯 Final understanding

> You *can* transform data in the warehouse
> but **dbt makes it reliable, organized, and production-ready**

---

## Project Overview

This dbt project processes **retail sales data** to create business intelligence metrics. It follows a layered architecture:

```
Raw Data (Snowflake) → Staging Layer → Marts Layer → BI/Analytics
```

### Data Flow

1. **Source**: Raw sales data loaded into Snowflake
2. **Staging**: Clean and standardize raw data (`stg_sales`)
3. **Marts**: Aggregated business metrics for specific domains:
   - Sales Summary
   - Customer Summary
   - Product Summary
   - Branch Summary
   - Payment Summary

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         SNOWFLAKE WAREHOUSE                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐                                               │
│  │ RAW Layer    │  ← Source data (sales table)                 │
│  └──────┬───────┘                                               │
│         │                                                        │
│         ▼                                                        │
│  ┌──────────────┐                                               │
│  │ Staging      │  ← stg_sales (cleaned, standardized)          │
│  │ Layer        │                                               │
│  └──────┬───────┘                                               │
│         │                                                        │
│         ▼                                                        │
│  ┌──────────────┐                                               │
│  │ Marts Layer  │  ← Business-level aggregations:               │
│  │              │     • sales_summary                           │
│  │              │     • customer_summary                        │
│  │              │     • product_summary                         │
│  │              │     • branch_summary                          │
│  │              │     • payment_summary                         │
│  └──────────────┘                                               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                  ┌───────────────────────┐
                  │   BI Tools (Power BI, │
                  │   Tableau, Looker)    │
                  └───────────────────────┘
```

---

## Project Structure

```
dbt_bi_metrics_platform_db/
├── project/
│   ├── dbt_project.yml          # Project configuration
│   ├── profiles.yml             # Database connection (in ~/.dbt/)
│   │
│   ├── models/                  # SQL transformations
│   │   ├── staging/             # Staging models
│   │   │   └── stg_sales.sql    # Clean raw sales data
│   │   └── marts/               # Business logic aggregations
│   │       ├── sales_summary.sql
│   │       ├── customer_summary.sql
│   │       ├── product_summary.sql
│   │       ├── branch_summary.sql
│   │       └── payment_summary.sql
│   │
│   ├── macros/                  # Reusable SQL snippets
│   ├── seeds/                   # CSV files (if any)
│   ├── tests/                   # Custom data tests
│   └── analyses/                # Exploratory queries
│
├── target/                      # Compiled artifacts (auto-generated)
├── logs/                        # dbt execution logs
└── README.md                    # This file
```

---

## Models Explained

### Staging Layer

#### `stg_sales.sql`
Cleans and standardizes raw sales data from the source table.

```sql
-- Input: Raw sales table
-- Output: Cleaned, standardized sales data
-- Fields: invoice_id, branch, city, customer_type, gender, product_line,
--         unit_price, quantity, tax, total, date, time, payment, cogs,
--         gross_margin_percentage, gross_income, rating
```

**Materialization**: Table

---

### Marts Layer

#### 1. `sales_summary.sql`
Aggregates sales metrics by city and product line.

```sql
-- Metrics: total_sales, total_quantity, avg_rating
-- Grouping: city, product_line
```

**Use Case**: Analyze which product lines perform best in each city.

---

#### 2. `customer_summary.sql`
Analyzes customer behavior by type and gender.

```sql
-- Metrics: total_transactions, total_sales, avg_rating
-- Grouping: customer_type, gender
```

**Use Case**: Understand customer segments and preferences.

---

#### 3. `product_summary.sql`
Summarizes product line performance.

```sql
-- Metrics: total_quantity, total_sales, avg_price
-- Grouping: product_line
```

**Use Case**: Identify top-performing product categories.

---

#### 4. `branch_summary.sql`
Aggregates sales by branch and city location.

```sql
-- Metrics: total_sales, total_qty
-- Grouping: branch, city
```

**Use Case**: Compare branch performance across locations.

---

#### 5. `payment_summary.sql`
Analyzes payment method distribution.

```sql
-- Metrics: transactions, total_sales
-- Grouping: payment
```

**Use Case**: Understand payment preferences and transaction volumes.

---

## How dbt Works

### 1. **Compilation**
dbt compiles your SQL models, resolving all `{{ ref() }}` functions to actual table names.

```sql
-- Your code
SELECT * FROM {{ ref('stg_sales') }}

-- Compiled SQL
SELECT * FROM "SNOWFLAKE"."RAW"."stg_sales"
```

### 2. **Dependency Graph**
dbt builds a DAG (Directed Acyclic Graph) based on model references:

```
sales (source)
    │
    ▼
stg_sales
    │
    ├──► sales_summary
    ├──► customer_summary
    ├──► product_summary
    ├──► branch_summary
    └──► payment_summary
```

### 3. **Materialization**
dbt executes models in the correct order, creating tables/views in your warehouse.

### 4. **Testing**
Run data quality tests to ensure integrity:

```bash
dbt test          # Run all tests
dbt test -m stg_sales  # Test specific model
```

### 5. **Documentation**
Generate interactive documentation:

```bash
dbt docs generate
dbt docs serve
```

---

## Getting Started

### Prerequisites

1. **Python 3.8+** installed
2. **Snowflake** account with appropriate permissions
3. **dbt Core** or **dbt Cloud** access

### Installation

```bash
# Navigate to project directory
cd project/

# Install dbt with Snowflake adapter
pip install dbt-snowflake

# Verify installation
dbt --version
```

### Configuration

1. **Update `dbt_project.yml`** (already configured):
   - Project name: `project`
   - Profile: `project`
   - Schema mappings: staging → RAW, marts → MARTS

2. **Set up `profiles.yml`** (located at `~/.dbt/profiles.yml`):
   ```yaml
   project:
     target: dev
     outputs:
       dev:
         type: snowflake
         account: your_account
         user: your_username
         password: your_password
         database: your_database
         warehouse: your_warehouse
         schema: RAW
   ```

### First Run

```bash
# Test connection
dbt debug

# Run all models
dbt run

# Run with specific model
dbt run -m stg_sales

# Run models in marts folder only
dbt run -m marts
```

---

## Common Commands

| Command | Description |
|---------|-------------|
| `dbt run` | Execute all models (or specified models) |
| `dbt run -m <model_name>` | Run a specific model |
| `dbt test` | Run data quality tests |
| `dbt seed` | Load CSV files as tables |
| `dbt build` | Run, test, and snapshot in one command |
| `dbt compile` | Generate SQL without executing |
| `dbt parse` | Validate project and generate manifest |
| `dbt docs generate` | Generate documentation |
| `dbt docs serve` | Host documentation locally |
| `dbt debug` | Test database connection |
| `dbt clean` | Remove target/ and dbt_packages/ |
| `dbt deps` | Install package dependencies |

### Model Selection Syntax

```bash
# Run specific model
dbt run -m sales_summary

# Run multiple models
dbt run -m sales_summary customer_summary

# Run all models in a directory
dbt run -m marts/

# Exclude a model
dbt run -m marts/ --exclude payment_summary

# Run model and its dependencies
dbt run -m +sales_summary

# Run model and all downstream models
dbt run -m stg_sales+
```

---

## Best Practices

### 1. **Model Naming Conventions**
- Staging models: `stg_<source_name>` (e.g., `stg_sales`)
- Intermediate models: `int_<topic>` (e.g., `int_orders_cleaned`)
- Marts models: `<topic>_summary` or `<topic>_analysis`

### 2. **Use Refs for Dependencies**
Always use `{{ ref() }}` to reference other models instead of hardcoding table names.

## 🔗 Understanding `ref()` in dbt (Simple Example)

Let’s make `ref()` super simple with a real-life style example in **dbt (data build tool)** 👇

---

### 🧠 Scenario: You have raw data

You start with a raw table:

```
raw_orders
```

---

### 🧩 Step 1: Create a staging model

File: `models/stg_orders.sql`

```sql
SELECT
  order_id,
  customer_id,
  amount
FROM raw_orders
```

Now dbt creates a model called:

```
stg_orders
```

---

### 🔗 Step 2: Use `ref()` in another model

File: `models/customer_orders.sql`

```sql
SELECT
  customer_id,
  SUM(amount) AS total_spent
FROM {{ ref('stg_orders') }}
GROUP BY customer_id
```

---

### 🤔 What just happened?

Instead of writing:

```sql
FROM stg_orders
```

You wrote:

```sql
FROM {{ ref('stg_orders') }}
```

---

### ⚙️ Why this matters (very simple)

#### ✅ 1. dbt runs things in the right order

* First → `stg_orders`
* Then → `customer_orders`

---

#### ✅ 2. No need to write schema/database

dbt automatically converts:

```
{{ ref('stg_orders') }}
```

into something like:

```
dev_analytics.stg_orders
```

---

#### ✅ 3. Safe & flexible

If you rename `stg_orders` → `stg_orders_v2`

You only update:

```sql
ref('stg_orders_v2')
```

No breaking changes 💡

---

### 🔄 Final Flow (easy to visualize)

```
raw_orders  →  stg_orders  →  customer_orders
                ↑
              ref()
```

---

### 🧠 One-line understanding

> `ref()` = “Use data from another dbt model in a smart, connected way”



### 3. **Configure Materializations**
Choose the right materialization strategy:
- `table`: For large, frequently queried datasets
- `view`: For simple transformations or small datasets
- `incremental`: For large tables that grow over time and Add/update only new rows (incremental ✅)

### 4. **Add Tests**
Define data quality tests in your model files:

```yaml
# models/schema.yml
version: 2

models:
  - name: stg_sales
    columns:
      - name: invoice_id
        tests:
          - unique
          - not_null
      - name: total
        tests:
          - not_null
```

### 5. **Document Your Models**
Add descriptions to models and columns:

```sql
{{
  config(materialized='table')
}}

/*
This model cleans and standardizes raw sales data.
Source: sales table in Snowflake
Owner: Data Engineering Team
*/
```

### 6.🧩 Macros in dbt (with Simple Example)

In **dbt (data build tool)**, **macros** are reusable pieces of SQL (like functions) written using **Jinja templating**.

> Think of macros as: **“write once, reuse everywhere” for SQL logic**

---

### 🧠 Why use macros?

* Avoid repeating SQL code
* Make queries dynamic
* Keep logic clean and reusable

---

### 📁 Where macros are stored

```id="c3k9vd"
macros/
  my_macro.sql
```

---

### ✍️ Example 1: Simple macro

File: `macros/add_tax.sql`

```sql id="8l2p7m"
{% macro add_tax(amount) %}
    {{ amount }} * 1.18
{% endmacro %}
```

👉 This macro adds 18% tax

---

### 🔗 Using the macro in a model

```sql id="r2w6xz"
SELECT
  order_id,
  {{ add_tax('amount') }} AS amount_with_tax
FROM orders
```

---

### ⚙️ What dbt compiles it into

```sql id="q1v7sa"
SELECT
  order_id,
  amount * 1.18 AS amount_with_tax
FROM orders
```

---

### 🧩 Example 2: Dynamic column selection

File: `macros/select_columns.sql`

```sql id="9xk3pj"
{% macro select_columns(cols) %}
    {{ cols | join(', ') }}
{% endmacro %}
```

Usage:

```sql id="y5b8nm"
SELECT
  {{ select_columns(['order_id', 'customer_id', 'amount']) }}
FROM orders
```

---

### 🔄 Example 3: Conditional logic

```sql id="m4z7qr"
{% macro filter_recent(column) %}
    {% if target.name == 'prod' %}
        {{ column }} >= current_date - interval '7 days'
    {% else %}
        {{ column }} >= current_date - interval '30 days'
    {% endif %}
{% endmacro %}
```

Usage:

```sql id="t8u2lk"
SELECT *
FROM orders
WHERE {{ filter_recent('order_date') }}
```

---

### 🚀 Why macros are powerful

* 🔁 Reusable logic across models
* ⚙️ Dynamic SQL generation
* 🌍 Environment-aware queries
* 🧹 Cleaner and shorter code

---

### 🧠 One-line understanding

> Macros = “custom SQL functions in dbt to make your code reusable and dynamic”

```

### 7. **Incremental Models for Large Data**
For large tables, use incremental materialization:

```sql
{{
  config(
    materialized='incremental',
    unique_key='invoice_id'
  )
}}

SELECT * FROM {{ ref('stg_sales') }}
{% if is_incremental() %}
  WHERE date > (SELECT MAX(date) FROM {{ this }})
{% endif %}
```

---

## Troubleshooting

### Common Issues

1. **"Nothing to do" error**
   - Ensure models are in the correct directory
   - Check `dbt_project.yml` model paths configuration

2. **Connection errors**
   - Run `dbt debug` to test connection
   - Verify credentials in `profiles.yml`

3. **Model not found**
   - Check `{{ ref() }}` syntax
   - Ensure model file exists and is named correctly

4. **Schema not created**
   - Verify warehouse permissions
   - Check schema configuration in `dbt_project.yml`

---

## Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [dbt Community Slack](https://community.getdbt.com/)
- [dbt Discourse Forum](https://discourse.getdbt.com/)
- [Snowflake dbt Adapter](https://docs.getdbt.com/reference/warehouse-profiles/snowflake-profile)

---

## Project Info

- **dbt Version**: 1.11.7
- **Adapter**: Snowflake 1.11.3
- **Project Version**: 1.0.0
- **Created**: March 2026

---

*This README was generated to explain the dbt BI Metrics Platform project structure and functionality.*
