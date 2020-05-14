[CmdletBinding(DefaultParameterSetName="SingleTest")]
Param(
    [Parameter(Mandatory=$true,Position=1,ParameterSetName="SingleTest")]
    [ValidateRange(0,18)]
    [int]$Test,
    [Parameter(Mandatory=$true,Position=1,ParameterSetName="Batch")]
    [switch]$Batch,
    [Parameter(Mandatory=$true,Position=2,ParameterSetName="Batch")]
    [string]$OutFile
)

Import-Module "$($PSScriptRoot)\PSPerformance.psm1"

if ($Batch) {
    if ($OutFile -notmatch ":\\") {
        $OutFile = "$($PSScriptRoot)\$($Outfile)"   #$OutFile is a filename, Prepend our CWD
    }
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -PercentComplete 0
    $CsvWriter = [System.IO.StreamWriter]::new($OutFile, $false, [System.Text.Encoding]::UTF8)
    $CsvWriter.WriteLine("PowerShell version $($Host.Version)")
    $CsvWriter.WriteLine("Filter vs Where-Object,,,,,,,,ForEach vs For,,,,,,,,ForEach vs .ForEach(),,,,,,,,ForEach vs ForEach-Object,,,,,,,,ForEach vs | ForEach-Object,,,,,,,,Array vs ArrayList,,,,,,,,ArrayList vs Generic List,,,,,,,,Object List vs Type List,,,,,,,,Replace vs Regex.Replace,,,,,,,,Pipes vs Long Form,,,,,,,,String.Insert vs +=,,,,,,,,String.Format vs -f,,,,,,,,Get-Content vs .NET Stream,,,,,,,,[void] vs Out-Null,,,,,,,,Write-Host vs Write-Output,,,,,,,,Write-Output vs [Console]::WriteLine(),,,,,,,,Function vs Code,,,,,,,,Class vs Code,,,,,,,,Path vs Get-ChildItem -Filter")
    $CsvWriter.WriteLine("Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max,Mean,Median,Min,Max")

    #TEST 0
    $LeftTitle = "Filter"
    $RightTitle = "Where-Object"
    $Iterations = 10
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 5
    $Left = Test-Performance -Count $Iterations -ScriptBlock {
        $ObjsA = Get-ChildItem -Path 'C:\Windows\System32' -Filter '*.exe'
    }
    $Right = Test-Performance -Count $Iterations -ScriptBlock {
        $ObjsB = Get-ChildItem -Path 'C:\Windows\System32' | Where-Object {$_.Extension -eq '.exe'}
    }
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")

    #TEST 1
    $LeftTitle = "ForEach"
    $RightTitle = "For"
    $Iterations = 10
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 10
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
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")

    #TEST 2
    $LeftTitle = "ForEach"
    $RightTitle = ".ForEach()"
    $Iterations = 10

    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 15
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
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")

    #TEST 3
    $LeftTitle = "ForEach"
    $RightTitle = "ForEach-Object"
    $Iterations = 10
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 20
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
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")
    
    #TEST 4
    $LeftTitle = "ForEach"
    $RightTitle = "| ForEach-Object"
    $Iterations = 10
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 25
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
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")

    #TEST 5
    $LeftTitle = "Array"
    $RightTitle = "ArrayList"
    $Iterations = 10
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 30
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
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")

    #TEST 6
    $LeftTitle = "ArrayList"
    $RightTitle = "Generic List"
    $Iterations = 10
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 35
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
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")

    #TEST 7
    $LeftTitle = "Object List"
    $RightTitle = "Type List"
    $Iterations = 10
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 40
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
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")

    #TEST 8
    $LeftTitle = "Replace"
    $RightTitle = "Regex.Replace"
    $Iterations = 10
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 45
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
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")

    #TEST 9
    $LeftTitle = "Pipes"
    $RightTitle = "Long Form"
    $Iterations = 10
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 50
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
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")

    #TEST 10
    $LeftTitle = "String.Insert"
    $RightTitle = "+="
    $Iterations = 10
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 55
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
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")

    #TEST 11
    $LeftTitle = "String.Format"
    $RightTitle = "-F"
    $Iterations = 10000
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 60
    $Left = Test-Performance -Count $Iterations -ScriptBlock {
        $String3 = [string]::Format("{0} {1:0.0}", (Get-Random), (Get-Random))
    }
    $Right = Test-Performance -Count $Iterations -ScriptBlock {
       $String4 = "{0} {1:0.0}" -f (Get-Random),(Get-Random)
    }
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")
    
    #TEST 12
    $LeftTitle = "Get-Content"
    $RightTitle = ".NET Stream"
    $Iterations = 1000
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 65
    $Left = Test-Performance -Count $Iterations -ScriptBlock {
        $Stuff = Get-Content C:\Temp\Item1.txt -Encoding UTF8
    }
    $Right = Test-Performance -Count $Iterations -ScriptBlock {
       $StreamReader = [System.IO.StreamReader]::new('C:\Temp\Item1.txt', [System.Text.Encoding]::UTF8)
       $More = $StreamReader.ReadToEnd()
    }
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")

    #TEST 13
    $LeftTitle = "[void]"
    $RightTitle = "Out-Null"
    $Iterations = 10
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 70
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
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")

    #TEST 14
    $LeftTitle = "Write-Host"
    $RightTitle = "Write-Output"
    $Iterations = 10
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 75
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
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")

    #TEST 15
    $LeftTitle = "Write-Output"
    $RightTitle = "[Console]::WriteLine()"
    $Iterations = 10
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 80
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
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")

    #TEST 16
    $LeftTitle = "Function"
    $RightTitle = "Code"
    $Iterations = 10
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 85
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
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")

    #TEST 17
    $LeftTitle = "Class"
    $RightTitle = "Code"
    $Iterations = 10
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 90
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
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")

    #TEST 18
    $LeftTitle = "Path"
    $RightTitle = "Get-ChildItem -Filter"
    $Iterations = 10
    Write-Progress -Id 0 -Activity "Running Performance Comparisons" -CurrentOperation "Pitting $($LeftTitle) against $($RightTitle)..." -PercentComplete 95
    $Left = Test-Performance -Count $Iterations -ScriptBlock {
        Get-ChildItem 'C:\Windows\inf\*.inf'
    }
    $Right = Test-Performance -Count $Iterations -ScriptBlock {
       Get-ChildItem 'C:\Windows\inf' -Filter '*.inf'
    }
    $CsvWriter.Write("$($Left.Mean),$($Left.Median),$($Left.Minimum),$($Left.Maximum),$($Right.Mean),$($Right.Maximum),$($Right.Minimum),$($Right.Maximum),")
    
    #WRAP UP
    $CsvWriter.Close()
} else {
    switch($Test) {
        0 {
            #SETUP
            $LeftTitle = "Filter"
            $RightTitle = "Where-Object"
            $Iterations = 10
    
            Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
    
            #EXECUTE
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

            Write-Host "Pitting $($LeftTitle) against $($RightTitle)..." -ForegroundColor Cyan
    
            #EXECUTE
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
        17 {
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
        18 {
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

    #WRAP UP
    Get-Winner -AName $LeftTitle -AValue $Left.Median -BName $RightTitle -BValue $Right.Median
    Write-Host ""
    Write-Host "Stats for $($LeftTitle)" -ForegroundColor Cyan
    $Left
    Write-Host "Stats for $($RightTitle):" -ForegroundColor Cyan
    $Right
}