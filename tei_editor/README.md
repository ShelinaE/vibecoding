# TEI Page Editor

This is a small app that runs on your own computer and opens in a web browser. It listens only on your computer, at `http://127.0.0.1:5001`.

## Before you start

Install Python 3.11 or newer if it is not already installed:

1. Go to [python.org/downloads](https://www.python.org/downloads/).
2. Download and install Python for your computer.
3. Close and reopen File Explorer (Windows) or Finder (macOS), then try the start script below.

The first time you start the app, it creates its private Python environment and installs Flask. This setup may need an internet connection. After that, starting and using the app does not need internet access.

## Start the app on Windows

1. Open the `tei_editor` folder in File Explorer.
2. Double-click `start.bat`.
3. Keep the black window open while you use the app. Your browser should open and show **TEI editor is running**.
4. To stop the app, close the black window.

## Start the app on macOS

1. Open the `tei_editor` folder in Finder.
2. Double-click `start.command`.
3. If macOS asks you to confirm, Control-click `start.command`, choose **Open**, and confirm **Open**.
4. Keep the Terminal window open while you use the app. Your browser should open and show **TEI editor is running**.
5. To stop the app, close the Terminal window.

## If something goes wrong

Read the message in the window opened by the start script. If Python is missing or too old, install Python 3.11 or newer and try again. If Flask cannot be installed on the first run, connect to the internet and double-click the start script again.

This first phase only checks that the app starts. It does not yet include transcription lines or save any transcription.
