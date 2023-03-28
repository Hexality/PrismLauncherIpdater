using namespace System.Drawing
using namespace System.Windows
using namespace System.Windows.Forms
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$global:ProgressPreference = 'SilentlyContinue'
[Application]::EnableVisualStyles()

##################### Variables #####################
$prism = Join-Path "$((Get-Location).Path)" prismlauncher.exe
#####################################################

##################### Functions #####################
function Wr {
    param ($url)
    
    (Invoke-WebRequest $url -contenttype 'application/json').Content | ConvertFrom-Json
}

function MakeShortcut {
    param ( [string]$Source, [string]$Destination )
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($Destination)
    $Shortcut.TargetPath = $Source
    $Shortcut.WorkingDirectory = "$((Get-Location).Path)"
    $Shortcut.Save()
}
function GetAccent {
    $a = (((reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" /v AccentPalette)[2].Split(' ')) | Sort-Object -Descending)[1]
    @{ 
        0 = "#$($a.Substring(0,6))"
        1 = "#$($a.Substring(8,6))"
        2 = "#$($a.Substring(16,6))"
        3 = "#$($a.Substring(24,6))"
        4 = "#$($a.Substring(32,6))"
        5 = "#$($a.Substring(40,6))"
    }
}
function GetTheme {
    $theme = Get-ItemPropertyValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name AppsUseLightTheme
    $a  = GetAccent
    switch ($theme) {
        '0' {
            #   Dark theme   #
                @{
                    bg = '#323232'
                    ba = '#222222'
                    fg = '#ffffff'
                    fa = '#424242'
                    tx = '#000000'
                    aca = if($null -ne $a.0){$a.0} else{'#89cf54'}
                    acb = if($null -ne $a.1){$a.1} else{'#679c3f'}
                    acc = if($null -ne $a.2){$a.2} else{'#45692a'}
                }
            }
        '1' {
            #  Light theme  #
                @{
                    bg = '#fafafa'
                    ba = '#d6d6d6'
                    fg = '#000000'
                    fa = '#adadad'
                    tx = '#ffffff'
                    aca = if($null -ne $a.5){$a.5} else{'#89cf54'}
                    acb = if($null -ne $a.4){$a.4} else{'#679c3f'}
                    acc = if($null -ne $a.3){$a.3} else{'#45692a'}
                }
            }
        }
}
#####################################################
function Launch {
    #&$prism
    $True
}
function UnpackFile {
    param($installer)
    $s.BackColor = '#5fa5f6'
    $s.FlatAppearance.MouseOverBackColor = '#5fa5f6'
    $s.FlatAppearance.MouseDownBackColor = '#5fa5f6'
    #$progressPreference = 'silentlyContinue'
    $u.Text = "Extracting..."
    $u.Location = [Point]::new(((($o.ClientSize.Width-$u.Size.Width)/2)+1),($o.ClientSize.Height-128))
    $o.Refresh()
    if(-not (Test-Path (Join-Path ((Get-Location).Path) _temp))){
        mkdir (Join-Path ((Get-Location).Path) _old)
    }
    elseif(Test-Path (Join-Path (Join-Path ((Get-Location).Path) _old) *)){
        Remove-Item -Recurse -Force (Join-Path (Join-Path ((Get-Location).Path) _old) *)
    }
    
    Expand-Archive -Path $env:TEMP\pack.zip -DestinationPath (Join-Path ((Get-Location).Path) _temp)
    if((Test-Path * -Exclude updater.ps1,updater.exe,_temp,_old,prismlauncher.cfg,icons,instances,translations)) {
        if(-not (Test-Path (Join-Path ((Get-Location).Path) _old))){
            mkdir (Join-Path ((Get-Location).Path) _old)
        }
        elseif(Test-Path (Join-Path (Join-Path ((Get-Location).Path) _old) *)){
            Remove-Item -Recurse -Force (Join-Path (Join-Path ((Get-Location).Path) _old) *)
        }
        $files = (Get-ChildItem ((Join-Path ((Get-Location).Path) _temp))).name
        foreach($file in $files) {
            Move-Item (Join-Path ((Get-Location).Path) $file) (Join-Path ((Get-Location).Path) _old)
        }
    }
    Move-Item (Join-Path (Join-Path ((Get-Location).Path) _temp) *) . -Force
    $s.BackColor = '#5fa5f6'
    $s.FlatAppearance.MouseOverBackColor = '#5fa5f6'
    $s.FlatAppearance.MouseDownBackColor = '#5fa5f6'
    $u.Text = ""
    $u.Location = [Point]::new((($o.ClientSize.Width-$u.Size.Width)/2),($o.ClientSize.Height-128))
    $o.Refresh()
    $o.Close()
    $o.Dispose()
    Remove-Item $env:TEMP\pack.zip
    if($installer) {
        MakeShortcut 'powershell -executionpolicy bypass -c ".(Join-Path ((Get-Location).Path) Updater.ps1)"' (Join-Path (Join-Path $env:USERPROFILE Desktop) 'Prism Launcher.lnk')
        MakeShortcut 'powershell -executionpolicy bypass -c ".(Join-Path ((Get-Location).Path) Updater.ps1)"' (Join-Path (Join-Path (Join-Path (Join-Path (Join-Path $env:APPDATA Microsoft) Windows) 'Start Menu') Programs) 'Prism Launcher.lnk')
    }
    Launch
}
function GetUpdate {
    param($wr,$installer)
    $s.BackColor = '#e4b524'
    $s.FlatAppearance.MouseOverBackColor = '#e4b524'
    $s.FlatAppearance.MouseDownBackColor = '#e4b524'

    $p = Test-Path (Join-Path ((Get-Location).Path) portable.txt)

    $u.Text = "Downloading..."
    $u.Location = [Point]::new(((($o.ClientSize.Width-$u.Size.Width)/2)+2),($o.ClientSize.Height-128))
    $o.Refresh()
    $outFile = "$(Join-Path $env:TEMP pack.zip)"

    $os = 'Windows'
    $abi = 'MSVC'
    $ly = 'Legacy'
    $arm = 'arm64'
    $tp = 'zip'
    $flt = (($wr.assets.browser_download_url) -match $os -match $abi -match $tp)
    $pb = $flt -match 'Portable'
    $nm = $flt -notmatch 'Portable'

    switch($env:PROCESSOR_ARCHITECTURE) {
        x86     {
            Invoke-WebRequest "$(if($p){$pb -match $ly} else {$nm -match $ly})" -OutFile $outFile }
        AMD64   {
            Invoke-WebRequest "$(if($p){$pb -notmatch "$($ly)|$($arm)"} else {$nm -notmatch "$($ly)|$($arm)"})" -OutFile $outFile }
        ARM64   {
            Invoke-WebRequest "$(if($p){$pb -match $arm} else {$nm -match $arm})" -OutFile $outFile }
    }

    $u.Text = ""
    $s.BackColor = '#5fa5f6'
    $s.FlatAppearance.MouseOverBackColor = '#5fa5f6'
    $s.FlatAppearance.MouseDownBackColor = '#5fa5f6'
    $o.Refresh()
    UnpackFile $installer
}
function InstallMenu {
    param($wr)
    Add-Type -Assembly System.Windows.Forms
    Add-Type -Assembly System.Drawing
    $code = @'
    [System.Runtime.InteropServices.DllImport("gdi32.dll")]
    public static extern IntPtr CreateRoundRectRgn(int nLeftRect, int nTopRect,
        int nRightRect, int nBottomRect, int nWidthEllipse, int nHeightEllipse);
'@
    $rect = Add-Type -MemberDefinition $code -Name "Win32Helpers" -PassThru

    $t = GetTheme

    $base64Icon = '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'
    $base64Logo = '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'

    $iconimageBytes = [Convert]::FromBase64String($base64Icon)
    $imageBytes = [Convert]::FromBase64String($base64Logo)
    $ims = New-Object IO.MemoryStream($iconimageBytes, 0, $iconimageBytes.Length)
    $ms = New-Object IO.MemoryStream($imageBytes, 0, $imageBytes.Length)
    $ims.Write($iconimageBytes, 0, $iconimageBytes.Length);
    $ms.Write($imageBytes, 0, $imageBytes.Length);
    $logo = [System.Drawing.Image]::FromStream($ms, $true)

    $o = [Form]@{
        MinimumSize = [Size]::new(300,420)
        MaximumSize = [Size]::new(300,420)
        BackColor = $t.bg
        ForeColor = $t.fg
        Icon = [System.Drawing.Icon]::FromHandle((new-object System.Drawing.Bitmap -argument $ims).GetHIcon())
        StartPosition = 1
        ControlBox = $False
        FormBorderStyle = 0
        TopMost = 1
    }

    $p = [Button]@{
        Text = "Install"
        Size = [Size]::new(130,32)
        Location = [Point]::new(($o.ClientSize.Width/2)-(130/2),($o.ClientSize.Height-158))
        Anchor = 'Bottom'
        FlatStyle = 'Flat'
        BackColor = $t.aca
        ForeColor = $t.tx
        Font = [Font]::new('Lato', 10)
    }
    $p.FlatAppearance.BorderSize = 0

    $q = [Button]@{
        Text = "Cancel"
        Size = [Size]::new(130,32)
        Location = [Point]::new(($o.ClientSize.Width/2)-(130/2),($o.ClientSize.Height-122))
        Anchor = 'Bottom'
        FlatStyle = 'Flat'
        BackColor = $t.bg
        ForeColor = $t.fg
        Font = [Font]::new('Lato', 9, [FontStyle]::Bold)
    }
    $q.FlatAppearance.BorderSize = 0

    $s = [Button]@{
        BackColor = $t.bg
        Size = [Size]::new(($o.ClientSize.Width-96),8)
        FlatStyle = 'Flat'
        Visible = $False
    }
    $s.Location = [Point]::new((($o.ClientSize.Width-$s.Width)/2),($o.ClientSize.Height-158))
    $s.FlatAppearance.BorderSize = 0
    $s.FlatAppearance.MouseOverBackColor = $t.bg
    $s.FlatAppearance.MouseDownBackColor = $t.bg

    $u = [Label]@{
        Text = ""
        AutoSize = $True
        Anchor = 'Bottom'
        ForeColor = $t.fg
        Font = [Font]::new('Lato', 10)
        Visible = $False
    }
    $u.Location = [Point]::new((($o.ClientSize.Width-$u.Size.Width)/2),($o.ClientSize.Height-128))

    $v = [Label]@{
        Text = "Installing..."
        AutoSize = $True
        Anchor = 'Bottom'
        ForeColor = $t.aca
        Font = [Font]::new('Lato', 11)
        Visible = $False
    }
    $v.Location = [Point]::new(($o.ClientSize.Width/2)-(($u.Size.Width-25)/2),($o.ClientSize.Height-64))

    $w = [PictureBox]@{
        Image = $logo
        Width =  $logo.Size.Width;
        Height =  $logo.Size.Height; 
        Location = [Point]::new((($o.ClientSize.Width+$logo.Size.Width)/9)+1,32)
    }

    $x = [CheckBox]@{
        Text = '    '
        FlatStyle = 'Flat'
        BackColor = $t.ba
        Font = [Font]::new('Lato', 4)
        Size = [Size]::new(18,16)
        AutoSize = $true
        Appearance = 'Button'
    }
    $x.Location = [Point]::new((($o.ClientSize.Width+$x.ClientRectangle.Width-64)/3),($o.ClientSize.Height-$x.ClientRectangle.Height)-40)
    
    $y = [Label]@{
        Text = 'Portable Installation'
        Font = [Font]::new('Lato', 9)
        AutoSize = $True
    }
    $y.Location = [Point]::new(($x.Location.X+$x.Width),$x.Location.Y+1)
    $x.FlatAppearance.BorderSize = 0
    $x.FlatAppearance.CheckedBackColor = $t.aca
    $x.FlatAppearance.MouseOverBackColor = $t.fa
    $x.FlatAppearance.MouseDownBackColor = $t.acb

    $o.add_Load({
        $hrgn = $rect::CreateRoundRectRgn(0,0,$o.Width, $o.Height, 16,16)
        $prnd = $rect::CreateRoundRectRgn(0,0,$p.Width, $p.Height, 4,4)
        $qrnd = $rect::CreateRoundRectRgn(0,0,$q.Width, $q.Height, 4,4)
        $srnd = $rect::CreateRoundRectRgn(0,0,$s.Width, $s.Height, 8,8)
        $crnd = $rect::CreateRoundRectRgn(0,0,$x.Width, $x.Height, 16,16)
        $o.Region = [Region]::FromHrgn($hrgn)
        $p.Region = [Region]::FromHrgn($prnd)
        $q.Region = [Region]::FromHrgn($qrnd)
        $s.Region = [Region]::FromHrgn($srnd)
        $x.Region = [Region]::FromHrgn($crnd)
    })

    $p.add_Click({
        $p.Visible = $False
        $q.Visible = $False
        $x.Visible = $False
        $y.Visible = $False
        $s.Visible = $True
        $u.Visible = $True
        $v.Visible = $False
        $o.Refresh()
        if($x.Checked) {
            "" > (Join-Path ((Get-Location).Path) portable.txt)
        }

        $installer = $True

        GetUpdate $wr $installer
        #Start-Sleep -s 10
        #$o.Close()
        #$o.Dispose()
    })
    $q.add_Click({
        $o.Close()
        $o.Dispose()
    })

    $o.Controls.AddRange(@($p,$q,$r,$s,$u,$v,$w,$x,$y))
    [void]$o.ShowDialog()
    $o.Dispose()
}
function UpdateMenu {
    param($ver,$wr)
    Add-Type -Assembly System.Windows.Forms
    Add-Type -Assembly System.Drawing

    $code = @'
    [System.Runtime.InteropServices.DllImport("gdi32.dll")]
    public static extern IntPtr CreateRoundRectRgn(int nLeftRect, int nTopRect,
        int nRightRect, int nBottomRect, int nWidthEllipse, int nHeightEllipse);
'@
    $rect = Add-Type -MemberDefinition $code -Name "Win32Helpers" -PassThru

    $t = GetTheme

    $base64Icon = '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'
    $base64Logo = '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'

    $iconimageBytes = [Convert]::FromBase64String($base64Icon)
    $imageBytes = [Convert]::FromBase64String($base64Logo)
    $ims = New-Object IO.MemoryStream($iconimageBytes, 0, $iconimageBytes.Length)
    $ms = New-Object IO.MemoryStream($imageBytes, 0, $imageBytes.Length)
    $ims.Write($iconimageBytes, 0, $iconimageBytes.Length);
    $ms.Write($imageBytes, 0, $imageBytes.Length);
    $logo = [System.Drawing.Image]::FromStream($ms, $true)

    $o = [Form]@{
        MinimumSize = [Size]::new(300,420)
        MaximumSize = [Size]::new(300,420)
        BackColor = $t.bg
        ForeColor = $t.fg
        Icon = [System.Drawing.Icon]::FromHandle((new-object System.Drawing.Bitmap -argument $ims).GetHIcon())
        StartPosition = 1
        ControlBox = $False
        FormBorderStyle = 0
        TopMost = 1
    }

    $p = [Button]@{
        Text = "Update"
        Size = [Size]::new(130,32)
        Location = [Point]::new(($o.ClientSize.Width/2)-(130/2),($o.ClientSize.Height-128))
        Anchor = 'Bottom'
        FlatStyle = 'Flat'
        BackColor = $t.aca
        ForeColor = $t.tx
        Font = [Font]::new('Lato', 10)
    }
    $p.FlatAppearance.BorderSize = 0

    $q = [Button]@{
        Text = "Remind me later"
        Size = [Size]::new(130,32)
        Location = [Point]::new(($o.ClientSize.Width/2)-(130/2),($o.ClientSize.Height-92))
        Anchor = 'Bottom'
        FlatStyle = 'Flat'
        BackColor = $t.bg
        ForeColor = $t.fg
        Font = [Font]::new('Lato', 9, [FontStyle]::Bold)
    }
    $q.FlatAppearance.BorderSize = 0

    $r = [Label]@{
        Text = "A new version ($ver) is available."
        AutoSize = $True
        Font = [Font]::new('Lato', 11)
        Anchor = 'Left, right'
    }
    $r.Location = [Point]::new(($o.ClientSize.Width/2)-(($r.Size.Width/2)+56),($o.ClientSize.Height-164))

    $s = [Button]@{
        BackColor = $t.bg
        Size = [Size]::new(($o.ClientSize.Width-96),8)
        FlatStyle = 'Flat'
        Visible = $False
    }
    $s.Location = [Point]::new(($o.ClientSize.Width/2)-(($r.Size.Width/2)+52),($o.ClientSize.Height-158))
    $s.FlatAppearance.BorderSize = 0
    $s.FlatAppearance.MouseOverBackColor = $t.bg
    $s.FlatAppearance.MouseDownBackColor = $t.bg

    $u = [Label]@{
        Text = ""
        AutoSize = $True
        Anchor = 'Bottom'
        ForeColor = $t.fg
        Font = [Font]::new('Lato', 10)
        Visible = $False
    }
    $u.Location = [Point]::new(($o.ClientSize.Width/2)-(($u.Size.Width)/2+10),($o.ClientSize.Height-128))

    $v = [Label]@{
        Text = "Updating..."
        AutoSize = $True
        Anchor = 'Bottom'
        ForeColor = $t.aca
        Font = [Font]::new('Lato', 11)
        Visible = $False
    }
    $v.Location = [Point]::new(($o.ClientSize.Width/2)-(($u.Size.Width-25)/2),($o.ClientSize.Height-64))

    $w = [PictureBox]@{
        Image = $logo
        Width =  $logo.Size.Width;
        Height =  $logo.Size.Height; 
        Location = [Point]::new((($o.ClientSize.Width/2))-($logo.Size.Width/2),32)
    }

    $o.add_Load({
        $hrgn = $rect::CreateRoundRectRgn(0,0,$o.Width, $o.Height, 16,16)
        $prnd = $rect::CreateRoundRectRgn(0,0,$p.Width, $p.Height, 4,4)
        $qrnd = $rect::CreateRoundRectRgn(0,0,$q.Width, $q.Height, 4,4)
        $srnd = $rect::CreateRoundRectRgn(0,0,$s.Width, $s.Height, 8,8)
        $o.Region = [Region]::FromHrgn($hrgn)
        $p.Region = [Region]::FromHrgn($prnd)
        $q.Region = [Region]::FromHrgn($qrnd)
        $s.Region = [Region]::FromHrgn($srnd)
    })

    $p.add_Click({
        Write-Host $True
        $p.Visible = $False
        $q.Visible = $False
        $r.Visible = $False
        $s.Visible = $True
        $u.Visible = $True
        $v.Visible = $False
        $o.Refresh()
        GetUpdate $wr
        #Start-Sleep -s 10
        #$o.Close()
        #$o.Dispose()
    })
    $q.add_Click({
        $o.Close()
        $o.Dispose()
        Launch
    })

    $o.Controls.AddRange(@($p,$q,$r,$s,$u,$v,$w))
    [void]$o.ShowDialog()
    $o.Dispose()
}
function CheckUpdate {
    $lt = @{
        Major = 0
        Minor = 0
    }
    $ct = (Get-Item $prism -ErrorAction SilentlyContinue).VersionInfo.FileVersionRaw
    $wr = Wr 'https://api.github.com/repos/prismlauncher/prismlauncher/releases/latest'
    $lt.Major,$lt.Minor = $wr.tag_name.Split('.')
    if($null -eq $ct) {
        InstallMenu $wr
    } else {
        switch(($ct.Major -lt $lt.Major ) -or ($ct.Minor -lt $lt.Minor)) {
            $True {UpdateMenu "$($lt.Major).$($lt.Minor)" $wr}
            $False {
                Launch
                exit
            }
        }
    }
}
CheckUpdate