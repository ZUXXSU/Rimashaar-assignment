# 🚀 iOS Developer Task Submission: User Registration & OTP Verification

## Project Status
**✅ Task Successfully Completed and Functional**

This repository contains the completed iOS application modules for the User Registration and OTP Verification task, as outlined in the requirements provided on November 18th, 2025.

---

## Task Objective

Develop two core modules for an iOS application: a user registration module and an OTP verification module, adhering strictly to the **UIKit** framework for UI implementation.

## 🛠️ Technology Stack

* **Platform:** iOS
* **Language:** Swift
* **Framework:** **UIKit** (Programmatic UI)
* **Networking:** `URLSession` (or preferred networking library)
* **Architecture:** MVC or MVVM (based on implementation choice)

---

## ✨ Features Implemented

### 1. Register Module

* **Interface:** Created a clean and responsive user registration interface (as per shared design/screenshot).
* **Validation:** Implemented robust client-side form validation for:
    * Ensuring all mandatory fields are filled.
    * Correct email format validation.
    * Correct phone number format and country code validation.
* **API Integration:** Successfully integrated with the provided registration endpoint:
    * `POST` request to `https://admin-cp.rimashaar.com/api/v1/register-new?lang=en`
* **Error Handling:** Implemented handling for various server responses (e.g., existing user errors, validation failures) and provided clear user feedback.
* **Success Logic:** On successful registration, the response is parsed to retrieve the necessary data (like `user_id` and the initial code/OTP) before seamlessly navigating to the OTP Verification screen.

### 2. Verify OTP Module

* **Interface:** Created a dedicated OTP verification screen (as per shared design/screenshot).
* **Input Handling:** Implemented efficient input handling for the OTP fields.
* **API Integration:** Successfully integrated with the verification endpoint:
    * `POST` request to `https://admin-cp.rimashaar.com/api/v1/verify-code?lang=en`
    * The request payload correctly includes the received `user_id` and the entered `otp`.
* **Navigation:** Handled server responses:
    * On successful OTP verification, the user is navigated to the main/welcome screen of the application.
    * On failure, appropriate error messages are displayed to the user.

---

## 🏗️ Code Structure & Best Practices

* **100% UIKit:** All views are built using **UIKit**, utilizing **layout anchors (or constraints)** for a fully programmatic and adaptable user interface. No Storyboards or XIBs were required.
* **Modularity:** The networking logic is separated from the UI/Controller logic for clean, maintainable code.
* **Error Handling:** Utilized `do-catch` blocks and specific network error enumeration to ensure comprehensive error handling.
* **Comments & Documentation:** Key classes, functions, and complex logic are documented using Swift documentation comments.

---

## 🏃 Getting Started

To run this project locally:

1.  **Clone the repository:**
    ```bash
    git clone [Your Repository URL]
    ```
2.  **Open in Xcode:**
    Navigate to the project directory and open the `.xcodeproj` file.
3.  **Build and Run:**
    Select an iOS Simulator or a physical device and press **Cmd+R**.

---

## 📧 Contact Information

**Submitted By:** [Your Name]
**Date of Submission:** November 18, 2025

***
*Thank you for the opportunity to complete this task.*
