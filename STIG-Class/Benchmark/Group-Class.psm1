# Subclass Benchmark.Group

Using Module .\Rule-Class.psm1

Class Group
{
    [String] $Id
    [String] $Title
    [String] $Description
    [Rule] $Rule

    Group ()
    {
        Write-Verbose 'New Class: Group, Constructor: Default'
        $this.Id = ''
        $this.Title = ''
        $this.Description = ''
        $this.Rule = [Rule]::new()
    }
}