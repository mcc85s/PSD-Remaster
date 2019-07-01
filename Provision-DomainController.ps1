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
    Provisions a Domain Controller with a GUI that specifically states "Hey, this key you're entering is important."
    
.DESCRIPTION
    Will install all necessary services on a Windows Server Computer much like a DSC-XML file would, except, 
    with a lot less code and a GUI interface that makes it 'pretty simple to do correctly'.
    
.NOTES
          FileName: Provision-DomainController.PS1
          Author: Michael C. 'Boss Mode' Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s 
          Created: 2019-07-01
          Modified: 2019-07-01
          Version - 0.0.0 - ( 2019-07-01 ) - Version 0.0.0 is an alpha build, but this part of the process is pretty bulletproof.
.USAGE
    Use in either basic PowerShell or the ISE Window.
    
#>

    
    # Domain Services / Deployment
    $Services = "AD-Domain-Services" , "GPMC" , "DHCP" +
    # RSAT Items
    @( "RSAT" | % {      "$_" ,  "$_-AD-AdminCenter" ,  "$_-AD-PowerShell" ,
                "$_-AD-Tools" ,            "$_-ADDS" ,     "$_-ADDS-Tools" ,
                    "$_-DHCP" ,    "$_-Role-Tools" } ) +
    # WDS Items
    @(  "WDS" | % {       "$_" ,       "$_-AdminPack" ,     "$_-Deployment" , "$_-Transport" } )

    $Services | % `
    { 
        If ( ( Get-WindowsFeature -Name $_ ).InstallState -ne "Installed" )
        {
            Echo "[~] The role $( $R ) will be installed."
            
            Install-WindowsFeature -Name $_ 
        }

        Else
        {
            Echo "[!] The role $_ is already installed"
        }
    }

    # Initiate Active-Directory Configuration

    Import-Module                                  ADDSDeployment
    
    $xaml = @"
    <Window 
                                        xmlns = "http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                                      xmlns:x = "http://schemas.microsoft.com/winfx/2006/xaml" 
                                        Title = "Secure Digits Plus LLC | Hybrid @ Domain Magistration Key" 
                                        Width = "480" 
                                       Height = "300" 
                          HorizontalAlignment = "Center" 
                                   ResizeMode = "NoResize" 
                        WindowStartupLocation = "CenterScreen" 
                                      Topmost = "True"  >
        <GroupBox 
                                       Header = "Directory Services Restore Mode Password" 
                          HorizontalAlignment = "Center" 
                            VerticalAlignment = "Center" 
                                       Height = "250" 
                                       Margin = "10,10,10,10" 
                                        Width = "460"   >
            <Grid 
                                       Height = "200"   >
                <Grid.ColumnDefinitions>
                    <ColumnDefinition   Width = "25*"  />
                    <ColumnDefinition   Width = "75*"  />
                    <ColumnDefinition   Width = "34*"  />
                    <ColumnDefinition   Width = "75*"  />
                    <ColumnDefinition   Width = "25*"  />
                </Grid.ColumnDefinitions>
                <Grid.RowDefinitions>
                    <RowDefinition     Height = "*"    />
                    <RowDefinition     Height = "*"    />
                    <RowDefinition     Height = "1.5*" />
                    <RowDefinition     Height = "1.5*" />
                    <RowDefinition     Height = "1.5*" />
                </Grid.RowDefinitions>
                <TextBlock             Grid.Row = "0" 
                                    Grid.Column = "1" 
                                Grid.ColumnSpan = "3" 
                                       FontSize = "12" 
                            HorizontalAlignment = "Center" 
                                  TextAlignment = "Center" 
                                     FontWeight = "Heavy" >
                                                   Safeguard this password you are entering.</TextBlock>
                <TextBlock             Grid.Row = "1" 
                                    Grid.Column = "1" 
                                Grid.ColumnSpan = "3" 
                                       FontSize = "12" 
                            HorizontalAlignment = "Center" 
                                  TextAlignment = "Center" >
                                                   Do *not* save it on any computer or electronic device.
                </TextBlock>
                <TextBlock             Grid.Row = "2" 
                                    Grid.Column = "1" 
                                       FontSize = "12" 
                            HorizontalAlignment = "Center" 
                              VerticalAlignment = "Center" 
                                  TextAlignment = "Right"  >
                                                   Password:
                </TextBlock>
                <TextBlock             Grid.Row = "3" 
                                    Grid.Column = "1" 
                                       FontSize = "12" 
                            HorizontalAlignment = "Center" 
                              VerticalAlignment = "Center" 
                                  TextAlignment = "Right"  >
                                                   Confirm:
                </TextBlock>
                <PasswordBox    Grid.ColumnSpan = "3" 
                                       Grid.Row = "2" 
                                    Grid.Column = "2" 
                                           Name = "Password" 
                                   PasswordChar = "*" 
                                         Height = "24" 
                                          Width = "180" 
                              VerticalAlignment = "Center" 
                            HorizontalAlignment = "Left">
                </PasswordBox>
                <PasswordBox    Grid.ColumnSpan = "3" 
                                       Grid.Row = "3" 
                                    Grid.Column = "2" 
                                           Name = "Confirm" 
                                   PasswordChar = "*" 
                                         Height = "24" 
                                          Width = "180" 
                              VerticalAlignment = "Center" 
                            HorizontalAlignment = "Left">
                </PasswordBox>
                <Button                Grid.Row = "4" 
                                    Grid.Column = "1" 
                                           Name = "Ok" 
                                        Content = "OK" 
                                          Width = "140" 
                            HorizontalAlignment = "Right" 
                                         Margin = "0,15,0,0"/>
                <Button                Grid.Row = "4" 
                                    Grid.Column = "3" 
                                           Name = "Cancel" 
                                        Content = "Cancel" 
                                          Width = "140" 
                            HorizontalAlignment = "Center" 
                                         Margin = "0,15,0,0"/>
            </Grid>
        </GroupBox>
    </Window>
"@

    Function Convert-XAMLToWindow 
    { 
        Param (

            [ Parameter ( Mandatory ) ]

                [ String ] $XAML , 
                    
                [ String [] ] $NamedElement = $null ,
                
                [ Switch ] $PassThru )
        
        $Assemblies = ( "Presentation" | % { "$_`Framework" , "$_`Core" } ) , "WindowsBase"
                    
        $Assemblies | % { Add-Type -AssemblyName $_ }
        
        $Reader = [ XML.XMLReader ]::Create( [ IO.StringReader ] $XAML )

        $Output = [ Windows.Markup.XAMLReader ]::Load( $Reader )

        Foreach ( $Name in $NamedElement ) 
        { 
            $Output |                         Add-Member   `
                -MemberType                 NoteProperty   `
                -Name                              $Name   `
                -Value           $Output.FindName( $Name ) `
                -Force 
        }

        If ( $PassThru ) 
        { 
            $Output
        } 
                
        Else           
        { 
            $Null   = $GUI.Dispatcher.InvokeAsync{  
            $Output = $GUI.ShowDialog()
                        
            Set-Variable                                   `
                -Name                             Output   `
                -Value                           $Output   `
                -Scope                                 1   }.Wait()
                    
            $Output
        }
    }

    Function Show-WPFWindow
    {
        Param (

            [ Parameter ( Mandatory ) ] [ Windows.Window ] $GUI )

            $Output = $Null
            $Null   = $GUI.Dispatcher.InvokeAsync{
            $Output = $GUI.ShowDialog()
                    
            Set-Variable                                   `
                -Name                             Output   `
                -Value                           $Output   `
                -Scope                                 1   }.Wait()
                
            $Output
    }

    $GUI = Convert-XAMLtoWindow                            `
        -Xaml                                        $Xaml `
        -NamedElement   'Password','Confirm','Ok','Cancel' `
        -PassThru

    $GUI.Cancel.Add_Click( { $GUI.DialogResult = $False } )

    $GUI.Ok.Add_Click(
    { 
        If ( $GUI.Password.Password -eq "" )
        {
            [ System.Windows.MessageBox ]::Show( 'You must enter a password' , 'Password Error' )
        }
                        
        ElseIf ( $GUI.Password.Password -ne $GUI.Confirm.Password )
        {
            [ System.Windows.MessageBox ]::Show( 'Password must match the confirmation' , 'Confirmation Error' )
        }

        Else { $GUI.DialogResult = $true }
    })

    $GUI.Password.Password = ''
    $GUI.Confirm.Password  = ''
                     $Null = $GUI.Password.Focus()
                   $Output = Show-WPFWindow -GUI $GUI

    If ( $Output -eq $True )
    { 
        $MessageBox = "Reboot Required" , "Your Domain is being configured to specifications."
                      
        [ System.Windows.MessageBox ]::Show( $MessageBox[0] , $MessageBox[1] )

        # Configures the domain as needed
        Install-ADDSForest                                                `
            -SafeModeAdministratorPassword   $GUI.Password.SecurePassword `
            -CreateDnsDelegation:                                  $False `
            -DatabasePath                               "C:\Windows\NTDS" `
            -DomainMode                                    "WinThreshold" `
            -DomainName                            "securedigitsplus.com" `
            -DomainNetbiosName                                  "VERMONT" `
            -ForestMode                                    "WinThreshold" `
            -InstallDns:                                            $True `
            -LogPath                                    "C:\Windows\NTDS" `
            -NoRebootOnCompletion:                                 $False `
            -SysvolPath                               "C:\Windows\SYSVOL" `
            -Force:                                                 $True

        Set-LocalUser $( $Env:Username )                                  `
            -Password                        $GUI.Password.SecurePassword `

    }
            
    Else 
    { 
        Echo "[!] Cancelled - The user either cancelled the dialog or it failed"
        Break
    }
