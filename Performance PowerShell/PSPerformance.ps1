[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true,Position=1)]
    [ValidateRange(0,100)]
    [int]$Test
)

Import-Module "c:\Users\scott.corio\Documents\GitHub\MMS-MOA-2020\Performance PowerShell\PSPerformance.psm1"

switch($Test) {
    0 {
        #SETUP
        $LeftTitle = "Filter"
        $RightTitle = "Where-Object"
        $Iterations = 10

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            $ObjsA = Get-ChildItem -Path 'C:\Windows\System32' -Filter '*.exe'
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
            $ObjsB = Get-ChildItem -Path 'C:\Windows\System32' | Where-Object {$_.Extension -eq '.exe'}
        }

    }
    1 {
        #SETUP
        $LeftTitle = "ForEach"
        $RightTitle = "For"
        $Iterations = 10

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            $x = 1..10000
            foreach ($i in $x) {
                $i += Get-Random
            }
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
            $y = 1..10000
            for ($i = 0; $i -lt 10000; $i++) {
                $y[$i] += Get-Random
            }
        }
    }
    2 {
        #SETUP
        $LeftTitle = "ForEach"
        $RightTitle = ".ForEach()"
        $Iterations = 10

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            $x = 1..10000
            foreach ($i in $x) {
                $i += Get-Random
            }
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
            $y = 1..10000
            $y.ForEach{$_ += Get-Random}
        }
    }
    3 {
        #SETUP
        $LeftTitle = "ForEach"
        $RightTitle = "ForEach-Object"
        $Iterations = 10

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            $x = 1..10000
            foreach ($i in $x) {
                $i += Get-Random
            }
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
            $y = 1..10000
            ForEach-Object -InputObject $y -Process {$_ += Get-Random}
        }
    }
    4 {
        #SETUP
        $LeftTitle = "ForEach"
        $RightTitle = "| ForEach-Object"
        $Iterations = 10

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            $x = 1..10000
            foreach ($i in $x) {
                $i += Get-Random
            }
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
            $y = 1..10000
            $y | ForEach-Object {$_ += Get-Random}
        }
    }
    5 {
        #SETUP
        $LeftTitle = "Array"
        $RightTitle = "ArrayList"
        $Iterations = 10

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            $Array = @()
            for ($i = 0; $i -lt 10000; $i++) {
                $Array += $i
            }
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
            $ArrayList = [System.Collections.ArrayList]::new()
            for($i = 0; $i -lt 10000; $i++) {
                [void]$ArrayList.Add($i)
            }
        }
    }
    6 {
        #SETUP
        $LeftTitle = "ArrayList"
        $RightTitle = "Generic List"
        $Iterations = 10

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            $ArrayList = [System.Collections.ArrayList]::new()
            for($i = 0; $i -lt 10000; $i++) {
                [void]$ArrayList.Add($i)
            }
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
            $List = [System.Collections.Generic.List[Object]]::new()
            for($i = 0; $i -lt 10000; $i++) {
                [void]$List.Add($i)
            }
        }
    }
    7 {
        #SETUP
        $LeftTitle = "Object List"
        $RightTitle = "Type List"
        $Iterations = 10

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            $ObjectList = [System.Collections.Generic.List[Object]]::new()
            for($i = 0; $i -lt 10000; $i++) {
                [void]$ObjectList.Add($i)
            }
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
            $TypeList = [System.Collections.Generic.List[int]]::new()
            for($i = 0; $i -lt 10000; $i++) {
                [void]$TypeList.Add($i)
            }
        }
    }
    8 {
        #SETUP
        $LeftTitle = "Replace"
        $RightTitle = "Regex.Replace"
        $Iterations = 10

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            $Haystack = "The Quick Brown Fox Jumped Over the Lazy Dog 5 Times"
            $Needle = "\ ([\d]*)\ "
            for ($i = 0; $i -lt 10000; $i++) {
                [void]($Haystack -replace $Needle, " $(Get-Random) ")
            }
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
            $Haystack = "The Quick Brown Fox Jumped Over the Lazy Dog 5 Times"
            $Needle = "\ ([\d]*)\ "
            for ($i = 0; $i -lt 10000; $i++) {
                [void]([regex]::Replace($Haystack, $Needle, " $(Get-Random) "))
            }
        }
    }
    9 {
        #SETUP
        $LeftTitle = "Pipes"
        $RightTitle = "Long Form"
        $Iterations = 10

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            $RSa = Get-Service | Where-Object {$_.Status -eq 'Running'} | Select-Object Name
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
           $Services = Get-Service
           $RunningServices = [System.Collections.Generic.List[Object]]::new()
           foreach ($Svc in $Services) {
                if ($Svc.Status -eq 'Running') {
                    [void]$RunningServices.Add($Svc.Name)
               }
           }
           $RSb = $RunningServices.ToArray()
        }
    }
    10 {
        #SETUP
        $LeftTitle = "String.Insert"
        $RightTitle = "+="
        $Iterations = 10

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
           [string]$String1 = ""
           for ($i = 0; $i -lt 10000; $i++) {
               $String1 = $String1.Insert($i, 'A')
           }
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
           [string]$String2 = ""
           for ($i = 0; $i -lt 10000; $i++) {
               $String2 += 'B'
           }
        }
    }
    11 {
        #SETUP
        $LeftTitle = "String.Format"
        $RightTitle = "-F"
        $Iterations = 10000

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            $String3 = [string]::Format("{0} {1:0.0}", (Get-Random), (Get-Random))
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
           $String4 = "{0} {1:0.0}" -f (Get-Random),(Get-Random)
        }
    }
    12 {
        #SETUP
        $LeftTitle = "Get-Content"
        $RightTitle = ".NET Stream"
        $Iterations = 1000

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            $Stuff = Get-Content C:\Temp\Item1.txt -Encoding UTF8
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
           $StreamReader = [System.IO.StreamReader]::new('C:\Temp\Item1.txt', [System.Text.Encoding]::UTF8)
           $More = $StreamReader.ReadToEnd()
        }
    }
    13 {
        #SETUP
        $LeftTitle = "[void]"
        $RightTitle = "Out-Null"
        $Iterations = 10

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            $vl = [System.Collections.Generic.List[int]]::new()
            for ($i = 0; $i -lt 1000; $i++) {
                [void]$vl.Add((Get-Random))
            }
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
            $on = [System.Collections.Generic.List[int]]::new()
            for ($i = 0; $i -lt 1000; $i++) {
                $on.Add((Get-Random)) | Out-Null
            }
        }
    }
    14 {
        #SETUP
        $LeftTitle = "Write-Host"
        $RightTitle = "Write-Output"
        $Iterations = 10

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            for ($i =0; $i -lt 100; $i++) {
                Write-Host "The quick brown fox jumps over the lazy dog"
            }
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
            for ($i =0; $i -lt 100; $i++) {
                Write-Output "The quick brown fox jumps over the lazy dog"
            }
        }
    }
    15 {
        #SETUP
        $LeftTitle = "Write-Output"
        $RightTitle = "[Console]::WriteLine()"
        $Iterations = 10

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            for ($i = 0; $i -lt 100; $i++) {
                Write-Output "The quick brown fox jumps over the lazy dog"
            }
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
           for ($i = 0; $i -lt 100; $i++) {
                [Console]::WriteLine("The quick brown fox jumps over the lazy dog")
            }
        }
    }
    16 {
        #SETUP
        $LeftTitle = ""
        $RightTitle = ""
        $Iterations = 10

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
           
        }
    }
    17 {
        #SETUP
        $LeftTitle = "Function"
        $RightTitle = "Code"
        $Iterations = 10

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            function Get-RandomSquare {
                $r = Get-Random
                return ($r * $r)
            }
            for ($i = 0; $i -lt 1000; $i++) {
                $x = Get-RandomSquare
            }
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
           for ($i = 0; $i -lt 1000; $i++) {
               $s = Get-Random
               $y = ($s * $s)
           }
        }
    }
    18 {
        #SETUP
        $LeftTitle = "Class"
        $RightTitle = "Code"
        $Iterations = 10

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            class MyMath {
                static [int] CountRealHigh() {
                    $x = 0
                    foreach ($i in 1..50000) {
                        $x++
                    }
                    return $x
                }
            }
            [MyMath]::CountRealHigh()
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
            $y = 0
           foreach ($i in 1..50000) {
                $y++
           }
           $y
        }
    }
    19 {
        #SETUP
        $LeftTitle = "Path"
        $RightTitle = "Get-ChildItem -Filter"
        $Iterations = 10

        #EXECUTE
        Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
        $Left = Test-Performance -Count $Iterations -ScriptBlock {
            Get-ChildItem 'C:\Windows\inf\*.inf'
        }
        $Right = Test-Performance -Count $Iterations -ScriptBlock {
           Get-ChildItem 'C:\Windows\inf' -Filter '*.inf'
        }
    }
}

Get-Winner -AName $LeftTitle -AValue $Left.Median -BName $RightTitle -BValue $Right.Median
Write-Host ""
Write-Host "Stats for $($LeftTitle)" -ForegroundColor Cyan
$Left
Write-Host "Stats for $($RightTitle):" -ForegroundColor Cyan
$Right