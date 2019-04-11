# Füge Script zur Nummernormalisierung hinzu
. \\dc\NETLOGON\ConvertTo-NormalizedPhoneNumber.ps1

# CSV Datei einlesen
function Get-UserNamesCSV {

#[CmdletBinding()]

    Write-Verbose "Read Users from CSV-File"

   $UserImport = Import-Csv \\dc\NETLOGON\Benutzer.csv -Delimiter "," -Encoding UTF8
    
    return $UserImport


}

# CSV Datei einlesen
function Get-DepartmentsCSV {

#[CmdletBinding()]

   $Department = Import-Csv \\dc\NETLOGON\Abteilung.csv -Delimiter "," -Encoding UTF8
    
    return $Department

}


function Get-Users{
#[CmdletBinding()]

    $users = Get-UserNamesCSV
    $Departments = Get-DepartmentsCSV

    foreach ($user in $users) {

        $HT = [ordered]@{
            "ID" = $user.id
            "GivenName" = $user.Vorname
            "LastName" = $user.nachname
            "Department" = $Departments | Where-Object -property AbteilungNr -eq $user.Abteilung | select-object -expand Name
            "OfficePhone" = ConvertTo-NormalizedPhoneNumber($user.Telefon)
            "CreateMail" = if ($user.email -eq "ja"){$true}else {$false}
        }
    New-Object -TypeName PsObject -Property $HT
    }

}


<#

function result{

$test1 = Get-Users
$test1
}
#>