"""
Synthetic SAST Vulnerability Test Fixture for TigerGate Evaluation.
DO NOT USE IN PRODUCTION. Synthetic test cases only.
"""
import sqlite3
import os
from flask import Flask, request

app = Flask(__name__)

@app.route("/user")
def get_user():
    user_id = request.args.get("id")
    conn = sqlite3.connect("test.db")
    cursor = conn.cursor()
    # CWE-89: SQL Injection via unsanitized string formatting
    query = f"SELECT * FROM users WHERE id = '{user_id}'"
    cursor.execute(query)
    return str(cursor.fetchall())

@app.route("/ping")
def ping_host():
    host = request.args.get("host")
    # CWE-78: OS Command Injection via system call
    os.system(f"ping -c 1 {host}")
    return "Ping executed"

@app.route("/read")
def read_file():
    filename = request.args.get("filename")
    # CWE-22: Path Traversal
    with open(f"/tmp/uploads/{filename}", "r") as f:
        return f.read()

if __name__ == "__main__":
    app.run(port=5000)
