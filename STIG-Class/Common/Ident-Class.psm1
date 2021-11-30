# Subclass Rule.Ident

Class Ident
{
    [String] $System
    [String] $Value

    Ident()
    {
        Write-Verbose 'New Class: Ident, Constructor: Default'
        $this.System = ''
        $this.Value = ''
    }
}