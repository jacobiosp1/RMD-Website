@echo off

:: 1. 设置项目路径和日志路径
set PROJECT_PATH=D:\RMD Website
set LOG_DIR=D:\R_Auto\logs
set LOG_FILE=%LOG_DIR%\auto_push.log

:: 2. 创建日志目录
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

:: 3. 切换项目目录
cd /d "%PROJECT_PATH%"

:: 4. 检查是否有改动
git status --porcelain > "%TEMP%\git_status.txt"
for /f %%i in ("%TEMP%\git_status.txt") do set size=%%~zi
del "%TEMP%\git_status.txt"

:: 没有改动直接退出
if %size% equ 0 exit /b 0

:: 5. 执行 Git 操作
:: 5.1 git add
git add . > nul 2>&1
if %errorlevel% neq 0 (
    echo FAILED: git add >> "%LOG_FILE%"
    exit /b 1
)

:: 5.2 git commit （此处加入了带时间的提交信息，格式和你想要的一致）
git commit -m "Auto update: %date% %time%" > nul 2>&1
if %errorlevel% neq 0 (
    echo FAILED: git commit >> "%LOG_FILE%"
    exit /b 1
)

:: 5.3 git pull
git pull --rebase origin HEAD > nul 2>&1
if %errorlevel% neq 0 (
    echo FAILED: git pull (conflict) >> "%LOG_FILE%"
    exit /b 1
)

:: 5.4 git push
git push origin HEAD > nul 2>&1
if %errorlevel% neq 0 (
    echo FAILED: git push (network/token) >> "%LOG_FILE%"
    exit /b 1
)

:: 6. 成功（纯英文，防止 txt 乱码）
echo SUCCESS: Pushed to GitHub >> "%LOG_FILE%"