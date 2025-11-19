// MongoDB E-commerce Database Query Examples
// Run these queries in Mongo Express or mongosh shell
// Connect to database: use kmidbt

// Load additional e-commerce data (orders and reviews) if not already loaded:
// mongoimport --uri "mongodb://admin:reptiles@localhost:27017/kmidbt?authSource=admin" --collection orders --file data/ecommerce/orders.json --jsonArray
// mongoimport --uri "mongodb://admin:reptiles@localhost:27017/kmidbt?authSource=admin" --collection reviews --file data/ecommerce/reviews.json --jsonArray

// =====================================
// BASIC QUERIES - PRODUCTS
// =====================================

// 1. Find all products
db.products.find();

// 2. Find electronics products
db.products.find({ category: "Electronics" });

// 3. Find products under $50
db.products.find({ price: { $lt: 50 } });

// 4. Find products with low stock (less than 50)
db.products.find({ stock: { $lt: 50 } });

// 5. Find products by tag
db.products.find({ tags: "laptop" });

// 6. Search products by name (case-insensitive)
db.products.find({ name: /laptop/i });


// =====================================
// WORKING WITH EMBEDDED DOCUMENTS
// =====================================

// 7. Find products with specific CPU specification
db.products.find({ "specifications.cpu": "Intel i7" });

// 8. Find wireless connectivity products
db.products.find({ "specifications.connectivity": /wireless/i });

// 9. Find products with noise cancelling feature
db.products.find({ "specifications.noise_cancelling": true });

// 10. Find customers in a specific city
db.customers.find({ "address.city": "New York" });

// 11. Find customers in California
db.customers.find({ "address.state": "CA" });


// =====================================
// ARRAY OPERATIONS
// =====================================

// 12. Find products with multiple specific tags
db.products.find({ tags: { $all: ["laptop", "computer"] } });

// 13. Find products with any of these tags
db.products.find({ tags: { $in: ["wireless", "bluetooth"] } });

// 14. Count products by category
db.products.aggregate([
  {
    $group: {
      _id: "$category",
      count: { $sum: 1 },
      avg_price: { $avg: "$price" }
    }
  },
  { $sort: { count: -1 } }
]);


// =====================================
// CUSTOMER QUERIES
// =====================================

// 15. Find VIP customers (loyalty points > 1000)
db.customers.find({ loyalty_points: { $gt: 1000 } });

// 16. Find customers registered in 2023
db.customers.find({
  registration_date: {
    $gte: "2023-01-01",
    $lt: "2024-01-01"
  }
});

// 17. Customers sorted by loyalty points
db.customers.find().sort({ loyalty_points: -1 });


// =====================================
// ORDER QUERIES (Embedded Arrays)
// =====================================

// 18. Find all orders for a specific customer
db.orders.find({ customer_id: 1001 });

// 19. Find orders with status "delivered"
db.orders.find({ status: "delivered" });

// 20. Find orders over $1000
db.orders.find({ total: { $gt: 1000 } });

// 21. Find orders containing a specific product
db.orders.find({ "items.product_id": 1 });

// 22. Find orders with more than 2 items
db.orders.find({ $expr: { $gt: [{ $size: "$items" }, 2] } });

// 23. Calculate total revenue
db.orders.aggregate([
  {
    $group: {
      _id: null,
      total_revenue: { $sum: "$total" },
      order_count: { $sum: 1 },
      avg_order_value: { $avg: "$total" }
    }
  }
]);


// =====================================
// RELATIONSHIPS - JOINING COLLECTIONS
// =====================================

// 24. Orders with customer information
db.orders.aggregate([
  {
    $lookup: {
      from: "customers",
      localField: "customer_id",
      foreignField: "_id",
      as: "customer"
    }
  },
  { $unwind: "$customer" },
  {
    $project: {
      order_id: "$_id",
      order_date: 1,
      total: 1,
      customer_name: {
        $concat: ["$customer.first_name", " ", "$customer.last_name"]
      },
      customer_email: "$customer.email"
    }
  }
]);

// 25. Find customer's total spending
db.orders.aggregate([
  {
    $group: {
      _id: "$customer_id",
      total_spent: { $sum: "$total" },
      order_count: { $sum: 1 }
    }
  },
  {
    $lookup: {
      from: "customers",
      localField: "_id",
      foreignField: "_id",
      as: "customer"
    }
  },
  { $unwind: "$customer" },
  {
    $project: {
      customer_name: {
        $concat: ["$customer.first_name", " ", "$customer.last_name"]
      },
      total_spent: { $round: ["$total_spent", 2] },
      order_count: 1,
      avg_order_value: { $round: [{ $divide: ["$total_spent", "$order_count"] }, 2] }
    }
  },
  { $sort: { total_spent: -1 } }
]);

// 26. Products with their reviews
db.products.aggregate([
  {
    $lookup: {
      from: "reviews",
      localField: "_id",
      foreignField: "product_id",
      as: "reviews"
    }
  },
  {
    $project: {
      name: 1,
      price: 1,
      review_count: { $size: "$reviews" },
      avg_rating: { $avg: "$reviews.rating" }
    }
  },
  { $sort: { review_count: -1 } }
]);

// 27. Top rated products (average rating >= 4.5)
db.reviews.aggregate([
  {
    $group: {
      _id: "$product_id",
      avg_rating: { $avg: "$rating" },
      review_count: { $sum: 1 },
      total_helpful: { $sum: "$helpful_count" }
    }
  },
  { $match: { avg_rating: { $gte: 4.5 } } },
  {
    $lookup: {
      from: "products",
      localField: "_id",
      foreignField: "_id",
      as: "product"
    }
  },
  { $unwind: "$product" },
  {
    $project: {
      product_name: "$product.name",
      category: "$product.category",
      price: "$product.price",
      avg_rating: { $round: ["$avg_rating", 2] },
      review_count: 1,
      total_helpful: 1
    }
  },
  { $sort: { avg_rating: -1, review_count: -1 } }
]);


// =====================================
// COMPLEX ANALYTICS QUERIES
// =====================================

// 28. Sales by product category
db.orders.aggregate([
  { $unwind: "$items" },
  {
    $lookup: {
      from: "products",
      localField: "items.product_id",
      foreignField: "_id",
      as: "product"
    }
  },
  { $unwind: "$product" },
  {
    $group: {
      _id: "$product.category",
      total_sales: { $sum: { $multiply: ["$items.quantity", "$items.price"] } },
      units_sold: { $sum: "$items.quantity" }
    }
  },
  { $sort: { total_sales: -1 } }
]);

// 29. Best selling products
db.orders.aggregate([
  { $unwind: "$items" },
  {
    $group: {
      _id: "$items.product_id",
      product_name: { $first: "$items.product_name" },
      total_quantity: { $sum: "$items.quantity" },
      total_revenue: { $sum: { $multiply: ["$items.quantity", "$items.price"] } }
    }
  },
  { $sort: { total_quantity: -1 } },
  { $limit: 10 }
]);

// 30. Monthly order trends
db.orders.aggregate([
  {
    $group: {
      _id: { $substr: ["$order_date", 0, 7] }, // Extract YYYY-MM
      order_count: { $sum: 1 },
      total_revenue: { $sum: "$total" },
      avg_order_value: { $avg: "$total" }
    }
  },
  { $sort: { _id: 1 } }
]);

// 31. Customer purchase frequency
db.orders.aggregate([
  {
    $group: {
      _id: "$customer_id",
      order_count: { $sum: 1 },
      first_order: { $min: "$order_date" },
      last_order: { $max: "$order_date" }
    }
  },
  {
    $lookup: {
      from: "customers",
      localField: "_id",
      foreignField: "_id",
      as: "customer"
    }
  },
  { $unwind: "$customer" },
  {
    $project: {
      customer_name: {
        $concat: ["$customer.first_name", " ", "$customer.last_name"]
      },
      order_count: 1,
      first_order: 1,
      last_order: 1,
      loyalty_points: "$customer.loyalty_points"
    }
  },
  { $sort: { order_count: -1 } }
]);


// =====================================
// INSERT OPERATIONS
// =====================================

// 32. Add a new product
db.products.insertOne({
  _id: 11,
  name: "Ergonomic Chair",
  category: "Furniture",
  price: 299.99,
  stock: 25,
  description: "Comfortable ergonomic office chair",
  specifications: {
    material: "Mesh",
    adjustable: true,
    lumbar_support: true
  },
  tags: ["chair", "office", "ergonomic"]
});

// 33. Add a new customer
db.customers.insertOne({
  _id: 1009,
  first_name: "Alice",
  last_name: "Cooper",
  email: "alice.cooper@email.com",
  phone: "+1-555-0109",
  address: {
    street: "555 Broadway",
    city: "Seattle",
    state: "WA",
    zip: "98101",
    country: "USA"
  },
  registration_date: "2024-03-28",
  loyalty_points: 0
});

// 34. Create a new order with embedded items
db.orders.insertOne({
  _id: 2009,
  customer_id: 1009,
  order_date: "2024-03-28",
  status: "processing",
  items: [
    {
      product_id: 11,
      product_name: "Ergonomic Chair",
      quantity: 1,
      price: 299.99
    }
  ],
  subtotal: 299.99,
  tax: 24.00,
  shipping: 19.99,
  total: 343.98,
  shipping_address: {
    street: "555 Broadway",
    city: "Seattle",
    state: "WA",
    zip: "98101",
    country: "USA"
  }
});


// =====================================
// UPDATE OPERATIONS
// =====================================

// 35. Update product price
db.products.updateOne(
  { _id: 11 },
  { $set: { price: 279.99 } }
);

// 36. Increase stock for multiple products
db.products.updateMany(
  { category: "Accessories" },
  { $inc: { stock: 20 } }
);

// 37. Add loyalty points to a customer
db.customers.updateOne(
  { _id: 1009 },
  { $inc: { loyalty_points: 50 } }
);

// 38. Update order status
db.orders.updateOne(
  { _id: 2009 },
  { $set: { status: "shipped" } }
);

// 39. Add a tag to products
db.products.updateMany(
  { category: "Electronics" },
  { $addToSet: { tags: "tech" } }
);


// =====================================
// REVIEW OPERATIONS
// =====================================

// 40. Add a product review
db.reviews.insertOne({
  _id: 3013,
  product_id: 11,
  customer_id: 1009,
  rating: 5,
  title: "Best chair I've ever owned",
  comment: "Extremely comfortable for long work sessions. Back pain is gone!",
  review_date: "2024-04-05",
  helpful_count: 0
});

// 41. Update helpful count for a review
db.reviews.updateOne(
  { _id: 3013 },
  { $inc: { helpful_count: 1 } }
);

// 42. Find all reviews by a customer
db.reviews.aggregate([
  { $match: { customer_id: 1001 } },
  {
    $lookup: {
      from: "products",
      localField: "product_id",
      foreignField: "_id",
      as: "product"
    }
  },
  { $unwind: "$product" },
  {
    $project: {
      product_name: "$product.name",
      rating: 1,
      title: 1,
      comment: 1,
      review_date: 1
    }
  }
]);


// =====================================
// DELETE OPERATIONS
// =====================================

// 43. Delete a product (be careful with relationships!)
// db.products.deleteOne({ _id: 11 });

// 44. Delete old reviews (older than 2023)
// db.reviews.deleteMany({ review_date: { $lt: "2023-01-01" } });


// =====================================
// INVENTORY MANAGEMENT
// =====================================

// 45. Products needing restock (stock < 50)
db.products.find(
  { stock: { $lt: 50 } },
  { name: 1, category: 1, stock: 1, price: 1 }
).sort({ stock: 1 });

// 46. Update stock after order (decrease inventory)
// When order 2009 is fulfilled, decrease stock:
db.products.updateOne(
  { _id: 11 },
  { $inc: { stock: -1 } }
);

// 47. Total inventory value by category
db.products.aggregate([
  {
    $group: {
      _id: "$category",
      total_units: { $sum: "$stock" },
      inventory_value: { $sum: { $multiply: ["$stock", "$price"] } }
    }
  },
  {
    $project: {
      category: "$_id",
      total_units: 1,
      inventory_value: { $round: ["$inventory_value", 2] }
    }
  },
  { $sort: { inventory_value: -1 } }
]);


// =====================================
// TEXT SEARCH (requires text index)
// =====================================

// 48. Create text index on product descriptions
db.products.createIndex({ name: "text", description: "text" });

// 49. Search products by text
db.products.find({ $text: { $search: "wireless" } });

// 50. Search with relevance score
db.products.find(
  { $text: { $search: "laptop computer" } },
  { score: { $meta: "textScore" } }
).sort({ score: { $meta: "textScore" } });
