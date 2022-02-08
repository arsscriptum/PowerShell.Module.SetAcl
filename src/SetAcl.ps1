<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
##
##  Some notes:
##    - In github, go to  // Settings / Developer settings / personal access token
##      to add a personal token with scope "Full control of private repositories"
##      and set variable '$access_token' below
##    - Set variable $organisation for your github organisation or username.
##    - When using multiple ssh keys with one or multiple github accounts
##      the keys are in ssh config file (~/.ssh/config), with differents hosts
##      set the '$github_host' variable accordingly
##
##  Quebec City, Canada, MMXXI
#>


function Script:AutoUpdateProgress {
    Write-Progress -Activity $Script:ProgressTitle -Status $Script:ProgressMessage -PercentComplete (($Script:StepNumber / $Script:TotalSteps) * 100)
    if($Script:StepNumber -lt $Script:TotalSteps){$Script:StepNumber++}
}

function Get-ServicePermission {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Service name")]
        [Alias('s')] [string] $ServiceName
      
    )
    $AccessChk = (get-command accesschk.exe).Source
    Write-ChannelMessage "Getting Permission for $ServiceName"
    &"$AccessChk" -l -i -c $ServiceName -nobanner
}

function Set-ServicePermission {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Service name")]
        [Alias('s')] [string] $ServiceName,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Username")]
        [Alias('n')] [string] $User
      
    )
    $TmpFile = (New-TemporaryFile).Fullname
    $SetAcl = (get-command setacl.exe).Source
    $Whoami = (get-command whoami.exe).Source
    $AccessChk = (get-command accesschk.exe).Source
    If( $PSBoundParameters.ContainsKey('User') -eq $False ){
        $User = &"$Whoami"
        Write-Verbose "User not specified so using current $User"
    }
    Write-ChannelMessage "Setting Permission on $ServiceName for $User"
    Write-Verbose "$SetAcl"
    Write-Verbose "-on $ServiceName -ot srv -actn ace -ace `"n:$User;p:full`""
    $Result = &"$SetAcl" -on $ServiceName -ot srv -actn ace -ace "n:$User;p:full" 2> $TmpFile
    if($?){
        Write-ChannelResult "Success"
        &"$AccessChk" -l -i -c $ServiceName -nobanner
    }else{
        $Msg = Get-Content -Path $TmpFile
        Write-ChannelResult "Error $Msg " -Warning
    }
    remove-Item -Path $TmpFile -Force
}


function Set-ServiceOwner {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Service name")]
        [Alias('s')] [string] $ServiceName,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Username")]
        [Alias('n')] [string] $User
      
    )
    $TmpFile = (New-TemporaryFile).Fullname
    $SetAcl = (get-command setacl.exe).Source
    $Whoami = (get-command whoami.exe).Source
    $AccessChk = (get-command accesschk.exe).Source
    If( $PSBoundParameters.ContainsKey('User') -eq $False ){
        $User = &"$Whoami"
        Write-Verbose "User not specified so using current $User"
    }
    Write-ChannelMessage "Setting Owner on $ServiceName for $User"
    Write-Verbose "$SetAcl"
    Write-Verbose "-on $ServiceName -ot srv -actn setowner -ownr `"n:$User`""
    $Result = &"$SetAcl" -on $ServiceName -ot srv -actn setowner -ownr "n:$User" 2> $TmpFile
    if($?){
        Write-ChannelResult "Success"
        &"$AccessChk" -l -i -c $ServiceName -nobanner
    }else{
        $Msg = Get-Content -Path $TmpFile
        Write-ChannelResult "Error $Msg " -Warning
    }
    remove-Item -Path $TmpFile -Force
}


