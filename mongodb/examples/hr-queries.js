// MongoDB HR Database Query Examples
// Run these queries in Mongo Express or mongosh shell
// Connect to database: use kmidbt

// =====================================
// BASIC QUERIES (Read Operations)
// =====================================

// 1. Find all employees
db.employees.find();

// 2. Find all employees (pretty format)
db.employees.find().pretty();

// 3. Find a specific employee by ID
db.employees.findOne({ _id: 100 });

// 4. Find employees in the IT department
db.employees.find({ department_id: 60 });

// 5. Find employees with salary greater than 10000
db.employees.find({ salary: { $gt: 10000 } });

// 6. Find employees hired after 2005
db.employees.find({ hire_date: { $gt: "2005-01-01" } });

// 7. Find employees with commission
db.employees.find({ commission_pct: { $ne: null } });

// 8. Find IT programmers
db.employees.find({ job_id: "IT_PROG" });


// =====================================
// PROJECTION (Selecting Specific Fields)
// =====================================

// 9. Get only names and salaries
db.employees.find({}, { first_name: 1, last_name: 1, salary: 1 });

// 10. Get names and salaries, exclude _id
db.employees.find({}, { _id: 0, first_name: 1, last_name: 1, salary: 1 });


// =====================================
// SORTING AND LIMITING
// =====================================

// 11. Top 5 highest paid employees
db.employees.find().sort({ salary: -1 }).limit(5);

// 12. Employees sorted by hire date (oldest first)
db.employees.find().sort({ hire_date: 1 });

// 13. Employees sorted by department, then by salary
db.employees.find().sort({ department_id: 1, salary: -1 });


// =====================================
// RELATIONSHIPS (Using References)
// =====================================

// 14. Find employee with their department name (manual lookup)
// First, find the employee
var emp = db.employees.findOne({ _id: 103 });
// Then, find their department
var dept = db.departments.findOne({ _id: emp.department_id });
print("Employee: " + emp.first_name + " " + emp.last_name);
print("Department: " + dept.department_name);

// 15. Find all employees in a specific department (using aggregation)
db.employees.aggregate([
  {
    $lookup: {
      from: "departments",
      localField: "department_id",
      foreignField: "_id",
      as: "department"
    }
  },
  { $unwind: "$department" },
  { $match: { "department.department_name": "IT" } },
  {
    $project: {
      first_name: 1,
      last_name: 1,
      salary: 1,
      department_name: "$department.department_name"
    }
  }
]);

// 16. Find employees with their salary history
db.employees.aggregate([
  {
    $lookup: {
      from: "salaries",
      localField: "_id",
      foreignField: "employee_id",
      as: "salary_history"
    }
  },
  {
    $project: {
      first_name: 1,
      last_name: 1,
      current_salary: "$salary",
      salary_history: 1
    }
  }
]);


// =====================================
// AGGREGATION PIPELINE
// =====================================

// 17. Average salary by department
db.employees.aggregate([
  {
    $group: {
      _id: "$department_id",
      avg_salary: { $avg: "$salary" },
      count: { $sum: 1 }
    }
  },
  { $sort: { avg_salary: -1 } }
]);

// 18. Employee count by job type
db.employees.aggregate([
  {
    $group: {
      _id: "$job_id",
      count: { $sum: 1 }
    }
  },
  { $sort: { count: -1 } }
]);

// 19. Total salary expenses by department with department names
db.employees.aggregate([
  {
    $group: {
      _id: "$department_id",
      total_salary: { $sum: "$salary" },
      avg_salary: { $avg: "$salary" },
      employee_count: { $sum: 1 }
    }
  },
  {
    $lookup: {
      from: "departments",
      localField: "_id",
      foreignField: "_id",
      as: "dept_info"
    }
  },
  { $unwind: "$dept_info" },
  {
    $project: {
      department_name: "$dept_info.department_name",
      total_salary: 1,
      avg_salary: { $round: ["$avg_salary", 2] },
      employee_count: 1
    }
  },
  { $sort: { total_salary: -1 } }
]);

// 20. Find managers and their direct reports count
db.employees.aggregate([
  {
    $group: {
      _id: "$manager_id",
      reports_count: { $sum: 1 }
    }
  },
  {
    $lookup: {
      from: "employees",
      localField: "_id",
      foreignField: "_id",
      as: "manager"
    }
  },
  { $unwind: "$manager" },
  {
    $project: {
      manager_name: {
        $concat: ["$manager.first_name", " ", "$manager.last_name"]
      },
      reports_count: 1
    }
  },
  { $sort: { reports_count: -1 } }
]);


// =====================================
// INSERT OPERATIONS
// =====================================

// 21. Insert a new employee
db.employees.insertOne({
  _id: 300,
  first_name: "John",
  last_name: "Doe",
  email: "JDOE",
  phone_number: "515.123.9999",
  hire_date: "2024-01-15",
  job_id: "IT_PROG",
  salary: 7500,
  commission_pct: null,
  manager_id: 103,
  department_id: 60
});

// 22. Insert multiple departments
db.departments.insertMany([
  { _id: 120, department_name: "Data Science", manager_id: null, location_id: 1400 },
  { _id: 130, department_name: "DevOps", manager_id: null, location_id: 1400 }
]);


// =====================================
// UPDATE OPERATIONS
// =====================================

// 23. Give a raise to employee 300
db.employees.updateOne(
  { _id: 300 },
  { $set: { salary: 8000 } }
);

// 24. Give 10% raise to all IT programmers
db.employees.updateMany(
  { job_id: "IT_PROG" },
  { $mul: { salary: 1.1 } }
);

// 25. Add a new field (email domain) to all employees
db.employees.updateMany(
  {},
  { $set: { email_domain: "@company.com" } }
);

// 26. Update department manager
db.departments.updateOne(
  { _id: 120 },
  { $set: { manager_id: 103 } }
);


// =====================================
// DELETE OPERATIONS
// =====================================

// 27. Delete a specific employee
db.employees.deleteOne({ _id: 300 });

// 28. Delete all employees in a specific department (careful!)
// Commented out for safety
// db.employees.deleteMany({ department_id: 120 });

// 29. Delete departments without managers
// db.departments.deleteMany({ manager_id: null });


// =====================================
// COMPLEX QUERIES
// =====================================

// 30. Find employees earning more than their department's average
db.employees.aggregate([
  {
    $group: {
      _id: "$department_id",
      dept_avg_salary: { $avg: "$salary" },
      employees: { $push: "$$ROOT" }
    }
  },
  { $unwind: "$employees" },
  {
    $match: {
      $expr: { $gt: ["$employees.salary", "$dept_avg_salary"] }
    }
  },
  {
    $project: {
      _id: "$employees._id",
      first_name: "$employees.first_name",
      last_name: "$employees.last_name",
      salary: "$employees.salary",
      dept_avg_salary: { $round: ["$dept_avg_salary", 2] }
    }
  }
]);

// 31. Find salary increases for employees (from salary history)
db.salaries.aggregate([
  { $sort: { employee_id: 1, effective_date: 1 } },
  {
    $group: {
      _id: "$employee_id",
      salary_records: { $push: { date: "$effective_date", salary: "$salary" } },
      count: { $sum: 1 }
    }
  },
  { $match: { count: { $gt: 1 } } },
  {
    $lookup: {
      from: "employees",
      localField: "_id",
      foreignField: "_id",
      as: "employee"
    }
  },
  { $unwind: "$employee" },
  {
    $project: {
      name: { $concat: ["$employee.first_name", " ", "$employee.last_name"] },
      salary_records: 1
    }
  }
]);

// 32. Hierarchical query: Find all employees reporting to a specific manager
// (including indirect reports - would need recursive query or multiple lookups)
db.employees.aggregate([
  { $match: { manager_id: 100 } },
  {
    $lookup: {
      from: "employees",
      localField: "_id",
      foreignField: "manager_id",
      as: "direct_reports"
    }
  },
  {
    $project: {
      _id: 1,
      first_name: 1,
      last_name: 1,
      job_id: 1,
      reports_count: { $size: "$direct_reports" }
    }
  }
]);
