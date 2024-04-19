import sqlite3

def insert(db, row):
    db.execute('insert into test (t1, i1) values (?, ?)', (row['t1'], row['i1']))
    db.commit()

def insert(db, row):
    db.execute('insert into test (t1, i1) values (?, ?)', (row['t1'], row['i1']))
    db.commit()

def retrieve(db, t1):
    cursor = db.execute('select * from test where t1 = ?', (t1,))
    return cursor.fetchone()

def update(db, row):
    db.execute('update test set i1 = ? where t1 = ?', (row['i1'], row['t1']))
    db.commit()

def delete(db, t1):
    db.execute('delete from test where t1 = ?', (t1,))
    db.commit()

def disp_rows(db):
    cursor = db.execute('select * from test order by t1')
    for row in cursor:
        print('  {}: {}'.format(row['t1'], row['i1']))