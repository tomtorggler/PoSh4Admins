
function Get-VMInfo {
#Requires -Module VMware.VimAutomation.Core
#Requires -Version 3
<#
.Synopsis
Get Information about a VM.
.Description
Use Get-VM (PowerCLI) to get information.
#>
    [CmdletBinding(
        SupportsShouldProcess=$true,
        HelpURI="https://google.com",
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
            Mandatory=$true,
            Position=1
        )] 
        [System.IO.FileInfo]
        $LogFile

    )

    Begin {}
     
    # required for pipeline input (process block will run for each object)
    Process {
        foreach ($vmName in $Name) {
        Write-Verbose -Message "Current VM is $vmName"
        Write-Debug -Message "`$vmName is $vmName"
        # reset variable $vm 
        $vm = $null

        try {
            # Get VM from PowerCLI
            if ($pscmdlet.ShouldProcess($vmName, "Get Information")){
                $vm = Get-VM -Name $vmName -Debug:$false -ErrorAction Stop
            }
        }
        catch {
            Write-Warning -Message "Could not find VM $vmName `n $_"
        }

        if ($vm) {
        Write-Debug -Message "`$vm is $vm"
            foreach ($v in $vm) {
                Write-Verbose "Creating output for $($v.Name)"
                # Create a HashTable for output
                $output = [ordered]@{
                    Name = $v.Name;
                    MacAddress = $((Get-NetWorkAdapter -VM $v -Debug:$false).MacAddress);
                }
                
                # Create a custom object using the hash table
                $outObject = New-Object `
                    -TypeName PSCustomObject `
                    -Property $output

                Write-Verbose "Writing output for $($V.Name)"
                # and write it to the pipeline
                $outObject | Write-Output 
                }
            }
        }
    } # end Process

    End {}

        
}
