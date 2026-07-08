import csv
from datetime import datetime

import psycopg2

try:
    connection = psycopg2.connect(
        host="localhost",
        dbname="sales",
        user="postgres",
        password="",
        port=5432
    )

    cursor = connection.cursor()

    with open("data/Sales Transaction v.4a.csv", mode="r") as file:
        reader = csv.reader(file)
        next(reader)
        for row in reader:

            transaction_no = row[0]
            date = datetime.strptime(row[1], '%m/%d/%Y').date()
            product_no = row[2]
            product_name = row[3]
            price = float(row[4]) if row[4] else 0
            quantity = int(row[5]) if row[5] else 0
            customer_no = row[6]
            country = row[7]

            insert_query = """
                            INSERT INTO sales (TransactionNo, Date, ProductNo, ProductName, Price, Quantity, CustomerNo, Country)
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                        """
            cursor.execute(insert_query, (transaction_no, date, product_no, product_name,
                                         price, quantity, customer_no, country))

        connection.commit()
        print(f"Данные успешно загружены. Добавлено записей: {cursor.rowcount}")

except Exception as error:
    print(f"Error while connecting to PostgreSQL: {error}")
    if connection:
        connection.rollback()

finally:
    if connection:
        cursor.close()
        connection.close()