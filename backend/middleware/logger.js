// backend/middleware/logger.js

const requestLogger = (req, res, next) => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${req.method} API Request to: ${req.url}`);
  
  // Proceed to the next middleware or route handler
  next();
};

module.exports = requestLogger;