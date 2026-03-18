"""Query MySQL using dynamic credentials from Akeyless.

Usage:
    python3 app/secure_query.py --user <user> --password <password> --query "SELECT ..."
"""

import argparse
import mysql.connector


def main():
    parser = argparse.ArgumentParser(description="Query MySQL with dynamic credentials")
    parser.add_argument("--user", required=True, help="MySQL username")
    parser.add_argument("--password", required=True, help="MySQL password")
    parser.add_argument("--query", required=True, help="SQL query to execute")
    parser.add_argument("--host", default="127.0.0.1", help="MySQL host")
    parser.add_argument("--port", type=int, default=3306, help="MySQL port")
    parser.add_argument("--database", default="demo", help="Database name")
    args = parser.parse_args()

    conn = mysql.connector.connect(
        host=args.host,
        port=args.port,
        user=args.user,
        password=args.password,
        database=args.database,
    )
    cursor = conn.cursor()
    cursor.execute(args.query)
    columns = [desc[0] for desc in cursor.description]
    rows = cursor.fetchall()
    conn.close()

    # Print header
    print(" | ".join(columns))
    print("-" * (len(" | ".join(columns)) + 10))
    for row in rows:
        print(" | ".join(str(v) for v in row))


if __name__ == "__main__":
    main()
