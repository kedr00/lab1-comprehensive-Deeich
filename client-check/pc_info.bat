@echo off
chcp 65001 >nul
title Diagnostics and Audit

rem ===== Пути к файлам =====
set "REPORT=%~dp0pc_report.txt"
set "APPS=%TEMP%\apps_list.txt"

rem ===== Счётчики =====
set /a checked=0
set /a missing=0

rem ===== Очищаем отчёт =====
echo Diagnostics report > "%REPORT%"
echo ============================== >> "%REPORT%"

rem ===== Заголовок =====
call :log ""
call :log "=============================================="
call :log "ОТЧЁТ О ПРОВЕРКЕ КОМПЬЮТЕРА"
call :log "Дата и время: %DATE% %TIME%"
call :log "Компьютер: %COMPUTERNAME%"
call :log "Пользователь: %USERNAME%"
call :log "=============================================="

rem ===== ОС =====
call :log ""
call :log "--- Операционная система ---"
set "os_name="
for /f "tokens=2 delims==" %%A in ('wmic os get Caption /value 2^>nul ^| find "="') do set "os_name=%%A"
if defined os_name (
    call :log "ОС: %os_name%"
) else (
    call :log "ОС: получить не удалось"
)

rem ===== Процессор =====
call :log ""
call :log "--- Процессор ---"
set "cpu="
for /f "tokens=2 delims==" %%A in ('wmic cpu get Name /value 2^>nul ^| find "="') do set "cpu=%%A"
if defined cpu (
    call :log "Процессор: %cpu%"
) else (
    call :log "Процессор: получить не удалось"
)

rem ===== Память =====
call :log ""
call :log "--- Память ---"
set "total_mem="
for /f "tokens=2 delims==" %%A in ('wmic OS get TotalVisibleMemorySize /value 2^>nul ^| find "="') do set "total_mem=%%A"
if defined total_mem (
    set /a total_mem_gb=%total_mem%/1048576
    call :log "Всего памяти: %total_mem_gb% ГБ"
) else (
    call :log "Всего памяти: получить не удалось"
)

set "free_mem="
for /f "tokens=2 delims==" %%A in ('wmic OS get FreePhysicalMemory /value 2^>nul ^| find "="') do set "free_mem=%%A"
if defined free_mem (
    set /a free_mem_gb=%free_mem%/1048576
    call :log "Свободно памяти: %free_mem_gb% ГБ"
) else (
    call :log "Свободно памяти: получить не удалось"
)

rem ===== Диск C =====
call :log ""
call :log "--- Диск C: ---"
set "disk_size="
for /f "tokens=2 delims==" %%A in ('wmic logicaldisk where "DeviceID='C:'" get Size /value 2^>nul ^| find "="') do set "disk_size=%%A"
if defined disk_size (
    set /a disk_size_gb=%disk_size%/1073741824
    call :log "Всего места: %disk_size_gb% ГБ"
) else (
    call :log "Всего места: получить не удалось"
)

set "disk_free="
for /f "tokens=2 delims==" %%A in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace /value 2^>nul ^| find "="') do set "disk_free=%%A"
if defined disk_free (
    set /a disk_free_gb=%disk_free%/1073741824
    call :log "Свободно места: %disk_free_gb% ГБ"
) else (
    call :log "Свободно места: получить не удалось"
)

rem ===== Список программ =====
call :log ""
call :log "Сбор списка программ (это может занять время)..."
> "%APPS%" echo.

rem 64-битные программы
for /f "tokens=2,*" %%A in ('reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr /I "DisplayName"') do (
    echo %%B>> "%APPS%"
)

rem 32-битные программы
for /f "tokens=2,*" %%A in ('reg query "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr /I "DisplayName"') do (
    echo %%B>> "%APPS%"
)

rem Сортируем и убираем повторы
sort "%APPS%" /O "%APPS%" 2>nul

call :log "Список программ собран."

rem ===== Проверка базового ПО =====
call :log ""
call :log "--- ПРОВЕРКА БАЗОВОГО ПО ---"
call :log ""

rem --- Офисный пакет ---
set /a checked+=1
findstr /i /c:"Office" /c:"LibreOffice" /c:"OpenOffice" /c:"МойОфис" "%APPS%" >nul 2>&1
if errorlevel 1 (
    set /a missing+=1
    call :log "Не обнаружен офисный пакет. Рекомендуется установить Microsoft Office, LibreOffice или МойОфис."
) else (
    call :log "Офисный пакет: требование выполнено."
)

rem --- Браузер ---
set /a checked+=1
findstr /i /c:"Chrome" /c:"Firefox" /c:"Yandex" /c:"Яндекс" /c:"Opera" "%APPS%" >nul 2>&1
if errorlevel 1 (
    set /a missing+=1
    call :log "Не обнаружен браузер. Рекомендуется установить Google Chrome, Firefox или Яндекс.Браузер."
) else (
    call :log "Браузер: требование выполнено."
)

rem --- PDF-ридер ---
set /a checked+=1
findstr /i /c:"Acrobat" /c:"Foxit" /c:"SumatraPDF" /c:"PDF24" "%APPS%" >nul 2>&1
if errorlevel 1 (
    set /a missing+=1
    call :log "Не обнаружен PDF-ридер. Рекомендуется установить Adobe Acrobat Reader, Foxit Reader или SumatraPDF."
) else (
    call :log "PDF-ридер: требование выполнено."
)

rem --- Архиватор ---
set /a checked+=1
findstr /i /c:"7-Zip" /c:"WinRAR" /c:"WinZip" /c:"PeaZip" "%APPS%" >nul 2>&1
if errorlevel 1 (
    set /a missing+=1
    call :log "Не обнаружен архиватор. Для работы с вложениями в почте рекомендуется установить 7-Zip или WinRAR."
) else (
    call :log "Архиватор: требование выполнено."
)

rem --- Антивирус ---
set /a checked+=1
findstr /i /c:"Defender" /c:"Kaspersky" /c:"ESET" /c:"Dr.Web" /c:"Avast" "%APPS%" >nul 2>&1
if errorlevel 1 (
    set /a missing+=1
    call :log "Не обнаружен антивирус. Рекомендуется установить и настроить антивирусную защиту."
) else (
    call :log "Антивирус: требование выполнено."
)

rem ===== Проверка излишнего ПО =====
call :log ""
call :log "--- ПРОВЕРКА ИЗЛИШНЕГО ПО ---"
call :log ""
call :log "Внимание: это рекомендация к проверке, а не указание к удалению."

rem --- Игры ---
call :log ""
call :log "Игровое ПО:"
findstr /i /c:"Steam" /c:"Epic Games" /c:"GOG" /c:"Origin" /c:"Ubisoft" /c:"Battle.net" /c:"Riot" "%APPS%" >nul 2>&1
if errorlevel 1 (
    call :log "  не обнаружено"
) else (
    call :log "  обнаружено (требуется проверка необходимости):"
    findstr /i /c:"Steam" /c:"Epic Games" /c:"GOG" /c:"Origin" /c:"Ubisoft" /c:"Battle.net" /c:"Riot" "%APPS%"
    findstr /i /c:"Steam" /c:"Epic Games" /c:"GOG" /c:"Origin" /c:"Ubisoft" /c:"Battle.net" /c:"Riot" "%APPS%" >> "%REPORT%"
)

rem --- Торренты ---
call :log ""
call :log "Торрент-клиенты:"
findstr /i /c:"torrent" /c:"BitTorrent" /c:"Vuze" "%APPS%" >nul 2>&1
if errorlevel 1 (
    call :log "  не обнаружено"
) else (
    call :log "  обнаружено (создают нагрузку на сеть):"
    findstr /i /c:"torrent" /c:"BitTorrent" /c:"Vuze" "%APPS%"
    findstr /i /c:"torrent" /c:"BitTorrent" /c:"Vuze" "%APPS%" >> "%REPORT%"
)

rem --- Мессенджеры ---
call :log ""
call :log "Мессенджеры:"
findstr /i /c:"Discord" /c:"Telegram" /c:"WhatsApp" /c:"Viber" /c:"Skype" "%APPS%" >nul 2>&1
if errorlevel 1 (
    call :log "  не обнаружено"
) else (
    call :log "  обнаружено (проверьте, входят ли в корпоративный стандарт):"
    findstr /i /c:"Discord" /c:"Telegram" /c:"WhatsApp" /c:"Viber" /c:"Skype" "%APPS%"
    findstr /i /c:"Discord" /c:"Telegram" /c:"WhatsApp" /c:"Viber" /c:"Skype" "%APPS%" >> "%REPORT%"
)

rem --- Развлечения ---
call :log ""
call :log "Развлекательное ПО:"
findstr /i /c:"Wallpaper Engine" /c:"OBS" /c:"Soundpad" /c:"Spotify" "%APPS%" >nul 2>&1
if errorlevel 1 (
    call :log "  не обнаружено"
) else (
    call :log "  обнаружено (проверьте соответствие корпоративному стандарту):"
    findstr /i /c:"Wallpaper Engine" /c:"OBS" /c:"Soundpad" /c:"Spotify" "%APPS%"
    findstr /i /c:"Wallpaper Engine" /c:"OBS" /c:"Soundpad" /c:"Spotify" "%APPS%" >> "%REPORT%"
)

rem ===== Итоги =====
call :log ""
call :log "=============================================="
call :log "ИТОГИ"
call :log "  Категорий базового ПО проверено: %checked%"
call :log "  Рекомендаций выдано: %missing%"
call :log "  Отчёт сохранён: %REPORT%"
call :log "=============================================="

rem ===== Удаляем временный файл =====
if exist "%APPS%" del "%APPS%"

echo.
echo Готово. Нажмите любую клавишу для выхода...
pause >nul
exit /b

rem ===== Подпрограмма для вывода на экран и в файл =====
:log
if "%~1"=="" (
    echo.
    echo.>> "%REPORT%"
) else (
    echo %~1
    echo %~1>> "%REPORT%"
)
exit /b
