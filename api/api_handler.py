from flask import Flask, request, jsonify
from flask_cors import CORS
from pathlib import Path
import sys

p = f"{Path(__file__).resolve().parent}"
sys.path.insert(0, p)

import chat_handler as CH

Chats = CH.Chat()
app = Flask(__file__)
CORS(app)


@app.route("/api/new", methods=["POST"])
def new():
    data = request.json
    entries = list(data.keys())
    if "room" not in entries or "password" not in entries:
        return jsonify({"error": "invalid entries"})

    room = data["room"]
    password = data["password"]
    if len(password) < 4:
        return jsonify({"error": "password too short"})

    key, status = Chats.new(room, password)

    if status == 0:
        return jsonify({"key": key})

    return jsonify({"error": key})


@app.route("/api/join", methods=["POST"])
def join():
    data = request.json
    entries = list(data.keys())
    if "room" not in entries or "password" not in entries:
        return jsonify({"error": "invalid entries"})

    password = data["password"]
    room = data["room"]

    key, status = Chats.join(room, password)
    if status == 0:
        return jsonify({"key": key})

    return jsonify({"error": key})


@app.route("/api/chat", methods=["POST"])
def chat():
    data = request.json
    entries = list(data.keys())
    if "room" not in entries or "key" not in entries or "message" not in entries:
        return jsonify({"error": "invalid entries"})

    key = data["key"]
    room = data["room"]
    message = data["message"]

    chats, status = Chats.chat(room, key, message)
    if status == 0:
        return jsonify({"chats": chats})

    return jsonify({"error": chats})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)
