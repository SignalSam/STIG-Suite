# Subclass Rule.Check

Using Module ..\Common\CheckContentRef-Class.psm1

Class Check
{
    [String] $System
    [CheckContentRef] $CheckContentRef
    [String] $CheckContent

    Check ()
    {
        Write-Verbose 'New Class: Check, Constructor: Default'
        $this.System = ''
        $this.CheckContentRef = [CheckContentRef]::new()
        $this.CheckContent = ''
    }
}