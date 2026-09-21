@echo off
chcp 65001 > nul

:: 1. 设置项目路径和日志路径
set PROJECT_PATH=D:\RMD Website
set LOG_DIR=C:\R_Auto\logs
set LOG_FILE=%LOG_DIR%\auto_push.log

:: 2. 创建日志目录（如果不存在）
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

:: 3. 切换到项目目录
cd /d "%PROJECT_PATH%"

:: 4. 检查是否有文件改动（通过判断 git status 输出内容的长度）
git status --porcelain > "%TEMP%\git_status.txt"
for /f %%i in ("%TEMP%\git_status.txt") do set size=%%~zi
del "%TEMP%\git_status.txt"

:: 如果没有改动，记录日志并退出，不执行后续 Git 操作
if %size% equ 0 (
    echo [%date% %time%] 没有检测到文件改动，跳过提交。 >> "%LOG_FILE%"
    exit /b 0
)

:: 5. 执行 Git 提交和推送
echo [%date% %time%] 检测到更新，开始推送... >> "%LOG_FILE%"

git add . >> "%LOG_FILE%" 2>&1
git commit -m "Auto update: %date% %time%" >> "%LOG_FILE%" 2>&1

:: 先拉取远程代码，防止远程有更新导致的冲突（使用 --rebase 保持提交线整洁）
git pull --rebase origin HEAD >> "%LOG_FILE%" 2>&1

:: 推送到 GitHub
git push origin HEAD >> "%LOG_FILE%" 2>&1

:: 6. 判断推送结果
if %errorlevel% neq 0 (
    echo [%date% %time%]  推送失败，请查看日志排查。 >> "%LOG_FILE%"
) else (
    echo [%date% %time%]  推送成功！GitHub Actions 开始构建。 >> "%LOG_FILE%"
)