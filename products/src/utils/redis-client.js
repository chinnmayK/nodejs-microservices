const { createClient } = require("redis");

const client = createClient({
  url: process.env.REDIS_URL,
});

client.on("error", (err) => console.log("Redis Client Error", err));

(async () => {
  await client.connect();
  console.log("✅ Redis Connected (Products)");
})();

module.exports = client;
