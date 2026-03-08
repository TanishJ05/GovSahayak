// backend/routes/applicationRoutes.js
const express = require("express");
const router = express.Router();
const db = require("../config/db");

// GET all applications for a specific user (For the Dashboard)
router.get("/user/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    const result = await db.query(
      "SELECT id, service_type, status, created_at FROM applications WHERE user_id = $1 ORDER BY created_at DESC",
      [userId]
    );
    res.json(result.rows);
  } catch (error) {
    console.error("Database Error fetching applications:", error);
    res.status(500).json({ error: "Failed to fetch applications" });
  }
});

// GET a specific application by ID (For the Tracking Bar)
router.get("/track/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await db.query(
      "SELECT id, service_type, status, created_at FROM applications WHERE id = $1",
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Application not found" });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error("Database Error tracking application:", error);
    res.status(500).json({ error: "Failed to track application" });
  }
});

module.exports = router;