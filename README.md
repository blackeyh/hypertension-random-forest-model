# 🌐 Random Forest Health Prediction Web App  
**Powered by Flask, Firebase, and Flutter**

🚀 A complete end-to-end machine learning solution for health classification using a Random Forest model — equipped with explainability, real-time prediction via Flask API, remote data logging via Firebase Firestore, and a Flutter-based mobile UI.

---

## 🧠 Why This Project?

This project bridges the gap between **ML development** and **real-world deployment**. It uses a highly accurate Random Forest classifier (up to **97% accuracy**) for predicting diabetes, heart conditions, and related health risks — all accessible via a **mobile app**, **Flask API**, and **Firebase-backed storage**.

---

## 📌 Features at a Glance

- ✅ **Random Forest Classifier** with dimensionality reduction via PCA.
- 🔍 **Explainable ML** using feature importance charts.
- 🌐 **Flask API** for prediction with JSON input/output.
- ☁️ **Firebase Firestore** for real-time cloud storage and logs.
- 📱 **Flutter App** for data input and live feedback.
- 📊 **Model Evaluation Metrics** (Accuracy, Precision, Recall, F1-score).
- 🧪 **Training code included** (`python/diabetes_hypertension_predict_acc_97.py`).

---

## ⚙️ ML Pipeline Overview

1. **Data Preprocessing**
   - Handle missing values.
   - Encode categorical features.
   - Standardize using `StandardScaler`.
   - Apply `PCA` for noise reduction.

2. **Model Training**
   - Train a `RandomForestClassifier` with optional grid search.
   - Save the model using `joblib`.

3. **Model Evaluation**
   - Outputs: Accuracy, Precision, Recall, F1 Score, Confusion Matrix.

4. **Model Serving (Flask API)**
   - Accepts POST requests with JSON payload.
   - Returns prediction results and logs to Firestore.

5. **Mobile Interface**
   - Flutter app where users can input medical details and receive predictions.

6. **Explainability**
   - Feature importance is visualized for transparency and trust.

---

## 🧾 Input Parameters

| Parameter             | Type     | Description                                  |
|-----------------------|----------|----------------------------------------------|
| `gender`              | String   | "Male" / "Female"                            |
| `age`                 | Number   | Age in years                                 |
| `heart_disease_history` | Binary | 1 = Yes, 0 = No                              |
| `smoking_history`     | Binary   | 1 = Yes, 0 = No                              |
| `hba1c_level`         | Float    | Long-term blood sugar level (%)              |
| `blood_glucose_level` | Float    | Current blood glucose (mg/dL)                |
| `diabetes`            | Binary   | 1 = Yes, 0 = No                              |

---

## 📊 Model Performance

The Random Forest model demonstrates high performance on the validation set:

| Metric       | Class 0 (No Risk) | Class 1 (At Risk) |
|--------------|------------------|-------------------|
| Precision    | 0.93             | 0.91              |
| Recall       | 0.91             | 0.93              |
| F1-Score     | 0.92             | 0.92              |
| **Accuracy** | **0.92** overall |

---

## 📸 UI Previews & Insights

### 🧬 Diabetes Entry Interface
![Diabetes Entry Page](diabetes_entry_page.png)

### 🔥 Feature Importance Visual
![Feature Importance](feature_importance_with_model_prediction.png)

### 👥 Gender, Age, Height Input
![Gender, Height, Weight, Age](gender_height_weight_age_entry_page.png)

### 📈 HbA1c Input
![HbA1c Entry](hbai1c_entry_page.png)

### ❤️ Heart Disease History Input
![Heart Disease Entry](heart_disease_entry_page.png)

### 🚬 Smoking History Input
![Smoking History](smoke_history_page.png)

---

## 🔌 Flask API Endpoints

| Endpoint   | Method | Description                  |
|------------|--------|------------------------------|
| `/predict` | POST   | Accepts JSON input & returns model prediction |
  
Example Input:
```json
{
  "age": 45,
  "gender": "Male",
  "heart_disease_history": 1,
  "smoking_history": 0,
  "hba1c_level": 6.1,
  "blood_glucose_level": 145,
  "diabetes": 1
}
```

## 🔐 Firebase Firestore Integration

All predictions and user inputs are securely logged.

Enables real-time updates and persistent health tracking.

---

##🧰 Tech Stack

🧪 Python Libraries
pandas, numpy, matplotlib, seaborn

scikit-learn

flask, joblib

firebase-admin

os, warnings

📲 Mobile App
Built with Flutter

Uses cloud_firestore, firebase_core, fl_chart

---

##🧠 Use Cases
💼 Health Risk Assessments in Telemedicine

🧬 Diabetes/Heart Disease Early Detection

🩺 Patient Health Logging & Monitoring Apps

🧑‍⚕️ ML-integrated Healthcare Dashboards

---

##📜 License
Licensed under the MIT License. See the LICENSE file for more details.

--

##🙏 Acknowledgments
🔥 Firebase – Realtime NoSQL database and auth

🧩 Flutter – Fast UI development

⚙️ scikit-learn – Reliable ML modeling

🌐 Flask – API serving made easy

🧠 Open-source contributors who inspire ML in healthcare



"Making health intelligence accessible, explainable, and actionable."
