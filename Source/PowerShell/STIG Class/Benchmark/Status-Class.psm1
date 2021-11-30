# Subclass Benchmark.Status

Class Status
{
    [String] $Value
    [DateTime] $Date

    Status ()
    {
        Write-Verbose 'New Class: Status, Constructor: Default'
        $this.Value = ''
        $this.Date = [DateTime]::Now
    }
}