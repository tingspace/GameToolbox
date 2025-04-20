[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, HelpMessage="Indicates whether to print debug logs or not")]
    [switch]
    $verbose = $false
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#region <<Logger>>

class Logger
{
    [bool]$DebugMode

    Logger([bool]$logDebug = $false)
    {
        $this.DebugMode = $logDebug
    }

    [void] LogInfo([string] $message)
    {
        $this.WriteLog("INFO", $message)
    }

    [void] LogError([string] $message)
    {
        $this.WriteLog("ERROR", $message)
    }

    [void] LogWarning([string] $message)
    {
        $this.WriteLog("WARN", $message)
    }

    [void] LogDebug([string] $message)
    {
        if ($false -eq $this.DebugMode)
        {
            return
        }
        $this.WriteLog("DEBUG", $message)
    }

    hidden [void] WriteLog([string]$level, [string]$message)
    {
        Write-Host "$($level.ToUpper()): ${message}"
    }
}

$LOGGER = [Logger]::new($verbose)

#endregion


#region <<Main Form Window>>

$form = New-Object System.Windows.Forms.Form
$form.Text = "Games to Install"
$form.Size = New-Object System.Drawing.Point(300, 300)
$form.StartPosition = "CenterScreen"
$form.TopMost = $true

#endregion


#region <<OK Button>>

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(55, 220)
$okButton.Size = New-Object System.Drawing.Size(75, 23)
$okButton.Text = "Install"
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

#endregion


#region <<Cancel Button>>

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(170, 220)
$cancelButton.Size = New-Object System.Drawing.Size(75, 23)
$cancelButton.Text = "Cancel"
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

#endregion


#region <<Helpful list text>>

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10, 20)
$label.Size = New-Object System.Drawing.Size(280, 20)
$label.Text = "The following games will be installed"
$form.Controls.Add($label)

#endregion


#region <<List Box>>

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10, 40)
$listBox.Size = New-Object System.Drawing.Size(260, 20)
$listBox.SelectionMode = "MultiExtended"
$listBox.Height = 160

$games = @{}

$fileContents = Get-Content ".\games.txt"
$appIds = ""
for ($i = 0; $i -lt $fileContents.Length; $i++)
{
    $line = $fileContents[$i]
    if ($line.StartsWith("#"))
    {
        continue
    }

    $pieces = $line -split "->"
    if ($pieces.Length -ne 2)
    {
        $LOGGER.LogError("Game line is in an unexpected format and will be skipped: $line")
        continue
    }

    $name = $pieces[0]
    $appid = 0
    try
    {
        $appid = [int]$pieces[1]
        $games[$name] = $appid

        [void] $listBox.Items.Add($name)
        $appIds = "$appIds/$appid"
    }
    catch [System.Management.Automation.PSInvalidCastException]
    {
        $LOGGER.LogError("App ID for $name is not an integer and will be skipped: $($pieces[1])")
        continue
    }
}

$form.Controls.Add($listBox)

#endregion


#region <<User Interaction>>

$installCmd = "steam://install"
$result = $form.ShowDialog()
if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $LOGGER.LogDebug("Install was clicked")
    $installCmd = "${installCmd}${appIds}"

    $LOGGER.LogDebug("Executing command: ${installCmd}")
    Start-Process $installCmd
}

if ($result -eq [System.Windows.Forms.DialogResult]::Cancel)
{
    $LOGGER.LogDebug("Cancel was clicked")
}

#endregion