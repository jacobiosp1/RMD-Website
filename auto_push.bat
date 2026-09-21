@echo off

:: 1. 设置项目路径和日志路径
set PROJECT_PATH=D:\RMD Website
set LOG_DIR=D:\R_Auto\logs
set LOG_FILE=%LOG_DIR%\auto_push.log

:: 2. 创建日志目录（如果 D 盘下该目录不存在，会自动创建）
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

:: 3. 切换到项目目录
cd /d "%PROJECT_PATH%"

:: 4. 检查是否有文件改动
git status --porcelain > "%TEMP%\git_status.txt"
for /f %%i in ("%TEMP%\git_status.txt") do set size=%%~zi
del "%TEMP%\git_status.txt"

:: 没有改动则直接退出，不写日志
if %size% equ 0 exit /b 0

:: 5. 开始执行 Git 操作
:: 5.1 git add
git add . > nul 2>&1
if %errorlevel% neq 0 (
    echo [%date% %time%] 失败：git add 出错 >> "%LOG_FILE%"
    exit /b 1
)

:: 5.2 git commit
git commit -m "Auto update" > nul 2>&1
if %errorlevel% neq 0 (
    echo [%date% %time%] 失败：git commit 出错 >> "%LOG_FILE%"
    exit /b 1
)

:: 5.3 git pull (防止远程冲突)
git pull --rebase origin HEAD > nul 2>&1
if %errorlevel% neq 0 (
    echo [%date% %time%] 失败：git pull 出错（可能有冲突） >> "%LOG_FILE%"
    exit /b 1
)

:: 5.4 git push
git push origin HEAD > nul 2>&1
if %errorlevel% neq 0 (
    echo [%date% %time%] 失败：git push 出错（检查网络或Token） >> "%LOG_FILE%"
    exit /b 1
)

:: 6. 全部成功
echo [%date% %time%] 推送成功 >> "%LOG_FILE%"