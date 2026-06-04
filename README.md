# Tracker Flutter

A fuel and maintenance tracker app built with Flutter, Firebase, Riverpod and GoRouter.

## 🚀 Présentation

Cette application permet de suivre :

- les véhicules
- les pleins de carburant
- les entretiens et réparations
- les dépenses mensuelles
- les catégories de maintenance

Elle utilise Firebase pour l'authentification et Firestore pour stocker les données utilisateur.

## 🧱 Architecture

- `lib/core/` : configuration des providers et du routeur
- `lib/domain/` : entités métier et interfaces de repository
- `lib/data/` : implémentations Firebase des repositories
- `lib/presentation/` : écrans et UI par fonctionnalité

## ⚙️ Fonctionnalités principales

- connexion / inscription Firebase
- gestion multi-véhicules
- ajout de pleins de carburant
- suivi des maintenances et catégories
- tableau de bord avec statistiques mensuelles

## 📦 Prérequis

- Flutter 3.x ou supérieur
- un environnement Flutter configuré (`flutter doctor`)
- un projet Firebase configuré pour Android/iOS/Web

## 🛠️ Installation

```bash
flutter pub get
```

### Lancer l'application

- Web :
  ```bash
  flutter run -d chrome
  ```

- Windows :
  ```bash
  flutter run -d windows
  ```

- Android :
  ```bash
  flutter run -d android
  ```

## 🔧 Configuration Firebase

Le projet utilise déjà les fichiers Firebase pour Android et Web, mais si tu veux
utiliser ton propre projet Firebase :

1. remplace `android/app/google-services.json`
2. remplace `ios/Runner/GoogleService-Info.plist`
3. mets à jour `lib/firebase_options.dart`

### Règles Firestore recommandées

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 🧪 Vérifications utiles

- `flutter analyze`
- `flutter test` (si tu ajoutes des tests)

## 📁 Fichiers importants

- `lib/main.dart`
- `lib/core/router/app_router.dart`
- `lib/core/providers.dart`
- `lib/presentation/dashboard/dashboard_page.dart`

## ✅ Notes

- Le build Windows peut nécessiter une configuration CMake à jour.
- Web est la cible la plus rapide pour les tests en local.

---

Développé pour suivre les dépenses auto et améliorer la visibilité du budget véhicule.

