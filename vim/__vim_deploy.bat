@REM v0.2.0
@REM 2022-07-06
@REM https://lxvs.net/cloudconf

@echo off
@setlocal EnableExtensions EnableDelayedExpansion

@set "batchname=%~nx0"
@set "batchfolder=%~dp0"
@if "%batchfolder:~-1%" == "\" set "batchfolder=%batchfolder:~0,-1%"
net session 1>nul 2>&1 || goto UacPrompt

set "dirTxt=cloudconf-vim-dir.txt"
set "gitDirTxt=cloudconf-vim-gitdir.txt"

@set "cRed=[91m"
@set "cGrn=[92m"
@set "cYlw=[93m"
@set "cSuf=[0m"

@echo;
@echo     %cYlw%Vim%cSuf%
@echo;

pushd %~dp0

if not defined vimDir (
    if exist "%dirTxt%" (
        call:GetPathFromText "%dirTxt%" vimDir
    ) else if exist "%ProgramFiles%\Vim" (
        set "vimDir=%ProgramFiles%\Vim"
        @echo %cYlw%warning: vimDir not specified, using `!vimDir!'%cSuf%
    ) else (
        >&2 echo %cRed%error: Please specify vimDir in file `%dirTxt%'%cSuf%
        pause
        popd
        exit /b 1
    )
)

if not defined gitDir (
    if exist "%gitDirTxt%" (
        call:GetPathFromText "%gitDirTxt%" gitDir
    ) else if exist "%ProgramFiles%\Git" (
        set "gitDir=%ProgramFiles%\Git"
        @echo %cYlw%warning: gitDir not specified, using `!gitDir!'%cSuf%
    ) else (
        >&2 echo %cYlw%warning: gitDir not found, skipped%cSuf%
    )
)

if "%vimDir:~-1%" == "\" set "vimDir=%vimDir:~0,-1%"

for /f %%i in ('dir /b /ad /o-d "%vimDir%" 2^>nul') do (
    if not defined vimVer (set "vimVer=%%~i")
)
if not defined vimVer (
    >&2 echo %cRed%error: failed to determin vim version%cSuf%
    pause
    popd
    exit /b 1
)

if defined gitDir (
    for /f %%i in ('dir /b /ad /o-d "%gitDir%\usr\share\vim" 2^>nul') do (
        if not defined gitVimVer (set "gitVimVer=%%~i")
    )
    if not defined gitVimVer (
        set gitDir=
        >&2 echo %cYlw%warning: failed to determin vim version of Git, skipped%cSuf%
    )
)

if not defined vimrc set "vimrc=_vimrc"
if not defined myvimrc set "myvimrc=%vimDir%\_vimrc"
if not defined vimHome set "vimHome=%vimDir%\%vimVer%"
if defined gitDir (
    if not defined gitvimrc set "gitvimrc=%gitDir%\etc\vimrc"
    if not defined gitVomHome set "gitVimHome=%gitDir%\usr\share\vim\%gitVimVer%"
)

for %%i in ("%vimrc%") do if exist "%%~fi" (
    if exist "%myvimrc%" del "%myvimrc%"
    mklink "%myvimrc%" "%%~fi" 1>nul
    if defined gitDir (
        if exist "%gitvimrc%" del "%gitvimrc%"
        mklink "%gitvimrc%" "%%~fi" 1>nul
    )
)

for /f %%i in ('dir /b /a-d *.vim 2^>nul') do (
    if exist "%vimHome%\%%~i" del "%vimHome%\%%~i"
    mklink "%vimHome%\%%~i" "%%~fi" 1>nul
    if defined gitDir (
        if exist "%gitVimHome%\%%~i" del "%gitVimHome%\%%~i"
        mklink "%gitVimHome%\%%~i" "%%~fi" 1>nul
    )
)

for /f %%i in ('dir /b /ad-h 2^>nul') do if not "%%~i" == ".git" (
    pushd "%%~i"
    for /f %%j in ('dir /b /a-d *.vim 2^>nul') do (
        if exist "%vimHome%\%%~i\%%~j" del "%vimHome%\%%~i\%%~j"
        mklink "%vimHome%\%%~i\%%~j" "%%~fj" 1>nul
        if defined gitDir (
            if exist "%gitVimHome%\%%~i\%%~j" del "%gitVimHome%\%%~i\%%~j"
            mklink "%gitVimHome%\%%~i\%%~j" "%%~fj" 1>nul
        )
    )
    popd
)

if exist "pack\" (
    if exist "%USERPROFILE%\vimfiles\pack\cloudconf" (
        rmdir "%USERPROFILE%\vimfiles\pack\cloudconf" || (
            pause
            exit /b 1
        )
    ) else if not exist "%USERPROFILE%\vimfiles\pack\" (
        mkdir "%USERPROFILE%\vimfiles\pack"
    )
    mklink /d "%USERPROFILE%\vimfiles\pack\cloudconf" "%cd%\pack" 1>nul
    if defined gitDir (
        if exist "%gitVimHome%\pack\cloudconf" (
            rmdir "%gitVimHome%\pack\cloudconf" || (
                pause
                exit /b 1
            )
        ) else if not exist "%gitVimHome%\pack\" (
            mkdir "%gitVimHome%\pack"
        )
        mklink /d "%gitVimHome%\pack\cloudconf" "%cd%\pack" 1>nul
    )
)

@echo %cGrn%Completed.%cSuf%
popd
if /i "%~1" NEQ "nopause" pause
exit /b

:uacPrompt
@echo;
@echo     Requesting Administrative Privileges...
@echo     Press YES in UAC Prompt to Continue
@echo;
@>"%TEMP%\UacPrompt.vbs" (
echo Set UAC = CreateObject^("Shell.Application"^)
echo args = "ELEV "
echo For Each strArg in WScript.Arguments
echo args = args ^& strArg ^& " "
echo Next
echo UAC.ShellExecute "%batchname%", args, "%batchfolder%", "runas", 1
)
@cscript //nologo "%TEMP%\UacPrompt.vbs"
@del /f "%TEMP%\UacPrompt.vbs"
@exit /b

:GetPathFromText
if "%~1" == "" exit /b 1
if "%~2" == "" exit /b 2
for /f "usebackq delims=" %%i in ("%~1") do if not defined %2 (
    set "folderPath=%%~i"
    call set "folderPath=!folderPath!"
    for %%j in ("!folderPath!\") do (
        if exist "%%~fj" (
            set "%2=%%~fj"
        ) else (
            >&2 echo %cRed%error: Directory does not exist: `%%~j'%cSuf%
            pause
            popd
            exit /b 1
        )
    )
)
exit /b
