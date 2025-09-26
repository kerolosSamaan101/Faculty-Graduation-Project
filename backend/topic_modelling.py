from flask import Flask, request, jsonify
import torch
from transformers import AutoModelForSequenceClassification, AutoTokenizer
import nltk
from nltk.corpus import stopwords
from nltk.stem import PorterStemmer
import string
import re
from bs4 import BeautifulSoup
import html

nltk.download('stopwords')
nltk.download('punkt')

stemmer = PorterStemmer()
stop_words = set(stopwords.words('english'))

def preprocess_text(text):
    if not text:  
        return ""

    soup = BeautifulSoup(text, "html.parser")
    for code in soup.find_all("code"):
        code.extract()
    text = soup.get_text()
    
    text = html.unescape(text)
    
    text = re.sub(r'\s+', ' ', text).strip()
    
    text = text.lower()
    
    allowed_words = {
        "a", "an", "the", "this", "that", "these", "those",
        "my", "your", "our", "his", "her", "its", "their",
        "some", "any", "each", "every", "either", "neither",
        "enough", "all", "both", "which", "what", "whose",
        "other", "another", "not", "no", "never", "none",
        "nobody", "nothing", "neither", "nowhere"
    }
    filtered_stop_words = stop_words - allowed_words

    tokens = text.split()
    processed_tokens = []
    
    for token in tokens:
        if token == "?" or token.isalpha():
            if token in allowed_words or token not in filtered_stop_words:
                stemmed_word = stemmer.stem(token) if token not in allowed_words else token
                processed_tokens.append(stemmed_word)
    
    return ' '.join(processed_tokens)

def predict_text(text):
    text = preprocess_text(text)  
    if not text:   
        return "Invalid input after preprocessing"

    inputs = tokenizer(text, padding="max_length", truncation=True, max_length=512, return_tensors="pt")
    
    with torch.no_grad():
        outputs = model(**inputs)

    logits = outputs.logits
    prediction = torch.argmax(logits, dim=1).item()
    
    return prediction , text

model_path = "bert_[80_20]" 
model = AutoModelForSequenceClassification.from_pretrained(model_path)
tokenizer = AutoTokenizer.from_pretrained(model_path)

model.eval()

app = Flask(__name__)

@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.get_json()
        text = data.get("text", "").strip()

        if not text:
            return jsonify({"error": "No text provided"}), 400

        prediction,text = predict_text(text)

        return jsonify({"prediction": prediction , "text": text})
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)

