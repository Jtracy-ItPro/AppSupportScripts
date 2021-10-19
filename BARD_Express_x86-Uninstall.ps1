# Uninstall BARD Express x86

$AppName = "BARD Express"
$ProcessNames = @("BARDExpress")

# MSI GUID-style uninstall
# uninstall info lives in x86 space

###################################

# Sweep installed apps and pull the uninstall string.
# This is meant to solve the problem of uninstalling auto-patched apps. with automation.
# Secunia will auto-apply new MSIs, which changes the string.
# The config manager client can unisntall with this script, with no regard to the version that's actually installed.


## Look for both architectures.

$UninstallRoot = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

#$UninstallRoot = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"

# Find the first app which matches the name. Be careful to make it find the corret one, in case more than one app matches.

# we need wildcards here, because the version is in the name. So use LIKE matching.

$AppInfo = Get-ChildItem -Path $UninstallRoot | Where-Object {$_.getValue("displayname") -eq $AppName} | Select-Object -First 1

If (!($AppInfo)){Write-Output "App not found!"; return}

$Version = $AppInfo.GetValue("DisplayVersion")

# Get the guid, needed for MSI uninstall.

$AppGuid = $AppInfo.PSChildName

# Craft the log file name
$LogFile = $env:TEMP + "\" + $AppName + "_" + $Version + "-Uninstall.log"

If (!($AppGuid)) {write-output "app not found!"; return}



#######################

Write-Output "Killing any running instances of this app:"

Get-Process | Where-Object {$_.processname -in $ProcessNames} | ForEach-Object {$_ | Stop-Process -Force -Verbose}

##########################3

# With all this information, run the uninstall command.

Write-Output "Uninstalling now:"

& MsiExec /x $AppGuid /q /norestart | Wait-Process

######################################