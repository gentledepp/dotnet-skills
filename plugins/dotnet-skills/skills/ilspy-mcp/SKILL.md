---
name: ilspy-mcp
description: >
  Self-installing ILSpy MCP Server skill (8 tools). Decompile and analyze compiled .NET
  assemblies (DLLs) that are NOT available as source code — NuGet packages, framework
  libraries, third-party DLLs. Powered by ILSpy.
  ALWAYS trigger when the user asks to: decompile a type/method from a DLL, inspect a
  NuGet package's API surface, list types in a compiled assembly, analyze assembly
  architecture, find type hierarchies in DLLs, get type members from a library, search
  members in a compiled assembly, find extension methods in a NuGet package, understand
  how a library method works internally, reverse-engineer a .NET DLL, or explore an
  unfamiliar NuGet dependency.
  NEVER use for C# source code analysis — use roslyn-mcp instead.
  ONLY use for compiled assemblies (.dll files) without available source code.
  When in doubt whether to use this or roslyn-mcp: if the target is a .dll file (NuGet
  cache, bin folder, GAC, framework directory), use this skill. If the target is .cs
  source code in the current solution, use roslyn-mcp.
---

# ILSpy MCP Server — Usage Guide for Claude Code

This skill enables Claude Code to **decompile and analyze compiled .NET assemblies** (DLLs)
via the ILSpy MCP Server (NuGet: `ILSpyMcp.Server`, command: `ilspy-mcp`). It provides
**8 tools** for reverse-engineering .NET libraries that are only available as compiled code.

**Use this for:** NuGet packages, framework assemblies, third-party DLLs, bin-folder output.
**Use roslyn-mcp for:** C# source code in the current solution/project.

---

## Bootstrap: Auto-Install & Configure

**Before using any ILSpy tool**, ensure the server is installed and the MCP connection
is configured. Follow these steps in order — skip any step that is already satisfied.

### Step 1: Install the dotnet tool (if missing)

Run the bootstrap script bundled with this skill:

```bash
# Linux / macOS / WSL:
bash "$(dirname "$0")/scripts/ensure-ilspy-mcp.sh"

# Windows PowerShell:
powershell -ExecutionPolicy Bypass -File "$(dirname "$0")/scripts/ensure-ilspy-mcp.ps1"
```

**Or equivalently**, run these commands directly:

```bash
# Check if already installed
dotnet tool list -g | grep -i ILSpyMcp.Server

# If not found, install it (requires .NET 9.0+ SDK)
dotnet tool install -g ILSpyMcp.Server
```

If the `dotnet` command is not found or the SDK version is below 9.0, inform the user
they need to install the .NET 9 SDK from https://dotnet.microsoft.com/download/dotnet/9.0

### Step 2: Ensure MCP server is registered

Check if `ilspy-mcp` appears in the output of `/mcp`.
If not, register it:

**Per-project** (preferred) — create or update `.mcp.json` in the solution/repo root:

```json
{
  "mcpServers": {
    "ilspy-mcp": {
      "type": "stdio",
      "command": "ilspy-mcp",
      "args": []
    }
  }
}
```

**Or globally** via CLI:

```bash
claude mcp add ilspy-mcp --command "ilspy-mcp" --scope user
```

After adding the config, reconnect with `/mcp` or restart Claude Code.

### Step 3: Verify

Call one of the tools with a known assembly path to confirm the server is working:

```
Use the ilspy-mcp list_assembly_types tool for /path/to/some.dll
```

---

## When to Use ILSpy MCP Tools

Use these tools when the target is a **compiled .NET assembly** (DLL) without available
source code. Common scenarios:

### Trigger Patterns

**Exploring a NuGet Package**
- "What types does this NuGet package provide?" → `list_assembly_types`
- "Show me the API of [LibraryClass]" / "Was bietet [LibraryClass] an?" → `get_type_members`
- "How does [LibraryMethod] work internally?" → `decompile_method`
- "Decompile [TypeName] from the DLL" / "Dekompiliere [TypeName]" → `decompile_type`

**Understanding Assembly Architecture**
- "Give me an overview of this assembly" → `analyze_assembly`
- "What namespaces and patterns does this library use?" → `analyze_assembly`
- "What's the architecture of this DLL?" / "Wie ist diese DLL aufgebaut?" → `analyze_assembly`

**Finding Types and Members**
- "Search for methods named Parse in this DLL" → `search_members_by_name`
- "Find extension methods for IServiceCollection" → `find_extension_methods`
- "What inherits from BaseController in this assembly?" → `find_type_hierarchy`
- "Finde alle Methoden die Serialize heißen" → `search_members_by_name`

**Locating NuGet Assembly Paths**
NuGet packages are typically cached at:
- **Windows:** `%USERPROFILE%\.nuget\packages\<package-name>\<version>\lib\<tfm>\`
- **Linux/macOS:** `~/.nuget/packages/<package-name>/<version>/lib/<tfm>/`
- **Global packages:** Check `dotnet nuget locals global-packages --list`

Framework assemblies are typically at:
- **Windows:** `C:\Program Files\dotnet\shared\Microsoft.NETCore.App\<version>\`
- **Linux:** `/usr/share/dotnet/shared/Microsoft.NETCore.App/<version>/`

---

## Tool Quick Reference

All tools accept `assemblyPath` (absolute path to a `.dll` file) as a required parameter.
All operations are **read-only** — no files are modified.

### Assembly Exploration

- `list_assembly_types` — List all types in an assembly by namespace.
  Params: `assemblyPath` (required), `namespaceFilter` (optional, case-insensitive)

- `analyze_assembly` — High-level architectural overview: namespaces, key public types,
  design patterns.
  Params: `assemblyPath` (required), `query` (optional — e.g., "architecture overview",
  "public API surface")

### Type Inspection

- `decompile_type` — Full decompilation of a class/interface/struct with AI-analyzed
  insights about usage patterns.
  Params: `assemblyPath` (required), `typeName` (required — fully qualified),
  `query` (optional — e.g., "method implementations", "overall structure")

- `get_type_members` — Complete API surface (methods, properties, events) without
  implementation details. Faster than decompile_type when you just need signatures.
  Params: `assemblyPath` (required), `typeName` (required)

- `find_type_hierarchy` — Inheritance chain: base classes, interfaces, derived types.
  Params: `assemblyPath` (required), `typeName` (required)

### Method Analysis

- `decompile_method` — Decompile a specific method to understand its implementation,
  parameters, behavior, and side effects.
  Params: `assemblyPath` (required), `typeName` (required), `methodName` (required),
  `query` (optional — e.g., "algorithm logic", "error handling")

### Search & Discovery

- `search_members_by_name` — Find methods, properties, or fields by name across all
  types in the assembly.
  Params: `assemblyPath` (required), `searchTerm` (required, case-insensitive),
  `memberKind` (optional — "method", "property", "field", "event")

- `find_extension_methods` — Discover extension methods available for a specific type.
  Params: `assemblyPath` (required), `targetTypeName` (required — fully qualified)

---

## How to Use the Tools Effectively

### Preferred Workflow

1. **Locate the assembly path first.** Use absolute paths. Check NuGet cache or bin folder.
   Example: `~/.nuget/packages/newtonsoft.json/13.0.3/lib/net6.0/Newtonsoft.Json.dll`

2. **Start broad, then narrow down.**
   - `list_assembly_types` → discover available types
   - `get_type_members` → inspect a specific type's API
   - `decompile_method` → understand a specific method's implementation

3. **Use `analyze_assembly` for unfamiliar libraries.** It gives you the big picture
   before you dive into individual types.

4. **Use `get_type_members` before `decompile_type`.** It's faster when you just need
   to know what methods/properties are available.

5. **Combine tools for comprehensive understanding.**
   - "How do I use the JsonSerializer class?" →
     1. `get_type_members(typeName: "Newtonsoft.Json.JsonSerializer")` — see API surface
     2. `decompile_method(methodName: "Serialize")` — understand behavior
     3. `find_extension_methods(targetTypeName: "Newtonsoft.Json.JsonSerializer")` — discover helpers

### Updating the Tool

```bash
dotnet tool update -g ILSpyMcp.Server
```

---

## When NOT to Use ILSpy MCP Tools

- **C# source code in the current project/solution** — use roslyn-mcp instead
- **Non-.NET files** (JavaScript, Python, config files, etc.)
- **Text search across source files** — use grep/rg
- **Questions about C# language syntax** — use general knowledge
- **Refactoring or modifying code** — use roslyn-mcp (ILSpy is read-only)

**Rule of thumb:** If the file ends in `.cs` and is in your repo, use roslyn-mcp.
If the file ends in `.dll`, use ilspy-mcp.

## Language

The user communicates in both German and English. Respond in whichever language the user
is currently using. Symbol names in code are always English.
