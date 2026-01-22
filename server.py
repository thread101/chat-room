from flask import Flask, render_template, url_for
from pathlib import Path

app = Flask(__file__)

@app.route("/")
def index():
    return render_template("login.html", title="Simple chat login")

@app.route("/chat")
def chat():
    return render_template("chat-home.html", title="Simple chat home")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)