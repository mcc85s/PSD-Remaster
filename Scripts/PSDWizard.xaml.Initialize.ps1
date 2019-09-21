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
