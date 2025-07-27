const axios = require("axios");

async function sendTestSMS() {
  const form = new URLSearchParams();
  form.append("username", "sandbox");
  form.append("to", "+250780000000");
  form.append("message", "🌸 Hello from NutriTrack MAMA (sandbox)");

  try {
    const response = await axios.post(
      "https://api.sandbox.africastalking.com/version1/messaging",
      form.toString(),
      {
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          apiKey:
            "atsk_acfdbb3e439ae55e076ec13b572c12261aa247640897bbbc79a1ea7edc4e279354ed1cf9",
        },
      }
    );
    console.log("✅ SMS sent successfully!");
    console.log(response.data);
  } catch (err) {
    console.error("❌ SMS failed:", err.response?.status, err.response?.data);
  }
}

sendTestSMS();
