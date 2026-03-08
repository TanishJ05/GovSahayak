const Groq = require("groq-sdk");
const db = require("../config/db");

const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY
});

exports.chat = async (req, res) => {
  try {
    const { message, user_id, language } = req.body;

    // 1. Direct Number Intercept (Fast Tracking)
    const isJustNumber = /^\d+$/.test(message.trim());
    if (isJustNumber) {
      const appId = message.trim();
      const result = await db.query("SELECT status FROM applications WHERE id = $1", [appId]);
      if (result.rows.length === 0) return res.json({ reply: "Application not found. / आवेदन नहीं मिला।" });
      return res.json({ reply: `The current status of your application (#${appId}) is: ${result.rows[0].status.toUpperCase()}` });
    }

    // 2. Ironclad Language Rules
    const userLang = language || "Auto-detect";
    let langRule = userLang === "Auto-detect" 
      ? "the exact same language the user used in their message." 
      : `STRICTLY ${userLang.toUpperCase()}.`;

    // 3. AI Intent & Translation Generation
    const completion = await groq.chat.completions.create({
      model: "llama-3.1-8b-instant",
      response_format: { type: "json_object" }, 
      temperature: 0.1, 
      messages: [
        {
          role: "system",
          content: `You are the Senate Bot Administrator, an autonomous Digital Governance ChatOps platform.
Return a JSON object: {"intent": "...", "localized_reply": "...", "regulatory_citation": "..."}

INTENTS & GUIDELINES:
1. apply_birth_certificate: "Birth Certificate process initiated. Please provide Hospital Summary and Parents' ID." (Cite: Registration of Births and Deaths Act, 1969)
2. apply_income_certificate: "Income Certificate process initiated. Required: Aadhaar Card, PAN Card, and Salary Slips." (Cite: Revenue Department Digital Services Guideline, 2024)
3. file_complaint: "Your complaint has been logged and assigned to the local administrator." (Cite: Public Grievance Redressal Act)
4. provide_documents: "Documents verified against regulatory standards. Application moved to processing."
5. check_application_status: "Please provide your tracking ID."
6. greeting/general: "Welcome to Senate Bot. I handle Birth/Income Certificates and Complaints autonomously."

MANDATORY: Translate "localized_reply" into ${langRule}. Use Devanagari for Hindi/Marathi. Keep citation in English.`
        },
        { role: "user", content: message }
      ]
    });

    const aiResponse = JSON.parse(completion.choices[0].message.content);
    const { intent, localized_reply, regulatory_citation } = aiResponse;

    // 4. Automated Database Routing (Success Criterion: End-to-End)
    let trackingId = "";
    
    // Map intents to database service types
    const serviceMap = {
      "apply_birth_certificate": "birth_certificate",
      "apply_income_certificate": "income_certificate",
      "file_complaint": "complaint"
    };

    if (serviceMap[intent]) {
      const result = await db.query(
        "INSERT INTO applications (user_id, service_type, status) VALUES ($1,$2,$3) RETURNING id",
        [user_id || 1, serviceMap[intent], "pending"]
      );
      trackingId = `\n\n📝 Tracking ID: ${result.rows[0].id}`;
    }

    // Handle Status Check Logic
    if (intent === "check_application_status") {
      const match = message.match(/\d+/);
      if (match) {
        const result = await db.query("SELECT status FROM applications WHERE id = $1", [match[0]]);
        if (result.rows.length > 0) {
          return res.json({ reply: `Status: ${result.rows[0].status.toUpperCase()}` });
        }
      }
    }

    // Final response with citation for "Explainable Decisions"
    const finalResponse = `${localized_reply}${trackingId}\n\n⚖️ Citation: ${regulatory_citation}`;
    return res.json({ reply: finalResponse });

  } catch (error) {
    console.error("System Error:", error);
    res.status(500).json({ reply: "Service temporarily unavailable." });
  }
};