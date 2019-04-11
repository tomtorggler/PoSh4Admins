#Verbindung zu Exchangeserver aufbauen
$Exchange = connect-exchange -Server server115
#Benutzer filtern für welche die Mailbox aktiviert werden soll
$MailboxToEnable = Get-dcADUser -filter * -Properties UserPrincipalname,EmailAddress,GivenName,msExchMailboxGuid | where {($_.Emailaddress -notlike $NUll) -and ($_.GivenName -notlike $NULL) -and ($_.msExchMailboxGuid -like $NULL)}
#Mailboxaktivierung
foreach ($UserToEnable in $MailboxToEnable){

Enable-Mailbox -Identity $UserToEnable.UserPrincipalname -ErrorAction silentlycontinue


}

Write-Host "User Mailboxen wurden angelegt" -ForegroundColor Green