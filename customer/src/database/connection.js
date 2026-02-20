const mongoose = require("mongoose");
const { MONGO_URI } = require("../config");

const databaseConnection = async () => {
  try {
    await mongoose.connect(MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log("✅ DB Connected");
  } catch (err) {
    console.error("❌ DB Connection Error");
    console.error(err.message);
    process.exit(1);
  }
};

module.exports = { databaseConnection };