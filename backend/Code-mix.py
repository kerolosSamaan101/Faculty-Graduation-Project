from flask import Flask, request, jsonify
from deep_translator import GoogleTranslator
import re

app = Flask(__name__)


def translate_code_mixed_sentence(sentence):
    words = sentence.split()
    translated_words = []

    for word in words:
        if re.search('[\u0600-\u06FF]', word):  # تحقق من وجود حروف عربية
            translated = GoogleTranslator(source='ar', target='en').translate(word)
            translated_words.append(translated)
        else:
            translated_words.append(word)

    return ' '.join(translated_words)

# الراوت الرئيسي
@app.route('/translate', methods=['POST'])
def translate():
    data = request.get_json()
    input_text = data.get('text', '')
    
    if not input_text:
        return jsonify({'error': 'No text provided'}), 400

    translated_text = translate_code_mixed_sentence(input_text)
    return jsonify({'translated_text': translated_text})

# تشغيل السيرفر
if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=5002)