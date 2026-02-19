#!/usr/bin/env python
# coding=utf-8

from flask import Flask, make_response, jsonify
import json
import os
from werkzeug.exceptions import NotFound

app = Flask(__name__)

# Base directory for data
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
USERS_FILE = os.path.join(BASE_DIR, "users.json")

def load_users():
    try:
        with open(USERS_FILE, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        return {"admin": {"name": "System Administrator", "role": "God"}}

users = load_users()

@app.route("/", methods=['GET'])
def index():
    return jsonify({
        "system": "Justitia 4.0 Dashboard",
        "status": "Operational",
        "version": "1.0.0",
        "endpoints": {
            "users": "/users",
            "health": "/health"
        }
    })

@app.route("/health", methods=['GET'])
def health():
    return jsonify({"status": "UP", "database": "Connected"})

@app.route("/users", methods=['GET'])
def all_users():
    return jsonify(users)

@app.route("/users/<username>", methods=['GET'])
def user_data(username):
    if username not in users:
        raise NotFound
    return jsonify(users[username])

if __name__ == "__main__":
    # We use port 8080 as standard for unprivileged containers
    app.run(host='0.0.0.0', port=8080)
