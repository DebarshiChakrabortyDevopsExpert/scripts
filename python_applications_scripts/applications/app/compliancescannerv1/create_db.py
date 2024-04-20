import sqlite3 as sql

#connect to SQLite
con = sql.connect('db_crud_compliance_scanner.db')

#Create a Connection
cur = con.cursor()

#Drop users table if already exsist.
cur.execute("DROP TABLE IF EXISTS POLICY")

#Create users table  in db_web database
sql ="""CREATE TABLE POLICY(
        UID INTEGER PRIMARY KEY AUTOINCREMENT,
        POLICYID CHAR(50) NOT NULL,
        RESOURCE_TYPE CHAR(50) NOT NULL, 
        POLICY_DESCRIPTION CHAR(250), 
        POLICY_ATTRIBUTE CHAR(50), 
        POLICY_VALUE CHAR(50) )"""
cur.execute(sql)

#Insert some values in the database to check
con.execute("INSERT INTO POLICY (POLICYID,RESOURCE_TYPE,POLICY_DESCRIPTION,POLICY_ATTRIBUTE,POLICY_VALUE) "
             "VALUES ('STO001', 'azurerm_storage_account', 'Boolean flag which forces HTTPS if enabled', 'enable_https_traffic_only', 'TRUE')")
con.commit()

#Query to check if the values are executed or not
cursor = con.execute("SELECT * from POLICY")
print(cursor.fetchall())

#close the connection
con.close()