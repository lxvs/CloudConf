@REM Sync User DB 0.1.0
@REM 2021-09-24
@REM https://lxvs.net/cloudconf

@echo off
pushd %~dp0
call "%cd%\__rime_deploy.bat" syncuserdb
popd
