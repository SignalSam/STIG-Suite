# Subclass Rule.FixText

Class FixText
{
    [String] $Fixref
    [String] $Value

    FixText ()
    {
        Write-Verbose 'New Class: FixText, Constructor: Default'
        $this.Fixref = ''
        $this.Value = ''
    }
}