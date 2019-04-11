
# Playbook

## Help

Update help and find out how to export/clear/import history.

## Variables & Objects 

```powershell
$info = @{
    ComputerName = "localhost"
    Memory = 1GB
    MaxCpuSpeed = 2000
}
```

```powershell
$info = @(
    @{
        ComputerName = "localhost"
        Memory = 1GB
        MaxCpuSpeed = 2000
    },
    @{
        ComputerName = "server1"
        Memory = 2GB
        MaxCpuSpeed = 2000
    }
)
```

Create a script that gets this data from WMI/CIM, store as file. No function yet.


## Profiles




## Remoting Linux
```powershell
$s = New-PSSession -HostName tom@65.52.133.56
Invoke-Command -Session $s -Command {cat /var/log/nginx/access.log}  | 
    ConvertFrom-Csv -Header remote_addr,remote_user,time_local,request,status,body_bytes_sent,http_referer,http_user_agent,gzip_ratio
```

