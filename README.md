# Mobile Test Firebase

A Flutter project demonstrating Firebase integration, specifically focusing on Firestore CRUD operations and Cloud Functions with FCM notifications.

## Project Overview

This project was developed as part of a mobile development course, covering the following key areas:

- **Week 9**: Setting up Firebase, Firestore integration, and implementing simple CRUD operations for an `items` collection.
- **Week 10**: Implementing backend logic using Firebase Cloud Functions to trigger notifications on database changes (Create, Update, Delete) and handling them in the Flutter app.

## Features

### 1. Firestore CRUD (Week 9)
- **Create**: Add new items to the `items` collection.
- **Read**: Real-time synchronization of items list.
- **Update**: Modify existing items.
- **Delete**: Remove items from the database.

### 2. Notifications & Cloud Functions (Week 10)
The project uses Firebase Cloud Functions to watch for changes in the `items` collection and send FCM (Firebase Cloud Messaging) notifications to subscribed devices.

- **Triggers**:
    - `onItemCreated`: Triggered when a new document is added.
    - `onItemUpdated`: Triggered when a document is modified.
    - `onItemDeleted`: Triggered when a document is removed.
- **Notification Handling**:
    - Foreground notifications using `flutter_local_notifications`.
    - Background/Terminated state notification handling.

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Backend**: Firebase (Firestore, Cloud Functions)
- **Key Packages**:
    - `firebase_core`
    - `cloud_firestore`
    - `firebase_messaging`
    - `flutter_local_notifications`

## Setup & Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**:
   - Ensure you have the `google-services.json` file placed in `android/app/`.
   - For iOS, ensure `GoogleService-Info.plist` is in `ios/Runner/`.

4. **Run the app**:
   ```bash
   flutter run
   ```

## Permissions

The application requires the following permissions on Android:
- `android.permission.VIBRATE`
- `android.permission.POST_NOTIFICATIONS` (Android 13+)
- `android.permission.INTERNET`

## Cloud Functions

The backend logic is located in the `functions/` directory. It deploys triggers that listen to the `items/{itemId}` path.

```javascript
// Example Trigger
exports.onItemCreated = onDocumentCreated("items/{itemId}", async (event) => {
  // Logic to send notification
});
```