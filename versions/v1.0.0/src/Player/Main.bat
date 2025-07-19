@echo off
@color 0A
@mode con: cols=65 lines=20
@chcp 437 >nul
@title Musicifier ^(...^)

set IsPaused=0
set showEasterEgg=0

if exist .\pid.txt (
    @chcp 65001 >nul
    goto Err000001
)
powershell (Get-WmiObject Win32_Process -Filter ProcessId=$PID).ParentProcessId>pid.txt
start .\PIDCheckerRunner.vbs
@chcp 65001 >nul
if exist .\mus_data.txt (
    start SoundPlayer.vbs
    goto WaitOnMusInfo   
)
goto NoMusic

:Err000001
@color 0C
@title Musicifier ^(×^) - Error ^> Already Started ^(Err000001^)
echo.
echo  This application cannot run in multiples; close the other
echo  application. If there is no other application running then
echo  reinstall Musicifier.
echo.
echo  Press any key to refresh. 
pause >nul
@title Musicifier ^(↻^)
@color 0A
cls
echo.
echo  Refreshing...
timeout /t 1 /nobreak >nul
call Main.bat

:GetData
if exist .\mus_data.txt (
    < .\mus_data.txt (
        set /p mus_data_filename=
        set /p mus_data_volume=
        set /p mus_data_setplaybackduration=
        set /p mus_data_repeat=
        set /p mus_data_playtype=
    )
)
if exist .\mus_info.txt (
    < .\mus_info.txt (
        set /p mus_info_filename=
        set /p mus_info_musicname=
        set /p mus_info_duration=
        set /p mus_info_durationdisplay=
        set /p mus_info_playbackposition=
        set /p mus_info_playbackpositiondisplay=
    )
)
exit /b

:WaitOnMusInfo
cls
if not exist .\mus_data.txt (
    goto NoMusic
)
if exist .\mus_info.txt (
    goto Display
)
choice /t 1 /c ©m /d © >nul
if %errorlevel% == 2 (
    @color 0C
    cls
    echo.
    echo  Loading Failed.
    echo  The user has abandoned the loading screen.
    timeout /t 3 /nobreak >nul
    goto EndSession
)
goto WaitOnMusInfo

:Display
:: Set Up
@title Musicifier ♫ -^> %mus_info_filename%
if not exist .\mus_data.txt (
    goto NoMusic
)
call :GetData
:: Display
setlocal EnableDelayedExpansion
cls
echo.
if "!mus_info_musicname!" NEQ "!mus_info_filename!" (
    echo  !mus_info_filename!: !mus_info_musicname!
)
if "!mus_info_musicname!" == "!mus_info_filename!" (
    echo  !mus_info_musicname!
)
set DisplayArea=
if %IsPaused% == 0 ( set DisplayArea= ^|^| )
if %IsPaused% == 1 ( set DisplayArea= ► )
set DisplayArea=!DisplayArea!-!mus_info_playbackpositiondisplay!/!mus_info_durationdisplay!- !mus_data_volume!%%
if "!mus_data_repeat!" == "True" ( set DisplayArea=!DisplayArea! ^(R^) )
if "!mus_data_repeat!" == "Once" ( set DisplayArea=!DisplayArea! ^(R1^) )
echo !DisplayArea!

:: EASTER EGG BELOW
if !showEasterEgg! == 1 (
    set RandomSequenceArea= 
    for /L %%i in (1,1,15) do (
        set /a randNum=!RANDOM! %% 4 + 1
       if !randNum! == 1 (set RandomSequenceArea=!RandomSequenceArea!ı)
        if !randNum! == 2 (set RandomSequenceArea=!RandomSequenceArea!l)
        if !randNum! == 3 (set RandomSequenceArea=!RandomSequenceArea!ı)
        if !randNum! == 4 (set RandomSequenceArea=!RandomSequenceArea!l)
    )  
    echo !RandomSequenceArea!
)

choice /t 1 /c ©vermqadpg /d © >nul
endlocal

:: Controls
if %errorlevel% == 1 (
    goto Display
)
if %errorlevel% == 2 (
    goto VolumeChanger
)
if %errorlevel% == 3 (
    cls
    call :GetData
    setlocal EnableDelayedExpansion
    (
        echo !mus_data_filename!
        echo !mus_data_volume!
        echo 2147483647
        echo !mus_data_repeat!
        echo !mus_data_playtype!
    )> .\mus_data.txt
    endlocal
    goto Display
)
if %errorlevel% == 4 (
    call :GetData
    setlocal EnableDelayedExpansion
    (
        echo !mus_data_filename!
        echo !mus_data_volume!
        echo !mus_data_setplaybackduration!
        if %mus_data_repeat% == False (
            echo True
        )
        if %mus_data_repeat% == True (
            echo Once
        )
        if %mus_data_repeat% == Once (
            echo False
        )
        echo !mus_data_playtype!
    )> .\mus_data.txt
    endlocal
)
if %errorlevel% == 5 (
    goto EndSession
)
if %errorlevel% == 6 (
    cls
    call :GetData
    setlocal EnableDelayedExpansion
    (
        echo !mus_data_filename!
        echo !mus_data_volume!
        echo GoBackPrevious
        echo !mus_data_repeat!
        echo !mus_data_playtype!
    )> .\mus_data.txt
    endlocal
    goto Display
)
if %errorlevel% == 7 (
    setlocal EnableDelayedExpansion
    cls
    call :GetData
    set /a newPlaybackPos=!mus_info_playbackposition!-10
    (
        echo !mus_data_filename!
        echo !mus_data_volume!
        echo !newPlaybackPos!
        echo !mus_data_repeat!
        echo !mus_data_playtype!
    )> .\mus_data.txt
    endlocal
    goto Display
)
if %errorlevel% == 8 (
    setlocal EnableDelayedExpansion
    cls
    call :GetData
    set /a newPlaybackPos=!mus_info_playbackposition!+10
    (
        echo !mus_data_filename!
        echo !mus_data_volume!
        echo !newPlaybackPos!
        echo !mus_data_repeat!
        echo !mus_data_playtype!
    )> .\mus_data.txt
    endlocal
    goto Display
)
if %errorlevel% == 9 (
    call :GetData
    if "%IsPaused%" == "0" (
        set IsPaused=1
        (
            setlocal EnableDelayedExpansion
            echo !mus_data_filename!
            endlocal
            echo %mus_data_volume%
            echo %mus_data_setplaybackduration%
            echo %mus_data_repeat%
            echo 1
        )> .\mus_data.txt
    ) else (
        if "%IsPaused%" == "1" (
            set IsPaused=0
            (
                setlocal EnableDelayedExpansion
                echo !mus_data_filename!
                endlocal
                echo %mus_data_volume%
                echo %mus_data_setplaybackduration%
                echo %mus_data_repeat%
                echo 0
            )> .\mus_data.txt
        )
    )
)
if %errorlevel% == 10 (
    if %showEasterEgg% == 1 (
        set showEasterEgg=0
    )
    if %showEasterEgg% == 0 (
        set showEasterEgg=1
    )
)
goto Display

:: CONTROLS
:: V - Change Volume
:: Q - Previous Song
:: E - Next Song
:: A - Backward 10s
:: D - Forward 10s
:: R - Toggle Repeat Mode
:: P - Pause

:NoMusic
@title Musicifier ♫ -^> Unknown
cls
echo.
echo  Unknown
echo  ► -0:00/0:00- 0%%
choice /t 1 /c ©m /d © >nul
if %errorlevel% == 2 (
    goto EndSession
)
if exist .\mus_data.txt (
    start SoundPlayer.vbs
    goto WaitOnMusInfo
)
goto NoMusic

:VolumeChanger
cls
echo.
echo  -Change Volume (V)-
echo     ^<Q %mus_data_volume%%% E^>
choice /c VQE >nul
if %errorlevel% == 1 (
    < .\mus_data.txt (
        set /p mus_data_filename=
        set /p x=
        set /p mus_data_setplaybackduration=
        set /p mus_data_repeat=
    )
    setlocal EnableDelayedExpansion
    (
        echo !mus_data_filename!
        echo !mus_data_volume!
        echo !mus_data_setplaybackduration!
        echo !mus_data_repeat!
        echo !mus_data_playtype!
    )> .\mus_data.txt
    endlocal
    goto Display
)
if %errorlevel% == 2 (
    if %mus_data_volume% GTR 0 (
        set /a mus_data_volume-=1
    )
)
if %errorlevel% == 3 (
    if %mus_data_volume% LSS 100 (
        set /a mus_data_volume+=1
    )
)
< .\mus_data.txt (
        set /p mus_data_filename=
        set /p x=
        set /p mus_data_setplaybackduration=
        set /p mus_data_repeat=
)
setlocal EnableDelayedExpansion
(
    echo !mus_data_filename!
    echo !mus_data_volume!
    echo !mus_data_setplaybackduration!
    echo !mus_data_repeat!
    echo !mus_data_playtype!
)> .\mus_data.txt
endlocal
goto VolumeChanger

:EndSession
call :GetData
if exist .\pid.txt (
    del /F /Q .\pid.txt
)
cd ..
call App.bat
