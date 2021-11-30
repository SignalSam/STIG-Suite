<#
 .Synopsis
  Defines object structure for data loaded from a Security Technical Implmentation Guide (STIG).

 .Description
  Provides programmable object for use in console or graphical applications. Structure is intended
  to receive the xml data of a DISA created document (.xml) or a DISA packaged archive (.zip).

 .Notes
  Last updated: 26 April 2021
#>

Using Module .\STIGXml-Class.psm1
Using Module .\STIGXmlStylesheet-Class.psm1
Using Module .\Benchmark\Benchmark-Class.psm1
Using Module .\Benchmark\Group-Class.psm1
Using Module .\Benchmark\Profile-Class.psm1
Using Module .\Benchmark\Select-Class.psm1
Using Module .\Benchmark\Rule-Class.psm1
Using Module .\Benchmark\Reference-Class.psm1
Using Module .\Common\Ident-Class.psm1
Using Module .\Common\FixText-Class.psm1
Using Module .\Common\Fix-Class.psm1
Using Module .\Benchmark\Check-Class.psm1
Using Module .\Common\CheckContentRef-Class.psm1

# CmdletBinding to be done in calling script.
# When used independantly as a .ps1, enable the CmdletBinding attribute and Parameter block.
# If you don't, verbose output isn't availible.
[CmdletBinding()]
Param
   (  )

# Root class, STIG.
Class STIG
{
    Hidden [System.Xml.XmlDocument] $_SourceXml
    Hidden [Boolean] $_XmlProcessed
    [Benchmark] $Benchmark
    [STIGXml] $Xml
    [STIGXmlStylesheet] $XmlStylesheet

    STIG ()
    {
        Write-Verbose 'New Class: STIG, Constructor: Default'
        
        $this._SourceXml = [System.Xml.XmlDocument]::new()
            $this._SourceXml.PreserveWhitespace = $True
        $this._XmlProcessed = $False
        $this.Benchmark = [Benchmark]::new()
        $this.Xml = [STIGXml]::new()
        $this.XmlStylesheet = [STIGXmlStylesheet]::new()
    }


    <#
     .Description
      Method to query Groups for keyword found in the following Rule properties:
        Description, FixText.Value, Check.CheckContent, Title

     .Inputs
      Keyword as [String].

     .Outputs
      Collection as [System.Collections.Generic.List[BenchmarkGroup]].
    #>
    [System.Collections.Generic.List[Group]] FilterRules ([String] $_Keyword)
    {
        Write-Verbose 'Invoked STIG.FilterRules method.'
        Write-Verbose "Keyword: [$_Keyword]"

        [System.Collections.Generic.List[Group]] $RulesFound = $this.Benchmark.Groups.FindAll({ `
            $args[0].Rule.Description -LIKE "*$_Keyword*" -OR `
            $args[0].Rule.FixText.Value -LIKE "*$_Keyword*" -OR `
            $args[0].Rule.Check.CheckContent -LIKE "*$_Keyword*" -OR `
            $args[0].Rule.Title -LIKE "*$_Keyword*" })

        Write-Verbose "Returning [$($RulesFound.Count)] results."
        Return $RulesFound
    }


    <#
     .Description
      Method to load xml data into _SourceXml as [XmlDocument]. Implements any of the
      [XmlDocument].Load() overloads, can additionally process and/or cache the data
      using provided overloads.

     .Inputs
      Xml data as [System.IO.Strean], [XmlTextReader], [String], or [XmlReader].
      Call to process post-load as [Boolean], optional via overload.
      Call to cache post-load to path as [String], optional via overload.

     .Outputs
      True or false as [Boolean].
    #>
    [Boolean] LoadXml ([Object] $_XmlData)
    {$error.Clear()
        $ErrorActionPreference = 'Stop'
        Try
        {
            Write-Verbose 'Invoked STIG.LoadXml method, overload: Default.'
            If ($_XmlData -IS [System.IO.Stream] -OR `
                $_XmlData -IS [System.Xml.XmlTextReader] -OR `
                $_XmlData -IS [String] -OR `
                $_XmlData -IS [System.Xml.XmlReader])
            {
                Write-Verbose 'Loading xml data...'
                $this._SourceXml = [System.Xml.XmlDocument]::new()

                If (($_XmlData -IS [String]) -AND ($_XmlData.EndsWith('.zip')))
                {
                    $this.UseObject(($DISAZip = [System.IO.Compression.ZipFile]::OpenRead($_XmlData)), `
                    {
                        $STIGEntry = $DISAZip.Entries | Where-Object { $_.Name.EndsWith('.xml') -AND ($_.Name -NOTLIKE 'DOD_EP_*') }
                        $this._SourceXml.Load($STIGEntry.Open())
                        Write-Verbose 'Success.'
                    })
                }
                Else
                {
                    $this._SourceXml.Load($_XmlData)
                    Write-Verbose 'Success.'
                }
                Return $True
            }
            Else
            {Write-Host
                Write-Verbose "Unsupported object type: $($_XmlData.GetType())"
                Return $False
            }
        }
        Catch
        {
            Write-Verbose 'Failed to load xml data.'
            Write-host $error
            Return $False
        }
        $ErrorActionPreference = 'Continue'    
    }

    # Overload to process post-load.
    [Boolean] LoadXml ([Object] $_XmlData, [Boolean] $_CallPostProcess)
    {
        $ErrorActionPreference = 'Stop'
        Try
        {
            Write-Verbose 'Invoked STIG.LoadXml method, overload: CallPostProcess.'
            If ($_XmlData -IS [System.IO.Stream] -OR `
                $_XmlData -IS [System.Xml.XmlTextReader] -OR `
                $_XmlData -IS [String] -OR `
                $_XmlData -IS [System.Xml.XmlReader])
            {
                Write-Verbose 'Loading xml data...'
                $this._SourceXml = [System.Xml.XmlDocument]::new()
                
                If (($_XmlData -IS [String]) -AND ($_XmlData.EndsWith('.zip')))
                {
                    $this.UseObject(($DISAZip = [System.IO.Compression.ZipFile]::OpenRead($_XmlData)), `
                    {
                        $STIGEntry = $DISAZip.Entries | Where-Object { $_.Name.EndsWith('.xml') -AND ($_.Name -NOTLIKE 'DOD_EP_*') }
                        $this._SourceXml.Load($STIGEntry.Open())
                        Write-Verbose 'Success.'
                    })
                }
                Else
                {
                    $this._SourceXml.Load($_XmlData)
                    Write-Verbose 'Success.'
                }

                If ($_CallPostProcess)
                {
                    If ($NULL -EQ $this._SourceXml.Benchmark)
                    {
                        If ($this.ProcessChecklist())
                            { Return $True }
                        Else
                            { Return $False }
                    }
                    ElseIf ($NULL -EQ $this._SourceXml.CHECKLIST)
                    {
                        If ($this.ProcessBenchmark())
                            { Return $True }
                        Else
                            { Return $False }
                    }
                    Else
                    {
                        Write-Verbose 'Unknown xml type.'
                        Return $False
                    }
                }
                Return $True
            }
            Else
            {
                Write-Verbose "Unsupported object type: $($_XmlData.GetType())"
                Return $False
            }
        }
        Catch
        {
            Write-Verbose 'Failed to load xml data.'
            Return $False
        }
    }

    # Overload to process and cache post-load.
    [Boolean] LoadXml ([Object] $_XmlData, [Boolean] $_CallPostProcess, [String] $_CachePath)
    {
        $ErrorActionPreference = 'Stop'
        Try
        {
            Write-Verbose 'Invoked STIG.LoadXml method, overload: CallPostProcessandCache.'
            If ($_XmlData -IS [System.IO.Stream] -OR `
                $_XmlData -IS [System.Xml.XmlTextReader] -OR `
                $_XmlData -IS [String] -OR `
                $_XmlData -IS [System.Xml.XmlReader])
            {
                Write-Verbose 'Loading xml data...'
                $this._SourceXml = [System.Xml.XmlDocument]::new()
                
                If (($_XmlData -IS [String]) -AND ($_XmlData.EndsWith('.zip')))
                {
                    $this.UseObject(($DISAZip = [System.IO.Compression.ZipFile]::OpenRead($_XmlData)), `
                    {
                        $STIGEntry = $DISAZip.Entries | Where-Object { $_.Name.EndsWith('.xml') -AND ($_.Name -NOTLIKE 'DOD_EP_*') }
                        $this._SourceXml.Load($STIGEntry.Open())
                        Write-Verbose 'Success.'
                    })
                }
                Else
                {
                    $this._SourceXml.Load($_XmlData)
                    Write-Verbose 'Success.'
                }

                If ($_CallPostProcess)
                {
                    If ($NULL -EQ $this._SourceXml.Benchmark)
                    {
                        If ($this.ProcessChecklist())
                            { Return $True }
                        Else
                            { Return $False }
                    }
                    ElseIf ($NULL -EQ $this._SourceXml.CHECKLIST)
                    {
                        If ($this.ProcessBenchmark())
                            { Return $True }
                        Else
                            { Return $False }
                    }
                    Else
                    {
                        Write-Verbose 'Unknown xml type.'
                        Return $False
                    }
                }

                If ($this.CacheXml($_CachePath))
                    { Return $True }
                Else
                    { Return $False }                 
            }
            Else
            {
                Write-Verbose "Unsupported object type: $($_XmlData.GetType())"
                Return $False
            }
        }
        Catch
        {
            Write-Verbose 'Failed to load xml data.'
            Return $False
        }
    }

    <#
     .Description
      Method to process benchmark xml data stored in _SourceXml and store into instance of STIG class.

     .Inputs
      None.

     .Outputs
     True or false as [Boolean].
    #>
    [Boolean] ProcessBenchmark ()
    {
        Write-Verbose 'Invoking STIG.ProcessXml method.'
        If ($this._XmlProcessed -NE $False)
            { $this._XmlProcessed = $False }

        If ($NULL -EQ $this._SourceXml)
        {
            Write-Verbose '_SourceXml is not populated, nothing to do.'
            Return $False
        }

        $ErrorActionPreference = 'Stop'
        Try
        {
            [System.Xml.XmlDeclaration] $_XmlDeclaration = $this._SourceXml.ChildNodes | Where-Object { $_.NodeType -EQ 'XmlDeclaration' }
            $this.Xml.Version = [Convert]::ToSingle($_XmlDeclaration.Version)
            $this.Xml.Encoding = $_XmlDeclaration.Encoding

            Write-Verbose 'Xml subclass populated...'

            [System.Collections.Generic.List[String]] $_SubStrings = ($this._SourceXml.ChildNodes | Where-Object { $_.NodeType -EQ 'ProcessingInstruction' }).Value.Split(' ')
            $this.XmlStylesheet.Type = $_SubStrings | Where-Object { $_.StartsWith('type=') }
            $this.XmlStylesheet.Href = $_SubStrings | Where-Object { $_.StartsWith('href=') }

            $this.XmlStylesheet.Type = ($this.XmlStylesheet.Type.Substring($this.XmlStylesheet.Type.IndexOf("'"))).Replace("'", '')
            $this.XmlStylesheet.Href = ($this.XmlStylesheet.Href.Substring($this.XmlStylesheet.Href.IndexOf("'"))).Replace("'", '')
        
            Write-Verbose 'XmlStylesheet subclass populated...'

            [System.Xml.XPath.XPathNavigator] $_XPathNavigator = $this._SourceXml.CreateNavigator()
            While ($_XPathNavigator.MoveToFollowing([System.Xml.XPath.XPathNodeType]::All))
                { $this.Benchmark.XmlNamespaces = $_XPathNavigator.GetNamespacesInScope([System.Xml.XmlNamespaceScope]::All) }

            [System.Xml.XmlNamespaceManager] $_XmlNameSpaceManager = [System.Xml.XmlNamespaceManager]::new($this._SourceXml.NameTable)
            $_XmlNameSpaceManager.AddNamespace('STIG', $this.Benchmark.XmlNamespaces[[String]::Empty])
            $_XmlNameSpaceManager.AddNamespace('dc', $this.Benchmark.XmlNamespaces['dc'])

            [System.Xml.XmlElement] $_XmlBenchmark = $this._SourceXml.DocumentElement

            Write-Verbose '_XmlBenchmark element populated...'

            $this.Benchmark.Id = $_XmlBenchmark.GetAttribute('id')
            $this.Benchmark.XmlLang = $_XmlBenchmark.GetAttribute('xml:lang')
            $this.Benchmark.XsiSchemaLocations = $_XmlBenchmark.GetAttribute('xsi:schemaLocation').Split(' ')
            $this.Benchmark.Status.Date = [DateTime]::Parse($_XmlBenchmark.SelectSingleNode('STIG:status', $_XmlNameSpaceManager).Attributes.GetNamedItem('date').Value)
            $this.Benchmark.Status.Value = $_XmlBenchmark.SelectSingleNode('STIG:status', $_XmlNameSpaceManager).InnerText
            $this.Benchmark.Title = $_XmlBenchmark.SelectSingleNode('STIG:title', $_XmlNameSpaceManager).InnerText
            $this.Benchmark.Description = $_XmlBenchmark.SelectSingleNode('STIG:description', $_XmlNameSpaceManager).InnerText
            $this.Benchmark.Notice.Id = $_XmlBenchmark.SelectSingleNode('STIG:notice', $_XmlNameSpaceManager).Attributes.GetNamedItem('id').Value
            $this.Benchmark.Notice.XmlLang = $_XmlBenchmark.SelectSingleNode('STIG:notice', $_XmlNameSpaceManager).Attributes.GetNamedItem('xml:lang').Value

            # FrontMatter and RearMatter were introduced in Version 2, they do not exist in Version 1.
            If ($NULL -NE $_XmlBenchmark.SelectSingleNode('STIG:front-matter', $_XmlNameSpaceManager))
            {
                $this.Benchmark.FrontMatter.XmlLang = $_XmlBenchmark.SelectSingleNode('STIG:front-matter', $_XmlNameSpaceManager).Attributes.GetNamedItem('xml:lang').Value
                $this.Benchmark.RearMatter.XmlLang = $_XmlBenchmark.SelectSingleNode('STIG:rear-matter', $_XmlNameSpaceManager).Attributes.GetNamedItem('xml:lang').Value
            }

            $this.Benchmark.Reference.Href = $_XmlBenchmark.SelectSingleNode('STIG:reference', $_XmlNameSpaceManager).Attributes.GetNamedItem('href').Value
            $this.Benchmark.Reference.Publisher = $_XmlBenchmark.SelectSingleNode('STIG:reference/dc:publisher', $_XmlNameSpaceManager).InnerText
            $this.Benchmark.Reference.Source = $_XmlBenchmark.SelectSingleNode('STIG:reference/dc:source', $_XmlNameSpaceManager).InnerText

            # Plaintext (plain-text) is used to populate Benchmark.Release and Benchmark.Date, these aren't native elements.
            # Version 1 Plaintext
            If ($_XmlBenchmark.'plain-text' -IS [System.Xml.XmlElement])
                { $this.Benchmark.PlainText.ReleaseInfo = $_XmlBenchmark.SelectSingleNode('STIG:plain-text', $_XmlNameSpaceManager).InnerText }

            # Version 2 Plaintext
            If ($this._SourceXml.Benchmark.'plain-text' -IS [System.Array])
            {
                $this.Benchmark.PlainText.ReleaseInfo = $_XmlBenchmark.SelectSingleNode("STIG:*[@id='release-info']", $_XmlNameSpaceManager).InnerText
                $this.Benchmark.PlainText.Generator = $_XmlBenchmark.SelectSingleNode("STIG:*[@id='generator']", $_XmlNameSpaceManager).InnerText
                $this.Benchmark.PlainText.ConventionsVersion = $_XmlBenchmark.SelectSingleNode("STIG:*[@id='conventionsVersion']", $_XmlNameSpaceManager).InnerText
            }

            $this.Benchmark.Release = [Convert]::ToInt32($this.Benchmark.PlainText.ReleaseInfo. `
                Substring($this.Benchmark.PlainText.ReleaseInfo.IndexOf(' ') + 1, $this.Benchmark.PlainText.ReleaseInfo.IndexOf('Benchmark') - 10))
            $this.Benchmark.Date = [DateTime]::Parse($this.Benchmark.PlainText.ReleaseInfo. `
                Substring($this.Benchmark.PlainText.ReleaseInfo.IndexOf('Date: ') + 6))
            $this.Benchmark.Version = [Convert]::ToInt32($_XmlBenchmark.SelectSingleNode('STIG:version', $_XmlNameSpaceManager).InnerText)

            Write-Verbose 'Benchmark subclass properties set...'

            [System.Xml.XmlNodeList] $_XmlProfiles = $_XmlBenchmark.SelectNodes('STIG:Profile', $_XmlNameSpaceManager)

            Write-Verbose 'Populating profiles...'
            If ($this.Benchmark.Profiles.Count -GT 0)
                { $this.Benchmark.Profiles.Clear() }

            ForEach ($_XmlProfile In $_XmlProfiles)
            {
                # The ProfileDescription element is depreciated but DISA's generator still produces escaped tags.
                # StripDepreciatedTags() will remove them.
                [Profile] $_BenchmarkProfile = [Profile]::new($_XmlProfile.Attributes.GetNamedItem('id').Value, `
                    $_XmlProfile.SelectSingleNode('STIG:title', $_XmlNameSpaceManager).InnerText, 
                    $this.Benchmark.StripDepreciatedTags($_XmlProfile.SelectSingleNode('STIG:description', $_XmlNameSpaceManager).InnerText))
                [System.Xml.XmlNodeList] $_XmlSelects = $_XmlProfile.SelectNodes('STIG:select', $_XmlNameSpaceManager)

                ForEach ($_XmlSelect In $_XmlSelects)
                {
                    [Select] $_ProfileSelect = [Select]::new( `
                        $_XmlSelect.Attributes.GetNamedItem('idref').Value,
                        [Convert]::ToBoolean($_XmlSelect.Attributes.GetNamedItem('selected').Value))
                    $_BenchmarkProfile.Selects.Add($_ProfileSelect)
                }

                $this.Benchmark.Profiles.Add($_BenchmarkProfile)
                Write-Verbose "Added [$($_XmlProfile.Attributes.GetNamedItem('id').Value)]."
            }

            [System.Xml.XmlNodeList] $_XmlGroups = $_XmlBenchmark.SelectNodes('STIG:Group', $_XmlNameSpaceManager)

            Write-Verbose 'Populating groups...'
            If ($this.Benchmark.Groups.Count)
                { $this.Benchmark.Groups.Clear() }

            ForEach ($_XmlGroup In $_XmlGroups)
            {
                [System.Xml.XmlNode] $_XmlRule = $_XmlGroup.SelectSingleNode('STIG:Rule', $_XmlNameSpaceManager)
                [System.Xml.XmlNode] $_XmlReference = $_XmlRule.SelectSingleNode('STIG:reference', $_XmlNameSpaceManager)
                [System.Xml.XmlNode] $_XmlCheck = $_XmlRule.SelectSingleNode('STIG:check', $_XmlNameSpaceManager)

                [Group] $_BenchmarkGroup = [Group]::new()
                    $_BenchmarkGroup.Id = $_XmlGroup.Attributes.GetNamedItem('id').Value
                    $_BenchmarkGroup.Title = $_XmlGroup.SelectSingleNode('STIG:title', $_XmlNameSpaceManager).InnerText

                    # The GroupDescription element is depreciated but DISA's generator still produces escaped tags.
                    # StripDepreciatedTags() will remove them.
                    $_BenchmarkGroup.Description = $this.Benchmark.StripDepreciatedTags($_XmlGroup.SelectSingleNode('STIG:description', $_XmlNameSpaceManager).InnerText)

                    $_BenchmarkGroup.Rule = [Rule]::new()
                        $_BenchmarkGroup.Rule.Id = $_XmlGroup.SelectSingleNode('STIG:Rule', $_XmlNameSpaceManager).Attributes.GetNamedItem('id').Value
                        $_BenchmarkGroup.Rule.Severity = [System.Enum]::Parse([SeverityLevel], $_XmlRule.Attributes.GetNamedItem('severity').Value)
                        $_BenchmarkGroup.Rule.Weight = [Convert]::ToSingle($_XmlRule.Attributes.GetNamedItem('weight').Value)
                        $_BenchmarkGroup.Rule.Version = $_XmlRule.SelectSingleNode('STIG:version', $_XmlNameSpaceManager).InnerText
                        $_BenchmarkGroup.Rule.Title = $_XmlRule.SelectSingleNode('STIG:title', $_XmlNameSpaceManager).InnerText
                    
                    # Multiple elements in the Description node are depreciated but DISA's generator still produces escaped tags.
                    # StripDepreciatedTags() will remove them. Additionally some Description nodes still contain the <Documentable> value
                    # despite the tag being depreciated, will check for and remove.
                    $_BenchmarkGroup.Rule.Description = $this.Benchmark.StripDepreciatedTags($_XmlRule.SelectSingleNode('STIG:description', $_XmlNameSpaceManager).InnerText)

                    If ( $_BenchmarkGroup.Rule.Description.EndsWith('true'))
                        {  $_BenchmarkGroup.Rule.Description =  $_BenchmarkGroup.Rule.Description.Substring(0,  $_BenchmarkGroup.Rule.Description.LastIndexOf('true')) }
                    ElseIf ( $_BenchmarkGroup.Rule.Description.EndsWith('false'))
                        {  $_BenchmarkGroup.Rule.Description =  $_BenchmarkGroup.Rule.Description.Substring(0,  $_BenchmarkGroup.Rule.Description.LastIndexOf('false')) }

                    #$_BenchmarkGroup.Rule.Reference = [Reference]::new()
                        $_BenchmarkGroup.Rule.Reference.Title = $_XmlReference.SelectSingleNode('dc:title', $_XmlNameSpaceManager).InnerText
                        $_BenchmarkGroup.Rule.Reference.Publisher = $_XmlReference.SelectSingleNode('dc:publisher', $_XmlNameSpaceManager).InnerText
                        $_BenchmarkGroup.Rule.Reference.Type = $_XmlReference.SelectSingleNode('dc:type', $_XmlNameSpaceManager).InnerText
                        $_BenchmarkGroup.Rule.Reference.Subject = $_XmlReference.SelectSingleNode('dc:subject', $_XmlNameSpaceManager).InnerText
                        $_BenchmarkGroup.Rule.Reference.Identifier = $_XmlReference.SelectSingleNode('dc:identifier', $_XmlNameSpaceManager).InnerText

                    # Version 1 Ident
                    If ($_XmlGroup.Rule.Ident -IS [System.Xml.XmlElement])
                    {
                        $_RuleIdent = [Ident]::new()
                            $_RuleIdent.System = $_XmlRule.SelectSingleNode('STIG:ident', $_XmlNameSpaceManager).Attributes.GetNamedItem('system').Value
                            $_RuleIdent.Value = $_XmlRule.SelectSingleNode('STIG:ident', $_XmlNameSpaceManager).InnerText
                        $_BenchmarkGroup.Rule.Idents.Add($_RuleIdent)
                    }
                    

                    # Version 2 Ident
                    If ($_XmlGroup.Rule.Ident -IS [System.Array])
                    {
                        ForEach ($_Ident In $_XmlGroup.Rule.Ident)
                        {
                            $_RuleIdent = [Ident]::new()
                                $_RuleIdent.System = $_Ident.system
                                $_RuleIdent.Value = $_Ident.InnerText
                            $_BenchmarkGroup.Rule.Idents.Add($_RuleIdent)
                        }
                    }

                    $_BenchmarkGroup.Rule.Fixtext = [Fixtext]::new()
                        $_BenchmarkGroup.Rule.FixText.Fixref = $_XmlRule.SelectSingleNode('STIG:fixtext', $_XmlNameSpaceManager).Attributes.GetNamedItem('fixref').Value
                        $_BenchmarkGroup.Rule.FixText.Value = $_XmlRule.SelectSingleNode('STIG:fixtext', $_XmlNameSpaceManager).InnerText

                    $_BenchmarkGroup.Rule.Fix = [Fix]::new()
                        $_BenchmarkGroup.Rule.Fix.Id = $_XmlRule.SelectSingleNode('STIG:fix', $_XmlNameSpaceManager).Attributes.GetNamedItem('id').Value

                    $_BenchmarkGroup.Rule.Check = [Check]::new()
                        $_BenchmarkGroup.Rule.Check.System = $_XmlCheck.Attributes.GetNamedItem('system').Value

                        $_BenchmarkGroup.Rule.Check.CheckContentRef = [CheckContentRef]::new()
                            $_BenchmarkGroup.Rule.Check.CheckContentRef.Name = $_XmlCheck.SelectSingleNode('STIG:check-content-ref', $_XmlNameSpaceManager).Attributes.GetNamedItem('name').Value
                            $_BenchmarkGroup.Rule.Check.CheckContentRef.Href = $_XmlCheck.SelectSingleNode('STIG:check-content-ref', $_XmlNameSpaceManager).Attributes.GetNamedItem('href').Value

                        $_BenchmarkGroup.Rule.Check.CheckContent = $_XmlCheck.SelectSingleNode('STIG:check-content', $_XmlNameSpaceManager).InnerText

                $this.Benchmark.Groups.Add($_BenchmarkGroup)
                Write-Verbose "Added [$($_XmlGroup.Attributes.GetNamedItem('id').Value)]."
            }

            $this._XmlProcessed = $True
            Write-Verbose 'STIG.ProcessBenchmark method completed.'
            Return $True
        }
        Catch
        {
            Write-Verbose 'Failed to process benchmark.'
            Return $False
        }
    }    


    <#
     .Description
      Method to process checklist xml data stored in _SourceXml and store into instance of STIG class.

     .Inputs
      None.

     .Outputs
     True or false as [Boolean].
    #>
    [Boolean] ProcessChecklist ()
    {
        Return $True
    }

    <#
     .Description
      Method to save the raw xml data loaded using STIG.LoadXml() to another file. Useful if using
      user profiles to store data. Requires the xml data be processed via [STIG].ProcessXml().

     .Inputs
      Fully qualified path to a directory with no tailing slash as [String].

     .Outputs
      True or false as [Boolean].
    #>
    [Boolean] CacheXml ([String] $_DestinationDirectory)
    {
        $ErrorActionPreference = 'Stop'
        Try
        {
            Write-Verbose 'Invoking STIG.CacheSourceXml method.'
            Write-Verbose "Destination: [$_DestinationDirectory]"

            If ($NULL -EQ $this._SourceXml)
            {
                Write-Verbose '_SourceXml is not populated, nothing to do.'
                Return $False
            }

            If ($this._XmlProcessed -EQ $False)
            {
                Write-Verbose 'Xml is not processed, invoke [STIG].ProcessXml() then call this method.'
                Return $False
            }

            If (Test-Path $_DestinationDirectory)
            {
                [String] $_FileName = "$($this.Benchmark.Id.Replace('_', ' ')) V$($this.Benchmark.Version)R$($this.Benchmark.Release).xml"
                
                If (Test-Path "$_DestinationDirectory\$_FileName")
                    { Remove-Item -Path "$_DestinationDirectory\$_FileName" -Force }
                [System.IO.File]::WriteAllLines("$_DestinationDirectory\$_FileName", $this._SourceXml.InnerXml)
                Write-Verbose "Created: [$_FileName]"
                Return $True
            }
            Else
            {
                Write-Verbose 'Failed, _DestinationDirectory is not a valid path.'
                Return $False
            }
        }
        Catch
        {
            Write-Verbose 'Failed to create file.'
            Return $False
        }
        $ErrorActionPreference = 'Continue'
    }

    <#
     .Description
      Method that emulates C#'s Using Statement. Does nothing if _InputObject does not inherit
      the IDisposable interface.

     .Inputs
      IDisposable object as [Object].
      Script block as [ScriptBlock].

     .Example
      [SITG]::UseObject(MyIDisposableObject, { Code...; Code...; Code... })

     .Example
      $this.UseObject(MyIDisposableObject, `
        {
            Code...
            Code...
        }
      )
    #>
    [Void] UseObject ([Object] $_InputObject, [ScriptBlock] $_ScriptBlock)
    {
        If ($_InputObject -IS [System.IDisposable])
        {
            Try
            {
                Write-Verbose 'Invoking STIG.UseObject method.'
                Write-Verbose "Object: $_InputObject"
                .$_ScriptBlock
            }
            Finally
            {
                If ($NULL -NE $_InputObject)
                    { $_InputObject.Dispose() }
                Write-Verbose 'Exiting UseObject method.'
            }
        }
    }

    <#
     .Description
      Method to remove tags no longer used in STIGs. The generator DISA uses to create
      a STIG leaves the tag but escapes the tag delimiters: <OldTag> becomes &lt;OldTag&gt;
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

Function New-STIG
    { Return [STIG]::new() }