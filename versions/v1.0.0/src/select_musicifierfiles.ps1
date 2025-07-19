Add-Type -AssemblyName System.Windows.Forms

# File Types
$MAF = "Musicifier Audio Files (*.mp3;*.wav)|*.mp3;*.wav"
$MPF = "Musicifier Playlist Files (*.mpm)|*.mpm"
$ASMF = "All Supported Musicifier Files (*.mp3;*.wav;*.mpm)|*.mp3;*.wav;*.mpm"

$dialog = New-Object Windows.Forms.OpenFileDialog
$dialog.Filter = $MAF + "|" + $MPF + "|" + $ASMF

function CacheMPM {
    param(
        [string]$selectedFile
    )

    if ([System.IO.Path]::GetExtension($selectedFile) -ieq ".mpm") {
        $lines = Get-Content -Path $selectedFile
        $first = $true
        $allfiles = ""

        # Read MPM File
        foreach ($line in $lines) {
            $cachePath = Join-Path ".\AppConfig\MusicCache" $line

            if (-not (Test-Path $cachePath)) {
                if ($first -ieq $false) {
                    $allfiles = $allfiles + ";" + $line
                } else {
                    $allfiles = $allfiles + $line
                }
                $first = $false
            }
        }

        # Cache Files
        if ($allfiles -ne "") {
            $filedialog = New-Object Windows.Forms.OpenFileDialog
            $filedialog.Filter = "Playlist Audio Files (*.from-mpm)|" + $allfiles 
            $filedialog.Multiselect = $true

            if ($filedialog.ShowDialog() -ne 'OK') {
                Write-Output "unknownfile"
                exit
            }

            foreach ($file in $filedialog.FileNames) {
                Copy-Item -Path $file -Destination ".\AppConfig\MusicCache\" -Force
            }
        }

        # Check If Cached All Files
        foreach ($line in $lines) {
            $cachePath = Join-Path ".\AppConfig\MusicCache" $line

            if (-not (Test-Path $cachePath)) {
                CacheMPM -selectedFile $selectedFile
            }
        }
    }
}

if ($dialog.ShowDialog() -eq 'OK') {
    $selectedFile = $dialog.FileName
    CacheMPM -selectedFile $selectedFile
    

    Write-Output $selectedFile
} else {
    Write-Output "unknownfile"
}
