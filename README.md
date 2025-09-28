# FCIS F1 Project  

## Overview  
FCIS F1 is a mobile application developed in **Flutter** that helps FCIS students connect with graduates and gain guidance for academic and career growth.  
The app integrates machine learning models to classify discussions and filter harmful content, ensuring a constructive and supportive environment.  

## Core Features  
- **Forum Discussion Categorization**  
  - Uses a **BERT-based model** to classify posts into topic fields:  
    - Flutter  
    - Web Frontend  
    - Web Backend  
    - Game Development  
    - ML & DL  

- **Content Moderation**  
  - Uses a **Transformer model** to detect hate speech in user posts and comments.  
  - Keeps discussions safe and professional.  

- **Student–Graduate Connection**  
  - Provides a dedicated space for communication, mentorship, and career advice. 

- **Graduaion Tean**
    - Kerolos Samaan : github Username => kerolosSamaan101
    - Mustafa Hussein : github Username => Mustafa101hussein
    - Waleed Mohamed : github Username => WaleedMGabr
    - Menna Ibrahim
    - Hajer Essam
    - Abdalla Mohsen


## Tech Stack  
- **Frontend:** Flutter (Dart)  
- **Machine Learning Models:**  
  - Transformer (Hate Speech Detection)  
  - BERT (Topic Field Prediction)  

## Getting Started  

### Prerequisites  
- [Flutter SDK](https://docs.flutter.dev/get-started/install)  
- Android Studio or VS Code with Flutter/Dart extensions installed  

### Run the App  
```bash
# Clone the repository
git clone <your-repo-link>

# Navigate into the project directory
cd fcis_f1_project

# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run
