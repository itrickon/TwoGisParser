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
echo Creating desktop shortcut...

set "EXE_PATH=%CD%\2GIS_Parser.exe"
set "DESKTOP_PATH=%USERPROFILE%\Desktop"
set "SHORTCUT_NAME=2GIS Parser.lnk"
set "ICON_PATH=%CD%\static\icon.ico"

echo EXE path: %EXE_PATH%
echo Desktop path: %DESKTOP_PATH%

:: Проверяем, существует ли EXE
if not exist "%EXE_PATH%" (
    echo ERROR: 2GIS_Parser.exe not found!
    pause
    exit /b 1
)

:: Создаем ярлык через PowerShell
echo Creating shortcut via PowerShell...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$WshShell = New-Object -ComObject WScript.Shell; ^
$Shortcut = $WshShell.CreateShortcut('%DESKTOP_PATH%\%SHORTCUT_NAME%'); ^
$Shortcut.TargetPath = '%EXE_PATH%'; ^
$Shortcut.WorkingDirectory = '%CD%'; ^
$Shortcut.IconLocation = '%ICON_PATH%'; ^
$Shortcut.Description = '2GIS Parser Application'; ^
$Shortcut.Save(); ^
Write-Host 'Shortcut created successfully!'"

:: Проверяем создание
if exist "%DESKTOP_PATH%\%SHORTCUT_NAME%" (
    echo Desktop shortcut created: %SHORTCUT_NAME%
) else (
    echo Failed to create desktop shortcut
)
echo.
pause