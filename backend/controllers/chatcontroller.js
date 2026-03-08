// backend/controllers/chatController.js
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

      if (result.rows.length === 0) {
        return res.json({ reply: "Application not found. Please verify your tracking ID." });
      }
      return res.json({ reply: `The current status of your application (#${appId}) is: ${result.rows[0].status.toUpperCase()}` });
    }

    // 2. Ironclad Language Rules
    const userLang = language || "Auto-detect";
    let langRule = "";
    
    if (userLang === "Auto-detect") {
        langRule = "the exact same language the user used in their message. If they typed English, reply in English.";
    } else {
        langRule = `STRICTLY ${userLang.toUpperCase()}. You must translate your final response into ${userLang}, no matter what language the user typed in.`;
    }

    // 3. AI Intent & Translation Generation
    const completion = await groq.chat.completions.create({
      model: "llama-3.1-8b-instant",
      response_format: { type: "json_object" }, 
      temperature: 0.1, 
      messages: [
        {
          role: "system",
          content: `You are a multi-lingual government AI assistant. 
Return a valid JSON object containing exactly two keys: "intent" and "localized_reply".

1. "intent": Must be EXACTLY ONE of: "greeting", "apply_birth_certificate", "check_application_status", "file_complaint", "general_query".

2. "localized_reply": You must convey the correct message from the list below, BUT IT MUST BE TRANSLATED INTO ${langRule}

   Messages to translate based on intent:
   - greeting: "Hello! I am the Senate Bot. I can help you apply for documents, file complaints, or check application statuses. How can I assist you today?"
   - apply_birth_certificate OR file_complaint: "Your request has been registered successfully."
   - check_application_status: "Please provide your tracking ID to check the status."
   - general_query: "Available services: Apply for Birth Certificate, File a Complaint, Check Application Status."

CRITICAL RULE: If the target language is Hindi, the "localized_reply" MUST be written entirely in Devanagari script. Do not output English if the target language is Hindi or Marathi.`
        },
        {
          role: "user",
          content: message
        }
      ]
    });

    const aiResponse = JSON.parse(completion.choices[0].message.content);
    const intent = aiResponse.intent;
    const finalReply = aiResponse.localized_reply;

    console.log("User requested lang:", userLang);
    console.log("Detected intent:", intent);
    console.log("AI Localized Reply:", finalReply);

    // 4. Database Routing & Final Output
    if (intent === "apply_birth_certificate") {
      const result = await db.query(
        "INSERT INTO applications (user_id, service_type) VALUES ($1,$2) RETURNING id",
        [user_id || 1, "birth_certificate"]
      );
      return res.json({
        reply: `${finalReply}\n\nTracking ID: ${result.rows[0].id}`,
        application_id: result.rows[0].id
      });
    }

    if (intent === "file_complaint") {
      const result = await db.query(
        "INSERT INTO applications (user_id, service_type) VALUES ($1,$2) RETURNING id",
        [user_id || 1, "complaint"]
      );
      return res.json({
        reply: `${finalReply}\n\nComplaint ID: ${result.rows[0].id}`,
        complaint_id: result.rows[0].id
      });
    }

    if (intent === "check_application_status") {
      const match = message.match(/\d+/);
      if (!match) {
        return res.json({ reply: finalReply });
      }

      const appId = match[0];
      const result = await db.query("SELECT status FROM applications WHERE id = $1", [appId]);
      
      if (result.rows.length === 0) {
        return res.json({ reply: "Application not found. / आवेदन नहीं मिला।" });
      }
      return res.json({ reply: `Status / स्थिति: ${result.rows[0].status.toUpperCase()}` });
    }

    return res.json({ reply: finalReply });

  } catch (error) {
    console.error("Groq/DB Error:", error);
    res.status(500).json({ reply: "I am experiencing high traffic right now. Please try again in a moment." });
  }
};