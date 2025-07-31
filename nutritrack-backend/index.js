const express = require("express");
const { admin, db } = require("./firebase");
const twilio = require("twilio");
const cors = require("cors");
const {
  router: nutritionSummaryRoute,
  getNutritionSummary,
} = require("./routes/nutritionSummary");
require("dotenv").config();

const app = express();
const PORT = 3000;
app.use(express.json());

app.use(cors());
// Add to your Node.js app
app.use((req, res, next) => {
  console.log("Received headers:", req.headers);
  next();
});

// Enhanced authentication middleware
const authenticate = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    console.log("Missing auth header");
    return res.status(403).json({ error: "Unauthorized - No token provided" });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    console.log("Authenticated user:", decodedToken.uid);
    next();
  } catch (error) {
    console.error("Token verification failed:", error.message);
    return res.status(403).json({
      error: "Unauthorized",
      details: error.message,
    });
  }
};
app.use(express.json());
app.use("/", nutritionSummaryRoute);

// Initialize Twilio client
const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const twilioNumber = process.env.TWILIO_PHONE_NUMBER;

if (!accountSid || !authToken || !twilioNumber) {
  throw new Error("Twilio credentials not configured");
}

const client = twilio(accountSid, authToken);

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

app.put("/patients/:id", authenticate, async (req, res) => {
  const { id } = req.params;
  const { name, age, phone, trimester } = req.body;

  if (!name || !age || !phone || !trimester) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    await db
      .collection("patients")
      .doc(id)
      .update({
        name,
        age: parseInt(age),
        phone,
        trimester: parseInt(trimester),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    res.status(200).json({ message: "Patient updated successfully" });
  } catch (err) {
    console.error("❌ Error updating patient:", err.message);
    res.status(500).json({ error: "Failed to update patient" });
  }
});

// ✅ Delete a patient
app.delete("/patients/:id", authenticate, async (req, res) => {
  const { id } = req.params;

  try {
    await db.collection("patients").doc(id).delete();
    res.status(200).json({ message: "Patient deleted successfully" });
  } catch (err) {
    console.error("❌ Error deleting patient:", err.message);
    res.status(500).json({ error: "Failed to delete patient" });
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
      createdAt: doc.data().createdAt.toDate().toISOString(), // Convert Firestore timestamp to ISO string
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

// ✅ Fetch notifications for healthcare workers
app.get("/notifications", authenticate, async (req, res) => {
  const { healthcareWorkerId } = req.query;

  if (!healthcareWorkerId) {
    return res.status(400).json({ error: "Missing healthcareWorkerId" });
  }

  try {
    const snapshot = await db
      .collection("notifications")
      .where("healthcareWorkerId", "==", healthcareWorkerId)
      .orderBy("createdAt", "desc")
      .limit(50)
      .get();

    const notifications = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
      createdAt: doc.data().createdAt.toDate().toISOString(),
    }));

    res.status(200).json(notifications);
  } catch (err) {
    console.error("❌ Error fetching notifications:", err.message);
    res.status(500).json({ error: "Failed to fetch notifications" });
  }
});

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

app.get("/hcw-alerts", authenticate, async (req, res) => {
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
        // .where("triggeredAt", ">=", cutoffDate)
        .orderBy("triggeredAt", "desc");

      const batchSnapshot = await alertsQuery.get();
      alerts.push(
        ...batchSnapshot.docs.map((doc) => {
          const data = doc.data();
          return {
            id: doc.id,
            ...data,
            // Ensure consistent date format
            triggeredAt: data.triggeredAt.toDate().toISOString(), // Convert to ISO string
          };
        })
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

// ✅ Register a new appointment
app.post("/register-appointment", authenticate, async (req, res) => {
  console.log("Received appointment data:", req.body);
  const {
    patientName = "",
    patientId = "",
    appointmentDateTime = "",
    doctorName = "",
    condition = "",
    assignedTo = "",
  } = req.body;

  if (
    !patientName ||
    !patientId ||
    !appointmentDateTime ||
    !doctorName ||
    !condition ||
    !assignedTo
  ) {
    console.log("Missing fields:", {
      patientName: !!patientName,
      patientId: !!patientId,
      appointmentDateTime: !!appointmentDateTime,
      doctorName: !!doctorName,
      condition: !!condition,
      assignedTo: !!assignedTo,
    });
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    // Create the appointment document
    const appointmentRef = await db.collection("appointments").add({
      patientName,
      patientId,
      appointmentDateTime: new Date(appointmentDateTime),
      doctorName,
      condition,
      assignedTo,
      status: "scheduled", // can be: scheduled, completed, cancelled
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    if (patientId) {
      await db.collection("notifications").add({
        type: "appointment",
        title: "New Appointment Scheduled",
        message: `Appointment with ${doctorName} for ${patientName}`,
        healthcareWorkerId: assignedTo,
        patientId: patientId,
        appointmentId: appointmentRef.id,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // Optionally link to patient if we find a matching patient
    const patientQuery = await db
      .collection("patients")
      .where("name", "==", patientName)
      .limit(1)
      .get();

    if (!patientQuery.empty) {
      const patientId = patientQuery.docs[0].id;
      await db.collection("appointments").doc(appointmentRef.id).update({
        patientId: patientId,
      });
    }

    res.status(201).json({
      id: appointmentRef.id,
      message: "Appointment created successfully",
    });
  } catch (err) {
    console.error("❌ Error creating appointment:", err.message);
    res.status(500).json({ error: "Failed to create appointment" });
  }
});

// ✅ Get appointments for a healthcare worker
app.get("/appointments", authenticate, async (req, res) => {
  const { healthcareWorkerId } = req.query;

  if (!healthcareWorkerId) {
    return res.status(400).json({ error: "Missing healthcareWorkerId" });
  }

  try {
    const snapshot = await db
      .collection("appointments")
      .where("assignedTo", "==", healthcareWorkerId)
      .orderBy("appointmentDateTime")
      .get();

    const appointments = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
      appointmentDateTime: doc.data().appointmentDateTime.toISOString(),
      createdAt: doc.data().createdAt.toDate().toISOString(),
      updatedAt: doc.data().updatedAt.toDate().toISOString(),
    }));

    res.status(200).json(appointments);
  } catch (err) {
    console.error("❌ Error fetching appointments:", err.message);
    res.status(500).json({ error: "Failed to fetch appointments" });
  }
});

// ✅ Start the server
app.listen(PORT, () => {
  console.log(`📡 NutriTrack backend running at http://localhost:${PORT}`);
});
