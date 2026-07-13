@echo off
REM ============================================================================
REM  Albert Worksheet Download - Streamlit launcher
REM  Double-click this file to start the app in your browser.
REM ============================================================================

setlocal

REM --- Always run from the folder this .bat lives in --------------------------
cd /d "%~dp0"

REM --- Find a Python launcher -------------------------------------------------
set "PY="
where py >nul 2>nul && set "PY=py"
if not defined PY (
    where python >nul 2>nul && set "PY=python"
)
if not defined PY (
    echo [ERROR] Python was not found on your PATH.
    echo         Install Python 3 from https://www.python.org/downloads/
    echo         and be sure to tick "Add Python to PATH" during setup.
    echo.
    pause
    exit /b 1
)

echo Using Python launcher: %PY%
echo.

REM --- Make sure Streamlit (and the rest) are installed -----------------------
%PY% -c "import streamlit" >nul 2>nul
if errorlevel 1 (
    echo Streamlit not found - installing dependencies from requirements.txt ...
    %PY% -m pip install --upgrade pip
    %PY% -m pip install -r requirements.txt
    if errorlevel 1 (
        echo.
        echo [ERROR] Dependency installation failed. See the messages above.
        pause
        exit /b 1
    )
)

REM --- Launch the app --------------------------------------------------------
echo.
echo Starting the Albert Worksheet app...
echo A browser tab should open automatically. Close this window to stop the app.
echo.
%PY% -m streamlit run app.py

REM --- If Streamlit exits with an error, keep the window open -----------------
if errorlevel 1 (
    echo.
    echo [ERROR] Streamlit exited unexpectedly. See the messages above.
    pause
)

endlocal
