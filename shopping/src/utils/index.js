const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const amqplib = require("amqplib");

const {
  APP_SECRET,
  EXCHANGE_NAME,
  SHOPPING_SERVICE,
  MSG_QUEUE_URL,
} = require("../config");

// ------------------
// Utility
// ------------------

module.exports.GenerateSalt = async () => bcrypt.genSalt();

module.exports.GeneratePassword = async (password, salt) =>
  bcrypt.hash(password, salt);

module.exports.ValidatePassword = async (enteredPassword, savedPassword, salt) =>
  (await bcrypt.hash(enteredPassword, salt)) === savedPassword;

module.exports.GenerateSignature = async (payload) =>
  jwt.sign(payload, APP_SECRET, { expiresIn: "30d" });

module.exports.ValidateSignature = async (req) => {
  try {
    const signature = req.get("Authorization");
    const payload = jwt.verify(signature.split(" ")[1], APP_SECRET);
    req.user = payload;
    return true;
  } catch {
    return false;
  }
};

module.exports.FormateData = (data) => {
  if (data) return { data };
  throw new Error("Data Not found!");
};

// ------------------
// Message Broker
// ------------------

module.exports.CreateChannel = async () => {
  let retries = 5;

  while (retries) {
    try {
      const connection = await amqplib.connect(MSG_QUEUE_URL);
      const channel = await connection.createChannel();

      await channel.assertExchange(EXCHANGE_NAME, "direct", {
        durable: true,
      });

      console.log("✅ RabbitMQ Connected");
      return channel;
    } catch (err) {
      console.log("❌ RabbitMQ connection failed. Retrying...");
      retries -= 1;
      await new Promise((res) => setTimeout(res, 5000));
    }
  }

  throw new Error("RabbitMQ connection failed");
};

module.exports.PublishMessage = (channel, service, msg) => {
  channel.publish(EXCHANGE_NAME, service, Buffer.from(msg));
};
