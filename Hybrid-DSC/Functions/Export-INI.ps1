    Function Export-Ini # Based on Oliver Lipkau's OutFile-INI on TechNet ______________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdLetBinding () ] Param ( 

            [ Parameter ( Mandatory = $True , Position = 0 ) ][ String ] $Path , 
            [ ValidateNotNullOrEmpty () ][ ValidatePattern ( '^([a-zA-Z]\:)?.+\.ini$' ) ] 
            [ Parameter ( Mandatory = $True , Position = 1 ) ][ String ] $Name ,
            [ ValidateNotNullOrEmpty () ]
            [ Parameter ( Mandatory = $True , Position = 2 , ValueFromPipeline = $True ) ][ Hashtable ] $Value , 
            [ ValidateSet ( "Unicode" , "UTF7" , "UTF8" , "UTF32" , "ASCII" , "BigEndianUnicode" , "Default" , "OEM" ) ] 
            [ Parameter ( Mandatory = $True , Position = 3 ) ][ String ] $Encoding = "Unicode" ,
                [ Switch ] $Force     , 
                [ Switch ] $Append    , 
                [ Switch ] $UTF8NoBOM ) 

        Begin
        {
            $P , $E , $F , $O , $HT = $Path , $Encoding , "$Path\$Name" , $Value , "Hashtable"

            If ( !$O )                { Write-Theme -Action "Exception [!]" "Value is Null" ; Break }
            If ( !( Test-Path $P ) )  { Write-Theme -Action "Exception [!]" "Invalid Path"  ; Break }
            If ( ( Test-Path $F ) -and ( !$Force ) )
            { 
                If (  $Append )       { $OF = @( GC $F ) }
                If ( !$Append )       { Write-Theme -Action "Exception [!]" "File exists @: Use -Force or -Append" ; Break }
            }

            Else { $OF = @( ) }
        }

        Process
        {
            Write-Theme -Action "Processing [~]" "Output"

            ForEach ( $i in $O.Keys )
            {
                If ( $( $O[$i].GetType().Name ) -ne $HT ) { $OF += "$i=$( $O[$i] )" } Else { $OF += "[$i]" }

                ForEach ( $j in $( $O[$i].Keys | Sort ) ) 
                {                                                                                          
                    If ( $j -Match "^Comment[\d]+" ) { $OF += "$( $O[$i][$j] )" } Else { $OF += "$j=$( $O[$i][$j] )" }
                }

                SC -Path $F -Value @( $OF ) -Encoding $E
            }

            GI $F

            Write-Theme -Action "Completed [+]" "$( $MyInvocation.MyCommand.Name ) $F"
        }

        End
        {
            If ( $UTF8NoBom ) { [ System.IO.File ]::WriteAllLines( ( $F ) , ( GC $F ) , ( New-Object System.Text.UTF8Encoding $False ) ) }
        }
                                                                                     #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}