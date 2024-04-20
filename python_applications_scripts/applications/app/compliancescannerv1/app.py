from flask import Flask,render_template,request,redirect,url_for,flash
import sqlite3 as sql
app=Flask(__name__)

## Create a database before starting the flask application
## Run create_db.py before starting the flask application to insert policy

## This is the webpage route for index of the azure policy
@app.route("/")
@app.route("/index")
def index():
    con=sql.connect("db_crud_compliance_scanner.db")
    con.row_factory=sql.Row
    cur=con.cursor()
    cur.execute("SELECT * from POLICY")
    data=cur.fetchall()
    return render_template("index.html",datas=data)

## This is the webpage route for adding a new policy
@app.route("/add_policy",methods=['POST','GET'])
def add_policy():
    if request.method=='POST':
        policy_id       =request.form['policyid']
        resource_type   =request.form['resourcetype']
        policy_desc     =request.form['policydesc']
        policy_attr     =request.form['policyattr']
        policy_value    =request.form['policyvalue']
        con             =sql.connect("db_crud_compliance_scanner.db")
        cur             =con.cursor()
        cur.execute("insert into POLICY(POLICYID,RESOURCE_TYPE,POLICY_DESCRIPTION,POLICY_ATTRIBUTE,POLICY_VALUE) values (?,?,?,?,?)",(policy_id,resource_type,policy_desc,policy_attr,policy_value))
        con.commit()
        flash('Policy Succesfully Added','success')
        return redirect(url_for("index"))
    return render_template("add_policy.html")


## This is the webpage route for editing an existing policy
@app.route("/edit_policy/<string:uid>",methods=['POST','GET'])
def edit_policy(uid):
    if request.method=='POST':
        policy_id       =request.form['policyid']        
        resource_type   =request.form['resourcetype']
        policy_desc     =request.form['policydesc']
        policy_attr     =request.form['policyattr']
        policy_value    =request.form['policyvalue']
        con=sql.connect("db_crud_compliance_scanner.db")
        cur=con.cursor()
        cur.execute("update POLICY set POLICYID=?,RESOURCE_TYPE=?,POLICY_DESCRIPTION=?,POLICY_ATTRIBUTE=?,POLICY_VALUE=? where UID=?",(policy_id,resource_type,policy_desc,policy_attr,policy_value,uid))
        con.commit()
        flash('Policy Succesfully Updated','success')
        return redirect(url_for("index"))
    con=sql.connect("db_crud_compliance_scanner.db")
    con.row_factory=sql.Row
    cur=con.cursor()
    cur.execute("select * from POLICY where UID=?",(uid,))
    data=cur.fetchone()
    return render_template("edit_policy.html",datas=data)

## This is the webpage route for deleting an existing policy
@app.route("/delete_policy/<string:uid>",methods=['GET'])
def delete_policy(uid):
    con=sql.connect("db_crud_compliance_scanner.db")
    cur=con.cursor()
    cur.execute("delete from POLICY where UID=?",(uid,))
    con.commit()
    flash('Policy has been Deleted','warning')
    return redirect(url_for("index"))

## Enable debugging for the flask application
if __name__=='__main__':
    app.secret_key='admin123'
    app.run(host='0.0.0.0',debug=True)
