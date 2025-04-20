[CmdletBinding()]
param (
    [Parameter(
        Mandatory=$false,
        HelpMessage="Loads the games from a provided file path")]
    [string]
    $LocalFilePath = $null
)

$delimiter = "->"

function ReadFromFile
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $filePath
    )
    Write-Host "Reading from: $filePath"

    if ($false -eq (Test-Path -Path $filePath))
    {
        throw "Could not find a file at: $filePath"
    }

    $appIds = ""
    $contents = Get-Content $filePath
    if ($contents.Length -eq 0)
    {
        throw "The file you gave was empty. The file: $filePath"
    }

    for ($i = 0; $i -lt $contents.Length; $i++)
    {
        $line = $contents[$i]
        if ($line.StartsWith("#"))
        {
            continue
        }

        # TODO: Add Guards
        $pieces = $line -split $delimiter
        if ($pieces.Length -ne 2)
        {
            Write-Host "Unexpected line: $line - Skipping..."
            continue
        }

        $name = $pieces[0]
        try
        {
            $appid = [int]$pieces[1]
            $appIds = "$appIds/$appid"
        }
        catch 
        {
            Write-Host "The AppID value for $name is not an integer. $($pieces[1])"
        }
    }

    return $appIds
}

function ReadFromWeb
{
    $fileUri = "https://raw.githubusercontent.com/tingspace/GameToolbox/refs/heads/main/InstallGames/games.txt"
    Write-Host "Reading from: $fileUri"

    $appids = ""
    $response = Invoke-WebRequest -Uri $fileUri
    if ([System.String]::IsNullOrWhiteSpace($response.Content))
    {
        throw "Received no data when fetching games from: $fileUri"
    }

    $contents = $response.Content -split "`n"
    for ($i = 0; $i -lt $contents.Length; $i++)
    {
        $line = $contents[$i]
        if ($line.StartsWith("#"))
        {
            continue
        }

        $pieces = $line -split $delimiter
        if ($pieces.Length -ne 2)
        {
            Write-Host "Unexpected line... Skipping..."
            Write-Host "The line: $line"
            continue
        }
        $name = $pieces[0]
        $appid = 0

        try {
            $appid = [int]$pieces[1]
            if ($appid -eq 0)
            {
                Write-Host "Unexpected appid for $name -> $appid - Skipping..."
                continue
            }

            $appids = "$appids/$appid"
        }
        catch [System.Management.Automation.PSInvalidCastException] {
            Write-Host "The AppID for $name is not an integer. Value: $($pieces[1])"
            Write-Host "Skipping..."
            continue
        }
    }

    return $appids
}


try
{
    $appIds = ""
    if ([System.String]::IsNullOrWhiteSpace($LocalFilePath))
    {
        $appIds = ReadFromWeb
    }
    else
    {
        $appIds = ReadFromFile -filePath $LocalFilePath
    }

    if ([System.String]::IsNullOrWhiteSpace($appIds))
    {
        throw "No games were found."
    }

    $installCmd = "steam://install$appIds"

    Write-Host "Commanding Steam to install games..."
    Start-Process $installCmd
    Write-Host "DONE!"
}
catch
{
    Write-Host "Failed to find games to install. See details below..."
    Write-Host $_.ToString()
    exit 1
}