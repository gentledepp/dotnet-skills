---
name: avalonia-devtools
description: >
  Self-installing Avalonia DevTools MCP Server skill (16 tools). Connect to running Avalonia
  applications to inspect visual trees, capture screenshots, modify properties, send input
  events, and iterate on XAML layouts via the previewer. Use this to verify UI correctness
  and design user interfaces for Avalonia apps.
  TRIGGER when the user asks to: verify an Avalonia UI, inspect the visual tree of an
  Avalonia app, take a screenshot of an Avalonia window/control, modify Avalonia control
  properties at runtime, design or iterate on an Avalonia UI layout, preview XAML changes,
  search for elements by type or x:Name, check applied styles or pseudo-classes, send
  click/key input to an Avalonia app, list or inspect resources/assets, or any task
  involving live inspection or manipulation of a running Avalonia application.
  REQUIRES the ACCELERATE_LICENSE_KEY environment variable to be set. If it is not set,
  direct the user to obtain their license key from the Avalonia customer portal at
  https://portal.avaloniaui.net/signin?returnUrl=%2F
---

# Avalonia DevTools MCP Server — Usage Guide for Claude Code

This skill enables Claude Code to **connect to running Avalonia applications and interact
with them directly** via the Avalonia DevTools MCP Server (command: `avdt mcp`). It provides
**16 tools** for inspecting visual trees, capturing screenshots, modifying properties,
sending input events, and iterating on XAML layouts via the previewer.

**Use this for:** Verifying UI correctness, designing Avalonia user interfaces, inspecting
control hierarchies, runtime property manipulation, and XAML previewing.

---

## MANDATORY: License Key Requirement

The Avalonia DevTools MCP server requires a valid **Accelerate license key**. The server
reads the key from the `ACCELERATE_LICENSE_KEY` environment variable.

**If the environment variable is not set**, you MUST inform the user:

> Your `ACCELERATE_LICENSE_KEY` environment variable is not set. You need a valid Avalonia
> Accelerate license key to use DevTools. Sign in to the Avalonia customer portal to obtain
> your key: https://portal.avaloniaui.net/signin?returnUrl=%2F
>
> Once you have your key, set it as an environment variable:
>
> **Windows (PowerShell):**
> ```powershell
> [System.Environment]::SetEnvironmentVariable('ACCELERATE_LICENSE_KEY', 'your-license-key', 'User')
> ```
>
> **Windows (Command Prompt):**
> ```cmd
> setx ACCELERATE_LICENSE_KEY "your-license-key"
> ```
>
> **macOS/Linux** (add to `~/.zshrc` or `~/.bashrc`):
> ```bash
> export ACCELERATE_LICENSE_KEY="your-license-key"
> ```
>
> Restart your terminal or editor after setting the variable.

For GUI-launched editors where environment variables may not propagate, add the key directly
to the MCP configuration using the `env` block (see Bootstrap Step 2 below).

---

## Application Preparation

Before DevTools can connect to an Avalonia application, the app must have diagnostics
support enabled.

### Step 1: Install the diagnostics NuGet package

```bash
dotnet add package AvaloniaUI.DiagnosticsSupport
```

### Step 2: Enable developer tools at startup

In `Program.cs`, add `.WithDeveloperTools()` to the app builder:

```csharp
public static AppBuilder BuildAvaloniaApp()
    => AppBuilder.Configure<App>()
        .UsePlatformDetect()
        .WithDeveloperTools();
```

Or in `App.axaml.cs`:

```csharp
public override void OnFrameworkInitializationCompleted()
{
    // ... your initialization code ...
    this.AttachDeveloperTools();
    base.OnFrameworkInitializationCompleted();
}
```

---

## Bootstrap: Auto-Install & Configure

**Before using any DevTools tool**, ensure the `avdt` CLI is installed and the MCP
connection is configured. Follow these steps in order — skip any step that is already satisfied.

### Step 1: Install the dotnet tool (if missing)

Run the bootstrap script bundled with this skill:

```bash
# Linux / macOS / WSL:
bash "$(dirname "$0")/scripts/ensure-avdt.sh"

# Windows PowerShell:
powershell -ExecutionPolicy Bypass -File "$(dirname "$0")/scripts/ensure-avdt.ps1"
```

**Or equivalently**, run these commands directly:

```bash
# Check if already installed
dotnet tool list -g | grep -i avdt

# If not found, install it (requires .NET 9.0+ SDK)
dotnet tool install -g avdt
```

If the `dotnet` command is not found or the SDK version is below 9.0, inform the user
they need to install the .NET 9 SDK from https://dotnet.microsoft.com/download/dotnet/9.0

### Step 2: Ensure MCP server is registered

Check if `avalonia_devtools` appears in the output of `/mcp`.
If not, register it:

**Per-project** (preferred) — create or update `.mcp.json` in the solution/repo root:

```json
{
  "mcpServers": {
    "avalonia_devtools": {
      "type": "stdio",
      "command": "avdt",
      "args": ["mcp"]
    }
  }
}
```

If the user's environment does not propagate environment variables to the editor, include
the license key directly:

```json
{
  "mcpServers": {
    "avalonia_devtools": {
      "type": "stdio",
      "command": "avdt",
      "args": ["mcp"],
      "env": {
        "ACCELERATE_LICENSE_KEY": "your-license-key"
      }
    }
  }
}
```

**Or globally** via CLI:

```bash
claude mcp add avalonia_devtools --command "avdt" --args "mcp" --scope user
```

After adding the config, reconnect with `/mcp` or restart Claude Code.

### Step 3: Verify

1. Confirm `avalonia_devtools` appears in the MCP server list (`/mcp`)
2. Start the Avalonia application you want to inspect
3. Use `attach-to-app` to connect and `tree` to confirm the visual tree loads

---

## Tool Quick Reference

### Connection

- `attach-to-app` — Connect to a running Avalonia application
- `attach-to-file` — Connect to the XAML previewer for layout iteration
- `detach` — Disconnect from the current session

### Inspection

- `tree` — Returns child elements of a node (pass `null` nodeId for root)
- `ancestors` — Returns parent chain from a node to the root
- `search` — Find elements by type or `x:Name`
- `screenshot` — Capture a PNG screenshot of an element

### Properties & Styles

- `props` — Get all property values for a node
- `set-prop` — Set a property value (use `null`/`unset` to clear)
- `styles` — View applied styles and setters for a node
- `pseudo-class` — Activate pseudo-classes on an element

### Resources & Assets

- `resources` — List application resources (optionally scoped to a node)
- `assets` — List embedded assets with their URLs
- `open-asset` — Download an asset by URL

### Interaction

- `input` — Send input events (click, key press) to an element
- `action` — Perform higher-level element actions

---

## How to Use the Tools Effectively

### Verifying UI Correctness

Use this workflow after generating or modifying Avalonia XAML/code-behind:

1. **Ensure the app is running** with `.WithDeveloperTools()` enabled
2. **Attach:** `attach-to-app` to connect to the running app
3. **Inspect the tree:** `tree` with `null` nodeId to get the root, then drill down
4. **Search for specific controls:** `search` by type (e.g., `Button`) or `x:Name`
5. **Capture screenshots:** `screenshot` to visually verify layout and appearance
6. **Check properties:** `props` to verify bindings, sizes, margins, colors are correct
7. **Check styles:** `styles` to verify that the right styles are applied

### Designing & Iterating on UI

Use this workflow when designing new Avalonia interfaces:

1. **Use the previewer:** `attach-to-file` to connect to a XAML file for rapid iteration
2. **Modify properties live:** `set-prop` to experiment with values without recompiling
3. **Test pseudo-classes:** `pseudo-class` to see hover, pressed, focus states
4. **Send input:** `input` to simulate user interactions and verify behavior
5. **Screenshot iterations:** `screenshot` to capture and compare design iterations

### Preferred Workflow

1. **Always check the license key first.** Before any DevTools operation, verify that
   `ACCELERATE_LICENSE_KEY` is available. If not, direct the user to the portal.

2. **Attach before inspecting.** All inspection tools require an active connection via
   `attach-to-app` or `attach-to-file`.

3. **Use `tree` to orient yourself.** Start from the root and navigate the visual hierarchy
   to understand the layout structure.

4. **Combine `search` + `props` + `screenshot`** for quick verification — find the element,
   check its properties, and visually confirm.

5. **Detach when done.** Use `detach` to cleanly disconnect from the application.

---

## When NOT to Use Avalonia DevTools

- **Non-Avalonia applications** (WPF, WinForms, MAUI, web apps, etc.)
- **C# code analysis or refactoring** — use roslyn-mcp instead
- **Decompiling DLLs** — use ilspy-mcp instead
- **Static XAML validation** without a running app — use general knowledge or Roslyn
- **The app is not running** — DevTools requires a live connection to the application

## Language

The user communicates in both German and English. Respond in whichever language the user
is currently using. Symbol names in code are always English.
