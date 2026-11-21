"""The first, minimal version of the TEI editor."""

from threading import Timer
import webbrowser

from flask import Flask

app = Flask(__name__)


@app.get("/")
def home():
    """Show a simple message so the user knows the app has started."""
    return "<main><h1>TEI editor is running</h1></main>"


if __name__ == "__main__":
    # Give Flask a moment to start before opening the page in the browser.
    Timer(1.0, lambda: webbrowser.open("http://127.0.0.1:5001")).start()
    app.run(host="127.0.0.1", port=5001, debug=False, use_reloader=False)
