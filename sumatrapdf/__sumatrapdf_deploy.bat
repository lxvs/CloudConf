@REM v0.0.1
@REM 2021-07-06
@REM https://lxvs.net/cloudconf

@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "batchname=%~nx0"
set "batchfolder=%~dp0"
if "%batchfolder:~-1%" == "\" set "batchfolder=%batchfolder:~0,-1%"

set "dirTxt=cloudconf-sumatrapdf-dir.txt"

@set "cRed=[91m"
@set "cGrn=[92m"
@set "cYlw=[93m"
@set "cSuf=[0m"

@echo;
@echo     %cYlw%SumatraPDF%cSuf%
@echo;

pushd %~dp0

if not defined sumatrapdfDir (
    if exist "%dirTxt%" (
        for /f "usebackq delims=" %%i in ("%dirTxt%") do if not defined sumatrapdfDir (
            set "folderPath=%%~i"
            call set "folderPath=!folderPath!"
            for %%j in ("!folderPath!\") do (
                if exist "%%~fj" (
                    set "sumatrapdfDir=%%~fj"
                ) else (
                    >&2 echo %cRed%ERROR: Invalid definition of sumatrapdfDir: %%j%cSuf%
                    pause
                    popd
                    exit /b 1
                )
            )
        )
    ) else if exist "%LOCALAPPDATA%\SumatraPDF" (
        set "sumatrapdfDir=%LOCALAPPDATA%\SumatraPDF"
        >&2 echo %cYlw%Warning: sumatrapdfDir not specified, using !sumatrapdfDir!%cSuf%
    ) else (
        >&2 echo %cRed%ERROR: Please specify sumatrapdfDir in file %dirTxt%%cSuf%
        pause
        popd
        exit /b 2
    )
)

if "%sumatrapdfDir:~-1%" == "\" set "sumatrapdfDir=%sumatrapdfDir:~0,-1%"

if not defined sumatrapdfSettings set "sumatrapdfSettings=SumatraPDF-settings.txt"

if exist "%cd%\%sumatrapdfSettings%" (
    if exist "%sumatrapdfDir%\%sumatrapdfSettings%" del /f "%sumatrapdfDir%\%sumatrapdfSettings%"
    copy "%cd%\%sumatrapdfSettings%" "%sumatrapdfDir%\%sumatrapdfSettings%"
) else (
    >&2 echo %cRed%ERROR: Cound not found file %sumatrapdfSettings%%cSuf%
    pause
    popd
    exit /b 1
)

@echo %cGrn%Completed.%cSuf%
popd
if /i "%~1" NEQ "nopause" pause
exit /b
