param(
    [ValidateSet("Files", "Folder")]
    [string]$Mode = "Folder",

    # 插件项目源地址
    [Parameter(Mandatory = $true)]
    [string]$SourceRoot="F:\AI\Obsidian\workspace-plus-group",

    # Obsidian仓库的插件地址
    [Parameter(Mandatory = $true)]
    [string]$TargetPluginDir="D:\project\obsidian\生活笔记\.obsidian\plugins\workspace-plus-group",

    # Files 模式下复制的文件，相对于 SourceRoot，使用分号分隔
    [string]$FileList = "main.js;manifest.json;styles.css",

    # Folder 模式下排除的目录，使用分号分隔
    [string]$ExcludeDirs = ".git;QuickRestart",

    # Folder 模式下排除的文件或通配符，使用分号分隔
    # 例如：package-lock.json;*.map;*.log;src\debug.js
    [string]$ExcludeFiles = "",

    # 可选：指定 Obsidian.exe
    [string]$ObsidianExe = "",

    # 可选：指定重新打开的 Vault
    [string]$VaultName = ""
)

$ErrorActionPreference = "Stop"

[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# ============================================================
# 通用工具
# ============================================================

function ConvertFrom-SemicolonList {
    param(
        [AllowEmptyString()]
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return @()
    }

    return @(
        $Value.Split(
            ";",
            [System.StringSplitOptions]::RemoveEmptyEntries
        ) |
        ForEach-Object {
            $_.Trim()
        } |
        Where-Object {
            -not [string]::IsNullOrWhiteSpace($_)
        }
    )
}

function Resolve-FullPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return [System.IO.Path]::GetFullPath(
        [Environment]::ExpandEnvironmentVariables($Path)
    )
}

function Get-ObsidianExecutable {
    param(
        [string]$ConfiguredPath
    )

    if (-not [string]::IsNullOrWhiteSpace($ConfiguredPath)) {
        $expandedPath = Resolve-FullPath $ConfiguredPath

        if (Test-Path -LiteralPath $expandedPath -PathType Leaf) {
            return $expandedPath
        }

        throw "指定的 Obsidian.exe 不存在：$expandedPath"
    }

    $runningProcesses = @(
        Get-Process -Name "Obsidian" -ErrorAction SilentlyContinue
    )

    foreach ($process in $runningProcesses) {
        try {
            if (
                -not [string]::IsNullOrWhiteSpace($process.Path) -and
                (Test-Path -LiteralPath $process.Path -PathType Leaf)
            ) {
                return $process.Path
            }
        }
        catch {
        }
    }

    $candidatePaths = @(
        "$env:LOCALAPPDATA\Obsidian\Obsidian.exe",
        "$env:LOCALAPPDATA\Programs\Obsidian\Obsidian.exe",
        "$env:ProgramFiles\Obsidian\Obsidian.exe",
        "${env:ProgramFiles(x86)}\Obsidian\Obsidian.exe"
    )

    foreach ($candidatePath in $candidatePaths) {
        if (
            -not [string]::IsNullOrWhiteSpace($candidatePath) -and
            (Test-Path -LiteralPath $candidatePath -PathType Leaf)
        ) {
            return $candidatePath
        }
    }

    return $null
}

# ============================================================
# 指定文件复制
# ============================================================

function Copy-SelectedFiles {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Destination,

        [Parameter(Mandatory = $true)]
        [string[]]$RelativeFiles
    )

    if ($RelativeFiles.Count -eq 0) {
        throw "Files 模式下没有指定任何文件。"
    }

    $missingFiles = @()

    foreach ($relativeFile in $RelativeFiles) {
        $sourceFile = Join-Path $Source $relativeFile

        if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
            $missingFiles += $sourceFile
        }
    }

    if ($missingFiles.Count -gt 0) {
        throw (
            "以下源文件不存在：`n" +
            ($missingFiles -join "`n")
        )
    }

    New-Item `
        -ItemType Directory `
        -Path $Destination `
        -Force |
        Out-Null

    foreach ($relativeFile in $RelativeFiles) {
        $sourceFile = Join-Path $Source $relativeFile
        $targetFile = Join-Path $Destination $relativeFile
        $targetParentDirectory = Split-Path -Parent $targetFile

        if (-not [string]::IsNullOrWhiteSpace($targetParentDirectory)) {
            New-Item `
                -ItemType Directory `
                -Path $targetParentDirectory `
                -Force |
                Out-Null
        }

        Copy-Item `
            -LiteralPath $sourceFile `
            -Destination $targetFile `
            -Force

        Write-Host "[覆盖文件] $relativeFile"
    }
}

# ============================================================
# 整个目录复制
# ============================================================

function Copy-WholeFolder {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Destination,

        [string[]]$ExcludedDirectories = @(),

        [string[]]$ExcludedFiles = @()
    )

    New-Item `
        -ItemType Directory `
        -Path $Destination `
        -Force |
        Out-Null

    $robocopyArguments = @(
        $Source
        $Destination

        # 复制所有子目录，包括空目录
        "/E"

        # 文件数据、属性、时间戳
        "/COPY:DAT"
        "/DCOPY:DAT"

        # 失败重试
        "/R:2"
        "/W:1"

        # 减少日志输出
        "/NP"
        "/NFL"
        "/NDL"
    )

    if ($ExcludedDirectories.Count -gt 0) {
        $robocopyArguments += "/XD"

        foreach ($excludedDirectory in $ExcludedDirectories) {
            $robocopyArguments += $excludedDirectory
        }

        Write-Host (
            "[排除目录] " +
            ($ExcludedDirectories -join ", ")
        )
    }

    if ($ExcludedFiles.Count -gt 0) {
        $robocopyArguments += "/XF"

        foreach ($excludedFile in $ExcludedFiles) {
            # 含目录分隔符时，按 SourceRoot 下的相对路径处理
            if (
                $excludedFile.Contains("\") -or
                $excludedFile.Contains("/")
            ) {
                $normalizedRelativePath = $excludedFile.Replace("/", "\")
                $robocopyArguments += (
                    Join-Path $Source $normalizedRelativePath
                )
            }
            else {
                # 纯文件名或通配符，例如 *.map、package-lock.json
                $robocopyArguments += $excludedFile
            }
        }

        Write-Host (
            "[排除文件] " +
            ($ExcludedFiles -join ", ")
        )
    }

    & robocopy.exe @robocopyArguments

    $robocopyExitCode = $LASTEXITCODE

    # Robocopy 0～7 为成功或非致命差异
    if ($robocopyExitCode -ge 8) {
        throw "Robocopy 复制失败，退出码：$robocopyExitCode"
    }

    Write-Host "[完成] 整个插件目录复制完成"
}

# ============================================================
# 重启 Obsidian
# ============================================================

function Stop-Obsidian {
    $processes = @(
        Get-Process -Name "Obsidian" -ErrorAction SilentlyContinue
    )

    if ($processes.Count -eq 0) {
        Write-Host "[重启] Obsidian 当前未运行"
        return
    }

    Write-Host "[重启] 正在正常关闭 Obsidian..."

    foreach ($process in $processes) {
        try {
            if ($process.MainWindowHandle -ne 0) {
                [void]$process.CloseMainWindow()
            }
        }
        catch {
        }
    }

    $deadline = (Get-Date).AddSeconds(5)

    while ((Get-Date) -lt $deadline) {
        $remainingProcesses = @(
            Get-Process -Name "Obsidian" -ErrorAction SilentlyContinue
        )

        if ($remainingProcesses.Count -eq 0) {
            Write-Host "[重启] Obsidian 已正常关闭"
            return
        }

        Start-Sleep -Milliseconds 200
    }

    $remainingProcesses = @(
        Get-Process -Name "Obsidian" -ErrorAction SilentlyContinue
    )

    if ($remainingProcesses.Count -gt 0) {
        Write-Host "[重启] 正常关闭超时，结束残留进程"

        $remainingProcesses |
            Stop-Process -Force -ErrorAction SilentlyContinue
    }
}

function Start-Obsidian {
    param(
        [AllowNull()]
        [string]$ExecutablePath,

        [string]$Vault
    )

    Start-Sleep -Milliseconds 800

    if (-not [string]::IsNullOrWhiteSpace($Vault)) {
        $encodedVaultName = [Uri]::EscapeDataString($Vault)
        $vaultUri = "obsidian://open?vault=$encodedVaultName"

        Start-Process $vaultUri
        Write-Host "[重启] 已打开 Vault：$Vault"
        return
    }

    if (
        -not [string]::IsNullOrWhiteSpace($ExecutablePath) -and
        (Test-Path -LiteralPath $ExecutablePath -PathType Leaf)
    ) {
        Start-Process -FilePath $ExecutablePath
        Write-Host "[重启] 已启动 Obsidian"
        return
    }

    Start-Process "obsidian://open"
    Write-Host "[重启] 已通过 Obsidian URI 启动"
}

function Restart-Obsidian {
    param(
        [AllowNull()]
        [string]$ExecutablePath,

        [string]$Vault
    )

    Stop-Obsidian

    Start-Obsidian `
        -ExecutablePath $ExecutablePath `
        -Vault $Vault
}

# ============================================================
# 主流程
# ============================================================

try {
    $resolvedSourceRoot = Resolve-FullPath $SourceRoot
    $resolvedTargetPluginDir = Resolve-FullPath $TargetPluginDir

    if (
        -not (
            Test-Path `
                -LiteralPath $resolvedSourceRoot `
                -PathType Container
        )
    ) {
        throw "源目录不存在：$resolvedSourceRoot"
    }

    if (
        $resolvedSourceRoot.TrimEnd("\") -eq
        $resolvedTargetPluginDir.TrimEnd("\")
    ) {
        throw "源目录和目标目录不能相同。"
    }

    $resolvedObsidianExe = Get-ObsidianExecutable `
        -ConfiguredPath $ObsidianExe

    Write-Host "============================================"
    Write-Host "Obsidian 插件部署"
    Write-Host "============================================"
    Write-Host "模式：$Mode"
    Write-Host "源目录：$resolvedSourceRoot"
    Write-Host "目标目录：$resolvedTargetPluginDir"
    Write-Host ""

    switch ($Mode) {
        "Files" {
            $selectedFiles = ConvertFrom-SemicolonList `
                -Value $FileList

            Copy-SelectedFiles `
                -Source $resolvedSourceRoot `
                -Destination $resolvedTargetPluginDir `
                -RelativeFiles $selectedFiles
        }

        "Folder" {
            $excludedDirectoryList = ConvertFrom-SemicolonList `
                -Value $ExcludeDirs

            $excludedFileList = ConvertFrom-SemicolonList `
                -Value $ExcludeFiles

            Copy-WholeFolder `
                -Source $resolvedSourceRoot `
                -Destination $resolvedTargetPluginDir `
                -ExcludedDirectories $excludedDirectoryList `
                -ExcludedFiles $excludedFileList
        }

        default {
            throw "未知部署模式：$Mode"
        }
    }

    Write-Host ""
    Write-Host "[成功] 插件部署完成"

    Restart-Obsidian `
        -ExecutablePath $resolvedObsidianExe `
        -Vault $VaultName

    exit 0
}
catch {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Red
    Write-Host "[失败] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
    Write-Host "复制失败，因此不会重启 Obsidian。" -ForegroundColor Yellow

    exit 1
}