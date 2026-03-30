# Flodo AI Task Management App

A premium, visually polished Task Management application built with Flutter, focusing on a high-performance reactive architecture and "Mobile Specialist" UI/UX.

## 🚀 Getting Started

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```
2. **Generate Hive models**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
3. **Run the app**:
   ```bash
   flutter run -d chrome
   ```
   *(Also compatible with iOS/Android Simulators)*

## 🛠 Technical Track & Decisions

### 📱 Track Chosen: Track B - The Mobile Specialist
This project was built to demonstrate a "senior-level" mastery of the Flutter ecosystem, prioritizing smooth animations, tactile feedback, and robust offline persistence.

- **State Management**: **Riverpod (2.x)** is used for its clean, provider-based architecture, ensuring efficient state propagation across the app without unnecessary rebuilds.
- **Persistence Layer**:
  - **Hive Database**: Replaced the initial Isar implementation to ensure **100% Cross-Platform compatibility** (Web, iOS, and Android). Hive is a high-performance NoSQL database that works perfectly on Chrome by using IndexedDB.
  - **Shared Preferences**: Used for the **Task Draft Persistence** requirement, ensuring typed text is saved even if the user accidentally swipes back or minimizes the app.

### 🌟 Stretch Goals Implemented
I have implemented **two out of the three** optional stretch goals:
1. **Stretch Goal 1: Debounced Autocomplete Search**: Real-time filtering with a 300ms debounce and **visual highlighting** of matching search terms within task titles.
2. **Stretch Goal 3: Persistent Drag-and-Drop**: Users can long-press and reorder tasks. This custom order is **persisted in Hive**, so the list remains in your preferred order across sessions.

### ✨ Premium UI/UX Features
- **Project Dashboard**: A header progress indicator showing "X of Y" tasks completed with an animated circular progress bar.
- **Hero Page Morphs**: Seamlessly morphing task cards into their edit screens for a hardware-accelerated, "app-like" feel.
- **Micro-interactions**: 
  - **Confetti Burst**: Celebrate task completion with an explosive confetti effect when a status changes to "Done."
  - **Haptic Feedback**: Tactile impacts on deletion, reordering, and saving.
  - **Shimmer Loading**: Professional "skeleton" placeholders during initial data loading.

## 🤖 AI Usage Report

- **Tool Used**: Antigravity (Powered by Google DeepMind).
- **Process**:
  - Leveraged AI to rapidly architect the Riverpod provider tree and the Hive model schema.
  - Used AI to implement the complex debouncing logic for Goal 1 and the order-shifting logic for Goal 3.
  - Assisted in designing the tailored dark-mode palette using HSL color tokens.
- **Helpful Prompts**: 
  - *"Examine the task dependency logic. If Task A blocks Task B, ensure Task B remains visually distinct until Task A's status is specifically 'done'."*
  - *"Implement a persistent reorderable list for Goal 3 that updates the internal 'sortOrder' field in the database."*
- **Challenges & Fixes**:
  - **Web Compatibility**: Initially used Isar 3.x, but encountered a JavaScript "Large Integer" error on Chrome when generating schema hashes. **Fix**: Migrated the entire persistence layer to **Hive**, which has superior web support.
  - **Typographic Consistency**: The default `RichText` widget didn't automatically pick up the `GoogleFonts.outfit` theme. **Fix**: I explicitly passed the `GoogleFonts` style to the `TextSpan` children for a 100% unified look.

---
*Created by Hunney Mandhotra for the Flodo AI Take-Home Assessment.*
