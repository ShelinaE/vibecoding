@echo off
setlocal

cd /d "%~dp0"
if errorlevel 1 goto folder_error

set "PYTHON_CMD="
py -3 -c "import sys; sys.exit(0 if sys.version_info >= (3, 11) else 1)" >nul 2>&1
if not errorlevel 1 set "PYTHON_CMD=py -3"

if not defined PYTHON_CMD (
    python -c "import sys; sys.exit(0 if sys.version_info >= (3, 11) else 1)" >nul 2>&1
    if not errorlevel 1 set "PYTHON_CMD=python"
)

if not defined PYTHON_CMD goto python_error

if exist ".venv\Scripts\python.exe" goto environment_ready
echo Setting up the TEI editor for its first use...
%PYTHON_CMD% -m venv .venv
if errorlevel 1 goto setup_error

:environment_ready
".venv\Scripts\python.exe" -c "import flask" >nul 2>&1
if not errorlevel 1 goto run_app
echo Installing Flask. Internet access may be needed for this first setup.
".venv\Scripts\python.exe" -m pip install -r requirements.txt
if errorlevel 1 goto setup_error

:run_app
echo Starting the TEI editor. Keep this window open while you use it.
".venv\Scripts\python.exe" app.py
if errorlevel 1 goto app_error
exit /b 0

:folder_error
echo ERROR: I could not open the TEI editor folder.
goto show_error

:python_error
echo ERROR: Python 3.11 or newer was not found. Install it from https://www.python.org/downloads/ and then double-click start.bat again.
goto show_error

:setup_error
echo ERROR: Setup failed. Check your internet connection if Flask could not be installed, then try again.
goto show_error

:app_error
echo ERROR: The TEI editor stopped with an error.

:show_error
echo.
pause
exit /b 1
