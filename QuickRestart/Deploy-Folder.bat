@echo off
chcp 65001 >nul
setlocal

powershell.exe ^
  -NoProfile ^
  -ExecutionPolicy Bypass ^
  -File "%~dp0Deploy-ObsidianPlugin.ps1" ^
  -Mode "Folder" ^
  -SourceRoot "F:\AI\Obsidian\Obsidian-workspace-plus-group" ^
  -TargetPluginDir "D:\project\obsidian\生活笔记\.obsidian\plugins\workspace-plus-group" ^
  -ExcludeDirs ".git;QuickRestart"

if errorlevel 1 (
    echo.
    echo 部署失败。
    pause
)

endlocal