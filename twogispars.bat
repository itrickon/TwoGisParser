@echo off
chcp 65001 >nul
echo.
echo ╔══════════════════════════════════════════════════╗
echo ║                   Парсер 2GIS                    ║
echo ╚══════════════════════════════════════════════════╝
echo.

echo.
echo Устанавливаем зависимости...
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
--distpath=. ^
--name="2GIS_Parser" ^
--onefile ^
--windowed ^
--icon="static/icon.ico" ^
--add-data="static;static" ^
--add-data="%LOCALAPPDATA%\ms-playwright;ms-playwright" ^
--runtime-hook=playwright_runtime_hook.py ^
--exclude-module=unittest ^
--exclude-module=pydoc ^
gui.py

echo Проверяем результат сборки...
if exist 2GIS_Parser.exe (
    echo Сборка успешно завершена!
    echo Удаляем папку build...
    rmdir /s build
    echo Готово. EXE файл находится в папке dist
) else (
    echo Ошибка сборки! Папка build сохранена для диагностики.
)

echo.
pause