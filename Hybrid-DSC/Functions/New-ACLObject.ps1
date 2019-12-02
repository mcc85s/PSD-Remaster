    Function New-ACLObject # Generates an ACL and edits its permissions ________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdletBinding () ] Param ( [ String ] $SAM , 

            [ FileSystemRights  ] $Rights              , 
            [ AccessControlType ] $Access    = 'Allow' , 
            [ InheritanceFlags  ] $Inherit   =  'None' , 
            [ PropagationFlags  ] $Propagate =  'None' )

            IEX "Using Namespace System.Security.AccessControl"

            Return [ FileSystemAccessRule ]::New( $SAM , $Rights , $Inherit , $Propagate , $Access ) 
                                                                                    #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}