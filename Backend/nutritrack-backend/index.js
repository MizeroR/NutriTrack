const express = require("express");
const { admin, db } = require("./firebase");
const twilio = require("twilio");
const cors = require("cors");
const {
  router: nutritionSummaryRoute,
  getNutritionSummary,
} = require("./routes/nutritionSummary");

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());
app.use("/", nutritionSummaryRoute);

// ✅ Register a patient and send onboarding SMS
app.post("/send-sms", async (req, res) => {
  const { name, phone, language, trimester, assignedTo } = req.body;

  if (!name || !phone || !language || !trimester) {
    return res.status(400).send("Missing required fields");
  }

  const messages = {
    english:
      "Welcome to NutriTrack MAMA 🌸 Log meals like: BEANS 1C or MILK 1C.",
    swahili:
      "Karibu NutriTrack MAMA 🌸 Tafadhali tuma chakula kama: MAHARAGE 1C",
    kinyarwanda:
      "Murakaza neza kuri NutriTrack MAMA 🌸 Andika: IBISHYIMO 1C buri munsi.",
  };

  const message = messages[language] || messages.english;

  try {
    const sms = await client.messages.create({
      body: message,
      from: twilioNumber,
      to: phone,
    });

    await db.collection("sms_logs").add({
      phone,
      message,
      messageSid: sms.sid,
      status: sms.status,
      type: "onboarding",
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    await db.collection("patients").add({
      name,
      phone: phone.trim(),
      language,
      trimester,
      assignedTo: assignedTo || "unassigned",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`✅ SMS sent to ${phone} (SID: ${sms.sid})`);
    res.status(200).send("SMS sent and logged.");
  } catch (err) {
    console.error("❌ Error sending SMS:", err.message);
    res.status(500).send("Failed to send SMS");
  }
});

// ✅ Get patients assigned to health worker
app.get("/patients", async (req, res) => {
  const assignedTo = req.query.assignedTo;
  if (!assignedTo) return res.status(400).json({ error: "Missing assignedTo" });

  try {
    const snapshot = await db
      .collection("patients")
      .where("assignedTo", "==", assignedTo)
      .get();

    const patients = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.status(200).json(patients);
  } catch (err) {
    console.error("❌ Error fetching patients:", err.message || err);
    res.status(500).json({ error: "Failed to fetch patients" });
  }
});

// ✅ Handle incoming food log SMS from patients
app.post(
  "/incoming-sms",
  express.urlencoded({ extended: false }),
  async (req, res) => {
    console.log("📩 Incoming SMS webhook hit!");

    const { From, Body } = req.body;
    if (!From || !Body) {
      console.log("❌ Missing data in webhook");
      return res.status(400).send("Missing data from Twilio.");
    }

    const match = Body.trim().match(/^([A-Z]+)\s+([0-9.]+[a-zA-Z]*)$/);
    const parsedFood = match ? match[1].toLowerCase() : null;
    const quantity = match ? match[2] : null;

    let patientRef = null;
    const patientSnap = await db
      .collection("patients")
      .where("phone", "==", From)
      .limit(1)
      .get();

    if (!patientSnap.empty) {
      patientRef = patientSnap.docs[0].ref;
      console.log("🔗 Linked to patient:", patientRef.id);
    } else {
      console.warn("⚠️ No matching patient found for", From);
    }

    await db.collection("nutrition_logs").add({
      from: From,
      body: Body,
      parsedFood,
      quantity,
      receivedAt: admin.firestore.FieldValue.serverTimestamp(),
      phone: From,
      linkedPatient: patientRef,
    });

    const confirmationMessage =
      parsedFood && quantity
        ? `✅ ${parsedFood.toUpperCase()} (${quantity}) logged. Thank you!`
        : `⚠️ Sorry, we couldn't understand your message. Try: BEANS 1C`;

    await client.messages.create({
      body: confirmationMessage,
      from: twilioNumber,
      to: From,
    });

    res.set("Content-Type", "text/xml");
    res.send(`<Response></Response>`);
  }
);

app.post("/send-alert", async (req, res) => {
  const { patientId } = req.body;
  if (!patientId) return res.status(400).json({ error: "Missing patientId" });

  try {
    const patientRef = db.collection("patients").doc(patientId);
    const patientDoc = await patientRef.get();
    if (!patientDoc.exists)
      return res.status(404).json({ error: "Patient not found" });

    const patient = patientDoc.data();
    const summary = await getNutritionSummary(patientId, 7);
    const { flags, recommendations } = summary;

    if (!flags || flags.length === 0) {
      return res
        .status(200)
        .json({ message: "No critical flags, no SMS sent." });
    }

    const message = `⚠️ Nutrition Alert:\n${flags[0]}\nAdvice: ${recommendations[0]}`;

    await client.messages.create({
      to: patient.phone,
      from: twilioNumber,
      body: message,
    });

    await db.collection("alerts_sent").add({
      patientId,
      phone: patient.phone,
      message,
      triggeredAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(200).json({ message: "Alert sent successfully." });
  } catch (err) {
    console.error("❌ Error sending alert:", err.message || err);
    res.status(500).json({ error: "Failed to send alert" });
  }
});

app.get("/hcw-alerts", async (req, res) => {
  const { healthcareWorkerId, days = 7 } = req.query;

  // Validate input
  if (!healthcareWorkerId) {
    return res.status(400).json({ error: "Missing healthcareWorkerId" });
  }

  try {
    // Step 1: Get all patient IDs assigned to this healthcare worker
    const patientsQuery = db
      .collection("patients")
      .where("assignedTo", "==", healthcareWorkerId)
      .select("id");

    const patientsSnapshot = await patientsQuery.get();

    if (patientsSnapshot.empty) {
      return res.status(200).json([]);
    }

    const patientIds = patientsSnapshot.docs.map((doc) => doc.id);

    // Step 2: Calculate date cutoff
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - parseInt(days));

    // Step 3: Batch queries if more than 10 patients
    const alerts = [];
    const batchSize = 10; // Firestore 'in' clause limit

    for (let i = 0; i < patientIds.length; i += batchSize) {
      const batch = patientIds.slice(i, i + batchSize);

      let alertsQuery = db
        .collection("alerts_sent")
        .where("patientId", "in", batch)
        .where("triggeredAt", ">=", cutoffDate)
        .orderBy("triggeredAt", "desc");

      const batchSnapshot = await alertsQuery.get();
      alerts.push(
        ...batchSnapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
          triggeredAt: doc.data().triggeredAt.toISOString(),
        }))
      );
    }

    // Step 4: Sort all alerts by date (newest first)
    alerts.sort((a, b) => b.triggeredAt - a.triggeredAt);

    res.status(200).json(alerts);
  } catch (err) {
    console.error("Error fetching alerts:", err);
    res.status(500).json({
      error: "Failed to fetch alerts",
      details: err.message,
    });
  }
});

// Add to index.js
app.get("/sms-logs", async (req, res) => {
  try {
    const snapshot = await db
      .collection("sms_logs")
      .orderBy("timestamp", "desc")
      .limit(50)
      .get();

    const logs = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
      // Convert Firestore timestamp to JS Date
      timestamp: doc.data().timestamp.toDate(),
    }));

    res.status(200).json(logs);
  } catch (err) {
    console.error("❌ Error fetching SMS logs:", err.message);
    res.status(500).json({ error: "Failed to fetch SMS logs" });
  }
});

// ✅ Start the server
app.listen(PORT, () => {
  console.log(`📡 NutriTrack backend running at http://localhost:${PORT}`);
});
