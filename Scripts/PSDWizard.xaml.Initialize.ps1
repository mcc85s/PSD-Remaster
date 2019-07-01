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
#\\ - - [ PXD-Wizard.Xaml.Initialize ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
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
          FileName: PSDWizard.xaml.ps1
          Solution: PowerShell Deployment for MDT
          Purpose: Script to initialize the wizard content in PSD
          Author: PSD Development Team
          Contact: @Mikael_Nystrom , @jarwidmark , @mniehaus , @SoupAtWork , @JordanTheItGuy
          Primary: @Mikael_Nystrom 
          Created: 
          Modified: 2019-05-09

          Version - 0.0.0 - () - Finalized functional version 1.

          TODO:

.Example
#>
Function Validate-Wizard
{
    # TODO: Make sure selection has been made
    # TODO: Set hidden variables / In order words, keep embedding 'problems' like CEIP
}

# Populate the top-level tree items
gci -Path "DeploymentShare:\Task Sequences" `
    | % {  $T = New-Object System.Windows.Controls.TreeViewItem
    $T.Header = $_.Name
       $T.Tag = $_
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : $( $T.Tag.PSPath )"
    If ( $_.PSIsContainer )
    {
        $T.Items.Add("*")
    }
    $TSTree.Items.Add( $T )
}

# Create the Expand event handler
[ System.Windows.RoutedEventHandler ] $ExpandEvent = {

    If ( $_.OriginalSource -is [ System.Windows.Controls.TreeViewItem ] )
    {
        # Populate the next level of objects
        $Current = $_.OriginalSource
        $Current.Items.clear()
            $Pos = $Current.Tag.PSPath.IndexOf(   "::" ) + 2
           $Path = $Current.Tag.PSPath.Substring( $Pos )
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): $Path"

        gci -Path $Path `
        | % {   $T        = New-Object System.Windows.Controls.TreeViewItem
                $T.Header = $_.Name
                $T.Tag    = $_
            Of ( $_.PSIsContainer )
            {
                $T.Items.Add( "*" )
            }
            $Current.Items.Add( $T )
        }
    }
}
$TSTree.AddHandler( [ System.Windows.Controls.TreeViewItem ]::ExpandedEvent , $expandEvent )

# Create the SelectionChanged event handler
$TSTree.add_SelectedItemChanged({
    If ( $This.SelectedItem.Tag.PSIsContainer -ne $True )
    {
        $TS_TaskSequenceID.Text = $This.SelectedItem.Tag.ID
    }
})
