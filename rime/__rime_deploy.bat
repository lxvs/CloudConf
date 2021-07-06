@REM v0.3.1
@REM 2021-09-22
@REM https://lxvs.net/cloudconf

@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 1>nul

set "batchname=%~nx0"
set "batchfolder=%~dp0"
if "%batchfolder:~-1%" == "\" set "batchfolder=%batchfolder:~0,-1%"

set "dirTxt=cloudconf-rime-dir.txt"
set "copyTxt=cloudconf-rime-list-copy.txt"
set "mklinkTxt=cloudconf-rime-list-mklink.txt"
set "userdbTxt=cloudconf-rime-list-userdb.txt"

@set "cRed=[91m"
@set "cGrn=[92m"
@set "cYlw=[93m"
@set "cSuf=[0m"

@echo;
@echo     %cYlw%rime%cSuf%
@echo;

pushd %~dp0

set "userdbscrape=%cd%\_userdbscrape.bat"
if not exist "%userdbscrape%" (
    >&2 echo %cRed%ERROR: could not find userdbscrape%cSuf%
    pause
    popd
    exit /b 1
)

if not defined rimeDir (
    if exist "%dirTxt%" (
        for /f "usebackq delims=" %%i in ("%dirTxt%") do if not defined rimeDir (
            set "folderPath=%%~i"
            call set "folderPath=!folderPath!"
            for %%j in ("!folderPath!\") do (
                if exist "%%~fj" (
                    set "rimeDir=%%~fj"
                ) else (
                    >&2 echo %cRed%ERROR: Invalid definition of rimeDir: %%j%cSuf%
                    pause
                    popd
                    exit /b 1
                )
            )
        )
    ) else if exist "%APPDATA%\Rime" (
        set "rimeDir=%APPDATA%\Rime"
        >&2 echo %cYlw%WARNING: rimeDir not specified, using !rimeDir!%cSuf%
    ) else (
        >&2 echo %cRed%ERROR: Please specify rimeDir in file %dirTxt%%cSuf%
        pause
        popd
        exit /b 2
    )
)

if "%rimeDir:~-1%" == "\" set "rimeDir=%rimeDir:~0,-1%"

if exist "%copyTxt%" (
    for /f %%i in (%copyTxt%) do (
        if exist "%%i" (
            if exist "%rimeDir%\%%i" del "%rimeDir%\%%i"
            copy "%%i" "%rimeDir%\%%i"
        ) else @echo %cYlw%WARNING: Could not find: %%i%cSuf%
    )
)

if exist "%mklinkTxt%" (
    for /f %%i in (%mklinkTxt%) do (
        if exist "%%i" (
            if exist "%rimeDir%\%%i" del "%rimeDir%\%%i"
            mklink "%rimeDir%\%%i" "%cd%\%%i" || goto UacPrompt
        ) else @echo %cYlw%WARNING: Could not find: %%i%cSuf%
    )
)

if not exist "%userdbTxt%" goto finish
set "userdbSize="
for %%i in ("%userdbTxt%") do if not defined userdbSize set "userdbSize=%%~zi"
if "%userdbSize%" == "0" goto finish

set "confirmed="
@echo;
@echo %cYlw%If you would like to backup userdb, you need to sync Rime user data first.%cSuf%
set /p "confirmed=%cYlw%If you have finished data synchronization, enter YES to proceed, or enter NO to skip it: %cSuf%"
:CheckSyncComfirmation
if not defined confirmed goto finish
if /i "%confirmed%" == "no" goto finish
if /i "%confirmed%" == "yes" goto SyncUserDb
set /p "confirmed=%cYlw%Please enter YES or NO: %cSuf%"
goto CheckSyncComfirmation

:SyncUserDb
if not exist "%rimeDir%\sync" (
    >&2 echo %cRed%Couldn't find %rimeDir%\sync.%cSuf%
    pause
    popd
    exit /b 3
)

for /f %%i in ('dir /b /ad /o-d "%rimeDir%\sync"') do if not defined syncid (
    set "syncid=%%i"
)

if not defined syncid (
    >&2 echo %cRed%Nothing in folder %rimeDir%\sync.%cSuf%
    pause
    popd
    exit /b 4
)

for /f %%i in (%userdbTxt%) do (
    if exist "%%i" (
        if exist "%rimeDir%\sync\%syncid%\%%i" del "%rimeDir%\sync\%syncid%\%%i"
        copy "%%i" "%rimeDir%\sync\%syncid%\%%i"
    ) else @echo %cYlw%WARNING: Could not find: %%i%cSuf%
)

:confirmation_sync
set "confirmed="
@echo;
@echo %cYlw%Now, sync Rime data again.%cSuf%
set /p "confirmed=%cYlw%If you have finished data synchronization, enter YES: %cSuf%"
if /i not "%confirmed%" == "yes" goto confirmation_sync

call "%userdbscrape%"

:finish
@echo %cGrn%Completed!%cSuf%
popd
if /i "%~1" NEQ "nopause" pause
exit /b

:uacPrompt
@echo;
@echo     Requesting Administrative Privileges...
@echo     Press YES in UAC Prompt to Continue
@echo;
>"%TEMP%\UacPrompt.vbs" (
echo Set UAC = CreateObject^("Shell.Application"^)
echo args = "ELEV "
echo For Each strArg in WScript.Arguments
echo args = args ^& strArg ^& " "
echo Next
echo UAC.ShellExecute "%batchname%", args, "%batchfolder%", "runas", 1
)
cscript //nologo "%TEMP%\UacPrompt.vbs"
del /f "%TEMP%\UacPrompt.vbs"
exit /b
