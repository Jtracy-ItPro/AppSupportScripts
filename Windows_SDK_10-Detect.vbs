' Detect Windows Software Development Kit 10

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

' The uninstall info lives in WOW64 space, even though this installs components for x64 and x86 both.

' Version is in the name. Use a partial match.

' The app I want to detect:

MyAppName = "Windows Software Development Kit - Windows 10."

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

       If (InStr(1,FoundAppName,MyAppName)) Then
            wscript.echo FoundAppName
		End If
	Next

End Function

' now run the scan

FindApp HKEY_LOCAL_MACHINE, UninstallWow64

