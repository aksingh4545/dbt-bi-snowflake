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

### 6. **Use Macros for Reusability**
Create macros for common transformations:

```sql
-- macros/calculate_margin.sql
{% macro calculate_margin(revenue, cogs) %}
    ({{ revenue }} - {{ cogs }}) / {{ revenue }} * 100
{% endmacro %}
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
