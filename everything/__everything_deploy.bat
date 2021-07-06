@REM v0.0.1
@REM 2021-07-06
@REM https://lxvs.net/cloudconf

@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "batchname=%~nx0"
set "batchfolder=%~dp0"
if "%batchfolder:~-1%" == "\" set "batchfolder=%batchfolder:~0,-1%"

set "dirTxt=cloudconf-everything-dir.txt"

@set "cRed=[91m"
@set "cGrn=[92m"
@set "cYlw=[93m"
@set "cSuf=[0m"

@echo;
@echo     %cYlw%Everything%cSuf%
@echo;

pushd %~dp0

@if not defined everythingDir (
    if exist "%dirTxt%" (
        for /f "usebackq delims=" %%i in ("%dirTxt%") do if not defined everythingDir (
            set "folderPath=%%~i"
            call set "folderPath=!folderPath!"
            for %%j in ("!folderPath!\") do (
                if exist "%%~fj" (
                    set "everythingDir=%%~fj"
                ) else (
                    >&2 echo %cRed%ERROR: Invalid definition of everythingDir: %%j%cSuf%
                    pause
                    popd
                    exit /b 1
                )
            )
        )
    ) else if exist "%APPDATA%\Everything" (
        set "everythingDir=%APPDATA%\everything"
        >&2 echo %cYlw%Warning: everythingDir not specified, using !everythingDir!%cSuf%
    ) else (
        >&2 echo %cRed%ERROR: Please specify everythingDir in file %dirTxt%%cSuf%
        pause
        popd
        exit /b 2
    )
)

if "%everythingDir:~-1%" == "\" set "everythingDir=%everythingDir:~0,-1%"

if not defined everything_ini set "everything_ini=everything.ini"

if exist "%cd%\%everything_ini%" (
    if exist "%everythingDir%\%everything_ini%" del /f "%everythingDir%\%everything_ini%"
    copy "%cd%\%everything_ini%" "%everythingDir%\%everything_ini%"
) else (
    >&2 echo %cRed%ERROR: %everything_ini% does not exist.%cSuf%
    popd
    pause
    exit /b 3
)

@echo %cGrn%Completed.%cSuf%
popd
if /i "%~1" NEQ "nopause" pause
exit /b
