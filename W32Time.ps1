$Time    = "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time"
$Servers = <# enter your domain NTP server(s), in csv #>
$Phase   = 3600

SP "$Time\Parameters"                   -Name Type                  -Value NTP
SP "$Time\Config"                       -Name AnnounceFlags         -Value 5
SP "$Time\TimeProviders\NTPServer"      -Name Enabled               -Value 1
SP "$Time\Parameters"                   -Name NTPServer             -Value $Servers
SP "$Time\Config"                       -Name MaxPosPhaseCorrection -Value 3600

"stop" , "start" | % { net $_ w32time }
