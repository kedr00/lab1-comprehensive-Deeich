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
for /f "tokens=2 delims==" %%A in ('wmic OS get TotalVisibleMemorySize /value ^| find "="') do set /a total_mem=%%A/1048576
for /f "tokens=2 delims==" %%A in ('wmic OS get FreePhysicalMemory /value ^| find "="') do set /a free_mem=%%A/1048576
echo Total Memory: %total_mem% GB >> "%REPORT%"
echo Free Memory: %free_mem% GB >> "%REPORT%"
echo Total Memory: %total_mem% GB
echo Free Memory: %free_mem% GB

echo.
echo Disk C:
echo Disk C: >> "%REPORT%"
for /f "tokens=2 delims==" %%A in ('wmic logicaldisk where "DeviceID='C:'" get Size /value ^| find "="') do set /a total_disk=%%A/1073741824
for /f "tokens=2 delims==" %%A in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace /value ^| find "="') do set /a free_disk=%%A/1073741824
echo Total Space: %total_disk% GB >> "%REPORT%"
echo Free Space: %free_disk% GB >> "%REPORT%"
echo Total Space: %total_disk% GB
echo Free Space: %free_disk% GB

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
