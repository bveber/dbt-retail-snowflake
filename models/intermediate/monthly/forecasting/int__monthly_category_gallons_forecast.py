import pandas as pd
from prophet import Prophet

# from darts.models.forecasting.prophet_model import Prophet
# from darts import TimeSeries
from snowflake.snowpark.functions import unix_timestamp, col
from snowflake.snowpark.types import (
    StructType,
    StructField,
    StringType,
    FloatType,
    DateType,
)


def model(dbt, session):
    dbt.config(
        materialized="table", packages=["pandas==1.5.3", "holidays==0.18", "prophet"]
    )

    def fit_and_predict(df):
        df.columns = ["STORE_NUMBER", "CATEGORY", "SALES_MONTH", "TOTAL_GALLONS"]
        ts = df[["SALES_MONTH", "TOTAL_GALLONS"]].rename(
            columns={"SALES_MONTH": "ds", "TOTAL_GALLONS": "y"}
        )
        model = Prophet()
        model.add_seasonality(
            name="annual",  # (name of the seasonality component),
            period=12,  # (nr of steps composing a season),
            fourier_order=2,  # (number of Fourier components to use),
        )
        model.fit(ts)
        forecast_horizon = 12
        future = model.make_future_dataframe(periods=forecast_horizon, freq="MS").tail(
            forecast_horizon
        )
        prediction = model.predict(future)

        preds_dict = {
            "STORE_NUMBER": df["STORE_NUMBER"].iloc[0],
            "CATEGORY": df["CATEGORY"].iloc[0],
            "SALES_MONTH": [],
            "FORECAST": [],
        }
        for i in range(len(prediction)):
            preds_dict["SALES_MONTH"].append(prediction.iloc[i]["ds"])
            preds_dict["FORECAST"].append(prediction.iloc[i]["yhat"])
        output_df = pd.DataFrame(preds_dict)
        output_df = output_df[["STORE_NUMBER", "CATEGORY", "SALES_MONTH", "FORECAST"]]
        return output_df

    my_sql_model_df = dbt.ref(
        "int__monthly_category_sales_filled_missing_dates_filtered"
    )
    print(my_sql_model_df.dtypes)

    final_df = (
        my_sql_model_df.select(
            "STORE_NUMBER", "CATEGORY", "SALES_MONTH", "TOTAL_GALLONS"
        )
        .groupBy(["STORE_NUMBER", "CATEGORY"])
        .applyInPandas(
            fit_and_predict,
            output_schema=StructType(
                [
                    StructField("STORE_NUMBER", StringType()),
                    StructField("CATEGORY", StringType()),
                    StructField("SALES_MONTH", DateType()),
                    StructField("FORECAST", FloatType()),
                ]
            ),
        )
    )

    return final_df
