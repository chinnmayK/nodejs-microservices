const { databaseConnection } = require("./connection");
const ProductRepository = require("./repository/product-repository");

module.exports = {
  databaseConnection,
  ProductRepository,
};
