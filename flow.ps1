
function Test-If {

    param([int]$x)

    if ($x -eq 1) {
        "x is 1"
    } elseif ($x -eq 2) {
        "x is 2"
    } else {
        "Something else"
    }
}

function Test-ForEach {

    param([int[]]$x)

    foreach ($i in $x) {
        $i
    }
}

function Test-Switch {
    param($x)

    switch ($x)
    {
        '1' {"x is 1"}
        '2' {"x is 2"}
        {$_ -in 'A','B','C'} {"x is a b or c"}
        Default {"Something else"}
    }
}

Describe "Testing" {
    Context "If" {
        It "Returns x is 1" {
            Test-If -x 1 | Should Be "x is 1"
        }
        It "Returns x is 2" {
            Test-If -x 2 | Should Be "x is 2"
        }
        It "Returns something else" {
            Test-If -x 23 | Should Be "Something else"
        }
    }

    Context "ForEach" {
        It "Returns each item in array" {
            Test-ForEach -x (1..3) | Should Be 1,2,3
        }
        It "Count is same" {
            (Test-ForEach -x (1..3) | Measure-Object).Count | Should Be (1..3).Count
        }
    
    }

    Context "Switch" {
        It "Returns x is 1" {
            Test-Switch -x 1 | Should Be "x is 1"
        }
        It "Returns x is 2" {
            Test-Switch -x 2 | Should Be "x is 2"
        }
        It "Returns something else" {
            Test-Switch -x 23 | Should Be "Something else"
        }
        It "Returns x is a b or c" {
            Test-Switch -x a | Should Be "x is a b or c"
        }
        It "Returns x is a b or c" {
            Test-Switch -x b | Should Be "x is a b or c"
        }
        It "Returns x is a b or c" {
            Test-Switch -x c | Should Be "x is a b or c"
        }
    }
}