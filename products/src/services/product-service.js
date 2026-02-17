const { ProductRepository } = require("../database");
const { FormateData } = require("../utils");
const redisClient = require("../utils/redis-client");

class ProductService {
  constructor() {
    this.repository = new ProductRepository();
  }

  // ================= CREATE PRODUCT =================
  async CreateProduct(productInputs) {
    const product = await this.repository.CreateProduct(productInputs);
    return FormateData(product);
  }

  // ================= GET ALL PRODUCTS =================
  async GetProducts() {

      const cacheKey = "products:all";

      // 1️⃣ Check cache
      const cached = await redisClient.get(cacheKey);

      if (cached) {
          console.log("⚡ CACHE HIT");
          return FormateData(JSON.parse(cached));
      }

      console.log("🐢 CACHE MISS → DB");

      const products = await this.repository.Products();

      let categories = {};
      products.map(({ type }) => {
          categories[type] = type;
      });

      const response = {
          products,
          categories: Object.keys(categories),
      };

      // 2️⃣ Save to Redis (TTL 60 sec)
      await redisClient.set(cacheKey, JSON.stringify(response), {
          EX: 60,
      });

      return FormateData(response);
  }

  // ================= GET SINGLE PRODUCT =================
  async GetProductDescription(productId) {
    const product = await this.repository.FindById(productId);

    if (!product) throw new Error("Product not found");

    return FormateData(product);
  }

  // ================= GET BY CATEGORY =================
  async GetProductsByCategory(category) {
    const products = await this.repository.FindByCategory(category);
    return FormateData(products);
  }

  // ================= GET SELECTED PRODUCTS =================
  async GetSelectedProducts(selectedIds) {
    const products = await this.repository.FindSelectedProducts(selectedIds);
    return FormateData(products);
  }

  // ================= CREATE EVENT PAYLOAD =================
  async GetProductPayload(userId, { productId, qty }, event) {
    const product = await this.repository.FindById(productId);

    if (!product) {
      throw new Error("No product available");
    }

    const payload = {
      event,
      data: {
        userId,
        product,
        qty,
      },
    };

    return FormateData(payload);
  }
}

module.exports = ProductService;
