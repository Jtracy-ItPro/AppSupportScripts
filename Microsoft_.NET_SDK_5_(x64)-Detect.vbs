' Detect Microsoft .Net 5 SDK (x64)
' This bundle includes .Net Core, Desktop and ASP runtimes for this architecture.

' =-=-=-=-==--=

' let's call this 1.2? - JT
' This app needs regex matching.

' This script is designed for a MEMCM detection rule
' If an app with a matching name is found, it will spit out the name.
' If not... there is no output.
' To narrow by architecture, you can exclude or include the appropriate hive.

'=-=-=-=-
' Version is in the middle of the string for this app. So I have to do a regex match. I can't use InStr with a wildcard in the middle.

' The app I want to detect. Use a regex for a wildcard that covers the verison.

MyAppName = "Microsoft .NET SDK 5\..*(x64)"

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
		Reg.GetStringValue Hive, KeyBase & Key, "DisplayName", FoundAppName

        If (IsNull(FoundAppName)) Then
        ' do nothing - you have to check null first or else the RegEx methods blow up!
     	ElseIf (MyRegEx.Test(FoundAppName) = -1) Then
			wscript.echo FoundAppName
		End If
	Next

End Function

' now run the scan

FindApp HKEY_LOCAL_MACHINE, UninstallWow32

