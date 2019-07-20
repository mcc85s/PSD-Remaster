#\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
#// /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ \\#
#\\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ //#
#// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
#\\                                                                                                                                                 //#
#//    <@[ Provision-FTPServer ]@>                                                                                         "Michael C. Cook Sr."    \\#
#\\                                                                                                                                                 //#
#//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
#\\ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ //#
#// \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \\#
#\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
# Originally written by a badass known as "Prateek Singh" ... https://4sysops.com/archives/install-and-configure-an-ftp-server-with-powershell/ # - \\#
# Added some 'flavor' and complicated ways to achieve the same end result... just cause I do that sometimes.
# Currently still testing, having issues with [ ADSI ]"WinNT://$Etc..."
# Included the params for localgroup and such, so it might work for others as is. Not certain of that but, feel free to let me know.

    Using Namespace System.Security.Principal ;
    Using Namespace System.Security.AccessControl ;

    Function Provision-FTPServer #\\  [ Designate-FTPServer ] @: Automates the process of 'Provisioning an FTP server like a badass or somethin'    //#
    {   #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
        #// -[ Declare Default Values ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
        $Default = @{  Type = @( "Site Name" , "Port" , "Root" ; @( "Group" , "Acct." | % { "$_ Name" ; "$_ Desc." } ) + "Acct. P/W" ) #- - - - - - //#
                      Value = @( "Default FTP Site" , "21" , "C:\ftp" , "FTP" , "Group" , "Root" , "Badass" , "`$tuff!" | % { "ex. '$_'" } ) } # - -\\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #// -[ Concatenate/Push ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        $Str = @( ForEach ( $i in 0..7 ) { ( $Default | % { "$( $_.Type[$i] ) $( $_.Value[$i] )" } ) } ) #- - - - - - - - - - - - - - - - - - - - - \\#
        $FTP = @( 0..6 | % { Read-Host "$( $Str[$_] )" } ; 7 | % { Read-Host "$( $Str[$_] )" -AsSecureString } ) ; ( $Str , $Default ) = ( $_ ) #- -//#
        #\\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #// [ Complicate the simple things in life ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #\\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        "FTP-Server" , "Server" | % { "Web-$_" } | % { Get-WindowsFeature | ? { $_.Name -eq $i } | % { $_.InstallState -ne "Installed" } | % { # - -//#
            Install-WindowsFeature $i -IncludeAllSubFeature -IncludeManagementTools } } ; IPMO WebAdministration #- - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #// -[ Perform-Magic ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        $FTP[2] | ? { ( Test-Path $_ ) -ne $True } | % { NI -Path $_ -ItemType Directory } #- - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        New-WebFtpSite       -Name $FTP[0] -Port        $FTP[1] -PhysicalPath $FTP[2] #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        New-LocalGroup       -Name $FTP[3] -Description $FTP[4] # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        New-LocalUser        -Name $FTP[4] -Password    $FTP[7] -Description  $FTP[5] -PasswordNeverExpires -UserMayNotChangePassword #- - - - - - -//#
        Add-LocalGroupMember -Name $FTP[3] -Member      $FTP[4] # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #// -[ Concatenate/Push ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        $F = "ftpServer.security" # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\# 
        $FTP += "IIS:\Sites\$( $FTP[0] )" , "$( $f ).$( $a = "authentication" )$a.basicA$( $a.TrimStart( 'a' ) ).enabled" , #- - - - - - - - - - - -//#
               "/system.$( $f.Replace( "." , "/" ) )/authorization" + @( "control" , "data" | % { "$f.ssl$_`ChannelPolicy" } ) #- - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #// -[ Show Amazon that you can craft some 'Basics' too ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        $FTP[9]      | % { SP -Path $FTP[8] -Name $_ -Value  $True } #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        Add-WebConfiguration -Filter $FTP[10] -Value @{ #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
            accessType = "Allow" ; roles = $FTP[3] ; permissions = 1 } -PSPath "IIS:\" -Location $FTP[0] #- - - - - - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #// -[ Tell that Secure Sockets Layer what your 'policy' is gonna be ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        $FTP[11..12] | % { SP -Path $FTP[8] -Name $_ -Value $False }

        $FTP += @( 'ReadAndExecute' , @( "Inherit" | % { "Container$_,Object$_" } ) , 'None' , 'Allow' )

        $FTP += New-Object NTAccount( "$( $FTP[3] )" )
        $FTP += [ FileSystemAccessRule ]::New( $FTP[17] , @( $FTP[13..16] ) )
        $FTP += Get-Acl -Path $FTP[2] ; $FTP[18].SetAccessRule( $FTP[17] ) ; $FTP[18] | Set-Acl -Path $FTP[2]

        Restart-WebItem $FTP[8] -VB
        If ( $? -eq $True ) { Echo "You just provisioned an FTP server like a badass or somethin... that's pretty cool."
                              Read-Host "Press Enter to Exit" }
        Else                { Echo "Your machine said the equivalent of 'Nah bro. It ain't goin down like that today...'"
                              Read-Host "Press Enter to try again at some other point." }
        # $FTP = $Null
        Exit
        }
