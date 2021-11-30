# Subclass Checklist.Information

Class Information
{
    [Int32] $Version
    [String] $Classification
    [String] $CustomName
    [String] $StigId
    [String] $Description
    [String] $Filename
    [String] $ReleaseInfo
    [String] $Title
    [String] $UUID
    [String] $Notice
    [String] $Source

    Information ()
    {
        Write-Verbose 'New Class: Information, Constructor: Default'
        $this.Version = 0
        $this.Classification = 'UNCLASSIFIED'
        $this.CustomName = ''
        $this.StigId = ''
        $this.Description = ''
        $this.Filename = ''
        $this.ReleaseInfo = ''
        $this.Title = ''
        $this.UUID = ''
        $this.Notice = ''
        $this.Source = ''
    }
}