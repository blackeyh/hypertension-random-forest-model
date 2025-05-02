import pandas as pd
import joblib
import os
import numpy as np
import matplotlib.pyplot as plt

# Path to your dataset and model files
dataset_path = r"diabetes_prediction_dataset_(1).csv"
model_path = r"random_forest_model.pkl"
feature_names_path = r"feature_names.pkl"

# Ensure the feature names file exists
if not os.path.exists(feature_names_path):
    print("Feature names file not found. Creating it now...")

    # Load the dataset to extract feature names
    df = pd.read_csv(dataset_path)

    # Define features (X) and target (y)
    X = df.drop(columns=["hypertension"])  # Drop target variable
    feature_names = X.columns.tolist()

    # Save feature names
    joblib.dump(feature_names, feature_names_path)
    print(f"Feature names saved successfully at: {feature_names_path}")
else:
    # Load feature names if the file exists
    feature_names = joblib.load(feature_names_path)
    print(f"Feature names loaded from: {feature_names_path}")

# Load the trained model
try:
    rf_model = joblib.load(model_path)
    print("Model loaded successfully!")
except Exception as e:
    print(f"Error loading model: {e}")
    exit()

# Function to gather patient input
def get_patient_data():
    print("Please enter the following patient details:")
    data = {
        "age": float(input("Age: ")),
        "heart_disease": int(input("Heart Disease (1 for Yes, 0 for No): ")),
        "bmi": float(input("BMI: ")),
        "HbA1c_level": float(input("HbA1c Level: ")),
        "blood_glucose_level": float(input("Blood Glucose Level: ")),
        "diabetes": int(input("Diabetes (1 for Yes, 0 for No): ")),
        "gender": int(input("Gender (1 for Male, 0 for Female): ")),
        "smoking_history": int(input("Smoking History (3 = Heavy, 2 = Moderate, 1 = Light, 0 = None): "))
    }

    # Convert to DataFrame and ensure column order matches the model's expectation
    patient_data = pd.DataFrame([data], columns=feature_names)
    return patient_data

# Get patient input
patient_data = get_patient_data()
print(f"Input data shape: {patient_data.shape}")

# Predict using the loaded model
try:
    prediction = rf_model.predict(patient_data)[0]
    probability = rf_model.predict_proba(patient_data)[0][1]  # Probability of hypertension

    print("\nPrediction Result:")
    print(f"Predicted Class: {'Hypertensive' if prediction == 1 else 'Non-Hypertensive'}")
    print(f"Probability of Hypertension: {probability:.2%}")
except Exception as e:
    print(f"Error during prediction: {e}")

# Get and visualize feature importances
try:
    feature_importances = rf_model.feature_importances_

    # Create a DataFrame for better visualization
    importance_df = pd.DataFrame({
        "Feature": feature_names,
        "Importance": feature_importances
    }).sort_values(by="Importance", ascending=False)

    print("\nFeature Importances:")
    print(importance_df)

    # Visualize feature importance
    plt.figure(figsize=(10, 6))
    plt.barh(importance_df["Feature"], importance_df["Importance"], color="skyblue")
    plt.xlabel("Feature Importance")
    plt.ylabel("Feature")
    plt.title("Feature Importance in Random Forest Model")
    plt.gca().invert_yaxis()  # Invert y-axis for better readability
    plt.show()
except AttributeError as e:
    print(f"Error retrieving feature importances: {e}")
