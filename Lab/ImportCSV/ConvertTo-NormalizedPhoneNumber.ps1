
# Alle sonderzeichen entfernen (,/,Leerzeichen ... - bis aufs + am Anfang

# Wenn Länderkürzel dabei = gut
# sonst +39 hinzufügen (Italy first)

# Wenn HandyRange - dann keine Null hinzufügen
# Sonst 0 hinter +39 hinzufügen

# if not +39 als Länderkürzel -> erste 0 streichen

function ConvertTo-NormalizedPhoneNumber() {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string]
        $Number,
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName=$true
        )]
        [object]
        $InputObject
    )
    process{


#    Telecom Italia (TIM): 330 bis 339 und 360 bis 368
#    Vodafone Omnitel: 340 bis 349
#    Wind Tre (inkl. ehemals Wind Telecomunicazioni und Blu): 320 bis 329 und 380 bis 389
#    ehemals: Tre (H3G): 390 bis 393 (gehört seit 1. Januar 2017 zu Wind Tre)

    $mobileRange = 330..339
    $mobileRange += 360..368
    $mobileRange += 340..349
    $mobileRange += 320..329
    $mobileRange += 380..389
    $mobileRange += 390..393



   # write-host "Input: $Number"

        # Clean leading and tailing spaces
        $Number = $Number.Trim()

        #Check if leading +
        $CountryCode = ""

        If ($Number.Substring(0,1) -eq "+") {
            write-verbose "Found leading +"

            If (($Number.Substring(1,1) -eq 1) -or ($Number.Substring(1,1) -eq 7)){
                write-verbose "Found special country Sub-10"
                $CountryCode = $Number.Substring(0,2)
                $Number = $Number.Remove(0,2)
            }
            else {
                $CountryCode = $Number.Substring(0,3)
                $Number = $Number.Remove(0,3)
            }
            
            # Clean all special characters
            
            $Number = $Number -replace '[^0-9]', ''


        }
        else {
            $CountryCode = "+39"
            
            $Number = $Number -replace '[^0-9]', ''
        }


        # Clean 0 from countries other than Italy
        If (($CountryCode -ne "+39") -and ($Number.Substring(0,1) -eq "0")){
            $Number = $Number.Remove(0,1)
        }
        
        #Remove leading 0 by Mobile Numbers
        If (($mobileRange -contains [int]$Number.Substring(1,3)) -and ($Number.Substring(0,1) -eq "0")) {
            $Number = $Number.Remove(0,1)
        }
        return $CountryCode+$Number
    }
}