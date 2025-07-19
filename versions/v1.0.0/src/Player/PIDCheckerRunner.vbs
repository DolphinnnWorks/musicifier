Set WshShell = CreateObject("WScript.Shell")
WshShell.Run ".\PIDChecker.bat", 0, False
WScript.Quit
