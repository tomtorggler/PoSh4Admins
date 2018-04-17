


function Test-AdCommand {
    [cmdletbinding()]
    param(
        [string]
        $ComputerName = "dc",
        [switch]
        $Import
    )

    Write-Verbose "Name: $($MyInvocation.InvocationName)"
    Write-Verbose $MyInvocation.BoundParameters

    if(Get-Command Get-ADUser -ErrorAction SilentlyContinue) {
        $true
    } elseif($Import) {
        $s = New-PSSession -ComputerName $ComputerName 
        Import-Module (Import-PSSession -Session $s -Module ActiveDirectory) -Global | Out-Null
        $true
    } else {
        $false
    }

}

function Get-Info {
    [cmdletbinding(DefaultParameterSetName="UserInput")]
    param(
        [Parameter(
            ParameterSetName="UserInput",
            Mandatory = $true,
            Position = 0
        )]
        [string]
        $Filter,
        [Parameter(
            ParameterSetName="InputObject",
            Mandatory = $true,
            ValueFromPipeline=$true,
            Position = 0
        )]
        $InputObject,

        [System.IO.FileInfo]
        $LogFile
    )
    process {

        if($Filter) {
            if(!(Test-AdCommand -Import)) {
                Write-Warning "AD commands required!"
            }
            $InputObject = Get-ADComputer -Filter "Name -like '$Filter'" 
        }

        foreach ($server in $InputObject.Name) {
        
            try {
                Write-Verbose "Trying to connect to $Server"
                $s = New-CimSession -ComputerName $server -ErrorAction Stop -Verbose:$false
            } catch {
                Write-Warning "Could not connect to $server"
                continue 
            
            }
            $OS = Get-CimInstance -CimSession $s -ClassName win32_operatingsystem -Verbose:$false
            $BIOS = Get-CimInstance -CimSession $s -ClassName win32_bios -Verbose:$false
            Remove-CimSession -CimSession $s -Verbose:$false

            New-Object -TypeName psobject -Property ([ordered]@{
                "ComputerName" = $server
                "SN" = $BIOS.SerialNumber
                "Version" = $Os.Version
            })    
        }

    }
}



