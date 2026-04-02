#!/usr/bin/env bash
# ============================================================================
# ensure-roslyn-mcp.sh
# Ensures the RoslynMcp.Server dotnet global tool is installed.
# Returns 0 if already installed or successfully installed, 1 on failure.
# ============================================================================

set -euo pipefail

TOOL_NAME="RoslynMcp.Server"
TOOL_COMMAND="roslyn-mcp"
MIN_DOTNET_MAJOR=9

# --- Preflight: .NET SDK ---------------------------------------------------

if ! command -v dotnet &>/dev/null; then
  echo "ERROR: dotnet SDK not found. Install .NET $MIN_DOTNET_MAJOR+ from https://dotnet.microsoft.com/download/dotnet/$MIN_DOTNET_MAJOR.0"
  exit 1
fi

DOTNET_VERSION=$(dotnet --version 2>/dev/null || echo "0.0.0")
DOTNET_MAJOR=$(echo "$DOTNET_VERSION" | cut -d. -f1)

if [ "$DOTNET_MAJOR" -lt "$MIN_DOTNET_MAJOR" ]; then
  echo "ERROR: .NET SDK $DOTNET_VERSION found, but $MIN_DOTNET_MAJOR.0+ is required."
  echo "       Download from https://dotnet.microsoft.com/download/dotnet/$MIN_DOTNET_MAJOR.0"
  exit 1
fi

echo "OK: .NET SDK $DOTNET_VERSION"

# --- Check if tool is already installed ------------------------------------

if dotnet tool list -g 2>/dev/null | grep -qi "$TOOL_NAME"; then
  INSTALLED_VERSION=$(dotnet tool list -g 2>/dev/null | grep -i "$TOOL_NAME" | awk '{print $2}')
  echo "OK: $TOOL_NAME $INSTALLED_VERSION is already installed."
  exit 0
fi

# --- Install ---------------------------------------------------------------

echo "Installing $TOOL_NAME globally..."

if dotnet tool install -g "$TOOL_NAME"; then
  INSTALLED_VERSION=$(dotnet tool list -g 2>/dev/null | grep -i "$TOOL_NAME" | awk '{print $2}')
  echo "OK: $TOOL_NAME $INSTALLED_VERSION installed successfully."
  
  # Verify command is accessible
  if command -v "$TOOL_COMMAND" &>/dev/null; then
    echo "OK: '$TOOL_COMMAND' command is on PATH."
  else
    echo "WARN: '$TOOL_COMMAND' not found on PATH."
    echo "      You may need to add ~/.dotnet/tools to your PATH:"
    echo "      export PATH=\"\$HOME/.dotnet/tools:\$PATH\""
  fi
  exit 0
else
  echo "ERROR: Failed to install $TOOL_NAME."
  exit 1
fi
