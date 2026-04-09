# Domain Investigator 🕵️‍♂️🔍

A modern, fast, and secure Flutter application to perform WHOIS lookups directly from your mobile device.

## Overview

Originally built with Ionic/Angular, this project was entirely migrated to **Flutter** to leverage native performance and privacy. The app fetches WHOIS information using direct TCP socket connections (via the Dart `whois` library) on port 43. 

This means:
- **No external APIs:** Your queries don't pass through an intermediate API (like ip2whois). The app queries the domain registries directly.
- **Privacy First:** Data goes straight from your device to the WHOIS servers.
- **Offline Reliability:** No backend to maintain or pay for.

## Features ✨

- **Direct WHOIS Lookups**: Gets real-time, unfiltered WHOIS registration data.
- **Adaptive Theming**: Automatically adjusts to your system's Light or Dark mode preferences.
- **Manual Theme Override**: Includes a toggle button in the AppBar to switch between themes dynamically manually.
- **Modern UI/UX**: Includes micro-animations, premium dark-mode styling, and a clean, responsive layout.

## Getting Started 🚀

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.10.8 or higher)
- A working device emulator or physical smartphone connected.

### Installation

1. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd domain-investigator
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Usage 📱

1. Open the app on your device.
2. Type a domain into the search bar (e.g., `google.com`).
3. Hit the **Search** button or Enter on your keyboard.
4. Read the unparsed, direct WHOIS response presented in a clean typography view below.

## License

This project is open-source and available under the terms of the MIT License.
