# Install Python 3.9x x64
# 3.9 this is considered a stable release.
# we might have to add this to PATH for it to do anything after it installs.

$Installer = "python-3.9.7-amd64.exe"
$LogFile = $env:TEMP + "\" + "Python_x64-Install.log"
$Parameters = "InstallAllUsers=1 Include_symbols=1"

$Installer = Get-Item $Installer | Select-Object -ExpandProperty fullname

& $Installer /quiet $Parameters /log "$LogFile" | Wait-Process
