# Subclass Rule.Reference

Class Reference
{
    [String] $Title
    [String] $Publisher
    [String] $Type
    [String] $Subject
    [String] $Identifier

    Reference ()
    {
        Write-Verbose 'New Class: Reference, Constructor: Default'
        $this.Title = ''
        $this.Publisher = ''
        $this.Type = ''
        $this.Subject = ''
        $this.Identifier = ''
    }
}