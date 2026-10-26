@echo off
chcp 65001 >nul
REM Тема работы: Диагностика клиентского компьютера
REM Автор: [Ваша фамилия]  Дата: 2026-XX-XX

set "REPORT=%~dp0pc_report.txt"
echo Диагностика компьютера > "%REPORT%"
echo ============================== >> "%REPORT%"
echo. >> "%REPORT%"

REM === Операционная система ===
echo Операционная система:
echo Операционная система: >> "%REPORT%"
for /f "tokens=1,2 delims==" %%a in ('wmic os get Caption /value ^| find "="') do (
    echo   Название: %%b
    echo   Название: %%b >> "%REPORT%"
)
for /f "tokens=1,2 delims==" %%a in ('wmic os get Version /value ^| find "="') do (
    echo   Версия: %%b
    echo   Версия: %%b >> "%REPORT%"
)
echo. >> "%REPORT%"
echo.

REM === Процессор ===
echo Процессор:
echo Процессор: >> "%REPORT%"
for /f "tokens=1,2 delims==" %%a in ('wmic cpu get Name /value ^| find "="') do (
    echo   %%b
    echo   %%b >> "%REPORT%"
)
echo. >> "%REPORT%"
echo.

REM === Оперативная память ===
echo Оперативная память:
echo Оперативная память: >> "%REPORT%"
for /f "tokens=1,2 delims==" %%a in ('wmic OS get TotalVisibleMemorySize /value ^| find "="') do set /a total_mem=%%b/1048576
for /f "tokens=1,2 delims==" %%a in ('wmic OS get FreePhysicalMemory /value ^| find "="') do set /a free_mem=%%b/1048576
echo   Всего памяти: %total_mem% ГБ
echo   Всего памяти: %total_mem% ГБ >> "%REPORT%"
echo   Свободно памяти: %free_mem% ГБ
echo   Свободно памяти: %free_mem% ГБ >> "%REPORT%"
echo. >> "%REPORT%"
echo.

REM === Диск C ===
echo Диск C:
echo Диск C: >> "%REPORT%"
for /f "tokens=1,2 delims==" %%a in ('wmic logicaldisk where "DeviceID='C:'" get Size /value ^| find "="') do set /a total_disk=%%b/1073741824
for /f "tokens=1,2 delims==" %%a in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace /value ^| find "="') do set /a free_disk=%%b/1073741824
echo   Всего: %total_disk% ГБ
echo   Всего: %total_disk% ГБ >> "%REPORT%"
echo   Свободно: %free_disk% ГБ
echo   Свободно: %free_disk% ГБ >> "%REPORT%"
echo. >> "%REPORT%"
echo.

REM === Установленные программы ===
echo Установленные программы:
echo Установленные программы: >> "%REPORT%"
echo Идёт поиск программ, это может занять несколько минут...
echo. >> "%REPORT%"
wmic product get name,version /format:list 2>nul | findstr /v "^$" >> "%REPORT%"
echo. >> "%REPORT%"

echo Отчёт сохранён.
echo Отчёт сохранён. >> "%REPORT%"
pause
