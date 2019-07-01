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

<#
.SYNOPSIS
	Installation for the PSD toolkit for MDT, AKA a more efficient 'Hydration Kit'
    Includes a switch for the imaging process

.DESCRIPTION
    Performs a GUI installation of an MDT share without needing the MDT GUI to begin a new deployment share
    
    Includes whatever the Hydration kit is trying to do in a much simpler manner ( AKA, checks for minimum requirements
    and if they're not installed, it pulls the installation files directly from Microsoft's website and then proceeds
    to install them silently and automatically.

    . . . this should all have been part of the main script anyway.

.LINK
	  https://github.com/Secure-Digits-Plus-LLC

.NOTES
          FileName: Install-PSD.PS1
          Author: Michael C. 'Boss Mode' Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s 
          Created: 2019-06-29
          Modified: 2019-06-29

          Version - 0.0.0 - ( 2019-06-29 ) - Finalized functional version 1.

.USAGE
    Either in PowerShell natively, or . . . Pst. Like a real man would. In the ISE Window. XD

#>

#//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
#\\ - - [ Elevate-Script ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#

# If the currently used account has Administrator access, and the window is not running as such, this block fixes that   

Function Elevate-Script
{  
    ( $w , $s , $p ) = ( $r = "Principal" ) , "Identity" , "BuiltInRole" | % { [ Type ] "Security.$r.Windows$_" }
    $r = ( New-Object $w $s::GetCurrent() ).IsInRole( $p::( $a = "Administrator" ) ) ; ( $w , $s , $p = "" )
    $f = "-File $PSCommandPath $( $MyInvocation.UnboundArguments )" ; $c = [ Int ] ( gcim Win32_OperatingSystem ).BuildNumber
    
    If        ( $r -eq $True ) { Set-ExecutionPolicy ByPass -Scope Process -Force ; Echo "[+] $a Access Granted"     }
    Else { If ( $c -ge  6000 ) { Echo "[~] Attempting" ; Start-Process -FilePath PowerShell.exe -Verb Runas -Args $f
                                If ( $? -eq $true ) {      Echo "[+] $a Script Elevation Successful" ;      Return } }
                                Else                { Read-Host "[!] $a Access Failed. Press Enter to Exit" ; Exit } }
}
Elevate-Script

#//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
#\\ - - [ Wrapper-Modules]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
                       
# Loads the Echo Wrappers, which stylize the messages. No need for so much logging when you are in the script.
# When you're in a target environment, that's a different story, that's where you need a lot of logging.
# But the server should be doing some logging too... just saying.

$fs = " // " ; $bs = " \\ " ; $Content = "$home\Desktop\Content.txt"
    
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
            if ( $x % 4 -ge 2 ) { $x  = $x - 2 ; $y  = $th.replace( "[" , " [ " ) ; $th = $y }
            if ( $x % 2 -ge 1 ) { $x  = $x - 1 ; $y  = $th.replace( "]" , " ]" )  ; $th = $y ; $z  = 0 }
            if ( $z = 1 ) { $z = " -" } else { $z = "- " } $y = $z * ( $x / 4 ) ; $x = "- " * ( $x / 4 )
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

#//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
#\\ - - [ GUI-Modules ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#

# Loads the GUI that allows anyone to quickly and accurately build a new PSD share, whether for plain MDT, or for
# the PSD project.

# Function that dynamically creates a XAML Window based on a $Xaml variable

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

# Second Function that actually throws the $Xaml content into the previously declared window, and then displays it on the screen

    Function Show-WPFWindow
    {
        Param ( [ Parameter ( Mandatory ) ] [ Windows.Window ] $GUI )

        $Output = $Null
                  $Null   = $GUI.Dispatcher.InvokeAsync{ $Output = $GUI.ShowDialog()
                        Set-Variable -Name Output -Value $Output -Scope 1 }.Wait()
        $Output 
    }

    Switch( $host.UI.PromptForChoice( 'Installation or Imaging ?' , 'Are you installing the program or provisioning images?' , 
    [ System.Management.Automation.Host.ChoiceDescription[] ]@( '&Installing' , '&Imaging' ) , 
    [ Int ] 1 )  )
    {
        0
        { 
    
    $XML       = 
    @{  Title  = "Deployment Share Installation"
        Header = "Deployment Configuration Settings"
        HInfo1 = "This tool will be able to assist you with the installation of MDT for PowerShell."
        HInfo2 = "You can make desired configuration changes from here, but if you are installing this for the 
                 first time, please be wary that this tool is still under development." }
                
    $Block     = ""                                                    ,
                 "Deployment Root, Ex. 'C:\Secured'"                   ,
                 "Deployment Share, Ex. 'Secured$'"                    ,
                 "PSDrive Name, Ex. 'DS001'"                           ,
                 "Share Description, Ex. 'PXD/Hybrid [ Development ]'"

    $Label     = ""      ,
                 "Root"  ,
                 "Share" ,
                 "Name"  ,
                 "Info"

    $TextBoxes = 1..4 | % { "<TextBlock 
                                Grid.Row          =      '$_' 
                                Grid.Column       =      '0' 
                                TextAlignment     =  'Right' 
                                VerticalAlignment = 'Center' 
                                FontSize          =     '10' >
                                $( $Block[$_] )
                             </TextBlock>
                             <TextBox   
                                Grid.Row          =      '$_' 
                                Grid.Column       =      '1' 
                                VerticalAlignment = 'Center' 
                                Height            =     '24' 
                                Width             =    '200' 
                                Name              =   '$( $Label[$_] )' >
                            </TextBox>" }

$Xaml = @"
<Window 
    xmlns                   = "http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x                 = "http://schemas.microsoft.com/winfx/2006/xaml" 
    Title                   = "Secure Digits Plus LLC | Hybrid @ $( $XML.Title )" 
    Width                   = "480" 
    Height                  = "374" 
    HorizontalAlignment     = "Center" 
    ResizeMode              = "NoResize" 
    WindowStartupLocation   = "CenterScreen" 
    Topmost                 = "True" >
    <GroupBox Header="$( $XML.Header)" HorizontalAlignment="Center" Height="320" Margin="10,10,10,10" VerticalAlignment="Center" Width="450">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="80"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="55"/>
        </Grid.RowDefinitions>
            <TextBlock Grid.ColumnSpan="2" TextAlignment="Center" Margin="5,5,5,5" TextWrapping="Wrap">
                $( $XML.HInfo1 )<LineBreak/><LineBreak/>
                $( $XML.HInfo2 )
            </TextBlock>
            $TextBoxes
            <Button  
                Grid.Row     =      "5" 
                Grid.Column  =      "0" 
                Name         =  "Start"     
                Content      =  "Start"     
                Height       =     "40" 
                Width        =    "200" />
            <Button  
                Grid.Row     =      "5" 
                Grid.Column  =      "1" 
                Name         = "Cancel" 
                Content      = "Cancel" 
                Height       =     "40" 
                Width        =    "200" />
        </Grid>
    </GroupBox>
</Window>
"@

    $GUI = Convert-XAMLtoWindow -Xaml $Xaml -NamedElement 'Root', 'Share' , 'Name' , 'Info' , 'Start', 'Cancel' -PassThru

    $GUI.Cancel.Add_Click( { $GUI.DialogResult = $False } )

    $GUI.Start.Add_Click({

        $0 = @( "Root Folder" ; "Network Share Name" ; "PSDrive Name" ; "Share Description" ) 
        $1 = $0 | % { "You must enter a $_" }
        $2 = $0 | % { "$_ Missing" }
        
        $Message = ( 0..3 | % { [ Type ] "System.Windows.MessageBox" } )

        If     (  $GUI.Root.Text -eq "" ) { ( $Message[0] )::Show( $1[0] , $2[0] ) }
        ElseIf ( $GUI.Share.Text -eq "" ) { ( $Message[1] )::Show( $1[1] , $2[1] ) }
        ElseIf (  $GUI.Name.Text -eq "" ) { ( $Message[2] )::Show( $1[2] , $2[2] ) }
        ElseIf (  $GUI.Info.Text -eq "" ) { ( $Message[3] )::Show( $1[3] , $2[3] ) }

        Else { $GUI.DialogResult = $True }

    })    

    $Output = Show-WPFWindow -GUI $GUI

    If ( $Output -eq $True )
    {   
        $Prov = $GUI.Root.Text  ,
                $GUI.Share.Text ,
                $GUI.Name.Text  ,
                $GUI.Info.Text 

                Set-Content -Path $Content -Value $Prov[0..3]
    }

    Else
    {
        Wrap-Action -Type "Exception" -Info "The user exited the dialogue"
        Read-Host "Press Enter to Exit"
        Exit
    }

    $Pull    = @( Get-Content $Content   )
    $Prov    = @( 0..3 | % { $Pull[$_] } )
    Remove-Item $Content -Force
    $Content = ""
    $Pull    = ""

    If ( $Prov[2] -eq "" ) { $Prov[2] = "PXD-Hybrid" } ; If ( $Prov[3] -eq "" ) { $Prov[3] = "PXD [ Development ]" } 

    ( $URI , $SMB , $PXD , $Info ) = $Prov[0..3]

    Switch ( $host.UI.PromptForChoice( 'Upgrade Share' , 'Is this a new or legacy Deployment share ?' , 
    [ System.Management.Automation.Host.ChoiceDescription [] ]@( '&New' , '&Upgrade' ) , [int] 1 ) )
    {
        0
        {
            Wrap-Action -Type "Selected" -Info "Create new Deployment Share"

            $Upgrade = 0

            Wrap-Action -Type "Provisioning" -Info "Deployment Folder"
            
            If ( ( Test-Path $URI ) -eq $False )
            {
                New-Item -Path $URI -ItemType Directory

                If ( $? -eq $True ) 
                { 
                    Wrap-Action -Type "Created" -Info "[+] URI Root / Deployment Folder"
                }

                Else
                {
                    Wrap-Action -Type "Exception" -Info "[!] Failure"
                    
                    Read-Host "An error prevented root creation, Press Enter to Exit"

                    Exit
                }
            }

            Wrap-Action -Type "Provisioning" -Info "Deployment Share"
            
            If ( ( Get-SmbShare | ? { $_.Path -eq $URI } -EA 0 ) -eq $null )
            {     
                New-SmbShare -Name $SMB -Path $URI -FullAccess Administrators -Description $Info

                If ( $? -eq $True )
                {
                    Wrap-Action -Type "Created" -Info "[+] SMB Share / Deployment Share"
                }

                Else
                {
                    Wrap-Action -Type "Exception" -Info "[!] PSD-URI Creation failed"

                    Read-Host "An error prevented share creation, Press Enter to Exit"

                    Exit
                }
            }
        }

        1
        {
            Wrap-Action -Type "Selected" -Info "Upgrade Deployment Share"
            
            $Upgrade = 1
        }
    }

# Mike's old school method of copying the files. Not using this function currently, but left in for legacy reasons

    Function Copy-PXDFolder
    {
        [ CmdLetBinding () ] Param (

            [ ValidateNotNullOrEmpty () ]

                [ Parameter ( Mandatory = $True , Position = 0 ) ]

                    [ string ] $Source,
        
            [ ValidateNotNullOrEmpty () ]
                
                [ Parameter ( Mandatory = $True , Position = 1 ) ]

                    [ String ] $Destination )

        $s = $Source
        $d = $Destination

        Wrap-Action -Type "Copying" -Info "$s to $d with xCopy"

        & xcopy $s $d /s /e /v /y /i

        If ( $? -eq $True )
        {
            Wrap-Action -Type "Successful" -Info "[+] Files were copied from source to target"
        }

        Else
        {
            Wrap-Action -Type "Exception" -Info "[!] Failure"

            Read-Host "MDT Files failed to be sourced correctly, Press Enter to exit"
            Exit
        }
    }

# Wrote an installation cmdlet that strings together the folder creation for ADK, WinPE, & MDT
# But to be honest, could be used for any application . . .

# If the versions that are installed don't meet minimum requirements, it will create a folder
# within the installation folder and then proceed to download the tools from Microsoft.
# It then automatically installs those applications and proceeds.

    Function Provision-Dependency 
    {
        [ CmdLetBinding () ] Param (

            [ Parameter (  Position =                                                                   0 , 
                          Mandatory =                                                               $True , 
                  ValueFromPipeline =                                                               $True , 
                        HelpMessage =                                  "Display Name of the dependency" ) ]

                        [ Alias                                                         ( "Application" ) ]
                        [ String ]                                                                    $ID ,

            [ Parameter ( Position =                                                                    1 , 
                         Mandatory =                                                                $True , 
                 ValueFromPipeline =                                                                $True , 
                       HelpMessage =                                       "Folder the file will go to" ) ]

                       [ Alias                                                               ( "Folder" ) ]
                       [ String ]                                                                   $Path ,

            [ Parameter ( Position =                                                                    2 , 
                         Mandatory =                                                                $True , 
                 ValueFromPipeline =                                                                $True , 
                       HelpMessage =                                            "Destination File Name" ) ]

                       [ Alias                                                             ( "Filename" ) ]
                       [ String ]                                                                   $File ,

            [ Parameter ( Position =                                                                    3 , 
                         Mandatory =                                                                $True , 
                 ValueFromPipeline =                                                                $True , 
                       HelpMessage =                                    "The URL where the file exists" ) ]

                       [ Alias                                                      ( "ResourceLocator" ) ]
                       [ String ]                                                                    $URL , 

            [ Parameter ( Position =                                                                    4 , 
                         Mandatory =                                                                $True , 
                 ValueFromPipeline =                                                                $True , 
                       HelpMessage =                                       "The Silent Argument String" ) ]

                       [ Alias (                                                           "Arguments"  ) ]
                       [ String ]                                                                 $Args ) 

        If ( ( Test-Path $Path ) -ne $True )
        {
            New-Item                                                                                $Path `
                -ItemType                                                                       Directory `
                -Value                                                                              $Path

            Echo                                                                   "[+] Directory created"

        }

        Invoke-WebRequest                                                                                 `
            -Uri                                                                                     $URL `
            -OutFile                                                                          $Path\$File `

        $Dependency = Start-Process                                                                       `
            -FilePath                                                                               $File `
            -Args                                                                                   $Args `
            -WorkingDirectory                                                                       $Path `
            -PassThru 

        for ( $j = 0 ; $j -le 100 ; $j = ( $j + 1 ) % 100 )
        {
            Write-Progress                                                                                `
                -Activity                                                           " [ Installing ] $ID" `
                -PercentComplete                                                                      $j  `
                -Status                                                               "$( $j )% Complete"
            
            Start-Sleep -Milliseconds 250
                                
            if ( $Dependency.HasExited ) 
            {
                Write-Progress                                                                            `
                    -Activity                                                             "[ Installed ]" `
                    -Completed

                Return
            }
        }
        Echo                                                                     "$ID has been installed"
    }

#//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
#\\ - - [ Check-Registry ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#

# This is the part where the versions are actually checked, if it's good, it says so and moves on.
# If it's not, it will do all of the things defined up above.

    $CPU  = $env:PROCESSOR_ARCHITECTURE 
    $SRV  = $env:COMPUTERNAME

    $Path = "" , "\WOW6432Node" `
    | % { "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall" }
    
    If ( $Architecture -eq "x86" )     { $Reg = GP "$( $Path[0] )\*"    }
    Else                               { $Reg = $Path | % { GP "$_\*" } }

    $Req     = "Minimum Requirements"
    $DLX     = "Download and install, or Exit ?"
    $DL      = "&Download" 
    $EX      = "&Exit"
    $Install = "C:\Hybrid-Installation"
    $DC      = "*Kit - Windows 10*" , "*Kit Windows Pre*" , "*Microsoft Deployment Toolkit*"

#//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
#\\ - - [ Check-WinADK ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#

    $Reg | ? { $_.DisplayName -like "$( $DC[0] )" } `
         | % {
                $Item = "WinADK"
                If ( $_.DisplayVersion -ge 10.1.17763.1 )
                { 
                    Wrap-Action                                                                           `
                        -Type                                                        "Dependency / $Item" `
                        -Info                                       "@ $( $_.DisplayVersion ) meets $Req" 
                } 

                Else 
                {
                    Switch ( $host.UI.PromptForChoice( "$Item does not meet $Req" , "$DL" , 
                    [ System.Management.Automation.Host.ChoiceDescription [] ]@( "$DL" , "$EX" ) ,        `
                    [ Int ] 0 ) )
                    {
                        0
                        {   Wrap-Action                                                                   `
                                -Type                                                       "Downloading" `
                                -Info                                                              $Item

                            Provision-Dependency                                                          `
                                    -ID                           "Windows Assessment and Deployment Kit" `
                                    -Path                                                "$Install\$Item" `
                                    -File                                                "winadk1903.exe" `
                                    -URL                "https://go.microsoft.com/fwlink/?linkid=2086042" `
                                    -Args      "/quiet /norestart /log $env:temp\win_adk.log /features +" 
                
                            Wrap-Action                                                                   `
                                -Type                                                             "$Item" `
                                -Info                                                       "[+] Updated"
                        }

                        1
                        {   Read-Host                                             "Press any key to exit"
                            Exit
                        }
                    }
                }
            }

#//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
#\\ - - [ Check-WinPE ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#

    $Reg | ? { $_.DisplayName -like "$( $DC[1] )" } `
         | % {  
                $Item = "WinPE"
                If ( $_.DisplayVersion -ge 10.1.17763.1  ) 
                { 
                    Wrap-Action                                                                           `
                        -Type                                                        "Dependency / $Item" `
                        -Info                                             "@ $( $_.DisplayVersion ) $Req" }  

                Else 
                {
                    Switch ( $host.UI.PromptForChoice( "$Item does not meet $Req" , "$DLX" , 
                    [ System.Management.Automation.Host.ChoiceDescription [] ]@( "$DL" , "$EX" ) ,        `
                    [ Int ] 0 ) )
                    {
                        0
                        {   Wrap-Action                                                                   `
                                -Type                                                       "Downloading" `
                                -Info                                                              $Item

                            Provision-Dependency                                                          `
                                    -ID                        " Windows ADK Preinstallation Environment" `
                                    -Path                                                "$Install\$Item" `
                                    -File                                                 "winpe1903.exe" `
                                    -URL                "https://go.microsoft.com/fwlink/?linkid=2087112" `
                                    -Args      "/quiet /norestart /log $env:temp\win_adk.log /features +" }
                        1
                        {   Read-Host                                             "Press any key to exit"
                            Exit                                                                          }
                    }
                }
            }

#//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
#\\ - - [ Check-MDT]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#

    $Reg | ? { $_.DisplayName -like "$( $DC[2] )" } `
         | % {
                $Item = "MDT"
                If ( $_.DisplayVersion -ge 6.3.8450.0000 )
                { 
                    Wrap-Action                                                                           `
                        -Type                                                        "Dependency / $Item" `
                        -Info                                             "@ $( $_.DisplayVersion ) $Req" } 

                Else 
                {
                    Switch ( $host.UI.PromptForChoice( "$Item does not meet $Req" , "$DLX" , 
                    [ System.Management.Automation.Host.ChoiceDescription [] ]@( "$DL" , "$EX" ) ,        `
                    [ Int ] 0 ) )
                    {
                        0
                        {   Wrap-Action                                                                   `
                                -Type                                                       "Downloading" `
                                -Info                                                              $Item
                        
                            $MDTURL =                    "https://download.microsoft.com/download/3/3/9/" +
                                                                   "339BE62D-B4B8-4956-B58D-73C4685FC492" +
                                                                          "/MicrosoftDeploymentToolkit_x"

                            If ( $CPU -eq "AMD64" ) { $MDTURL =                          "$MDTURL`64.msi" }
                            Else                    { $MDTURL =                          "$MDTURL`86.msi" }

                            Provision-Dependency                                                          `
                                    -ID                                    "Microsoft Deployment Toolkit" `
                                    -Path                                                "$Install\$Item" `
                                    -File                                "MicrosoftDeploymentToolkit.msi" `
                                    -URL                                                        $MDTURL   `
                                    -Args                                             "/quiet /norestart" 
                    
                            Wrap-Action                                                                   `
                                -Type                                                             "$Item" `
                                -Info                                                       "[+] Updated" }

                        1
                        {   Read-Host "Press any key to exit"
                            Exit                                                                          }
                    }
                }
            }


#//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
#\\ - - [ Provision-PXDShare] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#

# This is where the installation files are then placed into the directory/share that was just made.
# I've been working on a process that cleans up the modules these guys are using, but... there's just a lot to go through.
# For now, it does the same thing Michael Niehaus's script said for 2 years, only, I modified it quite a bit.

        $MDTDir = ( ( GP "HKLM:\SOFTWARE\Microsoft\Deployment 4" ).Install_Dir ).TrimEnd( '\' )
        
        Import-Module "$MDTDir\Bin\MicrosoftDeploymentToolkit.psd1"

        # If it's not an upgrade, create a new New-PSDrive with info from the GUI

        If ( $Upgrade -eq 0 )
        {
            If ( ( Get-PSDrive -Name $PXD -EA 0 ) -eq $Null )
            {
                New-PSDrive `
                    -Name                                                           $PXD `
                    -PSProvider                                            "MDTProvider" `
                    -Root                                                           $URI `
                    -Description                                                   $Info `
                    -NetworkPath                                                  "$SMB" `
                    |                                             Add-MDTPersistentDrive
            }
        }

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
            $Scripts = "Scripts"                                               # Scripts #
        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
        
        @( gci                          "$Install\$Scripts" -Filter "*.ps1" -EA 0 ).Name `
        | % {  #Copy-PXDFolder 

                Robocopy                         "$Install\$Scripts" "$URI\$Scripts" $_
                Dir                                                   "$URI\$Scripts\$_" `
                |                                                           Unblock-File }


        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
            $Templates = "Templates"                                         # Templates #
        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
        
        @( gci                                              "$Install\$Templates" ).Name `
        | % { 
                Robocopy                     "$Install\$Templates" "$URI\$Templates" $_
                Dir                                                 "$URI\$Templates\$_" `
                |                                                           Unblock-File }

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
            $Modules = "Tools\Modules"                                         # Modules #
        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

        "PSDGather", "PSDDeploymentShare", "PSDUtility", "PSDWizard" `
        | % {
                $ModPath =                                             "$URI\$Modules\$_"
                
                If ( ( Test-Path "$ModPath" ) -eq $False )
                {
                    $Null = New-Item                                           "$ModPath" `
                        -ItemType                                               Directory `

                    Wrap-Action                                                           `
                        -Type                                                   "Created" `
                        -Info                                          "[+] Directory $_"
                }

                Wrap-Action                                                               `
                        -Type                                                   "Copying" `
                        -Info                             "Module $_ to $URI\$Modules\$_"

                Robocopy                         "$Install\$Scripts" "$ModPath" "$_.psm1"
        
                Dir                                                            "$ModPath" `
                |                                                            Unblock-File }

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
            $BDD = "Microsoft.BDD"                                           # PSSnapIns #
        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

        Wrap-Action                                                                       `
            -Type                                                               "Copying" `
            -Info                                                     "[+] $URI\$Modules"

        If ( ( Test-Path "$URI\$Modules\$BDD.PSSnapin" )                      -eq $False )
        {
            $Null = New-Item                                "$URI\$Modules\$BDD.PSSnapIn" `
                        -ItemType                                              Directory

            Wrap-Action                                                                   `
                -Type                                                           "Created" `
                -Info                                                     "[+] Directory"
        }

        # Some Algebra and Calculus
        
        ( $d , $r , $x ) = ( '.dll' , '.config' , 'xml' )

        $PSSnapIn = ( 
                        (                    "" , $r , "-help.$x" | % {       "$d$_" } ) `
                      + (                    ".Format" , ".Types" | % {   "$_.ps1$x" } ) `
                    | % { "PSSnapIn$_" } )                                               `
                    + (                                   "" , "$r" | % { "Core$d$_" } ) `
                    +                                                  "ConfigManager$d" `

        ( $d , $r , $x ) = ''
                            
        $PSSnapIn `
        | % {   Copy-Item           "$MDTDir\Bin\Microsoft.BDD.$_" "$URI\$Modules\$Snap" }

        Wrap-Action `
            -Type                                                              "Copying" `
            -Info                                                  "[+] $URI\$Templates"

        if ( ( Test-Path "$URI\$Templates" ) -eq $False )
        {
            $Null = New-Item                                           "$URI\$Templates"
        }

        "Groups" , "Medias" , "OperatingSystems" , "Packages" , "SelectionProfiles" , 
        "TaskSequences" , "Applications" , "Drivers" , "Groups" , "LinkedDeploymentShares" `
        | % { "$_.xsd" } `
        | % {
                Copy-Item                      "$MDTDir\$Templates\$_" "$URI\$Templates"
    
                Wrap-Action `
                    -Type                                                      "Copying" `
                    -Info                                          "[+] $URI\$Templates"
        }


        If ( $Upgrade -eq 0 )
        {
            Wrap-Action `
                -Type                                                           "Update" `
                -Info                                           "[+] PSD ISO properties"

            $Name  = 86 , 64 `
            | % {                                            "Boot.x$_.LiteTouchISOName" ; 
                                                      "Boot.x$_.LiteTouchWIMDescription" }
            
            $Value = 86 , 64 `
            | % {                                                 "PSDLiteTouch_x$_.iso" ;
                                                "PowerShell Deployment Boot Image (x$_)" }

            0..3 | % { `
                        SP ${PXD}:                                                       `
                            -Name                                            $Name[$_]   `
                            -Value                                          $Value[$_] } `
        }

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

            $Null = New-Item `
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

#//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
#\\ - - [ Install-Hybrid ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#

# This is the part where I intend to supply an update linkage or installation for my own enhancements and modifications 
# to the MDT process in general.
# It will not work for you at the moment, and there's a reason for that. 

# This switch is disabled for the time being.

    Switch ( $host.UI.PromptForChoice( 'Install-Hybrid' , 'Install main Hybrid components or all?' , 
    [ System.Management.Automation.Host.ChoiceDescription [] ]@( '&Main' , '&All' ) , [int] 1 ) )
    {
        0
        {  $XML        = 
            @{  Title  = "Hybrid Installation"
                Header = "Hybrid Directory Name"
                HInfo1 = "You'll need to enter in a name for your Hybrid Modification directory" }

            $Block = ""                                           ,
                    "Directory Name Ex. 'Secure Digits Plus LLC'"        

            $Label = ""         ,
                    "Directory"  

            $TextBoxes = 1    | % { "<TextBlock 
                                      Grid.Row          =      '$_' 
                                      Grid.Column       =      '0' 
                                      TextAlignment     =  'Right' 
                                      VerticalAlignment = 'Center' 
                                      FontSize          =     '10' >
                                     $( $Block[$_] )
                                  </TextBlock>
                                     <TextBox   
                                      Grid.Row          =      '$_' 
                                      Grid.Column       =      '1' 
                                      VerticalAlignment = 'Center' 
                                      Height            =     '24' 
                                      Width             =    '200' 
                                      Name              =   '$( $Label[$_] )' >
                            </TextBox>" }

            $xaml = @"
<Window 
    xmlns                   = "http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x                 = "http://schemas.microsoft.com/winfx/2006/xaml" 
    Title                   = "Secure Digits Plus LLC | PXD-Hybrid @ $( $XML.Title )" 
    Width                   = "480" 
    Height                  = "260" 
    HorizontalAlignment     = "Center" 
    ResizeMode              = "NoResize" 
    WindowStartupLocation   = "CenterScreen" 
    Topmost                 = "True" >
    <GroupBox 
        Header              = "$( $XML.Header )" 
        HorizontalAlignment = "Center" 
        Height              = "200" 
        Margin              = "10,10,10,10" 
        VerticalAlignment   = "Center" 
        Width               = "450" >
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="80"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="55"/>
        </Grid.RowDefinitions>
            <TextBlock 
                Grid.Row        = "0"
                Grid.ColumnSpan = "2" 
                TextAlignment   = "Center" 
                Margin          = "5,5,5,5" 
                TextWrapping    = "Wrap" 
                FontSize        = "10"  >
                $( $XML.HInfo1 )
            </TextBlock>
                $TextBoxes
            <Button    Grid.Row="5" Grid.Column="0" Name = "Start"  Content = "OK"     Height = "40" Width = "200"/>
            <Button    Grid.Row="5" Grid.Column="1" Name = "Cancel" Content = "Cancel" Height = "40" Width = "200"/>
        </Grid>
    </GroupBox>
</Window>
"@

    $GUI = Convert-XAMLtoWindow -Xaml $Xaml -NamedElement 'Directory', 'Start', 'Cancel' -PassThru

    $GUI.Cancel.Add_Click( { $GUI.DialogResult = $False } )

    $GUI.Start.Add_Click({

        $0 = "Sub Folder Path ( URI ) "
        $1 = $0 | % { "You must enter a $_" }
        $2 = $0 | % { "$_ Missing" }
        
        $Message = ( 0 | % { [ Type ] "System.Windows.MessageBox" } )

        If     (  $GUI.Directory.Text -eq "" ) { ( $Message[0] )::Show( $1[0] , $2[0] ) }

        Else   { $GUI.DialogResult = $True } 

    })    

    $Output = Show-WPFWindow -GUI $GUI

    If ( $Output -eq $True )
    {   
            $Target = $GUI.Directory.Text 

            New-Item "$URI\$Target" -ItemType Directory -Force
        
            Robocopy "C:\Hybrid-Installation\Hybrid" "$URI\$Target" /mir
    }

    Else
    {
        Wrap-Action -Type "Exception" -Info "The user exited the dialogue"
    } 

        }

        1
        {   Wrap-Action -Type "Full Install" -Info "( Currently disabled )"
          #  Echo "[!] Feature not yet implemented"
        }
    }

#//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
#\\ - - [ Install-IIS ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#

    $XML = 
    @{  Title  = "IIS Deployment Server Setup"
        Header = "BITS/IIS Configuration Settings"
        HInfo1 = "This tool will assist with the configuration and deployment of BITS/IIS automatically."
        HInfo2 = "This configuration as is will load many more services than the task at hand requires. You 
                  may feel free to change the `$WebSvc list to your leisure, however, Hybrid may use them all." }

    $Block = ""                                      ,
            "Deployment Root Ex. '$( $URI )'"        ,
            "IIS Site Name Ex. 'PXD-Hybrid'"         ,
            "IIS App Pool Name Ex. 'SecureAppPool'"  ,
            "IIS VirtualHostName Ex. 'Secured'"

    $Label = ""      ,
             "Root"  ,
             "Site"  ,
             "Pool"  ,
             "VHost"

    $TextBoxes = 1..4 | % { "<TextBlock 
                                Grid.Row          =      '$_' 
                                Grid.Column       =      '0' 
                                TextAlignment     =  'Right' 
                                VerticalAlignment = 'Center' 
                                FontSize          =     '10' >
                                $( $Block[$_] )
                             </TextBlock>
                             <TextBox   
                                Grid.Row          =      '$_' 
                                Grid.Column       =      '1' 
                                VerticalAlignment = 'Center' 
                                Height            =     '24' 
                                Width             =    '200' 
                                Name              =   '$( $Label[$_] )' >
                            </TextBox>" }

    $xaml = @"
<Window 
    xmlns                   = "http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x                 = "http://schemas.microsoft.com/winfx/2006/xaml" 
    Title                   = "Secure Digits Plus LLC | PXD-Hybrid @ $( $XML.Title )" 
    Width                   = "480" 
    Height                  = "380" 
    HorizontalAlignment     = "Center" 
    ResizeMode              = "NoResize" 
    WindowStartupLocation   = "CenterScreen" 
    Topmost                 = "True" >
    <GroupBox 
        Header              = "$( $XML.Header )" 
        HorizontalAlignment = "Center" 
        Height              = "320" 
        Margin              = "10,10,10,10" 
        VerticalAlignment   = "Center" 
        Width               = "450" >
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="80"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="55"/>
        </Grid.RowDefinitions>
            <TextBlock 
                Grid.Row        = "0"
                Grid.ColumnSpan = "2" 
                TextAlignment   = "Center" 
                Margin          = "5,5,5,5" 
                TextWrapping    = "Wrap" 
                FontSize        = "10"  >
                $( $XML.HInfo1 )<LineBreak/><LineBreak/>
                $( $XML.HInfo2 )
            </TextBlock>
                $TextBoxes
            <Button    Grid.Row="5" Grid.Column="0" Name = "Start"  Content = "OK"     Height = "40" Width = "200"/>
            <Button    Grid.Row="5" Grid.Column="1" Name = "Cancel" Content = "Cancel" Height = "40" Width = "200"/>
        </Grid>
    </GroupBox>
</Window>
"@

    $GUI = Convert-XAMLtoWindow -Xaml $xaml -NamedElement 'Root', 'Site' , 'Pool' , 'VHost' , 'Start', 'Cancel' -PassThru

    $GUI.Cancel.add_Click({ $GUI.DialogResult = $false })

    $GUI.Start.add_Click({

        $0 = @( "Root Folder Path ( URI ) " ; "Site Name" ; "Application Pool Name" ; "Virtual Directory" ) 
        $1 = $0 | % { "You must enter a $_" }
        $2 = $0 | % { "$_ Missing" }
        
        $Message = ( 0..3 | % { [ Type ] "System.Windows.MessageBox" } )

        If     (  $GUI.Root.Text -eq "" ) { ( $Message[0] )::Show( $1[0] , $2[0] ) }
        ElseIf ( $GUI.Share.Text -eq "" ) { ( $Message[1] )::Show( $1[1] , $2[1] ) }
        ElseIf (  $GUI.Name.Text -eq "" ) { ( $Message[2] )::Show( $1[2] , $2[2] ) }
        ElseIf (  $GUI.Info.Text -eq "" ) { ( $Message[3] )::Show( $1[3] , $2[3] ) }

        Else { $GUI.DialogResult = $True }

    })    

    $Output = Show-WPFWindow -GUI $GUI

    If ( $Output -eq $True )
    {   
        $IIS = $GUI.Root.Text ,
               $GUI.Site.Text ,
               $GUI.Pool.Text ,
               $GUI.VHost.Text 

        If ( $IIS[1] -eq "" ) { $IIS[1] = "Default Web Site" }
        If ( $IIS[2] -eq "" ) { $IIS[2] =   "DefaultAppPool" }
        If ( $IIS[3] -eq "" ) { $IIS[3] =      "BITS-Deploy" }

        ( $SiteRoot , $SiteName , $SitePool , $VHost ) = $IIS[0..3]

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
            New-Item -Path $SiteRoot -ItemType Directory -Name $SiteRoot

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

        Import-Module WebAdministration

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
        
        New-WebAppPool `
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


        # Access Control List Information, using a script found on Chocolatey.org for an ASP.Net installation
        # But also made sure to include a lot of the functions declared by Johan and crew, in addition to 
        # understanding how the "Windows Server Feature" XML configurations are generated, and how to bypass
        # a need for an XML to begin with.

        Function Add-ACL # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        {
            [ CmdletBinding () ] Param (
        
                [ String ] $Path ,

                [ System.Security.AccessControl.FileSystemAccessRule ] $AceObject )

            $OBJACL =  Get-ACL `
                -Path                                                                       $SiteRoot

            $OBJACL.AddAccessRule( $AceObject )       
        
            Set-ACL `
                -Path                                                                       $Path  `
                -AclObject                                                                $OBJACL }
         
        #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        Function New-ACLObject # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        {
            [ CmdletBinding () ] Param (
        
                [ String ] $SamAccountName ,
    
                [ System.Security.AccessControl.FileSystemRights ]     $Permission ,

                [ System.Security.AccessControl.AccessControlType ] $AccessControl = 'Allow' ,
    
                [ System.Security.AccessControl.InheritanceFlags ]    $Inheritance = 'None' ,
        
                [ System.Security.AccessControl.PropagationFlags ]    $Propagation = 'None' )

            New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule( 

                $SamAccountName , $Permission , $Inheritance , $Propagation , $AccessControl ) } 
            
    #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    
             'IIS_IUSRS', 'IUSR', "IIS APPPOOL\$SitePool"   `
             | % {   
     
                 $Obj =  New-AclObject                           `
                            -SamAccountName                       $_ `
                            -Permission             'ReadAndExecute' `
                            -Inheritance          'ContainerInherit' ,
                                                 'ObjectInherit' 

                Add-Acl `
                    -Path                               $SiteRoot `
                    -AceObject                               $Obj
            }
  
        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   
            $AppData = "$SiteRoot"
            'IIS_IUSRS', "IIS APPPOOL\$SitePool" `
            | % {  
             
                $Obj = New-AclObject                             `
                        -SamAccountName                       $_ `
                        -Permission                     'Modify' `
                        -Inheritance          'ContainerInherit',`
                                             'ObjectInherit' `

                Add-Acl `
                    -Path                               $AppData `
                    -AceObject                              $Obj
            }

    #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    }
    
    Else 
    { 
        Wrap-Action -Type "Cancelled" -Info "The user either cancelled the dialog or it failed"
        Read-Host "Press Enter to Exit"
        Exit
    }

    }

        1
        {

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -# # #
# - - - [ Initialize-Hybrid ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

        #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
        # [ Default Settings ] - You may change these settings as you wish, but if you respect my work,  #
        #                        then a little credit from you will go a long way. -MC                   #
        #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

         $hybrid      =     "Initialize-Hybrid.ps1" ; $fs = " // " ; $bs = " \\ " ; 
         $RootVar_ini = "$home\Desktop\RootVar.ini" ;
        $Default = @(      "Secure Digits Plus LLC" ;     
                                  "\\DSC0\Secured$" ; 
                                             "DSC0" ; 
                                           "Hybrid" ;  
                                     "Power`$hell!" ; 
                 "https://www.securedigitsplus.com" ;       
                                   "(802) 447-8528" ; 
                           "24h/d, 7d/w, 365.25d/y" ; 
                    @( "OEM"  | % { "$($_)logo.bmp" ;  "$($_)bg.jpg" } ) ; 
                             "securedigitsplus.com" ; 
                                    "Administrator" ;   
                                     "Power`$hell!" ; `
                                          "Vermont" ; 
                                       "C:\Secured" )

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
     
    # Module that exports hashtables with keys into INI file ( Modified a little, from TechNet )

    Function Export-Ini 
    {
        [ CmdletBinding () ] Param (  

            [ Switch ] $Append ,

            [ ValidateSet ( "Unicode" , "UTF7" ,    "UTF8" , "UTF32" , "ASCII" , 
                            "BigEndianUnicode" , "Default" , "OEM" ) ]

            [ Parameter () ]
                
                [ String ] $Encoding ,
        
        [ ValidateNotNullOrEmpty () ]

        [ ValidatePattern ( '^([a-zA-Z]\:)?.+\.ini$' ) ]

            [ Parameter ( Mandatory = $True ) ]

                [ String ] $FilePath ,
        
                [ Switch ] $Force ,
        
        [ ValidateNotNullOrEmpty () ]

            [ Parameter ( ValueFromPipeline = $True , Mandatory = $True ) ]

                [ Hashtable ] $InputObject ,
        
                [ Switch ] $Passthru )

        Begin 
        { 
            Wrap-Action                                   `
                -Type                        "Processing" `
                -Info "$( $MyInvocation.MyCommand.Name )" 
        }
        
        Process 
        { 
            Wrap-Action                                   `
                -Type                           "Writing" `
                -Info                    "$( $FilePath )"

            If ( $Append ) 
            { 
                $Outfile = Get-Item $FilePath 
            }
              
            Else 
            { 
                $OutFile = New-Item                      `
                    -ItemType                       File `
                    -Path                      $FilePath `
                    -Force:$Force
            }

            if ( ! ( $OutFile ) ) 
            {
                Wrap-Action                              `
                    -Type                    "Exception" `
                    -Info        "Unable to access file" 
            }

            ForEach ( $q in $InputObject.Keys )
            { 
                if ( ! ( $( $InputObject[$q].GetType().Name ) -eq "Hashtable" ) ) 
                { 
                    Wrap-Action                            `
                        -Type                        "Key" `
                        -Info                      " [+] $q"

                    Add-Content                            `
                        -Path                     $OutFile `
                        -Value  "$q=$( $InputObject[$q] )" `
                        -Encoding                $Encoding 
                }
                else 
                {
                    Wrap-Action                            `
                        -Type                    "Section" `
                        -Info                     "[+] $q"

                    Add-Content                            `
                        -Path                     $OutFile `
                        -Value                      "[$q]" `
                        -Encoding                $Encoding
                }

                ForEach ( $z in $( $InputObject[$q].Keys | Sort-Object ) )
                { 
                    If ( $z -Match "^Comment[\d]+" ) 
                    {  
                        Wrap-Action                       `
                            -Type              "Property" `
                            -Info                 "[+] $z"

                        Add-Content                       `
                            -Path                $OutFile `
                            -Value "$( $InputObject[$q][$j] )" `
                            -Encoding           $Encoding 
                    }

                    Else
                    {  
                        Wrap-Action `
                            -Type "Key" `
                            -Info "[+] $z"

                        Add-Content                       `
                            -Path                $OutFile `
                            -Value "$z=$( $InputObject[$q][$z] )" `
                            -Encoding $Encoding
                    }
                }
            
            Add-Content `
                -Path $OutFile `
                -Value "" `
                -Encoding $Encoding
            }

            Wrap-Action `
                -Type "Completed" `
                -Info "$( $MyInvocation.MyCommand.Name ): $FilePath"

            If ( $PassThru ) 
            { 
                Return $OutFile 
            }
        }
         
        End 
        { 
            Wrap-Action `
                -Type "Exiting" `
                -Info "$( $MyInvocation.MyCommand.Name )" 
        } 
    }

        Function Display-TrueColors 
    { 
        $flag = @(
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

    "$fs                                                                                                        $bs";
    "$bs       ________________________________________________________________________________________         $fs";
    "$fs      //                                     |                                                \\        $bs";
    "$bs      \\   *     *     *     *     *     *   - - - - - - - - - - - - - - - - - - - - - - - - -//        $fs";
    "$fs      //      *     *     *     *     *      |   [   S E C U R E  D I G I T S  P L U S    ]   \\        $bs";
    "$bs      \\   *     *     *     *     *     *    - - - - - - - - - - - - - - - - - - - - - - - - //        $fs";
    "$fs      //      *     *     *     *     *      |   [   https://www.securedigitsplus.com     ]   \\        $bs";
    "$bs      \\   *     *     *     *     *     *   - - - - - - - - - - - - - - - - - - - - - - - - -//        $fs";
    "$fs      //      *     *     *     *     *      |                                                \\        $bs";
    "$bs      \\   *     *     *     *     *     *    - - - - - - - - - - - - - - - - - - - - - - - - //        $fs";
    "$fs      //      *     *     *     *     *      |          You are choosing to restore,          \\        $bs";
    "$bs      \\   *     *     *     *     *     *   - - - - - - - - - - - - - - - - - - - - - - - - -//        $fs";
    "$fs      //      *     *     *     *     *      |       'A Heightened Sense of Security'         \\        $bs";
    "$bs      \\   *     *     *     *     *     *    - - - - - - - - - - - - - - - - - - - - - - - - //        $fs";
    "$fs      //                                     |                                                \\        $bs";
    "$bs      \\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//        $fs";
    "$fs      //     [ The Constitution of the United States of America | Pledge of Alligience ]      \\        $bs";
    "$bs      \\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //        $fs";
    "$fs      //                                                                                      \\        $bs";
    "$bs      \\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//        $fs";
    "$fs      //          I pledge allegiance to the flag of the United States of America.            \\        $bs";
    "$bs      \\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //        $fs";
    "$fs      //     And to the Republic, for which it stands. One Nation, Under God, Indivisible     \\        $bs";
    "$bs      \\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//        $fs";
    "$fs      //                      With Liberty . . . and Justice for [ ALL ].                     \\        $bs";
    "$bs      \\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //        $fs";
    "$fs      //                                                                                      \\        $bs";
    "$bs      \\ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//        $fs";
    "$fs      //   What you are seeing is the beginning, of 'no stone unturned' security provisions.  \\        $bs";
    "$bs      \\______________________________________________________________________________________//        $fs";
    "$fs                                                                                                        $bs";
    "$bs      Special Thanks to Michael Niehaus, Damien Van Robaeys, and Shane Young for the inspiration        $fs";
    "$fs      and the education to design this software solution. At this time, this product is far from        $bs";
    "$bs      complete. However.. what it achieves is a 100% purity of your operating system deployment.        $fs";
    "$fs                                                                                                        $bs";
    )

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

    Wrap-Array -Block $flag
    
   # Start-Sleep -Seconds 2
    
    }

    Function Display-Logo 
    { 
        $logo = @(
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
    " //- - - - - - - - - - - - -                                                     - - - - - - - - - - - - - - \\ ";
    " \\ - - - - - - - - - - - -                   {_______________}                   - - - - - - - - - - - - - -// ";
    " //- - - - - - - - - - - -     {__________{ _ _]             [_ _ }__________}     - - - - - - - - - - - - - \\ ";
    " \\ - - - - - - - - - - -   {_ _ _ _ _{_______]  H Y B R I D  [______}_ _ _ _ _}    - - - - - - - - - - - - -// ";
    " //- - - - - - - - - - -  { _ _ _ _ { _ _ _ _ _]             [_ _ _ _ _ } _ _ _ _ }  - - - - - - - - - - - - \\ ";
    " \\ - - - - - - - - - -          { _ _ _ _ _ _]      B Y      [_ _ _ _ _ _ }          - - - - - - - - - - - -// ";
    " //- - - - - - - - - - -                                                             - - - - - - - - - - - - \\ ";
    " \\ - - - - - - - - - - -      [  S E C U R E   D I G I T S   P L U S   L L C  ]    - - - - - - - - - - - - -// ";
    " //- - - - - - - - - - - -                                                           - - - - - - - - - - - - \\ ";
    " \\ - - - - - - - - - - -      \_______________________________________________/      - - - - - - - - - - - -// ";
    " //- - - - - - - - - - -                                                               - - - - - - - - - - - \\ ";
    " \\ - - - - - - - - - -  [  0 6 / 2 5 / 2 0 1 9  |  M I C H A E L  C  C O O K  S R . ]  - - - - - - - - - - -// ";
    " //- - - - - - - - - -                                                                    - - - - - - - - - -\\ ";
    " \\ - - - - - - - - -   \_____________________________________________________________/    - - - - - - - - - // ";
    " //                                                                                                          \\ ";
    " \\               Our primary preference and purpose is to present to all people this promise:               // ";
    " //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\ ";
    " \\                   'We proclaim to process the plan, for platinum protections and policies,               // ";
    " // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\ ";
    " \\             whether premises, product, or patents, via persistently programmed protocology.              // ";
    " //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\ ";
    " \\                 In pursuit of the proper provisions, to prevent any party or personnel,                  // ";
    " // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\ ";
    " \\              from public or private access... using parameters, permissions, and passwords.              // ";
    " // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\ ";)
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

    Wrap-Array -Block $logo
        
    #Start-Sleep -Seconds 2
    
    }


    Function Display-Foot { 
    
    $foot= @(

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
    " //                                                                                                          \\ ";
    " \\  <@[ Script-Complete ]@>                                                                                 // ";
    " //                                                                                                          \\ ";
    " \\                          You've just deployed 'A heightened sense of security.'                          // ";
    " //                                                                                                          \\ ";
    " \\                      [ Secure Digits Plus LLC | Hybrid ] [ Desired State Controller ]                    // ";
    " //                                                                                                          \\ ";
    " \\                                   [ https://www.securedigitsplus.com ]                                   // ";
    " //                                                                                                          \\ ";)
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

    Wrap-Array -Block $foot 
        
    Read-Host "Press Enter to exit" 
    
    }

     $Default       = @(                          "Secure Digits Plus LLC" ;
                                                     "\\DSC0\Secured$" ; 
                                                                "DSC0" ; 
                                                              "Hybrid" ;  
                                                        "Power`$hell!" ; 
                                    "https://www.securedigitsplus.com" ;       
                                                      "(802) 447-8528" ; 
                                              "24h/d, 7d/w, 365.25d/y" ; 
                                        @( "OEM" | % { "$($_)logo.bmp" ;  
                                                         "$($_)bg.jpg" } ) + 
                                                          "Bennington" ;
                                                "securedigitsplus.com" ; 
                                                       "Administrator" ;    
                                                        "Power`$hell!" ;
                                       "webproxy.securedigitsplus.com" ;
                                                             "Vermont" ; 
                                                          "C:\Secured" )
    
   $Label      = @(                     "Organization (Provisionary):" ;  
                     @( "Provisional" | % { "Network Path ($_ Share):" ; 
                                            "Hostname/IP ($_ Server):" ;
                                             "Parent Admin ($_ User):" ; 
                                           "Parent P/W ($_ Password):" ;    
                                               "OEM WWW ($_ Website):" ;
                                               "OEM Phone ($_ Phone):" ;     
                                               "OEM Hours ($_ Share):" } ) +           
                               @( "OEM" | % { "$_ Logo (120x120.bmp):" ;
                                         "$_ Background (Any Format):" ;     
                                       "$_ Branch (Current Location):" } ) +
                                      "Network ID (Domain/Workgroup):" ;
                                   "Child Admin (Provisioning Admin):" ; 
                                  "Child P/W (Provisioning Password):" ;   
                                     "Proxy Host (Provisional Proxy):" ;
                                      "NetBIOS ID (Domain/Workgroup):" ;       
                                        "Server Local Deployment URI:" )
    
    $RowDef    = @( 0..16 | % { "<RowDefinition Height = $('"*"') />" } )

    $TextBlock = @( 0..16 | % { "<TextBlock 
                                                Grid.Column          =     '0' 
                                                Grid.Row             =    '$_' 
                                                Margin               =     '5' 
                                                FontSize             =    '10' 
                                                HorizontalAlignment  = 'Right'>
                                                $( $Label[$_] )
                                 </TextBlock>"                        } )

    $TextBox   = @( 0..16 | % { If ( ( $_ -eq 4 ) -or ( $_ -eq 13 ) )
                                {   "<PasswordBox 
                                                Name                 =   'r$_' 
                                                PasswordChar         = $('"*"') 
                                                Grid.Column          =     '1' 
                                                Grid.Row             =    '$_' 
                                                Height               =    '24' 
                                                FontSize             =    '10' 
                                                Margin               =     '5' >
                                     </PasswordBox>"
                                }

                                Else
                                {
                                    "<TextBox 
                                                Name               =   'r$_' 
                                                Grid.Column        =     '1' 
                                                Grid.Row           =    '$_' 
                                                Height             =    '24' 
                                                FontSize           =    '10' 
                                                Margin             =     '5'>
                                     </TextBox>"
                                } })


    $xaml = @"
    <Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="[ Secure Digits Plus LLC | Hybrid ] Desired State Controller" Width="480" Height="800" WindowStartupLocation="CenterScreen"
    Topmost="True" HorizontalAlignment="Center" ResizeMode="NoResize">
    <StackPanel>
        <StackPanel Margin="10,10,10,10" Width="450" Height="175">
        </StackPanel>
        <StackPanel Height="544">
            <TabControl Height="495" Margin="10,10,10,10" VerticalAlignment="Center">
                <TabItem Header="Root Variables" HorizontalAlignment="Center" Width="100">
                    <GroupBox Header="[ #Hybrid ] Provisional Preferences" HorizontalAlignment="Center" Height="450" Margin="5,5,5,5" VerticalAlignment="Top" Width="425">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="1*"/>
                                <ColumnDefinition Width="1.5*"/>
                            </Grid.ColumnDefinitions>
                            <Grid.RowDefinitions>
                                $RowDef
                            </Grid.RowDefinitions>
                                $TextBlock
                                $TextBox
                        </Grid>
                    </GroupBox>
                </TabItem>
            </TabControl>
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                <Button Name="Start" Margin="0,0,15,0" Height="20" Content="Start" Width="120"/>
                <Button Name="Close" Margin="15,0,0,0" Height="20" Content="Close" Width="120"/>
            </StackPanel>
        </StackPanel>
    </StackPanel>
</Window>
"@  
  
    $n = @( 0..16 | % { "r$_" } ) + "Start" , "Close"
    
# Now that all of the content has been prefetched, it's time to load the window and functions

    $GUI = Convert-XAMLToWindow -XAML $xaml -NamedElement $n -PassThru 
    
    $GUI.Close.Add_Click( { $GUI.DialogResult = $false } )
    
    $GUI.Start.Add_Click( 
    {   
        
        # Subroutine function prefetches, basically when the user clicks the start button,
        # it makes more declarations and then proceeds to find it's way to the end result,
        # which would be '$Output'
        
        $Message = @( 0..16 | % { [ Type ] "System.Windows.MessageBox" } )

        $1       = @( $Default | % { "Example: $_" } )

        $2       = @(                       "Provisionary" ; 
                   @(   "Deployment" | % {      "$_ Share" ; 
                                               "$_ Server" } ) ; 
                   @( "Source Admin" | % {   "$_ Username" ; 
                                             "$_ Password" } ) ;
                   @(        "Support" | % {  "$_ Website" ;  
                                         "$_ Phone Number" ;
                                                "$_ Hours" ; 
                                                 "$_ Logo" ;   
                                           "$_ Background" } ) ;
                                                  "Branch" ;       
                                                  "Domain" ; 
                   @(  "Target Admin"  | % { "$_ Username" ;      
                                             "$_ Password" } ) ;  
                                              "Proxy Host" ;
                                              "NetBIOS ID" ;    
                                             "Folder Path" ) `
                  | % { "$_ Missing" }

        # If this field is empty, draw a message on the screen that prevents the user or script from continuing
        # I've been trying to figure out a way to get all of these into a loop, but it's messy either way. This
        # was the best I could do for now

        If     (  $GUI.r0.Text     -eq "" ) { ( $Message[ 0] )::Show( $1[ 0] , $2[ 0] ) }
        ElseIf (  $GUI.r1.Text     -eq "" ) { ( $Message[ 1] )::Show( $1[ 1] , $2[ 1] ) }
        ElseIf (  $GUI.r2.Text     -eq "" ) { ( $Message[ 2] )::Show( $1[ 2] , $2[ 2] ) }
        ElseIf (  $GUI.r3.Text     -eq "" ) { ( $Message[ 3] )::Show( $1[ 3] , $2[ 3] ) }
        ElseIf (  $GUI.r4.Password -eq "" ) { ( $Message[ 4] )::Show( $1[ 4] , $2[ 4] ) }
        ElseIf (  $GUI.r5.Text     -eq "" ) { ( $Message[ 5] )::Show( $1[ 5] , $2[ 5] ) }
        ElseIf (  $GUI.r6.Text     -eq "" ) { ( $Message[ 6] )::Show( $1[ 6] , $2[ 6] ) }
        ElseIf (  $GUI.r7.Text     -eq "" ) { ( $Message[ 7] )::Show( $1[ 7] , $2[ 7] ) }
        ElseIf (  $GUI.r8.Text     -eq "" ) { ( $Message[ 8] )::Show( $1[ 8] , $2[ 8] ) }
        ElseIf (  $GUI.r9.Text     -eq "" ) { ( $Message[ 9] )::Show( $1[ 9] , $2[ 9] ) }
        ElseIf ( $GUI.r10.Text     -eq "" ) { ( $Message[10] )::Show( $1[10] , $2[10] ) }
        ElseIf ( $GUI.r11.Text     -eq "" ) { ( $Message[11] )::Show( $1[11] , $2[11] ) }
        ElseIf ( $GUI.r12.Text     -eq "" ) { ( $Message[12] )::Show( $1[12] , $2[12] ) }
        ElseIf ( $GUI.r13.Password -eq "" ) { ( $Message[13] )::Show( $1[13] , $2[13] ) }
        ElseIf ( $GUI.r14.Text     -eq "" ) { ( $Message[14] )::Show( $1[14] , $2[14] ) }
        ElseIf ( $GUI.r15.Text     -eq "" ) { ( $Message[15] )::Show( $1[15] , $2[15] ) }
        ElseIf ( $GUI.r16.Text     -eq "" ) { ( $Message[16] )::Show( $1[16] , $2[16] ) }


        Else   { $GUI.DialogResult = $True } } )

        # Defaults, declared in prefetch

              $GUI.r0.Text = $Default[ 0]
              $GUI.r1.Text = $Default[ 1]
              $GUI.r2.Text = $Default[ 2]
              $GUI.r3.Text = $Default[ 3]
          $GUI.r4.Password = $Default[ 4]
              $GUI.r5.Text = $Default[ 5]
              $GUI.r6.Text = $Default[ 6]
              $GUI.r7.Text = $Default[ 7]
              $GUI.r8.Text = $Default[ 8]
              $GUI.r9.Text = $Default[ 9]
             $GUI.r10.Text = $Default[10]
             $GUI.r11.Text = $Default[11]
             $GUI.r12.Text = $Default[12]
         $GUI.r13.Password = $Default[13]
             $GUI.r14.Text = $Default[14]
             $GUI.r15.Text = $Default[15]
             $GUI.r16.Text = $Default[16]

    # Sets the focus to the credentials

    $Null   = $GUI.r4.Focus()

    # All Overloads now have a declaration, definition, method, and result. It's time to run the code.
    
    $Output = Show-WPFWindow  -GUI $GUI
        
        If ( $Output -eq $True )
        {   
            $rv = $GUI.r0.Text  , $GUI.r1.Text  , $GUI.r2.Text  ,      $GUI.r3.Text , $GUI.r4.Password , 
                  $GUI.r5.Text  , $GUI.r6.Text  , $GUI.r7.Text  ,      $GUI.r8.Text , $GUI.r9.Text     , 
                  $GUI.r10.Text , $GUI.r11.Text , $GUI.r12.Text , $GUI.r13.Password , $GUI.r14.Text    , 
                  $GUI.r15.Text , $GUI.r16.Text
            
            # If you're looking for output, you'll need either ( New-Object ) or ( Set-Content )
            # Set-Content creates a file, if you use that, you can use a variable that ties to an actual outfile 
            # "-Path $_" . . . If you use a variable, you'll need to make a global declaration if you want 
            # it to actually work. For instance, $Global:Variable or $Script:Variable, because those items 
            # are considered "Scopes" and they fall under the selected 'Set-ExecutionPolicy'

            Set-Content -Path $Rootvar_INI -Value $rv[0..16] -Force
        } 

        Else 
        { 
            Wrap-Action -Type "Exception" -Info "[!] User canceled out of the Root-Variable Dialog"
            Start-Sleep -Seconds 3
            Exit 

        }
        
    

    Wrap-Action -Type "Initialized" -Info "[ Secure Digits Plus LLC | Hybrid ] Desired State Controller" 

    If ( ( Test-Path $RootVar_ini ) -eq $True )
    {
        Switch( $host.UI.PromptForChoice( 'Root Variables found' , 'Would you like to continue, update, or delete/change its location ?' , 
        [ System.Management.Automation.Host.ChoiceDescription[] ]@( '&Continue' , '&Update' , '&Change' ) , 
        [ Int ] 0 )  )
        {
            0
            {
                Wrap-Action -Type "Continue" -Info "[+] Using current settings and default path"
            }

            1
            {
                Wrap-Action -Type "Update" -Info "[+] Loading Hybrid GUI Module"
                Load-HybridGUI
            }

            2
            {
                Wrap-Action -Type "Change" -Info "[~] Type file location for your variables/credentials"
                [ String ] $Altvar_INI = Read-Host "Location"

                If ( ( Test-Path $altvar_INI ) -ne $True )
                { 
                    Wrap-Action -Type "Exception" -Info "[!] Path validation failed, launching GUI"
                    Load-HybridGUI
                }

                Else
                {
                    Wrap-Action -Type "Detected" -Info "[+] Alternate Root Variables Loaded"
                    $Rootvar_ini = $Altvar_ini
                }
            }
        }
    }
    Else 
    {
        Load-HybridGUI
    }   
        $rv    = @( Get-Content $Rootvar_ini )
        $r     = @( 0..16 | % { $rv[$_] }    )

        $dccred = New-Object -TypeName System.Management.Automation.PSCredential `
            -Args $r[3], ( ConvertTo-SecureString $r[4] -AsPlainText -Force )
        Wrap-Action -Type "Secured" -Info "[+] Source Magistration Key"

        $lmcred = New-Object -TypeName System.Management.Automation.PSCredential `
            -Args $r[12], ( ConvertTo-SecureString $r[13] -AsPlainText -Force )
        Wrap-Action -Type "Secured" -Info "[+] Target Magistration Key"

        ( $rv , $r[4] , $r[13] , $Rootvar_ini ) = ""


        #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -# # #
# - - - [ Provisional Root ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    Wrap-Function -ID "Provisional-Root"

        $Bridge = '(0)Resources' , '(1)Tools' , '(2)Images' , '(3)Profiles' , '(4)Certificates' , 
               '(5)Applications'

        $lm = $env:ComputerName , $env:Processor_Architecture , "$env:SystemDrive\" , $env:SystemRoot , 
            "$env:SystemRoot\System32" , $env:programdata , $env:ProgramFiles

        If ( $lm[0] -eq $r[2] ) { $dr = $r[16] } 
        Else                    { $dr =  $r[1] } 

        $DS = "$DR\$( $R[0] )"
        
        $Root = `
        @{  
            0 = $Bridge | % { "$ds\$_" }
            
            1 = $Bridge | % { "$( $lm[2] + $r[0] )\$_" }

            2 = "( Domain State Controller @ Source )" , "( Current Machine @ Variables )" , 
                "( Provision Index @ Bridge Control )"

            3 = "Provisionary" ,      "(DSC) Share" , "(DSC) Controller" , "Resources" , "Tools / Drivers" , 
                      "Images" ,         "Profiles" ,            "Certs" ,      "Apps"

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
        Wrap-ItemOut -Type $Root[3][0] -Info $r[0]
        Wrap-ItemIn  -Type $Root[3][1] -Info $r[1]
        Wrap-ItemOut -Type $Root[3][2] -Info $r[2]
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
                 Build  = @(    0 | % { "10.0.14393.3025" } ; 1..6 | % { "10.0.18362.175" } )
                 Major  = @(    0 | % {  "2016"  } ; 1..6 | % {  "1903" } )
                 Minor  = @(    0 | % { "(3025)" } ; 1..6 | % { "(175)" } ) 
                 Author = @( 0..6 | % { ( $r[0] ) } ) }

    $Stamp   = @( 0..6 | % { $wim.Build[$_] + ' [ ' + $wim.Major[$_] + ' ] '  } )

    $DISM    = @( 0..6 ) 
    0..6 | % { $DISM[$_] = @( $Tag[$_] ; $Wim.Name[$_] ; $Wim.Sign[$_] ; $Stamp[$_] ; $Wim.Author[$_] ) }

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

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Import-NewOSImage ]   ##########################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

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

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Import-NewTask ]   #############################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    Function Import-NewTask 
    {
        [ CmdLetBinding () ] Param(

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

        Import-MDTTaskSequence `
            -Path                   $PSP `
            -Name                $Formal `
            -Template               $XML `
            -Comments              $Info `
            -ID                      $ID `
            -Version                $Ver `
            -OperatingSystemPath    $SIP `
            -FullName            $TSName `
            -OrgName                $Org `
            -HomePage               $WWW `
            -AdminPassword       $lmcred `
            -Verbose
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
        sp -Path $DSC[0] -Name $n[$j] -Value $v[$j]
        Wrap-Action -Type "Drive Property" -Info "$($n[$j]) set to . . ."
        echo $v[$j]
        $j = $j + 1
    }
    until ( $j -ge $n.count )

    if ( $? -eq $True ) 
    { 
        Wrap-Action `
            -Type                                             "[ MDT ]" `
            -Info "PSDrive $( $MDT[1]) Properties updated Successfully"
    }
    else
    { 
        Wrap-Action `
            -Type                                             "[ MDT ]" `
            -Info     "PSDrive $( $MDT[1]) Properties failed to update"
        
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

            DeployRoot         = "http://$($r[2]),\\$($ENV:ComputerName)\$($psDeploymentShare)"
            UserID             = "$( $r[3] )"
            UserPassword       = "$( $dccred.GetNetworkCredential().Password )"
            UserDomain         = "$( $r[15] )"
            SkipBDDWelcome     = "YES"

            }
        }
    
    $Bootstrap_ini = "$( $MDT[14] )\Bootstrap.ini"

    If ( ! ( Test-Path $Bootstrap_ini ) ) 
    { 
        Remove-Item $Bootstrap_ini -EA 0 -Force 
    }
    
    Export-Ini `
        -Filepath $Bootstrap_ini `
        -Encoding UTF8 `
        -Force `
        -InputObject $Bootstrap_hash `
        -Passthru

    [ System.IO.File ]::WriteAllLines( 
        ( $Bootstrap_ini ), 
        ( Get-Content $Bootstrap_ini ) , 
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
    
    If ( (Test-Path $CustomSettings_ini) -eq $True ) 
    {
        Remove-Item $CustomSettings_ini -EA 0 -Force
    }
    
    Export-Ini `
        -Filepath $CustomSettings_ini `
        -Encoding UTF8 `
        -Force `
        -InputObject $CustomSettings_hash `
        -Passthru

    [ System.IO.File ]::WriteAllLines( ( $CustomSettings_ini ) , 
        ( Get-Content $CustomSettings_ini ) , 
        ( New-Object System.Text.UTF8Encoding $False ) )


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ MDT-PXE/Stuff  ]  ##############################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    $Icon = "$di\Control\computer.png"
    if ( ( test-path $icon ) -eq $True )
    {
        Copy-Item $Icon "$( $MDT[13] )\computer.png"
    }

    $head = "$di\Control\header-image.png"
    if ( ( test-path $head ) -eq $True )
    {
        Copy-Item $Head "$( $MDT[13] )\header-image.png"
    }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
#    [ Hybrid-Launcher ]   ############################################################################
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

    $Script = @(
@"
    (`$w,`$s,`$p)=("Principal"|%{(`$r=`$_),"Identity","BuiltInRole"}|%{[Type]"Security.`$r.Windows`$_"});`$a="Administrator";
    `$r=(New-Object `$w `$s::GetCurrent()).IsInRole( `$p::`$a );`$f="-File `$PSCommandPath `$(`$MyInvocation.UnboundArguments)"
    `$c=[int](gcim Win32_OperatingSystem).BuildNumber
    
    If        ( `$r -eq `$True ) { Set-ExecutionPolicy ByPass -Scope Process -Force ; Echo "[+] `$a Access Granted"     }
    Else { If ( `$c -ge  6000 ) { Echo "[~] Attempting" ; Start-Process -FilePath PowerShell.exe -Verb Runas -Args `$f
                                If ( `$? -eq `$true ) {      Echo "[+] `$a Script Elevation Successful" ;      Return } }
                                Else                { Read-Host "[!] `$a Access Failed. Press Enter to Exit" ; Exit } }
    cmdkey /add:'$( $r[2] )' /user:'$( $r[3] )' /pass:'$( $dccred.GetNetworkCredential().Password )'
    Echo "Domain Credential Added"
    Copy-Item -Path "$( $r[1] + '\' + $r[0] )\(0)Resources\Initialize-HybridClient.ps1" -Destination "`$home\Desktop" -Force
    Set-Content -Path "`$home\Desktop\RootVar.ini" -Value (
    '$( $r[0] )'  , '$(  $r[1] )' , '$( $r[2] )' , '$( $r[3] )' , '$( $dccred.GetNetworkCredential().Password )' ,
    '$( $r[5] )'  , '$(  $r[6] )' , '$( $r[7] )' , '$( $r[8] )' , '$( $r[9] )' , '$( $r[10] )' ,
    '$( $r[11] )' , '$( $r[12] )' , '$( $lmcred.GetNetworkCredential().Password )' , '$( $r[14] )' ,
    '$( $r[15] )' , '$( $r[16] )'
    )
    `$hybrid = "`$home\Desktop\Initialize-Hybrid.ps1" ; if ( `$hybrid ) { Remove-Item ( `$hybrid ) }
    Start-Sleep -Seconds 2
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force
    Powershell.exe "`$Home\Desktop\Initialize-HybridClient.ps1"
"@
)
    Set-Content -Path "$( $MDT[13] )\Initialize-Hybrid.ps1" -Value $Script -Force
    
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
