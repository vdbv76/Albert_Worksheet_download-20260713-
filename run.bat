@echo off
REM ============================================================================
REM  Albert Worksheet Download - Streamlit launcher
REM  Double-click this file to start the app in your browser.
REM ============================================================================

setlocal enabledelayedexpansion

REM --- Always run from the folder this .bat lives in --------------------------
cd /d "%~dp0"

REM ----------------------------------------------------------------------------
REM  Find a Python 3.9+ interpreter.
REM  Streamlit needs Python 3.9 or newer - an old Python (e.g. 3.5) will NOT
REM  work, so we test each candidate and keep the first that is new enough.
REM ----------------------------------------------------------------------------
set "PY="
for %%C in ("py -3.13" "py -3.12" "py -3.11" "py -3.10" "py -3.9" "py -3" "python" "py") do (
    if not defined PY (
        %%~C -c "import sys; sys.exit(0 if sys.version_info[:2]>=(3,9) else 1)" >nul 2>nul
        if not errorlevel 1 set "PY=%%~C"
    )
)

if not defined PY (
    echo [ERROR] No suitable Python found ^(need Python 3.9 or newer^).
    echo.
    echo   You appear to have only an old Python installed. Streamlit will not
    echo   run on it. Please install a current Python 3.x:
    echo.
    echo     https://www.python.org/downloads/
    echo.
    echo   During setup, tick "Add Python to PATH".
    echo   Then double-click this file again.
    echo.
    pause
    exit /b 1
)

echo Using Python: %PY%
for /f "delims=" %%V in ('%PY% -c "import sys;print(sys.version.split()[0])"') do set "PYVER=%%V"
echo Python version: %PYVER%
echo.

REM ----------------------------------------------------------------------------
REM  Make sure Streamlit (and the rest) are installed.
REM  --trusted-host flags let pip work behind a corporate SSL-inspecting proxy
REM  that otherwise triggers CERTIFICATE_VERIFY_FAILED.
REM ----------------------------------------------------------------------------
set "PIP_TRUSTED=--trusted-host pypi.org --trusted-host files.pythonhosted.org --trusted-host pypi.python.org"

%PY% -c "import streamlit" >nul 2>nul
if errorlevel 1 (
    echo Streamlit not found - installing dependencies from requirements.txt ...
    %PY% -m pip install --upgrade %PIP_TRUSTED% pip
    %PY% -m pip install %PIP_TRUSTED% -r requirements.txt
    if errorlevel 1 (
        echo.
        echo [ERROR] Dependency installation failed. See the messages above.
        echo   If you still see an SSL / certificate error, your network may
        echo   require a proxy or a custom CA. Ask IT for the pip proxy settings,
        echo   or run this once in a Command Prompt:
        echo.
        echo     %PY% -m pip config set global.trusted-host "pypi.org files.pythonhosted.org"
        echo.
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
