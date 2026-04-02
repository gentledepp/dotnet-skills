# ============================================================================
# ensure-ilspy-mcp.ps1
# Ensures the ILSpyMcp.Server dotnet global tool is installed.
# Returns exit code 0 if installed/available, 1 on failure.
# ============================================================================

$ErrorActionPreference = "Stop"

$ToolName       = "ILSpyMcp.Server"
$ToolCommand    = "ilspy-mcp"
$MinDotnetMajor = 9

# --- Preflight: .NET SDK ---------------------------------------------------

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
   Write-Error "ERROR: dotnet SDK not found. Install .NET ${MinDotnetMajor}+ from https://dotnet.microsoft.com/download/dotnet/${MinDotnetMajor}.0"
   exit 1
}

$dotnetVersion = (dotnet --version 2>$null)
$dotnetMajor   = [int]($dotnetVersion -split '\.')[0]

if ($dotnetMajor -lt $MinDotnetMajor) {
   Write-Error "ERROR: .NET SDK $dotnetVersion found, but ${MinDotnetMajor}.0+ is required."
   exit 1
}

Write-Host "OK: .NET SDK $dotnetVersion"

# --- Check if tool is already installed ------------------------------------

$toolList = dotnet tool list -g 2>$null
if ($toolList -match $ToolName) {
   $match = ($toolList | Select-String $ToolName).ToString()
   Write-Host "OK: $match (already installed)"
   exit 0
}

# --- Install ---------------------------------------------------------------

Write-Host "Installing $ToolName globally..."

dotnet tool install -g $ToolName

if ($LASTEXITCODE -eq 0) {
   Write-Host "OK: $ToolName installed successfully."

   if (Get-Command $ToolCommand -ErrorAction SilentlyContinue) {
      Write-Host "OK: '$ToolCommand' command is on PATH."
   } else {
      Write-Warning "'$ToolCommand' not found on PATH. You may need to restart your terminal or add %USERPROFILE%\.dotnet\tools to your PATH."
   }
   exit 0
} else {
   Write-Error "ERROR: Failed to install $ToolName."
   exit 1
}
