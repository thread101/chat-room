from flask import render_template, url_for
from pathlib import Path
import sys

p = f"{Path(__file__).resolve().parent}/api"
sys.path.insert(0, p)

from api_handler import *


@app.route("/")
def index():
    return render_template("login.html", title="Simple chat", rooms=Chats.rooms()[0])


@app.route("/chat-home")
def chat_home():
    return render_template("chat-home.html", title="Simple chat home")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
