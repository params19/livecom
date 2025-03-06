# Livecom

## Overview
LiveCom is a real-time messaging application that enables users to register and engage in seamless communication. It supports both individual and group chat functionalities, ensuring dynamic and interactive conversations. With a modern and responsive UI, LiveCom offers an intuitive user experience while integrating essential features such as message status updates, profile management, and notifications.

## Tech Stack
- **Flutter** - The core framework for building cross-platform mobile applications.  
- **Appwrite Cloud** - Cloud-based backend services for authentication and data management.  
- **Firebase Messaging** - Enables real-time push notifications for user interactions.
  
## Features
- **Chat Messaging**  
  - Send and receive text messages (Create, Read, Update, Delete)  
  - Send and receive image messages (Create, Read, Delete)  
- **User Presence & Interaction**  
  - Track user online status  
  - Mark messages as seen  
- **Profile Management**  
  - Modify profile picture (Create, Read, Update, Delete)  
- **Real-time Updates**  
  - UI updates dynamically with user interactions  
- **Group Chat Functionalities**  
  - Create and manage groups  
  - Perform CRUD operations on group messages  
  - Invite users to join groups  
  - Join public groups  
  - Track unread messages in group chats  

## Installation & Setup
1. **Clone the repository**  
   ```bash
   git clone https://github.com/your-repo/livecom.git
   cd livecom
   ```
2. **Install dependencies**  
   ```bash
   flutter pub get
   ```
3. **Set up environment variables**  
   - Create a `.env` file in the root directory.
   - Add necessary API keys and configurations.
4. **Run the app**  
   ```bash
   flutter run
   ```

## Usage
- Users can register using phone authentication.  
- Send and receive messages in real-time with an interactive UI.  
- Manage profile details, including profile picture updates.  
- Join or create groups for collaborative discussions.  
- Receive push notifications for new messages.  
- Keep track of unread messages and active conversations.  

## Dependencies
- **Cupertino Icons** - Provides high-quality iOS-style icons for Flutter applications.  
- **Appwrite** - Backend-as-a-service for authentication, database, and cloud functions.  
- **Country Code Picker** - Enables country code selection for phone authentication.  
- **File Picker** - Allows users to select and upload files from their device.  
- **Firebase Core** - Essential Firebase services integration for Flutter apps.  
- **Firebase Messaging** - Enables push notifications for new messages.  
- **Flutter Local Notifications** - Displays local notifications for user interactions.  
- **Provider** - State management solution for maintaining app-wide states.  
- **Shared Preferences** - Stores small amounts of persistent user data locally.  
- **Cached Network Image** - Efficiently loads and caches network images for performance.  
- **HTTP** - Handles network requests and API interactions.  
- **Flutter Dotenv** - Manages environment variables securely.  

## Topics Covered
- **Provider** - Manages application state efficiently with reactive updates.  
- **Shared Preferences** - Stores persistent key-value data locally on devices.  
- **Lifecycle Handlers** - Manages app state changes during its lifecycle.  
- **Push Notifications** - Sends real-time notifications to engage users.  
- **Appwrite Databases** - Stores and manages structured data seamlessly.  
- **Appwrite Authentication (Phone Login)** - Implements secure phone authentication.  
- **Appwrite Cloud Functions** - Executes server-side logic for automation.  
- **Appwrite Storage Bucket** - Stores and retrieves user-uploaded files efficiently.  

## Screenshots

### Auth
<div style="display: flex; gap: 20px;">
  <img width="298" alt="Screenshot 2025-03-06 at 6 12 50 PM" src="https://github.com/user-attachments/assets/dd0020f8-df61-4a3f-a902-d4dfdcc65915" />
  <img width="299" alt="Screenshot 2025-03-06 at 5 43 22 PM" src="https://github.com/user-attachments/assets/8d43edd8-dbdc-4d6e-a205-f6fb7fc98cda" />
</div>

### Homepage and Chats
<div style="display: flex; gap: 20px;">
  <img width="299" alt="Screenshot 2025-03-06 at 5 52 56 PM" src="https://github.com/user-attachments/assets/33c64db4-5dfe-4ead-a64d-64dd31cd93b1" />
  <img width="301" alt="Screenshot 2025-03-06 at 5 53 59 PM" src="https://github.com/user-attachments/assets/cb30eafc-3204-4a7a-980b-b2887d390641" />
</div>
<div style="display: flex; gap: 20px;">
  <img width="295" alt="Screenshot 2025-03-06 at 5 32 43 PM" src="https://github.com/user-attachments/assets/db8bf2a3-3e2b-4015-a3df-748aa398b4e1" />
  <img width="298" alt="Screenshot 2025-03-06 at 5 33 04 PM" src="https://github.com/user-attachments/assets/fff1a979-2973-457e-9758-864e07f85a22" />
</div>
<div style="display: flex; gap: 20px;">
  <img width="298" alt="Screenshot 2025-03-06 at 5 52 26 PM" src="https://github.com/user-attachments/assets/31de2905-8b74-49c9-83c8-020a945fdac9" />
</div>

### Groups
<div style="display: flex; gap: 20px;">
  <img width="298" alt="Screenshot 2025-03-06 at 6 07 01 PM" src="https://github.com/user-attachments/assets/0903b5b3-3df9-48ed-8cc3-5fc599ba1e2e" />
  <img width="300" alt="Screenshot 2025-03-06 at 5 54 29 PM" src="https://github.com/user-attachments/assets/979168f5-db87-4ee7-b9a2-6b059e3acc21" />
</div>
<div style="display: flex; gap: 20px;">
  <img width="301" alt="Screenshot 2025-03-06 at 5 54 55 PM" src="https://github.com/user-attachments/assets/2fecf4b8-8e4d-4b53-b2c1-a3ccde7deb9d" />
  <img width="297" alt="Screenshot 2025-03-06 at 6 15 13 PM" src="https://github.com/user-attachments/assets/9bdc7e88-7d74-429d-ae70-30081fbbd3b3" />
</div>

### Push Notifications
<div style="display: flex; gap: 20px;">
  <img width="298" alt="Screenshot 2025-03-06 at 6 40 34 PM" src="https://github.com/user-attachments/assets/0d347158-196b-4c54-9d21-e03e82af2f4b" />
  <img width="298" alt="Screenshot 2025-03-06 at 7 22 17 PM" src="https://github.com/user-attachments/assets/1aa6f197-cee8-4f1d-b25d-6cd032961e5a" />
</div>



## Contribution
Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a new branch: `git checkout -b feature-branch-name`
3. Commit your changes: `git commit -m "Add new feature"`
4. Push the branch: `git push origin feature-branch-name`
5. Submit a pull request.



