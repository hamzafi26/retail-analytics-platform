# sync-backlog-github.ps1
# Retail Analytics Platform - GitHub backlog sync
#
# Syncs:
#   - Issue title
#   - Description
#   - Assignee
#   - Project membership
#   - Status
#   - Type of ticket
#   - Phase
#   - Priority
#   - Effort
#
# Sprint is NOT managed by this script.
#
# Safe to rerun:
#   - Existing issues are reused
#   - Existing project items are reused
#   - Nothing is deleted
#
# Uses GitHub REST API only through `gh api`.
# Does NOT use `gh project` commands.
# Does NOT use GraphQL.

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# CONFIG
# ------------------------------------------------------------

$GitHubUser  = "Hamzafilali26"
$Repository  = "Hamzafilali26/retail-analytics-platform"
$ProjectName = "Retail Analytics Platform"
$BacklogPath = ".\backlog.json"

$ApiVersion   = "2026-03-10"
$DelaySeconds = 1
$RetryDelays  = @(10, 20, 40, 60)

# ------------------------------------------------------------
# HELPERS
# ------------------------------------------------------------

function Invoke-GitHubApi {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Endpoint,

        [ValidateSet("GET", "POST", "PATCH", "DELETE")]
        [string]$Method = "GET",

        $Body = $null
    )

    $attempt = 0

    while ($true) {
        $tempFile = $null

        try {
            $ghArgs = @(
                "api",
                "--method", $Method,
                "-H", "Accept: application/vnd.github+json",
                "-H", "X-GitHub-Api-Version: $ApiVersion"
            )

            if ($null -ne $Body) {
                $json = $Body | ConvertTo-Json -Depth 30 -Compress
                $tempFile = Join-Path $env:TEMP ("gh-api-" + [guid]::NewGuid().ToString() + ".json")

                # UTF-8 without BOM prevents PowerShell JSON encoding problems.
                $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
                [System.IO.File]::WriteAllText($tempFile, $json, $utf8NoBom)

                $ghArgs += @("--input", $tempFile)
            }

            $ghArgs += $Endpoint

            $raw = & gh @ghArgs 2>&1
            $exitCode = $LASTEXITCODE
            $text = ($raw | Out-String).Trim()

            if ($exitCode -eq 0) {
                if ([string]::IsNullOrWhiteSpace($text)) {
                    return [PSCustomObject]@{
                        Data = $null
                    }
                }

                # IMPORTANT:
                # Wrap parsed JSON in one object so PowerShell 5.1 does not
                # accidentally unwrap/enumerate JSON arrays returned by GitHub.
                return [PSCustomObject]@{
                    Data = ($text | ConvertFrom-Json)
                }
            }

            $temporary = (
                $text -match "(?i)secondary rate limit" -or
                $text -match "(?i)rate limit" -or
                $text -match "(?i)abuse detection" -or
                $text -match "(?i)temporarily unavailable" -or
                $text -match "(?i)HTTP 429"
            )

            if ($temporary -and $attempt -lt $RetryDelays.Count) {
                $wait = $RetryDelays[$attempt]
                Write-Warning "GitHub temporarily throttled the REST request. Retrying in $wait seconds..."
                Start-Sleep -Seconds $wait
                $attempt++
                continue
            }

            throw "GitHub REST request failed:`n$Method $Endpoint`n`n$text"
        }
        finally {
            if ($tempFile -and (Test-Path $tempFile)) {
                Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

function Get-DisplayValue {
    param($Value)

    if ($null -eq $Value) {
        return ""
    }

    if ($Value -is [string]) {
        return [string]$Value
    }

    if ($Value.PSObject.Properties.Name -contains "raw") {
        return [string]$Value.raw
    }

    if ($Value.PSObject.Properties.Name -contains "html") {
        return [string]$Value.html
    }

    return [string]$Value
}

function Find-Field {
    param(
        [array]$Fields,
        [string]$Name
    )

    return $Fields |
        Where-Object {
            ([string]$_.name).Equals(
                $Name,
                [System.StringComparison]::OrdinalIgnoreCase
            )
        } |
        Select-Object -First 1
}

function Get-OptionId {
    param(
        $Field,
        [string]$WantedValue
    )

    foreach ($option in @($Field.options)) {
        $name = Get-DisplayValue $option.name

        if ($name.Equals(
            $WantedValue,
            [System.StringComparison]::OrdinalIgnoreCase
        )) {
            return [string]$option.id
        }
    }

    return $null
}

function Build-IssueBody {
    param($Ticket)

    $body = ([string]$Ticket.body).Trim()

    if ($Ticket.depends_on -and @($Ticket.depends_on).Count -gt 0) {
        $body += "`n`nDepends on:`n"

        foreach ($dependency in @($Ticket.depends_on)) {
            $body += "- $dependency`n"
        }

        $body = $body.TrimEnd()
    }

    return $body
}

# ------------------------------------------------------------
# PRE-CHECKS
# ------------------------------------------------------------

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI (gh) is not available."
}

if (-not (Test-Path $BacklogPath)) {
    throw "backlog.json was not found in the current folder."
}

& gh auth status *> $null

if ($LASTEXITCODE -ne 0) {
    throw "GitHub CLI is not authenticated."
}

$Backlog = Get-Content $BacklogPath -Raw | ConvertFrom-Json

if (-not $Backlog.tickets) {
    throw "backlog.json contains no tickets."
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Retail Analytics Platform backlog sync" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Repository : $Repository"
Write-Host "Project    : $ProjectName"
Write-Host "Tickets    : $(@($Backlog.tickets).Count)"
Write-Host "Sprint     : NOT managed by this script"
Write-Host ""

# ------------------------------------------------------------
# FIND PROJECT
# ------------------------------------------------------------

$projectsResponse = Invoke-GitHubApi `
    -Endpoint "users/$GitHubUser/projectsV2?per_page=100"

$Projects = @($projectsResponse.Data)

$Project = $Projects |
    Where-Object {
        ([string]$_.title).Equals(
            $ProjectName,
            [System.StringComparison]::OrdinalIgnoreCase
        )
    } |
    Select-Object -First 1

if (-not $Project) {
    $names = ($Projects | ForEach-Object { $_.title }) -join ", "
    throw "Project '$ProjectName' not found. Available projects: $names"
}

$ProjectNumber = [int]$Project.number

Write-Host "Project #  : $ProjectNumber" -ForegroundColor Green

# ------------------------------------------------------------
# LOAD PROJECT FIELDS
# ------------------------------------------------------------

$fieldsResponse = Invoke-GitHubApi `
    -Endpoint "users/$GitHubUser/projectsV2/$ProjectNumber/fields?per_page=100"

$Fields = @($fieldsResponse.Data)

# Diagnostic output so failures are obvious instead of cryptic.
Write-Host ""
Write-Host "Detected Project fields:" -ForegroundColor DarkCyan

foreach ($field in $Fields) {
    Write-Host "  - $($field.name) [$($field.data_type)]"
}

Write-Host ""

$StatusField   = Find-Field $Fields "Status"
$TypeField     = Find-Field $Fields "Type of ticket"
$PhaseField    = Find-Field $Fields "Phase"
$PriorityField = Find-Field $Fields "Priority"
$EffortField   = Find-Field $Fields "Effort"

$RequiredFields = @{
    "Status"         = $StatusField
    "Type of ticket" = $TypeField
    "Phase"          = $PhaseField
    "Priority"       = $PriorityField
    "Effort"         = $EffortField
}

foreach ($fieldName in $RequiredFields.Keys) {
    if (-not $RequiredFields[$fieldName]) {
        $available = ($Fields | ForEach-Object { $_.name }) -join ", "
        throw "Required Project field '$fieldName' was not found. Available fields: $available"
    }
}

Write-Host "Required Project fields found." -ForegroundColor Green

# ------------------------------------------------------------
# VALIDATE BACKLOG VALUES
# ------------------------------------------------------------

foreach ($ticket in @($Backlog.tickets)) {

    $checks = @(
        @{ Field = $StatusField;   Name = "Status";         Value = [string]$ticket.status },
        @{ Field = $TypeField;     Name = "Type of ticket"; Value = [string]$ticket.type },
        @{ Field = $PhaseField;    Name = "Phase";          Value = [string]$ticket.phase },
        @{ Field = $PriorityField; Name = "Priority";       Value = [string]$ticket.priority },
        @{ Field = $EffortField;   Name = "Effort";         Value = [string]$ticket.effort }
    )

    foreach ($check in $checks) {
        if (-not (Get-OptionId $check.Field $check.Value)) {
            $available = @($check.Field.options) |
                ForEach-Object { Get-DisplayValue $_.name }

            throw "$($ticket.id): '$($check.Value)' is not a valid $($check.Name) option. Available: $($available -join ', ')"
        }
    }
}

Write-Host "Backlog values validated." -ForegroundColor Green

# ------------------------------------------------------------
# LOAD EXISTING ISSUES
# ------------------------------------------------------------

$issuesResponse = Invoke-GitHubApi `
    -Endpoint "repos/$Repository/issues?state=all&per_page=100"

$Issues = @($issuesResponse.Data)
$IssueByTitle = @{}

foreach ($issue in $Issues) {
    # GitHub /issues also returns pull requests.
    if ($issue.pull_request) {
        continue
    }

    $IssueByTitle[[string]$issue.title] = $issue
}

# ------------------------------------------------------------
# LOAD EXISTING PROJECT ITEMS
# ------------------------------------------------------------

$itemsResponse = Invoke-GitHubApi `
    -Endpoint "users/$GitHubUser/projectsV2/$ProjectNumber/items?per_page=100"

$ProjectItems = @($itemsResponse.Data)
$ProjectItemByIssueId = @{}

foreach ($item in $ProjectItems) {
    if ($item.content -and $item.content.id) {
        $ProjectItemByIssueId[[string]$item.content.id] = $item
    }
}

# ------------------------------------------------------------
# SYNC TICKETS
# ------------------------------------------------------------

$CreatedIssues  = 0
$ReusedIssues   = 0
$AddedToProject = 0
$UpdatedItems   = 0

foreach ($ticket in @($Backlog.tickets)) {

    $FullTitle = "$($ticket.id) - $($ticket.title)"
    $IssueBody = Build-IssueBody $ticket

    $IssueState = if ([string]$ticket.status -eq "Done") {
        "closed"
    }
    else {
        "open"
    }

    Write-Host ""
    Write-Host "------------------------------------------"
    Write-Host $FullTitle -ForegroundColor Cyan

    # --------------------------------------------------------
    # ISSUE: CREATE OR REUSE
    # --------------------------------------------------------

    if ($IssueByTitle.ContainsKey($FullTitle)) {
        $Issue = $IssueByTitle[$FullTitle]
        $ReusedIssues++

        Write-Host "Issue exists (#$($Issue.number)) - reusing." -ForegroundColor DarkGray

        $issueResponse = Invoke-GitHubApi `
            -Endpoint "repos/$Repository/issues/$($Issue.number)" `
            -Method PATCH `
            -Body @{
                title     = $FullTitle
                body      = $IssueBody
                assignees = @($GitHubUser)
                state     = $IssueState
            }

        $Issue = $issueResponse.Data
    }
    else {
        $issueResponse = Invoke-GitHubApi `
            -Endpoint "repos/$Repository/issues" `
            -Method POST `
            -Body @{
                title     = $FullTitle
                body      = $IssueBody
                assignees = @($GitHubUser)
            }

        $Issue = $issueResponse.Data

        $CreatedIssues++
        $IssueByTitle[$FullTitle] = $Issue

        Write-Host "Created issue #$($Issue.number)." -ForegroundColor Green
    }

    # --------------------------------------------------------
    # PROJECT: ADD OR REUSE
    # --------------------------------------------------------

    $IssueIdKey = [string]$Issue.id

    if ($ProjectItemByIssueId.ContainsKey($IssueIdKey)) {
        $ProjectItem = $ProjectItemByIssueId[$IssueIdKey]

        Write-Host "Already in Project - reusing item." -ForegroundColor DarkGray
    }
    else {
        $addResponse = Invoke-GitHubApi `
            -Endpoint "users/$GitHubUser/projectsV2/$ProjectNumber/items" `
            -Method POST `
            -Body @{
                type = "Issue"
                id   = [long]$Issue.id
            }

        $AddData = $addResponse.Data

        if ($AddData.value) {
            $ProjectItem = $AddData.value
        }
        elseif ($AddData.item) {
            $ProjectItem = $AddData.item
        }
        else {
            $ProjectItem = $AddData
        }

        if (-not $ProjectItem.id) {
            throw "$($ticket.id): Project item was added but GitHub returned no item ID."
        }

        $ProjectItemByIssueId[$IssueIdKey] = $ProjectItem
        $AddedToProject++

        Write-Host "Added to Project." -ForegroundColor Green
    }

    # --------------------------------------------------------
    # PROJECT FIELDS
    # --------------------------------------------------------

    $FieldUpdates = @(
        @{
            id    = [int]$StatusField.id
            value = Get-OptionId $StatusField ([string]$ticket.status)
        },
        @{
            id    = [int]$TypeField.id
            value = Get-OptionId $TypeField ([string]$ticket.type)
        },
        @{
            id    = [int]$PhaseField.id
            value = Get-OptionId $PhaseField ([string]$ticket.phase)
        },
        @{
            id    = [int]$PriorityField.id
            value = Get-OptionId $PriorityField ([string]$ticket.priority)
        },
        @{
            id    = [int]$EffortField.id
            value = Get-OptionId $EffortField ([string]$ticket.effort)
        }
    )

    Invoke-GitHubApi `
        -Endpoint "users/$GitHubUser/projectsV2/$ProjectNumber/items/$($ProjectItem.id)" `
        -Method PATCH `
        -Body @{
            fields = @($FieldUpdates)
        } | Out-Null

    $UpdatedItems++

    Write-Host "Status         : $($ticket.status)"
    Write-Host "Type of ticket : $($ticket.type)"
    Write-Host "Phase          : $($ticket.phase)"
    Write-Host "Priority       : $($ticket.priority)"
    Write-Host "Effort         : $($ticket.effort)"
    Write-Host "Sprint         : unchanged (manual)"
    Write-Host "Synced." -ForegroundColor Green

    Start-Sleep -Seconds $DelaySeconds
}

# ------------------------------------------------------------
# SUMMARY
# ------------------------------------------------------------

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Sync completed" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Created issues    : $CreatedIssues"
Write-Host "Reused issues     : $ReusedIssues"
Write-Host "Added to Project  : $AddedToProject"
Write-Host "Project items set : $UpdatedItems"
Write-Host ""
Write-Host "Sprint was not changed."
Write-Host "Nothing was deleted."
