function Format-Xml {
    <#
    .SYNOPSIS
        Format a XML object to be easier to read.
    .PARAMETER InputObject
        Specifies the XML object to be formated.
    .PARAMETER Indent
        Specifies the indentation level for each child element.  Default value is 2.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true)]
        [Xml]$InputObject,

        [Parameter(
            Mandatory = $false,
            Position = 1)]
        [Int]$Indent = 2
    )
    Process {
        $StringWriter = New-Object System.IO.StringWriter
        $XmlWriter = New-Object System.Xml.XmlTextWriter $StringWriter
        $XmlWriter.Formatting = 'Indented'
        $XmlWriter.Indentation = $Indent
        $InputObject.WriteContentTo($XmlWriter)
        $XmlWriter.Flush()
        $StringWriter.Flush()
        return $StringWriter.ToString()
    }
}