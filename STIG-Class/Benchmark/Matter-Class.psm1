# Subclass Benchmark.Matter

Class Matter
{
    [String] $XmlLang
    [String] $Value

    Matter ()
    {
        Write-Verbose 'New Class: Matter, Constructor: Default'
        $this.XmlLang = ''
        $this.Value = ''
    }
}