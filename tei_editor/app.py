"""The TEI page editor."""

from threading import Timer
import webbrowser

from flask import Flask, render_template

app = Flask(__name__)


@app.get("/")
def home():
    """Show one column of editable transcription lines."""
    return render_template("index.html", line_numbers=range(1, 31))


if __name__ == "__main__":
    # Give Flask a moment to start before opening the page in the browser.
    Timer(1.0, lambda: webbrowser.open("http://127.0.0.1:5001")).start()
    app.run(host="127.0.0.1", port=5001, debug=False, use_reloader=False)
