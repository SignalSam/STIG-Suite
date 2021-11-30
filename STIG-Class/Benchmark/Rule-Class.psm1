# Subclass Group.Rule

Using Module ..\Common\Reference-Class.psm1
Using Module ..\Common\Ident-Class.psm1
Using Module ..\Common\FixText-Class.psm1
Using Module ..\Common\Fix-Class.psm1
Using Module .\Check-Class.psm1

Class Rule
{
    [String] $Id
    [SeverityLevel] $Severity
    [Float] $Weight
    [String] $Version
    [String] $Title
    [String] $Description
    [Reference] $Reference
    [System.Collections.Generic.List[Ident]] $Idents
    [FixText] $FixText
    [Fix] $Fix
    [Check] $Check

    Rule ()
    {
        Write-Verbose 'New Class: Rule, Constructor: Default'
        $this.Id = ''
        $this.Severity = [SeverityLevel]::low
        $this.Weight = 0
        $this.Version = ''
        $this.Title = ''
        $this.Description = ''
        $this.Reference = [Reference]::new()
        $this.Idents = @()
        $this.FixText = [FixText]::new()
        $this.Fix = [Fix]::new()
        $this.Check = [Check]::new()
    }
}

# Enum for Rule.SeverityLevel
Enum SeverityLevel
{
    low = 3
    medium = 2
    high = 1
}