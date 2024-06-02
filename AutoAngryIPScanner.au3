#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon.ico
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=Auto-AngryIPScanner Portable Network Scanner
#AutoIt3Wrapper_Res_Fileversion=3.9.1.19
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductName=Auto-AngryIPScanner
#AutoIt3Wrapper_Res_ProductVersion=1
#AutoIt3Wrapper_Res_LegalCopyright=Auto-AngryIPScanner
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include "Include\AppUserModelID.au3"
#include "Include\CommonFunctions.au3"

Opt("WinTitleMatchMode", 2)

Global $Title = "AutoAngryIPScanner"
Global $LogTitle = "Log - " & $Title
_Log($Title)

OnAutoItExitRegister("_Exit")

Global $TempPath = @TempDir & "\" & StringReplace($Title, " ", "")
Global $Decompressor = $TempPath & "\7zr.exe"
Global $Package = $TempPath & "\" & $Title & ".7z"
Global $Program = $TempPath & "\jre\bin\javaw.exe"

_Log("")
_Log("$TempPath=" & $TempPath)
_Log("$Decompressor=" & $Decompressor)
_Log("$Package=" & $Package)
_Log("$Program=" & $Program)

_Log("")
_Log("Starting " & $Title)

If FileExists($TempPath) Then
	_Log("Removing " & $TempPath)
	If Not DirRemove($TempPath, 1) Then _Log("DirRemove Failed")
	Sleep(1000)
EndIf

_Log("")
_Log("Preparing Package...")
_Log("DirCreate(" & $TempPath & "): " & DirCreate($TempPath))
_Log("Unbundle 7z: " & FileInstall(".\7zr.exe", $Decompressor, 1))
_Log("Unbundle Archive: " & FileInstall(".\Package.7z", $Package, 1))

_Log("")
_Log("Extracting Archive...")
$Command = '"' & $Decompressor & '" x "' & $Package & '" -o"' & $TempPath & '" -y'
_Log($Command)
RunWait($Command)

_Log("Done...")

;============================================================================

_Log("")
_Log("Starting Program...")

$PrefsKey = "HKEY_CURRENT_USER\Software\JavaSoft\Prefs\ipscan"

RegRead($PrefsKey, "language")
If @error Then
	RegWrite($PrefsKey, "allow/Reports", "REG_SZ", "false")
	RegWrite($PrefsKey, "port/String", "REG_SZ", "21,22,80,443,445,3389,5900,8080")
	RegWrite($PrefsKey, "first/Run", "REG_SZ", "false")
	RegWrite($PrefsKey, "version/Check/Enabled", "REG_SZ", "false")
	RegWrite($PrefsKey, "display/Method", "REG_SZ", "/A/L/I/V/E")
	RegWrite($PrefsKey, "show/Scan/Stats", "REG_SZ", "false")
	RegWrite($PrefsKey, "ask/Scan/Confirmation", "REG_SZ", "false")
	RegWrite($PrefsKey, "selected/Fetchers", "REG_SZ", "fetcher.ip###fetcher.ping###fetcher.hostname###fetcher.ports###fetcher.mac###fetcher.mac.vendor###fetcher.netbios")
EndIf

$PID = ShellExecute($Program, "-cp .\ip net.azib.ipscan.Main", $TempPath, Default, @SW_SHOW)

$hWnd = WinWait("IP Range - Angry IP Scanner", "", 3)
_WindowAppId($hWnd, "5056067070")

$hLogWindow = WinGetHandle($LogTitle)
_WindowAppId($hLogWindow, "5056067070")
WinSetState($hLogWindow, "", @SW_MINIMIZE)

While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			ProcessClose($PID)
	EndSwitch

	If Not ProcessExists($PID) Then
		_Log("Removing " & $TempPath)

		Exit
	EndIf
	Sleep(100)
WEnd

;============================================================================
Func _Exit()
	FileDelete($TempPath)
	DirRemove($TempPath, 1)
	If @error Then _Log("DirRemove Failed")
EndFunc   ;==>_Exit
