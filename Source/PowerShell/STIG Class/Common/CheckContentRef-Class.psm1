# Subclass Check.CheckContentRef

Class CheckContentRef
{
    [String] $Name
    [String] $Href

    CheckContentRef ()
    {
        Write-Verbose 'New Class: CheckContentRef, Constructor: Default'
        $this.Name = ''
        $this.Href = ''
    }
}