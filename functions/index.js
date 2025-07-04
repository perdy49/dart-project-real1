const express = require("express");
const admin = require("firebase-admin");
const app = express();
const cors = require("cors");

app.use(cors());
app.use(express.json());

admin.initializeApp({
  credential: admin.credential.cert(require("./serviceAccountKey.json")),
});

app.post("/delete-user", async (req, res) => {
  const {uid} = req.body;

  try {
    await admin.auth().deleteUser(uid);
    await admin.firestore().collection("users").doc(uid).delete();

    res.status(200).json({
      success: true,
      message: `User dengan UID ${uid} berhasil dihapus.`,
    });
  } catch (error) {
    res.status(500).json({success: false, error: error.message});
  }
});

app.listen(3000, () => {
  console.log("Server jalan di port 3000");
});
