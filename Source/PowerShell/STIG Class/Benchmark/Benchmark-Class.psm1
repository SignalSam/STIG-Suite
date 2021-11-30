<#
 .Synopsis
  Defines object structure for data loaded from a Security Technical Implmentation Guide (STIG).

 .Description
  Provides programmable object for use in console or graphical applications. Structure is for
  the Benchmark portion of a STIG.

 .Notes
  Last updated: 26 April 2021
#>

Using Module .\Notice-Class.psm1
Using Module .\Matter-Class.psm1
Using Module .\Reference-Class.psm1
Using Module .\PlainText-Class.psm1
Using Module .\Status-Class.psm1
Using Module .\Profile-Class.psm1
Using Module .\Group-Class.psm1

# Root class STIG.Benchmark
Class Benchmark
{
    [String] $Description
    [String] $Id
    [Notice] $Notice
    [Matter] $FrontMatter
    [Matter] $RearMatter
    [Reference] $Reference
    [PlainText] $PlainText
    [Status] $Status
    [String] $Title
    [Int32] $Version
    [Int32] $Release
    [DateTime] $Date
    [String] $XmlLang
    [System.Collections.Generic.Dictionary[String, String]] $XmlNamespaces
    [System.Collections.Generic.List[String]] $XsiSchemaLocations
    [System.Collections.Generic.List[Profile]] $Profiles
    [System.Collections.Generic.List[Group]] $Groups

    Benchmark ()
    {
        Write-Verbose 'New Class: Benchmark, Constructor: Default'
        $this.Description = ''
        $this.Id = ''
        $this.Notice = [Notice]::new()
        $this.FrontMatter = [Matter]::new()
        $this.RearMatter = [Matter]::new()
        $this.Reference = [Reference]::new()
        $this.PlainText = [PlainText]::new()
        $this.Status = [Status]::new()
        $this.Title = ''
        $this.Version = 0
        $this.Release = 0
        $this.Date = [DateTime]::Now
        $this.XmlLang = ''
        $this.XmlNamespaces = New-Object 'System.Collections.Generic.Dictionary[String, String]'
        $this.XsiSchemaLocations = @()
        $this.Profiles = @()
        $this.Groups = @()
    }


    <#
     .Description
      Method to remove tags no longer used in STIGs. The generator DISA uses to create
      a STIG leaves the tag but esapces the tag delimiters: <OldTag> becomes &lt;OldTag&gt;
      This will mess up data so the escaped tags are removed via regular expression.

     .Inputs
      String with esacaped tags as [String].

     .Outputs
      String as [String].
    #>
    [String] StripDepreciatedTags ([String] $_Content)
    {
        Write-Verbose 'Invoking Benchmark.StripDepreciatedTags method...'
        [System.Collections.Generic.List[String]] $_TagsToStrip = @()
            $_TagsToStrip.Add('<[/]{0,1}ProfileDescription[^>]*>')
            $_TagsToStrip.Add('<[/]{0,1}GroupDescription[^>]*>')
            $_TagsToStrip.Add('<[/]{0,1}VulnDiscussion[^>]*>')
            $_TagsToStrip.Add('<[/]{0,1}FalsePositives[^>]*>')
            $_TagsToStrip.Add('<[/]{0,1}FalseNegatives[^>]*>')
            $_TagsToStrip.Add('<[/]{0,1}Documentable[^>]*>')
            $_TagsToStrip.Add('<[/]{0,1}Mitigations[^>]*>')
            $_TagsToStrip.Add('<[/]{0,1}SeverityOverrideGuidance[^>]*>')
            $_TagsToStrip.Add('<[/]{0,1}PotentialImpacts[^>]*>')
            $_TagsToStrip.Add('<[/]{0,1}ThirdPartyTools[^>]*>')
            $_TagsToStrip.Add('<[/]{0,1}MitigationControl[^>]*>')
            $_TagsToStrip.Add('<[/]{0,1}Responsibility[^>]*>')
            $_TagsToStrip.Add('<[/]{0,1}IAControls[^>]*>')

        ForEach ($Tag In $_TagsToStrip)
            { $_Content = [RegEx]::Replace($_Content, $Tag, [String]::Empty) }

        Write-Verbose 'Complete.'
        Return $_Content
    }
}