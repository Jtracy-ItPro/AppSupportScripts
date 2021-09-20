' Detect .Net Core Runtime 2 (x64)

' =-=-=-=-==--=

' @Jtracy_ItPro - App detection VbScript

' let's call this 1.2
' This version uses regex matching.

' This script is designed to be a MEMCM detection rule
' It scans the uninstall infor in your registry for the app.
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

' The docs are unclear, but it looks like you need .Net Core Runtime 2.x to support apps built with less than 3.0. It's not backwards-compatible.

' There is no Windows Desktop Runtime for 2.0, just Core.

' If you install the .Net Core 2 SDK, you get all runtimes including ASP.

' This all installs side-by side with .Net Core 3, .Net 5, .Net Frameworkk 4.8, and .Net Framework 3.5

' here's the weird stuff concerning the .net installers of today:

' If this runtime gets installed via the .Net SDK, then it will have an uninstall entry from the raw MSI, which is hidden from the user.
' You would have to use the SDK bundle uninstaller to remove it.
' If it gets installed with the standalone installer, it gets two entries. One hidden MSI entry for the lone component, and one visible EXE entry for the actual bundle installer.
' so look for the MSI if you just want to make sure the runtime is installed, no questions asked.
' But look for the EXE if you absolutely require a functioning uninstaller.

' to make it more confusing, all bundle installers live in the x86 uninstall listing. in contrast, the raw MSI components will live in 32 or 64, matching the actual architecture.

'=-=-=-=-

' We need a partial match for this app, due to version in the title.

' Version is in the middle of the string for this app. So I have to do a regex match.
' I can't use InStr with a wildcard in the middle.

' The app I want to detect:

MyAppName = "Microsoft .NET Core Runtime - 2\..*(x64)"

'=--=--=-=-==-=-
HKEY_LOCAL_MACHINE = &H80000002 ' - SYSTEM installs (all users)
HKEY_CURRENT_USER  = &H80000001 ' - Per-user installs
UninstallNative = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" ' - x64 apps here
UninstallWow64 = "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\" ' - x86 apps here
ProductsNative = "Software\Microsoft\Installer\Products\" ' - alternate place to find install info
ProductsSystem = "SOFTWARE\Classes\Installer\Products\"

Set Reg = GetObject("winmgmts://./root/default:StdRegProv")

'========== NEW - Set up the regex
dim MyRegEx
set MyRegEx = new RegExp

MyRegEx.IgnoreCase = true
MyRegEx.Global = true
MYRegEx.Pattern = MyAppName
'=======================================

' Define the function, to be repeated for each key base

Function FindApp (Hive, KeyBase)

	Reg.EnumKey Hive, KeyBase, Results

	For Each Key in Results
		' more weirdness. The bundle uninstaller can be identified by its valid url tab. 
		' because we don't want the bundle this time, we look for the entry with a blank string for the url.
		Reg.GetStringValue Hive, KeyBase & Key, "DisplayName", FoundAppName
		Reg.GetStringValue Hive, KeyBase & Key, "URLInfoAbout", URLInfoAbout

        If (IsNull(FoundAppName)) Then
        ' this is here to protect the regex test from blowing up on blank/null strings. Just filter those out.
		ElseIf (MyRegEx.Test(FoundAppName) and (URLInfoAbout ="")) Then
			wscript.echo FoundAppName
		End If
	Next

End Function

' now run the scan

FindApp HKEY_LOCAL_MACHINE, UninstallNative

