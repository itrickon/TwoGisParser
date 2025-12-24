@echo off
chcp 65001 >nul
echo.
echo ╔══════════════════════════════════════════════════╗
echo ║                    Парсер 2GIS                   ║
echo ╚══════════════════════════════════════════════════╝
echo.

echo Устанавливаем PyInstaller...
pip install pyinstaller

echo.
echo Компилируем в EXE...
pyinstaller --name="TwoGisParser" ^
--onefile ^
--windowed ^
--add-data=".;." ^
gui.py


echo.
echo Готово! 
echo EXE файл находится в папке: dist\
echo.

pause