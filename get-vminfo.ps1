
function Get-VMInfo {
# Requires -Module VMware.VimAutomation.Core
# Requires -Version 3
<#
.Synopsis
Get Information about a VM.
.Description
Use some VMware PowerCLI commands to get information about one or more VMs.
Used to demonstrate basic PowerShell toolmaking. Works on Windows and macOS.
#>
    [CmdletBinding(
        SupportsShouldProcess=$true,
        HelpURI="https://ntsystems.it",
        ConfirmImpact="Medium"
    )]
    param(
        # One or more names of virtual machines to get information for.
        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0
        )]
        [string[]]
        $Name,

        # The filepath to a LogFile
        [Parameter(
            Mandatory=$false,
            Position=1
        )] 
        [System.IO.FileInfo]
        $LogFile = "get-vminfo-log.txt"
    )
    Begin {
        Write-Verbose -Message "Initializing logfile at $LogFile"
        Remove-Item -Path $LogFile -ErrorAction SilentlyContinue
        Write-LogMessage -Path $LogFile -Message "Get-VMInfo started"
    }
     
    # required for pipeline input (process block will run for each object)
    Process {
        foreach ($vmName in $Name) {
            Write-Verbose -Message "Current VM is $vmName"
            Write-Debug -Message "`$vmName is $vmName"
            # reset variable $vm and create an array to collect the output
            $vm = $null
            $outArr = @()
            try {
                # Get VM from PowerCLI
                if ($pscmdlet.ShouldProcess($vmName, "Get Information")){
                    $vm = Get-VM -Name $vmName -Debug:$false -ErrorAction Stop
                }
            } catch {
                Write-Warning -Message "Could not find VM $vmName `n $_"
            }
            # If Get-VM returned something, lets add it to the output
            if ($vm) {
                Write-Debug -Message "`$vm is $vm"
                $outArr += Add-VmToOutArray -InputObject $vm
            }
        }
        Write-Verbose -Message "Output Array contains $($outArr.Count) objects"
        Write-Debug -Message "`$outArr = $outArr"
        $outArr | Sort-Object -Unique -Property Name | Write-Output 
    } # end Process

    End {}        
}
# Supporting functions
function Write-LogMessage {
    param(
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$Path,
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    "$(Get-Date) $Message" | Add-Content -Path $Path -Force
}
function Add-VmToOutArray {
    param(
        [Parameter(Mandatory=$true)]
        [System.Object]$InputObject
    )
    foreach ($vmObj in $InputObject) {
        Write-Verbose "Creating output for $($vmObj.Name)"
        # Create a HashTable for output
        $output = [ordered]@{
            Name = $vmObj.Name;
            MacAddress = $((Get-NetWorkAdapter -VM $vmObj -Debug:$false).MacAddress);
        }

        # Create a custom object using the hash table
        $outObject = New-Object -TypeName PSCustomObject -Property $output
        Write-Verbose "Writing output for $($vmObj.Name)"
        # and write it to the pipeline
        Write-Output -InputObject $outObject
    }
}
