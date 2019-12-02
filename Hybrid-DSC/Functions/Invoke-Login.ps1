    Function Invoke-Login # Allows entry / use of an AD service account _________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdLetBinding () ] Param (

            [ Parameter ( Position = 0 , Mandatory = $True , ValueFromPipeline = $True ) ] [ String ] $DC      ,
            [ Parameter ( Position = 1 , Mandatory = $True , ValueFromPipeline = $True ) ] [ String ] $Domain  ,
            [ Parameter ( Position = 2 , ValueFromPipeline = $True ) ]                     [ String ] $NetBIOS )


        IEX "Using Namespace System.DirectoryServices"

        $MSG   = ( 0 , "Username" ) , ( 1 , "Password" ) , ( 2 , "Confirmation" ) , ( 3 , "Authentication" ) | % {
            
            $w , $X = $_[0..1]

            If ( $W -lt 2 ) { "Show-Message       '$X Failure'                       'You must enter a $X' " }
            If ( $W -eq 2 ) { "Show-Message 'Password Failure'                       '$_ must match the $X'" }
            If ( $W -eq 3 ) { "Show-Message       '$X Failure' 'Submitted information is invalid/incorrect'" }
        }

        $GUI = Get-XAML -Login | % { Convert-XAMLtoWindow -Xaml $_ -NE ( Find-XAMLNamedElements -XAML $_ ) -PassThru }

        $GUI.Switch.Add_Click(  { $GUI.Port.IsEnabled    =  $True } )
        $GUI.Cancel.Add_Click(  { $GUI.DialogResult      = $False } )
        $GUI.Ok.Add_Click(      { 
        
            $Port         = $GUI.Port | % { If ( $_.IsEnabled ) { $_.Text } Else { 389 } }
            $DomX         = $Domain.Split( '.' ) -join ',DC='
            $GUI          | % {

                      $DX = [ DirectoryEntry ]::New( "LDAP://$DC`:$Port/DC=$DomX" , $_.Username.Text , $_.Password.Password )

                    If ( $_.Username | ? { $_.Text     -eq $Null } )          { IEX $MSG[0] }
                ElseIf ( $_.Password | ? { $_.Password -eq $Null } )          { IEX $MSG[1] }
                ElseIf ( $_.Confirm  | ? { $_.Password -eq $Null } )          { IEX $MSG[2] }
                ElseIf ( $_.Password.Password -notmatch $_.Confirm.Password ) { IEX $MSG[2] }
                ElseIf ( $DX.Name -eq $Null )                                 { IEX $MSG[3] }
                Else   { $_.DialogResult = $True }
            }
        })

        $Null = $GUI.Username.Focus()

        $OP = Show-WPFWindow -GUI $GUI

        If ( $OP -eq $True )
        {
            Write-Theme -Action "Login [+]" "Successful"
            Return [ PSCredential ]::New( $GUI.Username.Text , $GUI.Password.SecurePassword )
        }

        Else
        {
            Write-Theme -Action "Login [!]" "Failed" 12 4 15
        }                                                                           #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}