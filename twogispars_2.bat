@echo off
chcp 1251 >nul
echo.
echo ====================================================
echo =                   Parser 2GIS                    =
echo ====================================================
echo.

echo.
echo Installing dependencies...
pip install sv-ttk
pip install pyinstaller
pip install googletrans
pip install playwright
pip install openpyxl
pip install asyncio
playwright install chromium

echo.
echo Compiling EXE...
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
echo Move everything from the 2GIS_Parser folder to the root...
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
    
    echo Files have been moved to the root!
    if exist _internal echo _internal\
) else (
    echo The 2GIS_Parser folder was not created.
)
echo.
pause