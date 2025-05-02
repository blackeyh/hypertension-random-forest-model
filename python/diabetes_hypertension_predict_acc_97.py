#  import libraries
import pandas as pd # Reading Dataset , Data preporecession
import numpy as np
import matplotlib.pyplot as plt ## visualzation
import seaborn as sns
# Machine Learnign model
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from xgboost import XGBClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix, classification_report
from sklearn.model_selection import train_test_split
import warnings
warnings.filterwarnings("ignore")



df = pd.read_csv("diabetes_prediction_dataset_(1).csv")
df.head(10)

df.describe()

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from xgboost import XGBClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix, classification_report
from sklearn.model_selection import train_test_split
import warnings

warnings.filterwarnings("ignore")

df = pd.read_csv("diabetes_prediction_dataset_(1).csv")
#Check for diabetes values overall
diabetes_counts = df['diabetes'].value_counts()
diabetes_counts

df.info()

print("Number of rows:", df.shape[0])
print("Number of columns:", df.shape[1])
print("\nOverall information:")
print(df.info())


# check for null values
df.isnull().sum()


# check duplicate values
print(df.duplicated().sum())
# remove duplicate values
df = df.drop_duplicates()
print("______Removed Duplicate______")
print(df.duplicated().sum())


def add_counts(ax):
    for p in ax.patches:
        ax.annotate(f'{int(p.get_height())}', (p.get_x() + p.get_width() / 2., p.get_height()),
                    ha='center', va='center', fontsize=10, color='black', xytext=(0, 5),
                    textcoords='offset points')

# Set up the matplotlib figure


import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Function to add counts on bars
def add_counts(ax):
    for p in ax.patches:
        ax.annotate(f'{int(p.get_height())}',
                    (p.get_x() + p.get_width() / 2., p.get_height()),
                    ha='center', va='center', fontsize=10, color='black',
                    xytext=(0, 5), textcoords='offset points')

# Set up the matplotlib figure


# Calculate minimum, maximum, and average age
min_age = df['age'].min()
max_age = df['age'].max()
avg_age = df['age'].mean()

# Count of individuals with and without diabetes
diabetes_counts = df['diabetes'].value_counts()

# Group by diabetes status and calculate min and max ages
grouped_ages = df.groupby('diabetes')['age'].agg(['min', 'max'])

# Print the results

# Plotting



# Calculate minimum, maximum, and average age
min_age = df['age'].min()
max_age = df['age'].max()
avg_age = df['age'].mean()

# Count of individuals with and without hypertension
hypertension_counts = df['hypertension'].value_counts()

# Group by hypertension status and calculate min and max ages
grouped_ages_hypertension = df.groupby('hypertension')['age'].agg(['min', 'max'])



# Plotting

# P


# Calculate minimum, maximum, and average BMI
min_bmi = df['bmi'].min()
max_bmi = df['bmi'].max()
avg_bmi = df['bmi'].mean()

# Count of individuals with and without hypertension
hypertension_counts = df['hypertension'].value_counts()

# Group by hypertension status and calculate min and max BMI
grouped_bmi_hypertension = df.groupby('hypertension')['bmi'].agg(['min', 'max', 'mean'])



min_bmi = df['bmi'].min()
max_bmi = df['bmi'].max()
avg_bmi = df['bmi'].mean()

# Count of individuals with and without diabetes
diabetes_counts = df['diabetes'].value_counts()

# Group by diabetes status and calculate min, max, and mean BMI
grouped_bmi_diabetes = df.groupby('diabetes')['bmi'].agg(['min', 'max', 'mean'])

# Print the results
print(f"Minimum BMI: {min_bmi}")
print(f"Maximum BMI: {max_bmi}")
print(f"Average BMI: {avg_bmi}")
print("Diabetes Counts:")
print(diabetes_counts)
print("BMI Statistics by Diabetes Status:")
print(grouped_bmi_diabetes)

# Plotting


# Calculate minimum, maximum, and average glucose levels and HbA1c levels
min_glucose = df['blood_glucose_level'].min()
max_glucose = df['blood_glucose_level'].max()
avg_glucose = df['blood_glucose_level'].mean()

min_hba1c = df['HbA1c_level'].min()
max_hba1c = df['HbA1c_level'].max()
avg_hba1c = df['HbA1c_level'].mean()

# Group by diabetes and hypertension status to calculate stats for glucose and HbA1c levels
grouped_glucose = df.groupby(['diabetes', 'hypertension'])['blood_glucose_level'].agg(['min', 'max', 'mean'])
grouped_hba1c = df.groupby(['diabetes', 'hypertension'])['HbA1c_level'].agg(['min', 'max', 'mean'])



import matplotlib.pyplot as plt
import seaborn as sns

# Box plot for 'age' grouped by 'diabetes'


cross_table = pd.crosstab(df['diabetes'], df['smoking_history'])

# Create subplots

# Plotting the cross table as a heatmap


# Create a crosstab for hypertension and smoking history
cross_table = pd.crosstab(df['hypertension'], df['smoking_history'])

# Create subplots

# Plotting the cross table as a heatmap




import matplotlib.pyplot as plt
import seaborn as sns

# Distribution of Hypertension



from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from xgboost import XGBClassifier
from sklearn.metrics import classification_report, roc_auc_score

# Assuming 'df' is your dataset, encode the data
le = LabelEncoder()
df['gender'] = le.fit_transform(df['gender'])
df['smoking_history'] = le.fit_transform(df['smoking_history'])

# Step 2: Define features (X) and target (y)
X = df.drop(columns=['hypertension'])  # Drop the target variable
y = df['hypertension']  # Target variable


from imblearn.over_sampling import SMOTE
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from xgboost import XGBClassifier
from sklearn.metrics import classification_report, roc_auc_score

# Apply SMOTE to balance the dataset
smote = SMOTE(random_state=42)
X_resampled, y_resampled = smote.fit_resample(X, y)

# Train-test split
X_train, X_test, y_train, y_test = train_test_split(X_resampled, y_resampled, test_size=0.3, random_state=42)

from imblearn.over_sampling import SMOTE
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from xgboost import XGBClassifier
from sklearn.metrics import classification_report, roc_auc_score

# Apply SMOTE to balance the dataset
smote = SMOTE(random_state=42)
X_resampled, y_resampled = smote.fit_resample(X, y)

# Train-test split
X_train, X_test, y_train, y_test = train_test_split(X_resampled, y_resampled, test_size=0.3, random_state=42)

# Train Models
log_reg = LogisticRegression(class_weight='balanced', random_state=42, max_iter=1000)
log_reg.fit(X_train, y_train)

rf = RandomForestClassifier(class_weight='balanced', random_state=42)
rf.fit(X_train, y_train)

xgb = XGBClassifier(scale_pos_weight=(y_train.value_counts()[0] / y_train.value_counts()[1]), random_state=42)
xgb.fit(X_train, y_train)

# Evaluate Models
models = {"Logistic Regression": log_reg, "Random Forest": rf, "XGBoost": xgb}
for model_name, model in models.items():
    y_pred = model.predict(X_test)
    y_prob = model.predict_proba(X_test)[:, 1] if hasattr(model, "predict_proba") else None
    print(f"\n{model_name} Classification Report:\n")
    print(classification_report(y_test, y_pred))
    if y_prob is not None:
        print(f"{model_name} ROC-AUC Score: {roc_auc_score(y_test, y_prob):.2f}")

from sklearn.metrics import classification_report, roc_auc_score, roc_curve, auc, confusion_matrix, ConfusionMatrixDisplay
import matplotlib.pyplot as plt

# Logistic Regression Evaluation
print("Evaluating Logistic Regression...")

# Predictions
log_reg_pred = log_reg.predict(X_test)
log_reg_prob = log_reg.predict_proba(X_test)[:, 1]

# Classification Report
print("\nLogistic Regression Classification Report:\n")
print(classification_report(y_test, log_reg_pred))

# ROC Curve
fpr, tpr, _ = roc_curve(y_test, log_reg_prob)
roc_auc = auc(fpr, tpr)





from sklearn.metrics import classification_report, roc_auc_score, roc_curve, auc, confusion_matrix, ConfusionMatrixDisplay
import matplotlib.pyplot as plt

# Random Forest Evaluation and Visualization
print("Evaluating Random Forest...")
rf_pred = rf.predict(X_test)
rf_prob = rf.predict_proba(X_test)[:, 1]

# Classification Report
print("\nRandom Forest Classification Report:\n")
print(classification_report(y_test, rf_pred))

# ROC Curve
fpr, tpr, _ = roc_curve(y_test, rf_prob)
roc_auc = auc(fpr, tpr)






import pandas as pd

sample_test_data = pd.DataFrame({
    'age': [45, 70, 55, 60],
    'heart_disease': [1, 0, 0, 1],
    'bmi': [27.5, 30.0, 25.0, 32.5],
    'HbA1c_level': [6.5, 5.8, 5.4, 7.0],
    'blood_glucose_level': [140, 120, 110, 180],
    'diabetes': [1, 0, 0, 1],
    'gender': [1, 0, 1, 0],  # Encoded values for gender
    'smoking_history': [3, 0, 2, 1]  # Encoded values for smoking history
})

# Reorder columns to match the training dataset
sample_test_data = sample_test_data[X_train.columns]

# Function to map numerical predictions to text
def map_prediction_to_text(predictions):
    return ["Hypertensive" if pred == 1 else "Non-Hypertensive" for pred in predictions]

# List to store results for exporting (optional)
results = []

# Loop through each model and make predictions
for model_name, model in models.items():
    print(f"\n{model_name} Sample Test Predictions:")

    # Predict classes
    sample_predictions = model.predict(sample_test_data)
    sample_predictions_text = map_prediction_to_text(sample_predictions)
    print("Predicted Class (Hypertension):", sample_predictions_text)

    # Predict probabilities if available
    if hasattr(model, "predict_proba"):
        sample_probabilities = model.predict_proba(sample_test_data)[:, 1]
        for i, prob in enumerate(sample_probabilities):
            prob_text = f"Individual {i+1} Probability of Hypertension: {prob:.2%} ({'Likely Hypertensive' if prob > 0.5 else 'Likely Non-Hypertensive'})"
            print(prob_text)

            # Add results to list for exporting
            results.append({
                "Model": model_name,
                "Individual": i + 1,
                "Predicted Class": sample_predictions_text[i],
                "Probability of Hypertension": f"{prob:.2%}"
            })
    else:
        print("Model does not support probability predictions.")
        for i, pred_text in enumerate(sample_predictions_text):
            # Add results to list for exporting
            results.append({
                "Model": model_name,
                "Individual": i + 1,
                "Predicted Class": pred_text,
                "Probability of Hypertension": "N/A"
            })

# Optionally, export results to a CSV
results_df = pd.DataFrame(results)
results_df.to_csv("sample_test_predictions.csv", index=False)

# Print results for verification
print("\nPredictions saved to 'sample_test_predictions.csv'.")

import joblib

# Re-save the trained model
joblib.dump(rf, r"D:\work\maya\random_forest_model.pkl")
print("Model saved successfully!")
