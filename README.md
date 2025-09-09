# Stock Management Project

This repository contains a stock management system with a Flutter frontend, PHP backend, and a MySQL database.

## Structure

- `flutter_application_1/` — Flutter frontend application
- `backend/` — PHP backend API
- `stock_management.sql` — MySQL database dump

## Setup Instructions

Environment Setup
1.	Installation Requirements
Backend (PHP + DB)
•	XAMPP (Apache + PHP 8 + MySQL)
•	PHP extensions: mysqli, openssl, mbstring
•	PHPMailer
•	An STMP accopunt for OTP emails
Frontend
•	Flutter SDK
•	VS Code 
•	Flutter package: http

2.	Folder Location (Local)
•	Add the whole project into:
Windows: c:\xampp\htdocs\stockmanagement_project\

3.	Database setup
•	Open XAMPP Control panel
•	Click start for Apache and MySQL
Screenshot of the XAMPP Control panel:
 
•	Go to: http://localhost/phpmyadmin
•	Create a new database: stock_management
Screenshot of creating a new database:
 
•	Import file: stock_management.sql (imported from GitHub) into the new database
•	Click on the import option and select the file (stock_management.sql)
 
•	Click on the import option below
 

Project Setup in Flutter 
Option 1: Clone Using Git 
•	Run these Commands in CMD
cd C:\xampp\htdocs
git clone https://github.com/Niskarsh-Shrestha/Stock-management-project.git stock_management_project

•	If you’ve already cloned before and just need updates:
cd C:\xampp\htdocs\stock_management_project
git pull

			OR

Option 2: Download ZIP (Quick One-Time Use)
1.	Go to GitHub: Stock Management Project
2.	Click Code → Download ZIP.
3.	Extract to:
C:\xampp\htdocs\stock_management_project

After these setup:
•	Open VS Code and open the folder flutter_application_1 in VS Code: 
C:\xampp\htdocs\stock_management_project\flutter_application_1
•	Wait for some time as VS Code is installing the packages in the background.
•	At the top, click Run → Start Without Debugging (or press Ctrl + F5).
Screenshot:
 

•	The app will build and open on the selected emulator/connected device/window


## Requirements

- XAMPP (or similar web server)
- PHP 8+
- MySQL/MariaDB
- Flutter SDK
