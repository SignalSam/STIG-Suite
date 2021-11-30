# Subclass Checklist.Asset

Class Asset
{
    [Role] $Role
    [Boolean] $ComputingType
    [String] $Name
    [String] $IPAddress
    [String] $MACAddress
    [String] $FDQN
    [String] $Comments
    # Need to email DISA as to what TechnologyArea actually is.
    [String] $TechnologyArea
    [Int32] $TargetKey
    [Boolean] $WebOrDatabase
    [String] $WebDatabaseSite
    [String] $WebDatabaseInstance

    Asset ()
    {
        Write-Verbose 'New Class: Asset, Constructor: Default'
        $this.Role = 0
        $this.ComputingType = $True
        $this.Name = ''
        $this.IPAddress = ''
        $this.MACAddress = ''
        $this.FDQN = ''
        $this.Comments = ''
        $this.TechnologyArea = ''
        $this.TargetKey = 0
        $this.WebDatabaseInstance = $false
        $this.WebDatabaseSite = ''
        $this.WebDatabaseInstance = ''
    }
}

# Enum for Asset.Role
Enum Role
{
    DomainController = 3
    MemberServer = 2
    Workstation = 1
    None = 0
}