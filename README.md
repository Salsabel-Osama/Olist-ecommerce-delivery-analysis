# 🛒 Olist E-Commerce — Business Analytics & Late Delivery Prediction

## 📌 Project Overview

This project analyzes the **Brazilian Olist E-Commerce dataset** to understand business performance, customer and seller behavior, delivery performance, and the factors associated with late deliveries.

The project follows a complete data analytics workflow:

> **Raw Data → Data Cleaning → EDA → SQL Server → Business Insights → Machine Learning → Risk Segmentation → Final Recommendations**

The main objective is not only to analyze historical data, but to transform the data into **actionable business insights** and build a machine learning model that can identify orders with a higher risk of late delivery.

---

# 🎯 THE DISCOVERY MISSION

## Go Beyond the Data. Find the Story.

### What is happening in the business?

Olist has a large volume of orders, with more than **99K orders** in the dataset.

Most orders are delivered successfully, but late delivery remains an important operational issue.

From the analysis:

* Total orders: **99,441**
* Delivered orders: **96,478**
* Late orders: **7,827**
* Overall late-delivery rate: **7.87%**

Although the majority of orders are not late, thousands of orders still experience delivery delays.

This makes delivery performance an important area for operational monitoring and prediction.

---

# 🔎 Where Are the Frictions or Challenges?

Several challenges appeared during the analysis.

### 1. Delivery delays

The overall late-delivery rate is:

**7.87%**

This means that approximately 8 out of every 100 orders were classified as late.

The problem becomes more visible when looking at different periods and operational characteristics.

---

### 2. Strong seasonal variation

Late delivery rates vary considerably by month.

Some months show significantly higher late-delivery rates than others.

The analysis showed particularly high late-delivery percentages in:

* March: **16.56%**
* November: **13.83%**
* February: **12.95%**

While lower rates were observed in months such as:

* June: **2.17%**
* July: **3.96%**

This suggests that delivery performance is not constant throughout the year.

Seasonality should therefore be considered when planning logistics capacity and delivery operations.

---

### 3. Delivery time is strongly related to late delivery

The correlation analysis showed:

| Variable                | Correlation with Late Delivery |
| ----------------------- | -----------------------------: |
| Delivery Time           |                      **0.590** |
| Carrier Time            |                      **0.212** |
| Approval Time           |                          0.021 |
| Delivery Estimation Gap |                         -0.060 |

The strongest relationship was observed between **delivery time and late delivery**.

This is expected operationally: orders requiring longer delivery times have a greater likelihood of exceeding the expected delivery date.

However, delivery-time-related variables were deliberately excluded from the machine learning model because they are only known **after the delivery process has already progressed** and would create data leakage.

---

# 📊 Key Business Metrics

## Orders

* **99,441** total orders
* **96,478** delivered
* **1,107** shipped
* **625** canceled
* **609** unavailable
* Remaining orders were in created, approved, invoiced, or processing states.

---

## Late Delivery

| Metric         |     Value |
| -------------- | --------: |
| Total orders   |    99,441 |
| On-time orders |    91,614 |
| Late orders    |     7,827 |
| Late rate      | **7.87%** |

The dataset is highly imbalanced because late orders represent a relatively small portion of all orders.

This imbalance became an important consideration during machine learning.

---

# 💰 Sales & Payment Insights

The aggregated order-level data showed:

| Metric               |       Mean |
| -------------------- | ---------: |
| Product value        | **137.75** |
| Freight value        |  **22.82** |
| Payment value        | **160.99** |
| Payment count        |   **1.04** |
| Maximum installments |   **2.93** |

Most orders contain only one item:

* Median number of items: **1**
* Mean number of items: **1.14**
* Orders with multiple items: **9,803**

Similarly, most orders use a single payment:

* Median payment count: **1**
* Mean payment count: **1.04**
* Orders with multiple payments: **2,961**

---

# 🚚 Delivery Performance

The analysis identified several operational patterns.

### Delivery duration

For delivered orders:

* Mean delivery time: **12.56 days**
* Median delivery time: **10.22 days**
* 75th percentile: **15.72 days**
* Maximum observed delivery time: approximately **209.63 days**

The large maximum indicates the presence of extreme delivery durations.

---

# 📅 Seasonality

Late-delivery rates vary by month.

| Month     |  Late Rate |
| --------- | ---------: |
| January   |      6.04% |
| February  | **12.95%** |
| March     | **16.56%** |
| April     |      5.80% |
| May       |      6.47% |
| June      |  **2.17%** |
| July      |      3.96% |
| August    |      7.37% |
| September |      5.04% |
| October   |      4.84% |
| November  | **13.83%** |
| December  |      8.14% |

The results suggest that some periods experience considerably more delivery pressure than others.

---

# 📈 Yearly Delivery Trend

The late-delivery rate increased across the observed years:

| Year | Late Rate |
| ---- | --------: |
| 2016 |     1.22% |
| 2017 |     6.38% |
| 2018 | **9.16%** |

This indicates a substantial increase in the share of late deliveries over the observed period.

The result deserves further investigation because it could reflect changes in order volume, logistics operations, geographic distribution, seller mix, or other factors.

---

# 🧹 Data Cleaning

The original dataset contained multiple raw tables:

* Customers
* Geolocation
* Order Items
* Payments
* Reviews
* Orders
* Products
* Sellers
* Category Translation

Data quality checks were performed before analysis.

### Duplicate checks

Duplicate and inconsistent records were investigated.

### Date validation

Negative operational durations were identified.

For example:

**166 orders** initially had negative carrier times.

These records were investigated and corrected/invalid values were removed from the relevant calculations.

After cleaning:

> **Negative carrier times = 0**

Negative approval times:

> **0**

---

# 🗃️ Missing Values

Some missing values remained intentionally because they represent legitimate business situations.

Examples include:

* Orders that were not approved yet
* Orders that were not shipped
* Orders that were not delivered
* Orders without matching item records
* Orders without payment records

Final master dataset:

**99,441 rows × 21 columns**

---

# 🗄️ SQL Server Integration

The cleaned datasets were loaded into **Microsoft SQL Server** using the database:

`OlistDB`

The SQL analysis connected the main Olist tables and created business-oriented queries.

The SQL analysis covered five main areas:

1. **Sales & Revenue Analysis**
2. **Customer & Seller Analysis**
3. **Delivery Performance & Business Insights**
4. **Product / Category Analysis**
5. **Review & Customer Satisfaction**

The SQL layer was used to move from simple descriptive analysis toward relational business analysis using:

* `JOIN`
* `GROUP BY`
* `CASE`
* Aggregations
* Filtering
* Date functions
* Subqueries
* Business metrics

This allowed the project to answer questions across multiple tables rather than analyzing each dataset independently.

---

# 🔗 Data Relationships

The main relational structure can be summarized as:

```text
Customers
    |
    | customer_id
    v
Orders
    |
    +------------------+
    |                  |
    | order_id         | order_id
    v                  v
Order Items         Payments
    |
    | product_id
    v
Products
    |
    | product_category_name
    v
Category Translation

Orders
    |
    | customer_id
    v
Customers

Order Items
    |
    | seller_id
    v
Sellers
```

This relational structure was important for answering cross-functional business questions.

---

# 🤖 Machine Learning

## Objective

The machine learning objective was:

> **Predict whether an order is likely to experience late delivery.**

Target variable:

```text
late_delivery
```

Where:

* `0` = not late
* `1` = late

---

# ⚠️ Data Leakage Prevention

A major part of the ML preparation was preventing data leakage.

Variables that describe events occurring after or during the delivery process were excluded.

Excluded features included:

* `delivery_time_days`
* `carrier_time_days`
* `delivery_estimation_gap_days`
* `order_delivered_customer_date`
* `order_delivered_carrier_date`

These variables could provide information that would not realistically be available when trying to predict delivery risk in advance.

---

# 🧩 Feature Engineering

The purchase timestamp was transformed into useful features:

* Purchase year
* Purchase month
* Purchase day
* Purchase day of week
* Purchase hour

Additional order-level features included:

* Approval time
* Number of items
* Product value
* Freight value
* Number of unique products
* Number of unique sellers
* Payment value
* Payment count
* Maximum installments
* Order status

Final ML dataset:

**99,441 orders**

---

# ⚖️ Class Imbalance

The target distribution was:

| Class   | Orders | Percentage |
| ------- | -----: | ---------: |
| On-time | 91,614 |     92.13% |
| Late    |  7,827 |      7.87% |

Because the target is imbalanced, accuracy alone is not sufficient for evaluating the model.

Therefore, the project focused on:

* Precision
* Recall
* F1 Score
* ROC-AUC
* PR-AUC
* Confusion Matrix

---

# 🧪 Train / Test Split

The dataset was divided into:

### Training

**79,552 orders**

### Testing

**19,889 orders**

The target distribution was preserved between the training and testing sets.

---

# 🤖 Models Tested

Three classification approaches were evaluated:

### 1. Logistic Regression

Performance:

* ROC-AUC: **0.5997**
* PR-AUC: **0.0996**
* F1: approximately **0.18**

The model was able to identify a relatively large portion of late orders, but with low precision.

---

### 2. Random Forest

Performance:

* ROC-AUC: **0.7482**
* PR-AUC: **0.2149**
* F1: **0.2945**
* Precision: **0.2022**
* Recall: **0.5412**

Random Forest captured nonlinear relationships better than Logistic Regression.

---

### 3. Gradient Boosting

The final selected model was Gradient Boosting.

At the selected threshold of **0.15**:

* Accuracy: **86.10%**
* Precision: **25.22%**
* Recall: **38.98%**
* F1 Score: **30.62%**
* ROC-AUC: **0.7396**
* PR-AUC: **0.2187**

Confusion Matrix:

```text
                 Predicted
                 0       1
Actual 0      16515   1809
Actual 1        955    610
```

Therefore:

* True Negatives: **16,515**
* False Positives: **1,809**
* False Negatives: **955**
* True Positives: **610**

---

# 🎚️ Why Threshold = 0.15?

The default classification threshold of 0.50 was not ideal for identifying late orders.

At the default threshold, Gradient Boosting predicted almost all orders as on-time.

Threshold tuning showed that reducing the threshold improved the detection of late orders.

At threshold **0.15**:

* Precision = **25.22%**
* Recall = **38.98%**
* F1 = **30.62%**

The threshold was therefore selected based on the balance between precision, recall, and F1 rather than relying on the default 0.50 threshold.

---

# 🔍 Feature Importance

The Gradient Boosting model identified the following as the most influential features:

| Feature           | Importance |
| ----------------- | ---------: |
| Purchase Month    | **0.4648** |
| Freight Value     | **0.1564** |
| Purchase Year     | **0.1229** |
| Purchase Day      | **0.1145** |
| Approval Time     |     0.0407 |
| Delivered Status  |     0.0391 |
| Product Value     |     0.0192 |
| Number of Items   |     0.0119 |
| Day of Week       |     0.0093 |
| Number of Sellers |     0.0082 |

### Important interpretation

The model's feature importance indicates which variables were useful for the model's predictions.

It does **not** prove that these variables independently cause late delivery.

For example, the strong importance of purchase month indicates that the model found substantial temporal patterns in the data.

---

# 🚨 Risk Segmentation

The final model was also used to divide test orders into operational risk groups.

## Risk Levels

### 🟢 Low Risk

**15,675 orders**

Actual late-delivery rate:

**4.59%**

---

### 🟡 Medium Risk

**4,168 orders**

Actual late-delivery rate:

**19.91%**

---

### 🔴 High Risk

**46 orders**

Actual late-delivery rate:

**34.78%**

---

# 📊 Risk Segmentation Summary

| Risk Level  | Orders | Late Orders | Actual Late Rate |
| ----------- | -----: | ----------: | ---------------: |
| Low Risk    | 15,675 |         719 |        **4.59%** |
| Medium Risk |  4,168 |         830 |       **19.91%** |
| High Risk   |     46 |          16 |       **34.78%** |

The risk segmentation creates a practical operational layer on top of the machine learning predictions.

The observed late rate increases from the Low Risk group to the Medium and High Risk groups.

This provides a potential framework for prioritizing operational monitoring.

---

# 💡 REAL INSIGHTS

## Insight 1 — Late delivery is a meaningful operational issue

The overall late-delivery rate is **7.87%**.

While most orders arrive on time, the absolute number of late orders is still substantial.

---

## Insight 2 — Delivery performance changes significantly by season

March and November had substantially higher late-delivery rates than several other months.

This indicates that operational planning should consider seasonal patterns.

---

## Insight 3 — Delivery duration is strongly associated with lateness

Delivery time had the strongest simple correlation with late delivery:

**0.590**

However, this variable was excluded from ML because it introduces leakage when predicting risk before delivery is completed.

---

## Insight 4 — Freight cost contains useful predictive information

Freight value was one of the strongest features in the Gradient Boosting model.

This may indicate a relationship between shipping characteristics and delivery risk.

However, the model's feature importance alone should not be interpreted as proof of causality.

---

## Insight 5 — The business can prioritize orders instead of treating all orders equally

Risk segmentation creates three groups with different observed late-delivery rates.

This provides a potential operational workflow:

```text
All Orders
    |
    v
ML Prediction
    |
    +---- Low Risk
    |
    +---- Medium Risk
    |
    +---- High Risk
```

Instead of monitoring every order equally, management could investigate higher-risk orders first.

---

# 🎯 REAL IMPACT

The project can support several business actions.

### 1. Proactive delivery monitoring

Orders identified as higher risk could receive additional monitoring before the expected delivery date.

### 2. Seasonal capacity planning

Higher-risk months can be investigated to determine whether additional logistics capacity is required.

### 3. Logistics investigation

Freight-related patterns can be investigated further to understand whether shipping distance, seller location, destination, or carrier operations contribute to delays.

### 4. Operational prioritization

Risk segmentation can help operations teams prioritize potentially problematic orders.

### 5. Continuous monitoring

The model can be retrained periodically as new order data becomes available.

---

# ⚠️ Limitations

This project has several limitations.

### 1. Historical dataset

The model was trained on historical Olist data and may not automatically generalize to a different business environment.

### 2. Class imbalance

Late deliveries represent only **7.87%** of orders.

Therefore, precision and recall for the late class are more informative than accuracy alone.

### 3. Feature availability

Some potentially useful operational variables were intentionally excluded because they would cause data leakage.

### 4. Feature importance is not causality

A high feature importance does not mean that changing the feature will necessarily cause delivery performance to change.

### 5. Threshold trade-off

The selected threshold prioritizes improved detection of late orders, but it also creates false positives.

The appropriate threshold would ultimately depend on the operational cost of:

* Missing a late order
* Investigating an order that would actually arrive on time

---

# 🏗️ Project Architecture

```text
                RAW OLIST DATA
                       |
                       v
              DATA CLEANING
                       |
                       v
              CLEANED CSV FILES
                       |
             +---------+---------+
             |                   |
             v                   v
         SQL SERVER             EDA
         OlistDB                 |
             |                   |
             v                   v
     BUSINESS ANALYSIS      MASTER DATASET
             |                   |
             +---------+---------+
                       |
                       v
              MACHINE LEARNING
                       |
          +------------+------------+
          |            |            |
          v            v            v
      Logistic     Random       Gradient
     Regression     Forest       Boosting
                       |
                       v
              FINAL MODEL
                       |
                       v
              RISK SEGMENTATION
                       |
                       v
             BUSINESS INSIGHTS
```

---

# 📁 Suggested Project Structure

```text
Olist-Ecommerce-Analytics/
│
├── README.md
│
├── dataset/
│   ├── raw/
│   │   ├── olist_customers_dataset.csv
│   │   ├── olist_geolocation_dataset.csv
│   │   ├── olist_order_items_dataset.csv
│   │   ├── olist_order_payments_dataset.csv
│   │   ├── olist_order_reviews_dataset.csv
│   │   ├── olist_orders_dataset.csv
│   │   ├── olist_products_dataset.csv
│   │   ├── olist_sellers_dataset.csv
│   │   └── product_category_name_translation.csv
│   │
│   └── cleaned_data/
│       ├── ...
│       └── final_ml_predictions.csv
│
├── notebooks/
│   └── Olist_Analysis_ML.ipynb
│
├── sql/
│   ├── 01_sales_revenue.sql
│   ├── 02_customer_seller_analysis.sql
│   ├── 03_delivery_performance.sql
│   ├── 04_product_category_analysis.sql
│   └── 05_reviews_customer_satisfaction.sql
│
└── reports/
    └── project_summary.md
```

---

# 🛠️ Technologies Used

### Python

* Pandas
* NumPy
* Matplotlib
* Seaborn
* Scikit-learn

### Database

* Microsoft SQL Server
* SQLAlchemy
* PyODBC

### Machine Learning

* Logistic Regression
* Random Forest
* Gradient Boosting
* Classification metrics
* Threshold tuning
* Feature importance
* Risk segmentation

---

# 📌 Final Project Conclusion

The analysis demonstrates that the Olist dataset contains meaningful patterns related to delivery performance.

The overall late-delivery rate was **7.87%**, with substantial variation across time periods.

Machine learning models were tested to predict late delivery before using information that would only become available after delivery.

Among the tested approaches, Gradient Boosting produced the final model used for risk segmentation.

At a threshold of **0.15**, the model achieved:

> **Precision: 25.22%**
> **Recall: 38.98%**
> **F1 Score: 30.62%**
> **Accuracy: 86.10%**
> **ROC-AUC: 0.7396**
> **PR-AUC: 0.2187**

The resulting risk segmentation showed different observed late-delivery rates:

* Low Risk → **4.59%**
* Medium Risk → **19.91%**
* High Risk → **34.78%**

This transforms the project from a descriptive analysis into a more practical business analytics solution where historical data is used to identify patterns, predict delivery risk, and support operational prioritization.

---

# 🚀 Future Improvements

Possible future improvements include:

* Hyperparameter tuning
* XGBoost / LightGBM comparison
* Time-based train/test validation
* Geographic features
* Seller-level historical performance
* Customer location features
* Product category features
* Freight-to-product-value ratio
* Distance-based logistics features
* Calibration of predicted probabilities
* Cost-sensitive threshold optimization
* Model monitoring after deployment
* Interactive dashboard using Power BI or Streamlit

---

# 📎 Final Deliverable

The final project combines:

✅ Data Cleaning
✅ Exploratory Data Analysis
✅ Data Quality Validation
✅ SQL Server Database
✅ Multi-table SQL Analysis
✅ Business Metrics
✅ Delivery Analysis
✅ Customer & Seller Analysis
✅ Product & Category Analysis
✅ Review & Satisfaction Analysis
✅ Machine Learning
✅ Leakage Prevention
✅ Threshold Optimization
✅ Gradient Boosting
✅ Feature Importance
✅ Risk Segmentation
✅ Business Recommendations

---

# ⭐ Project Takeaway

> **The goal of this project was not simply to build a machine learning model.**
>
> The goal was to move from raw transactional data to a complete business understanding:
>
> **What is happening → Why it matters → What patterns exist → What can be predicted → How the business can act on it.**

**From Data → Insights → Prediction → Business Impact.**
