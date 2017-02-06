# Assign Variables
$i = 1
$i
$i.GetType()

# Single vs. Double quotation marks and variable expansion
'this is $i'
"`$i is $i"

# Types
[int]$a = "hallo"
[string]$b = 123
$b + 1
1 + $b

# Use $() to evaluate expressions within a string
"It‘s $((Get-Date).TimeOfDay)"  
$date = Get-Date
'Date is $date'
"Date is $($date)"

# Arrays
$services = Get-Service
$services | Get-Member

# Auto ForEach
$services | ForEach-Object {$_.Name}
$services.Name

# more Arrays
$myArray = @(1,(Get-Process),(Get-Service))

# Get members of the Array object
,$myArray | Get-Member

# Shows members for Processes
$myArray[1] | Get-Member

# Shows members for Serivces
$myArray[2] | Get-Member

# Hash Tables contain Key=Value pairs
$s1 = [ordered]@{
	Name = “Thomas”; 
	Language = “PowerShell”;
	Age = 28;
}
$s1.Add("Location","Brixen")
$S1.Remove("Age")

$s2 = @{
	Name = “Paul”; 
	Language = “PowerShell”;
	Age = 49;
}
# multiple hash tables can be put into an array
$Students = @($s1,$s2)
# the items in the array can be easily accessed using the new Where method
$Students.Where{$_.Name -eq "Thomas"}.Age

# an alternative way of creating the Array
$Students = @(
    @{
        Name = “Thomas”; 
	    Language = “PowerShell”;
	    Age = 28;
    },
    @{
        Name = “Paul”; 
	    Language = “PowerShell”;
	    Age = 49;
    }
)

# Create objects from test using Import-CSV
$csv = Import-Csv C:\Users\mycsv.txt

# Providers
Get-ChildItem Cert:\LocalMachine\Root | Where-Object Subject -like "*Micro*"
Get-ChildItem HKLM:\SOFTWARE
Get-ItemProperty `
'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' `
-Name CurrentVersion 

# Nested Properties and expressions for dynamic properties
$Vm | Select-Object -Property Name,@{Name="Mac";Expression={($_|Get-NetworkAdapter).MacAddress}}

# Remoting interactive
Enter-PSSession -ComputerName server101
Get-PSSession | Select-Object Name,ComputerName,State,ConfigurationName

# Remoting with sessions and persistence
$session = New-PSSession -ComputerName server101
# non-persistend
Invoke-Command -ComputerName server102 -ScriptBlock {$test = 1}
Invoke-Command -ComputerName server102 -ScriptBlock {$test}
# persistent
Invoke-Command -Session $session -ScriptBlock {$test = 123}
Invoke-Command -Session $session -ScriptBlock {$test}

# Cleanup sessions to free resources
Get-PSSession | Remove-PSSession

# Importing Sessions to make remote cmdlets available locally
$adsession = New-PSSession -ComputerName DC
Invoke-Command -Session $adsession -ScriptBlock {Get-Module}
Invoke-Command -Session $adsession -ScriptBlock { Import-Module ActiveDirectory,Cisco.UCSManager }
# Get-AdUser is not available locally but can be invoked through Invoke-Command
Invoke-Command -Session $adsession -ScriptBlock {Get-AdUser -Filter *}
# Importing the PSSession makes cmdlets available locally
Import-PSSession -Session $adsession -Module ActiveDirectory
Get-ADGroup -Filter * | Get-Member
# Providers will not be made available through importing the remote session
Invoke-Command -Session $adsession -ScriptBlock {Get-PSProvider}
Get-PSProvider

# Remoting with CIM sessions (WMI)
$myServers = New-CimSession -ComputerName @("server101","server102","server103")
Get-Disk -CimSession $myServers | Select-Object *Name
Get-Volume -CimSession $myServers
