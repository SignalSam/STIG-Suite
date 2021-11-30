# Subclass Benchmark.Notice

Class Notice
{
    [String] $Id
    [String] $XmlLang

    Notice ()
    {
        Write-Verbose 'New Class: Notice, Constructor: Default'
        $this.Id = ''
        $this.XmlLang = ''
    }
}