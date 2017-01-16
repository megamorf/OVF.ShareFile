[CmdletBinding()]
param(
    [ValidateSet('http','https')]
    $Protocol = 'http'
)

Function ConvertFrom-HtmlTable
{
    param(
        [Parameter(Mandatory = $true)]
        $WebRequest,

        [Parameter(Mandatory = $true)]
        [int] $TableNumber
    )

    if($WebRequest -is [Microsoft.PowerShell.Commands.HtmlWebResponseObject])
    {
        $tables = @($WebRequest.ParsedHtml.getElementsByTagName("TABLE"))
    }
    else
    {
        $tables = @($WebRequest.getElementsByTagName("TABLE"))
    }

    ## Extract the tables out of the web request

    $table = $tables[$TableNumber]
    $titles = @()
    $rows = @($table.Rows)

    ## Go through all of the rows in the table
    foreach($row in $rows)
    {
        $cells = @($row.Cells)

        ## If we’ve found a table header, remember its titles
        if($cells[0].tagName -eq "TH")
        {
            $titles = @($cells | Foreach-Object { ("" + $_.InnerText).Trim() })
            continue
        }

        ## If we haven’t found any table headers, make up names "P1", "P2", etc.
        if(-not $titles)
        {
            $titles = @(1..($cells.Count + 2) | Foreach-Object { "P$_" })
        }

        ## Now go through the cells in the the row. For each, try to find the
        ## title that represents that column and create a hashtable mapping those
        ## titles to content

        $resultObject = [Ordered] @{}

        for($counter = 0; $counter -lt $cells.Count; $counter++)
        {
            $title = $titles[$counter]

            if(-not $title) { continue }

            $resultObject[$title] = ("" + $cells[$counter].InnerText).Trim()
        }

        ## And finally cast that hashtable to a PSCustomObject
        [PSCustomObject] $resultObject
    }
}


Describe 'ShareFile Health Check' {
    BeforeAll {

        <# Doesn't work in scheduled task :(
        $WebRequest = Invoke-WebRequest -Uri 'http://localhost/configservice/PreFlightCheck.aspx'
        if($WebRequest.StatusCode -ne 200)
        {
            throw "Error retrieving ShareFile Monitoring status"
        }
        #>
        try {
            # Accept self-signed certs
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

            # Query website
            $Url = '{0}://localhost/configservice/PreFlightCheck.aspx' -f $Protocol
            Write-Verbose -Message "Querying url $Url"
            $websiteContent = (New-Object System.Net.WebClient).DownloadString($Url)

            # Parse html code
            $html = New-Object -ComObject "HTMLFile"
            $src = [System.Text.Encoding]::Unicode.GetBytes($websiteContent)
            $html.write($src)

            # Extract table and convert to object collection
            $Table = ConvertFrom-HtmlTable -WebRequest $html -TableNumber 0
        }
        catch {
        }

        $testCases = @(
            @{
                Setting  = 'Registry Permissions Access'
                Expected = 'Permissions OK'
            }
            @{
                Setting  = 'Storage Location Access'
                Expected = 'Permissions OK'
            }
            @{
                Setting  = 'IIS User Account Configuration'
                Expected = 'OK'
            }
            @{
                Setting  = 'File Cleanup Service Status'
                Expected = 'Running'
            }
            @{
                Setting  = 'File Copy Service Status'
                Expected = 'Running'
            }
            @{
                Setting  = 'File Upload Service Status'
                Expected = 'Running'
            }
            @{
                Setting  = 'ShareFile Connectivity from Management Service'
                Expected = 'OK*'
            }
            @{
                Setting  = 'ShareFile Connectivity from StorageZones Controller Website'
                Expected = 'OK*'
            }
            @{
                Setting  = 'ShareFile Connectivity from File Cleanup Service'
                Expected = 'OK*'
            }
            @{
                Setting  = 'ShareFile Connectivity from File Copy Service'
                Expected = 'OK*'
            }
            @{
                Setting  = 'Queue SDK Connectivity'
                Expected = 'OK*'
            }
            @{
                Setting  = 'Proxy Configuration'
                Expected = 'Proxy Not Configured'
            }
            @{
                Setting  = 'Citrix Cloud Storage Uploader Service'
                Expected = 'Cloud based object Storage Not Configured*'
            }
        )
    }

    It 'ShareFile SZC Website is up and running' {
        #$WebRequest.StatusCode | Should Be 200
        $websiteContent | Should Not BeNullOrEmpty
    }

    Context 'ShareFile SZC monitoring page' {

        It '<Setting> is OK' -TestCases $testCases {
            param ($Setting, $Expected)

            $Actual = $Table | Where-Object {$_."Config Name" -eq $Setting} | Select-Object -ExpandProperty Details
            $Actual | Should BeLike $Expected
        }
    }
}
