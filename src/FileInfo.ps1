
$folderSymbols = @{
    ".git"       = [char]::ConvertFromUtf32(0xF1D3)
    ".idea"      = [char]::ConvertFromUtf32(0xE7B5)
    ".vscode"    = [char]::ConvertFromUtf32(0xE70C)
}

$extensionSymbols = @{
    ".gitignore" = [char]::ConvertFromUtf32(0xF1D3)
    ".zip"       = [char]::ConvertFromUtf32(0xF1C6)
    ".json"      = [char]::ConvertFromUtf32(0xE60B)
    ".py"        = [char]::ConvertFromUtf32(0xE606)
    ".xml"       = [char]::ConvertFromUtf32(0xE60E)
    ".html"      = [char]::ConvertFromUtf32(0xE60E)
    ".go"        = [char]::ConvertFromUtf32(0xE627)
    ".md"        = [char]::ConvertFromUtf32(0xE73E)
    ".scss"      = [char]::ConvertFromUtf32(0xE74B)
    ".sass"      = [char]::ConvertFromUtf32(0xE74B)
    ".coffee"    = [char]::ConvertFromUtf32(0xE74B)
    ".swift"     = [char]::ConvertFromUtf32(0xE755)
    ".ps1"       = [char]::ConvertFromUtf32(0xE795)
    ".psm1"      = [char]::ConvertFromUtf32(0xE795)
    ".psd1"      = [char]::ConvertFromUtf32(0xE795)
    ".cs"        = [char]::ConvertFromUtf32(0xE72E)
    ".fs"        = [char]::ConvertFromUtf32(0xE72E)
    ".vbs"       = [char]::ConvertFromUtf32(0xF40F)
    ".gif"       = [char]::ConvertFromUtf32(0xF40F)
    ".jpg"       = [char]::ConvertFromUtf32(0xF40F)
    ".jpeg"      = [char]::ConvertFromUtf32(0xF40F)
    ".doc"       = [char]::ConvertFromUtf32(0xF1C2)
    ".docx"      = [char]::ConvertFromUtf32(0xF1C2)
    ".xls"       = [char]::ConvertFromUtf32(0xF1C3)
    ".xlsx"      = [char]::ConvertFromUtf32(0xF1C3)
    ".ppt"       = [char]::ConvertFromUtf32(0xF1C4)
    ".pptx"      = [char]::ConvertFromUtf32(0xF1C4)
    ".txt"       = [char]::ConvertFromUtf32(0xF40E)
    ".rb"        = [char]::ConvertFromUtf32(0xE791)
    ".mov"       = [char]::ConvertFromUtf32(0xF1C8)
    ".mp4"       = [char]::ConvertFromUtf32(0xF1C8)
    ".mp3"       = [char]::ConvertFromUtf32(0xF1C7)
    ".wav"       = [char]::ConvertFromUtf32(0xF1C7)
    ".ogg"       = [char]::ConvertFromUtf32(0xF1C7)
    ".ai"        = [char]::ConvertFromUtf32(0xE7B4)
    ".ps"        = [char]::ConvertFromUtf32(0xE7B8)
    ".js"        = [char]::ConvertFromUtf32(0xE74E)
    ".pho"       = [char]::ConvertFromUtf32(0xE73D)
    ".hs"        = [char]::ConvertFromUtf32(0xE61F)
    ".lhs"       = [char]::ConvertFromUtf32(0xE61F)
}

# Helper method to write file length in a more human readable format
function Write-FileLength
{
    param ($length)

    if ($length -eq $null)
    {
        return ""
    }
    elseif ($length -ge 1GB)
    {
        return ($length / 1GB).ToString("F") + 'GB'
    }
    elseif ($length -ge 1MB)
    {
        return ($length / 1MB).ToString("F") + 'MB'
    }
    elseif ($length -ge 1KB)
    {
        return ($length / 1KB).ToString("F") + 'KB'
    }

    return $length.ToString() + '  '
}

function Get-FileSymbolFromName {
    param(
        $name,
        $hashtable,
        $default
    )

    $symbol = $hashtable.Item($name)
    if ($symbol) {
        return " $symbol "
    }
    return $default
}

function Get-FileSymbol
{
    param($file)

    if ($file -is [System.IO.DirectoryInfo]) {
        Get-FileSymbolFromName -name $file.Name -hashtable $folderSymbols -default " $([char]::ConvertFromUtf32(0xF07C)) "
    }
    else {
        Get-FileSymbolFromName -name $file.Extension -hashtable $extensionSymbols -default " $([char]::ConvertFromUtf32(0xF15B)) "
    }

    
}

# Outputs a line of a DirectoryInfo or FileInfo
function Write-Color-LS
{
    param ([string]$color = "white", $file, $symbol)

    Write-host ("{0,-7} {1} {2,10} {3} {4}" -f $file.mode, ([String]::Format("{0,10}  {1,8}", $file.LastWriteTime.ToString("d"), $file.LastWriteTime.ToString("t"))), (Write-FileLength $file.length), $symbol, $file.name) -foregroundcolor $color
}

function FileInfo {
    param (
        [Parameter(Mandatory=$True,Position=1)]
        [System.IO.FileSystemInfo] $file
    )

    $regex_opts = ([System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
	
    $hidden = New-Object System.Text.RegularExpressions.Regex(
        $global:PSColor.File.Hidden.Pattern, $regex_opts)
    $code = New-Object System.Text.RegularExpressions.Regex(
        $global:PSColor.File.Code.Pattern, $regex_opts)
    $executable = New-Object System.Text.RegularExpressions.Regex(
        $global:PSColor.File.Executable.Pattern, $regex_opts)
    $text_files = New-Object System.Text.RegularExpressions.Regex(
        $global:PSColor.File.Text.Pattern, $regex_opts)
    $compressed = New-Object System.Text.RegularExpressions.Regex(
        $global:PSColor.File.Compressed.Pattern, $regex_opts)

    if ($hidden.IsMatch($file.Name))
    {
        Write-Color-LS $global:PSColor.File.Hidden.Color $file -symbol (Get-FileSymbol $file)
    }
    elseif ($file -is [System.IO.DirectoryInfo])
    {
        Write-Color-LS $global:PSColor.File.Directory.Color $file -symbol (Get-FileSymbol $file)
    }
    elseif ($code.IsMatch($file.Name))
    {
        Write-Color-LS $global:PSColor.File.Code.Color $file -symbol (Get-FileSymbol $file)
    }
    elseif ($executable.IsMatch($file.Name))
    {
        Write-Color-LS $global:PSColor.File.Executable.Color $file -symbol (Get-FileSymbol $file)
    }
    elseif ($text_files.IsMatch($file.Name))
    {
        Write-Color-LS $global:PSColor.File.Text.Color $file -symbol (Get-FileSymbol $file)
    }
    elseif ($compressed.IsMatch($file.Name))
    {
        Write-Color-LS $global:PSColor.File.Compressed.Color $file -symbol (Get-FileSymbol $file)
    }
    else
    {
        Write-Color-LS $global:PSColor.File.Default.Color $file -symbol (Get-FileSymbol $file)
    }
}