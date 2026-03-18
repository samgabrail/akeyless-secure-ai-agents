import mysql.connector

# Database credentials
DB_HOST = "127.0.0.1"
DB_PORT = 3306
DB_USER = "root"
DB_PASSWORD = "DemoRoot2026"
DB_NAME = "demo"

def query_customers():
    conn = mysql.connector.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME
    )
    cursor = conn.cursor()
    cursor.execute("SELECT company_name, contact_name, contract_tier, annual_revenue FROM customers")
    results = cursor.fetchall()
    for row in results:
        print(f"{row[0]} | {row[1]} | {row[2]} | ${row[3]:,.2f}")
    conn.close()

if __name__ == "__main__":
    query_customers()
