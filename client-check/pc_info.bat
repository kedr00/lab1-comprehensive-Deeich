@echo off
chcp 65001 >nul
title Diagnostics

set "REPORT=%~dp0pc_report.txt"
echo Diagnostics > "%REPORT%"
echo ============================== >> "%REPORT%"
echo. >> "%REPORT%"

echo OS Information:
echo OS Information: >> "%REPORT%"
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" >> "%REPORT%"
systeminfo | findstr /B /C:"OS Name" /C:"OS Version"

echo.
echo Processor:
echo Processor: >> "%REPORT%"
wmic cpu get name /value | findstr /C:"Name" >> "%REPORT%"
wmic cpu get name /value | findstr /C:"Name"

echo.
echo Memory:
echo Memory: >> "%REPORT%"
wmic OS get TotalVisibleMemorySize /value | findstr /C:"=" >> "%REPORT%"
wmic OS get TotalVisibleMemorySize /value | findstr /C:"="

echo.
echo Disk C:
echo Disk C: >> "%REPORT%"
dir C:\ | findstr /C:"bytes free" >> "%REPORT%"
dir C:\ | findstr /C:"bytes free"

echo.
echo Installed Programs:
echo Installed Programs: >> "%REPORT%"
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2>nul | findstr /I "DisplayName" >> "%REPORT%"
reg query "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2>nul | findstr /I "DisplayName" >> "%REPORT%"
echo Look in pc_report.txt for full list.

echo.
echo Report saved.
echo Report saved. >> "%REPORT%"
pause
