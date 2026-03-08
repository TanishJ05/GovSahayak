# GovSahayak - AI-powered Government Assistant

-Simplifying citizen-government interactions with instant, localized AI routing and tracking.-

Built for "Bluebit Hackathon 4.0"

----
#Problem Statement-
Navigating government services is often confusing, slow, and hindered by language barriers. Citizens struggle to find the right forms, track their applications, and get simple answers without waiting in long queues or dealing with complex web portals.

#Our Solution
**GovSahayak** is a multi-lingual, AI-driven chatbot application that acts as a unified interface for some government services. Instead of navigating complex menus, citizens can simply type their needs in their native language (English, Hindi, or Marathi). The AI instantly detects their intent, registers their request, and issues a tracking ID.

#Key Features
Autonomous Document Processing: Handles requests for Birth Certificates, Income Certificates, and Complaints entirely through chat.

Intelligent Document Discovery: Dynamically requests necessary documents (Aadhaar, PAN, Salary Slips) based on the specific service requested.

Multi-lingual Devanagari Support: Full support for Hindi and Marathi, allowing users to interact in their native script.

Explainable Decisions: Every AI response includes official regulatory citations (e.g., Registration of Births and Deaths Act, 1969) to ensure legal transparency.

Simulated Secure Authentication: A polished OTP-based login flow ensures a professional and secure user journey.

#Technical Stack
Frontend: Flutter (Web/Android/iOS)

Backend: Node.js & Express

AI Engine: Llama 3.1 via Groq SDK (Ultra-low latency)

Database: PostgreSQL (Relational persistence for application tracking)

#Installation & Setup
Database: Initialize PostgreSQL and create the gov_sahayak database.

Backend:

Navigate to /backend.

Create a .env file with your GROQ_API_KEY and DB credentials.

Run node server.js.

Frontend:

Navigate to /frontend.

Run flutter run -d chrome.

