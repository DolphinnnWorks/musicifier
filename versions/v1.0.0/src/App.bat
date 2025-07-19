@echo off
@mode con: cols=65 lines=20
@chcp 437 >nul

if not defined _HIGH_PRIORITY_SET (
    set "_HIGH_PRIORITY_SET=1"
    start "" /HIGH "%~f0"
    exit /b
)

set CurrentPosition=1
set OnlineCache=.\AppConfig\OnlineCache
set "OnlineMainPage=https://raw.githubusercontent.com/I-dont-know-what-to-put/musicifier/refs/heads/main/onlinelibrary"
set "OnlineDownloadLink=%OnlineMainPage%/infofiles/max.txt"

set DefaultVolume=100
set DefaultRepeat=False

goto MainMenu

:MainMenu
@color 0A
@chcp 65001 >nul
@title Musicifier ♫
cls
echo.
echo  Welcome To Musicifier ♫!
echo.
echo  1.) Play Music
echo  2.) Settings
echo  3.) Help
choice /c 123 >nul
if %errorlevel% == 1 (
    goto MusicChoose
)
if %errorlevel% == 2 (
    goto Settings
)
if %errorlevel% == 3 (
    goto Help
)
goto Err000002


:: HELP & SETTINGS

:Help
cls
echo.
echo  Music Controls:
echo    V -^> Change Volume
echo    R -^> Switch To Dont Repeat / Repeat / Repeat One Music
echo    Q -^> Go Back To The Previous Music
echo    E -^> Go To The Next Music
echo    A -^> Backward 10s
echo    D -^> Forward 10s
echo    P -^> Toggle Pause
echo    M -^> Return To Main Menu
echo.
echo  Press Any Key To Continue.
pause >nul
cls
echo.
echo  Online Library Navigation Controls:
echo    Q -^> Previous ID
echo    E -^> Next ID
echo    D -^> Play/Download Music
echo    J -^> Jump To ID
echo    M -^> Return To Main Menu
echo.
echo  Press Any Key To Return To Main Menu
pause >nul
goto MainMenu

:Settings
cls
echo.
echo  Settings
echo  1.) Check Cache
echo  2.) Publish Music
echo  3.) License
echo.
echo  M -^> Return
choice /c m123 >nul
if %errorlevel% == 1 ( goto MainMenu )
if %errorlevel% == 2 ( goto Settings_Cache )
if %errorlevel% == 3 ( start https://forms.gle/oFn7o2Pb2DHgXm2a6 )
if %errorlevel% == 4 ( start License.txt )
goto Settings

:Settings_Cache
for /f "delims=" %%i in ('cscript //nologo CacheSizeCalculator.vbs .\') do set size=%%i
cls
echo.
echo  Settings -^> Cache
echo.
echo  Cache Size: %size%
echo  1.) Delete Cache
echo.
echo  M -^> Return
choice /c m1 >nul
if %errorlevel% == 2 (
    goto Settings_Cache_Removal
)
goto MainMenu

:Settings_Cache_Removal
cls
echo.
echo  Are you sure you want to do this?
echo  You may lose cached music from playlists.
echo.
echo  ^(Y/N^)?
choice /c yn >nul
if %errorlevel% == 2 ( goto Settings_Cache )
cls
echo.
echo  Deleting Cache Please Wait...
echo  [          ]
del /f /q ".\AppConfig\OnlineCache"
timeout /t 0 /nobreak >nul
cls
echo.
echo  Deleting Cache Please Wait...
echo  [oooo      ]
del /f /q ".\AppConfig\MusicCache"
timeout /t 0 /nobreak >nul
cls
echo.
echo  Deleting Cache Please Wait...
echo  [ooooooooo ]
timeout /t 0 /nobreak >nul
cls
echo.
echo  Finalizing...
echo  [oooooooooo]
timeout /t 0 /nobreak >nul
cls
echo.
echo  Completed!
echo  [oooooooooo]
echo.
echo  Press any key or wait 3 seconds to go back.
timeout /t 3 >nul
goto Settings_Cache

:: MUSIC CHOOSING

:MusicChoose
cls
echo.
echo  What music do you want to play?
echo  1.) Choose a file from your computer
echo  2.) Musicifier Online Library (WIP!)
echo.
echo  M -^> Return
choice /c 12M >nul
if %errorlevel% == 1 (
    goto MusicChoose_SelectFile
)
if %errorlevel% == 2 (
    goto OnlineLibrary_ChooseMusic
)
if %errorlevel% == 3 (
    goto MainMenu
)
goto Err000002

:MusicChoose_SelectFile
@chcp 437 >nul
@title Musicifier ^(...^)
cls
echo.
echo  Choose a file from your computer.
for /f "delims=" %%f in ('powershell -ExecutionPolicy Bypass -File select_musicifierfiles.ps1') do set filepath=%%f
for %%F in ("%filepath%") do set filename=%%~nxF
@chcp 65001 >nul
@title Musicifier ♫
if "%filepath%" == "unknownfile" (
    cls
    echo.
    echo  Operation Canceled.
    timeout /t 3 >nul
    goto MusicChoose
)
copy "%filepath%" ".\AppConfig\MusicCache\" >nul
if exist .\AppConfig\default_player_settings.txt (
    < .\AppConfig\default_player_settings.txt (
        set /p DefaultVolume=
        set /p DefaultRepeat=
    )
)
setlocal EnableDelayedExpansion
(
    echo !filename!
    echo !DefaultVolume!
    echo Okay
    echo !DefaultRepeat!
    echo Okay
)> .\Player\mus_data.txt
endlocal
cd .\Player
call Main.bat


:: ONLINE LIBRARY

set OnlineTitle=Unknown
set OnlineAuthor=Unknown
set OnlineDuration=0:00
set OnlinePublisher=Unknown:Unknown

:OnlineLibrary_Download
@chcp 437 >nul
@title Musicifier ^(...^)
cls
echo.
echo  Downloading from the online library...
powershell -Command "Start-BitsTransfer -Source '%OnlineLinkMusicifierFile%' -Destination .\AppConfig\OnlineCache\mus_online_info.txt" >nul

setlocal EnableDelayedExpansion
set i=0
for /f "usebackq delims=" %%a in (".\AppConfig\OnlineCache\mus_online_info.txt") do (
    set /a i+=1
    if !i! == 1 set "_OnlineTitle=%%a"
    if !i! == 2 set "_OnlineAuthor=%%a"
    if !i! == 3 set "_OnlineDuration=%%a"
    if !i! == 4 set "_OnlinePublisher=%%a"
)
endlocal & (
    set "OnlineTitle=%_OnlineTitle%"
    set "OnlineAuthor=%_OnlineAuthor%"
    set "OnlineDuration=%_OnlineDuration%"
    set "OnlinePublisher=%_OnlinePublisher%"
)
if "%OnlineTitle%"=="404: Not Found" (
    goto HTML404
)
exit /b

:OnlineLibrary_ChooseMusic
set "OnlineLinkMusicifierFile=%OnlineMainPage%/infofiles/%CurrentPosition%.txt"
call :OnlineLibrary_Download
if "%OnlineTitle%"=="batscript:endmax" (
    set "CurrentPosition=1"
    goto :OnlineLibrary_ChooseMusic
)
cls
@chcp 65001 >nul
@title Musicifier ♫ -  Online Library: %OnlineTitle%
echo.
echo  %OnlineTitle%: %OnlineAuthor%
echo  Publisher: %OnlinePublisher%
echo  0:00 - %OnlineDuration%
echo  ^< Q -%CurrentPosition%- E ^>
echo.
echo  M - Menu
echo  D - Download
echo  J - Jump To
choice /c MQEDJ >nul
if %errorlevel%==1 goto :MainMenu
if %errorlevel%==2 set /a CurrentPosition-=1
if %errorlevel%==3 set /a CurrentPosition+=1
if %errorlevel%==4 goto OnlineLibrary_DownloadMusic
if %errorlevel%==5 (
    echo.
    set /p CurrentPosition=Jump To?: 
    goto OnlineLibrary_ChooseMusic
)
if %CurrentPosition% LEQ 0 (
    @chcp 437 >nul
    @title Musicifier ^(...^)
    cls
    echo.
    echo  Downloading from the online library...
    powershell -Command "Start-BitsTransfer -Source '%OnlineMainPage%/infofiles/max.txt' -Destination .\AppConfig\OnlineCache\max.txt" >nul
    < .\AppConfig\OnlineCache\max.txt (
        set /p CurrentPosition=
    )
)
goto OnlineLibrary_ChooseMusic

:OnlineLibrary_DownloadMusic
@chcp 437 >nul
@title Musicifier ^(...^)
cls
echo.
echo  Downloading Music...
if not exist ".\AppConfig\OnlineCache\%OnlineTitle% - %OnlineAuthor%.mp3" (
    powershell -Command "Start-BitsTransfer -Source '%OnlineMainPage%/musicfiles/%CurrentPosition%.txt' -Destination '.\AppConfig\OnlineCache\%OnlineTitle% - %OnlineAuthor%.mp3'" >nul
    if %errorlevel%==1 (
        goto Err000003
    )
)
copy ".\AppConfig\OnlineCache\%OnlineTitle% - %OnlineAuthor%.mp3" ".\AppConfig\MusicCache\%OnlineTitle% - %OnlineAuthor%.mp3"
if exist .\AppConfig\default_player_settings.txt (
    < .\AppConfig\default_player_settings.txt (
        set /p DefaultVolume=
        set /p DefaultRepeat=
    )
)
(
    echo %OnlineTitle% - %OnlineAuthor%.mp3
    echo %DefaultVolume%
    echo Okay
    echo %DefaultRepeat%
    echo Okay
)> .\Player\mus_data.txt
cd .\Player
call Main.bat


:: ERROR SCREENS

:HTML404
@color 0C
@chcp 65001 >nul
@title 404: Page Not Found
cls
echo.
echo  404: Page Not Found
echo.
echo  Press any key to go back to Main menu
pause >nul
set "CurrentPosition=1"
goto MainMenu

:Err000003
@color 0C
@chcp 65001 >nul
@title Musicifier (×) - Error ^> Download Failed (Err000003)
cls
echo.
echo  Download failed; possible issue that the user has no
echo  internet.
echo  Tried to access the website below but returned an error.
echo  URL:
echo    %OnlineDownloadLink%
echo.
echo  If you think this is a mistake; open the URL.
echo  If the URL does not help you at all please report this
echo  as a bug.
echo.
echo  Press any key to go back to Main menu
pause >nul
goto MainMenu

:Err000002
@color 0C
@chcp 65001 >nul
@title Musicifier (×) - Error ^> No Response (Err000002)
cls
echo.
echo  The action you had done returned with no response.
echo  If the issue persists report this as a bug.
echo.
echo  Press any key to exit the application.
pause >nul
exit
