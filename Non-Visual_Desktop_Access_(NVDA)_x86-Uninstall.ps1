# Uninstall Non-Visual Desktop Access (NVDA) x86

# This script is meant for the downloadable version of NVDA
# Not the Windows App Store version.
# This installer uses NSIS and installs for all users on the computer

# NSIS has a behavior where it spawns subprocesses when the Uninstall.EXE quits
# This confuses Software Center, which incorrectly reports a "failed" uninstall.
# The solution is to wrap the command and wait-out the child processes, then let the script finish.

$Uninstaller = ${env:ProgramFiles(x86)} + "\NVDA\uninstall.exe"

# Run the uninstaller and wait for it to finish.

& $Uninstaller /S | Wait-Process

# Wait until the child process finishes, before returning.

$ChildProcessName = "Au_"

While(Get-Process | Where-Object {$_.ProcessName -eq $ChildProcessName})
    {Start-Sleep -Seconds 5}
