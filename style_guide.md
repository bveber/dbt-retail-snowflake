# DBT Style Guide

This style guide is a based on the standard [dbt Style Guide](https://github.com/dbt-labs/corp/blob/main/dbt_style_guide.md).

## Model Naming
Models (typically) fit into three main categories: staging, marts, intermediate. For more detail about why we use this structure, check out [this discourse post](https://discourse.getdbt.com/t/how-we-structure-our-dbt-projects/355) and [this article detailing the structure](https://towardsdatascience.com/staging-intermediate-mart-models-dbt-2a759ecc1db1).
The file and naming structures are as follows:
```
├── dbt_project.yml
└── models
    ├── intermediate
    |   └── store
    |       ├── _models.yml
    |       └── int__sales.sql
    ├── marts
    |   └── store
    |       └── _models.yml
    |       └── store_profiles.sql
    └── staging
        └── apps
            ├── _models.yml
            ├── stg__source_data.sql
```
- All objects should be plural, such as: `store_profiles.sql`
- Staging tables are prefixed with `stg__`, such as: `stg_pos__source_data`
- Intermediate tables are prefixed with `int__<object>`, such as: `int__sales`
- Each subdirectory should contain a `_models.yml` file for documentation and testing

## Model configuration

- Model-specific attributes (like sort/dist keys) should be specified in the model.
- If a particular configuration applies to all models in a directory, it should be specified in the `dbt_project.yml` file.
- In-model configurations should be specified like this:

```python
{{ '{{' }}
  config(
    materialized = 'table',
    sort = 'id',
    dist = 'id'
  )
{{ '}}' }}
```
- Marts should always be configured as tables

## Conventions
* Only `stg_` models should select from `source`s.
* All other models should only select from other models.

## Testing

- Every subdirectory should contain a `_models.yml` file, in which each model in the subdirectory is tested.
- At a minimum, unique and not_null tests should be applied to the primary key of each model.

## Naming and field conventions

* Schema, table and column names should be in `snake_case`.
* For base/staging models, fields should be ordered in categories, where identifiers are first and timestamps are at the end.
* Booleans should be prefixed with `is_` or `has_`.
* Avoid reserved words as column names
* Consistency is key! Use the same field names across models where possible, e.g. a key to the `customers` table should be named `customer_id` rather than `user_id`.

## CTEs

For more information about why we use so many CTEs, check out [this discourse post](https://discourse.getdbt.com/t/why-the-fishtown-sql-style-guide-uses-so-many-ctes/1091).

- All `{{ '{{' }} ref('...') {{ '{{' }}` statements should be placed in CTEs at the top of the file
- Where performance permits, CTEs should perform a single, logical unit of work.
- CTE names should be as verbose as needed to convey what they do
- CTEs with confusing or noteable logic should be commented
- CTEs that are duplicated across models should be pulled out into their own models
- create a `final` or similar CTE that you select from as your last line of code. This makes it easier to debug code within a model (without having to comment out code!)
- CTEs should be formatted like this:

``` sql
with

events as (

    ...

),

-- CTE comments go here
filtered_events as (

    ...

)

select * from filtered_events
```

## SQL style guide

- Use trailing commas
- Indents should be four spaces (except for predicates, which should line up with the `where` keyword)
- Lines of SQL should be no longer than 80 characters
- Field names and function names should all be lowercase
- Aggregations should be executed as early as possible before joining to another table.
- If joining two or more tables, _always_ prefix your column names with the table alias. If only selecting from one table, prefixes are not needed.
- Prefer != to <>. This is because != is more common in other programming languages and reads like "not equal" which is how we're more likely to speak.

- *DO NOT OPTIMIZE FOR A SMALLER NUMBER OF LINES OF CODE. NEWLINES ARE CHEAP, BRAIN TIME IS EXPENSIVE*

### Example SQL
```sql
with

my_data as (

    select * from {{ '{{' }} ref('my_data') {{ '{{' }}

),

some_cte as (

    select * from {{ '{{' }} ref('some_cte') {{ '{{' }}

),

some_cte_agg as (

    select
        id,
        sum(field_4) as total_field_4,
        max(field_5) as max_field_5

    from some_cte
    group by id

),

final as (

    select [distinct]
        my_data.field_1,
        my_data.field_2,
        my_data.field_3,

        -- use line breaks to visually separate calculations into blocks
        case
            when my_data.cancellation_date is null
                and my_data.expiration_date is not null
                then expiration_date
            when my_data.cancellation_date is null
                then my_data.start_date + 7
            else my_data.cancellation_date
        end as cancellation_date,

        some_cte_agg.total_field_4,
        some_cte_agg.max_field_5

    from my_data
    left join some_cte_agg  
        on my_data.id = some_cte_agg.id
    where my_data.field_1 = 'abc'
        and (
            my_data.field_2 = 'def' or
            my_data.field_2 = 'ghi'
        )
    having count(*) > 1

)

select * from final

```

- Your join should list the "left" table first (i.e. the table you are selecting `from`):
```sql
select
    trips.*,
    drivers.rating as driver_rating,
    riders.rating as rider_rating

from trips
left join users as drivers
    on trips.driver_id = drivers.user_id
left join users as riders
    on trips.rider_id = riders.user_id

```

## YAML style guide

* Indents should be two spaces
* List items should be indented
* Use a new line to separate list items that are dictionaries where appropriate
* Lines of YAML should be no longer than 80 characters.

### Example YAML
```yaml
version: 2

models:
  - name: events
    columns:
      - name: event_id
        description: This is a unique identifier for the event
        tests:
          - unique
          - not_null

      - name: event_time
        description: "When the event occurred in UTC (eg. 2018-01-01 12:00:00)"
        tests:
          - not_null

      - name: user_id
        description: The ID of the user who recorded the event
        tests:
          - not_null
          - relationships:
              to: ref('users')
              field: id
```


## Jinja style guide

* When using Jinja delimiters, use spaces on the inside of your delimiter, like `{{ '{{' }} this {{ '{{' }}` instead of `{{ '{{' }}this{{ '{{' }}`
* Use newlines to visually indicate logical blocks of Jinja