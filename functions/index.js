const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const {setGlobalOptions} = require("firebase-functions");
setGlobalOptions({maxInstances: 10});

// Tambahkan fungsi deleteUser
exports.deleteUser = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "User belum login.",
    );
  }

  const uid = data.uid;

  try {
    // Hapus user dari Firebase Authentication
    await admin.auth().deleteUser(uid);

    // (Opsional) Hapus juga data Firestore user
    await admin.firestore().collection("users").doc(uid).delete();

    return {
      success: true,
      message: `User dengan UID ${uid} berhasil dihapus.`,
    };
  } catch (error) {
    throw new functions.https.HttpsError("unknown", error.message);
  }
});
