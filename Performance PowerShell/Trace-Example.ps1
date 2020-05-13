#region setup and get baseline
Import-Module "c:\Users\scott.corio\Documents\GitHub\MMS-MOA-2020\Performance PowerShell\PSPerformance.psm1"

$Baseline = Test-Performance -Count 10 -ScriptBlock {Get-Service | Where-Object {$_.Status -eq 'Running'}}
$Baseline
#endregion

#region Initial Trace-Command
Trace-Command -Name TypeConversion -ListenerOption Timestamp -Expression {Get-Service | Where-Object {$_.Status -eq 'Running'}} -PSHost
#endregion

#region Trace-Command with Enum Called out
$Running = [System.ServiceProcess.ServiceControllerStatus]::Running
Trace-Command -Name TypeConversion -ListenerOption Timestamp -Expression {Get-Service | Where-Object {$_.Status -eq $Running}} -PSHost
#endregion

#Lets Compare
$Running = [System.ServiceProcess.ServiceControllerStatus]::Running
$Baseline = Test-Performance -Count 10 -ScriptBlock {Get-Service | Where-Object {$_.Status -eq 'Running'}}
$WithEnum = Test-Performance -Count 10 -ScriptBlock {Get-Service | Where-Object {$_.Status -eq $Running}}
Get-Winner -AName 'Baseline' -AValue $Baseline.Median -BName "Enumerated" -BValue $WithEnum.Median
#endregion