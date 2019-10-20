
    # Got a message from Reddit, https://www.reddit.com/r/PowerShell/comments/dki4dx/remove_orphaned_users_permission_from_share/
    # Because, I saw something of interest, I then decided to update this guy's script even though I probably won't use it. 
    
    # Perhaps some people will.

    # Ruud Borst
    # https://gallery.technet.microsoft.com/scriptcenter/Retrieve-All-Users-from-AD-b76e3443

    # Call Namespace
    Using Namespace System.DirectoryServices

    # Import ActiveDirectory module ( probably unnecessary honestly )
    Import-Module ActiveDirectory

    Function Get-ADUsersByProperties
    {
        # Replaced New-Object System.DirectoryServices etc yada... with this...
        $Searcher   = [ DirectorySearcher ]::New()

        $Searcher   | % {

            $_.SearchRoot = [ DirectoryEntry ]::New( “GC://$( ( [ ADSI ] "LDAP://RootDSE" ).rootDomainNamingContext )” )
            $_.PageSize   = 1000
            $_.PropertiesToLoad.Clear()

        }

        "Name" , "UserprincipalName" , "proxyAddresses" , "sAMAccountName" , "displayName" | % { $Searcher.PropertiesToLoad.Add( "$_" ) > $Null }

        $Searcher | % { 

            $_.CacheResults = $False
            $_.Filter       = “(&(objectCategory=User))” 
        }

        Return $Searcher.FindAll() 
    }
