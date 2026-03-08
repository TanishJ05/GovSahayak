// backend/server.js
const express = require("express");
const cors = require("cors");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 5001;

// Import Middleware
const requestLogger = require("./middleware/logger");

// Global Middleware
app.use(cors());
app.use(express.json());
app.use(requestLogger); // <-- Added our new middleware here

// Import Routes
const chatRoutes = require("./routes/chatRoutes");
const applicationRoutes = require("./routes/applicationRoutes");

// Mount Routes
app.use("/api/chat", chatRoutes);
app.use("/api/applications", applicationRoutes);

// Basic health check route
app.get("/", (req, res) => {
  res.send("Senate Bot API is running");
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});