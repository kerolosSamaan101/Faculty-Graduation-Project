from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import pickle
import re
import nltk
from nltk.corpus import stopwords
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.sequence import pad_sequences

# Setup
app = Flask(__name__)
CORS(app)
nltk.download('stopwords')
stop_words = set(stopwords.words('english'))

# Load tokenizer and model
with open('tokenizer.pkl', 'rb') as file:
    tokenizer = pickle.load(file)

model = load_model('0.9516 10th.h5')

# Preprocessing function
def clean_text(text):
    text = text.lower()  # Lowercase
    text = re.sub(r"[^\w\s]", "", text)  # Remove punctuation
    tokens = text.split()
    tokens = [word for word in tokens if word not in stop_words]  # Remove stopwords
    return " ".join(tokens)

def preprocess_text(text, tokenizer, max_length=150):
    cleaned_text = clean_text(text)
    seq = tokenizer.texts_to_sequences([cleaned_text])
    padded_seq = pad_sequences(seq, maxlen=max_length, padding="post", truncating="post")
    return padded_seq

# Prediction route
@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.get_json()
        text = data.get("text", "").strip()

        if not text:
            return jsonify({"error": "No text provided"}), 400

        processed_text = preprocess_text(text, tokenizer)

        # Predict
        prediction_prob = model.predict(processed_text)[0][0]
        result = 1 if prediction_prob > 0.5 else 0

        return jsonify({
            "prediction": result
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Run the app
if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=5000)
