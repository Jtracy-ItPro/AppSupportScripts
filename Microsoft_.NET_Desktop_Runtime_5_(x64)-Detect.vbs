' Detect Windows Desktop Runtime 5 (x64)

' =-=-=-=-==--=

' let's call this 1.2? - JT
' This version uses regex matching.

' This script is designed for a MEMCM detection rule
' If an app with a matching name is found, it will spit out the name.
' If not... there is no output.
' To narrow by architecture, you can exclude or include the appropriate hive.

' This is meant to do partial matches.

'=-=-=-=-=-=-=-

' This is a bundle that includess .Net Core 5 Runtime.

' Note: if you install the .Net Core 5 SDK, you get all components including ASP.

'ok here's the wierd stuff

' If this runtime can get installed via the .Net SDK, then it will have an uninstall entry from the raw MSI, which is hidden from the user.
' If it gets installed with the standalone installer for the Desktop Runtime, it gets two entries. One hidden MSI entry, and one visible EXE entry for the actual bundle installer.
' so look for the MSI if you just want to make sure the runtime is installed, no questions asked. But look for the EXE if you need a functioning uninstaller.

' to make it more confusing, all bundle installers live in the x86 uninstall listing,.

' in contrast, the raw MSI components will live in 32 or 64, matching the actual architecture.

'=-=-=-=-
' Version is in the middle of the string for this app. So I have to do a regex match. You can't use InStr with a wildcard in the middle.

' The app I want to detect

MyAppName = "Microsoft Windows Desktop Runtime - 5\..*(x64)"


'=--=--=-=-==-=-
HKEY_LOCAL_MACHINE = &H80000002
HKEY_CURRENT_USER  = &H80000001
UninstallNative = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
UninstallWow32 = "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"
ProductsNative = "Software\Microsoft\Installer\Products\"
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

' now run the function
' per-user product search

FindApp HKEY_LOCAL_MACHINE, UninstallNative

