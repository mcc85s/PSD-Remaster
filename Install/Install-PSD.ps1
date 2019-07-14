#\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
#// /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ \\#
#\\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ //#
#// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
#\\                                                                                                                   //#
#//   <@[ Script-Initialization ]@>                        "Script Magistration by Michael C. 'Boss Mode' Cook Sr."   \\#
#\\                                                                                                                   //#
#//                        [ Secure Digits Plus LLC | Hybrid ] [ Desired State Controller ]                           \\#
#\\                                                                                                                   //#
#//                  [ https://www.securedigitsplus.com | Server/Client | Seedling/Spawning Script ]                  \\#
#\\                                                                                                                   //#
#//                                                                                                                   \\#
#\\# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #//#
#//# [ Declare-Functions ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#\\#
#\\# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #//#

    using namespace System.Security.Principal

    Function Elevate-Script
    {   
        ( [ WindowsPrincipal ] [ WindowsIdentity ]::GetCurrent() ).IsInRole( "Administrators" ) | % {
        
        If ( ( $_ -eq $False ) -and ( ( [ Int ]( gcim Win32_OperatingSystem ).BuildNumber -ge 6000 ) -eq $True ) )
        {   Echo "Attempting [~] Script Elevation" ; Start-Process -FilePath PowerShell.exe -Verb Runas `
        -Args "-File $PSCommandPath $( $MyInvocation.UnboundArguments )"
            If ( $? -eq $True ) { Echo "[+] Elevation Successful" ;  Echo "[+] Access Granted" ; Return }
            Else                { Echo "[!] Elevation Failed" ; Read-Host "[!] Access Denied"  ;   Exit } }
        ElseIf ( $_ -eq $True )
        {   Echo "Access [+] Granted" ; Set-ExecutionPolicy Bypass -Scope Process -Force } }
    }

    $Message = [ Type ] "System.Windows.MessageBox"

#\\ - - [ Echo/Write-Output Wrappers ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #//#

    ( $fs , $bs ) = ( " // " , " \\ " )
    
    Function Wrap-Top { Echo @( " " * 108 ; $fs + "_-" * 52 + $bs ; $bs + " -" * 52 + $fs ) }
    Function Wrap-Bot { Echo @( $bs + " -" * 52 + $fs ; $fs + "_-" * 52 + $bs ; " " * 108 ) }
    Function Wrap-Out { Echo ( $fs + "  " * 52 + $bs ) }
    Function Wrap-In  { Echo ( $bs + "  " * 52 + $fs ) }
    Function Wrap-Title
    { 
        [ CmdLetBinding () ] Param ( 

            [ Parameter ( Position = 0 , Mandatory , ValueFromPipeline = $True ) ]

                [ String ] $Title )

            $th = "[ $Title ]" ; $y  = $th.length ; $x  = 104 - $y
            If ( $x % 4 -ge 2 ) { $x  = $x - 2 ; $y  = $th.replace( "[" , " [ " ) ; $th = $y }
            If ( $x % 2 -ge 1 ) { $x  = $x - 1 ; $y  = $th.replace( "]" , " ]" )  ; $th = $y ; $z  = 0 }
            If ( $z = 1 ) { $z = " -" } Else { $z = "- " } $y = $z * ( $x / 4 ) ; $x = "- " * ( $x / 4 )
            Wrap-Top ; Echo "$( $fs + $x + $th + $y + $bs )"
    }

    Function Wrap-Function 
    {
        [ CmdLetBinding () ] Param ( 

            [ Parameter ( Position = 0 , Mandatory , ValueFromPipeline = $True ) ]

                [ String ] $ID )

            $th = "[ $ID ]" ; $y = $th.length ; $x = 104 - $y ; 
            if ( $x % 4 -ge 2 ) { $x = $x - 2 ; $y = $th.replace( "[" , " [ " ) ; $th = $y }
            if ( $x % 2 -ge 1 ) { $x = $x - 1 ; $y = $th.replace( "]" , " ]" )  ; $th = $y ; $z = 0 }
            if ( $z = 1 ) { $z = " -" } else { $z = "- " } $y = $z * ( $x / 4 ) ; $x = "- " * ( $x / 4 )
        
            Wrap-Top ; Echo "$( $fs + $x + $th + $y + $bs )" ; Wrap-Bot
    }

    Function Wrap-Section
    {
        [ CmdLetBinding () ] Param (

            [Parameter ( Position = 0 , Mandatory , ValueFromPipeline = $True ) ]

                [ String ] $Section )

            $z = $Section ; $x = " " * 10 ; $y = " " * ( 94 - $z.Length )

            Wrap-In ; Echo "$( $fs + $x + $z + $y + $bs )" ; Wrap-In
    }

    Function Wrap-ItemIn
    {
        [ CmdLetBinding () ] Param ( 

            [ Parameter ( Position = 0 , Mandatory , ValueFromPipeline = $True ) ]

                [ String ] $Type,

            [ Parameter ( Position = 1 , Mandatory , ValueFromPipeline = $True ) ]

                [ String ] $Info )
        
            $x = " " * ( 23 - $Type.Length ) ; $y = " " * ( 78 - $Info.Length )

            Echo "$( $bs + $x + $Type ) : $( $Info + $y + $fs )"
    }

    Function Wrap-ItemOut
    {
        [ CmdLetBinding () ] Param (

            [ Parameter ( Position = 0 , Mandatory , ValueFromPipeline = $True ) ]

                [ String ] $Type,

            [ Parameter ( Position = 1 , Mandatory , ValueFromPipeline = $True ) ]

                [ String ] $Info )
        
            $x = " " * ( 23 - $Type.Length ) 
            $y = " " * ( 78 - $Info.Length )

            echo ( $fs + $x + $Type + " : " + $Info + $y + $bs )
    }

    Function Wrap-Array
    {
        [ CmdletBinding () ] Param (

            [ Parameter ( Position = 0 , Mandatory , ValueFromPipeline = $True ) ]

                [ Array ] $Block )
        
                Wrap-Top
                echo $Block
                Wrap-Bot
    }

    Function Wrap-Action 
    {
        [ CmdletBinding () ] Param (

            [ Parameter ( Position = 0 , Mandatory , ValueFromPipeline = $True ) ]

                [ String ] $Type,
    
            [ Parameter ( Position = 1 , Mandatory , ValueFromPipeline = $True ) ]

                [ String ] $Info )

            $x = " " * ( 23 - $Type.Length )
            $y = " " * ( 78 - $Info.Length )
        
            echo @( " " * 108 ; $fs + "_-" * 52 + $bs ; $bs + " -" * 52 + $fs )
            echo @( $fs + $x + $Type +" : " + $Info + $y + $bs )
            echo @( $bs + " -" * 52 + $fs ; $fs + "_-" * 52 + $bs ; " " * 108 )
    }

    Function Test-Credential
    {
        [ CmdLetBinding () ][ OutputType ( [ String ] ) ] Param ( 
        
            [ Parameter ( Mandatory = $False , ValueFromPipeLine = $True , ValueFromPipelineByPropertyName = $True ) ] 
        
                [ Alias ( 'PSCredential' ) ] [ ValidateNotNull () ] 
                
                [ System.Management.Automation.PSCredential ][ System.Management.Automation.Credential () ] $Credentials )
    
        $Domain , $Root , $Username , $Password = @( 0..3 | % { $Null } )

        If ( $Credentials -eq $null )
        {
            Try
            {
                $Credentials = Get-Credential "domain\$env:username" -EA 4
            }

            Catch
            {
                $ErrorMsg = $_.Exception.Message
                Wrap-Action -Type "Exception" -Info "[!] Service Account Validation Failure"
                Read-Host "Press Enter to Exit"
                Exit
            }
        }
        
        Try
        {
            $Username = $Credentials.Username
            $Password = $Credentials.GetNetworkCredential().Password
            $Root     = "LDAP://$( ( [ ADSI ]'').distinguishedName )"
            $Domain   = New-Object System.DirectoryServices.DirectoryEntry( $Root , $UserName , $Password )
        }

        Catch
        {
        
            $_.Exception.Message
            Continue
        }
  
        If ( ! $Domain )
        {
            Wrap-Action -Type "Exception" -Info "[!] Domain does not exist" 

            # Should not occur in really any scenario, but if it does ? 
            # Pst. It'll be 'handled'. BEFORE it even causes a problem . . .
            # Like a Boss who tells people what to do . . ? Pst. 'This' boss sees problems before they even happen . . .
            # That's . . . like . . . some top notch 'upper level management' right there . . .
            
            # Hope I kept my 'upper level management' to a minimum.
            # And if I didn't . . ? Pst . . . Then I'm probably as obnoxious as you think I am, basically.
             
            Wrap-Action -Type "Install" -Info "Active Directory Domain Services to proceed"
            Read-Host "Press Enter to Exit"
            Exit
        }
    
        Else
        {
            If ( $Domain.Name -ne $Null )
            {
                Return "Authenticated"
            }
        
            Else
            {
                Wrap-Action -Type "Exception" -Info "[!] Service Account was not Authenticated"
                Read-Host "Press Enter to Exit"
                Exit
            }
        }
    }

    $Message::Show( "Enter Hybrid Service Account Credential" )
    $DCCred = Get-Credential "$( $Env:UserDomain )\Hybrid"
    If ( ( $DCCred | Test-Credential ) -ne "Authenticated" )
    {
        Exit
    }

    Function Convert-XAMLToWindow 
    { 
        Param ( [ Parameter ( Mandatory ) ] [ String ] $XAML , [ String [] ] $NamedElement = $Null , [ Switch ] $PassThru )

        $AssemblyName = @( "Presentation" | % { "$_`Framework" ; "$_`Core" } ) + "WindowsBase" `
        | % { Add-Type -AssemblyName $_ }

        $Reader = [ XML.XMLReader ]::Create([ IO.StringReader ] $XAML )
        $Output = [ Windows.Markup.XAMLReader ]::Load( $Reader )
    
        $NamedElement | % { $Output | Add-Member -MemberType NoteProperty -Name $_ -Value $Output.FindName( $_ ) -Force }

        If ( $PassThru )  { $Output }

        Else 
        {
            $Null = $GUI.Dispatcher.InvokeAsync{ $Output = $GUI.ShowDialog()            
                Set-Variable -Name Output -Value $Output -Scope 1 }.Wait()
        
        $Output }
    }

    Function Show-WPFWindow
    {
        Param ( [ Parameter ( Mandatory ) ] [ Windows.Window ] $GUI )

        $Output = $Null
                  $Null   = $GUI.Dispatcher.InvokeAsync{ $Output = $GUI.ShowDialog()
                        Set-Variable -Name Output -Value $Output -Scope 1 }.Wait()
        $Output 
    }

    Function Add-ACL
    {
        [ CmdletBinding () ] Param (
        
            [ String ] $Path ,

                [ System.Security.AccessControl.FileSystemAccessRule ] $AceObject )

            $OBJACL =  Get-ACL `
                -Path                                                              $SiteRoot

            $OBJACL.AddAccessRule( $AceObject )       
        
            Set-ACL `
                -Path                                                                  $Path  `
                -AclObject                                                           $OBJACL 
    }

    Function New-ACLObject
    {
        [ CmdletBinding () ] Param (
            [ String ] $SamAccountName ,
                [ System.Security.AccessControl.FileSystemRights  ]               $Permission ,
                [ System.Security.AccessControl.AccessControlType ]  $AccessControl = 'Allow' ,
                [ System.Security.AccessControl.InheritanceFlags  ]    $Inheritance =  'None' ,
                [ System.Security.AccessControl.PropagationFlags  ]    $Propagation =  'None' )
            
            New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule( 

                $SamAccountName , $Permission , $Inheritance , $Propagation , $AccessControl ) 

    }

    Function Get-WIMName 
    {
        [ CmdLetBinding () ] Param (

            [ ValidateNotNullOrEmpty () ]

            [ Parameter ( Mandatory = $True , Position = 0 , ValueFromPipeline = $True ) ]

                [ String ] $IP ,

            [ ValidateNotNullOrEmpty () ]

            [ Parameter ( Position = 1 , ValueFromPipeline = $True ) ]

                [ String ] $ID )
        
        ( Get-WindowsImage -ImagePath $IP ).ImageName 
    
    }

    Function Get-WIMBuild 
    {
        [ CmdLetBinding () ] Param(

            [ ValidateNotNullOrEmpty () ]

            [ Parameter ( Mandatory = $True , Position = 0 , ValueFromPipeline = $True ) ]

                [ String ] $IP ,

            [ ValidateNotNullOrEmpty () ]

            [ Parameter ( Position = 1 , ValueFromPipeline = $True ) ]

                [ String ] $ID )

        ( Get-WindowsImage -ImagePath $IP -Index $ID ).Version
    
    }

    Function Import-NewOSImage 
    {
        [ CmdLetBinding () ] Param (

            [ ValidateNotNullOrEmpty () ]

            [ Parameter ( Mandatory = $True , Position = 0 , ValueFromPipeline = $True ) ]

            [ Alias ( "Path" ) ]

                [ String ] $IP ,

            [ ValidateNotNullOrEmpty () ]

            [ Parameter ( Mandatory = $True , Position = 1 , ValueFromPipeline = $True ) ]

            [ Alias ( "SourceFile" ) ]

                [ String ] $SF ,
                
            [ ValidateNotNullOrEmpty () ]

            [ Parameter ( Mandatory = $True , Position = 2 , ValueFromPipeline = $True ) ]
            
            [ Alias ( "DestinationFolder" ) ]

                [ String ] $DF )

                    Import-MDTOperatingSystem         `
                        -Path                   $IP   `
                        -SourceFile             $SF   `
                        -DestinationFolder      $DF   `
                        -Move                         `
                        -Verbose
    }

    Function Import-NewTask 
    {
        [ CmdLetBinding () ] Param (

            [ ValidateNotNullOrEmpty () ]

                [ Parameter ( Mandatory = $True , Position = 0 , ValueFromPipeline = $True ) ]

                    [ Alias ( "Path" ) ]

                    [ String ] $PSP ,

            [ ValidateNotNullOrEmpty () ]

                [ Parameter ( Mandatory = $True , Position = 1 , ValueFromPipeline = $True ) ]

                    [ Alias ( "Name" ) ]

                    [ String ] $Formal ,

       
            [ ValidateNotNullOrEmpty () ]

                [ Parameter ( Mandatory = $True , Position = 2 , ValueFromPipeline = $True ) ]

                    [ Alias ( "Template" ) ]

                    [ String ] $XML ,


            [ ValidateNotNullOrEmpty () ]

                [ Parameter ( Mandatory = $True , Position = 3 , ValueFromPipeline = $True ) ]

                    [ Alias ( "Comments" ) ]

                    [ String ] $Info ,


            [ ValidateNotNullOrEmpty () ]

                [ Parameter ( Mandatory = $True , Position = 4 , ValueFromPipeline = $True ) ]

                    [ String ] $ID ,

            [ ValidateNotNullOrEmpty () ]

                [ Parameter ( Mandatory = $True , Position = 5 , ValueFromPipeline = $True ) ]

                    [ Alias ( "Version" ) ]

                    [ String ] $Ver ,

            [ ValidateNotNullOrEmpty () ]

                [ Parameter ( Mandatory = $True , Position = 6 , ValueFromPipeline = $True ) ]

                    [ Alias ( "OperatingSystemPath" ) ]

                    [ String ] $SIP ,

            [ ValidateNotNullOrEmpty () ]

                [ Parameter ( Mandatory = $True , Position = 7 , ValueFromPipeline = $True ) ]

                    [ Alias ( "FullName" ) ]

                    [ String ] $TSName ,
                
            [ ValidateNotNullOrEmpty () ]

                [ Parameter ( Mandatory = $True , Position = 8 , ValueFromPipeline = $True ) ]

                    [ Alias ( "OrgName" ) ]

                    [ String ] $Org ,

            [ ValidateNotNullOrEmpty () ]

                [ Parameter ( Mandatory = $True , Position = 9 , ValueFromPipeline = $True ) ]

                    [ Alias ( "HomePage" ) ]

                    [ String ] $WWW ,

            [ ValidateNotNullOrEmpty () ]

                [ Parameter ( Mandatory = $True , Position = 10 , ValueFromPipeline = $True ) ]

                    [ Alias ( "AdminPassword" ) ]

                    [ String ] $LMCred )

        Import-MDTTaskSequence -Path $PSP -Name $Formal -Template $XML -Comments $Info `
            -ID $ID -Version $Ver -OperatingSystemPath $SIP -FullName $TSName -OrgName $Org -HomePage $WWW `
            -AdminPassword $LMCred -VB
    }

    Function Provision-Dependency 
    {
        [ CmdLetBinding () ] Param (
            [ Parameter (  Position = 0 , Mandatory = $True , ValueFromPipeline = $True ) ]
            [ Alias     (     "Application" ) ]                         [ String ]    $ID ,
            [ Parameter (  Position = 1 , Mandatory = $True , ValueFromPipeline = $True ) ]
            [ Alias     (          "Folder" ) ]                         [ String ]  $Path ,
            [ Parameter (  Position = 2 , Mandatory = $True , ValueFromPipeline = $True ) ]
            [ Alias     (        "Filename" ) ]                         [ String ]  $File ,
            [ Parameter (  Position = 3 , Mandatory = $True , ValueFromPipeline = $True ) ]
            [ Alias     ( "ResourceLocator" ) ]                         [ String ]   $URL ,
            [ Parameter (  Position = 4 , Mandatory = $True , ValueFromPipeline = $True ) ]
            [ Alias     (       "Arguments" ) ]                         [ String ]  $Args )

            If ( ( Test-Path $Path ) -ne $True )
            {
                NI $Path -ItemType Directory -Value $Path
                Wrap-Action -Type "Created" -Info "[+] Directory @: $Path"
            }
        
            IWR -Uri $URL -OutFile "$Path\$File"
            Wrap-Action -Type "Installing" -Info $ID
            Wrap-Action -Type "Processing" -Info "This could take a while. Grab a salad or somethin'"
            $Dependency = SAPS -FilePath $File -Args $Args -WorkingDirectory $Path -PassThru 

            For ( $j = 0 ; $j -le 100 ; $j = ( $j + 1 ) % 100 )
            {
                Write-Progress -Activity " [ Installing ] $ID" -PercentComplete $j -Status "$( $j )% Complete"
                Sleep -Milliseconds 250 # Putting computers AND people to sleep since ... 
                                
                If ( $Dependency.HasExited ) 
                {
                    Write-Progress -Activity "[ Installed ]" -Completed
                    Return
                }
            }
    }

    Function Export-Ini 
    {
        [ CmdletBinding () ] Param (                                                                    [     Switch ]      $Append , 
            [ ValidateSet ( "Unicode" , "UTF7" ,    "UTF8" , "UTF32" , "ASCII" , "BigEndianUnicode" , "Default" , "OEM" ) ]
            [ Parameter () ]                                                                            [     String ]    $Encoding ,
            [ ValidateNotNullOrEmpty () ][ ValidatePattern ( '^([a-zA-Z]\:)?.+\.ini$' ) ]
            [ Parameter ( Mandatory = $True ) ]                                  [ String ] $FilePath , [     Switch ]       $Force ,
            [ ValidateNotNullOrEmpty () ][ Parameter ( ValueFromPipeline = $True , Mandatory = $True ) ][  Hashtable ] $InputObject ,
                                                                                                        [     Switch ]    $Passthru )
        Begin   { Wrap-Action -Type "Processing" -Info "$( $MyInvocation.MyCommand.Name )" }
        Process { Wrap-Action -Type    "Writing" -Info "$( $FilePath )"
            If ( $Append ) { $Outfile = Get-Item $FilePath }
            Else { $OutFile = NI -ItemType File -Path $FilePath -Force:$Force } 

            # Using 'force' parameters is generally well received by females . . . but, be sure to use them appropriately.
            # Don't roll your eyes at my script . . . 

            If ( ! ( $OutFile ) ) { Wrap-Action -Type "Exception" -Info "Unable to access file" }
            ForEach ( $q in $InputObject.Keys )
            { 
                If ( ! ( $( $InputObject[$q].GetType().Name ) -eq "Hashtable" ) ) 
                { 
                    Wrap-Action -Type "Key" -Info "[+] $q"
                    AC -Path $OutFile -Value "$q=$( $InputObject[$q] )" -Encoding $Encoding 
                }
                
                Else 
                {
                    Wrap-Action -Type "Section" -Info "[+] $q"
                    AC -Path $OutFile -Value "[$q]" -Encoding $Encoding
                }

                ForEach ( $z in $( $InputObject[$q].Keys | Sort-Object ) )
                { 
                    If ( $z -Match "^Comment[\d]+" ) 
                    {  
                        Wrap-Action -Type "Property" -Info "[+] $z"
                        AC -Path $OutFile -Value "$( $InputObject[$q][$z] )" -Encoding $Encoding 
                    }

                    Else
                    {  
                        Wrap-Action -Type "Key" -Info "[+] $z"
                        AC -Path $OutFile -Value "$z=$( $InputObject[$q][$z] )" -Encoding $Encoding
                    }
                }

                AC -Path $OutFile -Value "" -Encoding $Encoding 
            }

            Wrap-Action -Type "Completed" -Info "$( $MyInvocation.MyCommand.Name ): $FilePath"

            If ( $PassThru ) { Return $OutFile } 
        }
        End { Wrap-Action -Type "Exiting" -Info "$( $MyInvocation.MyCommand.Name )" } 
    }

    Function Display-TrueColors 
    { 
        Wrap-Array -Block @(
        " //                                                                                                          \\ " ;
        " \\        ________________________________________________________________________________________          // " ;
        " //       //                                     |                                                \\         \\ " ;
        " \\       \\   *     *     *     *     *     *   - - - - - - - - - - - - - - - - - - - - - - - - -//         // " ;
        " //       //      *     *     *     *     *      |                                                \\         \\ " ;
        " \\       \\   *     *     *     *     *     *    - - - - - - - - - - - - - - - - - - - - - - - - //         // " ;
        " //       //      *     *     *     *     *      |  [ Dynamically Engineered Digital Security ]   \\         \\ " ;
        " \\       \\   *     *     *     *     *     *   - - - - - - - - - - - - - - - - - - - - - - - - -//         // " ;
        " //       //      *     *     *     *     *      |                                                \\         \\ " ;
        " \\       \\   *     *     *     *     *     *    - - - - - - - - - - - - - - - - - - - - - - - - //         // " ;
        " //       //      *     *     *     *     *      | [ Application Development - Virtualization ]   \\         \\ " ;
        " \\       \\   *     *     *     *     *     *   - - - - - - - - - - - - - - - - - - - - - - - - -//         // " ;
        " //       //      *     *     *     *     *      |       [ Network & Hardware Magistration ]      \\         \\ " ;
        " \\       \\   *     *     *     *     *     *    - - - - - - - - - - - - - - - - - - - - - - - - //         // " ;
        " //       //                                     |                                                \\         \\ " ;
        " \\       \\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//         // " ;
        " //       //                                   {_______________}                                  \\         \\ " ;
        " \\       \\- - - - - - - - - - - - - - - - - - \             / - - - - - - - - - - - - - - - - - //         // " ;
        " //       //                   { __________{ _ _]             [_ _ }__________ }                  \\         \\ " ;
        " \\       \\ - - - - - - - - - - - - - {_______/  H Y B R I D  \______}- - - - - - - - - - - - - -//         // " ;
        " //       //               { _ _ _ _ { _ _ _ _ \               / _ _ _ _ } _ _ _ _ }              \\         \\ " ;
        " \\       \\- - - - - - - - - - - { _ _ _ _ _ _]      B Y      [_ _ _ _ _ _ } - - - - - - - - - - //         // " ;
        " //       //                                                                                      \\         \\ " ;
        " \\       \\ - - - - - - - - - [  S E C U R E   D I G I T S   P L U S   L L C  ] - - - - - - - - -//         // " ;
        " //       //                                                                                      \\         \\ " ;
        " \\       \\- - - - - - - - - -\_______________________________________________/- - - - - - - - - //         // " ;
        " //       //                                                                                      \\         \\ " ;
        " \\       \\ - - - - - -[  0 7 / 1 2 / 2 0 1 9  |  M I C H A E L  C  C O O K  S R . ]- - - - - - -//         // " ;
        " //       //                                                                                      \\         \\ " ;
        " \\       \\______________________________________________________________________________________//         // " ;
        " //                                                                                                          \\ " ;
        " \\                                                                                                          // " ;
        " //                                   [ A heightened sense of security ]                                     \\ " )
    
    Sleep -Seconds 2
    
    }

    Function Display-Foot 
    { 
        Wrap-Array -Block @(
        " //                                                                                                          \\ " ;
        " \\  <@[ Script-Complete ]@>                                                                                 // " ;
        " //                                                                                                          \\ " ;
        " \\                          You've just deployed 'A heightened sense of security.'                          // " ;
        " //                                                                                                          \\ " ;
        " \\                      [ Secure Digits Plus LLC | Hybrid ] [ Desired State Controller ]                    // " ;
        " //                                                                                                          \\ " ;
        " \\                                   [ https://www.securedigitsplus.com ]                                   // " ;
        " //                                                                                                          \\ " )
        Read-Host "Press Enter to exit" 
    }

 Function Load-GUIModule
 {
    [ Net.ServicePointManager ]::SecurityProtocol = [ Net.SecurityProtocolType ]::TLS12
    $Background = "$Home\Downloads\sdp-bg.jpg"
    $Banner     = "$Home\Downloads\banner.png"
    
    $Named = @( 0..4 | % { "r$_" } ; 0..2 | % { "iis$_" } ; 0..2 | % { "dc$_" } ; 0..3 | % { "p$_" } ; 0..1 | % { "img$_" } ; 0 | % { "n$_" } )

    $T0_Tags  = "" , "" , "System Root 'C:\'" , "Deploy Root 'Secured'" , "SMB Name 'Secured$'" , "PSDrive 'Secured:'" , "Share Description '[Dev]'" ,
                "" , "" , "BITS / IIS Name 'Hybrid'" , "IIS App Pool 'SecureApp'" , "Virtual Host / Proxy" , 
                "" , "" , "NetBIOS Domain" , "Child Admin User" , "Child Admin P/W"

    $T0_Offs  = @( "" ; "" ; @( $Named[0..4] ) + "" ; "" ; @( $Named[5..7] ) + "" ; "" ; @( $Named[8..10] ) )

    $T0_List  = @{

    RowDef    = @( 0..16 | % {

    "                            <RowDefinition Height                    =                               '*' />
    "})

    TextBlock = @( 2..6 + 9..11 + 14..16 | % {

    "                      <TextBlock 
                                                Grid.Row             =                                '$_' 
                                                Grid.Column          =                                '0' 
                                                Margin               =                                '5' 
                                                FontSize             =                               '12' 
                                                HorizontalAlignment  =                           'Center'
                                                Foreground           =                             'Black' >
                                                <TextBlock.Effect>
                                                    <DropShadowEffect
                                                        ShadowDepth  =                                '3' 
                                                        Color        =                             'Cyan' />
                                                </TextBlock.Effect>
                                                    $( $T0_Tags[$_] )
                           </TextBlock>
    "
    })

    TextBoxes = @( 2..6 + 9..11 + 14..15 | % { 

    "                       <TextBox  
                                                Name                 =                               '$( $T0_Offs[$_] )' 
                                                Grid.Row             =                               '$_' 
                                                Grid.Column          =                                '1' 
                                                Margin               =                                '5' 
                                                Height               =                               '20' 
                                                FontSize             =                               '10' />
    "
    }) +
                @( 16 | % { 

    "                       <PasswordBox 
                                                Name                 =                               '$( $T0_Offs[$_] )'
                                                Grid.Row             =                               '$_' 
                                                Grid.Column          =                                '1' 
                                                Margin               =                                '5' 
                                                Height               =                               '20' 
                                                FontSize             =                               '10' 
                                                PasswordChar         =                                '*' >
                            </PasswordBox>
    "
    })}

    $T1_Tags  = @( "" ; "Company Name" ; @( "Website" , "Phone" , "Hours" | % { "Support $_" ; } ) + "" ; `
                "Logo [ 120x120.bmp ]" ; "Background" ; "" ; "Branch / FQDN" )

    $T1_Offs  = @( "" ; @( $Named[11..14] ) + "" ; @( $Named[15..16] ) + "" ; $( $Named[17] ) )

    $T1_List  = @{

    RowDef    = @( 0..10 | % { 
    "                            <RowDefinition Height                    =                               '32' /> " })

    TextBlock = @( 1..4 + 6 , 7 , 9 | % {  
    "                      <TextBlock 
                                                Grid.Row             =                                '$_' 
                                                Grid.Column          =                                '0' 
                                                HorizontalAlignment  =                           'Center' 
                                                VerticalAlignment    =                           'Center' 
                                                FontSize             =                               '12' 
                                                Margin               =                                '5'
                                                Foreground           =                             'Lime' >
                                                <TextBlock.Effect>
                                                    <DropShadowEffect
                                                        ShadowDepth  =                                '2' 
                                                        Color        =                             'Cyan' />
                                                </TextBlock.Effect>
                                                    $( $T1_Tags[$_] )
                           </TextBlock>
    "})

    TextBoxes = @( 1..4 + 6 , 7 , 9 | % { 

    "                       <TextBox 
                                                Name                 =                               '$( $T1_Offs[$_] )'
                                                Grid.Row             =                                '$_' 
                                                Grid.Column          =                                '1' 
                                                Height               =                               '20' 
                                                FontSize             =                               '10' 
                                                Margin               =                                '5' />
    "
    })}

    $XAMLRoot = @"
<Window
                xmlns                 =       'http://schemas.microsoft.com/winfx/2006/xaml/presentation'
                xmlns:x               =                    'http://schemas.microsoft.com/winfx/2006/xaml'
                Title                 =    '[ Secure Digits Plus LLC | Hybrid ] Desired State Controller' 
                Width                 =                                                             '640' 
                Height                =                                                             '850' 
                WindowStartupLocation =                                                    'CenterScreen'
                Topmost               =                                                            'True' 
                HorizontalAlignment   =                                                          'Center'
                ResizeMode            =                                                        'NoResize'  >
    <StackPanel>
        <StackPanel.Background>
            <ImageBrush ImageSource   =                                                     '$Background' 
                        Stretch       =                                                   'UniformToFill' />
        </StackPanel.Background>
        <StackPanel
                Height                =                                                             '250'  >
            <Image 
                Width                 =                                                             '640' 
                Height                =                                                             '240' 
                Source                =                                                         '$Banner' 
                HorizontalAlignment   =                                                          'Center' 
                Margin                =                                                             '10' />
        </StackPanel>
        <StackPanel 
                Height                =                                                             '515'  >
            <TabControl 
                Height                =                                                             '515' 
                HorizontalContentAlignment =                                                     'Center' 
                HorizontalAlignment   =                                                          'Center' 
                VerticalAlignment     =                                                          'Center' 
                Background            =                                                        '{x:Null}' 
                BorderBrush           =                                                        '{x:Null}' 
                Foreground            =                                                        '{x:Null}' 
                Margin="10,0">
                <TabItem 
                    Header            =                                         'Stage Deployment Server' 
                    HorizontalAlignment =                                                        'Center' 
                    Width             =                                                             '160' 
                    BorderBrush       =                                                        '{x:Null}'  >
                    <TabItem.Effect>
                        <DropShadowEffect/>
                    </TabItem.Effect>
                    <Grid 
                        Height            =                                                         '480' 
                        VerticalAlignment =                                                         'Top'  >
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width =                                              '0.5*' />
                            <ColumnDefinition Width =                                              '0.5*' />
                        </Grid.ColumnDefinitions>
                        <Grid.RowDefinitions>
                            $( $T0_List.RowDef )
                        </Grid.RowDefinitions>
                        <TextBlock 
                                                Grid.Row             =                                '0'
                                                Grid.Column          =                                '0'
                                                Grid.ColumnSpan      =                                '2'
                                                Margin               =                                '5' 
                                                FontSize             =                               '14' 
                                                HorizontalAlignment  =                           'Center'
                                                TextAlignment        =                           'Center'
                                                Foreground           =                             'Lime'  >
                            # - - - - - [ MDT Base Share Settings ] - - - - - #
                            <TextBlock.Effect>
                                <DropShadowEffect/>
                            </TextBlock.Effect>
                        </TextBlock>
                        <TextBlock 
                                                Grid.Row             =                                '1'
                                                Grid.Column          =                                '0'
                                                Grid.ColumnSpan      =                                '2'
                                                Margin               =                                '5' 
                                                FontSize             =                               '12' 
                                                HorizontalAlignment  =                           'Center'
                                                TextAlignment        =                           'Center'
                                                Foreground           =                             'Cyan' >
                            <TextBlock.Effect>
                                <DropShadowEffect/>
                            </TextBlock.Effect>
                            These settings will generate a new MDT share
                        </TextBlock>
                        $( $T0_List.TextBlock[0..4] )
                        <RadioButton            x:Name              =                            'Legacy' 
                                                Grid.Row            =                                 '7'
                                                Grid.Column         =                                 '0' 
                                                Margin              =                                 '5' 
                                                Content             =                          'Disabled' 
                                                HorizontalAlignment =                            'Center' 
                                                VerticalAlignment   =                            'Center'
                                                Foreground          =                              'Cyan' 
                                                IsEnabled           =                             'False' >
                            <RadioButton.Effect>
                                <DropShadowEffect/>
                            </RadioButton.Effect>
                        </RadioButton>
                        <RadioButton            x:Name              =                        'PowerShell' 
                                                Grid.Row            =                                 '7' 
                                                Grid.Column         =                                 '1' 
                                                Margin              =                                 '5' 
                                                Content             =                          'Disabled' 
                                                HorizontalAlignment =                            'Center' 
                                                VerticalAlignment   =                            'Center' 
                                                Foreground          =                              'Cyan'
                                                IsEnabled           =                             'False' >
                            <RadioButton.Effect>
                                <DropShadowEffect/>
                            </RadioButton.Effect>
                        </RadioButton>
                        <!-- # - - - - [ BITS / IIS Config ] - - - - #  -->
                        <TextBlock 
                                                Grid.Row             =                                '8'
                                                Grid.Column          =                                '0'
                                                Grid.ColumnSpan      =                                '2' 
                                                Margin               =                                '5' 
                                                FontSize             =                               '14'
                                                HorizontalAlignment  =                           'Center'
                                                TextAlignment        =                           'Center'
                                                Foreground           =                             'Lime' >
                            <TextBlock.Effect>
                                <DropShadowEffect/>
                            </TextBlock.Effect>
                        # - - - - - - - - [ BITS / IIS Config ] - - - - - - - - #
                        </TextBlock>
                        $( $T0_List.TextBlock[5..7] )
                        <RadioButton 
                                                x:Name               =                            'IIS_I'
                                                Grid.Row             =                               '12'
                                                Grid.Column          =                                '0'
                                                Margin               =                                '5' 
                                                Content              =                         'Disabled' 
                                                HorizontalAlignment  =                           'Center'
                                                VerticalAlignment    =                           'Center' 
                                                Foreground           =                             'Cyan' 
                                                IsEnabled            =                            'False' >
                            <RadioButton.Effect>
                                <DropShadowEffect/>
                            </RadioButton.Effect>
                        </RadioButton>
                        <RadioButton 
                                                x:Name               =                            'IIS_X'
                                                Grid.Row             =                               '12'
                                                Grid.Column          =                                '1'
                                                Margin               =                                '5'
                                                Content              =                         'Disabled'
                                                HorizontalAlignment  =                           'Center'
                                                VerticalAlignment    =                           'Center'
                                                Foreground           =                             'Cyan'
                                                IsEnabled            =                            'False' >
                            <RadioButton.Effect>
                                <DropShadowEffect/>
                            </RadioButton.Effect>
                        </RadioButton>
                        <TextBlock 
                                                Grid.Row             =                               '13'
                                                Grid.Column          =                                '0' 
                                                Grid.ColumnSpan      =                                '2' 
                                                Margin               =                                '5'
                                                FontSize             =                               '14'
                                                HorizontalAlignment  =                           'Center'
                                                TextAlignment        =                           'Center'
                                                Foreground           =                             'Lime' >
                            <TextBlock.Effect>
                                <DropShadowEffect/>
                            </TextBlock.Effect>
                        # - - [ Network and Source Credentials ]  - - #
                        </TextBlock>
                        $( $T0_List.TextBlock[8..10] )
                        $( $T0_List.TextBoxes[0..10] )
                    </Grid>
                </TabItem>
                <TabItem 
                    Header                                           =                       'Image Info' 
                    HorizontalAlignment                              =                           'Center' 
                    Width                                            =                              '150' 
                    BorderBrush                                      =                         '{x:Null}' >
                    <TabItem.Effect>
                        <DropShadowEffect/>
                    </TabItem.Effect>
                    <Grid 
                        Height                                       =                              '400' 
                        VerticalAlignment                            =                              'Top' >
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width                  =                             '0.5*' />
                            <ColumnDefinition Width                  =                             '0.5*' />
                        </Grid.ColumnDefinitions>
                        <Grid.RowDefinitions>
                        $( $T1_List.RowDef )
                        </Grid.RowDefinitions>
                        <TextBlock 
                                                Grid.Row             =                                '0'
                                                Grid.Column          =                                '0' 
                                                Grid.ColumnSpan      =                                '2' 
                                                Margin               =                                '5'
                                                FontSize             =                               '14'
                                                HorizontalAlignment  =                           'Center'
                                                TextAlignment        =                           'Center'
                                                Foreground           =                             'Lime' >
                            <TextBlock.Effect>
                                <DropShadowEffect/>
                            </TextBlock.Effect>
                        # - - [ Company Information ]  - - #
                        </TextBlock>
                        $( $T1_List.TextBlock[0..3] )
                        <TextBlock 
                                                Grid.Row             =                                '5'
                                                Grid.Column          =                                '0' 
                                                Grid.ColumnSpan      =                                '2' 
                                                Margin               =                                '5'
                                                FontSize             =                               '14'
                                                HorizontalAlignment  =                           'Center'
                                                TextAlignment        =                           'Center'
                                                Foreground           =                             'Lime' >
                            <TextBlock.Effect>
                                <DropShadowEffect/>
                            </TextBlock.Effect>
                        # - - [ Custom Graphics ]  - - #
                        </TextBlock>
                        $( $T1_List.TextBlock[ 4..5 ] )
                        <TextBlock 
                                                Grid.Row             =                                '8'
                                                Grid.Column          =                                '0' 
                                                Grid.ColumnSpan      =                                '2' 
                                                Margin               =                                '5'
                                                FontSize             =                               '14'
                                                HorizontalAlignment  =                           'Center'
                                                TextAlignment        =                           'Center'
                                                Foreground           =                             'Lime' >
                            <TextBlock.Effect>
                                <DropShadowEffect/>
                            </TextBlock.Effect>
                        # - - [ Network Definitions ]  - - #
                        </TextBlock>
                        $( $T1_List.TextBlock[ 6 ] )
                        $( $T1_List.TextBoxes )
                    </Grid>
                </TabItem>
            </TabControl>
        </StackPanel>
        <StackPanel 
                Orientation                                          =                       'Horizontal' 
                FlowDirection                                        =                      'LeftToRight' 
                VerticalAlignment                                    =                           'Bottom' 
                HorizontalAlignment                                  =                           'Center' 
                Height                                               =                               '40' 
                Margin                                               =                      '150,0,150,0' >
            <Button 
                Name                                                 =                            'Start'  
                Content                                              =                            'Start'  
                HorizontalAlignment                                  =                             'Left'  
                Height                                               =                               '20' 
                Width                                                =                              '170' />
            <Button 
                Name                                                 =                           'Cancel' 
                Content                                              =                           'Cancel' 
                HorizontalAlignment                                  =                            'Right' 
                Height                                               =                               '20' 
                Width                                                =                              '170' />
        </StackPanel>
    </StackPanel>
</Window>
"@
    
        $GUI = Convert-XAMLtoWindow -Xaml $XAMLRoot -NamedElement @( $Named ; "Start" ; "Cancel" ) -PassThru

        $GUI.Cancel.Add_Click({ $GUI.DialogResult = $false })

        $GUI.Start.Add_Click({

        $0 = @( "File System/Drive" ;       "Root Folder" ;    "Network Share Name" ;      "PSDrive Name" ; 
                "Share Description" ;         "Site Name" ; "Application Pool Name" ; "Virtual Directory" ;
                     "NetBIOS Name" ; "Target/LM Admin User" ; "Target/LM Admin Pass" )

        $1 = $0 | % { "You must enter a $_" }
        $2 = $0 | % { "$_ Missing" }

        $MSG = 0..16 | % { [ Type ] $Message }

        If     (      $GUI.r0.Text -eq "" ) { ( $MSG[ 0] )::Show( $1[ 0] , $2[ 0] ) }
        ElseIf (      $GUI.r1.Text -eq "" ) { ( $MSG[ 1] )::Show( $1[ 1] , $2[ 1] ) }
        ElseIf (      $GUI.r2.Text -eq "" ) { ( $MSG[ 2] )::Show( $1[ 2] , $2[ 2] ) }
        ElseIf (      $GUI.r3.Text -eq "" ) { ( $MSG[ 3] )::Show( $1[ 3] , $2[ 3] ) }
        ElseIf (      $GUI.r4.Text -eq "" ) { ( $MSG[ 4] )::Show( $1[ 4] , $2[ 4] ) }
        ElseIf (    $GUI.iis0.Text -eq "" ) { ( $MSG[ 5] )::Show( $1[ 5] , $2[ 5] ) }
        ElseIf (    $GUI.iis1.Text -eq "" ) { ( $MSG[ 6] )::Show( $1[ 6] , $2[ 6] ) }
        ElseIf (    $GUI.iis2.Text -eq "" ) { ( $MSG[ 7] )::Show( $1[ 7] , $2[ 7] ) }
        ElseIf (     $GUI.dc0.Text -eq "" ) { ( $MSG[ 8] )::Show( $1[ 8] , $2[ 8] ) }
        ElseIf (     $GUI.dc1.Text -eq "" ) { ( $MSG[ 9] )::Show( $1[ 9] , $2[ 9] ) }
        ElseIf ( $GUI.dc2.Password -eq "" ) { ( $MSG[10] )::Show( $1[10] , $2[10] ) }
        ElseIf (      $GUI.p0.Text -eq "" ) { ( $MSG[11] )::Show( $1[11] , $2[11] ) }
        ElseIf (      $GUI.p1.Text -eq "" ) { ( $MSG[12] )::Show( $1[12] , $2[12] ) }
        ElseIf (      $GUI.p2.Text -eq "" ) { ( $MSG[13] )::Show( $1[13] , $2[14] ) }
        ElseIf (      $GUI.p3.Text -eq "" ) { ( $MSG[14] )::Show( $1[14] , $2[14] ) }
        ElseIf (    $GUI.img0.Text -eq "" ) { ( $MSG[15] )::Show( $1[15] , $2[15] ) }
        ElseIf (    $GUI.img1.Text -eq "" ) { ( $MSG[16] )::Show( $1[16] , $2[16] ) }
        ElseIf (      $GUI.n0.Text -eq "" ) { ( $MSG[17] )::Show( $1[17] , $2[17] ) }

        Else { $GUI.DialogResult = $True }

    })    
        $Output = Show-WPFWindow -GUI $GUI

        If ( $Output -eq $True )
        {   
            # - [ Convert GUI to Usable Variables ] - - - - - - - - - - - - - - - - - - - #

            $LMCRED = New-Object -TypeName System.Management.Automation.PSCredential `
                        -Args "$( $GUI.dc1.Text )" , "$( $GUI.dc2.Password )"

            $DSC = [ Ordered ]@{   
                        R0_Company     = "$( $GUI.p0.Text )"
                        R1_UNCRoot     = "\\$Env:ComputerName\$SMB"
                        R2_Hostname    = "$Env:ComputerName"
                        R3_DC_User     = "$( $DCCred.Username )"
                        R4_DC_Pass     = "[!] A Password"
                        R5_WWW_Site    = "$( $GUI.p1.Text )"
                        R6_Phone       = "$( $GUI.p2.Text )"
                        R7_Hours       = "$( $GUI.p3.Text )"
                        R8_Logo        = "$( $GUI.img0.Text )"
                        R9_Background  = "$( $GUI.img1.Text )"
                        R10_Branch     = "$( $GUI.n0.Text )"
                        R11_Domain     = "$env:USERDNSDOMAIN"
                        R12_LM_User    = "$( $LMCRED.Username )"
                        R13_LM_Pass    = "$( $LMCRED.GetNetworkCredential().Password )"
                        R14_Proxy      = "$Env:ComputerName"
                        R15_NetBIOS    = "$Env:UserDomain"
                        R16_DSC_Folder = "$( $GUI.r0.Text.TrimEnd('\') )$( ( $GUI.r1.Text ) )" }
        
            0..( $DSC.Count - 1 ) | % { echo "[  $_ ] Key/Value $( $DSC.Keys[$_] ) $( $DSC.Values[$_] )" }
        }

        Else
        {
            Wrap-Action -Type "Exception" -Info "[!] Either the user cancelled or the dialog failed"
            Read-Host "Press Enter to Exit"
            Exit
        }
}
            
        # Dependency Checks

        $CPU     = $env:PROCESSOR_ARCHITECTURE 
        $SRV     = $env:COMPUTERNAME
        $Install = "C:\Hybrid-Installation"

        $Deploy  = "Deployment"

        $MDTFile = "Microsoft$Deploy`Toolkit_x"
        $MDTURL  = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492"

        $ADK     = "Windows Assessment and $Deploy Kit"

        $MDT     = "Microsoft $Deploy Toolkit"

        $7zip    = "https://www.7-zip.org/a/7z1900"

        $Path = "" , "\WOW6432Node" | % { "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall" }
    
        If ( $CPU -eq "x86" )
        { 
            $Reg     = $Path[    0 ] | % { GP "$_\*" }   
            $MDTFile = "$MDTFile`86.msi"
            $7zip    = "7Z1900.exe"
        }

        Else                      
        { 
            $Reg     = $Path[ 0..1 ] | % { GP "$_\*" } 
            $MDTFile = "$MDTFile`64.msi"
            $7zip    = "7z1900-x64.exe"
        }

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
        $List = @{     

        0 =   @{  Regex =                                         "$Deploy Kit - Windows 10"
                   Full =                                                "$ADK - Windows 10"
                    Min =                                                     '10.1.17763.1'
                    Tag =                                                           "WinADK"
                     ID =                            "Windows Assessment and Deployment Kit" 
                   Path =                                                  "$Install\WinADK" 
                   File =                                                   "winadk1903.exe"
                    URL =                  "https://go.microsoft.com/fwlink/?linkid=2086042"
                   Args =         "/quiet /norestart /log $env:temp\win_adk.log /features +" }
               
        1 =   @{  Regex =                                                  "Preinstallation"
                   Full =  "$ADK - Windows Preinstallation Environment Add-ons - Windows 10"
                    Min =                                                     '10.1.17763.1'
                    Tag =                                                            "WinPE"
                     ID =                          "Windows ADK Preinstallation Environment" 
                   Path =                                                   "$Install\WinPE" 
                   File =                                                    "winpe1903.exe"
                    URL =                  "https://go.microsoft.com/fwlink/?linkid=2087112"
                   Args =         "/quiet /norestart /log $env:temp\win_adk.log /features +" }

        2 =   @{  Regex =                                                     "$Deploy Tool"
                   Full =                                                             "$MDT"
                    Min =                                                    '6.3.8450.0000'
                    Tag =                                                              "MDT" 
                     ID =                                     "Microsoft Deployment Toolkit"
                   Path =                                                     "$Install\MDT"
                   File =                                                         "$MDTFile" 
                    URL =                                                 "$MDTURL/$MDTFile" 
                   Args =                                                "/quiet /norestart" }

        3 =   @{  Regex =                                                            '7-Zip'
                   Full =                                                            '7-Zip'
                    Min =                                                            '19.00'
                    Tag =                                                            '7-Zip'
                   Path =                                                   "$Install\7-Zip"
                   File =                                                            "$7zip"
                    URL =                                    "https://www.7-zip.org/a/$7zip"
                   Args =                                                               "/S" }
        }

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

        $Req     = "Minimum Requirements"
        $DL      = "Download"
        $EX      = "Exit"
        $DLX     = "$DL and install, or $EX"

        Foreach ( $i in 0..3 )
        {
            $Item = $Reg | ? { $_.DisplayName -like "*$( $List[$i].Regex )*" } | Select DisplayName , DisplayVersion
            If ( ( $Item -ne $Null ) -and ( $Item.DisplayVersion -ge $List[$i].Min ) )
            {
                Wrap-Action -Type "Dependency" -Info "$( $List[$i].Tag ) meets $Req"
            }

            Else
            {   
                Switch ( $host.UI.PromptForChoice( "$( $List[$i].Full ) does [!] meet $Req" , "$( $List[$i].Tag ) $DLX ?" , 
                [ System.Management.Automation.Host.ChoiceDescription [] ]@( "&$DL" , "&$EX" ) ,           `
                [ Int ] 0 ) )
                {
                    0
                    {   Wrap-Action                                                                        `
                            -Type                                                            "Downloading" `
                            -Info                                                           $List[$i].Tag

                        Provision-Dependency                                                               `
                            -ID                                                             $List[$i].ID   `
                            -Path                                                           $List[$i].Path `
                            -File                                                           $List[$i].File `
                            -URL                                                            $List[$i].URL  `
                            -Args                                                           $List[$i].Args
                    
                        If ( $? -eq $True )
                        {
                            Wrap-Action                                                                    `
                                -Type                                                         "Successful" `
                                -Info                                     "[+] $( $List[$i].Tag ) Updated" 
                        }

                        Else
                        {
                            Wrap-Action `
                                -Type                                                          "Exception" `
                                -Info                            "[!] $( $List[$i].Tag ) Failed to update"
                                
                            Read-Host "Press Enter to Exit"
                                
                            Exit 
                        } 
                    }
                               
                    1
                    {   Read-Host                                                  "Press any key to exit"
                        Exit                                                                               
                    }
                }
            }
        }

        # Create the Base Deployment Share
    
        $MDTDir = ( ( GP "HKLM:\SOFTWARE\Microsoft\Deployment 4" ).Install_Dir ).TrimEnd( '\' )
        IPMO "$MDTDir\Bin\MicrosoftDeploymentToolkit.psd1"

        # - [ Create Folder ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

        If ( ( Test-Path $URI ) -eq $False )
        {
            NI -Path $URI -ItemType Directory
            If ( $? -eq $True ) { Wrap-Action -Type "Success"   -Info "[+] '$URI' Created" }
            Else                { Read-Host "Exception [!] '$URI' creation failed. Press Enter to Exit" ; Exit }
        }

        # - [ Generate Share ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

        If ( ( GSMBS | ? { $_.Path -eq $URI } -EA 0 ) -eq $Null )
        {     
            NSMBS -Name $SMB -Path $URI -Description $TAG -FullAccess Administrators
            If ( $? -eq $True ) { Wrap-Action -Type "Created" -Info "[+] SMB Share"       }
            Else                { Wrap-Action -Type "Exception" -Info "[!] New-SMBShare '$SMB' failed"
                                      Read-Host "Press Enter to Exit" ; Exit }
        }
        
        # - [ Generate PSDrive ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

        If ( ( GDR -Name $PSD -EA 0 ) -eq $Null )
        {
            NDR `
                -Name                                                                    $PSD `
                -PSProvider                                                       MDTProvider `
                -Root                                                                    $URI `
                -Description                                                             $TAG `
                -NetworkPath                                            "$( $Network.Share )" `
                |                                                      Add-MDTPersistentDrive
                
            If ( $? -eq $True ) { Wrap-Action -Type "Created" -Info "[+] New-PSDrive '$PSD'" }
            Else { Read-Host "Exception [!] New-PSDrive '$PSD' failed, Press Enter to Exit" ; Exit   }
        }

        # - [ Update Registry ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

        $RegRoot     =                                               'HKLM:\SOFTWARE\Policies'
        $RegFull     =    "Secure Digits Plus LLC\Hybrid\Desired State Controller\$PName\$PSD"
        $RegRecurse  =                                                   $RegFull.Split( '\' )

        0 | % { 
            If ( ( Test-Path "$RegRoot\$( $RegRecurse[0] )" ) -ne $True )
            {
                $Null =                                                                    NI `
                    -Path                                                            $RegRoot `
                    -Name                                                      $RegRecurse[0]
            }
        }

        $RegPath = "$RegRoot\$( $RegRecurse[0] )"
                
        1..4 | % {
            If ( ( Test-Path "$RegPath\$( $RegRecurse[$_] )" ) -ne $True )
            {
                $Null =                                                                   NI `
                    -Path                                                           $RegPath `
                    -Name                                                    $RegRecurse[$_] 
            }
            
            $RegPath = "$RegPath\$( $RegRecurse[$_] )"
        }

        $RegFull =                                                        "$RegRoot\$RegFull"

        If ( ( Test-Path $RegFull ) -eq $True )
        {
            $Hybrid  = @{   Date    = "$( Get-Date -UFormat "%m-%d-%y %H:%M:%S")"
                            Root    =                                        $URI
                            Share   =                                        $SMB
                            PSDrive =                                        $PSD
                            Tag     =                                        $TAG }

            $RegName  = @( $Hybrid.Keys   )
            $RegValue = @( $Hybrid.Values ) 

            0..4 | % {
            $Null =                                                                   SP `
                -Path                                                         "$RegFull" `
                -Name                                                       $RegName[$_] `
                -Value                                                     $RegValue[$_] `
                -Force                                                                     }

            $Share , $BITS , $Company , $Network | % {

            $RegName  = @( $_.Keys   )
            $RegValue = @( $_.Values )
            $i = $RegName.Count - 1

            $Null =                                                                    SP `
                -Path                                                          "$RegFull" `
                -Name                                                        $RegName[$i] `
                -Value                                                      $RegValue[$i] `
                -Force                                                                     }
        }

        Else
        {
            Wrap-Action                                                                  `
                -Type                                                        "Exception" `
                -Info                                     "The user exited the dialogue"

            Read-Host                                              "Press Enter to Exit"
            Exit
        }

        Switch ( $host.UI.PromptForChoice( 'PowerShell Deployment' , 'Standard MDT, or Upgrade to PSD-Development?' , 
        [ System.Management.Automation.Host.ChoiceDescription [] ]@( '&Standard MDT' , '&PSD-Development' ) , [ Int ] 1 ) )
        {
            0
            {   Wrap-Action                                                              `
                    -Type                                                     "Selected" `
                    -Info                     "Standard MDT - Share Generation complete"

            }

            1
            {
                Wrap-Action                                                              `
                    -Type                                                   "Installing" `
                    -Info                          "PowerShell-[Deployment/Development]"

                # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
                $Scripts = "Scripts"                                                   # Scripts #
                # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
        
                @( gci                          "$Install\$Scripts" -Filter "*.ps1" -EA 0 ).Name `
                | % {  #Copy-PXDFolder 

                        Robocopy                         "$Install\$Scripts" "$URI\$Scripts" $_
                        Dir                                                   "$URI\$Scripts\$_" `
                        |                                                           Unblock-File }

                # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
                $Templates = "Templates"                                             # Templates #
                # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
        
                @( gci                                              "$Install\$Templates" ).Name `
                | % { 
                        Robocopy                     "$Install\$Templates" "$URI\$Templates" $_
                        Dir                                                 "$URI\$Templates\$_" `
                        |                                                           Unblock-File }

                # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
                $Modules = "Tools\Modules"                                             # Modules #
                # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

                "PSDGather", "PSDDeploymentShare", "PSDUtility", "PSDWizard" `
                | % {
                        $ModPath =                                            "$URI\$Modules\$_"
                    
                        If ( ( Test-Path "$ModPath" ) -eq $False )
                        {
                            $Null = NI                                                "$ModPath" `
                                -ItemType                                              Directory `

                            Wrap-Action                                                          `
                                -Type                                                  "Created" `
                                -Info                                         "[+] Directory $_"
                        }

                        Wrap-Action                                                              `
                            -Type                                                      "Copying" `
                            -Info                                        "Module $_ to $ModPath"

                        Robocopy                        "$Install\$Scripts" "$ModPath" "$_.psm1"
        
                        Dir                                                           "$ModPath" `
                        |                                                          Unblock-File  }

                # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
                $BDD = "Microsoft.BDD"                                               # PSSnapIns #
                # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

                Wrap-Action                                                                      `
                    -Type                                                              "Copying" `
                    -Info                                                    "[+] $URI\$Modules"

                If ( ( Test-Path "$URI\$Modules\$BDD.PSSnapin" )                     -eq $False  )
                {
                    $Null = NI                                     "$URI\$Modules\$BDD.PSSnapIn" `
                        -ItemType                                                     Directory

                    Wrap-Action                                                                  `
                        -Type                                                          "Created" `
                        -Info                                                    "[+] Directory"
                }

                # Some Algebra and Calculus
        
                ( $d , $r , $x ) = ( '.dll' , '.config' , 'xml' )

                $PSSnapIn = ( 
                                (                   "" , $r , "-help.$x" | % {       "$d$_" } ) `
                              + (                   ".Format" , ".Types" | % {   "$_.ps1$x" } ) `
                            | % { "PSSnapIn$_" } )                                              `
                            + (                                  "" , "$r" | % { "Core$d$_" } ) `
                            +                                                 "ConfigManager$d" `

                ( $d , $r , $x ) = ''
                            
                $PSSnapIn | % {        CP   "$MDTDir\Bin\$BDD.$_" "$URI\$Modules\$BDD.PSSnapIn" }

                Wrap-Action                                                                     `
                    -Type                                                             "Copying" `
                    -Info                                                 "[+] $URI\$Templates"

                If ( ( Test-Path "$URI\$Templates" ) -eq $False )
                {
                    $Null = NI                                                "$URI\$Templates" `
                }

                "Groups" , "Medias" , "OperatingSystems" , "Packages" , "SelectionProfiles" , 
                "TaskSequences" , "Applications" , "Drivers" , "Groups" , "LinkedDeploymentShares" `
                | % { "$_.xsd" } | % { CP "$MDTDir\$Templates\$_" "$URI\$Templates"
    
                Wrap-Action `
                    -Type                                                      "Copying" `
                    -Info                                          "[+] $URI\$Templates" }

               #If ( $Upgrade -eq 0 )
               #{
               #    Wrap-Action `
               #        -Type                                                           "Update" `
               #        -Info                                           "[+] PSD ISO properties"
               #
               #$Name  = 86 , 64 `
               #| % {                                            "Boot.x$_.LiteTouchISOName" ; 
               #                                          "Boot.x$_.LiteTouchWIMDescription" }
               #
               #$Value = 86 , 64 `
               #| % {                                                 "PSDLiteTouch_x$_.iso" ;
               #                                    "PowerShell Deployment Boot Image (x$_)" }
               #
               #0..3 | % { `
               #        SP ${PXD}:                                                       `
               #            -Name                                            $Name[$_]   `
               #            -Value                                          $Value[$_] } `

                Wrap-Action `
                    -Type                                                              "Sending" `
                    -Info                                  "[+] ZTIGather.XML to correct folder"

                ( gci $MDTDir\Templates\Distribution\Scripts -Filter "*Gather.xml" -EA 0 )       `
                | % {   Copy-Item                          $_.FullName "$URI\$Modules\PSDGather" }

                $Message  = "Logs" , "Dynamics Logs Sub" , "DriverSources" , "DriverPackages"    `
                | % { "$_ Folder" }
         
                $Path = "Logs" , "Logs\Dyn" , "DriverSources" , "DriverPackages" 

                0..3 | % { 
                
                    Wrap-Action `
                        -Type                                                         "Creating" `
                        -Info                         "$( $Message[$_] ) in $URI\$( $Path[$_] )"

                    $Null = NI `
                        -ItemType                                                      Directory `
                        -Path                                                $URI\$( $Path[$_] ) `
                        -Force
                }

                If ( ! ( $Upgrade ) )
                {
                    Wrap-Action `
                        -Type                                                         "Reducing" `
                        -Info                                "[~] Permissions Hardening on $SMB"

                    "Users" , "Administrators" , "SYSTEM" | % { "$_`:(OI)(CI)(RX)" } `
                    | % { $null = icacls $URI /grant "$_" }

                    Grant-SmbShareAccess `
                        -Name                                                              $SMB `
                        -AccountName                                                 "EVERYONE" `
                        -AccessRight                                                     Change `
                        -Force

                    Revoke-SmbShareAccess `
                        -Name                                                              $SMB `
                        -AccountName                                            "CREATOR OWNER" `
                        -Force
                }
            }
        }

        $SiteRoot = $URI
        $SD       = $env:SystemDrive
        $Date     = ( Get-Date -UFormat "%m-%d-%Y" )
        $LogPath  = "$Home\Desktop\ACL"
        $Server   = $Env:ComputerName                   
        
        $PSP      = "Machine/Webroot/AppHost"
        $DWS      = "$SiteName"
        $SWS      = "System.WebServer"
        $WSS      = "Security/Authentication"
        $Full     = "IIS:\Sites\$SiteName\$VHost"

    #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        If ( ( Test-Path $SiteRoot ) -eq $False )
        {
            NI -Path $SiteRoot -ItemType Directory -Name $SiteRoot

            If ( $? -eq $True )
            {
                Echo "" , "Successful [+] '$SiteRoot' Directory Created" , ""
            }
        
            Else
            {
                Echo "" , "Exception [!] Site Path Directory not created" , ""
                Read-Host "Press any key to exit"
            }
        }

        Else
        {
            Echo "" , "Detected [+] '$SiteRoot' exists, continuing" , ""
        }

               # Web Control

        $WebSvc = @(                "Web-Server" ;
                                   "DSC-Service" ;
                                      "FS-SMBBW" ;
                               "ManagementOData" ;
                    "WindowsPowerShellWebAccess" ;
                             "WebDAV-Redirector" ;
        @( "BITS" | % {                     "$_" ; 
                                    "$_-IIS-Ext" ; 
                                "RSAT-$_-Server" } ) ;
        @(  "Net" | % { "$_-Framework-45-ASPNET" ; 
                      "$_-WCF-HTTP-Activation45" } ) ;
        @(# "Web"                            
                                   @(  "App-Dev" ;  
                                       "AppInit" ; 
                                     "Asp-Net45" ; 
                                    "Basic-Auth" ; 
                                   "Common-Http" ; 
                                "Custom-Logging" ; 
                                "DAV-Publishing" ;
                                   "Default-Doc" ; 
                                   "Digest-Auth" ;
                                  "Dir-Browsing" ;
                                     "Filtering" ;
                                        "Health" ;        
                    @( "HTTP" | % {  "$_-Errors" ; 
                                    "$_-Logging" ; 
                                   "$_-Redirect" ; 
                                    "$_-Tracing" } ) ;
                                      "Includes" ; 
                   @( "ISAPI" | % {     "$_-Ext" ; 
                                     "$_-Filter" } ) ; 
                                 "Log-Libraries" ;
                                      "Metabase" ; 
                                  "Mgmt-Console" ;
                                     "Net-Ext45" ;
                                   "Performance" ;   
                               "Request-Monitor" ; 
                                      "Security" ; 
                              "Stat-Compression" ; 
                                "Static-Content" ; 
                                      "Url-Auth" ;
                                     "WebServer" ;
                                  "Windows-Auth" ) | % { "Web-$_" } ) ;
        @( "WAS" | % {                      "$_" ;  
                              "$_-Process-Model" ;  
                                "$_-Config-APIs" } ) )
        
        # Services Declared, now run the loop.

        $WebSvc | % { Echo "[ $_ ]" ; Install-WindowsFeature -Name $_ }

        IPMO WebAdministration

        $Default = "Default Web Site"

        $DWSite = ( Get-Website -Name $Default -EA 0 )
    
        If ( $DWSite -ne $Null )
        {
            If ( $DWSite.State -eq 'Running' )
            { 
                Stop-Website | SP "IIS:\Sites\$Default" ServerAutoStart False
            }
        }

        $Service = "MRxDAV" , "WebClient" 

        0..1 | % { 
                    
        $Check = ( Get-Service                                                           `
                -ComputerName                                                    $Server `
                -Name                                                       $Service[$_] `
                -EA                                                                    0 ) 

            If ( ( $Check ).Status -ne "Running" )
            {
                Set-Service `
                    -ComputerName                                                $Server `
                    -StartupType                                               Automatic `
                    -EA                                                                4 `
                    -Status                                                        Start `
                    -Name                                                   $Service[$_]
            }
        }
        
        New-WebAppPool                                                                   `
            -Name                                                              $SitePool `
            -Force

        SP IIS:\AppPools\$SitePool Enable32BitAppOnWin64 True
        SP IIS:\AppPools\$SitePool ManagedRuntimeVersion v4.0
        SP IIS:\AppPools\$SitePool ManagedPipelineMode Integrated
     
        Restart-WebAppPool                                                               `
            -Name                                                              $SitePool `
   
        New-Website                                                                      `
            -Name                                                              $SiteName `
            -ApplicationPool                                                   $SitePool `
            -PhysicalPath                                                      $SiteRoot `
            -Force
   
        Start-Website                                                                    `
            -Name                                                              $SiteName

         # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        New-WebVirtualDirectory `
            -Site                                                            "$SiteName" `
            -Name                                                               "$Vhost" `
            -PhysicalPath                                                    "$SiteRoot" `
            -Force

        $MWA =                                                 "MACHINE/WEBROOT/APPHOST"
        $SWS =                                                        "System.WebServer"
        $WSS =                                                 "Security/Authentication"

        Set-WebConfigurationProperty                                                     `
                  -PSPath                                                         "$MWA" `
                -Location                                                    "$SiteName" `
                  -Filter                                        "$SWS/webdav/authoring" `
                    -Name                                                      "Enabled" `
                   -Value                                                         "True"

        $DAV = @"
		Set Config "$SiteName/$Vhost" /Section:$SWS/Webdav/AuthoringRules
        /+[Users='*',Path='*',Access='Read,Source'] /Commit:AppHost
"@
        $Sys32 =                                                  "$SD\Windows\System32"
        
		$Results = Start-Process                             "$Sys32\inetsrv\AppCMD.EXE" `
                           -Args                                                    $DAV `
                    -NoNewWindow                                                         `
                       -PassThru                                                         `
                      | Out-Null

        If ( ! ( ( 
        Get-WebConfigurationProperty                                                     `
            -PSPath                                                               "$MWA" `
            -Filter                                                 "$SWS/StaticContent" `
            -Name "." ).Collection                   | ? { $_.FileExtension -eq ".*" } ) )
        {
            $MimeResults = Add-WebConfigurationProperty                                  `
                -PSPath                                    "IIS:\Sites\$SiteName\$Vhost" `
                -Filter                                             "$SWS/StaticContent" `
                  -Name                                                              "." `
                 -Value @{  FileExtension =                                         '.*' ; 
                                 MimeType =                                 'Text/Plain' }
        }

         Set-WebConfigurationProperty                                                    `
            -Filter                                              "/$SWS/DirectoryBrowse" `
            -Name                                                              "Enabled" `
            -PSPath                                        "IIS:\Sites\$SiteName\$VHost" `
            -Value                                                                $True

        #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        $TGT =    "anonymousAuthentication" , 
                  "windowsAuthentication" + 
               @( "webDAV/authoring" `
                   | % { "$_`Rules" ; ( @( "$_/Properties" ) * 2 ) } ) + `

               @( "security/RequestFiltering" `
                   | % { @( "$_/FileExtensions" ) * 2  + @( "$_/Verbs" ) * 2 } )

        $Full = "$SiteName/$VHost"

        $WCP = @{
        0 = "$Full"      , "$SWS/$WSS/$( $TGT[0] )" , "Enabled"         , "False"
        1 = "$Full"      , "$SWS/$WSS/$( $TGT[1] )" , "Enabled"         , "True"
        2 = "$Sitename/" , "$SWS/$(      $TGT[2] )" , "DefaultMimeType" , "Text/XML" 
        3 = "$Full"      , "$SWS/$(      $TGT[3] )" , "AllowInfinitePropfindDepth" , "True"
        4 = "$Sitename"  , "$SWS/$(      $TGT[4] )" , "AllowInfinitePropfindDepth" , "True"
        5 = "$Full"      , "$SWS/$(      $TGT[5] )" , "ApplyToWebDAV"   , "False"
        6 = "$Sitename/" , "$SWS/$(      $TGT[6] )" , "ApplyToWebDAV"   , "False"
        7 = "$Full"      , "$SWS/$(      $TGT[7] )" , "ApplyToWebDav"   , "False"
        8 = "$Sitename/" , "$SWS/$(      $TGT[8] )" , "ApplyToWebDav"   , "False"  }
          
           
        0..8 | % {  Set-WebConfigurationProperty                    `
                                    -PSPath           $MWA          `
                                    -Location         $WCP[$_][0]   `
                                    -Filter           $WCP[$_][1]   `
                                    -Name             $WCP[$_][2]   `
                                    -Value            $WCP[$_][3]   }

            $Filtering = Get-IISConfigSection `
            | ? { $_.SectionPath -like "*$SWS/security/requestfiltering*" }     `
            | Get-IISConfigElement -ChildElementName           'HiddenSegments'

				Set-IISConfigAttributeValue                                     `
                           -ConfigElement                           $Filtering  `
                           -AttributeName                       'ApplyToWebDAV' `
                          -AttributeValue                               $False

        #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    
             'IIS_IUSRS', 'IUSR', "IIS APPPOOL\$SitePool"                       `
             | % {   
     
                 $Obj =  New-AclObject                                          `
                            -SamAccountName                                  $_ `
                            -Permission                        'ReadAndExecute' `
                            -Inheritance                     'ContainerInherit' ,
                                                                'ObjectInherit' 

                Add-Acl                                                         `
                    -Path                                             $SiteRoot `
                    -AceObject                                             $Obj
            }
  
        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   
            $AppData = "$SiteRoot"
            'IIS_IUSRS', "IIS APPPOOL\$SitePool"                                `
            | % {  
             
                $Obj = New-AclObject                                            `
                        -SamAccountName                                      $_ `
                        -Permission                                    'Modify' `
                        -Inheritance                         'ContainerInherit',
                                                                'ObjectInherit'

                Add-Acl                                                         `
                    -Path                                              $AppData `
                    -AceObject                                             $Obj
            }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -# # #
# - - - [ Provisional Root ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#


    # - [ Hybrid Installation / Initial Imaging Process ] - #

    Wrap-Function -ID "Provision-HybridDSC"

    # TODO: Test/Pull from "gp $RegPath" to prevent this

    If ( ( Test-Path $URI ) -eq $Null )
    {
        Wrap-Action -Type "Exception" -Info "There is no root folder defined"
        Read-Host "Press Enter to Exit"
        Exit
    }

    If ( ( Test-Path "$URI\$PName" ) -ne $True )
    {
        NI -Path "$URI\$PName" -ItemType Directory
        If ( $? -eq $True )
        {
            Wrap-Action -Type "Directory" -Info "[+] '$URI\$PName' Created"
        }
        Else
        {
            Wrap-Action -Type "Exception" -Info "[!] '$URI\$PName' creation failed"
            Read-Host "Press Enter to Exit"
            Exit
        }
    }

    $Bridge =  'Resources'    , 
               'Tools'        , 
               'Images'       , 
               'Profiles'     , 
               'Certificates' , 
               'Applications'

    0..5 | % { 
        
        $Current = "$URI\$PName\($_)$( $Bridge[$_] )"

        If ( ( Test-Path "$Current" ) -ne $True )
        {
            NI -Path "$Current" -ItemType Directory
            If ( $? -eq $True )
            {
                Wrap-Action -Type "Directory" -Info "[+] $_ created"
            }
            Else
            {
                Wrap-Action -Type "Exception" -Info "[!] $_ creation failed"
            }
        }

    # TODO: Get this working in entirety with 7-zip and automatically extract contents to destination folders
    #If ( ( gci $Current ) -eq $Null )
    #{
    #   IWR -URI "location" -OutFile "$Install\$PName\($_)$( $Bridge[$_] )"
    #
    #}

    }

        $LMV = @{    # - [ Local Machine Variables ] - - #
                     HN =              $env:ComputerName # 
                      X =    $env:Processor_Architecture #
                      D =            "$env:SystemDrive\" #
                      W =                $env:SystemRoot #
                    S32 =     "$env:SystemRoot\System32" #
                     PD =               $env:programdata #
                     PF =              $env:ProgramFiles #
                     # - - - - - - - - - - - - - - - - - #
               }

        $LM = @( $LMV | % { $_.HN , $_.X , $_.D , $_.W , $_.S32 , $_.PD , $_.PF }) 

        $HybridDSC    = "HKLM:\SOFTWARE\Policies\Secure Digits Plus LLC\Hybrid\Desired State Controller"
        If ( ( Test-Path $HybridDSC ) -ne $Null )
        {
            $Provisionary = gci $HybridDSC -EA 0
            If ( ( $Provisionary.Name ) -ne $Null )
            {
                       $Split = $Provisionary.Name.Split( '\' )
                       $Count = $Split.Count - 1
                $Provisionary = $Split[$Count]
            }
        }
        
        If ( $LM[0] -eq $R[2] ) # If the current machine is the deployment server, target the local path
        { 
            $DR = $URI
        } 
        Else                    # If it isn't, target it's network path/share
        { 
            $dr = $
        }

        $DS = "$DR\$( $R[0] )"
        
        $Root = `
        @{  
            0 = $Bridge | % { "$ds\$_" }
            
            1 = $Bridge | % { "$( $lm[2] + $r[0] )\$_" }

            2 = "( Domain State Controller @ Source )" , 
                "( Current Machine @ Variables )"      , 
                "( Provision Index @ Bridge Control )"

            3 =                         "Provisionary" ,      
                                         "(DSC) Share" , 
                                    "(DSC) Controller" +
                                 @( $Bridge | % { $_ } ) 
                                     

            4 =   "(DSC) Host" , "Current Hostname" , "CPU Architecture" , "System Drive" , "Windows Root" , 
                    "System32" ,     "Program Data"

            5 = "(DSC) Target" ,  "Resources" , "Tools / Drivers" , "Images" , "Profiles" , "Certificates" , 
                "Applications" , "Background" ,            "Logo" }

        If ( $lm[0] -eq $r[2] ) { $srv = "Yes" }
        Else                    { $srv =  "No" }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -# # #
# - - - [ Hybrid Control Panel ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

        Wrap-Title -Title "Provisional-Root" 
        Wrap-Section -Section $Root[2][0]
        Wrap-ItemOut -Type $Root[3][0] -Info $r[0]        # Provisionary Name $PName
        Wrap-ItemIn  -Type $Root[3][1] -Info $r[1]        # Deployment Server Hostname 
        Wrap-ItemOut -Type $Root[3][2] -Info $r[2]        # Deployment Share Name / $SMB
        Wrap-ItemIn  -Type $Root[3][3] -Info $Root[0][0]
        Wrap-ItemOut -Type $Root[3][4] -Info $Root[0][1]
        Wrap-ItemIn  -Type $Root[3][5] -Info $Root[0][2]
        Wrap-ItemOut -Type $Root[3][6] -Info $Root[0][3]
        Wrap-ItemIn  -Type $Root[3][7] -Info $Root[0][4]
        Wrap-ItemOut -Type $Root[3][8] -Info $Root[0][5]
        Wrap-Section -Section $Root[2][1]
        Wrap-ItemOut -Type $Root[4][0] -Info $srv
        Wrap-ItemIn  -Type $Root[4][1] -Info $lm[0]
        Wrap-ItemOut -Type $Root[4][2] -Info $lm[1]
        Wrap-ItemIn  -Type $Root[4][3] -Info $lm[2]
        Wrap-ItemOut -Type $Root[4][4] -Info $lm[3]
        Wrap-ItemIn  -Type $Root[4][5] -Info $lm[4]
        Wrap-ItemOut -Type $Root[4][6] -Info $lm[5]
        Wrap-Section -Section $Root[2][2]
        Wrap-ItemOut -Type $Root[5][0] -Info $lm[0]
        Wrap-ItemIn  -Type $Root[5][1] -Info $Root[1][0]
        Wrap-ItemOut -Type $Root[5][2] -Info $Root[1][1]
        Wrap-ItemIn  -Type $Root[5][3] -Info $Root[1][2]
        Wrap-ItemOut -Type $Root[5][4] -Info $Root[1][3]
        Wrap-ItemIn  -Type $Root[5][5] -Info $Root[1][4]
        Wrap-ItemOut -Type $Root[5][6] -Info $Root[1][5]

        Wrap-In
        Wrap-Out
        Wrap-Bot
        
    Read-Host "Press (Enter) to continue"

    $d = $Root[0] ; $l = $Root[1] ;  $b = $Bridge ; $Root = "" ; $Bridge = "" ;

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#   [ Provision-Images ]   ############################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    Wrap-Function -ID "Provision-Images"

    $di     = $d[2]

    $dt     = "$dr\Operating Systems\Server" , 
              "$dr\Operating Systems\Client"

    $Date   = ( Get-Date -UFormat "%Y%m%d" ) , 
              ( "( " + ( Get-Date -UFormat "%m-%d-%Y" ) + " MC-SDP )")

    $N_A    = "Not Detected"

    $Tag    = "DC2016" , "10E64" , "10E86" , "10H64" , "10H86" , "10P64" , "10P86"
        
    $Wim    = @{ Name   = @( ( "Windows Server 2016 Datacenter (x64)" ) ; 
                            @( "Education" , "Home" , "Professional"  ) | % { 
                               "Windows 10 $_ (x64)" ; "Windows 10 $_ (x86)" } )
                 Sign   = @( 0..6 | % { "$( $Date[1] ) [ $( $Tag[$_] ) ] " } )
                 Build  = @(    0 | % { "10.0.14393.693" } ; 1..6 | % { "10.0.18362.207" } )
                 Major  = @(    0 | % {  "1607"  } ; 1..6 | % {  "1903" } )
                 Minor  = @(    0 | % { "(693)" } ; 1..6 | % { "(207)" } ) 
                 Author = @( 0..6 | % { ( "Secure Digits Plus LLC" ) } ) }

    $Stamp   = @( 0..6 | % { $wim.Build[$_] + ' [ ' + $wim.Major[$_] + ' ] '  } )

    $DISM    = @( 0..6 ) 
    0..6 | % { $DISM[$_] = @( $Tag[$_] ; $Wim.Name[$_] ; $Wim.Sign[$_] ; $Stamp[$_] ; $Wim.Author[$_] ) }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Working WIM Files ]   ##########################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    Wrap-Action -Type "Loading" -Info "[+] DISM WIM Store"

    $wIndex  = ( GCI $di -EA 0 ).FullName[0..6]
    $wFiles  = ( GCI $wIndex -Filter "*.wim" -EA 0 )

    If ( ( Test-Path $wFiles.FullName[0..6] ) -ne $True ) { 
    
        $Store    = [ Ordered ] @{ 
            Name  = $N_A
            File  = $N_A 
            Tag   = $N_A 
            Path  = $N_A 
            Date  = $N_A 
            Full  = $N_A 
            Build = $N_A } } 

    Else {  

    "When Detected"
        $Store    = [ Ordered ] @{ 
            Name  = ( 0..6 | % { ( Get-WIMName -IP $wFiles.FullName[$_] )        } )
            File  = ( 0..6 | % { $wfiles.Name[$_]                                } )
            Tag   = ( 0..6 | % { $wfiles.BaseName[$_]                            } )
            Path  = ( 0..6 | % { $wfiles.DirectoryName[$_]                       } )
            Date  = ( 0..6 | % { $wfiles.LastWriteTime[$_]                       } ) 
            Full  = ( 0..6 | % { $wfiles.Fullname[$_]                            } )
            Build = ( 0..6 | % { ( Get-WIMBuild -IP $wFiles.FullName[$_] -ID 1 ) } ) } }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Current Server WIM File ]   ####################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    Wrap-Action -Type "Loading" -Info "[+] MDT Server WIM Store"

    If ( ( GCI $dt[0] -EA 0 ) -ne $null )
    {
        $cIndexS  = ( GCI $dt[0] -EA 0 ).FullName
        $cFilesS  = ( GCI $cIndexS -Filter "*.wim" -EA 0 )

    If ( $cFilesS -eq $Null ) { 
    $CurrentS  = [ Ordered ] @{
        Name   = $N_A
        File   = $N_A 
        Tag    = $N_A 
        Path   = $N_A 
        Date   = $N_A 
        Full   = $N_A
        Build  = $N_A  } } 

    Else 
    {
            If ( ( Test-Path ( $cIndexS + '\' + $cfilesS ) ) -eq $True )
            {
                $CurrentS  = [ Ordered ] @{ 
            Name   = "Windows Server 2016 Datacenter (x64)"
            File   = $cfilesS.Name
            Tag    = $cfilesS.BaseName
            Path   = $cfilesS.DirectoryName
            Date   = $cfilesS.LastWriteTime
            Full   = $cfilesS.Fullname
            Build  = ( Get-WIMBuild -IP $cFilesS.FullName -ID 1 )                                 } } } }

    Else {
    $CurrentS  = [ Ordered ] @{
        Name   = $N_A
        File   = $N_A 
        Tag    = $N_A 
        Path   = $N_A 
        Date   = $N_A 
        Full   = $N_A
        Build  = $N_A  } }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Current Client WIM File ]   ####################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    Wrap-Action -Type "Loading" -Info "[+] MDT Client WIM Store"

    If ( ( GCI $dt[1] -EA 0 ) -ne $Null )
    {
        $cIndexC  = ( GCI $dt[1] -EA 0 ).FullName
        $cFilesC  = ( GCI $cIndexC -Filter "*.wim" -EA 0 )

    If ( $cFilesC -eq $Null ) { 
    $CurrentC  = [Ordered] @{
        Name   = $N_A  
        File   = $N_A  
        Tag    = $N_A  
        Path   = $N_A 
        Date   = $N_A 
        Full   = $N_A 
        Build  = $N_A } }

    else
    {

        if ( ( Test-Path ( $cIndexC + '\' + $cfilesC ) ) -eq $True )
        {
            $CurrentC  = [Ordered] @{ 
                Name   = "Windows 10 Home/Education/Pro (x86/64)"
                File   = $cfilesC.Name
                Tag    = $cfilesC.BaseName
                Path   = $cfilesC.DirectoryName
                Date   = $cfilesC.LastWriteTime
                Full   = $cfilesC.Fullname
                Build  = ( Get-WIMBuild -IP $cFilesC.FullName -ID 1 ) } } } }

    else {
    $CurrentC  = [Ordered] @{
        Name   = $N_A
        File   = $N_A 
        Tag    = $N_A 
        Path   = $N_A 
        Date   = $N_A 
        Full   = $N_A
        Build  = $N_A  } }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Update WIM Files ]   ###########################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
        
    $Update   = [Ordered]  @{ 
        Name  = ( "Windows Server 2016 Datacenter (x64)" , "Windows 10 Home/Education/Pro (x86/64)" )
        File  = ( 0..1 | % { "$( $Date[0] )_$( $Wim.Major[$_] )_$( $Wim.Minor[$_] ).wim"          } )
        Tag   = ( 0..6 | % { $Tag[$_]                                                             } ) 
        Path  = $di
        Date  = $Date[0]
        Full  = ( 0..1 | % { ( "$di\$( $Date[0] )_$( $Wim.Major[$_] )_$( $Wim.Minor[$_] ).wim" )  } )
        Build = ( 0..1 | % { $Wim.build[$_]                                                    }  ) }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Stored WIM Info ]   ###########################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    Wrap-Title   -Title   "Stored-WIM(S)"
    
    0..( $Store.File.Count - 1 ) | % {

        Wrap-Section -Section $Store.Name[$_]

        Wrap-ItemOut -Type "[+] Path " -Info  $Store.Path[$_]

        Wrap-ItemIn  -Type "[+] File " -Info  $Store.File[$_]

        Wrap-ItemOut -Type "[+] Date " -Info  $Store.Date[$_]

        Wrap-ItemIn  -Type "[+] Build" -Info $Store.Build[$_]

        Wrap-Out 
    }

    Wrap-Bot

    Read-Host "Verify list and press Enter to continue"

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Current WIM Info ]   ###########################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    Wrap-Title  -Title   "Current-WIM(S)"
    $Current = @{ 0 = $CurrentS ; 1 = $CurrentC }

    0..1 | % {  Wrap-Section -Section                    $Current[$_].Name
                Wrap-ItemOut -Type     "[+] Path " -Info $Current[$_].Path
                Wrap-ItemIn  -Type     "[+] File " -Info $Current[$_].File
                Wrap-ItemOut -Type     "[+] Date " -Info $Current[$_].Date
                Wrap-ItemIn  -Type     "[+] Build" -Info $Current[$_].Build
                Wrap-Out }

    Wrap-Bot

    Read-Host "Press Enter to Continue"

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Update WIM Info ]   ############################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    Wrap-Title `
        -Title "Update-WIM(S)"

    0..( $Update.File.Count - 1 ) | % {
    
        Wrap-Section -Section                $Update.Name[$_]
        Wrap-Itemout -Type "[+] Path " -Info $Update.Path
        Wrap-ItemIn  -Type "[+] File " -Info $Update.File[$_]
        Wrap-ItemOut -Type "[+] Date " -Info $Update.Date
        Wrap-ItemIn  -Type "[+] Build" -Info $Update.Build[$_]

        Wrap-Out 
    
    }

    Wrap-Bot

    Read-Host "Press Enter to Continue"

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ DISM-Server ]   ################################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    Wrap-Action -Type "Processing" -Info $Store.Name[0]

    Echo $DISM

    If ( ( Test-Path  $Update.Full[0] ) -eq $True )
    {
        Remove-Item $Update.Full[0]
    }
    Robocopy $Store.Path[0] $di $Store.File[0]

    Rename-Item  ( "$di\$( $Store.File[0] )" ) `
        -NewName (        $Update.Full[0]    )

    if ( $? -eq $True ) 
    {
        Wrap-Action -Type "Successful" -Info "[+] Server Image Updated" 
    }
    else
    {
        Wrap-Action -Type "Failed" -Info "[!] Server Image not updated" 
    }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ DISM-Client ]   ################################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    Wrap-Function -ID "Client-Image"

    if ( ( Test-Path $Update.Full[1] ) -eq $True ) 
    {
        Remove-Item $Update.Full[1]
    }

    1..6 | % {

        Wrap-Action -Type "DISM" -Info ( $Store.Name[$_] )

        Echo "[ Current Image Info ]" ; "" ; $DISM[$_] ; ""

        Export-WindowsImage                             `
            -SIP                   ( $Store.Full[$_]  ) `
            -SN                    ( $Store.Name[$_]  ) `
            -DIP                   ( $Update.Full[1]  ) `
            -DN                    ( $Store.Name[$_]  ) `
            -vb

        if ( $? -eq $True ) 
        {
            Wrap-Action -Type "Success" -Info "[+] Image $( $Store.Name[$_] ) Updated"
        }
        else 
        { 
            Wrap-Action -Type "Exception" -Info "[!] Image $( $Store.Name[$_] ) Not Updated"
        }
    }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Recycle-MDT ]   ################################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    Wrap-Function -ID "Recycle-MDT" 
    
    # MDT Module/Drive Controls

    $MDTModule = "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
    if ( ( Test-Path $MDTModule ) -eq $True )
    {
        Import-Module $MDTModule
    }
    else
    {
        Read-Host "MDT is not installed or was not detected, press any key to exit."
    }

    $Drive = ( ( Get-MDTPersistentDrive -EA 0 ) | ? { $_.Path -eq $r[16] }).Name

        $MDT = 
            "MDTProvider" , 
            $Drive , 
            "Administrators" , 
            "$( $Drive ):\Operating Systems\Server" , 
            "$( $Drive ):\Operating Systems\Client" ,
            "$( $Drive ):\Task Sequences\Server" , 
            "$( $Drive ):\Task Sequences\Client" , 
            "$( $r[16] )" , 
            "$( $r[16].Split('\')[1] )$" ,
            "$( $r[1] )" , 
            "$dr\Boot" , 
            "$dr\Operating Systems\Server" , 
            "$dr\Operating Systems\Client" , 
            "$dr\Scripts" , 
            "$dr\Control" , 
            "$( $r[0] ) [ Production ]"
        
        $Drive = ( $Drive + ":" )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ URI-Check ]   ##################################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

        if ( ( Test-Path ( $MDT[7] ) ) -ne $True )
        {
            New-Item -Path $MDT[7] -ItemType Directory -Value $MDT[7]

            if ( $? -eq $True ) 
            { 
                Wrap-Action -Type "Directory" -Info "[+] $( $MDT[7] ) created"
            }

            else
            { 
                Wrap-Action -Type "Exception" -Info "[!] $( $MDT[7] ) not created" 
            }
        }

        else
        {
            Wrap-Action -Type "Folder Discovered" -Info "[+] $( $MDT[7] )"
        }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ SMB-Check ]   ##################################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
        
        if ( ( Get-SMBShare -Name ( $MDT[8] ) -EA 0 ) -eq $Null )
        {
            Wrap-Action -Type "SMB-Share" -Info "Not Detected, creating"

            New-SMBShare `
                -Name                             $MDT[ 8] `
                -Path                             $MDT[ 7] `
                -ScopeName                        $MDT[ 0] `
                -Description                      $MDT[15] `
                -FullAccess                       $MDT[ 2]

            if ( $? -eq $True ) 
            {
                Wrap-Action -Type "SMB-Share" -Info "[+] $( $MDT[15] )"      
            }

            else
            {
                Wrap-Action -Type "Exception" -Info "[!] SMB-Share creation $( $MDT[15] ) failed"
            }
        }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ PersistentDrive-Check ]   ######################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

        $GetPSD = ( Get-MDTPersistentDrive -EA 0 )
        if ( ( ( Get-PSDrive -Name ( $GetPSD ).Name -EA 0 ) ) -eq $null )
        {
            Wrap-Action -Type "Persistent Drive" -Info "Not Detected, creating/opening"

            New-PSDrive `
                -Name                           ( $GetPSD ).Name `
                -PSProvider                       $MDT[ 0]       `
                -Root                             $MDT[ 7]       `
                -Description                      $MDT[15]       `
                -NetworkPath                      $MDT[ 9]       `
          | Add-MDTPersistentDrive                $MDT[ 1]

            if ( $? -eq $True )
            {
                Wrap-Action -Type "Persistent Drive" -Info "[+] $( $MDT[15] )"
            }
            else
            {
                Wrap-Action -Type "Persistent Drive" -Info "[!] $( $MDT[15] )"
            }
        }

        $GetPSD = "" ;

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ PSD-Check ]   ##################################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#    

        if ( ( Get-PSDrive -Name $MDT[1] ) -eq $null )
        {
            New-PSDrive `
                -Name                         $MDT[ 1]  `
                -PSProvider                   $MDT[ 0]  `
                -Root                         $MDT[ 7]  `
                -Description                  $MDT[15] `
                -NetworkPath                  $MDT[ 9]
        }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ MDT-Children Check ]   #########################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

        $PSD   = @( $MDT[3..6] | % { $_ } ) + @( $MDT[11..12] | % { $_ } )

        $Path  = @( ( 0..1 | % { "$Drive\Operating Systems" } )
                    ( 2..3 | % { "$Drive\Task Sequences"    } )
                    ( 4..5 | % { "$dr\Operating Systems"    } ) )
                     
        $Name  = @( ( "Server" , "Client" | % { $_ } ) * 3 )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ MDT OS/TS Items Check ]   ######################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

        0..3 | % {

            if ( ( Test-Path $PSD[$_] ) -eq $true )
            { 
                Wrap-Action `
                    -Type               "Path Found" `
                    -Info        "[+] $( $PSD[$_] )"   
            }
        
            else    
            {
                New-Item                             `
                    -Path                  $Path[$_] `
                    -Enable                   "True" `
                    -Name                  $Name[$_] `
                    -Comments        "$( $Date[1] )" `
                    -ItemType               "Folder" `
                    -vb

                if ( $? -eq $True )     
                { 
                    Wrap-Action                      `
                        -Type         "Path Created" `
                        -Info    "[+] $( $PSD[$_] )"
                }
                    
                else
                {
                    Wrap-Action                      `
                        -Type         "Path Failure" `
                        -Info    "[-] $( $PSD[$_] )" 
                }
            }
        }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ MDT-WIM Check ]   ##############################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

        4..5 | % {
            
            # If found, say so and skip

            if ( ( ( Test-Path $PSD[$_] ) -eq $True ) )
            { 
                Wrap-Action                           `
                    -Type                "Path Found" `
                    -Info         "[+] $( $PSD[$_] )"   
            }

            # If not, create and continue
            else           
            {       
                New-Item                              `
                    -Path                    $PSD[$_] `
                    -ItemType               Directory `
                    -Value                   $PSD[$_]
                        
                If ( $? -eq $True ) 
                { 
                    Wrap-Action                       `
                        -Type     "Directory Created" `
                        -Info     "[+] $( $PSD[$_] )" 
                }
                else 
                {
                    Wrap-Action                       `
                        -Type     "Directory Failure" `
                        -Info     "[!] $( $PSD[$_] )"
                }
            }
        }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Recycle-MDT ]   ################################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

        0..5 | % {

            $Name = @( gci ( $PSD[$_] ) -ea 0 )
            if ( $name.count -eq 1 )
            {
                if ( $Name -ne $null )
                {
                    Remove-Item ( $PSD[$_] + '\' + $Name.Name ) -recurse -vb -ea 0
                }
            }
            
            else
            {
                foreach ( $names in $name )
                {
                    if ( $Names -ne $null )
                    {
                        Remove-Item @( $PSD[$_] + '\' + $Names.Name ) -recurse -vb -ea 0
                    }
                }
            }
            
            if ( $? -eq $True )
            {
                Wrap-Action                                 `
                    -Type                         "Removed" `
                    -Info   "[+] $( $PSD[$_] ) Child Items"
            }
            
            else
            {
                Wrap-Action                                 `
                    -Type                       "Exception" `
                    -Info   "[-] $( $PSD[$_] ) Child Items"  
            }
        }

    0..1 | % {

        if ( ( Test-Path $Update.Full[$_] ) -ne $True ) 
        {
            Wrap-Action                               `
                -Type                 "Image Missing" `
                -Info     "[!] $( $Update.Full[$_] )" 
        }
        else                
        {
            Wrap-Action                               `
                -Type                   "Image Found" `
                -Info     "[+] $( $Update.Full[$_] )"
        
        if ( $_ -eq 0 )
        {
            $Folder = "Server"
        }
        else
        {
            $Folder = "Client"
        }

            Import-NewOSImage                        `
                -IP                         $PSD[$_] `
                -SF                 $Update.Full[$_] `
                -DF     "$Folder\$( $Wim.Build[$_])"
            
            if ( $? -eq $True )
            {
                Wrap-Action                             `
                    -Type          "Import Successful" `
                    -Info   "[+] $( $Update.Full[$_] )"
            }

            else
            {
                Wrap-Action                             `
                    -Type                   "Exception" `
                    -Info           "[!] Import Failed"
            }
        }
    }

    $Server = @{
        
        List     = @( GCI $PSD[0] -EA 0              )
        Template = @( "$di\Control\PSDServerMod.xml" )

        }

    $Client = @{
            
        List     = @( GCI $PSD[1] -EA 0              )
        Template = @( "$di\Control\PSDClientMod.xml" )
            
        }

    0..6 | % {

        if ( $_ -eq 0 )
        {
            $XML      = @(     Get-Content $Server.Template )
            $PSP      =                              $MDT[ 5]
            $SIP      = "$( $MDT[3] )\$( $Server.List.Name )"
            $GUID     =                     $Server.List.GUID
        }

        else
        {
            $XML      = @(     Get-Content $Client.Template )
            $PSP      =                              $MDT[ 6]
            $SIP      = "$( $MDT[4] )\$( $Client.List.Name[ ( $_ - 1 ) ] )"
            $GUID     =       $Client.List.GUID[ ( $_ - 1 ) ]
        }

        $XMLArray = @()

        0..$XML.Count | % { if ( $XML[$_] -like "*OSGUID*" ) { $XMLArray += $_ } }
        foreach ( $i in $XMLArray )
        { 
            $XML[$i]  = $XML[$i].Split('{')[0] + $GUID + $XML[$i].Split('}')[1]
        }

        $XML_Path     = "$( $Store.Path[$_] )\$( $Tag[$_] ).xml"
        
        Set-Content                                          `
            -Path                                  $XML_Path `
            -Value                                      $XML `
            -Force 
        
        $NT = @{
                    PSD_Path      =                                    $PSP
                    Cool_ID       =                           $DISM[$_][ 1]
                    XML           =                               $XML_Path
                    Info          =                               $Date[ 1]
                    Tag_ID        =                           $DISM[$_][ 0]
                    Date          =                               $Date[ 0]
                    PS_SIP        =                                    $SIP
                    Dumb_ID       =                           $DISM[$_][ 1]
                    Author        =                                  $R[ 0]
                    Website       =                                  $R[ 5]
                    ChildPW       = $lmcred.GetNetworkCredential().Password
                    }
        
        Wrap-Action `
            -Type                            "Import-NewTask" `
            -Info "[+] $( $DISM[$_][0] ) / $( $DISM[$_][1] )" 

        Import-NewTask `
                -PSP                $NT.PSD_Path  `
                -Formal             $NT.Cool_ID   `
                -XML                $NT.XML       `
                -Info               $NT.Info      `
                -ID                 $NT.Tag_ID    `
                -Ver                $NT.Date      `
                -SIP                $NT.PS_SIP    `
                -TSName             $NT.Dumb_ID   `
                -Org                $NT.Author    `
                -WWW                $NT.Website   `
                -LMCred             $NT.ChildPW   `

    }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Update-DSC ]   #################################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    Wrap-Action -Type "[ MDT ]" -Info "Updating PSDrive $( $MDT[1] ) Properties"
    
    $DSC =   ( $MDT[1] + ':' ) , "Boot.x86" , "Boot.x64" , ".GenerateLiteTouchISO" , 
            ".LiteTouchWIMDescription" , ".LiteTouchISOName" , ".BackgroundFile"

    $n   =  "Comments" , "MonitorHost" +  
            @( $DSC[3..6] | % { $DSC[1] + $_ } ) + 
            @( $DSC[3..6] | % { $DSC[2] + $_ } )

    $v   =  $Date[1] , 
            $r[2] , 
            "True" , 
            ( $r[0] + ' (x86)' ) , 
            ( $r[0] + ' (x86).iso' ) , 
            ( $d[0] + '\' + $r[9]  ) , 
            "True" , 
            ( $r[0] + ' (x64)' ) ,
            ( $r[0] + ' (x64).iso' ) , 
            ( $d[0] + '\' + $r[9] )

    $j = 0
    do
    {
        SP -Path $DSC[0] -Name $n[$j] -Value $v[$j]
        Wrap-Action -Type "Drive Property" -Info "$($n[$j]) set to . . ."
        Echo $v[$j]
        $j = $j + 1
    }
    until ( $j -ge $n.count )

    if ( $? -eq $True ) 
    { 
        Wrap-Action `
            -Type                                             "[ MDT ]" `
            -Info "PSDrive $( $MDT[1] ) Properties updated Successfully"
    }

    else
    { 
        Wrap-Action `
            -Type                                             "[ MDT ]" `
            -Info     "PSDrive $( $MDT[1] ) Properties failed to update"
        
        break 
    }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Recycle-Bootstrap ]   ##########################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
    
    $Bootstrap_hash = @{
            
        Settings = @{
    
            Priority           = "Default"
    
            }

        Default = @{

            DeployRoot         = "http://$( $r[2] ),$( $r[1] )"
            UserID             = "$( $r[3] )"
            UserPassword       = "$( $dccred.GetNetworkCredential().Password )"
            UserDomain         = "$( $r[15] )"
            SkipBDDWelcome     = "YES"

            }
        }
    
    $Bootstrap_ini = "$( $MDT[14] )\Bootstrap.ini"

    If ( ! ( Test-Path $Bootstrap_ini ) ) 
    { 
        RI $Bootstrap_ini -EA 0 -Force 
    }
    
    Export-Ini `
        -Filepath $Bootstrap_ini `
        -Encoding UTF8 `
        -Force `
        -InputObject $Bootstrap_hash `
        -Passthru

    [ System.IO.File ]::WriteAllLines( 
        ( $Bootstrap_ini ), 
        ( GC $Bootstrap_ini ) , 
        ( New-Object System.Text.UTF8Encoding $False ) )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Recycle-CustomSettings ]   #####################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    $CustomSettings_Hash = @{

        Settings = @{

            Priority           = "Default"
            Properties         = "MyCustomProperty"
        
            }
        
        Default = @{
        
            _SMSTSOrgName      = "$( $r[0] )"
            OSInstall          = "Y"
            SkipCapture        = "NO"
            SkipAdminPassword  = "YES"
            SkipProductKey     = "YES"
            SkipComputerBackup = "NO"
            SkipBitLocker      = "YES"
            KeyboardLocale     = "en-US"
            TimeZoneName       = "Eastern Standard Time"
            EventService       = "http://$( $r[2] ):9800"
        
            }
        }

    $CustomSettings_ini = "$( $MDT[14] )\CustomSettings.ini"
    
    If ( ( Test-Path $CustomSettings_ini) -eq $True ) 
    {
        RI $CustomSettings_ini -EA 0 -Force
    }
    
    Export-Ini `
        -Filepath $CustomSettings_ini `
        -Encoding UTF8 `
        -Force `
        -InputObject $CustomSettings_hash `
        -Passthru

    [ System.IO.File ]::WriteAllLines( ( $CustomSettings_ini ) , 
        ( GC $CustomSettings_ini ) , 
        ( New-Object System.Text.UTF8Encoding $False ) )


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ MDT-PXE/Stuff  ]  ##############################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
    $Control = "$DI\Control"

    $Icon = @( gci $Control -Filter "*computer.png" -EA 0 ).FullName
    If ( ( Test-Path $Icon ) -eq $True )
    {
        CP $Icon "$( $MDT[13] )\computer.png"
    }

    $Head = @( gci $Control -Filter "*header-image.png" -EA 0 ).FullName
    If ( ( Test-Path $Head ) -eq $True )
    {
        CP $Head "$( $MDT[13] )\header-image.png"
    }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Hybrid-Launcher ]   ############################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    $Script = @"
#\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
#// /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ \\#
#\\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ //#
#// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
#\\                                                                                                                   //#
#//   <@[ Script-Initialization ]@>                        "Script Magistration by Michael C. 'Boss Mode' Cook Sr."   \\#
#\\                                                                                                                   //#
#//                        [ Secure Digits Plus LLC | Hybrid ] [ Desired State Controller ]                           \\#
#\\                                                                                                                   //#
#//                  [ https://www.securedigitsplus.com | Server/Client | Seedling/Spawning Script ]                  \\#
#\\                                                                                                                   //#
#//                                                                                                                   \\#
#\\# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #//#
#//# [ Declare-Functions ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#\\#
#\\# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #//#

    using namespace System.Security.Principal

    Function Elevate-Script
    {   
        ( [ WindowsPrincipal ] [ WindowsIdentity ]::GetCurrent() ).IsInRole( "Administrators" ) | % {

            If ( ( `$_ -eq `$False ) -and ( ( [ Int ]( gcim Win32_OperatingSystem ).BuildNumber -ge 6000 ) -eq `$True ) )
            {   
                Echo "Attempting [~] Script Elevation"
                
                SAPS `
                    -FilePath PowerShell.exe `
                    -Verb Runas `
                    -Args "-File `$PSCommandPath `$( `$MyInvocation.UnboundArguments )"
                
                If ( `$? -eq `$True ) 
                { 
                    Echo "[+] Elevation Successful"
                    Echo "[+] Access Granted"
                    Return 
                }

                Else
                { 
                    Echo "[!] Elevation Failed"
                    Read-Host "[!] Access Denied"
                    Exit 
                }
            }

            ElseIf ( `$_ -eq `$True )
            {   
                Echo "Access [+] Granted"
                Set-ExecutionPolicy Bypass -Scope Process -Force 
            }
        }
    }  
    
    Elevate-Script

    CMDKEY /add:$( $r[2] ) /user:$( $r[3] ) /pass:$( $dccred.GetNetworkCredential().Password )
    
    If ( `$_ -eq `$True )
    {
         Echo "[+] Domain Credential Added"
    }

    Else
    {
        Echo "Exception [!] - Something didn't feel like 'working correctly'"
    }
    
    CP -Path "$( $r[1] )\$( $r[0] )\(0)Resources\Initialize-HybridClient.ps1" -Destination "`$home\Desktop" -Force
    SC -Path "`$home\Desktop\RootVar.ini" -Value (
    '$( $r[0] )'  , '$(  $r[1] )' , '$( $r[2] )' , '$( $r[3] )' , '$( $dccred.GetNetworkCredential().Password )' ,
    '$( $r[5] )'  , '$(  $r[6] )' , '$( $r[7] )' , '$( $r[8] )' , '$( $r[9] )' , '$( $r[10] )' ,
    '$( $r[11] )' , '$( $r[12] )' , '$( $lmcred.GetNetworkCredential().Password )' , '$( $r[14] )' ,
    '$( $r[15] )' , '$( $r[16] )'
    )
    `$hybrid = "`$home\Desktop\Initialize-Hybrid.ps1"
    If ( Test-Path `$hybrid ) { RI `$hybrid -Force  }
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force
    Powershell.exe "`$Home\Desktop\Initialize-HybridClient.ps1"
"@
    SC -Path "$( $MDT[13] )\Initialize-Hybrid.ps1" -Value $Script -Force
    
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Update-BootImage ]   ###########################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    $Drive = ( $MDT[1] + ':' )
    Switch( $host.UI.PromptForChoice( 'Recycle-MDT' , 'Select MDT Update Method' , 
    [ System.Management.Automation.Host.ChoiceDescription[] ]@( '&Full' , '&Fast' , '&Compress' ) , 
    [ Int ] 0 )  )
    {
        0 { Update-MDTDeploymentShare -Path $Drive -Force -Verbose }
           
        1 { Update-MDTDeploymentShare -Path $Drive -Verbose }

        2 { Update-MDTDeploymentShare -Path $Drive -Compress -Verbose }
    } 

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ WDS-Controls ]   ###############################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    $Boot  = $MDT[10]
    $Lti   = "LiteTouchPE"
    $Pro   = $r[0].Replace(' ','_')
    $x86   = " (x86)"
    $x64   = " (x64)"
    $_86   = "_x86"
    $_64   = "_x64"

  $WDS = "$Boot\$Pro$_86.wim" , "$Boot\$Pro$_64.wim" , "$Boot\$Pro$_86.xml" , "$Boot\$Pro$_64.xml"

  $LTW = "$Boot\$Lti$_86.wim" , "$Boot\$Lti$_64.wim" , "$Boot\$Lti$_86.xml" , "$Boot\$Lti$_64.xml"

  $PXE = $r[0]+$x86 , $r[0]+$x64

  $IMG = @( Get-WDSBootImage -Architecture X86 -EA 0 -ImageName $PXE[0] ;
            Get-WDSBootImage -Architecture X64 -EA 0 -ImageName $PXE[1] )

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Provisional-Boot.x86 ]   #######################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    0..3 | % {
        If ( ( Test-Path $WDS[$_] ) -eq $True )
        {
            Remove-Item $WDS[$_] -Force
            Rename-Item $LTW[$_] $WDS[$_]
        }

        Else
        {
            Rename-Item $LTW[$_] $WDS[$_]
        }
    }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Cycle-BootImages ]   ###########################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    0..1 | % { If ( $_ -eq 0 ) { $Arch = "x86" }
               If ( $_ -eq 1 ) { $Arch = "x64" } }

                If ( $IMG[$_].Description -eq $PXE[$_] )
                { 
                    Remove-WdsBootImage         `
                        -Architecture $Arch     `
                        -ImageName ( $PXE[$_] ) `
                        -vb 
                }

                Wrap-Action `
                    -Type "Recycling" `
                    -Info "[+] WDS Boot Image  / $( $PXE[$_] )"

                Import-WDSBootImage `
                    -Path           $WDS[$_] `
                    -NewDescription $PXE[$_] `
                    -SkipVerify -vb

                If ( $? -eq $True ) 
                { 
                        Wrap-Action `
                        -Type "Recycled" `
                        -Info $WDS[$_] 
                }
            

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Restart-WDS ]   ################################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    Wrap-Function `
        -ID "Restart-WDS"

    Restart-Service `
        -Name WDSServer
    
    If ( $? -eq $true ) 
    { 
        Wrap-Action `
            -Type "WDS Image" `
            -Info "[+] Successfully updated!"
        
        Display-Foot

        Exit 
    }
    
    Else
    {
        Wrap-Action `
            -Type "WDS Image" `
            -Info "[-] Update failed"

        Display-Foot

        Exit 
    }

    }


}

