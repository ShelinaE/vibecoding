#!/bin/bash

cd "$(dirname "$0")" || {
    printf 'ERROR: I could not open the TEI editor folder.\n'
    IFS= read -r -p 'Press Return to close this window. ' _
    exit 1
}

pause_on_error() {
    printf '\nPress Return to close this window. '
    IFS= read -r _
}

fail() {
    printf '\nERROR: %s\n' "$1"
    pause_on_error
    exit 1
}

PYTHON=""
for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1 &&
        "$candidate" -c 'import sys; sys.exit(0 if sys.version_info >= (3, 11) else 1)' >/dev/null 2>&1; then
        PYTHON="$candidate"
        break
    fi
done

if [ -z "$PYTHON" ]; then
    fail "Python 3.11 or newer was not found. Install it from https://www.python.org/downloads/ and then double-click start.command again."
fi

if [ ! -x ".venv/bin/python" ]; then
    printf 'Setting up the TEI editor for its first use...\n'
    "$PYTHON" -m venv .venv || fail "I could not create the Python environment."
fi

if ! .venv/bin/python -c 'import flask' >/dev/null 2>&1; then
    printf 'Installing Flask. Internet access may be needed for this first setup.\n'
    .venv/bin/python -m pip install -r requirements.txt || fail "I could not install Flask. Check your internet connection and try again."
fi

printf 'Starting the TEI editor. Keep this window open while you use it.\n'
.venv/bin/python app.py
APP_STATUS=$?

if [ "$APP_STATUS" -ne 0 ]; then
    fail "The TEI editor stopped with an error."
fi
