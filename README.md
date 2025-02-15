# 📖 eBook Reader App

A simple and performance-friendly eBook Reader built with Flutter and Firebase. Supports Google Sign-In, cloud storage for books, and a basic EPUB/PDF reader.

## 🚀 Features
- 📚 Firestore for storing book metadata
- ☁️ Supabase Storage for eBook files
- 📖 Basic EPUB/PDF Reader
- 🔄 Sync reading progress and bookmarks
- 📶 Offline support (upcoming)

## 🛠️ Tech Stack
- **Flutter** (UI framework)
- **Firestore** (Database for books and user progress)
- **Supabase Storage** (Cloud storage for eBooks)
- **Provider/Riverpod** (State management)
- **flutter_pdfview** (PDF rendering)
- **epub_viewer** (EPUB support)

## 📦 Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/your-username/ebook-reader-app.git
   cd ebook-reader-app
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Configure Firebase:
    - Create a Firebase & Supabase project
    - Set up Firestore and Supabase Storage
    - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) into the `android/app` and `ios/Runner` directories
4. Run the app:
   ```sh
   flutter run
   ```

## 🏗️ Project Structure
```
📂 lib/
│── 📂 models/               # Data models (User, Book, Progress)
│── 📂 services/             # Firebase Auth, Firestore, Storage
│── 📂 providers/            # State management (Provider/Riverpod)
│── 📂 screens/              # UI Screens
│    ├── settings_scree,dart # Settings for font/themes
│    ├── home_screen.dart    # Main library
│    ├── reader_screen.dart  # EPUB/PDF viewer
│── 📂 widgets/              # Reusable UI components
│── main.dart                # App entry point
```

## 📌 TODO
- [ ] Implement offline reading mode
- [ ] Improve UI with book covers and categories
- [ ] AI-powered book recommendations

## 🤝 Contributing
Feel free to submit issues and pull requests. Let's build a great eBook reader together!

## 📜 License
This project is licensed under the MIT License.

