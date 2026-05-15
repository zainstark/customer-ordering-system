# Frontend — Customer Ordering System

A Flutter application for the customer ordering system. Supports web, desktop (macOS, Windows, Linux), and mobile (iOS, Android).

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Running the App](#running-the-app)
  - [Web](#web)
  - [macOS](#macos)
  - [Windows](#windows)
  - [Linux](#linux)
  - [iOS](#ios)
  - [Android](#android)
- [Project Structure](#project-structure)

---

## Prerequisites

Install Flutter by following the official guide for your platform:
**https://docs.flutter.dev/install**

Once installed, verify your setup:

```bash
flutter doctor
```

Fix any issues reported before proceeding.

Then, install project dependencies:

```bash
flutter pub get
```

---

## Getting Started

Clone the repository and navigate to the frontend directory:

```bash
cd frontend
flutter pub get
```

---

## Running the App

### Web

Run on the default browser:

```bash
flutter run -d chrome
```

Run as a web server (useful for Docker, remote access, or custom ports):

```bash
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
```

Then open `http://localhost:8080` in your browser. Replace `0.0.0.0` with a specific IP to restrict access, or keep it as `0.0.0.0` to accept connections on all interfaces.

To build for production:

```bash
flutter build web
```

The output will be in `build/web/`.

---

### macOS

> Requires macOS with Xcode installed.

```bash
flutter run -d macos
```

To build a release:

```bash
flutter build macos
```

---

### Windows

> Requires Windows with Visual Studio (with Desktop development with C++ workload) installed.

```bash
flutter run -d windows
```

To build a release:

```bash
flutter build windows
```

---

### Linux

> Requires Linux with CMake, GTK, and Ninja build tools installed.

Install dependencies on Ubuntu/Debian:

```bash
sudo apt-get install clang cmake ninja-build libgtk-3-dev
```

Then run:

```bash
flutter run -d linux
```

To build a release:

```bash
flutter build linux
```

---

### iOS

> Requires macOS with Xcode and an iOS Simulator or physical device.

List available simulators:

```bash
open -a Simulator
```

Run on a simulator:

```bash
flutter run -d ios
```

To build a release (requires Apple Developer account for device deployment):

```bash
flutter build ios
```

---

### Android

> Requires Android Studio with an emulator or a connected physical device.

List available devices:

```bash
flutter devices
```

Run on an emulator or connected device:

```bash
flutter run -d android
```

To build an APK:

```bash
flutter build apk
```

---

## Project Structure

```
lib/
├── Core/
│   ├── injector/       # Dependency injection
│   ├── network/        # Dio client, API endpoints, error handling
│   ├── router/         # App routing (go_router or auto_route)
│   ├── theme/          # Colors and theme config
│   └── utils/          # Dimensions and observers
└── features/
    ├── cart/           # Cart feature (data, domain, presentation)
    ├── menu/           # Menu feature (data, domain, presentation)
    ├── orders/         # Orders feature (data, domain, presentation)
    ├── shell/          # App shell scaffold
    └── widgets/        # Shared widgets (e.g. AppNetworkImage)
```

Each feature follows clean architecture with `data`, `domain`, and `presentation` layers. The `presentation` layer uses Cubit for state management.

---

## Backend

The backend runs on Django. See the backend README for setup and API documentation. By default it runs at:

```
http://127.0.0.1:8000
```

Make sure the backend is running before launching the Flutter app, as the app depends on the API for menu, cart, and orders data.