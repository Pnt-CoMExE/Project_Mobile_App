Node.js backend for Project API

Instructions:
1. Copy this backend folder to your development environment.
2. Create a file named .env in this folder (you can copy .env.example) and set DB credentials.
3. Run `npm install` to install dependencies.
4. Run `node server.js` (or `npm run dev` if you have nodemon) to start server.
5. Import setup.sql into your MySQL server to create database and users table.
6. The API endpoints:
   POST /api/auth/register  -> { username, password, fullname }
   POST /api/auth/login     -> { username, password }
