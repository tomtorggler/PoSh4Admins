function Test-TryCatch {
    param([string]$name,[switch]$skipTry)

    if(!$skipTry) {

        try {
            Get-Process $name -ErrorAction Stop
        }
        catch {
            Write-Warning "That did not work!"    
        }
        
        "The error does not terminate the script"    
    } 
    else {
    
        Get-Process $name -ErrorAction Stop
        "The error terminates the script"
    }
}

Describe "Test Try Catch" {

    It "Does not throw with Try" {
        { Test-TryCatch -Name UnknownProcess } | Should not throw
    }
    It "Does continue execution and return the message" {
        Test-TryCatch -Name UnknownProcess | Should Be "The error does not terminate the script"    
    }
    It "Throws without the Try Block" {
        { Test-TryCatch -Name UnknownProcess -skipTry } | Should throw
    }
}