# Subclass Profile.Select

Class Select
{
    [String] $IdRef
    [Boolean] $Selected

    Select ()
    {
        Write-Verbose 'New Class: Select, Constructor: Default'
        $this.IdRef = ''
        $this.Selected = $False
    }
    Select ([String] $_IdRef, [Boolean] $_Selected)
    {
        Write-Verbose 'New Class: Select, Constructor: Full'
        Write-Verbose "Parameters: _IdRef: [$_IdRef], _Selected: [$_Selected]"
        $this.IdRef = $_IdRef
        $this.Selected = $_Selected
    }
}