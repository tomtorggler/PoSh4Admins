. \\dc\NETLOGON\Get-UsersFromCSV.ps1

function Create-ADUser{

        $session = New-PSSession -ComputerName dc

        #Invoke-Command -Session $s -ScriptBlock {import-Module ActiveDirectory}

        Import-PSSession -Session $session -Prefix DC -Module ActiveDirectory
   
        $users = Get-Users

        $accountdetails = @()

        foreach($user in $users){

        $Pass = (([char[]]([char]65..[char]122)) + 0..9 | sort {Get-Random})[0..10] -join ''

        $username = $user.givenname + "." + $user.lastname

        $params_user = @{
            givenname = $user.givenname
            officephone = $user.phone
            department = $user.departement
            emailaddress = $user.givenname + "." + $user.lastname + "@dotr.net"
            surname = $user.lastname
            
            changepasswordatlogon = $true
            enabled = $true
            userprincipalname = $username + "@dotr.net"
            samaccountname = $username
            
            
        }

        $userexists = Get-dcADUser -Filter "Name -like '$username'"

        if($userexists -eq $Null){

        New-dcADUser -Name $username @params_user -accountpassword (ConvertTo-SecureString -AsPlainText $Pass -force)
        "$username $pass"
        
        $details = @{
            username = $username;
            password = $pass;
        }
        $accountdetails += New-Object psobject -Property $details
        
        }
        else{
        
        Set-dcADUser -Identity $username @params_user
      
        
            }
        }
        
    $accountdetails | Export-Csv -Path \\dc\NETLOGON\Password.csv -Delimiter "," -Encoding UTF8 -NoTypeInformation
}