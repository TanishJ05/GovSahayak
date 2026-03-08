const { Pool } = require("pg");
require("dotenv").config();

const pool = new Pool({
  user: process.env.DB_USER || "tanish",
  host: process.env.DB_HOST || "localhost",
  database: process.env.DB_NAME || "gov_chatbot",
  password: process.env.DB_PASSWORD || "",
  port: process.env.DB_PORT || 5432,
});

// Test the database connection immediately
pool
  .connect()
  .then((client) => {
    console.log("✅ Connected to PostgreSQL successfully");
    client.release(); // release connection back to pool
  })
  .catch((err) => {
    console.error("❌ PostgreSQL connection error:", err.message);
  });

module.exports = pool;