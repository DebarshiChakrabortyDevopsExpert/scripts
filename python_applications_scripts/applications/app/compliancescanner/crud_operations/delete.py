import sqlite3

conn = sqlite3.connect('students.db')

conn.execute("DELETE from STUDENT where ID = 2;")
conn.commit()

cursor = conn.execute("SELECT * from STUDENT")
print(cursor.fetchall())

conn.close()