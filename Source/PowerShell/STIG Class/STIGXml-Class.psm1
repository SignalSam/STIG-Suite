# Subclass STIGXml
Class STIGXml
{
    [String] $Encoding
    [Float] $Version

    STIGXml ()
    {
        Write-Verbose 'New Class: GuideXml, Constructor: Default'
        $this.Encoding = ''
        $this.Version = 0
    }
}