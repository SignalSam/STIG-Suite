# Subclass Benchmark.Reference

Class Reference
{
    [String] $Href
    [String] $Publisher
    [String] $Source

    Reference ()
    {
        Write-Verbose 'New Class: Reference, Constructor: Default'
        $this.Href = ''
        $this.Publisher = ''
        $this.Source = ''
    }
}