# QuickJobs

## Overview
QuickJobs is a job-finding platform designed to streamline the hiring process for both job seekers and recruiters. It provides an efficient way for candidates to find relevant job opportunities while allowing recruiters to post and manage job listings with ease.

## Features
### For Job Seekers:
- Search and apply for jobs based on location, industry, and experience level.
- Create and update your profile with resumes and skills.
- Get personalized job recommendations.
- Track application status and receive interview notifications.

### For Recruiters:
- Post job listings with detailed descriptions.
- Manage applications and shortlist candidates.
- Communicate directly with applicants.
- Filter candidates based on skills and experience.

## Tech Stack
- **Frontend:** React.js
- **Backend:** Node.js with Express.js
- **Database:** MongoDB
- **Authentication:** JWT-based authentication

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yash-borkar/QuickJobs
   ```
2. Navigate to the project directory:
   ```bash
   cd QuickJobs
   ```
3. Install dependencies for both frontend and backend:
   ```bash
   cd frontend && npm install
   cd ../backend && npm install
   ```

## Database Setup
1. Install MongoDB
2. Create a database
3. Set up environment variables in a `.env` file in the backend folder:
   ```env
   MONGO_URI=
   PORT=
  
   CLOUD_NAME=
   API_KEY=
   API_SECRET=

   SECRET_KEY=
   EXPIRES_IN=7d

   ```

## Running the Project
1. Start the backend server:
   ```bash
   cd backend
   npm start
   ```
2. Start the frontend server:
   ```bash
   cd frontend
   npm start
   ```

## Contribution
Contributions are welcome! Feel free to fork the repository and submit pull requests.
