# Subclass Benchmark.PlainText

Class PlainText
{
    [String] $ReleaseInfo
    [String] $Generator
    [String] $ConventionsVersion

    PlainText ()
    {
        Write-Verbose 'New Class: PlainText, Constructor: Default'
        $this.ReleaseInfo = ''
        $this.Generator = ''
        $this.ConventionsVersion = ''
    }
}