#\\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//#
#// /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ \\#
#\\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ //#
#//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
#\\                                                                                                                                                 //#
#//     [=-=-=-=-=-=-=-=-=-]                                                                                             [-=-=-=-=-=-=-=-=-=-=-=]   \\#
#\\     |  Install-Hybrid  |                                                                                             |  Michael C. Cook Sr  |   //#
#//     [-=-=-=-=-=-=-=-=-=]           // -=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_- \\           [=-=-=-=-=-=-=-=-=-=-=-]   \\#
#\\                                    \\                                                                   //                                      //#
#//                               _-_-_//  [ Secure Digits Plus LLC | Hybrid | Desired State Controller ]   \\_-_-_                                 \\#
#\\                              [                                                                                 ]                                //#
#//                               [  https://www.securedigitsplus.com | Server/Client | Seedling/Spawning Script  ]                                 \\#
#\\                              [                                                                                 ]                                //#
#//                              \\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-//                                \\#
#\\                                                                                                                                                 //#
#//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
#\\ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ //#
#// \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \\#
#\\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//#
#//  [ Install-Hybrid ] @: Installs the base folder and application prerequisites for initializing a Hybrid Desired State Controller Server         \\#
#\\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//#

    #[-=-=-=-=-=-=-=-=-=-=-=-=]#
    #|   Declare Namespaces   |#
    #[=-=-=-=-=-=-=-=-=-=-=-=-]#
    Using Namespace System.Security.Principal

#\\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
    Function Elevate-Script #\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ //#
    { #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
        ( [ WindowsPrincipal ] [ WindowsIdentity ]::GetCurrent() ).IsInRole( "Administrators" ) | % { 
        
            If ( ( $_ -eq $False ) -and ( ( [ Int ] ( gcim Win32_OperatingSystem ).BuildNumber -ge 6000 ) -eq $True ) ) 
            {   
                Echo "Attempting [~] Script Elevation"
                SAPS -FilePath PowerShell.exe -Verb Runas -Args "-File $( $MyInvocation.MyCommand.Path ) $( $MyInvocation.UnboundArguments )"
                If ( $? -eq $True ) 
                { 
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
    
            ElseIf ( $_ -eq $True ) 
            { 
                Echo "Access [+] Granted"
                Set-ExecutionPolicy Bypass -Scope Process -Force 
            } 
        } 
    }

#\\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//#
    Function Wrap-Action # Wrap-Action ( Echo / Write-Output Wrapper )/\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ \\#
    { #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=//#
        [ CmdletBinding () ] Param ( 

            [ Parameter ( Position = 0 , Mandatory , ValueFromPipeline = $True ) ][ String ] $Type , 

            [ Parameter ( Position = 1 , Mandatory , ValueFromPipeline = $True ) ][ String ] $Info ) 
      
            $fs = " // " ; $bs = " \\ " ; $x = " " * ( 25 - $Type.Length ) ; $y = " " * ( 80 - $Info.Length )
       
            Echo @( ( $fs + ( "¯-" * 54 ) + $bs ) ; "$( $bs + $x + $Type ) : $( $Info + $y + $fs )" ; ( $fs + ( "-_" * 54 ) + $bs ) ) }

#\\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
    Function Wrap-Array #/\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ //#
    { #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
        [ CmdletBinding () ] Param (
            
            [ Parameter ( Position = 0 , Mandatory , ValueFromPipeline = $True ) ]
            
                [ Array ] $Block )

                $fs = " // " ; $bs = " \\ " ; 
                Echo @( " " * 112 ; $fs + "=-" * 54 + $bs ; $bs + "-=" * 54 + $fs ) ; 
                Echo $Block ;
                Echo @( $bs + "=-" * 54 + $fs ; $fs + "-=" * 54 + $bs ; " " * 112 ) }

#\\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
    Function Display-TrueColors # /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ //#
    { #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
        Wrap-Array -Block @(                                                                                                     #\\ -=-=-=-=-=-=-= //#
        " //                                                                                                              \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\         // -=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_ \\           // " ; #\\ -=-=-=-=-=-=-= //#
        " //         \\                                     ][                                               //           \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\         //   *     *     *     *     *     *   ][ -_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=- \\           // " ; #\\ -=-=-=-=-=-=-= //#
        " //         \\      *     *     *     *     *      ][                                               //           \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\         //   *     *     *     *     *     *   ][ =-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-= \\           // " ; #\\ -=-=-=-=-=-=-= //#
        " //         \\      *     *     *     *     *      ][    Dynamically Engineered Digital Security    //           \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\         //   *     *     *     *     *     *   ][ -=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_- \\           // " ; #\\ -=-=-=-=-=-=-= //#
        " //         \\      *     *     *     *     *      ][                                               //           \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\         //   *     *     *     *     *     *   ][ _-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_ \\           // " ; #\\ -=-=-=-=-=-=-= //#
        " //         \\      *     *     *     *     *      ][    Application Development - Virtualization   //           \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\         //   *     *     *     *     *     *   ][ -_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=- \\           // " ; #\\ -=-=-=-=-=-=-= //#
        " //         \\      *     *     *     *     *      ][        Network & Hardware Magistration        //           \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\         //   *     *     *     *     *     *   ][ =-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-= \\           // " ; #\\ -=-=-=-=-=-=-= //#
        " //         \\                                     ][                                               //           \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\         // -_-=-_-=_-=-_-=-_-=-_-=-_-=-_-=_-=-_][ -=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_- \\           // " ; #\\ -=-=-=-=-=-=-= //#
        " //         \\                                                                                      //           \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\         // -=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_[=]\_/[=]\_/[=]\_/[=]=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-_ \\           // " ; #\\ -=-=-=-=-=-=-= //#
        " //         \\                                 | |               | |                                //           \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\         // _-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=-[=]  H Y B R I D  [=]-=-_-=-_-=-_-=-_-=-_-=-_-=-_-=- \\           // " ; #\\ -=-=-=-=-=-=-= //#
        " //         \\                                 | |               | |                                //           \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\         // -_-=-_-=-_-=-_-=-[=]\_/[=]\_/[=]|=|      B Y      |=|[=]\_/[=]\_/[=]-_-=-_-=-_-=-_-= \\           // " ; #\\ -=-=-=-=-=-=-= //#
        " //         \\                  |                                                 |                 //           \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\         // =-_-=-_-=-_-=-_-=[   S E C U R E   D I G I T S   P L U S   L L C   ]=-_-=-_-=-_-=-_- \\           // " ; #\\ -=-=-=-=-=-=-= //#
        " //         \\                   \                                               /                  //           \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\         // -=-_-=-_-=[=]\_/[=]\_/[=]\_/[=]\_/[=]\__/[=]\__/[=]\_/[=]\_/[=]\_/[=]\_/[=]_-=-_-=-_ \\           // " ; #\\ -=-=-=-=-=-=-= //#
        " //         \\           [=]                                                           [=]          //           \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\         // _-=-_-=-  [=]  0 7 / 2 5 / 2 0 1 9  |  M I C H A E L  C  C O O K  S R . [=]-_-=-_-=- \\           // " ; #\\ -=-=-=-=-=-=-= //#
        " //         \\           [=]                                                           [=]          //           \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\         // _-=-_-=-_-[=]-=-_-=-_-=_-=-_-=-_-=-_-=-_-=-_-=_-=-_-=-_-=-_-=-_-=-_-=_-=[=]=-_-=-_-= \\           // " ; #\\ -=-=-=-=-=-=-= //#
        " //                                                                                                              \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\                                      [ A heightened sense of security ]                                      // " ; #\\ -=-=-=-=-=-=-= //#
        " //                                                                                                              \\ " ) ; Sleep -S 2 } # - \\#

#\\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
    Function Display-Foot # /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ //#
    { #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
        Wrap-Array -Block @(                                                                                                     #\\ -=-=-=-=-=-=-= //#
        " //                                                                                                              \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\    <@[ Script-Complete ]@>                                                                                   // " ; #\\ -=-=-=-=-=-=-= //#
        " //                                                                                                              \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\                        [ Secure Digits Plus LLC | Hybrid ] [ Desired State Controller ]                      // " ; #\\ -=-=-=-=-=-=-= //#
        " //                                                                                                              \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\                                     [ https://www.securedigitsplus.com ]                                     // " ; #\\ -=-=-=-=-=-=-= //#
        " //                                                                                                              \\ " ; #// =-=-=-=-=-=-=- \\#
        " \\                                      [ A heightened sense of security ]                                      // " ; #\\ -=-=-=-=-=-=-= //#
        " //                                                                                                              \\ " ) ; Sleep -S 2 } # - \\#

#\\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
    Function Convert-XAMLToWindow #\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ //#
    { #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
        Param ( [ Parameter ( Mandatory ) ] [ String ]                    $XAML ,
                                            [ String [] ] $NamedElement = $Null ,
                                            [ Switch ]                $PassThru )

        @( "Presentation" | % { "$_`Framework" ; "$_`Core" } ) + "WindowsBase" | % { Add-Type -AssemblyName $_ }

        $Reader       = [ XML.XMLReader ]::Create([ IO.StringReader ] $XAML )

        $Output       = [ Windows.Markup.XAMLReader ]::Load( $Reader )

        $NamedElement | % { $Output | Add-Member -MemberType NoteProperty -Name $_ -Value $Output.FindName( $_ ) -Force }

        If ( $PassThru )  { $Output }

        Else 
        {   
            $Null = $GUI.Dispatcher.InvokeAsync{ $Output = $GUI.ShowDialog()
            SV -Name Output -Value $Output -Scope 1 }.Wait() ; $Output } 
    }

#\\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
    Function Show-WPFWindow #\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ //#
    { #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
        Param ( [ Parameter ( Mandatory ) ] [ Windows.Window ] $GUI ) 

        $Output = $Null 

                  $Null = $GUI.Dispatcher.InvokeAsync{ $Output = $GUI.ShowDialog()
                        SV -Name Output -Value $Output -Scope 1 }.Wait()
        $Output 
    }

#\\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
    Function Install-Hybrid #/ /\ \/ /\ \/ /\ \/ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ //#
    { #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
        $Installation = @{ Name               = "Secure Digits Plus LLC"
                           Title              = "[ Secure Digits Plus LLC | Hybrid ] Desired State Controller Installation"
                           Path               = ( gci "C:\Hybrid-Installation\Hybrid" ).FullName[0]
                           Background         = "background.jpg"
                           Banner             = "banner.png" }

        $Title        = $Installation.Title
        $Background   = $Installation | % { "$( $_.Path )\$( $_.Background )" }
        $Banner       = $Installation | % { "$( $_.Path )\$( $_.Banner )" }

        $XAML = @"
        <Window
                        xmlns                 =       "http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                        xmlns:x               =                    "http://schemas.microsoft.com/winfx/2006/xaml"
                        Title                 =                                                          "$Title" 
                        Width                 =                                                             "640" 
                        Height                =                                                             "450" 
                        WindowStartupLocation =                                                    "CenterScreen"
                        Topmost               =                                                            "True" 
                        HorizontalAlignment   =                                                          "Center"
                        ResizeMode            =                                                        "NoResize" >
            <StackPanel>
                <StackPanel.Background>
                    <ImageBrush ImageSource   =                                                     "$Background" 
                                Stretch       =                                                   "UniformToFill" />
                </StackPanel.Background>
                <StackPanel
                        Height                =                                                             "250" >
                    <Image 
                        Width                 =                                                             "600" 
                        Height                =                                                             "250" 
                        Source                =                                                         "$Banner" 
                        HorizontalAlignment   =                                                          "Center" 
                        Margin                =                                                             "0,0" />
                </StackPanel>
                <StackPanel 
                        Height                =                                                             "120" >
                    <TextBlock
                        HorizontalAlignment   =                                                          "Center" 
                        FontSize              =                                                              "14"
                        FontWeight            =                                                            "Bold" 
                        Foreground            =                                                       "#FF84FF4A" 
                        FontFamily            =                                                        "Segoe UI" >
                        <TextBlock.Effect>
                            <DropShadowEffect
                                ShadowDepth   =                                                               "5"
                                Color         =                                                       "#FF5B5546" />
                        </TextBlock.Effect>
                            Enter an installation folder for Hybrid-DSC
                        </TextBlock>
                    <TextBox
                        Name                  =                                                         "Install"
                        Height                =                                                              "22" 
                        TextWrapping          =                                                            "Wrap" 
                        Width                 =                                                             "300" 
                        Margin                =                                                              "10" />
                </StackPanel>
                <StackPanel 
                    Orientation               =                                                      "Horizontal" 
                    FlowDirection             =                                                     "LeftToRight" 
                    VerticalAlignment         =                                                          "Bottom" 
                    HorizontalAlignment       =                                                          "Center" 
                    Height                    =                                                              "40" 
                    Margin                    =                                                     "145,0,145,0" >
                    <Button 
                        Name                  =                                                           "Start" 
                        Content               =                                                           "Start"  
                        HorizontalAlignment   =                                                            "Left" 
                        Height                =                                                              "20" 
                        Width                 =                                                             "170" />
                    <Button 
                        Name                  =                                                          "Cancel" 
                        Content               =                                                          "Cancel" 
                        HorizontalAlignment   =                                                           "Right" 
                        Height                =                                                              "20" 
                        Width                 =                                                             "170" />
                </StackPanel>
            </StackPanel>
        </Window>
"@
        #_________________________________________#
        # - [ Converts the XAML into a Window ] - #
        # = = = = = = = = = = = = = = = = = = = = #
        $GUI = Convert-XAMLtoWindow -Xaml $XAML -NamedElement "Install" , "Start" , "Cancel" -PassThru

        $GUI.Cancel.Add_Click( { $GUI.DialogResult = $False } )

        $GUI.Start.Add_Click( { 
    
        $0 = "Installation Location" ; $1 = $0 | % { "You must enter a $_" } ; $2 = $0 | % { "$_ Missing" }

        If ( $GUI.Install.Text -eq "" ) { [ System.Windows.MessageBox ]::Show( $1 , $2 ) }

        Else { $GUI.DialogResult = $True } })

        #______________________________________________#
        # - [ Synchronizes WPF with Window Element ] - #
        #= = = = = = = = = = = = = = = = = = = = = = = #
        $Output = Show-WPFWindow -GUI $GUI

        If ( $Output -eq $True )
        {
            $Base     = $GUI.Install.Text
            $Vendor   = "Secure Digits Plus LLC"
            $Registry = "HKLM:\SOFTWARE\Policies"
            $BasePath = "$Registry\$Vendor"

            $Base | ? { ( Test-Path $_ ) -ne $True } | % { 
            
                Wrap-Action "Creating" "Installation Directory"
                NI $_ -ItemType Directory
                If ( $_ -eq $False ) 
                { 
                    Wrap-Action "Exception" "[!] The directory could not be created"
                    Read-Host "Press Enter to Exit"
                    Exit
                }
                Wrap-Action "Created" "[+] Installation Directory"
            }

            Sleep -M 100

            $Base | ? { ( Test-Path $_ ) -eq $True } | % {

                $BasePath | ? { ( Test-Path $_ ) -eq $False } | % {
                        
                    Wrap-Action "Creating" "Registry Entry for Installation path"
                    NI -Path $Registry -Name $Vendor
                    If ( $? -ne $True ) 
                    {
                        Wrap-Action "Exception" "[!] Registry Entry Failed"
                    }
                    ( "Hybrid-DSC" , $Base ) , ( "Installation Date" , ( Get-Date ) ) | % { 
                        SP -Path $BasePath -Name $_[0] -Value $_[1] 
                        Wrap-Action "Created" "[+] $_"
                    }
                }
            }
            Return $Base
        }

        Else
        {
            Wrap-Action "Exception" "[!] The exited or the dialogue failed"
            Read-Host "Press Enter to Exit"
            Exit
        }
    }

#\\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
    Function Populate-DSCRoot #\/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ //#
    { #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
        $Base = ( gp "HKLM:\Software\Policies\Secure Digits Plus LLC" ).'Hybrid-DSC'
        $Inst = @( gci "C:\Hybrid-Installation\Hybrid" ).FullName

        Start $Base

        $Root = "Resources" , "Tools" , "Images" , "Profiles" , "Certificates" , "Applications"

        0..5 | % { "$Base\($_)$( $Root[$_] )" } | ? { ( Test-Path $_ ) -ne $True } | % { NI -Path $_ -ItemType Directory }

        $Root = ( gci $Base ).FullName
        
        $Path = @{  0 = @() ; 1 = "Drivers" , "DISM++" , "VM" ; 2 = @( "DC2016" ; @( "E" , "H" , "P" | % { "$_`64" ; "$_`86" } | % { "10$_" } ) ) 
                    3 = @() ; 4 = "Root" | % { "$_" , "CA" , "Auth$_" } ; 5 = "chrome" , "silverlight" , "jre" , "libre" , "mwb" , "flash" , 
                    "air" , "reader" , "ccleaner" , "klite" ,  "tv" }
        
        $File = @{  0 = @(   "Server" , "Client" | % { "Initialize-Hybrid$_.ps1" } ; "logo.bmp" , "bg.jpg" | % { "OEM$_" } 
                    "StartLayout.xml" ; "UEV-Profile.ps1" ) ; 1 = @() ; 2 = @() ; 3 = @() ; 4 = @() ; 5 = @() }

        ForEach ( $i in 0..5 )
        {
            $R = $Root[$i] ; $P = $Path[$i] ; $C = $Path[$i].Count ; $F = $File[$i] ; $D = $File[$i].Count
            If ( ( $C -gt 1 ) -or ( $D -gt 1 ) )
            {
                If ( $C -gt 1 )
                {
                    ForEach ( $j in ( 0..( $C - 1 ) ) )
                    { 
                        "$R\($j)$( $P[$j] )" | ? { ( Test-Path $_ ) -eq $False } | % { NI -Path $_ -ItemType Directory }
                    }
                }
                
                If ( $D -gt 1 )
                {
                    ForEach ( $k in ( 0..( $D - 1 ) ) )
                    {
                        $F[$k] | ? { ( Test-Path "$R\$_" ) -eq $False } | % { Robocopy "$( $Inst[$i] )" "$R" "$_" }
                    }
                }
            }
        }
    }

#\\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
    Function Collect-Applications #\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ //#
    { #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
        $Base = ( gp "HKLM:\Software\Policies\Secure Digits Plus LLC" ).'Hybrid-DSC'
        If ( ( Test-Path $Base ) -ne $True ) 
        { 
            Wrap-Action "Exception" "[!] The Directory was not found" 
            Read-Host "Press Enter to Exit"
            Exit
        }
        If ( ( gci $Base  ).count -eq 0 )
        { 
            Wrap-Action "Exception" "[!] The Directory was found empty"
            Read-Host "Press Enter to Exit"
            Exit
        }

        $Applications = ( gci $Base -Filter "*Applications" -EA 0 ).FullName

    #=-=[ Application Names ]=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
        
        $DisplayName = @( @( "Google Chrome" , "Microsoft Silverlight" , "Java Runtime Environment" , "Libre Office Fresh" | % { 
        "$_ (x86)" , "$_ (x64)" } ) ; @( "Malwarebytes" ; @( "Flash" , "Air" + @( "Reader DC" | % { "$_" ; "$_ MUI" } ) | % { "Adobe $_" } ) + 
        "CCleaner" , "K-Lite Codec Pack Full" , "Teamviewer 14" ) | % { "$_ (x22)" } )

    #=-=[ Application Versions ]-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
        
        $Version = @( 0..1 | % { "75.0.3770.142" } ; 0..1 | % { "5.1.50907.0" } ; 0..1 | % { "8.0.211" } ; 0..1 | % { "6.2.5" } ; 
        "3.8.3.296511612" ; "32.0.0.223" ; "32.0.0.125" ; "2019.012.20064" ; "2019.012.20035" ; "5.60.7307" ; "15.0.4" ; "14.4.2669" )

    #=-=[ Application URLs ]-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
        
        $URL = @( 
        @( "" ,   "64" | % { "https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise$_.msi" } ) + 
        @( "" , "_x64" | % { "https://download.microsoft.com/download/F/D/0/FD0B0093-DE8A-4C4E-BDC4-F0C56D72018C/50907.00/Silverlight$_.exe" } ) + 
        @( 7 , 9 | % { "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=23872$_`_478a62b7d4e34b78b671c754eaaf38ab" } ) + 
        @( ( "" , 86 ) , ( "_64" , 64 ) | % { 
        "https://download.documentfoundation.org/libreoffice/stable/6.2.5/win/x86$( $_[0] )/LibreOffice_6.2.5_Win_x$( $_[1] ).msi" } ) + 
        "https://downloads.malwarebytes.com/file/mb3/" , 
        "https://download.macromedia.com/get/flashplayer/pdc/32.0.0.223/install_flash_player_32_plugin.msi" , 
        "http://airdownload.adobe.com/air/win/download/32.0/AdobeAIRInstaller.exe" ,
        "http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1901020064/AcroRdrDC1901020064_MUI.exe" ,
        "http://ftp.adobe.com/pub/adobe/reader/win/AcrobatDC/1901220035/AcroRdrDCUpd1901220035_MUI.msp" , 
        "https://download.ccleaner.com/ccsetup560.exe" , 
        "https://files3.codecguide.com/K-Lite_Codec_Pack_1504_Full.exe" ,
        "https://download.teamviewer.com/download/version_14x/TeamViewer_Setup.exe" )

    #=-=[ Application File Names ]-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
        
        $File = @( @( "chrome" , "silverlight" , "jre" , "libre" | % { "$_(x86)" , "$_(x64)" } ) ;
        @( "mwb" ; @( "flash" , "air" + @( "reader" | % { "$_" ; "$_`mui" } ) ) + "ccleaner" , "klite" , "tv" ) | % { "$_(x22)" } )
       
        $X = "msi" , "exe" , "msp" ; $Exe = $X[ 0 , 0 , 1 , 1 , 1 , 1 , 0 , 0 , 1 , 1 , 1 , 1 , 2 , 1 , 1 , 1 ]
        
        $Applications = ( gci $Base -Filter "*Applications" -EA 0 ).FullName ; $Program = ( gci $Applications ).FullName
        
        $Target = $Program[ 0 , 0 , 1 , 1 , 3 , 3 , 4 , 4 , 5 , 6 , 7 , 8 , 8 , 9 , 10 , 2 ]

    #=-=[ Application File Hashes ]-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\\#
            $Checksum = "f5ae4e45ec177ee53513426aabef2d0c0967584c30327678afb6f77535718357" , # Google Chrome x86 # - - - - - - - - - - - - - - - - -\\#
                        "a5941959bf0f5058702252d411cf39c2982c751f5b662c48b651d94ce4a7ee19" , # Google Chrome x64 #- - - - - - - - - - - - - - - - - //#
                        "88e1b76bdf799478a72fa27db0bfe7bc5d02cc7e53675967399300448f0e266f" , # Silverlight x86 # - - - - - - - - - - - - - - - - - -\\#
                        "8d263a6f42a378073b6f057f242a42076f9f4082340153c2e27ecc959c5036aa" , # Silverlight x64 #- - - - - - - - - - - - - - - - - - //#
                        "47DE97325B8EA90EA9F93E1595CC7F843DA0C9C6E4C9532ABEA3A194CFB621D9" , # Java x86 #- - - - - - - - - - - - - - - - - - - - - -\\#
                        "C18CF8F2776B69DC838440AADFAAE36F50717636F38EEC5F1E4A27A8CB4F20FB" , # Java x64 # - - - - - - - - - - - - - - - - - - - - - //#
                        "717fb9e17a3feb8af1662e668b919db86fab343303b78f88c7859003056ee010" , # Libre x86 # - - - - - - - - - - - - - - - - - - - - -\\#
                        "9b01f6f382dbb31367e12cfb0ad4c684546f00edb20054eeac121e7e036a5389" , # Libre x64 #- - - - - - - - - - - - - - - - - - - - - //#
                        "f8247c1c6d47165640e70ee9cfa9a7a7b4e0e96cb850852690742508f70e2f01" , # Malwarebytes #- - - - - - - - - - - - - - - - - - - -\\#
                        "ee34f7a2ecd40039738861fd331ff9d9c5320a33d61b62ae71e108b78f999892" , # Adobe Flash #- - - - - - - - - - - - - - - - - - - - //#
                        "6718308E10A45176155D0ECC8458BD3606308925B91F26A7D08C148CF52C9DB3" , # Adobe Air # - - - - - - - - - - - - - - - - - - - - -\\#
                        "81953f3cf426cbe9e6702d1af7f727c59514c012d8d90bacfb012079c7da6d23" , # Adobe Reader DC #- - - - - - - - - - - - - - - - - - //#
                        "67AAB19943FA63393F15E1354FACCE65BED476D1C2BB5D311DB8450614A33200" , # Adobe Reader DC MUI/Update #- - - - - - - - - - - - -\\#
                        "00be05f95e08eb4f181ccde15403e782150a616cb93fd74525c99920f53a2cea" , # CCleaner # - - - - - - - - - - - - - - - - - - - - - //#
                        "1F6BDE89E752811FDC04492D0F73216720B625E54966B3E350659BABD9AD7A83" , # K-Lite Codec Pack # - - - - - - - - - - - - - - - - -\\#
                        "df26627cc29716b65a3ed72f78d59808244f9bc4ad2624657ddbee79d2baa422"   # Teamviewer 14 #- - - - - - - - - - - - - - - - - - - //#

        $Item = @( 0..15 )
        0..15 | % { $Item[$_] = @{      Name = "$( $DisplayName[$_] ) v$( $Version[$_] )"
                                        File = "$( $Target[$_] )\$( $File[$_] ).$( $Exe[$_] )"
                                         URL = "$( $URL[$_] )"
                                    Checksum = "$( $Checksum[$_] )"} 
        }
        Return $Item
    }

#\\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
    Function Review-Applications #/\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ //#
    { #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
        Switch( $Host.UI.PromptForChoice( "Application Template Review" , "Would you like to review the Designated Application Template?" , 
        [ System.Management.Automation.Host.ChoiceDescription [] ]@( '&Yes' , '&No' ) , [ Int ] 0 ) )
        {
            0 { Wrap-Action "Review" "[~] User chose to review the applications list"

                $Item = @( Collect-Applications )

                $j = 0 ; $Item | % { 
    "#//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\\#"
    "#\\ @: $( If ( $j -lt 10 ) { "$J " } Else { "$J" } ) $( "/\ \/ " * 22                                                                        )//#"
    "#//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\\#"
    "#\\"
    "#//  [ $(               $_.Name ) ]"
    "#\\  *$( ( "-*" ) * ( ( $_.Name.Length / 2 ) ) )-*"
    "#//        URL : $(      $_.URL )"
    "#\\       File : $(     $_.File )"
    "#//   Checksum : $( $_.Checksum )"
    "#\\"
                $Null = ( $j = $j + 1 ) }
                Read-Host "Press Enter to Continue" }

            1 { Wrap-Action "Bypass" "[~] User chose to bypass the application review screen" 
                Sleep -S 1 }
        }
    }

#\\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
    Function Download-Applications # \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ //#
    { #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
        
        $Item  = @( Collect-Applications )
        $Base = ( gp "HKLM:\Software\Policies\Secure Digits Plus LLC" ).'Hybrid-DSC'

        Wrap-Action "Downloading" "[+] Application Template"
        IPMO BITSTransfer

        $Total = [ System.Diagnostics.Stopwatch ]::StartNew()

        $Time  = @( 0..15 )

        0..15 | % { 
            
            If ( ( Test-Path $Item.File[$_] ) -ne $True )
            {
                Wrap-Action "Downloading" "$( $Item.Name[$_] )"
                $Time[$_] = [ System.Diagnostics.Stopwatch ]::StartNew()
                Start-BitsTransfer -Source $Item.URL[$_] -Destination $Item.File[$_] -Description $Item.Name[$_] -EA 0
                If ( $? -eq $False )
                {
                    IWR -Uri $Item.URL[$_] -OutFile $Item.File[$_]
                }
                $Time[$_].Stop()
                Write-Host -F Cyan "Time Elapsed : $( ( $Time[$_] | Select Elapsed ).Elapsed ) $( $Item.Name[$_] )"
            }
        }

        $Total.Stop()
        $T        = $Total.Elapsed
        $Size    = @( gci "$Base\(5)Applications" -Recurse -File | Select Length | % { $_.Length } | Measure -Sum ).Sum
        $Rate    = ( ( $Size / 1MB ) / ( ( $T.Minutes * 60 ) + ( $T.Seconds ) ) | % { "{0:n3}" -f $_ } )

        Wrap-Action "Downloads Complete" "[ Total Time Elapsed @: $( $Total.Elapsed ) @: $Rate MB/sec ]"

        0..15 | % {

            $ID = $( $Item.Name[$_] )

            If ( ( Test-Path $Item.File[$_] ) -ne $True ) { Wrap-Action "Exception" "[!] $ID Not Found" }

            Else 
            { 
                Wrap-Action "Detected" "[+] $( $Item.Name[$_] )"
                
                $Hash = ( Get-FileHash -Path $Item.File[$_] -Algorithm SHA256 ).Hash
                
                If ( $Hash -eq $Item.Checksum[$_] ) { Wrap-Action "[+] Checksum Valid" "$ID" } 
                
                Else 
                {
                    Wrap-Action "[!] Checksum Invalid" "$ID"
                    
                    Wrap-Action "[!] Removing File" "[!] $ID"
                
                    RI $Item.File[$_] -Force
                }
            }
        }
    }

#\\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
    Function Make-Decision #/\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ //#
    { #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
        $BasePath = "HKLM:\Software\Policies\Secure Digits Plus LLC"
        If ( ( gp $BasePath -ea 0 ) -ne $Null ) 
        {
        ( $Base , $InstallDate ) = ( gp $BasePath -EA 0 | % { $_.'Hybrid-DSC' , $_."Installation Date" } )
    
        If ( ( ( $Base , $InstallDate ) -ne $Null ) -and ( Test-Path $Base ) -eq $True ) 
        { 
            Switch( $Host.UI.PromptForChoice( 
"Change / Refresh / Remove" ,
" An existing installation was detected        
                                               
    [ Hybrid-DSC Location ]                    
    = = = = = = = = = = =                      
        $Base                                      
                                               
    [ Installation Date ]                      
    = = = = = = = = =                          
        $InstallDate                               
                                            " ,
            [ System.Management.Automation.Host.ChoiceDescription [] ]@( '&Change' , '&Refresh' , '&Remove' ) , [ Int ] 0 ) )
            {
                0 { Wrap-Action "Change" "[+] Selected"
                    RI $BasePath
                    RI $Base -Recurse -Force
                    ( $Base , $BasePath , $InstallDate ) = $Null
                    Install-Hybrid
                    Populate-DSCRoot
                    Review-Applications
                    Download-Applications
                    Wrap-Action "Installation" "[+] Complete"
                    Read-Host "Press Enter to Exit" 
                    Exit } 
                
                1 { Wrap-Action "Refresh" "[+] Selected"
                    RI $Base -Recurse -Force
                    NI $Base -ItemType Directory
                    Populate-DSCRoot
                    Review-Applications
                    Download-Applications
                    Wrap-Action "Installation" "[+] Complete"
                    Read-Host "Press Enter to Exit" 
                    Exit }

                2 { Wrap-Action "Remove" "[+] Selected"
                    RI $BasePath
                    RI $Base -Recurse -Force 
                    Wrap-Action "Uninstallation" "[+] Complete"
                    Read-Host "Press Enter to Exit" 
                    Exit } 
            }
        }
        If ( $Base -ne $Null -and ( ( Test-Path $Base -EA 0 ) -eq $True ) -and ( ( gci $Base ).count -eq 0 ) ) 
        { 
            Populate-DSCRoot
            Review-Applications
            Download-Applications
            Read-Host "[+] Installation Complete" 
            Exit
        }
    }

    Else
    {
        Install-Hybrid
        Populate-DSCRoot
        Review-Applications
        Download-Applications
        Read-Host "[+] Installation Complete"
        Exit
    }
}

#\\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
Elevate-Script ; Display-TrueColors ; Make-Decision #\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ //#
#\\=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\#
