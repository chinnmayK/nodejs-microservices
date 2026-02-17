const mongoose = require("mongoose");
const { MONGO_URI } = require("../config");

const databaseConnection = async () => {
  try {
    await mongoose.connect(MONGO_URI);
    console.log("✅ DB Connected");
  } catch (err) {
    console.log("❌ DB Connection Error");
    console.log(err);
    process.exit(1);
  }
};

module.exports = { databaseConnection };
