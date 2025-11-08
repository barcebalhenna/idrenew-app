# IDRenew ♻️

> A smart mobile assistant for identifying and responsibly managing electronic waste.

## About The App

**IDRenew** is a mobile application designed to help users make informed, eco-friendly decisions about what to do with old or broken electronic parts.

It solves a common problem: most people don't know if their old parts are reusable, hazardous, or recyclable. Our app gives you a clear path:

1.  **Scan Your Part:** Use your phone's camera to instantly identify an electronic part.
2.  **Get Smart Guidance:** Our on-device TFLite model analyzes the part. If it's in good condition, we provide reuse and DIY ideas. If it's damaged (or has low scan confidence), we immediately guide you on how to properly dispose of it.
3.  **Find a Location:** A built-in map helps you find nearby e-waste centers or repair shops.
4.  **Track Your Impact:** All your scans are saved to a personal history page in Firebase, letting you see the e-waste you've diverted from landfills.

## About the Developers

This project was built by **HeMi Technologies**, a two-person team dedicated to creating innovative solutions for real-world environmental challenges.

## Team & Contributions

For this project, all development and design tasks were managed by our two members.

* **Henna Marie Barcebal - Lead Developer (Programming)**
    * Developed the full-stack Flutter application.
    * Trained and implemented the on-device TFLite model for image classification.
    * Engineered the backend, setting up Firebase and the Cloud Firestore database.
    * Programmed all core app logic, including the camera integration, map functionality, and history systems.

* **Mika Ysabelle Regalado - UX/UI Designer & Quality Assurance Lead**
    * Designed the complete user interface (UI) and user experience (UX) flow, from initial wireframes to final high-fidelity mockups.
    * Acted as the Quality Assurance (QA) Lead, creating test cases and conducting thorough testing to identify bugs, usability issues, and edge cases.
    * Managed project documentation and ensured the final app met all functional and design requirements.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
