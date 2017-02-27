@ECHO off
CLS
COLOR 0F
SET cwd=%~dp0

NET SESSION >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
	TITLE Bastion Installer
) ELSE (
  TITLE [ERROR] Permission Denied
	ECHO [Bastion]: Bastion BOT Installer requires Administrator permissions. Run this installer as Administrator.
	GOTO :EXIT
)

FOR /F "usebackq tokens=1,2 delims==" %%i IN (`wmic os get LocalDateTime /VALUE 2^>NUL`) DO IF '.%%i.'=='.LocalDateTime.' SET ldt=%%j
SET ldt=%ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2% %ldt:~8,2%:%ldt:~10,2%:%ldt:~12,6%
ECHO [ %ldt% ]
ECHO [Bastion]: Bastion BOT Installer
ECHO [Bastion]: Starting Installer...
ECHO.

ECHO [Bastion]: Initializing System...
IF EXIST "%PROGRAMFILES(X86)%" (
	SET BIT=x64
	bitsadmin /transfer "Downloading wget" /download /priority high https://eternallybored.org/misc/wget/current/wget64.exe %WINDIR%\wget.exe &>nul
) ELSE (
	SET BIT=x86
	bitsadmin /transfer "Downloading wget" /download /priority high https://eternallybored.org/misc/wget/current/wget.exe %WINDIR%\wget.exe &>nul
)
MOVE /Y Bastion Bastion-Old >nul 2>&1
ECHO.

ECHO [Bastion]: Verifying Git installation...
git --version >nul 2>&1 && ECHO [Bastion]: Git is already installed. Looks good. || (
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
	ECHO [Bastion]: Make sure to follow the Bastion Windows Installation Guide to install Node before running this installer.
	GOTO :EXIT
)
ECHO.

ECHO [Bastion]: Installing system files...
CD /D %USERPROFILE%\Desktop
git clone -b master -q --depth 1 https://github.com/snkrsnkampa/Bastion.git >nul 2>&1 || (ECHO [Bastion]: Unable to download Bastion System files. Check your internet connection. && GOTO :EXIT)

::TODO: Find a way to show a message when npm install fails.
CD Bastion && CALL npm install >nul 2>&1
npm install -g windows-build-tools >nul 2>&1 || (ECHO [Bastion]: Unable to install windows-build-tools. Check your internet connection or ask for help in Bastion help server https://discord.gg/fzx8fkt. && GOTO :EXIT)
ECHO [Bastion]: System files successfully installed.

ECHO [Bastion]: Verifying ffmpeg installation...
ffmpeg >nul 2>&1 && ECHO [Bastion]: ffmpeg is already installed. Looks good. || (
	TITLE [ERROR] ffmpeg Not Found
	ECHO [Bastion]: ffmpeg is not installed in your computer.
	IF "%BIT%" == "x64" (
		wget https://sankarsankampa.com/download/ffmpeg/win/x64/ffmpeg.exe >nul 2>&1
	) ELSE (
		wget https://sankarsankampa.com/download/ffmpeg/win/x86/ffmpeg.exe >nul 2>&1
	)
)
ECHO.

ECHO [Bastion]: Finalizing...
CD settings && COPY config_example.json config.json && COPY credentials_example.json credentials.json
ECHO.
ECHO [Bastion]: Do you want to setup your credentials now?
CHOICE /m "[User]: "
IF %ERRORLEVEL%==2 GOTO :CREDENTIALS
ECHO [Bastion]: Please enter the BOT ID
SET /P botId="[User]: "
ECHO [Bastion]: Please enter the BOT Token
SET /P token="[User]: "
ECHO [Bastion]: Please enter the Owner ID
SET /P ownerID="[User]: "
:CREDENTIALS
(
	ECHO {
	ECHO   "botId": "%botID%",
	ECHO   "token": "%token%",
	ECHO   "ownerId": [
	ECHO     "%ownerID%"
	ECHO   ]
	ECHO }
) > credentials.json
ECHO [Bastion]: Done. \o/
ECHO.
SET prefix=bas?
SET status=online
SET game=with servers
ECHO [Bastion]: Do you want to configure your BOT now?
CHOICE /m "[User]: "
IF %ERRORLEVEL%==2 GOTO :CONFIG
ECHO [Bastion]: What should be the commands' prefix? [Default: bas?]
SET /P prefix="[User]: "
ECHO [Bastion]: What should be the BOT's status? [Default: online]
ECHO [Bastion]: [online / idle / dnd / invisible]
SET /P status="[User]: "
ECHO [Bastion]: What should be the BOT's game? [Default: with servers]
SET /P game="[User]: "
:CONFIG
(
	ECHO {
	ECHO   "prefix": "%prefix%",
	ECHO   "status": "%status%",
	ECHO   "game": "%game%"
	ECHO }
) > config.json
ECHO [Bastion]: Done. \o/
ECHO.

ECHO [Bastion]: System Initialized. O7
ECHO [Bastion]: Ready to boot up and start running.
EXIT /B 0

:EXIT
ECHO.
ECHO [Bastion]: Press any key to exit.
PAUSE >nul 2>&1
CLS
CD /D "%cwd%"
TITLE Windows Command Prompt (CMD)
COLOR
