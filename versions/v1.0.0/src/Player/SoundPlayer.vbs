' Config
MusicFilesLocation = "..\AppConfig\MusicCache\"
Dim OutputInformation(5)

Function GetMusicData()
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    Set objFile = objFSO.OpenTextFile("mus_data.txt")
    
    Dim Output(4)
    If Not objFile.AtEndOfStream Then Output(0) = objFile.ReadLine Else Output(0) = "unknown.mp3" End If
    If Not objFile.AtEndOfStream Then Output(1) = objFile.ReadLine Else Output(1) = 20 End If
    If Not objFile.AtEndOfStream Then Output(2) = objFile.ReadLine Else Output(2) = "Okay" End If
    If Not objFile.AtEndOfStream Then Output(3) = objFile.ReadLine Else Output(3) = "True" End If
    If Not objFile.AtEndOfStream Then Output(4) = objFile.ReadLine Else Output(4) = "Okay" End If
    objFile.Close

    ' 1 -> File Name + Extension
    ' 2 -> Volume
    ' 3 -> Playback Position
    ' 4 -> On Repeat
    ' 5 -> Play Type

    GetMusicData = Output
End Function

Function GetPlaylistData(PlaylistFile)
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    Set objFile = objFSO.OpenTextFile(MusicFilesLocation & GetMusicData()(0))

    CurrentLine = 0
    Dim Output()

    Do Until objFile.AtEndOfStream
        ReDim Preserve Output(CurrentLine + 1)
        Output(CurrentLine + 1) = MusicFilesLocation & objFile.ReadLine
        CurrentLine = CurrentLine + 1
    Loop

    Output(0) = CurrentLine

    objFile.Close

    GetPlaylistData = Output
End Function

Function CalculateModernTime(Seconds)
    If Seconds >= 60 Then
        Minutes = Int(Seconds / 60)
        SecondsInMinutes = Seconds - (Minutes * 60)
        If SecondsInMinutes < 10 Then
            CalculateModernTime = Minutes & ":0" & SecondsInMinutes
            Exit Function
        Else
            CalculateModernTime = Minutes & ":" & SecondsInMinutes
            Exit Function
        End If
    Else
        If Seconds < 10 Then
            CalculateModernTime = "0:0" & Seconds
            Exit Function
        Else
            CalculateModernTime = "0:" & Seconds
            Exit Function
        End If
    End If

    CalculateModernTime = "0:00"
    Exit Function
End Function

Function RunSoundPlayerMain(StartPlaylistPosition)
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    Set Sound = CreateObject("WMPlayer.OCX.7")
    
    MusicFilesLocation = objFSO.GetAbsolutePathName(MusicFilesLocation) & "\"

    If LCase(objFSO.GetExtensionName(MusicFilesLocation & GetMusicData()(0))) = "mpm" Then
        Sound.URL = GetPlaylistData(MusicFilesLocation & GetMusicData()(0))(StartPlaylistPosition)
    Else
        Sound.URL = MusicFilesLocation & GetMusicData()(0)
    End If

    Sound.Controls.play
    Sound.settings.volume = GetMusicData()(1)

    PlaylistSongPosition = StartPlaylistPosition
    StartTime = Timer

    Do While Sound.playState <> 1
        ' Check
        WScript.sleep(250)
        Elapsed = Int(Timer - StartTime)
        CachedMusicData = GetMusicData()

        ' Update (Read)
        Sound.settings.volume = CachedMusicData(1)

        PreviousMusicData = GetMusicData()
        If CachedMusicData(2) <> "Okay" And CachedMusicData(2) <> "GoBackPrevious" Then
            Sound.Controls.currentposition = Int(CachedMusicData(2))

            On Error Resume Next
            Set objFile = objFSO.CreateTextFile("mus_data.txt", True)
            If Err.Number <> 0 Then
                Err.Clear
            Else
                objFile.WriteLine PreviousMusicData(0)
                objFile.WriteLine PreviousMusicData(1)
                objFile.WriteLine "Okay"
                objFile.WriteLine PreviousMusicData(3)
                objFile.WriteLine PreviousMusicData(4)
                objFile.Close
            End If
            On Error GoTo 0
        ElseIf CachedMusicData(2) = "GoBackPrevious" Then
            On Error Resume Next
            Set objFile = objFSO.CreateTextFile("mus_data.txt", True)
            If Err.Number <> 0 Then
                Err.Clear
            Else
                objFile.WriteLine PreviousMusicData(0)
                objFile.WriteLine PreviousMusicData(1)
                objFile.WriteLine "Okay"
                objFile.WriteLine PreviousMusicData(3)
                objFile.WriteLine PreviousMusicData(4)
                objFile.Close
            End If
            On Error GoTo 0
            
            If LCase(objFSO.GetExtensionName(MusicFilesLocation & CachedMusicData(0))) = "mpm" And CachedMusicData(3) <> "Once" Then
                Set Sound = Nothing
                If PlaylistSongPosition - 1 = 0 Then
                    RunSoundPlayerMain(GetPlaylistData(MusicFilesLocation & GetMusicData()(0))(0))
                Else
                    RunSoundPlayerMain(PlaylistSongPosition - 1)
                End If 
                Exit Function
            Else
                Sound.Controls.currentposition = 0
            End If
        End If
        
        CachedMusicData = GetMusicData()
        If CachedMusicData(3) = "True" Or CachedMusicData(3) = "Once" Then
            If CachedMusicData(3) = "Once" Or LCase(objFSO.GetExtensionName(MusicFilesLocation & CachedMusicData(0))) <> "mpm"  Then
                Sound.settings.setMode "loop", True
            Else
                Sound.settings.setMode "loop", False
            End If
        Else
            Sound.settings.setMode "loop", False
        End If

        CachedMusicData = GetMusicData()
        If CachedMusicData(4) = "0" Then
            Sound.Controls.play
        ElseIf CachedMusicData(4) = "1" Then
            Sound.Controls.pause
        End If
        If CachedMusicData(4) = "0" Or CachedMusicData(4) = "1" Then
            Set objFile = objFSO.CreateTextFile("mus_data.txt", True)
            objFile.WriteLine CachedMusicData(0)
            objFile.WriteLine CachedMusicData(1)
            objFile.WriteLine "Okay"
            objFile.WriteLine CachedMusicData(3)
            objFile.WriteLine "Okay"
            objFile.Close
        End If

        ' Update (Write)
        CachedMusicData = GetMusicData()

        OutputInformation(0) = objFSO.GetBaseName(MusicFilesLocation & CachedMusicData(0)) ' File Name (No Extension)
        If LCase(objFSO.GetExtensionName(MusicFilesLocation & CachedMusicData(0))) = "mpm" Then ' Music Name 
            OutputInformation(1) = objFSO.GetBaseName(MusicFilesLocation & GetPlaylistData(MusicFilesLocation & CachedMusicData(0))(StartPlaylistPosition))
        Else
            OutputInformation(1) = objFSO.GetBaseName(MusicFilesLocation & CachedMusicData(0))
        End If
        OutputInformation(2) = Int(Sound.currentmedia.duration) ' Duration
        OutputInformation(3) = CalculateModernTime(Int(Sound.currentmedia.duration)) ' Duration + Minutes
        OutputInformation(4) = Int(Sound.Controls.currentposition) ' Playback Position
        OutputInformation(5) = CalculateModernTime(Int(Sound.Controls.currentposition)) ' Playback Position + Minutes

        Set objFile = objFSO.CreateTextFile("mus_info.txt", True)
        objFile.WriteLine CStr(OutputInformation(0)) ' File Name (No Extension)
        objFile.WriteLine CStr(OutputInformation(1)) ' Music Name
        objFile.WriteLine CStr(OutputInformation(2)) ' Duration
        objFile.WriteLine CStr(OutputInformation(3)) ' Duration + Minutes
        objFile.WriteLine CStr(OutputInformation(4)) ' Playback Position
        objFile.WriteLine CStr(OutputInformation(5)) ' Playback Position + Minutes
        objFile.Close
    Loop

    If LCase(objFSO.GetExtensionName(MusicFilesLocation & CachedMusicData(0))) = "mpm" And PlaylistSongPosition + 1 <= UBound(GetPlaylistData(MusicFilesLocation & GetMusicData()(0))) Then
        RunSoundPlayerMain(PlaylistSongPosition + 1)
        Exit Function
    End If

    If CachedMusicData(3) = "True" Then
        RunSoundPlayerMain(1)
    Else
        If objFSO.FileExists("mus_data.txt") Then
            On Error Resume Next
            objFSO.DeleteFile "mus_data.txt", True
            On Error Goto 0
        End If
        WScript.Quit
    End If
End Function

RunSoundPlayerMain(1)
