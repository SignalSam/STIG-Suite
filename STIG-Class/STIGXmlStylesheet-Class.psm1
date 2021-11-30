# Subclass STIGXmlStylesheet
Class STIGXmlStylesheet
{
    [String] $Type
    [String] $Href

    STIGXmlStylesheet ()
    {
        Write-Verbose 'New Class: GuideXmlStylesheet, Constructor: Default'
        $this.Type = ''
        $this.Href = ''
    }
}