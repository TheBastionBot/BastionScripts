@ECHO off
IF NOT DEFINED IS_CHILD_PROCESS (CMD /K SET IS_CHILD_PROCESS=1 ^& %0 %*) & EXIT )
CLS
COLOR 0F
SET cwd=%~dp0

NET SESSION >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
	TITLE Bastion Installer
) ELSE (
  TITLE [ERROR] Permission Denied
  ECHO [Bastion]: Bastion Bot Installer requires Administrator permissions. Run this installer as Administrator.
  GOTO :EXIT
)

FOR /F "usebackq tokens=1,2 delims==" %%i IN (`wmic os get LocalDateTime /VALUE 2^>NUL`) DO IF '.%%i.'=='.LocalDateTime.' SET ldt=%%j
SET ldt=%ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2% %ldt:~8,2%:%ldt:~10,2%:%ldt:~12,6%
ECHO [ %ldt% ]
ECHO [Bastion]: Bastion Bot Installer
ECHO [Bastion]: Starting Installer...
ECHO.

ECHO [Bastion]: Initializing System...
CD /D %USERPROFILE%\Desktop
RD /S /Q Bastion-Old 2>nul
MOVE /Y Bastion Bastion-Old >nul 2>&1
ECHO.

ECHO [Bastion]: Verifying Chocolatey installation...
choco --version >nul 2>&1 && ECHO [Bastion]: Chocolatey is already installed. Looks good. || (
  ECHO [Bastion]: Chocolatey is not installed.
  ECHO [Bastion]: Installing Chocolatey...
  @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
  CALL refreshenv
)
ECHO.

ECHO [Bastion]: Verifying Git installation...
git --version >nul 2>&1 && ECHO [Bastion]: Git is already installed. Looks good. || (
  ECHO [Bastion]: Git is not installed.
  ECHO [Bastion]: Installing Git...
  choco install git.install -y
  CALL refreshenv
)
ECHO.

ECHO [Bastion]: Verifying Node installation...
node --version >nul 2>&1 && ECHO [Bastion]: Node is already installed. Looks good. || (
  ECHO [Bastion]: Node is not installed.
  ECHO [Bastion]: Installing Node...
  choco install nodejs-lts -y
  CALL refreshenv
)
ECHO.

ECHO [Bastion]: Installing system files...
git clone -b master -q --depth 1 https://github.com/TheBastionBot/Bastion.git >nul 2>&1 || (ECHO [Bastion]: Unable to download Bastion System files. Check your internet connection. && GOTO :EXIT)

::TODO: Find a way to show a message when npm install fails.
CD Bastion && CALL npm install --only=production --no-optional --no-package-lock >nul 2>&1
CALL npm install -g windows-build-tools >nul 2>&1 || (ECHO [Bastion]: Unable to install windows-build-tools. Check your internet connection or ask for help in Bastion help server https://discord.gg/fzx8fkt. && GOTO :EXIT)
ECHO [Bastion]: System files successfully installed.

ECHO [Bastion]: Verifying FFmpeg installation...
ffmpeg -h >nul 2>&1 && ECHO [Bastion]: FFmpeg is already installed. Looks good. || (
  ECHO [Bastion]: FFmpeg is not installed.
  ECHO [Bastion]: Installing FFmpeg...
  choco install ffmpeg -y
  CALL refreshenv
)
ECHO.

ECHO [Bastion]: Finalizing...
ECHO.

ECHO [Bastion]: Do you want to setup your credentials now?
CHOICE /m "[User]: "
IF %ERRORLEVEL%==2 GOTO :CREDENTIALS
ECHO [Bastion]: Please enter the Bot ID
SET /P botId="[User]: "
ECHO [Bastion]: Please enter the Bot Token
SET /P token="[User]: "
ECHO [Bastion]: Please enter the Owner ID
SET /P ownerID="[User]: "
ECHO [Bastion]: Please enter your Google API Key
SET /P gAPIkey="[User]: "
ECHO [Bastion]: Please enter your Twitch API Client ID
SET /P twitchClientID="[User]: "
ECHO [Bastion]: Please enter your Twitch API Client Secret
SET /P twitchClientSecret="[User]: "
ECHO [Bastion]: Please enter your PUBG Tracker Network API Key
SET /P PUBGAPIKey="[User]: "
ECHO [Bastion]: Please enter your Bungie API Key
SET /P bungieAPIKey="[User]: "
ECHO [Bastion]: Please enter your Fortnite Tracker API Key
SET /P fortniteAPIKey="[User]: "
ECHO [Bastion]: Please enter your Battlefield Tracker Network API Key
SET /P battlefieldAPIKey="[User]: "
ECHO [Bastion]: Please enter your HiRez API DevID
SET /P HiRezDevId="[User]: "
ECHO [Bastion]: Please enter your HiRez API AuthKey
SET /P HiRezAuthKey="[User]: "
ECHO [Bastion]: Please enter your The Movie Database API Key
SET /P theMovieDBApiKey="[User]: "
ECHO [Bastion]: Please enter your Musixmatch API Key
SET /P musixmatchAPIKey="[User]: "
ECHO [Bastion]: Please enter your Cleverbot API Key
SET /P chatAPIkey="[User]: "
:CREDENTIALS
(
  ECHO {
  ECHO   "botId": "%botID%",
  ECHO   "token": "%token%",
  ECHO   "ownerId": [
  ECHO     "%ownerID%"
  ECHO   ],
	ECHO   "webhooks": {
	ECHO      "bastionLog": ""
	ECHO    },
  ECHO   "googleAPIkey": "%gAPIkey%",
  ECHO   "twitchClientID": "%twitchClientID%",
  ECHO   "twitchClientSecret": "%twitchClientSecret%",
  ECHO   "bungieAPIKey": "%bungieAPIKey%",
  ECHO   "PUBGAPIKey": "%PUBGAPIKey%",
  ECHO   "battlefieldAPIKey": "%battlefieldAPIKey%",
  ECHO   "fortniteAPIKey": "%fortniteAPIKey%",
  ECHO   "HiRezDevId": "%HiRezDevId%",
  ECHO   "HiRezAuthKey": "%HiRezAuthKey%",
  ECHO   "theMovieDBApiKey": "%theMovieDBApiKey%",
  ECHO   "musixmatchAPIKey": "%musixmatchAPIKey%",
  ECHO   "cleverbotAPIkey": "%chatAPIkey%"
  ECHO }
) > settings\credentials.json
ECHO [Bastion]: Done.
ECHO.

SET prefix=#!
SET status=online
SET game=with servers
ECHO [Bastion]: Do you want to configure your Bot now?
CHOICE /m "[User]: "
IF %ERRORLEVEL%==2 GOTO :CONFIG
ECHO [Bastion]: What should be the commands' prefix? [Default: bas?]
SET /P prefix="[User]: "
ECHO [Bastion]: What should be the Bot's status? [Default: online]
ECHO [Bastion]: [online / idle / dnd / invisible]
SET /P status="[User]: "
ECHO [Bastion]: What should be the Bot's game? [Default: with servers]
SET /P game="[User]: "
:CONFIG
(
  ECHO {
  ECHO   "shardCount": 1,
  ECHO   "prefix": "%prefix%",
  ECHO   "status": "%status%",
  ECHO   "game": "%game%",
  ECHO   "musicStatus": true
  ECHO }
) > settings\config.json
ECHO [Bastion]: Done.
ECHO.

ECHO [Bastion]: System Initialized. O7
ECHO [Bastion]: Ready to boot up and start running.

:EXIT
ECHO.
ECHO [Bastion]: Press any key to exit.
PAUSE >nul 2>&1
CLS
CD /D "%cwd%"
TITLE Windows Command Prompt (CMD)
COLOR
