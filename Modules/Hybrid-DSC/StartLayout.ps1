    

    Using Namespace System.Management.Automation

    # Redundant Schema Declarative
    $Schema   = "http://schemas.microsoft.com/Start/2014"


    Function Return-ProgramList
    {
        # Default Programs
        $Programs = @( @( "Server Manager" ; @( "" , " ISE" | % { "Windows PowerShell\Windows PowerShell$_" } ) +
        @( "Administrative Tools" , "Task Manager" , "Control Panel" , "File Explorer" | % { "System Tools\$_" } ) +
        "Accessories\Remote Desktop Connection" , "Administrative Tools\Event Viewer" ) | % { "$_.lnk" } )[0..5+7,8,6]

        $DT = "DesktopApplication"

        # Default DesktopApplicationTile Size Prefix
        $Prefix   = ForEach ( $j in 0 , 2 , 4 ) { ForEach ( $i in 0 , 2 , 4 ) { "<start:$( $DT )Tile Size='2x2' Column='$i' Row='$j' $( $DT )LinkPath" } }

        # Default Environment Variable Prefix
        $Suffix   = @( "%ALLUSERSPROFILE%" , "%APPDATA%" | % { "$_\Microsoft\Windows\Start Menu\Programs" } )[0,1,1,1,0,1,0,0,1]

        # Concatenated DAT Output Array
        $Output   = 0..8 | % { "          $( $Prefix[$_] )='$( $Suffix[$_] )\$( $Programs[$_] )' />" }

        Return $Output
    }


    Function Export-FullLayout
    {
        [ CmdLetBinding () ] Param (

            [ Parameter ( Position = 0 , Mandatory = $True , ValueFromPipeline = $True , HelpMessage = "Target Path" ) ] $Path ,
            [ Parameter ( Position = 1 , Mandatory = $True , ValueFromPipeline = $True , HelpMessage = "Target Name" ) ] $Name ,
            [ Switch ] $Default )

        If ( $Default )
        {
            If ( ( Test-Path $Path ) -eq $True )
            {
                If ( ( Test-Path "$Path\$Name" ) -eq $True )
                {
                    Switch( $Host.UI.PromptForChoice( "File Detected" , "Overwrite?" , [ Host.ChoiceDescription [] ]@( "&Yes" , "&No" ) , [ Int ] 0 ) )
                    {
                        0 { $Overwrite = 1 }
                        1 { $Overwrite = 0 ; Echo "User aborted" ; Break }
                    }
                }
            }

            $Output = @( Return-ProgramList )
            
            $Overwrite | % { 
            
                If ( ( $_ -eq $Null ) -or ( $_ -eq 1 ) ) 
                { 
                    SC -Path "$Path\$Name" -Value @(
                    "<LayoutModificationTemplate Version='1' xmlns='$Schema/LayoutModification'>" 
                    "  <LayoutOptions StartTileGroupCellWidth='6' />"
                    "  <DefaultLayoutOverride>"
                    "    <StartLayoutCollection>"
                    "      <defaultlayout:StartLayout GroupCellWidth='6' xmlns:defaultlayout='$Schema/FullDefaultLayout'>"
                    "        <start:Group Name='Windows Server' xmlns:start='$Schema/StartLayout'>"
                    $Output
                    "        </start:Group>"
                    "      </defaultlayout:StartLayout>"
                    "    </StartLayoutCollection>"
                    "  </DefaultLayoutOverride>"
                    "</LayoutModificationTemplate>" ) | % { $_.Replace( "'" , '"' ) }
                }
            }
        }
    }

    Function Create-StartXML
    {
        $Mod = [ PSCustomObject ]@{

            "LayoutModificationTemplate" = [ PSCustomObject ]@{
            
                "xmlns"                  = "$Schema/LayoutModification"
                "xmlns:defaultlayout"    = "$Schema/FullDefaultLayout"
                "xmlns:start"            = "$Schema/StartLayout"
                "xmlns:taskbar"          = "$Schema/TaskbarLayout"
                Version                  = "1" 
                LayoutOptions            = [ PSCustomObject ]@{ StartTileGroupCellWidth = 6 }
                DefaultLayoutOverride    = [ PSCustomObject ]@{ StartLayoutCollection = [ PSCustomObject ]@{
                    
                            "defaultlayout:StartLayout" = [ PSCustomObject ]@{ GroupCellWidth = 6 ; "xmlns:defaultlayout" = "$Schema/FullDefaultLayout"
                            "start:Group" = [ PSCustomObject ]@{ 
                                Name          = "$Author @ Start Menu"
                                "xmlns:start" = "$Schema/StartLayout"
                            }
                        }
                    }
                }
            }
        }
        Return $Mod
    }

    $NP       =   "NoteProperty"
    $PS       = "PSCustomObject"

    $Mod      = @( Create-StartXML )


    Function Recurse-Object
    {
        Param (  ) 
    }

    Create-StartXML 
    
    $OP = @( )

    $Mod      = @( Create-StartXML )
    
    $Name     = $Mod | GM | ? { $_.MemberType -eq $NP } | % { $_.Name }
