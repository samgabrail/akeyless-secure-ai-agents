CREATE DATABASE IF NOT EXISTS demo;
USE demo;

CREATE TABLE IF NOT EXISTS customers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  company_name VARCHAR(100) NOT NULL,
  contact_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  contract_tier VARCHAR(20) NOT NULL,
  annual_revenue DECIMAL(12,2),
  region VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO customers (company_name, contact_name, email, contract_tier, annual_revenue, region) VALUES
("Acme Corp", "Sarah Chen", "s.chen@acme.io", "Enterprise", 2450000.00, "US-West"),
("GlobalTech Industries", "James Rodriguez", "j.rodriguez@globaltech.com", "Enterprise", 8900000.00, "US-East"),
("Nordic Systems AB", "Erik Lindgren", "erik@nordicsystems.se", "Professional", 1200000.00, "EU-North"),
("Quantum AI Labs", "Priya Sharma", "priya@quantumai.dev", "Enterprise", 5600000.00, "APAC"),
("SecureStack Ltd", "Tom Bradley", "tom.b@securestack.co.uk", "Professional", 890000.00, "EU-West"),
("DataFlow Systems", "Maria Santos", "maria@dataflow.io", "Starter", 340000.00, "LATAM"),
("CloudBridge Networks", "Alex Kim", "akim@cloudbridge.net", "Enterprise", 4200000.00, "APAC"),
("Pinnacle Finance Group", "Robert Fischer", "rfischer@pinnaclefg.com", "Enterprise", 12000000.00, "US-East"),
("GreenEnergy Solutions", "Anna Mueller", "a.mueller@greenenergy.de", "Professional", 1800000.00, "EU-Central"),
("TechVentures Inc", "David Park", "dpark@techventures.com", "Starter", 560000.00, "US-West");
