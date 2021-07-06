@REM Rime UserDB Scrape 0.1.0
@REM 2021-09-13
@REM https://lxvs.net/cloudconf

@echo off
setlocal
chcp 65001 1>nul

@set "cRed=[91m"
@set "cGrn=[92m"
@set "cYlw=[93m"
@set "cSuf=[0m"

if not defined syncid (
    @echo %cYlw%userdbTxt not defined, work as standalone mode.%cSuf%
    goto standalone
)

for /f "usebackq" %%i in ("%userdbTxt%") do (
    if exist "%rimeDir%\sync\%syncid%\%%~i" (
        if exist "%%~i" del "%%~i"
        >"%%~i" (
            for /f "usebackq eol= delims=" %%I in ("%rimeDir%\sync\%syncid%\%%~i") do @echo %%I
        )
    ) else @echo %cYlw%WARNING: Could not find: %rimeDir%\sync\%syncid%\%%i%cSuf%
)

exit /b

:standalone
if "%~1" == "" goto help
if not exist "%~1" goto help
if "%~z1" == "0" exit /b
set "userdb=%~nx1"
pushd %~dp1
copy /y "%userdb%" "%TEMP%\%userdb%" 1>nul
>"%userdb%" (
    for /f "usebackq eol= delims=" %%I in ("%TEMP%\%userdb%") do @echo %%I
)
del "%TEMP%\%userdb%" 1>nul
exit /b

:help
exit /b
