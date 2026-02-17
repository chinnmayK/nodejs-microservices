const mongoose = require("mongoose");
const { MONGODB_URI } = require("../config");

const databaseConnection = async () => {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log("✅ Customer DB Connected");
  } catch (err) {
    console.error("❌ Customer DB Connection Error");
    console.error(err);
    process.exit(1);
  }
};

module.exports = { databaseConnection };
