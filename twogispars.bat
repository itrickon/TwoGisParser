@echo off
chcp 65001 >nul
echo.
echo ╔══════════════════════════════════════════════════╗
echo ║                   Парсер 2GIS                    ║
echo ╚══════════════════════════════════════════════════╝
echo.

echo.
echo Устанавливаем зависимости...
powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe' -OutFile 'python_setup.exe'"
pip install sv-ttk
pip install pyinstaller
pip install googletrans
pip install playwright
pip install openpyxl
pip install asyncio
playwright install chromium

echo.
echo Собираем EXE...
pyinstaller --clean --noconfirm ^
--exclude-module=playwright._impl._locale ^
--distpath=. ^
--name="2GIS_Parser" ^
--onedir ^
--windowed ^
--icon="static/icon.ico" ^
--add-data="static;static" ^
--add-data="%LOCALAPPDATA%\ms-playwright\chromium-*;ms-playwright" ^
--runtime-hook=playwright_runtime_hook.py ^
--exclude-module=unittest ^
--exclude-module=pydoc ^
gui.py

echo.
echo Перемещаем всё из папки 2GIS_Parser в корень...
if exist "2GIS_Parser" (
    move "2GIS_Parser\_internal" "." >nul 2>nul
    move "2GIS_Parser\2GIS_Parser.exe" "." >nul 2>nul
    
    :: Если есть другие файлы
    for %%F in ("2GIS_Parser\*.*") do (
        if not "%%F"=="2GIS_Parser\_internal" if not "%%F"=="2GIS_Parser\2GIS_Parser.exe" (
            move "%%F" "." >nul 2>nul
        )
    )
    
    rmdir /s /q "2GIS_Parser"
    rmdir /s /q build
    del *.spec 2>nul
    
    echo Файлы перемещены в корень!
    if exist _internal echo _internal\
) else (
    echo Папка 2GIS_Parser не создана
)
echo.
pause