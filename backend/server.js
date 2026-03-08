// backend/server.js
const express = require("express");
const cors = require("cors");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 5001;

// Middleware
app.use(cors());
app.use(express.json());

// Import Routes
const chatRoutes = require("./routes/chatRoutes");

// Mount Routes
app.use("/api/chat", chatRoutes);

// Basic health check route
app.get("/", (req, res) => {
  res.send("Senate Bot API is running");
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});