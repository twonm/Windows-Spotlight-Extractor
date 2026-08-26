@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

:: ============================================
:: Windows Spotlight Wallpaper Extractor
:: Compatible with all Windows 10/11 language versions
:: ============================================

:: Try to get system locale, fallback to English if wmic fails
:: ============================================
:: Language Detection (Multi-method fallback)
:: ============================================
set "MSG_LANG=en"
set "LOCALE="

:: Method 1: Registry (Most reliable)
for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Nls\Language" /v InstallLanguage 2^>nul') do set "LOCALE=%%a"

:: Method 2: WMIC (Fallback 1)
if not defined LOCALE (
    for /f "tokens=2 delims==." %%a in ('wmic os get locale /value 2^>nul ^| find "="') do set "LOCALE=%%a"
)

:: Method 3: systeminfo (Fallback 2)
if not defined LOCALE (
    for /f "tokens=2 delims=:" %%a in ('systeminfo 2^>nul ^| findstr /i "系统区域设置 System Locale"') do (
        for %%b in (%%a) do (
            echo %%b | findstr /i "zh-cn zh-CN 中文" >nul && set "LOCALE=0804"
            echo %%b | findstr /i "zh-tw zh-HK" >nul && set "LOCALE=0404"
        )
    )
)

:: Set language based on locale
if defined LOCALE (
    if "%LOCALE%"=="0804" set "MSG_LANG=zh"
    if "%LOCALE%"=="0404" set "MSG_LANG=zh"
    if "%LOCALE%"=="0c04" set "MSG_LANG=zh"
)

:: Define messages
if "%MSG_LANG%"=="zh" (
    set "MSG_TITLE=Windows 聚焦壁纸提取工具"
    set "MSG_SOURCE=源路径"
    set "MSG_TARGET=目标路径"
    set "MSG_ERROR_DIR=错误：未找到Windows聚焦壁纸目录！请确认系统已开启Windows聚焦功能。"
    set "MSG_CREATING=信息：正在创建目标文件夹..."
    set "MSG_CREATE_FAIL=错误：无法创建目标文件夹，请检查权限！"
    set "MSG_SCANNING=信息：正在扫描壁纸文件..."
    set "MSG_EXTRACT=提取"
    set "MSG_COMPLETE=完成"
    set "MSG_TOTAL=总计文件"
    set "MSG_EXTRACTED=新提取"
    set "MSG_SKIPPED=已存在（已跳过）"
    set "MSG_OPENING=信息：正在打开目标文件夹..."
    set "MSG_PRESS_KEY=按任意键退出..."
    set "MSG_OPEN_FAIL=警告：无法打开目标文件夹"
    set "MSG_NO_FILES=未找到可提取的壁纸文件"
) else (
    set "MSG_TITLE=Windows Spotlight Wallpaper Extractor"
    set "MSG_SOURCE=Source"
    set "MSG_TARGET=Target"
    set "MSG_ERROR_DIR=Error: Windows Spotlight directory not found! Please confirm Windows Spotlight is enabled."
    set "MSG_CREATING=Info: Creating target folder..."
    set "MSG_CREATE_FAIL=Error: Cannot create target folder, please check permissions!"
    set "MSG_SCANNING=Info: Scanning for wallpaper files..."
    set "MSG_EXTRACT=Extracted"
    set "MSG_COMPLETE=Complete"
    set "MSG_TOTAL=Total files"
    set "MSG_EXTRACTED=Newly extracted"
    set "MSG_SKIPPED=Already exists (skipped)"
    set "MSG_OPENING=Info: Opening target folder..."
    set "MSG_PRESS_KEY=Press any key to exit..."
    set "MSG_OPEN_FAIL=Warning: Cannot open target folder"
    set "MSG_NO_FILES=No extractable wallpaper files found"
)

:: Source path
set "SOURCE=%localappdata%\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets"

:: ============================================
:: Target path parsing
:: ============================================
set "TARGET="
if "%~1"=="" (
    set "TARGET=%~dp0WindowsSpotlight"
) else (
    set "TARGET=%~1"
)

:: Handle drag-drop: if parameter is a file, use its parent directory
if not "%~x1"=="" (
    if exist "%~1\" (
        :: It's a folder
        set "TARGET=%~1"
    ) else (
        :: It's a file
        set "TARGET=%~dp1"
    )
)

:: Ensure trailing backslash
if not "%TARGET:~-1%"=="\" set "TARGET=%TARGET%\"

:: Clean display path
set "TARGET_DISPLAY=%TARGET%"
if "%TARGET_DISPLAY:~-1%"=="\" set "TARGET_DISPLAY=%TARGET_DISPLAY:~0,-1%"

:: ============================================
:: Main execution
:: ============================================
echo.
echo ============================================
echo      %MSG_TITLE%
echo ============================================
echo.
echo [%MSG_SOURCE%] %SOURCE%
echo [%MSG_TARGET%] %TARGET_DISPLAY%
echo.

:: Check source
if not exist "%SOURCE%" (
    echo [ERROR] %MSG_ERROR_DIR%
    echo.
    echo %MSG_PRESS_KEY%
    pause >nul
    exit /b 1
)

:: Create target
if not exist "%TARGET%" (
    echo [INFO] %MSG_CREATING%
    mkdir "%TARGET%" 2>nul
    if errorlevel 1 (
        echo [ERROR] %MSG_CREATE_FAIL%
        echo.
        echo %MSG_PRESS_KEY%
        pause >nul
        exit /b 1
    )
)

:: Statistics
set /a COUNT=0
set /a SKIP=0
set /a TOTAL=0

echo [INFO] %MSG_SCANNING%
echo.

for %%F in ("%SOURCE%\*") do (
    set /a TOTAL+=1
    set "FILESIZE=%%~zF"
    
    :: Skip if file is too small (thumbnail/icon)
    if !FILESIZE! GTR 102400 (
        set "FILENAME=%%~nF.jpg"
        
        if exist "%TARGET%!FILENAME!" (
            set /a SKIP+=1
        ) else (
            copy "%%F" "%TARGET%!FILENAME!" >nul 2>&1
            if !errorlevel! == 0 (
                set /a COUNT+=1
                echo [%MSG_EXTRACT%] !FILENAME!
            )
        )
    )
)

echo.
echo ============================================
echo [%MSG_COMPLETE%]
echo         %MSG_TOTAL%: %TOTAL%
if %COUNT% GTR 0 echo         %MSG_EXTRACTED%: %COUNT%
if %SKIP% GTR 0 echo         %MSG_SKIPPED%: %SKIP%
if %COUNT%==0 if %TOTAL% GTR 0 echo         %MSG_NO_FILES%
echo ============================================
echo.

:: Open folder
echo [INFO] %MSG_OPENING%
timeout /t 1 /nobreak >nul 2>&1
start "" "%TARGET%" 2>nul

echo.
echo %MSG_PRESS_KEY%
pause >nul

endlocal
exit /b 0