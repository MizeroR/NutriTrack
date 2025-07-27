const express = require("express");
const { admin, db } = require("../firebase");
const { analyzeNutrition } = require("../utils/analyzer");

const router = express.Router();

// ✅ EXTRACTED LOGIC AS A REUSABLE FUNCTION
async function getNutritionSummary(patientId, days = 7) {
  const patientRef = db.collection("patients").doc(patientId);
  const patientDoc = await patientRef.get();

  if (!patientDoc.exists) {
    throw new Error("Patient not found");
  }

  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - days);

  const logsSnap = await db
    .collection("nutrition_logs")
    .where("linkedPatient", "==", patientRef)
    .where("receivedAt", ">=", admin.firestore.Timestamp.fromDate(cutoff))
    .get();

  const logs = logsSnap.docs.map((doc) => doc.data());
  const summary = analyzeNutrition(logs, days);

  return {
    patientId,
    daysAnalyzed: days,
    ...summary,
  };
}

// ✅ This still handles the GET request
router.get("/nutrition-summary/:patientId", async (req, res) => {
  const { patientId } = req.params;
  const days = parseInt(req.query.days) || 7;

  try {
    const summary = await getNutritionSummary(patientId, days);
    res.json(summary);
  } catch (err) {
    console.error("❌ Nutrition summary error:", err.message || err);
    res.status(500).json({ error: "Failed to compute nutrition summary" });
  }
});

// ✅ EXPORT BOTH ROUTER AND FUNCTION
module.exports = {
  router,
  getNutritionSummary,
};
