Dim args, result
Set args = WScript.Arguments

Set objFSO = CreateObject("Scripting.FileSystemObject")

CacheSize = objFSO.GetFolder(".\AppConfig\MusicCache").Size + objFSO.GetFolder(".\AppConfig\OnlineCache").Size
Unit = "B"

If CacheSize >= 1024 And CacheSize < 1048576 Then
    CacheSize = Int(CacheSize / 1024)
    Unit = "KB"
ElseIf CacheSize >= 1048576 And CacheSize < 1073741824 Then
    CacheSize = Int(CacheSize / 1048576)
    Unit = "MB"
ElseIf CacheSize >= 1073741824 Then
    CacheSize = Int(CacheSize / 1073741824)
    Unit = "GB"
End If

WScript.Echo CStr(CacheSize) + " " + Unit
