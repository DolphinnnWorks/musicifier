@color 0B
@mode con: cols=65 lines=20
@chcp 65001 >nul
@title PIDChecker

if not exist .\pid.txt (
    @echo off
    @title PIDChecker.bat Error (×^)
    @color 0C
    cls
    echo.
    echo  Process ID (PID^) is unknown; pid.txt not found.
    timeout /t 3 /nobreak >nul
    exit
)

< .\pid.txt (
  set /p PID=
)

set mus_data_volume=UNKNOWN

:Loop
tasklist /FI "PID eq %PID%" | find "%PID%" >nul
if not exist .\pid.txt (
    goto EndSession
)
if %errorlevel%==1 ( goto EndSession )
    
if exist .\mus_data.txt (
    < .\mus_data.txt (
        set /p mus_data_filename=
        set /p mus_data_volume=
        set /p mus_data_setplaybackduration=
        set /p mus_data_repeat=
    )
)
goto Loop

:EndSession
Taskkill  /F /IM wscript.exe
if exist .\pid.txt (
    del .\pid.txt
)
if exist .\mus_info.txt (
    del .\mus_info.txt
)
if exist .\mus_data.txt (
    del .\mus_data.txt
)

if not "%mus_data_volume%" == "UNKNOWN" (
    (
        echo %mus_data_volume%
        echo %mus_data_repeat%
    )> ..\AppConfig\default_player_settings.txt
)
exit
