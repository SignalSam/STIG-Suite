# Subclass Benchmark.Profile

Using Module .\Select-Class.psm1

Class Profile
{
    [String] $Id
    [String] $Title
    [String] $Description
    [System.Collections.Generic.List[Select]] $Selects

    Profile ()
    {
        Write-Verbose 'New Class: Profile, Constructor: Default'
        $this.Id = ''
        $this.Title = ''
        $this.Description = ''
        $this.Selects = @()
    }
    Profile ([String] $_Id, [String] $_Title, [String] $_Description)
    {
        Write-Verbose 'New Class: Profile, Constructor: Full'
        Write-Verbose 'Parameters:'
        Write-Verbose "`t_Id: [$_Id]"
        Write-Verbose "`t_Title: [$_Title]"
        Write-Verbose "`t_Description: [$_Description]"
        Write-Verbose "`t_Selects: -SEE CLASS-"
        Write-Verbose '****** END CLASS ******'

        $this.Id = $_Id
        $this.Title = $_Title
        $this.Description = $_Description
        $this.Selects = @()
    }
}