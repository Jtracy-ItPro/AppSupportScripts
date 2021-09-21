# Install Microsoft OpenJDK 11 x64
# This is free and made by MS
# Java 11 is considered the long-term servicing version.

# The setting to take over the JAVA_HOME dir, would effectively set this as the default JDK instance on your computer. This setting is off by default.
# The ADDLOCAL parameter ensures that it's enabled instead. Remove the parameters if you don't want it.

$Installer = "microsoft-jdk-11.0.12.7.1-windows-x64.msi"
$LogFile = $env:TEMP + "\" +"Microsoft_OpenJDK_11_x64-Install.log"
$Parameters = "ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome"

#==-=-=-=-=-==

$Installer = get-item -Path "$Installer" | Select-Object -ExpandProperty FullName

# install it

& MsiExec.exe /i $Installer /q /NoRestart $Parameters /Log $LogFile | Wait-Process

