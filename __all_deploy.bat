@echo off
setlocal

set "batchname=%~nx0"
set "batchfolder=%~dp0"
if "%batchfolder:~-1%" == "\" set "batchfolder=%batchfolder:~0,-1%"
fltmc 1>nul 2>&1 || goto UacPrompt

pushd %~dp0

for /f "delims=" %%i in ('dir /ad-h /b 2^>nul') do if exist "%%i\__%%i_deploy.bat" call "%%i\__%%i_deploy.bat" nopause

popd
pause
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
