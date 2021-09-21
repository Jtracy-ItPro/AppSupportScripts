' Detect Python 3.9 x64 (System install)

' =-=-=-=-==--=

' @Jtracy_ItPro - App detection VbScript

' let's call this 1.2

' This script is designed to be a MEMCM detection rule
' It scans the uninstall info in your registry for the app.
' If an app with a matching name is found, it will spit out the name.
' If not... there is no output.
' your management agent sees if the app is intstalled or not.
' This works for any app that you can see in your installed apps list.

' to find an app for the whole system, scan against HKLM
' to find an app installed for the current user, scan against HKCU
' To find the app irrespective of architecture, just re-run the function against both Native and WOW64 locations
' To find for a specific architecture, just scan against one.

' The reason why it scans registry is because Win32_product is too slow for a detection rule, or anything else.
' The reason why it's VbScript is because it's faster than powershell in this scenario (this part can be debated)

' This script looks for an app, irrespective of version, in cases where file-based and reg-based rules aren't ideal.
' Intended for places that don't use app model for their updates.
' one could easily adapt this to look for a specific version. Example use case - in-house apps.

'=-=-=-=-=-=-=-

' This is for a "SYSTEM" install. I don't know how this works if you do it per-user.

'=-=-=-=-

' even though this might be the x64 version, the uninstall info still lives in wow64 space.

' no partial match needed. We will just look for the exact string.

' The app I want to detect:

MyAppName = "Python Launcher"

' The version I want to detect:

MyVersion = "3.9"

'=--=--=-=-==-=-
HKEY_LOCAL_MACHINE = &H80000002 ' - SYSTEM installs (all users)
HKEY_CURRENT_USER  = &H80000001 ' - Per-user installs
UninstallNative = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" ' - x64 apps here
UninstallWow64 = "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\" ' - x86 apps here
ProductsNative = "Software\Microsoft\Installer\Products\" ' - alternate place to find install info
ProductsSystem = "SOFTWARE\Classes\Installer\Products\"
'=--=--=-=-==-=-

Set Reg = GetObject("winmgmts://./root/default:StdRegProv")

' Define the function, to be repeated for each key base

Function FindApp (Hive, KeyBase)

	Reg.EnumKey Hive, KeyBase, Results

	For Each Key in Results
		Reg.GetStringValue Hive, KeyBase & Key, "DisplayName", FoundAppName
		Reg.GetStringValue Hive, KeyBase & Key, "DisplayVersion", FoundAppVersion

        If ((FoundAppName = MyAppName) and Instr(1,FoundAppVersion,MyVersion)) Then
            wscript.echo FoundAppName
            wscript.echo FoundAppVersion
	    End If     
	Next

End Function

' now run the scan

FindApp HKEY_LOCAL_MACHINE, UninstallWow64

