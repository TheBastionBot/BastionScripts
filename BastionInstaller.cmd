@ECHO off
TITLE Bastion Installer
CLS
COLOR 0F
ECHO.
ECHO -------------------------------
ECHO      Bastion BOT Installer
ECHO -------------------------------
ECHO.

SET cwd=%~dp0

ECHO [Bastion]: Initializing System...
RMDIR /S /Q Bastion >nul 2>&1
ECHO.

ECHO [Bastion]: Verifying Git installation...
git --version >null 2>&1 && ECHO [Bastion]: Git is already installed. Looks good. || (
	TITLE [ERROR] Git Not Found
	ECHO [Bastion]: Git is not installed.
	ECHO [Bastion]: Make sure you choose the Option "Run Git from the Windows Command Prompt" while installing Git.
	GOTO :EXIT
)
ECHO.

ECHO [Bastion]: Verifying Node installation...
node --version >nul 2>&1 && ECHO [Bastion]: Node is already installed. Looks good. || (
	TITLE [ERROR] Node Not Found
	ECHO [Bastion]: Node is not installed in your computer.
	ECHO [Bastion]: Make sure to follow the Bastion Windows Installation Guide before running this installer.
	GOTO :EXIT
)
ECHO.

ECHO [Bastion]: Installing system files...
CD /D %USERPROFILE%\Desktop
git clone -b master -q --depth 1 https://github.com/snkrsnkampa/Bastion.git >nul 2>&1 || (ECHO [Bastion]: Unable to download Bastion System files. Check your internet connection. && GOTO :EXIT)

::TODO: Find a way to show a message when npm install fails.
CD Bastion && CALL npm install >nul 2>&1
ECHO [Bastion]: System files successfully installed.

ECHO [Bastion]: Finalizing...
CD settings && COPY config_example.json config.json && COPY credentials_example.json credentials.json && ECHO [Bastion]: Done. \o/
ECHO.

ECHO [Bastion]: System Initialized. O7
ECHO [Bastion]: Ready to boot up and start running.
EXIT /B 0

:EXIT
ECHO.
ECHO [Bastion]: Press any key to exit.
PAUSE >nul 2>&1
CD /D "%cwd%"
TITLE Windows Command Prompt (CMD)