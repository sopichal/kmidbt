---
title: MongoDB - NoSQL Database
author: KMI DBT Course
date: 2024
theme: default
---

# MongoDB - NoSQL Database

**KMI DBT Course**
Palacký University, Department of Computer Science

---

## Table of Contents

1. Motivation - Why MongoDB?
2. MongoDB Basics & Architecture
3. Setup & Docker Environment
4. CRUD Operations & Queries
5. Replication & Clustering
6. Sources & References

---

# 1. Motivation - Why MongoDB Was Created

---

## The Problem (Early 2000s)

Traditional relational databases faced challenges:

- **Web-scale applications** - Millions of users, massive data growth
- **Rigid schemas** - Changing table structures required migrations
- **Horizontal scaling** - Difficult to distribute data across servers
- **Complex relationships** - Not all data fits into normalized tables
- **Development speed** - Agile development needed flexible data models

---

## Real-World Examples

**E-commerce Product Catalog:**
- Different products have different attributes
- Electronics: CPU, RAM, screen size
- Clothing: Size, color, material
- Books: ISBN, author, publisher

**Social Media Posts:**
- Text, images, videos, comments
- Variable number of likes, tags
- Nested conversations

**IoT Sensor Data:**
- Different sensors, different measurements
- Time-series data at massive scale
- Need for real-time ingestion

---

## Why MongoDB?

MongoDB was created (2007-2009) to solve these problems:

**1. Flexible Schema**
- Store JSON-like documents
- No predefined structure required
- Easy to evolve data model

**2. Horizontal Scalability**
- Built-in sharding (data distribution)
- Replica sets for high availability
- Designed for cloud deployment

**3. Developer Productivity**
- Natural data representation (JSON)
- Rich query language
- No impedance mismatch

---

# 2. MongoDB Basics & Architecture

---

## What is MongoDB?

**MongoDB** = "Humongous" Database

- Document-oriented NoSQL database
- Stores data in flexible JSON-like documents (BSON)
- Open-source, cross-platform
- Written in C++

---

## SQL vs NoSQL Comparison

| Aspect | Relational (SQL) | MongoDB (NoSQL) |
|--------|------------------|-----------------|
| Data Model | Tables, rows, columns | Collections, documents |
| Schema | Fixed, predefined | Flexible, dynamic |
| Relationships | Foreign keys, JOINs | Embedding, references |
| Query Language | SQL | MongoDB Query Language |
| Scaling | Vertical (bigger server) | Horizontal (more servers) |
| Transactions | ACID (always) | ACID (since 4.0) |

---

## Document Model

**Relational approach (MySQL):**
```sql
-- Employees table
| id  | first_name | last_name | dept_id |
|-----|------------|-----------|---------|
| 100 | Steven     | King      | 90      |

-- Departments table
| id | name      | location_id |
|----|-----------|-------------|
| 90 | Executive | 1700        |
```

**Document approach (MongoDB):**
```json
{
  "_id": 100,
  "first_name": "Steven",
  "last_name": "King",
  "department": {
    "id": 90,
    "name": "Executive",
    "location_id": 1700
  }
}
```

---

## Key Concepts

**Database**
- Container for collections
- Like a database in SQL

**Collection**
- Group of documents
- Like a table in SQL
- No fixed schema

**Document**
- JSON-like record (BSON format)
- Like a row in SQL
- Can have different fields

**Field**
- Key-value pair in document
- Like a column in SQL

---

## Document Structure

```json
{
  "_id": ObjectId("507f1f77bcf86cd799439011"),
  "name": "Laptop Pro 15",
  "price": 1299.99,
  "category": "Electronics",
  "specifications": {
    "cpu": "Intel i7",
    "ram": "16GB",
    "storage": "512GB SSD"
  },
  "tags": ["laptop", "computer", "electronics"],
  "reviews": [
    {
      "user": "john_doe",
      "rating": 5,
      "comment": "Excellent laptop!"
    }
  ]
}
```

**Features:**
- `_id` - Unique identifier (automatically generated)
- Nested documents (specifications)
- Arrays (tags, reviews)
- Mixed data types

---

## Data Modeling Strategies

**1. Embedding (Denormalization)**
```json
{
  "_id": 2001,
  "customer": "Emma Johnson",
  "items": [
    { "product": "Mouse", "quantity": 1, "price": 29.99 },
    { "product": "Keyboard", "quantity": 1, "price": 89.99 }
  ]
}
```

**Pros:** Fast reads, single query
**Cons:** Data duplication, large documents

---

## Data Modeling Strategies (cont.)

**2. References (Normalization)**
```json
// Order document
{
  "_id": 2001,
  "customer_id": 1001,
  "items": [...]
}

// Customer document
{
  "_id": 1001,
  "name": "Emma Johnson",
  "email": "emma@email.com"
}
```

**Pros:** No duplication, smaller documents
**Cons:** Multiple queries needed (like JOINs)

---

## MongoDB Architecture

```
┌─────────────────────────────────────┐
│         Application Layer           │
│   (Your App, Mongo Express, etc)    │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│         MongoDB Server              │
│  ┌──────────────────────────────┐  │
│  │     Query Engine             │  │
│  ├──────────────────────────────┤  │
│  │     Storage Engine           │  │
│  │       (WiredTiger)           │  │
│  └──────────────────────────────┘  │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│      Data Files (BSON)              │
│      Indexes                        │
└─────────────────────────────────────┘
```

---

# 3. Setup & Docker Environment

---

## Course Environment Setup

We provide three Docker Compose configurations:

1. **compose.yml** - Simple single node
2. **compose-1-node-persistence.yml** - Single node with data persistence
3. **compose-3-node-cluster-persistence.yml** - 3-node replica set

All configurations include:
- MongoDB 7.0
- Mongo Express (web UI)
- Pre-loaded sample data
- Network: `kmidbt-net`

---

## Starting MongoDB

From the `mongodb/` directory:

```bash
# Simple setup (no persistence)
docker compose up -d

# With persistence (recommended)
docker compose -f compose-1-node-persistence.yml up -d

# 3-node cluster
docker compose -f compose-3-node-cluster-persistence.yml up -d
```

**Access:**
- MongoDB: `localhost:27017`
- Mongo Express: http://localhost:8081
- Credentials: `admin` / `reptiles`

---

## Mongo Express Web Interface

**Features:**
- Browse databases and collections
- Run queries visually
- View and edit documents
- Create indexes
- Execute JavaScript queries

---

## Sample Datasets

**HR Dataset** (mirrors MySQL course):
- `departments` - Company departments
- `employees` - Employee records
- `salaries` - Salary history

**E-commerce Dataset**:
- `products` - Product catalog with specifications
- `customers` - Customer data with addresses
- `orders` - Orders with embedded items
- `reviews` - Product reviews

**Automatically loaded on first start!**

---

## Connecting to MongoDB

**Via Mongo Express:**
1. Open http://localhost:8081
2. Select `kmidbt` database
3. Click on any collection

**Via mongosh (CLI):**
```bash
docker exec -it mongodb mongosh \
  -u admin -p reptiles \
  --authenticationDatabase admin

use kmidbt
show collections
```

---

# 4. CRUD Operations & Queries

---

## Basic Query Operations

**Find all documents:**
```javascript
db.employees.find()
```

**Find with filter:**
```javascript
db.employees.find({ department_id: 60 })
```

**Find one document:**
```javascript
db.employees.findOne({ _id: 100 })
```

**Find with comparison:**
```javascript
db.employees.find({ salary: { $gt: 10000 } })
```

---

## Query Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `$eq` | Equal | `{ age: { $eq: 25 } }` |
| `$ne` | Not equal | `{ status: { $ne: "inactive" } }` |
| `$gt` | Greater than | `{ salary: { $gt: 50000 } }` |
| `$gte` | Greater or equal | `{ age: { $gte: 18 } }` |
| `$lt` | Less than | `{ price: { $lt: 100 } }` |
| `$lte` | Less or equal | `{ stock: { $lte: 10 } }` |
| `$in` | In array | `{ status: { $in: ["active", "pending"] } }` |
| `$nin` | Not in array | `{ category: { $nin: ["archived"] } }` |

---

## Projection (Selecting Fields)

**Include specific fields:**
```javascript
db.employees.find(
  {},
  { first_name: 1, last_name: 1, salary: 1 }
)
```

**Exclude fields:**
```javascript
db.employees.find(
  {},
  { _id: 0, password: 0 }
)
```

**Result:**
```json
{ "first_name": "Steven", "last_name": "King", "salary": 24000 }
```

---

## Sorting and Limiting

**Sort (ascending/descending):**
```javascript
db.employees.find().sort({ salary: -1 })
```

**Limit results:**
```javascript
db.employees.find().limit(5)
```

**Combine sort and limit:**
```javascript
db.employees.find()
  .sort({ salary: -1 })
  .limit(10)
```

**Top 10 highest paid employees!**

---

## Querying Embedded Documents

**Product with specifications:**
```json
{
  "name": "Laptop",
  "specifications": {
    "cpu": "Intel i7",
    "ram": "16GB"
  }
}
```

**Query nested field:**
```javascript
db.products.find({ "specifications.cpu": "Intel i7" })
```

**Note the dot notation!**

---

## Querying Arrays

**Product with tags:**
```json
{
  "name": "Laptop",
  "tags": ["computer", "electronics", "portable"]
}
```

**Find by array element:**
```javascript
db.products.find({ tags: "electronics" })
```

**Find by multiple elements:**
```javascript
db.products.find({ tags: { $all: ["computer", "portable"] } })
```

---

## Insert Operations

**Insert one document:**
```javascript
db.employees.insertOne({
  _id: 300,
  first_name: "John",
  last_name: "Doe",
  salary: 7500,
  department_id: 60
})
```

**Insert many documents:**
```javascript
db.departments.insertMany([
  { _id: 120, department_name: "Data Science" },
  { _id: 130, department_name: "DevOps" }
])
```

---

## Update Operations

**Update one document:**
```javascript
db.employees.updateOne(
  { _id: 300 },
  { $set: { salary: 8000 } }
)
```

**Update many documents:**
```javascript
db.employees.updateMany(
  { job_id: "IT_PROG" },
  { $inc: { salary: 500 } }
)
```

**Update operators:**
- `$set` - Set field value
- `$inc` - Increment number
- `$push` - Add to array
- `$pull` - Remove from array

---

## Delete Operations

**Delete one document:**
```javascript
db.employees.deleteOne({ _id: 300 })
```

**Delete many documents:**
```javascript
db.employees.deleteMany({ department_id: 120 })
```

**⚠️ Be careful with deleteMany() - no undo!**

---

## Aggregation Pipeline

**Problem:** Find average salary by department

**SQL approach:**
```sql
SELECT department_id, AVG(salary)
FROM employees
GROUP BY department_id
```

**MongoDB approach:**
```javascript
db.employees.aggregate([
  {
    $group: {
      _id: "$department_id",
      avg_salary: { $avg: "$salary" }
    }
  }
])
```

---

## Aggregation Stages

```javascript
db.orders.aggregate([
  { $match: { status: "delivered" } },      // Filter
  { $unwind: "$items" },                     // Flatten array
  { $group: {                                // Group
      _id: "$customer_id",
      total: { $sum: "$items.price" }
    }
  },
  { $sort: { total: -1 } },                 // Sort
  { $limit: 10 }                            // Top 10
])
```

**Pipeline = Chain of operations**

---

## $lookup - "JOIN" in MongoDB

```javascript
db.employees.aggregate([
  {
    $lookup: {
      from: "departments",           // Join with
      localField: "department_id",   // Match field
      foreignField: "_id",           // To field
      as: "department"               // Output name
    }
  }
])
```

**Result:**
```json
{
  "_id": 100,
  "first_name": "Steven",
  "department": [
    { "_id": 90, "department_name": "Executive" }
  ]
}
```

---

## Example: Sales by Category

```javascript
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
      total_sales: { $sum: "$items.price" }
    }
  },
  { $sort: { total_sales: -1 } }
])
```

---

## Indexes

**Create index:**
```javascript
db.employees.createIndex({ email: 1 })
```

**Compound index:**
```javascript
db.employees.createIndex({
  department_id: 1,
  salary: -1
})
```

**Text index:**
```javascript
db.products.createIndex({
  name: "text",
  description: "text"
})
```

**Why?** Indexes dramatically speed up queries!

---

# 5. Replication & Clustering

---

## Why Replication?

**Problems with single server:**
- Hardware failure = data loss
- Maintenance = downtime
- Limited read capacity
- No disaster recovery

**Solution:** Replica Sets

---

## MongoDB Replica Set

```
┌─────────────────┐
│   Application   │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼────┐ ┌────────┐
│Primary│─│Second-│─│Second- │
│       │ │ary 1  │ │ary 2   │
└───────┘ └───────┘ └────────┘
  (Write)  (Read)    (Read)
```

**Key concepts:**
- **Primary** - Handles all writes
- **Secondary** - Replicates data from primary
- **Automatic failover** - If primary fails, secondary becomes primary

---

## Replica Set Configuration

Our `compose-3-node-cluster-persistence.yml`:

```yaml
services:
  mongodb1:  # Primary (elected automatically)
    ports: ["27017:27017"]

  mongodb2:  # Secondary
    ports: ["27018:27017"]

  mongodb3:  # Secondary
    ports: ["27019:27017"]
```

**Replica Set Name:** `rs0`

**Initialization:** Automatic via health check

---

## Starting the Replica Set

```bash
docker compose -f compose-3-node-cluster-persistence.yml up -d
```

**Wait ~30 seconds for initialization**

**Check status:**
```bash
docker exec -it mongodb1 mongosh \
  -u admin -p reptiles \
  --authenticationDatabase admin

rs.status()
```

---

## Replica Set Status

```javascript
rs.status()
```

**Key information:**
- Which node is PRIMARY
- Which nodes are SECONDARY
- Replication lag
- Last heartbeat

```json
{
  "members": [
    {
      "name": "mongodb1:27017",
      "stateStr": "PRIMARY"
    },
    {
      "name": "mongodb2:27017",
      "stateStr": "SECONDARY"
    }
  ]
}
```

---

## Reading from Secondaries

**By default:** All reads go to primary

**Enable secondary reads:**
```javascript
db.getMongo().setReadPref("secondaryPreferred")
```

**Read preferences:**
- `primary` - Only primary (default)
- `secondary` - Only secondaries
- `primaryPreferred` - Primary, fallback to secondary
- `secondaryPreferred` - Secondary, fallback to primary
- `nearest` - Lowest latency

---

## Write Concern

**Control write acknowledgment:**

```javascript
db.employees.insertOne(
  { name: "John" },
  { writeConcern: { w: "majority" } }
)
```

**Options:**
- `w: 1` - Primary acknowledged (fast)
- `w: "majority"` - Majority of nodes (safe)
- `w: 3` - All 3 nodes (slowest, safest)

**Trade-off:** Safety vs Performance

---

## Automatic Failover Demo

**1. Check primary:**
```bash
rs.status()
```

**2. Kill primary:**
```bash
docker stop mongodb1
```

**3. Wait 10-15 seconds**

**4. Check status again:**
```bash
# Connect to mongodb2
rs.status()
# mongodb2 or mongodb3 is now PRIMARY!
```

**5. Restart mongodb1:**
```bash
docker start mongodb1
# It rejoins as SECONDARY
```

---

## Sharding (Advanced)

For **very large** datasets:

```
┌─────────────┐
│   mongos    │  (Query Router)
└──────┬──────┘
       │
   ┌───┴───┬───────┐
   │       │       │
┌──▼──┐ ┌──▼──┐ ┌──▼──┐
│Shard│ │Shard│ │Shard│
│  1  │ │  2  │ │  3  │
└─────┘ └─────┘ └─────┘
```

**Sharding = Horizontal data partitioning**
- Data split across multiple servers
- Each shard is a replica set
- Automatic data distribution

**Not covered in this course** (replica sets are sufficient for learning)

---

## Backup Strategies

**1. mongodump (Logical backup):**
```bash
docker exec mongodb mongodump \
  --uri="mongodb://admin:reptiles@localhost:27017" \
  --out=/backup
```

**2. File system snapshots:**
- Stop MongoDB
- Copy data directory
- Restart MongoDB

**3. Replica set backup:**
- Take backup from secondary (no impact on primary)

---

## Best Practices

**Data Modeling:**
- Embed for 1-to-few relationships
- Reference for 1-to-many or many-to-many
- Avoid unbounded arrays

**Performance:**
- Create indexes on frequently queried fields
- Use projection to limit returned fields
- Limit result sets

**Reliability:**
- Use replica sets in production
- Enable authentication
- Regular backups

---

# 6. Sources & References

---

## Official Documentation

**MongoDB Manual:**
https://docs.mongodb.com/manual/

**MongoDB University (Free Courses):**
https://university.mongodb.com/

**MongoDB Compass (GUI Tool):**
https://www.mongodb.com/products/compass

---

## Course Materials

**Sample Datasets:**
- HR Dataset - Based on Oracle HR schema
- E-commerce Dataset - Custom created for this course

**Docker Images:**
- MongoDB: https://hub.docker.com/_/mongo
- Mongo Express: https://hub.docker.com/_/mongo-express

**Repository:**
All course materials available in the `mongodb/` directory

---

## Additional Resources

**Books:**
- "MongoDB: The Definitive Guide" by Shannon Bradshaw
- "Designing Data-Intensive Applications" by Martin Kleppmann

**Community:**
- MongoDB Community Forums: https://www.mongodb.com/community/forums/
- Stack Overflow: [mongodb] tag

**Tools:**
- Studio 3T (MongoDB GUI)
- NoSQLBooster (Query tool)

---

## Comparison Resources

**MongoDB vs MySQL:**
- When to use SQL vs NoSQL
- Migration guides
- Performance comparisons

**Related Technologies:**
- Mongoose (Node.js ODM)
- PyMongo (Python driver)
- Spring Data MongoDB (Java)

---

## Disclaimer

**Educational Use:**
- This environment uses simplified security settings
- Credentials are hardcoded for learning purposes
- **DO NOT use in production environments**

**Sample Data:**
- HR data derived from Oracle sample schema
- E-commerce data is fictional
- All personal information is randomly generated

**Docker Environment:**
- Designed for local development and learning
- Resource limits should be set for shared systems
- Data may be lost if volumes are not used

---

## References

**MongoDB History:**
- Founded: 2007 by Dwight Merriman, Eliot Horowitz, Kevin Ryan
- Initial release: 2009
- Name origin: "Humongous" database

**Standards:**
- BSON (Binary JSON): http://bsonspec.org/
- JSON: https://www.json.org/

**License:**
- MongoDB Server: Server Side Public License (SSPL)
- Sample data: Public domain / MIT

---

## Questions?

**Contact:**
KMI DBT Course
Palacký University
Department of Computer Science

**Resources:**
- Course repository: `kmidbt/mongodb/`
- README: `mongodb/README.md`
- Examples: `mongodb/examples/`

---

# Thank You!

**Next Steps:**
1. Start the Docker environment
2. Explore Mongo Express UI
3. Try the example queries
4. Compare with MySQL approach
5. Build your own queries!

**Happy Learning! 🚀**
