# Stock Management Project

This repository contains a stock management system with a Flutter frontend, PHP backend, and a MySQL database.

## Structure

- `flutter_application_1/` — Flutter frontend application
- `backend/` — PHP backend API
- `stock_management.sql` — MySQL database dump

## Setup Instructions

1. **Import the Database**
   - Open phpMyAdmin.
   - Create a database named `stock_management`.
   - Import `stock_management.sql`.

2. **Backend Setup**
   - Place the `backend` folder in your web server directory (e.g., `htdocs` for XAMPP).
   - Update database credentials in `backend/db.php` if needed.

3. **Frontend Setup**
   - Open `flutter_application_1` in VS Code.
   - Run `flutter pub get`.
   - Start XAMPP and make sure both Apache and MySQL services are running.
   - Start the app with `flutter run`.

## Requirements

- XAMPP (or similar web server)
- PHP 8+
- MySQL/MariaDB
- Flutter SDK
