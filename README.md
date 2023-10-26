# DBT Retail Example Project

# `Why are we here?`

The purpose of this project is for me (a Machine Learning Engineer) to gain more practical experience
with DBT (and several other tools) while creating a functional demo in a domain I have some experience in.
Maybe someday I will turn this into an interactive demo.

# `What are we doing?`

The ultimate goal of this project is to provide time-series forecasts using a
[publicly available dataset](https://data.iowa.gov/Sales-Distribution/Iowa-Liquor-Sales/m3tr-qhgy)
from the state of Iowa that documents all transactions between liquor stores and vendors.
This repo currenlty provides monthly-level forecasts for product-categories at each store.
In theory, this could be useful to individual liquor stores to understand future demand in order to make more
intelligent purchasing decisions or for vendors to be better prepared for future orders. Ultimately, this
level of granularity was chosen arbitrarily, potentially trading-off some practical utililty for
data that is easier to work with.

# `How does it work?`

We are using [DBT](https://www.getdbt.com/product/what-is-dbt/) to define a number of transformations
required to prepare raw transactional data for a many-models time-series forecasting implementation.
The source data for this project is available as a public-facing
<!-- [BigQuery table](https://console.cloud.google.com/marketplace/details/iowa-department-of-commerce/iowa-liquor-sales),
therefore this project uses the [dbt-bigquery adapter](https://docs.getdbt.com/reference/warehouse-setups/bigquery-setup). -->
The raw data is transformed via BigQuery tables and views before a
[python model](https://docs.getdbt.com/docs/build/python-models) uses a package called
[dart](https://unit8co.github.io/darts/) to generate the time-series forecasts. The python models are run in the backend using
<!-- [Dataproc Serverless](https://cloud.google.com/dataproc-serverless/docs) via a custom container defined
at `dockerfiles/minimal_python_ts` and are materialized as BigQuery tables. -->


## `DBT`

DBT's website sums up their product quite succinctly: "dbt™ is a SQL-first transformation workflow
that lets teams quickly and collaboratively deploy analytics code following software engineering best practices
like modularity, portability, CI/CD, and documentation". This tool is an easy-to-use option for teams looking
to optimize and version-manage their data transformation pipelines that provides a common interface for
Data Engineers, Analysts, Machine Learning Engineers and Data Scientists.

### `Project configuration`

The dbt_project.yml file is the primary configuration for your DBT project. Learn more about it [here](https://docs.getdbt.com/reference/dbt_project.yml)

### `Project structure`

For information on best practice for how to structure your models directory review the following docs:

- [DBT best practices](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview)
- [Staging vs Intermediate vs Mart Models in dbt](https://towardsdatascience.com/staging-intermediate-mart-models-dbt-2a759ecc1db1)

### `Models`

The key component of DBT is the `model`. Models are generally SQL-based transformation and are placed in
the `/models` directory.

### `Python model`

In DBT the most commonly used models are SQL-based transformations. Many Data Engineers and Analysts might
only ever need this type of model. However, many ML pipelines require some amount of python processing.
This can be done using the [python model](https://docs.getdbt.com/docs/build/python-models).
DBT allows users to define python transformation via [Snowpark](https://docs.snowflake.com/en/developer-guide/snowpark/index).

### `dbt-snowflake adapter`

DBT offers a number of connectors (Redshift, Databricks, Bigquery, etc.) but we will be using the
Snowflake adapter for this project. Review the
[docs](https://docs.getdbt.com/docs/core/connect-data-platform/snowflake-setup) in order to setup this adapter and learn
more about it.

## `Snowflake backend`


### `Snowpark`


## `Data Science`

This project is done from the perspective of a Machine Learning Engineer, so the Data Science likely leaves a lot
to be desired but this should serve as a good introduction to time-series forecasting. For this project, the forecasts
are made monthly for all combinations stores and product-categories. This fits nicely with the spark runtime
as it allows us to aggregate data at the store/product-category level, then fit and predict with time-series
in each partition.

### `darts`

According to their website: "Darts is a Python library for user-friendly forecasting and anomaly detection on
time series. It contains a variety of models, from classics such as ARIMA to deep neural networks. The forecasting
models can all be used in the same way, using fit() and predict() functions, similar to scikit-learn. The library
also makes it easy to backtest models, combine the predictions of several models, and take external data into account."
This package adds a convenient layer on many different forecasting packages, providing a consistent way to fit and
test multiple forecasting models.

During experimentation it makes sense to download the full package, however it supports many different model
architectures, so unless you intend on using all of them (or at least the most complex ones) it might make sense
to perform testing and validation with darts, but in production it might make sense to use u8darts (the slimmed down version)
or to remove the darts dependency and use only the required packages.

### `Python Worksheet experimentation`
TBD. Preliminary thoughts are to use a python worksheet to perform initial experimentation with different
model architectures and hyperparameters. This would be done on a small subset of the data, but would allow for quick iteration. 

### `pandas_udf`

In this and similar time-series projects its natural for Data Scientists to perform initial experimentation
on a filtered datasets with a handful of various store/product-cateogory combinations. As long as the output
of the Data Science experimentation results in a function that accepts a pandas dataframe with all data for
one group and returns a pandas dataframe with the forecasts it is incredibly easy to translate Data Science
into for a PySpark job that aggregates at the store/product-cateogory level and applies the function derived by
the DS team. For more details about this workflow review the following docs:

- [applyInPandas](https://spark.apache.org/docs/3.2.1/api/python/reference/api/pyspark.sql.GroupedData.applyInPandas.html)
- [pandas_udf](https://spark.apache.org/docs/3.1.2/api/python/reference/api/pyspark.sql.functions.pandas_udf.html)

# `Likely next steps`

As with any project, there are a number of possible improvements that have not been explored yet.
We'll spend some time highlighting some of the more obvious choices.

## `Improve project requirements`

This project provides monthly forecasts at the store/product-category granularity level, but it
might not actually be useful to any possible users of this tool. For the sake of this project,
we are assuming a couple of different potential fictional user, but the first step would
be identifying that actual users. Once, the users are known, it would be importatnt to meet
with them and better understand their needs.

## `Additional data`

This dataset is a great example of retail data, but in most real-world time-series forecasting
projects there will be several other supporting datasets. For example, it would be nice to know
of store closures, so the transaction data can be properly imputed. Moreover, it would be helpful
to know the status of all stores, vendors, categories and items. One known problem in the current
implementation is dead product-categories. It would be nice to know which ones are active so only
the appropriate time-series are used for forecasting.

## `More DS experimentation`

This project has only done a cursory amount of DS experimentation. Only a handful of categories at
two high-volume stores were used for experimentation. It would be good to explore more modeling techniques.
This might include more model architectures at the same granularity, be it univariate or multivariate.

## `Model promotion`

Determine a metric and threshold for succes so Data Scientists can identify superior models that should
be promoted to production.

## `Scale up`

Right now forecasts are generated for all categories at two stores. Doing so would almost certainly surface
unknown data quality issues.

# How to do this at home

## Install dbt

## Setup Google Cloud Project

## Setup DBT project environment

### DBT environment

#### Build and push runtime container

## Build your datasets

## Marvel in your success!

# `Resources:`

- Learn more about [the data](https://data.iowa.gov/Sales-Distribution/Iowa-Liquor-Sales/m3tr-qhgy)
- Learn more about [data preparation for time-series forecasting](https://towardsdatascience.com/preparing-data-for-time-series-analysis-cd6f080e6836)
- Learn more about [DBT](https://www.getdbt.com/product/what-is-dbt/)
<!-- - Learn more about [dbt-bigquery](https://docs.getdbt.com/reference/warehouse-setups/bigquery-setup)
- Learn more about [Google BigQuery](https://cloud.google.com/bigquery)
- Learn more about [Google Dataproc Serverless](https://cloud.google.com/dataproc-serverless/docs)
- Learn more about [Google Colab](https://research.google.com/colaboratory/faq.html)
- Learn more about [darts](https://unit8.com/resources/darts-time-series-made-easy-in-python/) -->
- Learn more about [Prophet](https://facebook.github.io/prophet/docs/quick_start.html)
- Learn more about [pypark pandas_udf](https://spark.apache.org/docs/3.1.2/api/python/reference/api/pyspark.sql.functions.pandas_udf.html)