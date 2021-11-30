<#
 .Synopsis
  Defines object structure for data loaded from a Security Technical Implmentation Guide (STIG).

 .Description
  Provides programmable object for use in console or graphical applications. Structure is for
  the Checklist portion of a STIG.

 .Notes
  Last updated: 26 April 2021
#>

Using Module .\Asset-Class.psm1
Using Module .\Information-Class.psm1

# Root class STIGChecklist
Class Checklist
{
    [Asset] $Asset
    [Information] $Information
    [System.Collections.Generic.List[Vulnerability]] $Vulnerabilities

    Checklist ()
    {
        Write-Verbose 'New Class: Checklist, Constructor: Default'
        $this.Asset = [Asset]::new()
        $this.Information = [Information]::new()
        $this.Vulnerabilities = @()
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
        Write-Verbose 'Invoking STIGBenchmark.StripDepreciatedTags method...'
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