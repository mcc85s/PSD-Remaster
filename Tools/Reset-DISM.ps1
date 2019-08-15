
$SVC = "bits" , "wuauserv" , "appidsvc" , "cryptsvc" 

$SVC | % { net stop $_ }

( gci "$Env:ALLUSERSPROFILE\Application Data\Microsoft\Network\Downloader" ).FullName | % { RI $_ -Force }

"SoftwareDistribution" , "system32\catroot2" | % { "$Env:SystemRoot\$_" } | % { RI $_ -Force -Recurse }

"bits" , "wuauserv" | % { sc.exe sdset $_ D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU) }

"$env:windir\System32" | % { cd /d $_ }

"atl" , "urlmon" , "mshtml" , "sdhocvw" , "browseui" , "jscript" , "vbscript" , "scrrun" , "msxml" , "msxml3" , "msxml6" , "actxprxy" , "softpub" , 
"wintrust" , "dssenh" , "rsaenh" , "gpkcsp" , "slbcsp" , "cryptdlg" , "oleaut32" , "ole32" , "shell32" , "initpki" , "wuapi" , "wuaueng" , "wuaueng1" ,
"wucltui" , "wups" , "wups2" , "wuweb" , "qmgr" , "qmgrprxy" , "wucltux" , "muweb" , "wuwebv" | % { regsvr32.exe /s "$( $_ )".dll }

"netsh winsock reset" | % { "$_" ; "$_ proxy" } | % { IEX $_ }

$SVC | % { net start $_ }
