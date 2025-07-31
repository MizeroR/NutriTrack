// firebase.js
// const admin = require("firebase-admin");

// const serviceAccount = require("./serviceAccountKey.json");

// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount),
//   databaseURL: "https://nutritrack-aef4a-default-rtdb.firebaseio.com",
// });

// const db = admin.firestore();

// module.exports = { admin, db };

const admin = require('firebase-admin');

// Load from environment variable
const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: process.env.FIREBASE_DATABASE_URL
});

const db = admin.firestore();
module.exports = { admin, db }
