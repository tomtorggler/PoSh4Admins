$proc = Get-CimInstance Win32_Processor
$mem = Get-CimInstance Win32_PhysicalMemoryArray
$vol = Get-CimInstance Win32_Volume

$out = @{
    ComputerName = $env:COMPUTERNAME
    Memory = "$($mem.MaxCapacity / 1MB) GB"
    MaxCpuSpeed = "$($proc.MaxClockSpeed) MHz"
    Volumes = @()
}
foreach($v in $vol) {
    $volObj = New-Object -TypeName psobject -Property @{
        DriveLetter = $v.DriveLetter
        FreeSpace = "$($v.FreeSpace / 1GB) GB"
    }
    $out.Volumes += $volObj
}

New-Object -TypeName psobject -Property $out
