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
#//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
#\\ - - [ PXD-Wizard ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#

# The following script is newly formatted and contains slight alterations or adjustments made by the aforementioned auth.
# Although I am nowhere close to complete, I have given these scripts my full attention in attempting to optimize them.
# There are definitely many issues that I have noticed, but making mistakes is part of life. Learning from them, and
# making the effort to correct them is what matters the most. Comments, questions, mcook@securedigitsplus.com

<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: PSDWizard.psm1
          Solution: PowerShell Deployment for MDT
          Purpose: Module for the PSD Wizard
          Author: PSD Development Team
          Contact: @Mikael_Nystrom , @jarwidmark , @mniehaus , @SoupAtWork , @JordanTheItGuy
          Primary: @Mikael_Nystrom 
          Created: 
          Modified: 2019-05-09

          Version - 0.0.0 - () - Finalized functional version 1.

          TODO:

          # Added some formatting @mcc85s

.Example
#>

$Script:Wizard = $Null
$Script:Xaml   = $Null

Function Get-PSDWizard
{
    Param ( $XamlPath ) 

    # Load the XAML
    [ void ][ System.Reflection.Assembly ]::LoadWithPartialName( 'PresentationFramework' )
    [ xml ] $Script:Xaml = Get-Content $XamlPath
 
    # Process XAML
    $Reader = ( New-Object System.Xml.XmlNodeReader $Script:Xaml ) 
    $Script:Wizard = [ Windows.Markup.XamlReader ]::Load( $reader )

    # Store objects in PowerShell variables
    $Script:Xaml.SelectNodes( "//*[@Name]" ) | % {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Creating variable $( $_.Name )"
        Set-Variable -Name ( $_.Name ) -Value $Script:Wizard.FindName( $_.Name ) -Scope Global
    }

    # Attach event handlers
    $WizFinishButton.Add_Click(
    {
        $Script:Wizard.DialogResult =  $True
        $Script:Wizard.Close() 
    })

    # Attach event handlers
    $WizCancelButton.Add_Click(
    {
        $Script:Wizard.DialogResult = $False
        $Script:Wizard.Close() 
    })

    # Load wizard script and execute it
    Invoke-Expression "$( $XamlPath ).Initialize.ps1" | Out-Null

    # Return the form to the caller
    Return $Script:Wizard
}

Function Save-PSDWizardResult
{
    $Script:Xaml.SelectNodes( "//*[@Name]" ) `
    | ? { $_.Name -like "TS_*" } `
    | % {       $Name = $_.Name.Substring( 3 )
             $Control = $Script:Wizard.FindName( $_.Name )
               $Value = $Control.Text
        si -Path tsenv:$Name -Value $Value 
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Set variable $Name using form value $Value"
    }
}

Function Set-PSDWizardDefault
{
    $Script:Xaml.SelectNodes( "//*[@Name]") `
    | ? { $_.Name -like "TS_*" } `
    | % {       $Name = $_.Name.Substring( 3 )
             $Control = $Script:Wizard.FindName( $_.Name )
               $Value = $Control.Text
        $Control.Text = ( Get-Item tsenv:$Name ).Value
    }
}

Function Show-PSDWizard
{
    Param ( $XamlPath ) 

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Processing wizard from $XamlPath"

    $Wizard = Get-PSDWizard $XamlPath ; Set-PSDWizardDefault
    $Result = $Wizard.ShowDialog()    ; Save-PSDWizardResult
    Return $Wizard
}

Export-ModuleMember -Function Show-PSDWizard

