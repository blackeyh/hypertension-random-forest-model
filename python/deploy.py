from flask import Flask, request, jsonify
import pandas as pd
import joblib
import os
import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Flask app
app = Flask(__name__)

# Path to your dataset and model files
dataset_path = r"diabetes_prediction_dataset_(1).csv"
model_path = r"random_forest_model.pkl"
feature_names_path = r"feature_names.pkl"
firebase_cred_path = r"firebasecredpath"

# Initialize Firebase
cred = credentials.Certificate(firebase_cred_path)
firebase_admin.initialize_app(cred)

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


# Function to retrieve data from Firestore
def get_patient_data_from_firestore(email):
    db = firestore.client()
    doc_ref = db.collection('users').document(email)
    doc = doc_ref.get()

    if doc.exists:
        data = doc.to_dict()
        print("Retrieved Data from Firestore:")
        print(data)

        # Convert the fields to the expected types explicitly (e.g., float for numeric fields)
        patient_data = {
            "age": int(data.get("age", 0)),  # Ensure 'age' is an integer
            "heart_disease": 1 if data.get("heart_disease", False) else 0,
            "hbA1c_level": float(data.get("hbA1c_level", 0.0)),  # Ensure 'hbA1c_level' is a float
            "blood_glucose_level": float(data.get("blood_glucose_level", 0.0)),  # Ensure 'blood_glucose_level' is a float
            "diabetes": 1 if data.get("has_diabetes", False) else 0,
            "gender": 1 if data.get("gender", "").lower() == "male" else 0,
            "smoking_history": int(data.get("smoking_history", 0)),  # Ensure 'smoking_history' is an integer
        }

        # Handle height and weight to calculate BMI
        height = float(data.get("height", 0))  # assuming height is in cm
        weight = float(data.get("weight", 0))  # assuming weight is in kg
        if height > 0 and weight > 0:
            bmi = weight / (height / 100) ** 2  # BMI formula
        else:
            bmi = 0  # Default BMI if height or weight is invalid
        patient_data["bmi"] = bmi

        print("Mapped Patient Data for Prediction:")
        print(patient_data)

        return patient_data
    else:
        print(f"Document for {email} does not exist.")
        return None


# Route to handle prediction requests
@app.route('/predict', methods=['POST'])
def predict():
    # Get email from the request body
    data = request.get_json()
    email = data.get("email")

    if not email:
        return jsonify({"error": "Email is required in the request."}), 400

    # Get patient data from Firestore
    patient_data = get_patient_data_from_firestore(email)

    if not patient_data:
        return jsonify({"error": f"Patient data not found or incomplete for email: {email}."}), 404

    # Check if all required data is present
    missing_data = []
    for feature in feature_names:
        if feature not in patient_data:
            missing_data.append(feature)



    # Convert to DataFrame and ensure column order matches the model's expectation
    patient_data_df = pd.DataFrame([patient_data], columns=feature_names)

    # Predict using the loaded model
    try:
        prediction = rf_model.predict(patient_data_df)[0]
        probability = rf_model.predict_proba(patient_data_df)[0][1]  # Probability of hypertension

        prediction_result = {
            "Predicted Class": "Hypertensive" if prediction == 1 else "Non-Hypertensive",
            "Probability of Hypertension": f"{probability:.2%}"
        }
    except Exception as e:
        # Catch prediction-related errors and provide more context
        return jsonify({"error": f"An error occurred during the prediction process: {str(e)}. "
                                 "Please ensure the model is loaded correctly and the input data is formatted properly."}), 500

    # Get feature importances
    try:
        feature_importances = rf_model.feature_importances_

        # Create a DataFrame for better visualization
        importance_df = pd.DataFrame({
            "Feature": feature_names,
            "Importance": feature_importances
        }).sort_values(by="Importance", ascending=False)

        importance_text = importance_df.to_string(index=False)

    except AttributeError as e:
        # Catch errors related to feature importances and provide context
        return jsonify({"error": f"An error occurred while retrieving feature importances: {str(e)}. "
                                 "Please check the model and feature importance data."}), 500

    return jsonify({
        "prediction": prediction_result,
        "feature_importances": importance_text
    })



app.run(debug=True, host="0.0.0.0", port=8000)
