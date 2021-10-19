# Install Non-Visual Desktop Access (NVDA) x86
#
# This app is like VLC. Installs a desktop shortcut, and stores its nag settings in a per-user INI file.
# this script will pre-load a custom INI file, run the installer, let the app auto-launch after install, and then kill the desktop shortcut.
# On that first run, the user can pick how he wants the app to behave. Other users have to find the app and run it voluntarily.
# This app installs for all users. The only way to get per-user install is to runt he Windows app store version.

$Installer = ".\nvda_2021.2.exe"
$Transcript = $env:TEMP + "\" + "NVDA-Install-Transcript.log"
$LogFile =  $env:TEMP + "\" + "NVDA-Install.log"

Start-Transcript -Path $Transcript




##########################3
# Install the app
# we don't want it to run immediately after install, because it just ignores my pre-loaded ini files.

#& $Installer --install -f "$LogFile" | Wait-Process
& $Installer --install-silent -f "$LogFile" | Wait-Process

#####################
## install Config
# Pre-load the custom INI file for each profile.
# This slaps-away the update and telemetry nags.
# If we load it before the install, the app will just ignore it.

$ConfigFile = $PWD.Path + "\nvda.ini"
$AppDataFolder = "\AppData\Roaming\nvda\"

$ProfileStore = (Get-Item -Path $Env:PUBLIC | Split-Path -Parent)
$ProfileFolders = Get-ChildItem -Path $ProfileStore -Directory -Exclude "Public","Default User","All Users" -Force

$TargetFolders =  $ProfileFolders | ForEach-Object {($_.FullName + $AppDataFolder)}

# Ensure that folders have been made before copying the file.
$TargetFolders | ForEach-Object {If (!(Test-Path($_))){New-Item -Type Directory -Path $_ -Verbose}}

# Copy the config file
# do not overwrite!
$TargetFolders | ForEach-Object {Copy-Item -Path $ConfigFile -Destination $_ -Force:$False -Verbose}

#####################
# POST-Install Config

# Remove the desktop shortcut that gets installed for all users.

$DesktopShortcut = $env:PUBLIC + "\Desktop\NVDA.lnk"
Get-Item -Path $DesktopShortcut | ForEach-Object {$_ | Remove-Item -Force -Verbose}

#######

Stop-Transcript