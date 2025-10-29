Refactor summary and instructions
- main.dart updated to central routes and uses student welcome/login/register as primary entry.
- Added models/user.dart and services/{api_service.dart,auth_service.dart}.
- Updated student/login.dart to use AuthService and redirect by role.
- Added simple PHP backend in /backend with db.php, register.php, login.php.
- SQL schema file sport_borrow.sql exists at project root. Import it to create users table and other necessary tables.

PHP / MySQL quick steps:
1. Put the backend folder into your XAMPP htdocs (e.g. C:\xampp\htdocs\project_api)
2. Edit db.php DB credentials if necessary.
3. Import sport_borrow.sql using phpMyAdmin to create database 'sport_borrow' and tables.
4. Update ApiService.baseUrl in lib/services/api_service.dart to point to your machine (e.g. http://localhost/project_api or http://10.0.2.2/project_api for Android emulator).
