$logFile = ""
"path to the logfile"

function Write-Log {
    Param ([string]$message)
    "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')): $message" | Out-File -FilePath $logFile -Append
}


if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Log "This script requires Administrator privileges. Exiting."
    exit
}

Write-Log "Starting UserProfileTempFiles cleanup."


$userProfilesBasePath = "C:\Users"


$userProfileDirs = Get-ChildItem -Path $userProfilesBasePath -Directory

foreach ($userDir in $userProfileDirs) {
    $tempPath = Join-Path -Path $userDir.FullName -ChildPath "AppData\Local\Temp"

    if (Test-Path $tempPath) {
        $PreList = Get-ChildItem -Path $tempPath -Force -Recurse -ErrorAction SilentlyContinue
        Write-Log "Removing Files and Folders from: $tempPath"
        Write-Log "Will be deleting: $($PreList.Count) File System Objects"

        foreach ($item in $PreList) {
            try {
                Remove-Item $item.FullName -Recurse -Force -ErrorAction Stop
                Write-Log "Deleted: $($item.FullName)"
            } catch {
                Write-Log "Failed to delete item: $($item.FullName)"
            }
        }

        $PostList = Get-ChildItem -Path $tempPath -Force -Recurse -ErrorAction SilentlyContinue
        Write-Log "Skipped: $($PostList.Count) files"
    } else {
        Write-Log "Temp path does not exist or is not accessible: $tempPath"
    }
}

Write-Log "UserProfileTempFiles cleanup completed."
