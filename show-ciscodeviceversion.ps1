#Import-Csv .\ips.csv | Select-Object -Property Type,Description,@{Name="DeviceIP";Expression={$_.IP}}
function Show-CiscoDeviceVersion {
<#
.Synopsis
Invoke Show Version on NXAPI devices.
.Description
.Parameter ImportFile    
Specify the path to a CSV file in the following format.
IP,Description,Type
172.16.1.90,Bozen1,Router
172.16.1.91,Innsbruck1,Router
.Example
The following example gets "show version" information from the ip 172.16.1.90

Show-CiscoDeviceVersion -DeviceIP 172.16.1.90 - Credential (Get-Credential)
.Example
The following example gets "show version" information from all devices found in the import.csv file.

Show-CiscoDeviceVersion -ImportFile .\import.csv - Credential (Get-Credential)
#>
    [CmdletBinding()]
    param(
        # Specify the IP Address of a device running nxapi.
        [Parameter(Mandatory=$true,
            Position=0,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName="DeviceIP")]
        [System.Net.IPAddress[]]
        [Alias("IP")]
        $DeviceIP,

        [Parameter(Mandatory=$true,
            ParameterSetName="ImportFile")]
        [System.IO.FileInfo]
        $ImportFile,

        # Specify Credentials to connect to the device.
        [Parameter(Mandatory=$true,
            Position=1)]
        [pscredential]
        [Alias("RequestCredential")]
        $Credential
    )
    Begin{
        $RequestContentType = "application/json-rpc"
        $RequestMethod = "Post"
        $RequestBody = @{
            "jsonrpc"= "2.0";
            "method"= "cli";
            "params" = @{
                "cmd"= "show version";
                "version"= 1;
            };
            "id" = 1;
        }
        $startTime = Get-Date
    } # End Begin
    Process{
        if ($ImportFile) {
            try {
                $CsvImport = Import-Csv -Path $ImportFile -ErrorAction Stop
            } catch {
                Write-Warning "Could not import from $ImportFile"
                return
            }
       
            if ($CsvImport) {
            Write-Verbose "Imported $($csvimport.count) lines from $ImportFile"
            $DeviceIP = $CsvImport.IP
            } else {
                Write-Warning "No Objects imported"
                return
            }
        } 
        foreach ($Device in $DeviceIP) {
            if(Test-Connection $Device -Quiet -Count 1) {
                Write-Verbose "ICMP to $Device successful"
                $RequestUri = "http://$Device/ins"
                $Params = @{
                    Uri = $RequestUri;
                    Method = $RequestMethod;
                    Body = ($RequestBody | ConvertTo-Json);
                    ContentType = $RequestContentType;
                    Credential = $Credential;
                    ErrorAction = "Stop";
                }
                try {
                    $Response = Invoke-RestMethod @Params
                    Write-Verbose "Connection to $Device successful"
                }
                catch {
                    Write-Warning "Error connecting to $Device"
                }
            
                $Output = [ordered]@{
                    Hostname = $Response.Result.Body.host_name; 
                    KickStartImage = $Response.Result.Body.kickstart_ver_str;
                    ChassisId = $Response.Result.Body.chassis_id;
                }
            
                New-Object -TypeName psobject -Property $Output | Write-Output
        
            } else {
                Write-Warning "Could not reach $Device"
            }
        }
    } # End Process   
    End {
        $endTime = Get-Date
        $runTime = New-TimeSpan -Start $startTime -End $endTime | Select-Object -ExpandProperty TotalMilliseconds
        Write-Verbose "Runtime was $([math]::round($runTime)) ms"
    }
}