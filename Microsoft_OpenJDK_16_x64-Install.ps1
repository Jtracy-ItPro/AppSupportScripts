# Install Microsoft OpenJDK 16 x64
# This is free and made by MS
# v16 is the current release, it is not long-term servicing.
# to test app support, try to run Minecraft Server jar file and see what happens.

# The setting to take over the JAVA_HOME dir, would effectively set this as the default JDK instance on your computer. This setting is off by default.
# The ADDLOCAL parameter ensures that it's enabled instead. Remove the parameters if you don't want it.

$Installer = "microsoft-jdk-16.0.2.7.1-windows-x64.msi"
$LogFile = $env:TEMP + "\" +"Microsoft_OpenJDK_16_x64-Install.log"
$Parameters = "ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome"

#==-=-=-=-=-==

$Installer = Get-Item -Path "$Installer" | Select-Object -ExpandProperty FullName

# install it

& MsiExec.exe /i $Installer /q /NoRestart $Parameters /Log $LogFile | Wait-Process

