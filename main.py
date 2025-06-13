import chainlit as cl
import pyodbc
import os

# Azure SQL connection details from environment variables
SQL_SERVER = os.getenv('AZURE_SQL_SERVER', 'chainlit-sql-server.database.windows.net')
SQL_DATABASE = os.getenv('AZURE_SQL_DATABASE', 'chainlitdb')
SQL_USERNAME = os.getenv('AZURE_SQL_USERNAME', 'tdadmin')
SQL_PASSWORD = os.getenv('AZURE_SQL_ADMIN_PASSWORD', 'YourStrong!Passw0rd')

# Connection string for Azure SQL
conn_str = (
    f'DRIVER={{ODBC Driver 18 for SQL Server}};'
    f'SERVER={SQL_SERVER};'
    f'DATABASE={SQL_DATABASE};'
    f'UID={SQL_USERNAME};'
    f'PWD={SQL_PASSWORD};'
    'Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;'
)

def get_db_time():
    try:
        with pyodbc.connect(conn_str) as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT SYSDATETIME()")
            row = cursor.fetchone()
            return str(row[0]) if row else 'No result'
    except Exception as e:
        return f"Error: {e}"

@cl.on_message
def main(message: cl.Message):
    if message.content.strip().lower() == 'time':
        db_time = get_db_time()
        cl.Message(content=f"Azure SQL DB time: {db_time}").send()
    else:
        cl.Message(content="Send 'time' to get the current time from Azure SQL DB.").send()
