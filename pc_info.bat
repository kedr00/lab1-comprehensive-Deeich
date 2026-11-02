@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

set "REPORT=%~dp0pc_report.txt"
set "TMPDIR=%TEMP%"
set "APPS_LIST=%TMPDIR%\apps_list.txt"
set "APPS_TMP=%TMPDIR%\apps_tmp.txt"

if exist "%APPS_LIST%" del /q "%APPS_LIST%" >nul 2>&1
if exist "%APPS_TMP%"  del /q "%APPS_TMP%"  >nul 2>&1

> "%REPORT%" echo ============================================================
>>"%REPORT%" echo   WORKPLACE STATUS REPORT
>>"%REPORT%" echo   Generated: %DATE% %TIME%
>>"%REPORT%" echo ============================================================
>>"%REPORT%" echo.

call :log "Collecting PC information..."
call :log ""

call :log "--- System Information ---"
set "OS_NAME="
for /f "tokens=2 delims==" %%A in ('wmic os get Caption /value 2^>nul ^| find "="') do set "OS_NAME=%%A"
if not defined OS_NAME (
    call :log "Failed to get OS name."
) else (
    call :log "OS: !OS_NAME!"
)
set "CS_NAME="
for /f "tokens=2 delims==" %%A in ('wmic computersystem get Name /value 2^>nul ^| find "="') do set "CS_NAME=%%A"
if not defined CS_NAME (
    call :log "Failed to get computer name."
) else (
    call :log "Computer Name: !CS_NAME!"
)
call :log ""

call :log "--- CPU and RAM ---"
set "CPU_NAME="
for /f "tokens=2 delims==" %%A in ('wmic cpu get Name /value 2^>nul ^| find "="') do set "CPU_NAME=%%A"
if not defined CPU_NAME (
    call :log "Failed to get CPU info."
) else (
    call :log "CPU: !CPU_NAME!"
)
set "TOTAL_MEM="
for /f "tokens=2 delims==" %%A in ('wmic ComputerSystem get TotalPhysicalMemory /value 2^>nul ^| find "="') do set "TOTAL_MEM=%%A"
if not defined TOTAL_MEM (
    call :log "Failed to get RAM size."
) else (
    set /a MEM_GB=!TOTAL_MEM! / 1073741824
    call :log "RAM: !MEM_GB! GB"
)
call :log ""

call :log "--- Disks ---"
set "DISK_FOUND="
for /f "skip=1 tokens=1,2" %%A in ('wmic logicaldisk get DeviceID^,Size 2^>nul') do (
    if not "%%A"=="" if not "%%B"=="" (
        set "DISK_FOUND=1"
        set /a DISK_GB=%%B / 1073741824
        call :log "Disk %%A: !DISK_GB! GB"
    )
)
if not defined DISK_FOUND call :log "Failed to get disk info."
call :log ""

call :log "Querying registry for installed software..."
call :log ""

for /f "tokens=2*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr /i "DisplayName"') do (
    echo %%B>>"%APPS_TMP%"
)
for /f "tokens=2*" %%A in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr /i "DisplayName"') do (
    echo %%B>>"%APPS_TMP%"
)
if exist "%APPS_TMP%" (
    sort "%APPS_TMP%" /unique > "%APPS_LIST%"
    del /q "%APPS_TMP%" >nul 2>&1
)
if not exist "%APPS_LIST%" (
    call :log "Failed to generate software list."
) else (
    for /f %%C in ('type "%APPS_LIST%" ^| find /c /v ""') do call :log "Total software found: %%C"
)
call :log ""

call :log "============================================================"
call :log "  BASE OFFICE SOFTWARE RECOMMENDATIONS"
call :log "============================================================"
call :log ""

set /a BASE_CHECKED=0
set /a BASE_MISSING=0

set /a BASE_CHECKED+=1
set "FOUND="
for /f "delims=" %%L in ('type "%APPS_LIST%" 2^>nul ^| findstr /i "Office LibreOffice OpenOffice"') do set "FOUND=%%L"
if defined FOUND (
    call :log "[OK] Office Suite: !FOUND!"
) else (
    set /a BASE_MISSING+=1
    call :log "[RECOMMENDATION] Office suite not found. Install Microsoft Office or LibreOffice."
)

set /a BASE_CHECKED+=1
set "FOUND="
for /f "delims=" %%L in ('type "%APPS_LIST%" 2^>nul ^| findstr /i "Chrome Firefox Edge"') do set "FOUND=%%L"
if defined FOUND (
    call :log "[OK] Browser: !FOUND!"
    echo !FOUND! | findstr /i "Edge" >nul && call :log "     Note: Edge is a system component, its presence does not mean the PC is configured."
) else (
    set /a BASE_MISSING+=1
    call :log "[RECOMMENDATION] Browser not found. Install Google Chrome or Mozilla Firefox."
)

set /a BASE_CHECKED+=1
set "FOUND="
for /f "delims=" %%L in ('type "%APPS_LIST%" 2^>nul ^| findstr /i "Acrobat Foxit SumatraPDF"') do set "FOUND=%%L"
if defined FOUND (
    call :log "[OK] PDF Reader: !FOUND!"
) else (
    set /a BASE_MISSING+=1
    call :log "[RECOMMENDATION] PDF reader not found. Install Adobe Acrobat Reader or Foxit Reader."
)

set /a BASE_CHECKED+=1
set "FOUND="
for /f "delims=" %%L in ('type "%APPS_LIST%" 2^>nul ^| findstr /i "7-Zip WinRAR WinZip"') do set "FOUND=%%L"
if defined FOUND (
    call :log "[OK] Archiver: !FOUND!"
) else (
    set /a BASE_MISSING+=1
    call :log "[RECOMMENDATION] Archiver not found. Install 7-Zip or WinRAR to handle email attachments."
)

set /a BASE_CHECKED+=1
set "FOUND="
for /f "delims=" %%L in ('type "%APPS_LIST%" 2^>nul ^| findstr /i "Defender Kaspersky ESET Dr.Web"') do set "FOUND=%%L"
if defined FOUND (
    call :log "[OK] Antivirus: !FOUND!"
) else (
    set /a BASE_MISSING+=1
    call :log "[RECOMMENDATION] Antivirus not found. Install Kaspersky, ESET, or Dr.Web."
)
call :log ""

call :log "============================================================"
call :log "  EXCESSIVE SOFTWARE RECOMMENDATIONS (FOR REVIEW)"
call :log "============================================================"
call :log ""
call :log "Warning: this is for review, not an order to delete."
call :log ""

set /a EXTRA_FOUND=0

call :log "--- Gaming Software and Platforms ---"
set "GROUP_FOUND="
for /f "delims=" %%L in ('type "%APPS_LIST%" 2^>nul ^| findstr /i "Steam Epic Games GOG Origin Ubisoft Battle.net Riot game gaming"') do (
    call :log "  Found: %%L"
    set "GROUP_FOUND=1"
    set /a EXTRA_FOUND+=1
)
if not defined GROUP_FOUND call :log "  Not found."
call :log ""

call :log "--- Torrent Clients and File Sharing ---"
set "GROUP_FOUND="
for /f "delims=" %%L in ('type "%APPS_LIST%" 2^>nul ^| findstr /i "torrent uTorrent BitTorrent qBittorrent Vuze"') do (
    call :log "  Found: %%L"
    set "GROUP_FOUND=1"
    set /a EXTRA_FOUND+=1
)
if not defined GROUP_FOUND call :log "  Not found."
call :log ""

call :log "--- Messengers and Personal Communication ---"
set "GROUP_FOUND="
for /f "delims=" %%L in ('type "%APPS_LIST%" 2^>nul ^| findstr /i "Discord Telegram WhatsApp Viber Skype"') do (
    call :log "  Found: %%L"
    call :log "     Review: may be used as a work tool."
    set "GROUP_FOUND=1"
    set /a EXTRA_FOUND+=1
)
if not defined GROUP_FOUND call :log "  Not found."
call :log ""

call :log "--- Entertainment and Customization Tools ---"
set "GROUP_FOUND="
for /f "delims=" %%L in ('type "%APPS_LIST%" 2^>nul ^| findstr /i "Wallpaper Engine OBS Soundpad"') do (
    call :log "  Found: %%L"
    set "GROUP_FOUND=1"
    set /a EXTRA_FOUND+=1
)
if not defined GROUP_FOUND call :log "  Not found."
call :log ""

call :log "============================================================"
call :log "  SUMMARY"
call :log "============================================================"
call :log "Base software categories checked: !BASE_CHECKED!"
call :log "Base software recommendations: !BASE_MISSING!"
call :log "Excessive software found (for review): !EXTRA_FOUND!"
call :log "Report saved to: %REPORT%"
call :log ""

if exist "%APPS_LIST%" del /q "%APPS_LIST%" >nul 2>&1
if exist "%APPS_TMP%"  del /q "%APPS_TMP%"  >nul 2>&1

echo.
echo Work completed. Report saved to: %REPORT%
pause
exit /b 0

:log
set "MSG=%~1"
if not defined MSG (
    echo(
    >>"%REPORT%" echo(
) else (
    echo !MSG!
    >>"%REPORT%" echo !MSG!
)
exit /b 0
