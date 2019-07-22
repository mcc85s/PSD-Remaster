#\\= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =//#
#// /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ \\#
#\\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ //#
#// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = \\#
#\\                                                                                                                                                 //#
#//    <@[ Provision-FTPServer ]@>                                                                                          Michael C. Cook Sr."    \\#
#\\                                                                                                                                                 //#
#// [ Automates the 'Provisioning of an FTP server' . . . $LABOS = "like a boss or somethin'" ]      [ Does that make me one ? Who knows \_(ツ)_/ ]  \\#
#\\                                                                                                                                                 //#
#//= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =\\#
#\\ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ //#
#// \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \\#
#\\ = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = //#

<#
.SYNOPSIS
    Installs the prerequisites necessary to successfully and provision a functional FTP server regardless of whether it is a domain or local.
    

.Description
    Originally written by "Prateek Singh" and found at this link @ https://4sysops.com/archives/install-and-configure-an-ftp-server-with-powershell/
    It is an extensively modified and reworked version that works for either a local FTP server, or an Active Directory Domain Controller

    Had a bit of fun learning how to make some magic happen with PowerShell and Active Directory, essentially what this process does, is it will
    check to see if Active Directory is currently installed, if it is, it will filter options from the Users and Computers section of said directory,
    and make certain that you're not attempting to overwrite a currently existing domain account.

    The original author was utilizing some older methods, which would work if you happen to have LSA enabled, but most network administrators don't
    do that for the obvious reason... that if you're in a domain environment, you should never have LSA enabled. It causes issues with overlapping
    domain accounts and is a security vulnerability if you don't modify that with a GPO template or 'a pretty cool PowerShell Script...

    Ahem... "ADRecon..."

    At any rate, using this script is simply a matter of loading the script and then running the command "Provision-FTPServer"

    At some point I may include a GUI, I have an advanced version of being able to dynamically generate any type of GUI based on array variables.
    It's not ready to deploy openly, so for the time being, feel free to use this at your leisure through the Read-Host input panel.

    - MC

#>
    #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
    #// -[ Declare Namespaces ] @: Shortens some proceeding assembly calls for less redundancy, and you know what? That's pretty cool - - - - - - - //#
    #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
    Using Namespace System.Security.Principal ; #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
    Using Namespace System.Security.AccessControl ; # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
    #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
    Function Provision-FTPServer #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
    {   #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #// -[ Declare Default Values ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        $D = @{ 0 = @( "Site Name" , "Port" , "Root" ; @( "Group" , "Account" | % { "$_ Name" ; "$_ Info" } ) + "Account Password" ) #- - - - - - - \\#
                1 = @( "FTP Site" , "21" , "C:\ftp" , "FTP_USR" , "A collection of wizards" , "Root" , "Badass" , "`$tuff!" ) } #- - - - - - - - - -//#
        #\\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #//- [ Concatenate/Push ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #\\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        $S = @( 0..7 | % { "[ $( $D[0][$_] ) ] Example @: '$( $D[1][$_] )'" } ) #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        $F = @( 0..6 | % { Read-Host "$( $S[$_] )" } ; 7 | % { Read-Host "$( $S[$_] )" -AsSecureString } ) ; ( $S , $D ) = ( $_ ) # - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #// -[ Concatenate/Push ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        $FS = "ftpServer.security"  ; $ADS = "ActiveDirectory" , "AD-Domain-Services" ; $F += "IIS:\Sites\$( $F[0] )" , # - - - - - - - - - - - - - \\#
        "$( $FS ).$( $A = "authentication" )$A.basicA$( $A.TrimStart( 'a' ) ).enabled" , "/system.$( $FS.Replace( "." , "/" ) )/authorization" + # -//#
        @( "control" , "data" | % { "$FS.ssl$_`ChannelPolicy" } ) ; "Name" , "CurrentLocation" #- - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #// -[ Cast Windows Features to an Array & then declare IIS Services ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        $GW = @( Get-WindowsFeature ) # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        ForEach ( $S in ( "-FTP" , "" | % { "Web$_-Server" } ) ) { $GW | ? { $_.Name -eq $S -and $_.InstallState -ne "Installed" } | % { #- - - - - //#
            Install-WindowsFeature $S -IncludeAllSubFeature -IncludeManagementTools } } IPMO WebAdministration  #  - - - - - - - - - - - - - - - - -\\#
        #\\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
        #//- [ Check/Create URI Folder ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
        #\\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
        $F[2] | ? { ( Test-Path $_ ) -ne $True } | % { NI -Path $_ -ItemType Directory ; Echo "Folder [+] $( $F[2] )" } #- - - - - - - - - - - - - -\\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #// -[ Check/Create IIS FTP Site ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        $F[8] | ? { ( Test-Path $_ ) -ne $True } | % { New-WebFtpSite -Name $F[0] -Port $F[1] -PhysicalPath $F[2] ; Echo "FTP [+] $( $F[8] )" }#- - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #// -[ Check for AD , Load AD Module , Set AD Flag ] @: Pst... Cause Active Directory is where you gotta go full 'Boss Mode'- - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        $GW  | ? { $_.Name -eq $ADS[1] -and $_.InstallState -eq "Installed" } | % { IPMO $ADS[0] ; $ADS = 1 # - - - - - - - - - - - - - - - - - - - \\#
        GDR -Name AD | % { $AD = "$( $_.Name ):" ; $DC = $_.CurrentLocation ; $CN = gci $AD\$DN | % { gci $AD\$_ } } } # - - - - - - - - - - - - - -//#
        #\\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #//- [ Set the Local Policy Conditions for non-AD environments ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #\\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        If ( $ADS -eq 0 ) { $G = @{ 0 = GLG  -Name $F[3] -EA 0 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
                                    1 = GLU  -Name $F[5] -EA 0 #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
                                    2 = GLGM -Name $F[3] -EA 0 } } # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #\\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #//- [ Domain Policy - Simplify a way to handle a complicated AD query ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #\\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        If ( $ADS -eq 1 ) { $G = @{ 0 = $CN | ? { $_.Name -eq $F[3] } | Select Name #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
                                    1 = $CN | ? { $_.Name -eq $F[5] } | Select Name # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
                                    2 = $CN | ? { $_.Name -eq $F[3] } | % { Get-ADGroupMember -Identity $_.Name } } } #- - - - - - - - - - - - - - -//#
        #\\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #//- [ I'm sure I could take this part a bit further, but it's whatevs ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #\\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        0..2 | % { If ( $G[$_] -eq $Null ) { $N[$_] = 1 } Else { $N[$_] = 0 } } #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        If ( $N[0] -eq 1 ) { NLG  -Name $F[3] -Description $F[4] } #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        If ( $N[1] -eq 1 ) { NLU  -Name $F[5] -Password    $F[7] -Description         $F[5] -PasswordNeverExpires -UserMayNotChangePassword } #- - -//#
        If ( $ADS  -eq 0 ) { $N[2] | ? { $_ -eq 1 } | % { ALGM -Name $F[3]  -Member   $F[5] } } # - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        If ( $ADS  -eq 1 ) { $N[2] | ? { $_ -eq 1 } | % { Add-ADGroupMember -Identity $F[3] -Members $F[5] } } # - - - - - - - - - - - - - - - - - -//#
        #\\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #//- [ Amazon can't even compete with these kinds of Basic's . . . ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #\\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        SP -Path $F[8] -Name $F[9] -Value  $True # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        Add-WebConfiguration -Filter $F[10] -Value @{ accessType = "Allow" ; roles = $F[3] ; permissions = 1 } -PSPath "IIS:\" -Location $F[0] #- - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #// -[ Tell that Secure Sockets Layer what your 'policy' is gonna be ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        $F[11..12] | % { SP -Path $F[8] -Name $_ -Value $False } #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #// -[ Access Control schematics ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        $NT  = New-Object NTAccount( $F[5] ) #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        $FS  = [ FileSystemAccessRule ]::New( #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
                                        $NT , #.IdentityReference  | Property [2] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
                           "ReadAndExecute" , #.FileSystemRights   | Property [1]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
          "ContainerInherit, ObjectInherit" , #.InheritanceFlags   | Property [3] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
                                     "None" , #.PropogationFlags   | Property [5]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
                                    "Allow" ) #.AccessControlType  | Property [0] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #// -[ Access Control Constructors ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        $ACL = Get-Acl $F[2] ; $ACL.SetAccessRule( $FS ) ; $ACL | Set-Acl -Path $F[2] ; Restart-WebItem $F[8] -VB # - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #// -[ Outro ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        If ( $? -eq $True ) { Echo   "You just set up an FTP server like a boss. That's pretty cool." Read-Host "Press Enter to Exit" ; Exit } #- - \\#
        Else                { Echo "This computer just gave you some sass... Maybe ask more nicely ?" Read-Host "Press Enter to Exit" ; Exit } } # -//#
        #\\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
        #//- [ /Provision-FTPServer ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
        #\\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
