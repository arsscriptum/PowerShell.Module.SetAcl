
<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

#===============================================================================
# ChannelProperties
#===============================================================================

class ChannelProperties
{
    #ChannelProperties
    [string]$Channel = 'SETACL'
    [ConsoleColor]$TitleColor = 'DarkCyan'
    [ConsoleColor]$MessageColor = 'DarkGray'
    [ConsoleColor]$ErrorColor = 'DarkRed'
    [ConsoleColor]$SuccessColor = 'DarkGreen'
    [ConsoleColor]$ErrorDescriptionColor = 'DarkYellow'
}
$Script:ChannelProps = [ChannelProperties]::new()


function Write-ChannelMessage{                
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message        
    )

    Write-Host "[$($Script:ChannelProps.Channel)] " -f $($Script:ChannelProps.TitleColor) -NoNewLine
    Write-Host "$Message" -f $($Script:ChannelProps.MessageColor)
}


function Write-ChannelResult{                               
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [switch]$Warning
    )

    if($Warning -eq $False){
        Write-Host "[$($Script:ChannelProps.Channel)] " -f $($Script:ChannelProps.TitleColor) -NoNewLine
        Write-Host "[ OK ] " -f $($Script:ChannelProps.SuccessColor) -NoNewLine
    }else{
        Write-Host "[WARN] " -f $($Script:ChannelProps.ErrorColor) -NoNewLine
    }
    
    Write-Host "$Message" -f $($Script:ChannelProps.MessageColor)
}



function Write-ChannelError{                              
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.ErrorRecord]$Record
    )
    $formatstring = "{0}`n{1}"
    $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
    $ExceptMsg=($formatstring -f $fields)
    Write-Host "[$($Script:ChannelProps.Channel)] " -f $($Script:ChannelProps.TitleColor) -NoNewLine
    Write-Host "[ERROR] " -f $($Script:ChannelProps.ErrorColor) -NoNewLine
    Write-Host "$ExceptMsg`n`n" -ForegroundColor DarkYellow
}

function Get-HttpWebResponseContent
{
<#
    .SYNOPSIS
        Returns the content that may be contained within an HttpWebResponse object.

    .DESCRIPTION
        Returns the content that may be contained within an HttpWebResponse object.

        This would commonly be used when trying to get the potential content
        returned within a failing WebResponse.  Normally, when you call
        Invoke-WebRequest, it returns back a BasicHtmlWebResponseObject which
        directly contains a Content property, however if the web request fails,
        you get a WebException which contains a simpler WebResponse, which
        requires a bit more effort in order to access the raw response content.

    .PARAMETER WebResponse
        An HttpWebResponse object, typically the Response property on a WebException.

    .OUTPUTS
        System.String - The raw content that was included in a WebResponse; $null otherwise.
#>
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [System.Net.HttpWebResponse] $WebResponse
    )

    $streamReader = $null

    try
    {
        $content = $null

        if (($null -ne $WebResponse) -and ($WebResponse.ContentLength -gt 0))
        {
            $stream = $WebResponse.GetResponseStream()
            $encoding = [System.Text.Encoding]::UTF8
            if (-not [String]::IsNullOrWhiteSpace($WebResponse.ContentEncoding))
            {
                $encoding = [System.Text.Encoding]::GetEncoding($WebResponse.ContentEncoding)
            }

            $streamReader = New-Object -TypeName System.IO.StreamReader -ArgumentList ($stream, $encoding)
            $content = $streamReader.ReadToEnd()
        }

        return $content
    }
    finally
    {
        if ($null -ne $streamReader)
        {
            $streamReader.Close()
        }
    }
}

