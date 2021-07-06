@REM v0.0.1
@REM 2021-07-06
@REM cloudconf-getversions
@REM https://lxvs.net/cloudconf

@echo off
setlocal EnableExtensions EnableDelayedExpansion
pushd %~dp0

set warning=
type NUL > %TEMP%\getversions
for /f "delims=" %%i in ('dir /b /ad-h 2^>NUL') do (
    if exist "%%i\__%%i_deploy.bat" (
        set "name=%%i"
        set "version="
        set "update="
        set "broken="
        for /f "usebackq tokens=2" %%j in ("%%i\__%%i_deploy.bat") do if not defined broken (
            if not defined version (
                set version=%%j
            ) else if not defined update (
                set update=%%j
            ) else (
                set broken=1
            )
        )
        >>%TEMP%\getversions (echo;
        echo !name! !version!
        echo Last updated: !update!)
    ) else (
        >&2 echo Warning: __%%i_deploy.bat does not exist.
        set warning=1
    )
)
type %TEMP%\getversions | clip
del %TEMP%\getversions
popd
if defined warning pause
exit /b
