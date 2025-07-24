const admin = require("firebase-admin");
const db = admin.firestore();
var serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://nutritrack-aef4a-default-rtdb.firebaseio.com",
});
// [PASTE THE MIGRATION SCRIPT HERE]
// Run in Firebase Admin console or as a Cloud Function

async function migrateAlerts() {
  // Get all patients first
  const patientsSnapshot = await db.collection("patients").get();
  const patientMap = new Map();

  patientsSnapshot.forEach((doc) => {
    patientMap.set(doc.id, doc.data().assignedTo);
  });

  // Process alerts in batches
  const alertsSnapshot = await db.collection("alerts_sent").get();
  const batchSize = 500;
  let processed = 0;

  while (processed < alertsSnapshot.size) {
    const batch = db.batch();
    const alertsBatch = alertsSnapshot.docs.slice(
      processed,
      processed + batchSize
    );

    alertsBatch.forEach((doc) => {
      const hcwId = patientMap.get(doc.data().patientId);
      if (hcwId) {
        batch.update(doc.ref, { healthcareWorkerId: hcwId });
      }
    });

    await batch.commit();
    processed += batchSize;
    console.log(`Processed ${processed} alerts`);
  }

  console.log("Migration completed successfully");
}

migrateAlerts().catch(console.error);

migrateAlerts().catch(console.error);
