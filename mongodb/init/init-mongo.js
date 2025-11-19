// MongoDB initialization script
// This script automatically loads sample data when the container starts for the first time

// Switch to the kmidbt database
db = db.getSiblingDB('kmidbt');

print('Loading HR sample data...');

// Load departments
db.departments.insertMany([
  { _id: 10, department_name: "Administration", manager_id: 200, location_id: 1700 },
  { _id: 20, department_name: "Marketing", manager_id: 201, location_id: 1800 },
  { _id: 30, department_name: "Purchasing", manager_id: 114, location_id: 1700 },
  { _id: 40, department_name: "Human Resources", manager_id: 203, location_id: 2400 },
  { _id: 50, department_name: "Shipping", manager_id: 121, location_id: 1500 },
  { _id: 60, department_name: "IT", manager_id: 103, location_id: 1400 },
  { _id: 70, department_name: "Public Relations", manager_id: 204, location_id: 2700 },
  { _id: 80, department_name: "Sales", manager_id: 145, location_id: 2500 },
  { _id: 90, department_name: "Executive", manager_id: 100, location_id: 1700 },
  { _id: 100, department_name: "Finance", manager_id: 108, location_id: 1700 },
  { _id: 110, department_name: "Accounting", manager_id: 205, location_id: 1700 }
]);

print('Departments loaded: ' + db.departments.countDocuments());

// Load employees
db.employees.insertMany([
  { _id: 100, first_name: "Steven", last_name: "King", email: "SKING", phone_number: "515.123.4567", hire_date: "2003-06-17", job_id: "AD_PRES", salary: 24000, commission_pct: null, manager_id: null, department_id: 90 },
  { _id: 101, first_name: "Neena", last_name: "Kochhar", email: "NKOCHHAR", phone_number: "515.123.4568", hire_date: "2005-09-21", job_id: "AD_VP", salary: 17000, commission_pct: null, manager_id: 100, department_id: 90 },
  { _id: 102, first_name: "Lex", last_name: "De Haan", email: "LDEHAAN", phone_number: "515.123.4569", hire_date: "2001-01-13", job_id: "AD_VP", salary: 17000, commission_pct: null, manager_id: 100, department_id: 90 },
  { _id: 103, first_name: "Alexander", last_name: "Hunold", email: "AHUNOLD", phone_number: "590.423.4567", hire_date: "2006-01-03", job_id: "IT_PROG", salary: 9000, commission_pct: null, manager_id: 102, department_id: 60 },
  { _id: 104, first_name: "Bruce", last_name: "Ernst", email: "BERNST", phone_number: "590.423.4568", hire_date: "2007-05-21", job_id: "IT_PROG", salary: 6000, commission_pct: null, manager_id: 103, department_id: 60 },
  { _id: 105, first_name: "David", last_name: "Austin", email: "DAUSTIN", phone_number: "590.423.4569", hire_date: "2005-06-25", job_id: "IT_PROG", salary: 4800, commission_pct: null, manager_id: 103, department_id: 60 },
  { _id: 106, first_name: "Valli", last_name: "Pataballa", email: "VPATABAL", phone_number: "590.423.4560", hire_date: "2006-02-05", job_id: "IT_PROG", salary: 4800, commission_pct: null, manager_id: 103, department_id: 60 },
  { _id: 107, first_name: "Diana", last_name: "Lorentz", email: "DLORENTZ", phone_number: "590.423.5567", hire_date: "2007-02-07", job_id: "IT_PROG", salary: 4200, commission_pct: null, manager_id: 103, department_id: 60 },
  { _id: 108, first_name: "Nancy", last_name: "Greenberg", email: "NGREENBE", phone_number: "515.124.4569", hire_date: "2002-08-17", job_id: "FI_MGR", salary: 12008, commission_pct: null, manager_id: 101, department_id: 100 },
  { _id: 109, first_name: "Daniel", last_name: "Faviet", email: "DFAVIET", phone_number: "515.124.4169", hire_date: "2002-08-16", job_id: "FI_ACCOUNT", salary: 9000, commission_pct: null, manager_id: 108, department_id: 100 },
  { _id: 110, first_name: "John", last_name: "Chen", email: "JCHEN", phone_number: "515.124.4269", hire_date: "2005-09-28", job_id: "FI_ACCOUNT", salary: 8200, commission_pct: null, manager_id: 108, department_id: 100 },
  { _id: 111, first_name: "Ismael", last_name: "Sciarra", email: "ISCIARRA", phone_number: "515.124.4369", hire_date: "2005-09-30", job_id: "FI_ACCOUNT", salary: 7700, commission_pct: null, manager_id: 108, department_id: 100 },
  { _id: 112, first_name: "Jose Manuel", last_name: "Urman", email: "JMURMAN", phone_number: "515.124.4469", hire_date: "2006-03-07", job_id: "FI_ACCOUNT", salary: 7800, commission_pct: null, manager_id: 108, department_id: 100 },
  { _id: 113, first_name: "Luis", last_name: "Popp", email: "LPOPP", phone_number: "515.124.4567", hire_date: "2007-12-07", job_id: "FI_ACCOUNT", salary: 6900, commission_pct: null, manager_id: 108, department_id: 100 },
  { _id: 114, first_name: "Den", last_name: "Raphaely", email: "DRAPHEAL", phone_number: "515.127.4561", hire_date: "2002-12-07", job_id: "PU_MAN", salary: 11000, commission_pct: null, manager_id: 100, department_id: 30 },
  { _id: 115, first_name: "Alexander", last_name: "Khoo", email: "AKHOO", phone_number: "515.127.4562", hire_date: "2003-05-18", job_id: "PU_CLERK", salary: 3100, commission_pct: null, manager_id: 114, department_id: 30 },
  { _id: 116, first_name: "Shelli", last_name: "Baida", email: "SBAIDA", phone_number: "515.127.4563", hire_date: "2005-12-24", job_id: "PU_CLERK", salary: 2900, commission_pct: null, manager_id: 114, department_id: 30 },
  { _id: 121, first_name: "Adam", last_name: "Fripp", email: "AFRIPP", phone_number: "650.123.2234", hire_date: "2005-04-10", job_id: "ST_MAN", salary: 8200, commission_pct: null, manager_id: 100, department_id: 50 },
  { _id: 145, first_name: "John", last_name: "Russell", email: "JRUSSEL", phone_number: "011.44.1344.429268", hire_date: "2004-10-01", job_id: "SA_MAN", salary: 14000, commission_pct: 0.4, manager_id: 100, department_id: 80 },
  { _id: 146, first_name: "Karen", last_name: "Partners", email: "KPARTNER", phone_number: "011.44.1344.467268", hire_date: "2005-01-05", job_id: "SA_MAN", salary: 13500, commission_pct: 0.3, manager_id: 100, department_id: 80 },
  { _id: 200, first_name: "Jennifer", last_name: "Whalen", email: "JWHALEN", phone_number: "515.123.4444", hire_date: "2003-09-17", job_id: "AD_ASST", salary: 4400, commission_pct: null, manager_id: 101, department_id: 10 },
  { _id: 201, first_name: "Michael", last_name: "Hartstein", email: "MHARTSTE", phone_number: "515.123.5555", hire_date: "2004-02-17", job_id: "MK_MAN", salary: 13000, commission_pct: null, manager_id: 100, department_id: 20 },
  { _id: 203, first_name: "Susan", last_name: "Mavris", email: "SMAVRIS", phone_number: "515.123.7777", hire_date: "2002-06-07", job_id: "HR_REP", salary: 6500, commission_pct: null, manager_id: 101, department_id: 40 },
  { _id: 204, first_name: "Hermann", last_name: "Baer", email: "HBAER", phone_number: "515.123.8888", hire_date: "2002-06-07", job_id: "PR_REP", salary: 10000, commission_pct: null, manager_id: 101, department_id: 70 },
  { _id: 205, first_name: "Shelley", last_name: "Higgins", email: "SHIGGINS", phone_number: "515.123.8080", hire_date: "2002-06-07", job_id: "AC_MGR", salary: 12008, commission_pct: null, manager_id: 101, department_id: 110 }
]);

print('Employees loaded: ' + db.employees.countDocuments());

// Load salaries (salary history)
db.salaries.insertMany([
  { _id: 1, employee_id: 100, effective_date: "2003-06-17", salary: 24000, salary_type: "annual" },
  { _id: 2, employee_id: 101, effective_date: "2005-09-21", salary: 17000, salary_type: "annual" },
  { _id: 3, employee_id: 102, effective_date: "2001-01-13", salary: 17000, salary_type: "annual" },
  { _id: 4, employee_id: 103, effective_date: "2006-01-03", salary: 9000, salary_type: "annual" },
  { _id: 5, employee_id: 103, effective_date: "2020-01-01", salary: 9500, salary_type: "annual" },
  { _id: 6, employee_id: 104, effective_date: "2007-05-21", salary: 6000, salary_type: "annual" },
  { _id: 7, employee_id: 105, effective_date: "2005-06-25", salary: 4800, salary_type: "annual" },
  { _id: 8, employee_id: 108, effective_date: "2002-08-17", salary: 12008, salary_type: "annual" },
  { _id: 9, employee_id: 108, effective_date: "2018-08-17", salary: 12500, salary_type: "annual" },
  { _id: 10, employee_id: 109, effective_date: "2002-08-16", salary: 9000, salary_type: "annual" },
  { _id: 11, employee_id: 110, effective_date: "2005-09-28", salary: 8200, salary_type: "annual" },
  { _id: 12, employee_id: 114, effective_date: "2002-12-07", salary: 11000, salary_type: "annual" },
  { _id: 13, employee_id: 145, effective_date: "2004-10-01", salary: 14000, salary_type: "annual" },
  { _id: 14, employee_id: 145, effective_date: "2019-10-01", salary: 15000, salary_type: "annual" },
  { _id: 15, employee_id: 200, effective_date: "2003-09-17", salary: 4400, salary_type: "annual" },
  { _id: 16, employee_id: 201, effective_date: "2004-02-17", salary: 13000, salary_type: "annual" },
  { _id: 17, employee_id: 203, effective_date: "2002-06-07", salary: 6500, salary_type: "annual" },
  { _id: 18, employee_id: 204, effective_date: "2002-06-07", salary: 10000, salary_type: "annual" },
  { _id: 19, employee_id: 205, effective_date: "2002-06-07", salary: 12008, salary_type: "annual" }
]);

print('Salaries loaded: ' + db.salaries.countDocuments());

print('\nLoading E-commerce sample data...');

// Load products
db.products.insertMany([
  { _id: 1, name: "Laptop Pro 15", category: "Electronics", price: 1299.99, stock: 45, description: "High-performance laptop with 15-inch display", specifications: { cpu: "Intel i7", ram: "16GB", storage: "512GB SSD" }, tags: ["laptop", "computer", "electronics"] },
  { _id: 2, name: "Wireless Mouse", category: "Accessories", price: 29.99, stock: 150, description: "Ergonomic wireless mouse with USB receiver", specifications: { connectivity: "Wireless 2.4GHz", battery: "2x AA", dpi: "1600" }, tags: ["mouse", "wireless", "accessories"] },
  { _id: 3, name: "USB-C Hub", category: "Accessories", price: 49.99, stock: 89, description: "7-in-1 USB-C hub with HDMI and card reader", specifications: { ports: ["HDMI", "USB 3.0 x3", "SD", "MicroSD", "USB-C"], power_delivery: "100W" }, tags: ["hub", "usb-c", "adapter"] },
  { _id: 4, name: "Mechanical Keyboard", category: "Accessories", price: 89.99, stock: 67, description: "RGB mechanical keyboard with blue switches", specifications: { switch_type: "Blue", backlight: "RGB", connectivity: "USB Wired" }, tags: ["keyboard", "mechanical", "gaming"] },
  { _id: 5, name: "27-inch Monitor", category: "Electronics", price: 349.99, stock: 32, description: "4K UHD monitor with HDR support", specifications: { resolution: "3840x2160", refresh_rate: "60Hz", panel: "IPS" }, tags: ["monitor", "4k", "display"] },
  { _id: 6, name: "Webcam HD", category: "Accessories", price: 79.99, stock: 120, description: "1080p HD webcam with built-in microphone", specifications: { resolution: "1920x1080", fps: "30", microphone: "Built-in" }, tags: ["webcam", "camera", "video"] },
  { _id: 7, name: "Bluetooth Headphones", category: "Audio", price: 159.99, stock: 78, description: "Noise-cancelling over-ear headphones", specifications: { connectivity: "Bluetooth 5.0", battery: "30 hours", noise_cancelling: true }, tags: ["headphones", "audio", "bluetooth"] },
  { _id: 8, name: "Portable SSD 1TB", category: "Storage", price: 129.99, stock: 95, description: "Fast portable SSD with USB-C", specifications: { capacity: "1TB", interface: "USB 3.2 Gen 2", read_speed: "1050 MB/s" }, tags: ["ssd", "storage", "portable"] },
  { _id: 9, name: "Laptop Stand", category: "Accessories", price: 39.99, stock: 134, description: "Adjustable aluminum laptop stand", specifications: { material: "Aluminum", adjustable: true, max_weight: "5kg" }, tags: ["stand", "laptop", "desk"] },
  { _id: 10, name: "USB Cable 3-Pack", category: "Accessories", price: 15.99, stock: 200, description: "USB-C to USB-A cables, 6ft each", specifications: { length: "6ft", type: "USB-C to USB-A", count: 3 }, tags: ["cable", "usb", "charging"] }
]);

print('Products loaded: ' + db.products.countDocuments());

// Load customers
db.customers.insertMany([
  { _id: 1001, first_name: "Emma", last_name: "Johnson", email: "emma.johnson@email.com", phone: "+1-555-0101", address: { street: "123 Main St", city: "New York", state: "NY", zip: "10001", country: "USA" }, registration_date: "2023-01-15", loyalty_points: 450 },
  { _id: 1002, first_name: "Michael", last_name: "Smith", email: "michael.smith@email.com", phone: "+1-555-0102", address: { street: "456 Oak Ave", city: "Los Angeles", state: "CA", zip: "90001", country: "USA" }, registration_date: "2023-03-22", loyalty_points: 720 },
  { _id: 1003, first_name: "Sarah", last_name: "Williams", email: "sarah.williams@email.com", phone: "+1-555-0103", address: { street: "789 Pine Rd", city: "Chicago", state: "IL", zip: "60601", country: "USA" }, registration_date: "2023-02-10", loyalty_points: 1200 },
  { _id: 1004, first_name: "James", last_name: "Brown", email: "james.brown@email.com", phone: "+1-555-0104", address: { street: "321 Elm St", city: "Houston", state: "TX", zip: "77001", country: "USA" }, registration_date: "2023-04-05", loyalty_points: 380 },
  { _id: 1005, first_name: "Emily", last_name: "Davis", email: "emily.davis@email.com", phone: "+1-555-0105", address: { street: "654 Maple Dr", city: "Phoenix", state: "AZ", zip: "85001", country: "USA" }, registration_date: "2023-05-18", loyalty_points: 890 },
  { _id: 1006, first_name: "David", last_name: "Miller", email: "david.miller@email.com", phone: "+1-555-0106", address: { street: "987 Cedar Ln", city: "Philadelphia", state: "PA", zip: "19101", country: "USA" }, registration_date: "2023-06-30", loyalty_points: 560 },
  { _id: 1007, first_name: "Olivia", last_name: "Garcia", email: "olivia.garcia@email.com", phone: "+1-555-0107", address: { street: "147 Birch St", city: "San Antonio", state: "TX", zip: "78201", country: "USA" }, registration_date: "2023-07-12", loyalty_points: 1450 },
  { _id: 1008, first_name: "Daniel", last_name: "Martinez", email: "daniel.martinez@email.com", phone: "+1-555-0108", address: { street: "258 Spruce Ave", city: "San Diego", state: "CA", zip: "92101", country: "USA" }, registration_date: "2023-08-25", loyalty_points: 230 }
]);

print('Customers loaded: ' + db.customers.countDocuments());

// Note: Orders and reviews are larger, so they're available in the data/ directory
// for manual import if needed. Basic sample data loaded above is sufficient for initial exploration.

print('\n=== Sample data loading complete! ===');
print('HR Collections: departments, employees, salaries');
print('E-commerce Collections: products, customers');
print('Additional data available in /data directory for manual import.');
